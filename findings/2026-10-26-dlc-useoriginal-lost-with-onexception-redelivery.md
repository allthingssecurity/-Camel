# Dead letter channel useOriginalMessage / useOriginalBody is ignored when an onException overrides the redelivery

Status: code-bug candidate. Found by the L3 differential (runs/oc1-real, oc-501-70) through the rule
L3.dlc.clause-redelivery. Reproduced in plain Java DSL on Camel aa63c0a4cb94, 4.22.1 and 4.23.0 (released jars from
~/.m2). Not a recent regression.

Severity guess: medium. The dead letter queue silently gets the modified message instead of the original one. The
documented reason to set useOriginalMessage is to retry by hand, by moving the dead letter message back to the
input queue (dead-letter-channel.adoc 332-333, quoted below). With the documented per-exception redelivery override,
that retry processes a half-transformed message. Nothing reports it.

## Docs
- dead-letter-channel.adoc 230-333: "By enabling useOriginalMessage on the dead letter channel, then the message
  moved to the dead letter queue would be the original incoming message", and "If we want to manually retry, we can
  move the JMS message from the failed to the input queue, with no problem as the message is the same as the original
  we received". Also the useOriginalBody note (289-291).
- exception-redelivery.adoc 27-62: "Sometimes you want to configure the redelivery policy on a per exception type
  basis", with `onException(ValidationException.class).maximumRedeliveries(2);`. The clause has no steps. Only the
  redelivery is configured, and the failure still goes to the dead letter channel ("Only when all redelivery
  attempts have failed, then the message is moved to the dead letter queue", dead-letter-channel.adoc 140).

No page says that adding such a clause turns the dead letter channel's useOriginalMessage off.

## Minimal reproducer (harness/probes/DlcOriginalViaClauseProbe.java)
```java
errorHandler(deadLetterChannel("mock:dead").useOriginalMessage().redeliveryDelay(0));
onException(IllegalArgumentException.class).maximumRedeliveries(2).redeliveryDelay(0);   // per-exception redelivery
from("direct:a").setBody(constant("changed")).setHeader("h", constant("changed"))
    .throwException(new IllegalArgumentException("x"));
// send body "original", header h=original
```

| dead letter channel | onException clause | message in mock:dead |
|---|---|---|
| useOriginalMessage | none | original / h=original |
| useOriginalMessage | another exception class | original / h=original |
| useOriginalMessage | matching, maximumRedeliveries(2) | **changed / h=changed** |
| useOriginalMessage | matching, maximumRedeliveries(0) | **changed / h=changed** |
| useOriginalBody | none | original / h=changed |
| useOriginalBody | matching, maximumRedeliveries(2) | **changed / h=changed** |

The results are the same on 4.22.1 and 4.23.0.

## Cause (Camel at the pin)
- `RedeliveryErrorHandler.RedeliveryTask` first resets to the error handler defaults (`useErrorHandlerDefaults`,
  lines 1085-1097). That sets `useOriginalInMessage = useOriginalMessagePolicy`, which is the dead letter channel's
  setting.
- When an exception policy matches, it overwrites both flags unconditionally:
  `useOriginalInMessage = exceptionPolicy.isUseOriginalInMessage(); useOriginalInBody = exceptionPolicy.isUseOriginalInBody();`
  (lines 1492-1493, and the same at 543-544).
- The clause did not set them, so they are false. The clause has no failure processor, so the dead letter endpoint
  is still the one used, but now with the current message.
- Fix sketch: take the policy's flags only when the onException configures them, or when it has its own failure
  processor (steps). Otherwise keep the error handler's.

## Spec
- Doc mode: L3.dlc.clause-redelivery, where the dead letter channel moves the message as configured (useOriginal*).
- Real mode: the delta L3.dlc.clause-redelivery.real. The current message is moved.
