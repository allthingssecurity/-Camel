# A blocking send never returns: routing slip + nested doTry/doFinally + onException with redelivery (lost callback)

Status: code-bug candidate (found by the L2 route differential's hang detection, runs/sup-real random-137-1210,
minimized with tools/minimize.py, reproduced in plain Java DSL). Camel aa63c0a4cb94, also 4.22.1 and 4.23.0 (released
jars from ~/.m2): not a recent regression.
Severity guess: medium-high (ProducerTemplate.send / the consumer thread blocks forever; no Camel thread is working —
an async callback is never called, so the exchange is in flight forever and the calling thread is lost).

## Docs
No documentation allows a hang: error-handler.adoc 29-32 (the exception propagates back to the caller), doTry-eip.adoc
221-229, routingSlip-eip.adoc 82 (pipeline fashion), exception-redelivery.adoc 110-126 (redelivery at the point of
failure). The L2 rules give a result for this route (no UNSPECIFIED step).

## Minimal reproducer (harness/probes/HangRepro.java)
```java
onException(IllegalStateException.class).handled(true).maximumRedeliveries(1).redeliveryDelay(0);
from("direct:r0").routingSlip(constant("mock:m2,direct:r1,direct:r1"));
from("direct:r1")
    .doTry()
        .doTry()
            .throwException(new IllegalStateException("y"))
        .doFinally()
            .to("direct:r2")
        .endDoTry()
    .endDoTry()
    .doFinally()
    .end();
from("direct:r2").doTry().routingSlip(constant("mock:m1")).endDoTry().doFinally().end();

template.send("direct:r0", e -> e.getMessage().setBody("y"));   // never returns
```
jstack: the sending thread parks in DefaultAsyncProcessorAwaitManager.await (from DefaultProducerTemplate.send), no
Camel thread alive or runnable, CPU idle.

## Every ingredient is needed (harness/probes/HangProbe.java; each variant removes one)
| variant | result |
|---|---|
| as above | HANG |
| no redelivery (maximumRedeliveries 0) | returns |
| not handled (handled not set) | returns |
| no onException | returns |
| slip "direct:r1" once | returns |
| to("direct:r1") instead of the slip | returns |
| no outer doTry in r1 | returns |
| r2 without its doTry (plain routing slip) | returns |
| r2's doTry around to("mock:m1") instead of the slip | returns |
| redeliveryDelay 0 / 1 / 50 ms | HANG in all |

## Where to look (for the red-team)
The redelivery of the failed throwException inside the nested doTry, whose doFinally re-enters a doTry with a routing
slip, while the outer routing slip is on its second direct:r1 step: one of RoutingSlip / TryProcessor / FinallyProcessor
/ RedeliveryErrorHandler does not call the AsyncCallback (or calls it on a path that is dropped) after a handled
exception. Not traced to the line yet.

## Second occurrence
runs/yaml2-real random-154-3912 (found through the YAML DSL run, hangs with the model API too): a routing slip
"mock:m2,direct:r1", onException clauses with redelivery, doTry in the called route; same family.
