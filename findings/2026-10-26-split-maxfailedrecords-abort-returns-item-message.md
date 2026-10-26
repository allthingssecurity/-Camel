# Split with maxFailedRecords: on abort the exchange carries the failed item's message, not the original

Status: code-bug candidate (L2 route differential, rule L2.split.maxFailedRecords.abort). Camel aa63c0a4cb94.
Severity guess: medium (silent: after the abort the route's error handling, onException, a dead letter channel or the
caller sees the body and headers of one split item, as modified by the split steps, instead of the input message).
Exchange properties of the item are MERGED into the original's: one set in the failing item is there afterwards
(random-41-3291), one removed in it is still there (random-41-1967), i.e. a copy-results merge of the item into the
original rather than "sets an exception on the exchange". The message is swapped outright.

## Rule and doc lines (docs/core/camel-core-engine/src/main/docs/modules/eips/pages/split-eip.adoc)
- 380: "The Splitter will by default return the original input message."
- 1150-1152: "The `maxFailedRecords` option sets the maximum number of failed split items before aborting. ... When
  the threshold is reached, the splitter stops and sets an exception on the exchange."
- 1203-1204: with 5, "the first 4 failures are tolerated ... When the 5th failure occurs, the splitter stops and the
  exchange will have an exception set."
Nothing says the exchange's message is replaced. stopOnException, the documented all-or-nothing variant (1144), keeps
the original message (below), so the two abort paths differ.

## Real Camel (harness/probes/SplitAbortProbe.java)

    from("direct:max").split(body()).maxFailedRecords(1)
        .setHeader("item", simple("${body}")).setBody(constant("changed"))
        .throwException(new IllegalStateException("boom")).end().to("mock:after");
    send body "a,b,c", header orig=yes:
      direct:max   body=changed headers={orig=yes, item=a} exception=CamelExchangeException ... Caused by IllegalStateException
      direct:max2  (maxFailedRecords(2)) body=changed headers={orig=yes, item=b} exception=CamelExchangeException
      direct:stop  (stopOnException instead) body=a,b,c headers={orig=yes} exception=CamelExchangeException

Differential: 12 of 3 000 generated cases (runs/split1), all with maxFailedRecords, including a split inside doFinally
(final body = the split item).

## Where
MulticastProcessor (core-processor) line ~692: when `!shouldContinueOnFailure(...)` it wraps the exception and calls
`doDone(exchange, true)` with the sub-exchange; Splitter.shouldContinueOnFailure (line ~574-614) returns false when
`tracker.getFailureCount() >= maxFailedRecords` (or `ratio >= errorThreshold`). For stopOnException the same branch is
taken but the original's message comes back, so the difference is in how the threshold path hands the result back
(not traced to the line yet: for the pipeline's red-team).

Tests: SplitterMaxFailedRecordsTest only asserts `result.getException() != null` and the mock count; nothing pins the
body/headers of the result. errorThreshold (same branch) is probably affected too: not generated yet.
History: the local clone starts at 025f7cb97232 (2026-09-15); the feature predates it.

## Minimal reproducer
    Exchange r = template.send("direct:max", e -> e.getMessage().setBody("a,b,c"));
    assertEquals("a,b,c", r.getMessage().getBody());   // fails: "changed"

## Related doc bug (notes/main.md)
model/split.json (SplitDefinition @Metadata): maxFailedRecords "When the count is exceeded", errorThreshold "abort if
more than 10%", and split-eip.adoc 1263-1264 "stops when either threshold is exceeded"; the code uses `>=` (reached),
as split-eip.adoc 1151-1152, 1203-1204 and 1209-1210 say.
