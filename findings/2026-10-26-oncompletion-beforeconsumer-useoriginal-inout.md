# onCompletion(mode=BeforeConsumer, useOriginalMessage) ignores the original message for InOut exchanges

Status: code-bug candidate. Found by the L3 onCompletion differential (runs/oc1-real, oc-501-2748). I minimized it
with a dead-mock marker, then reproduced it in plain Java DSL (harness/probes/OcBeforeOriginalProbe.java) on Camel
aa63c0a4cb94.

Severity guess: low to medium. In BeforeConsumer mode an onCompletion with useOriginalMessage does not get the
original message, but only when the exchange is InOut. For an InOnly exchange it does. Either way the result is
silent. In BeforeConsumer mode the onCompletion's message is also what the caller receives (oncompletion.adoc
418-421), so the caller's response depends on the message exchange pattern.

## Docs
- model/onCompletion.json useOriginalMessage: "Will use the original input message when an Exchange for this on
  completion".
- oncompletion.adoc 418-421: BeforeConsumer "allows the onCompletion to modify the Exchange".
- Nothing says that the exchange pattern changes which message the onCompletion gets.

## Reproducer (harness/probes/OcBeforeOriginalProbe.java)
```java
RouteDefinition r = from("direct:a");
r.onCompletion().useOriginalMessage().modeBeforeConsumer().to("mock:oc").end();
r.setBody(constant("changed")).setHeader("h", constant("changed"));
template.send("direct:a", ExchangePattern.InOut, e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
```

| mode | MEP | onCompletion sees | caller gets |
|---|---|---|---|
| AfterConsumer | InOnly | original / h=original | changed / h=changed |
| AfterConsumer | InOut | original / h=original | changed / h=changed |
| BeforeConsumer | InOnly | original / h=original | original / h=original |
| BeforeConsumer | InOut | **changed / h=changed** | changed / h=changed |

## Cause (Camel at the pin)
`OnCompletionProcessor.prepareExchange` (lines 384-427):
- The copy is used for AfterConsumer and parallel processing. It moves OUT to IN (`if (answer.hasOut()) { answer.setIn(answer.getOut()); answer.setOut(null); }`) before `if (useOriginalBody) answer.setIn(original)`.
- In BeforeConsumer mode the exchange is used as it is (`answer = exchange`), and only the IN message is replaced.
- The InOut exchange still has its OUT message, which `getMessage()` returns. So the onCompletion steps see, and leave, the current message.
- Fix sketch: move OUT to IN, or clear OUT, in the as-is branch too, before setting the original IN.

## Spec
- Doc mode: L3.onCompletion with L3.onCompletion.before. The steps start from the original message, and the caller
  gets what they leave.
- Real mode: the delta L3.onCompletion.before-original.real. For an InOut exchange in BeforeConsumer mode with
  useOriginalMessage there is no rule.

## Also InOnly, after a transform (main session, runs/sc3-xml-real scope-717-829)
In the harness, model API and XML DSL alike, an InOnly send reproduces it as soon as the route used `transform`:
`transform(header B1)` or `transform(constant zz)` makes the BeforeConsumer + useOriginalMessage onCompletion see the
current message. `setBody` does not. A Java DSL probe (OcBeforeOriginalProbe, transform variant) did not reproduce
it for InOnly. The red-team should check what differs: the route built through RoutesDefinition.prepareRoute, or
setUseOriginalMessage("true") against useOriginalMessage(). Plausibly the same cause, an OUT message that the as-is
branch of prepareExchange leaves in place. The Real-mode delta now covers every MEP.
