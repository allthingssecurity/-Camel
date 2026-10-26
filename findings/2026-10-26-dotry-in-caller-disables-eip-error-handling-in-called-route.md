# A doTry in the caller changes error handling in the called route: duplicate deliveries, lost redeliveries, lost failures

Status: code-bug candidate. Found while the combo campaign was classifying hangs: reading why the routing slip's
per-step error handler is skipped. Confirmed with a plain Java DSL probe (harness/probes/TryBlockLeakProbe.java).
Camel aa63c0a4cb94, and also the released 4.22.1 and 4.23.0 jars from ~/.m2, with identical results. Not a recent
regression.

Severity guess: **medium-high**. The same route behaves differently depending on whether its caller wrapped the call in
a `doTry`, even a doTry that has only a doFinally:
- A routing slip redelivers the WHOLE slip, so endpoints that already succeeded get the message again (duplicates).
- A multicast or recipient list loses the configured redelivery completely: one attempt.
- A dynamic router written like the documented example (a bean that counts its invocations in an exchange property,
  dynamicRouter-eip.adoc 137-145) loses the failure. The send returns with no exception, and the failed step is never
  retried.

## Docs

- exception-redelivery.adoc 110-126: "All redelivery attempts start at the point of the failure", "not the complete
  route".
- split-eip.adoc 1667: "error handling still applies for the sub messages". The same per-output handling is implemented
  for multicast, recipient list, routing slip and dynamic router (MulticastProcessor/RoutingSlip `createErrorHandler`:
  "fine grained error handling on the output side ... to support redelivery on that output alone").
- doTry-eip.adoc 221-225 limits the doTry exception (no onException, redelivery or dead letter channel) to "the steps of
  a `doTry ... doCatch ... doFinally` block". The called route is another route with its own error handler.
  - A plain `to()` in that called route still gets its redeliveries (table row `enrichLike`).
  - Only the EIPs with per-output error handlers change.

## Mechanism (lines at the pin)

- `TryProcessor.java:128` sets the exchange property `TryRouteBlock=true` while the doTry's steps run. It is restored in
  `TryProcessor.java:141-145` when the doTry ends.
- direct: hands the SAME exchange to the called route, so the property is still true there.
- `RoutingSlip.java:382-390` (`createErrorHandler`) and `MulticastProcessor.java:1191-1194` (`wrapInErrorHandler`, used
  by multicast, by recipient list at `RecipientListProcessor.java:370`, and inherited by `Splitter`; split was not
  probed) read the property: "do not wrap in error handler if we are inside a try block".
  - They then skip the per-output error handler, even though the EIP is not inside a doTry of its own route.
  - The node's normal channel error handler in the called route still applies. For a routing slip, that error handler
    redelivers the whole slip from the start.
  - For multicast and recipient list, no redelivery happens at all.

## Minimal reproducer (TryBlockLeakProbe, `doTryFinally` + `slip`)

```java
onException(IllegalStateException.class).maximumRedeliveries(2).redeliveryDelay(0);
from("direct:r0").doTry().to("direct:r1").doFinally().to("mock:fin").end();    // without the doTry: correct
from("direct:r1").routingSlip(constant("mock:m1,direct:fail"));
from("direct:fail").errorHandler(noErrorHandler())                               // an output whose producer fails
    .process(e -> { throw new IllegalStateException("boom"); });

template.send("direct:r0", e -> e.getMessage().setBody("b"));
// plain caller:  mock:m1 = 1, fail attempts = 3 (redelivery of the failed step only)
// doTry caller:  mock:m1 = 3 (DUPLICATES), fail attempts = 3 (the whole slip is redelivered)
```

## Results (TryBlockLeakProbe; identical on aa63c0a4cb94, 4.22.1 and 4.23.0)

| caller of r1 | EIP in r1 | mock:m1 | attempts on the failing output | exception at the caller |
|---|---|---|---|---|
| `to("direct:r1")` | routing slip | 1 | 3 | ISE |
| `to("direct:r1")` | multicast | 1 | 3 | ISE |
| `to("direct:r1")` | recipient list | 1 | 3 | ISE |
| `to("direct:r1")` | dynamic router (counting bean) | 1 | 3 | ISE |
| `to("direct:r1")` | plain `to(mock:m1).to(direct:fail)` | 1 | 3 | ISE |
| doTry/doFinally around the call | routing slip | **3** | 3 | ISE |
| doTry/doFinally around the call | multicast | 1 | **1** | ISE |
| doTry/doFinally around the call | recipient list | 1 | **1** | ISE |
| doTry/doFinally around the call | dynamic router (counting bean) | 1 | **1** | **none: failure lost** |
| doTry/doFinally around the call | plain `to` | 1 | 3 | ISE |
| doTry/doCatch(IOException) around the call (not matching) | the same five | the same as doTry/doFinally | | |
| doTry/doCatch(Exception) around the call | the same five | the same counts; the doCatch handles | | |

For the dynamic router: the whole router node is redelivered. The counting bean then returns null (it already returned
mock:m1 and direct:fail), so the redelivery "succeeds" without retrying the failed step, and the failure disappears. The probe counts 4 bean
calls with the doTry caller (mock:m1, direct:fail, then null on each of the 2 redeliveries) against 3 with the plain
caller.

## Fix idea

The try-block flag should only cover the doTry's own route. Two options:
- TryProcessor could scope the property to the route, for example by storing the route id and comparing it with
  `ExchangeHelper.getRoute(exchange)` in RoutingSlip/MulticastProcessor.
- The direct: producer could clear and restore it around the call, the same as other route-scoped state.

## Relation to other findings

- It explains part of the redelivery behaviour of the known routing-slip hang shape: with a doTry in the caller, the
  inner slip has no per-step error handler.
- It is not the same defect. Here nothing hangs, and the trigger is only a doTry in the caller plus a per-output EIP in
  the called route.
