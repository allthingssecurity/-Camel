# A routing slip (or dynamic router) routes to a recipient list's endpoints instead of its own

Status: code-bug candidate. Found by the L2 route differential's hang detection in the combo family
(runs/combo-real1, case combo-11-1902; also combo-11-77 and combo-11-1563, which have the same cause). Minimized with
tools/minimize.py and by hand, then reproduced in plain Java. Camel aa63c0a4cb94, and also the released 4.22.1 and
4.23.0 jars from ~/.m2, so it is not a recent regression.

It is not the known routing-slip hang (findings/2026-10-26-hang-routingslip-dotry-redelivery-lost-callback.md, the lost
SLIP_PRODUCER). All three cases still hang with that bug patched (the red-team's restore of SLIP_PRODUCER, plus a guard
that fails the exchange when the property is missing, compiled as a classpath overlay). They return once the routing
slip ignores the stale value described below.

Severity guess: **high**. A message goes to the wrong endpoints, and the endpoints the route names never get it.
- The slip's own destination never receives the message.
- The recipient list's destinations receive it from the slip, at a point where the recipient list itself was skipped.
- When the stale text is not a valid endpoint for the slip's delimiter, the send blocks for 30 s (the direct: consumer
  timeout). The harness reports that as HANG. Then the dead letter channel gets a DirectConsumerNotAvailableException.

## Docs

- routingSlip-eip.adoc and dynamicRouter-eip.adoc: the slip is "the expression" of the EIP. No page says that a
  routing slip can take its endpoints from another EIP.
- recipientList-eip.adoc 4: each recipient gets a copy of the message.
- doTry-eip.adoc 9-10 and 27: doTry/doFinally "mimics how try/catch/finally works in Java", so a finally block runs all
  its steps.
- The exchange property involved, `CamelEvaluateExpressionResult` (Exchange.java:141), is not documented for users.

## Mechanism (lines at the pin)

1. `RecipientListReifier.java:95-113` builds a recipient list as a pipeline of two processors:
   `EvaluateExpressionProcessor` and then `RecipientListProcessor`.
2. `EvaluateExpressionProcessor.java:43` stores the evaluated list in the exchange property
   `CamelEvaluateExpressionResult`. `RecipientListProcessor.java:248` removes it, but only when it runs.
3. The inner pipeline stops between the two processors when the exchange is already marked as handled by an error
   handler (`PipelineHelper.java:40-43`, "Handled by the error handler").
   - That happens in a doFinally after a direct: call whose route failed and was handled by its error handler (a dead
     letter channel, or `onException(...).handled(true)`). The doFinally then runs only its first step.
   - The main session found that part independently: findings/2026-10-26-dofinally-only-first-step-after-handled-direct.md
     and harness/probes/FinallyFirstStepProbe.java. When the first step
     is a recipient list, only the evaluation runs. The value stays on the exchange and nothing is sent.
4. `RoutingSlip.java:204` (`process`) takes any `CamelEvaluateExpressionResult` it finds as its slip, in place of its
   own expression. `DynamicRouter` extends `RoutingSlip` (`DynamicRouter.java:32`), so it does the same.
   - Only the recipient list's evaluator ever sets this property, so a routing slip that runs later on the same
     exchange routes to the recipient list's value.
   - "Later" can be the first step of the caller's own doFinally, a redelivery of an enclosing step, or a later step
     after the handled state is cleared.

## Minimal reproducer (harness/probes/StaleRecipientsProbe.java, variant `slip`)

```java
errorHandler(deadLetterChannel("mock:dead"));
from("direct:r0").doTry().to("direct:r2").doFinally().routingSlip(constant("mock:slip")).end();
from("direct:r2").doTry().to("direct:r3").doFinally().recipientList(constant("mock:a,mock:b")).end();
from("direct:r3").throwException(new java.io.IOException("r3 failed"));

template.send("direct:r0", e -> e.getMessage().setBody("b"));
// mock:slip receives NOTHING; mock:a receives the message (from the routing slip); mock:dead receives it once
```

## Which ingredients are needed (StaleRecipientsProbe; the same on aa63c0a4cb94, 4.22.1 and 4.23.0)

| variant | mock:slip | mock:a | mock:b | result |
|---|---|---|---|---|
| as above (dead letter channel) | 0 | **1** | 0 | wrong destination |
| `onException(Exception.class).handled(true)` instead of the DLC | 0 | **1** | 0 | wrong destination |
| `dynamicRouter` (a bean that returns mock:slip once) instead of the slip | 0 | **1** | 0 | wrong destination |
| r2's doFinally has a further step after the recipient list (`slip-sameRoute`) | 0 | **1** | 0 | wrong destination |
| no error handler (default; the failure is not handled) | 1 | 1 | 1 | correct (exception IOException) |
| r3 does not fail | 1 | 1 | 1 | correct |
| `recipientList(constant("mock:slip"))` in r0's doFinally | 0 | 0 | 0 | its own evaluation overwrites the value, then it is skipped too |
| routing slip that ignores the property (overlay) | 1 | 0 | 0 | correct for the slip; the recipient list is still skipped (the doFinally part) |

Only mock:a receives the message, not mock:b. The routing slip's own pipeline stops after its first destination for
the same handled-state reason.

## The campaign case (harness/probes/StaleSlipBlockRepro.java)

- The dead letter channel has `maximumRedeliveries(1)`.
- r0: `failover { doTry { throw ISE } doFinally { routingSlip("direct:r2") } }`.
- r2: a nested doTry/doFinally (calling r3, which fails) inside a doTry whose doCatch has
  `doTry { to mock:m2 } doFinally { recipientList("direct:r3;direct:r3", ";") }`.

What happens:
1. The DLC handles the r3 failure, and the doCatch's doFinally evaluates the list without running it.
2. The failover's error handler redelivers r0's doTry.
3. The doFinally routing slip then resolves `"direct:r3;direct:r3"` (with its delimiter ",") as one endpoint,
   `direct://r3;direct:r3`, which has no consumer.
4. The send blocks for 30 s and then returns with exception null (the DLC took the DirectConsumerNotAvailableException).

| variant (StaleSlipBlockRepro / harness variants) | result |
|---|---|
| as above | blocks 30 s (HANG at the harness's 4-10 s) |
| default error handler instead of the DLC | returns (ISE) |
| DLC with maximumRedeliveries 0 | returns |
| no failover (doTry directly in r0) | returns (ISE) |
| `to("direct:r2")` instead of the slip in r0's doFinally | returns |
| recipient list with a single entry `direct:r3` | returns |
| recipient list without aggregation strategy | blocks |

## Fix idea

- Make the property private to the recipient list. `RecipientListProcessor` could own the evaluated value (for example
  under a key unique to the processor), or the reifier could pass it without an exchange property.
- `RoutingSlip.process` should not read a value it did not set. Nothing in the routing slip reifier sets
  `CamelEvaluateExpressionResult` at the pin.
- Separately, the doFinally truncation (findings/2026-10-26-dofinally-only-first-step-after-handled-direct.md) makes the
  stale value possible in the first place. The defect reported here is a routing slip that reads a
  property it does not own. The truncation is the one way found so far to leave that property behind.
