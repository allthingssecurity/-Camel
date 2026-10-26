# Doc bugs and doc gaps (candidates; reviewed by the Camel pipeline before any PR)

Camel aa63c0a4cb94. Each entry: page and line, what it says, what Camel does, evidence.

## L0 exchange, L2/L3 routes (notes/main.md)
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

## L0 type conversion (notes/convert.md)
1. camel-4x-upgrade-guide-4_23.adoc 2103-2104: "returns an Integer for all values within the Integer range ... and
   supports exponent notation such as 1e5" reads as if "1e5" gave Integer 100000; it gives Double 100000.0 (pinned by
   the test in the same commit). Suggest: "... exponent notation such as `1e5` (which gives a `Double`)".
2. Message.java 144-145 (getHeader(name, type)) and Exchange.java 464 (getProperty(name, type)) say null when absent;
   for `boolean.class` the result is `false` (deliberate, tested). Exchange.getVariable has the same javadoc
   (Exchange.java 563) - not checked.
3. Exchange.java 459-467 (getProperty(name, type)): no `@throws TypeConversionException`, but a value whose converter
   fails throws it (like getHeader, whose javadoc has the @throws at Message.java 146). Same for getVariable.
4. TypeConverter.java 69 (@Metadata "null when ... the value is null") does not mention primitive types, for which a
   null value converts to 0/false (camel-4x-upgrade-guide-4_24.adoc 2458, only in a camel-milo section). Message.java
   296-297 (getBody: "null if body does not exist") contradicts it for `getBody(int.class)` of a null body (Camel
   gives 0; UNSPECIFIED in the spec).
5. TypeConverter.java 92 "is never null" vs camel-4x-upgrade-guide-4_12.adoc 52-53 (an allowNull converter may answer
   null for mandatoryConvertTo): the javadoc should mention the exception.
6. The type-converter page documents no concrete conversion between String and the number/boolean types at all
   (all concrete rules come from Simple examples and upgrade guides): the gaps below are the list of what a short
   "built-in conversions" table on type-converter.adoc would settle.

## L1 placeholders and languages (notes/lang.md)
1. property-placeholder-functions.adoc line 13: `service.name` should be `service.host` (the function's name in
   ServiceHostPropertiesFunction; tests use `{{service.host:FOO}}`). Rule changed (DOC-BUG).
2. using-propertyplaceholder.adoc line 582: "read the configuration transparently as ```{{ my-property }}```": the
   spaces are not trimmed by Camel ("Property with key [ my-property ] not found"); probably a typographic
   artefact. Not yet a DOC-BUG (no evidence of intent); 303 disagreements stay counted.
3. Contradiction on precedence: spi/PropertiesComponent.java javadoc lines 42-43 ("override properties (highest
   priority)") and properties-component.adoc line 141 ("take precedence and will use first") vs lines 131-133 and
   145-147 (OS environment and JVM system property modes "override any existing properties"). Camel: env and system
   properties win over override properties.
4. variable-language.adoc line 67: "The Header language is part of *camel-core*." (copy of header-language.adoc;
   should say Variable).
5. properties-component.adoc lines 54-56 ("You can also prefix with `env.`") is under "locations"; a reader may take
   it for placeholders in general, where `{{env.X}}` is a plain key. Minor; could say "in locations".

## L3 onException (main session, 2026-10-26)
- exception-handling-patterns.adoc 68-69: "If you don't set a response, the caller gets an empty body, not the
  exception." Camel returns the body as it was when the exception occurred (probe: body "in" after handled(true) with
  no transform); line 67 and the handled option text ("whatever this onException block produces") are right.
- dead-letter-channel.adoc 573-584 (redelivery headers) says only what is added "When a message is redelivered".
  Undocumented: with handled(true) or continued(true) the three headers are removed before the onException block runs
  (it never sees the redelivery count, although 3 attempts are made); an exchange whose exception goes back to the
  caller has CamelRedelivered=false / CamelRedeliveryCounter=0 when it was not redelivered (only when the route has
  onException clauses). Candidate: document both (the first is surprising for error-queue routes that log the count).
- OnExceptionDefinition.validateConfiguration refuses, at route creation, an onException with no steps and no options
  ("is not configured") and handled together with continued; neither is documented on exception-clause.adoc.
- idempotentConsumer-eip.adoc 18-19: "remove the message id from the repository if the Exchange failed, otherwise it
  stays there". Camel also removes it when the failure was handled by onException(...).handled(true) or a dead letter
  channel (IdempotentOnCompletion.onComplete: "did not process successfully but was failure handled ... not consider it
  as complete"), so a duplicate is processed again after a handled failure. Deliberate; candidate: document it.

## L4 lifecycle (notes/l4.md)

- configuring-route-startup-ordering-and-autostartup.adoc 209 and 438, graceful-shutdown.adoc 18: "stop the routes in
  the *reverse* order that they were started" reads as the reverse of the order in which the routes were started; Camel
  stops in the reverse of their startupOrder numbers, which differs as soon as a route is started on its own after the
  context start (startRoute / startAllRoutes). Suggested wording: "in the reverse order of their startup order (the
  order in which Camel starts them at startup)", as graceful-shutdown.adoc 138-139 already says.
- (with the finding) configuring-route-startup-ordering-and-autostartup.adoc 188-196: true only for the first start of
  each route; until the finding is fixed, the numbers of routes without startupOrder grow with every restart.

## L3 dead letter channel (main session, 2026-10-26)

- error-handler.adoc 58-62: "The Dead Letter Channel will redeliver at most 6 times using 1-second delay" contradicts
  dead-letter-channel.adoc 142-151 ("Redelivery is disabled by default ... The maximumRedeliveries is set to 0") and
  model/deadLetterChannel.json. The 6 is from Camel 2.x.
- An onException clause without steps but with handled set explicitly, under a dead letter channel: the docs say
  handled(true) means "only the steps in this onException block execute" (model onException.handled), and that
  handled(false) propagates the exception back. Camel moves the exchange to the dead letter queue and the caller sees
  no exception, in both cases (harness/probes/DlcEmptyClauseProbe.java). With a step in the clause, the same
  handled(false) propagates the exception. Candidate: document that a step-less clause only overrides the redelivery
  and leaves the outcome to the error handler.

- dead-letter-channel.adoc 583-584 says CamelRedeliveryMaxCounter "is absent if you use retryWhile". But
  exception-redelivery.adoc 21-25 says a clause with any redelivery option inherits the error handler's
  maximumRedeliveries. Camel shows that inherited maximum in the header, also with retryWhile (runs/rw1-real
  random-601-2900: a dead letter channel with maximumRedeliveries 2 and a clause with retryWhile give
  CamelRedeliveryMaxCounter=2). It is the same when the clause sets maximumRedeliveries itself
  (harness/probes/RetryWhileProbe.java: "retry<3 max=1"). Candidate: the header is absent only when no maximum applies.
