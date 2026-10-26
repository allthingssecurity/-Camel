# Notes of the main session (L0 exchange, L2 routes, harness)

## Doc-bug / doc-gap candidates (to go to findings/doc-bugs.md after review)
1. **transform vs setBody wording is Camel 2 era.** transform-eip.adoc 95-98 and setBody-eip.adoc 91-94: "The Transform EIP
   always sets the result on the OUT message body. Set Body sets the result accordingly to the Exchange Pattern".
   exchange-pattern.adoc 24-26 says both "always operate on the current message body regardless of the exchange
   pattern". The spec follows exchange-pattern.adoc (L2.transform); 25 000 differential cases (InOnly and InOut,
   headers set before transform) agree with it, i.e. transform does not drop headers or behave differently by MEP.
   Candidate: rewrite the two "difference" sections.
2. **removeHeaders option text loses its `*`.** model/removeHeaders.json (generated): "wildcard (pattern ends with ),";
   the source @Metadata in RemoveHeadersDefinition.java:51 has "(pattern ends with *)". The generator strips `*`
   (probably as markup). Check other generated JSON descriptions with `*` for the same loss before reporting.
3. **Null values: headers keep the name, properties and variables drop it.** No page says either. Camel:
   DefaultMessage.setHeader keeps `name -> null` (iterating headers shows it); AbstractExchange.setProperty and the
   variable repositories remove the name. Users who iterate getProperties()/getVariables() vs getHeaders() see the
   difference. Candidate: one sentence in exchange/message docs (doc gap, not a bug).

4. **Split thresholds: "exceeded" vs "reached".** model/split.json (SplitDefinition @Metadata): maxFailedRecords "When
   the count is exceeded", errorThreshold "abort if more than 10%"; split-eip.adoc 1263-1264 "stops when either
   threshold is exceeded". split-eip.adoc 1151-1152, 1203-1204, 1209-1210 and the code (Splitter.shouldContinueOnFailure:
   `>=`) say reached / "meets or exceeds". Candidate: fix the @Metadata texts and line 1263.
5. **Split stopOnException: what is thrown.** model/split.json: "the caused exception will be thrown". Camel throws a
   CamelExchangeException caused by it ("Multicast processing failed for number N"), pinned by
   SplitterStopOnExceptionTest:53. Candidate: say so (the same text is on multicast and recipientList, check them).
   Also cosmetic: the message says "Multicast" for a split.

## Open code-bug candidates (findings/)
- 2026-10-26-split-maxfailedrecords-abort-returns-item-message.md (Real delta L2.split.abort-result.real)
- 2026-10-26-dotry-escaping-exception-handled-when-nested.md (Real: UNSPECIFIED, L3.doTry.escape.real)
- 2026-10-26-failover-monitors-suppressed-exceptions.md (Real delta L2.lb.failover.suppressed.real)
- type conversion agent: tc-bigdecimal-biginteger-mandatory-null, getbody-object-null-body-returns-message,
  getmandatorybody-null-primitive
- languages agent: placeholder-escape-handling, placeholder-negation-only-leading, tokenize-token-always-regex
- L5 agent: l5-catalog-missing-path-reported-invalid, l5-ignore-case-global-options-dropped,
  l5-seda-offertimeout-duration, l5-seda-size-max-value-ignored, l5-timer-pattern-not-kept, and one more (see the private note)
- 2026-10-26-hang-routingslip-dotry-redelivery-lost-callback.md (a blocking send never returns; also in 4.22.1, 4.23.0)

## CODE-rule candidates (UNSPECIFIED classes where Camel was consistent; adopt only with exact semantics + citation)
- Split item failed, no stopOnException, no threshold: the exchange fails with the item's exception, unwrapped
  (runs/mc2: 171 of 171). Which exception when several fail, and the message after, still to pin down.
- Multicast/recipientList copy failed (default aggregation): the copy's exception propagates, unwrapped (183 of 183).
- Stop inside doFinally while an exception is pending: the exception is kept (runs/l3a: 29 of 29).
- Splitting null: zero items, the exchange goes on (most cases; the rest fail later for other reasons).

## CODE rules adopted (review as a group, KICKOFF.md)
- L0.props.null-removes, L0.headers.null-kept, L2.to.direct.stop-propagates (CHANGELOG.md has the evidence).

## Differential runs (route level, Camel aa63c0a4cb94 compiled at the pin, HotSpot 21)
| run | cases | sends compared | agree | mismatch | unspec sends | notes |
|---|---|---|---|---|---|---|
| first | 200 | 257 | 186 | 14 | 68 | all 14: null property/variable (-> CODE rule) |
| second | 3 200 | 4 227 | 3 132 | 68 | 1 086 | exchange-scope variables still stored null (our FIX) |
| third | 15 000 | 19 886 | 15 000 | 0 | 5 174 | 52 UNSPECIFIED "stop inside direct" all propagate (-> CODE) |
| fourth | 10 000 | 13 186 | 10 000 | 0 | 3 457 | |
| l3a (doTry) | 3 000 | 3 331 | 3 000 | 0 | 1 345 | all L3 rules hit hundreds of times |
| split1 | 3 000 | 1 375 | 2 959 | 41 | 2 323 | 25 stopOnException wrapper (DOC-BUG), 16 maxFailedRecords abort (finding) |
| split2 (Doc) | 3 000 | 1 391 | 2 987 | 13 | 2 335 | all 13: the open maxFailedRecords finding |
| split2-real | 3 000 | 1 397 | 3 000 | 0 | 2 339 | Real mode (Doc + finding delta): no new disagreement |
| mc2 / mc2-real | 8 000 | 3 466 / 3 489 | 7 967 / 8 000 | 33 / 0 | 6 336 | multicast+recipientList; all 33 Doc = the open finding |
| bias1 / bias1-real | 5 000 | 2 882 / 2 918 | 4 942 / 5 000 | 58 / 0 | 3 613 | generator biased to documented cases |
Most UNSPECIFIED sends come from L1 Simple (string operators on null / non-String left sides): the Simple docs do not
say what they do; ship-simple recorded Camel's answers (ossfuzz-track/RESULTS-ship-simple.md).

## Hang observations (the first, unreproduced one, and the minimized one: see the finding above)
2026-10-26, runs/rs1 (first run of routingSlip/dynamicRouter/convertBodyTo cases, seeds 121/122): one send never
returned. jstack: main thread parked in DefaultAsyncProcessorAwaitManager.await (from DefaultProducerTemplate.send),
NO Camel threads alive, CPU idle: an async callback that is never called (a lost completion). Not reproduced in the
same seeds afterwards nor in a probe (harness/probes/AggHangProbe.java: aggregator + SynchronousExecutorService + doTry,
6 000 sends). The harness now runs each blocking send on a worker thread with a 10 s timeout (HANG in the mismatch
file) and reports exchanges still in flight when the case's context stops (INFLIGHT on stderr). INFLIGHT cases seen
so far are the aggregator's deferred output (timing), not leaks. A background hunt (runs/hunt.log) is watching.
