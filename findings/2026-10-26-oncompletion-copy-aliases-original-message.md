# An AfterConsumer onCompletion changes the caller's exchange when it and the dead letter channel use the original message

Status: code-bug candidate. Found by the L3 differential (runs/oc2-dlc-real, dlc-503-3848). Reproduced in plain Java
DSL (harness/probes/OcDlcAliasProbe.java) on Camel aa63c0a4cb94.

Severity guess: low to medium. The onCompletion copy, which "should not interfere", writes into the exchange the
caller gets back. With parallelProcessing it is a second thread writing to that message while the caller reads it.
I did not test that case.

## Docs
- oncompletion.adoc 37-43: "Camel spins off a copy of the Exchange and routes it in a separate thread, similar to a
  Wire Tap ... We chose this model as we did not want the onCompletion route to interfere with the original route."
- model onCompletion.useOriginalMessage: "Will use the original input message".
- dead-letter-channel.adoc 230-291: useOriginalMessage moves the original input message to the dead letter queue.

## Reproducer
```java
errorHandler(deadLetterChannel("mock:dead").useOriginalMessage());
RouteDefinition r = from("direct:a");
r.onCompletion().useOriginalMessage().setBody(constant("oc-mutated")).setHeader("h", constant("oc")).end();
r.setBody(constant("changed")).throwException(new IllegalArgumentException("x"));
Exchange x = template.send("direct:a", e -> e.getMessage().setBody("original"));
```

| DLC useOriginalMessage | onCompletion useOriginalMessage | route fails | caller gets |
|---|---|---|---|
| yes | yes | yes | **oc-mutated, h=oc** |
| yes | no | yes | original |
| no | yes | yes | changed |
| no | no | yes | changed |
| any | any | no | changed |

## Cause (Camel at the pin; to confirm in the red-team)
- When the dead letter channel uses the original message, it sets the unit of work's stored original IN message on the exchange.
- `OnCompletionProcessor.prepareExchange` takes the correlated copy and then calls `answer.setIn(original)` with
  `ExchangeHelper.getOriginalInMessage(exchange)`, which is the same stored instance (OnCompletionProcessor.java
  418-423).
- The caller's exchange and the onCompletion copy therefore share one Message object. The copy's setBody and
  setHeader change the caller's message.
- Fix sketch: copy the original message (`original.copy()`) before setting it, in OnCompletionProcessor (and in the
  error handler's use of it).

## Spec
- Doc mode: L3.onCompletion. The caller's exchange is unchanged by an AfterConsumer onCompletion.
- Real mode: the delta L3.onCompletion.alias.real. No rule for an AfterConsumer onCompletion with useOriginalMessage
  after the dead letter channel moved the original message.
