# doCatch no longer catches after a called route "continued" a failure (4.23.0 regression)

Status: code-bug candidate. Found by the L2 route differential (combo family, Real mode, runs/combo-ov2hunt case
combo-21-188), reduced by hand and reproduced in plain Java DSL (harness/probes/ContinuedCalleeProbe.java).
- **Camel aa63c0a4cb94 and 4.23.0: wrong. 4.22.1: correct.**
- This is a regression from CAMEL-25115 (commit e7d5f2c4d74f, "Error handler failure paths: fix bugs found in a deep
  review", 2026-09-28, first released in 4.23.0).

Severity guess: **high**.
- A matching `doCatch` is silently skipped, so the exception escapes the `doTry`, and the exchange fails where the user
  wrote a handler. The handler steps (compensation, error replies, ...) never run.
- The trigger is a common shape: inside a `doTry`, a call (to direct:, routing slip, dynamic router or recipient list)
  into a route where an `onException(...).continued(true)` ignored a failure, followed by any later exception in the
  same doTry body.

## Docs

- exception-handling-patterns.adoc 416-418: `continued` "allows you to both handle and continue routing in the original
  route as if the exception did not occur".
- doTry-eip.adoc 211-213: "the first doCatch that matches is used ... the exception and its causes are matched".
- doTry-eip.adoc 9-10, 27: doTry mimics Java try/catch.
- No page says that an earlier, continued failure disables the doCatch blocks of an enclosing doTry.

## Minimal reproducer (ContinuedCalleeProbe, `continued` / `to` / doTry=true)

```java
onException(NumberFormatException.class).continued(true);
from("direct:r2")
    .doTry()
        .to("direct:callee")                                    // fails; onException continues it
        .to("mock:next")                                        // runs (correct)
        .throwException(new IllegalStateException("after the call"))
    .doCatch(IllegalStateException.class)
        .to("mock:catch")                                       // NEVER runs on aa63c0a4cb94 / 4.23.0
    .end();
from("direct:callee").throwException(new NumberFormatException("in callee")).to("mock:calleeEnd");

Exchange x = template.send("direct:r2", e -> e.getMessage().setBody("b"));
// 4.23.0: mock:catch = 0, x.getException() = IllegalStateException("after the call")
// 4.22.1: mock:catch = 1, x.getException() = null
```

## Ingredients (ContinuedCalleeProbe; aa63c0a4cb94 and 4.23.0 are the same; 4.22.1 catches in every row)

| inside the doTry, before the throw | callee | mock:catch | exception after the send |
|---|---|---|---|
| nothing (control) | | 1 | - |
| `to("direct:calleeOk")` (the callee does not fail) | ok | 1 | - |
| `to("direct:callee")` | fails, continued | **0** | **IllegalStateException** |
| `routingSlip("direct:callee")` | fails, continued | **0** | **IllegalStateException** |
| `dynamicRouter` to the callee | fails, continued | **0** | **IllegalStateException** |
| `recipientList("direct:callee")` | fails, continued | **0** | **IllegalStateException** |
| the same without the doTry | fails, continued | (no catch) | IllegalStateException (correct) |
| `handled(true)` instead of `continued(true)` | fails, handled | 0 | - (the caller stops routing, a separate known effect) |

The campaign case, combo-21-188:
- The pin's expected trace has the doCatch block of r2. In route r2, a dynamic router goes to a route whose failure an
  `onException(Exception).onWhen(...).continued(true)` with redelivery deals with. A `throwException` then follows in
  r2's doTry body.
- Camel skips r2's `doCatch(RuntimeException)`: 12 mock events instead of the 14 the rules give.
- It agrees with the spec once the doCatch runs. A classpath overlay that changes CatchProcessor.java:135 to
  `Boolean.TRUE.equals(...)` makes the case agree with the rules on all 3 sends. With the same overlay, every
  ContinuedCalleeProbe row catches.

## Mechanism (lines at the pin)

- `RedeliveryErrorHandler.java:1395-1399` (added by e7d5f2c4d74f): when an onException `continued` the exchange, the
  caught exception is stored in the exchange property `CamelExceptionHandled` (EXCEPTION_HANDLED). The intent was "so
  it is not regarded as a previous exception of a later failure".
- `CatchProcessor.java:134-138`: a doCatch exits WITHOUT matching when `EXCEPTION_HANDLED` is set ("If a previous catch
  clause handled the exception"). The property was meant for sibling doCatch blocks of one doTry.
- `TryProcessor.java:114` clears the property only when the doTry starts. A continued failure DURING the doTry body
  (in a called route: direct: shares the exchange) leaves it set, so every doCatch of that doTry is skipped for any
  later exception.

## Fix idea

- Use a marker that is private to the error handler for the "continued" memory (or compare against the exception
  itself), and do not reuse `EXCEPTION_HANDLED`, which means "caught by a doCatch".
- Alternatively, CatchProcessor could treat EXCEPTION_HANDLED as "already caught" only when it holds `Boolean.TRUE`,
  which is what CatchProcessor.java:174 sets, and not an exception object.
- A test: the reproducer above, expected `mock:catch` = 1.
