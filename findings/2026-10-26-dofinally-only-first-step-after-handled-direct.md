# doFinally runs only its first step when the doTry body called a route whose error handler handled the failure

Status: code-bug candidate. Found by the L3 dead letter channel differential (runs/dlc4-real, dlc-406-3078 and
dlc-406-4427; XML DSL dlc-407-2338). Reproduced in plain Java DSL, on Camel aa63c0a4cb94, 4.22.1 and 4.23.0 (released
jars from ~/.m2). Not a recent regression.

Severity guess: medium. The cleanup in a doFinally is cut short silently: no exception, no log at INFO. The steps
that are skipped are exactly the ones users put there because they must "always" run (release a lock, write an
audit record, compensate). It happens whenever the doTry body calls a route (direct:) whose error handler handled a
failure. That covers a dead letter channel, which is a common production setup, and also onException(...).handled(true).

## Docs
- doFinally: "steps to always execute after a doTry block completes, regardless of whether an exception was thrown
  or caught" (model/doFinally.json, description; try-catch-finally in doTry-eip.adoc).
- dead-letter-channel.adoc 186-188: after the move to the dead letter queue, "The exchange is then complete, and from
  the client point of view, the message is done being processed".

Read together, either all the doFinally steps run (doFinally "always"), or none do (the exchange is complete).
Camel runs exactly the first one.

## Minimal reproducer (harness/probes/FinallyFirstStepProbe.java)
```java
errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));      // or: onException(IAE.class).handled(true)
from("direct:a")
    .doTry().to("direct:b")
    .doFinally().to("mock:f1").to("mock:f2").setHeader("f3", constant("yes")).to("mock:f4").end()
    .to("mock:end");
from("direct:b").setBody(constant("in-b")).throwException(new IllegalArgumentException("x"));
```

| variant | dead | f1 | f2 | f3 header | f4 | end |
|---|---|---|---|---|---|---|
| direct:b does not fail | 0 | 1 | 1 | yes | 1 | 1 |
| direct:b fails, dead letter channel | 1 | 1 | **0** | **null** | **0** | 0 |
| direct:b fails, onException(...).handled(true) | 1 | 1 | **0** | **null** | **0** | 0 |

The same holds on 4.22.1 and 4.23.0. In the random runs, the second and later doFinally steps were skipped in every
case: a transform followed by a direct: call, a setBody followed by a setHeader, a setVariable followed by a
setProperty.

## Cause (Camel at the pin)
- The doFinally block is a Pipeline. `Pipeline.run` always runs the first processor (`first || continueProcessing(...)`,
  Pipeline.java 94-96). Before each later one, it calls `PipelineHelper.continueProcessing`, which returns false when
  `exchange.getExchangeExtension().isErrorHandlerHandled()` (PipelineHelper.java 40-43).
- The called route's error handler set that flag when it handled the failure.
- `FinallyProcessor.process` clears the exception before it runs the block, but not the errorHandlerHandled flag.
- Result: the first step runs, the pipeline then breaks out "Handled by the error handler", and the rest are skipped.

## Spec
- Doc mode: L3.doFinally.after-complete. All the doFinally steps run, then the exchange is complete again, so the
  route does not go on.
- Real mode: the delta L3.doFinally.after-complete.real, a doFinally entered with a complete exchange: no rule.
