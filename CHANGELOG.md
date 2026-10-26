# CHANGELOG of rule changes

Format: date | rule | old -> new | tag | evidence.

- 2026-10-26 | L1.simple header lookup (Simple.v `ev`, FHeader) | exact-name lookup (SimpleSpec.v) -> case-insensitive
  `Exchange.hget` | FIX | SimpleSpec modelled headers as a plain list; the message docs say headers are a
  case-insensitive map [MJ.31-34, UG23.1823]. Its generator never varied the case, so no earlier result changes.
- 2026-10-26 | L0.props.null-removes (new; used by L0.vars.scope var_set and L2.setProperty) | null stored under the
  name (unstated Map reading, wrongly tagged DOC) -> setting null removes the name | FIX + CODE | docs silent
  [EXJ.479-490, EXJ.592-594]; AbstractExchange.setProperty / AbstractVariableRepository.setVariable ("if the value is
  null, we just remove the key from the map"); runs/first: all 14 mismatches of 200 cases.
- 2026-10-26 | L0.headers.null-kept (new tag on hset) | (untagged) -> null header kept, CODE | docs silent;
  DefaultMessage.setHeader puts null. Headers and properties differ here: doc-gap candidate in notes/main.md.
- 2026-10-26 | L2.to.direct.stop-propagates (new) | stop inside a direct-called route: UNSPECIFIED -> the caller
  stops too | CODE | docs silent; Pipeline.process:91 and PipelineHelper.continueProcessing:67 check
  exchange.isRouteStop() on the shared exchange; runs/third: Camel did this in 52 of 52 cases.
- 2026-10-26 | L2.split.stopOnException (via new L2.split.failure-wrapped) | the item's exception is thrown ->
  CamelExchangeException (message not documented) caused by the item's exception | DOC-BUG | [M:split.stopOnException]
  "the caused exception will be thrown"; MulticastProcessor wraps deliberately ("wrap in exception to explain where it
  failed"), pinned by SplitterStopOnExceptionTest:53, MulticastStopOnExceptionTest:56; runs/split1: 25 cases.
- 2026-10-26 | L0 exn | record (class, message) -> inductive with an optional cause; doCatch matches the chain
  [DT.211-213] | FIX | needed once Camel's wrappers appear (split).


## From L0 type conversion (notes/convert.md)
- L0.TC.to_double: decimal text -> exact Double value -> UNSPECIFIED when the value needs more than 2^53 quarters;
  FIX (misread: no Double holds 9223372036854775807; rounding undocumented).
- L0.TC.to_number_exponent (split out of L0.TC.to_number): exponent text "1e5" -> Integer 100000 -> Double 100000.0;
  DOC-BUG (073c6cf7ec20 CAMEL-24976 ObjectConverterTest `assertEquals(1e5d, ObjectConverter.toNumber("1e5"))`, the
  same commit that wrote UG423.2103-2104). Example doc_number_exponent updated accordingly.
- L0.TC.to_number_long_decimal (new, was UNSPECIFIED): integer text beyond the Integer range -> Long; plain decimal
  text -> Double; CODE (ObjectConverter.toNumber(String), 073c6cf7ec20, tests `toNumber("2147483648") ==
  2147483648L`, `toNumber("1.5") == 1.5d`).
- L0.TC.absent_boolean (new): getHeader/getProperty of an absent name as boolean: null -> false; DOC-BUG
  (DefaultMessage.getHeader(String, Class), AbstractExchange.evalPropertyValue "avoid NullPointerException when
  converting to boolean"; pinned by DefaultExchangeTest `getProperty("beer", boolean.class) == FALSE` and Issue3Test
  `assertFalse(in.getHeader("someproperty", boolean.class))`).
- L0.TC.api_getProperty: value whose converter fails -> null -> null or TypeConversionException (and the outcome set
  of an UNSPECIFIED conversion gains TypeConversionException); FIX (misread "cannot be converted"). Lemma
  getProperty_never_throws removed.

## From L1 placeholders and languages (notes/lang.md)
- L1.ph.precedence: override properties first -> env, then sys, then override, then initial; a key in both the
  override layer and env/sys is UNSPECIFIED. FIX: [PCJ.42-43] ("override properties (highest priority)") and
  [PC.131-133, PC.145-147] (env/sys mode override "any existing properties") contradict; the first rule picked a
  side. Camel: env and sys win over override properties (777 cases now UNSPECIFIED, recorded).
- L1.ph.env: `env.NAME` removed; a name not written as an OS variable (lower case, dot) -> UNSPECIFIED. FIX:
  [PC.56] is about property-file locations, not placeholders (Camel: `{{env.X}}` is a plain key); a lower-case name
  was looked up as it is (Camel upper-cases it: IOHelper.lookupEnvironmentVariable).
- L1.ph.precedence (env part): a plain key not written as an OS variable while the environment has it or its OS
  spelling -> UNSPECIFIED. FIX: same mapping gap (Camel: `{{cspec_lc}}` does not see the variable `cspec_lc`).
- L1.ph.service: `service.name:` -> `service.host:`. DOC-BUG: [PF.13] names it service.name; Camel's function is
  service.host (ServiceHostPropertiesFunction.getName(); PropertiesComponentServiceHostTest,
  PropertiesComponentServiceHostPortTest).
- L1.lang.tokenize.pairs: an end token outside a pair: "text outside the pairs" -> UNSPECIFIED. FIX: not documented
  (Camel stops at a stray end token: "]][a]" gives no part).
- L1.lang.tokenize.newline: `\n` text read as a new line in pair mode too -> plain token only. FIX: the docs show it
  for the plain token only [TK.37-38]; Camel refuses it in pair mode.
- L1.lang.predicate.value: UNSPECIFIED for a non-Boolean value as a predicate -> null false; String blank/false
  false, otherwise true; collection non-empty; other values true. CODE: ObjectHelper.evaluateValuePredicate
  (camel-util), unchanged since the clone's root 025f7cb97232 (1690 cases now compared, all agree).
- L1.lang.tokenize.nullbody: UNSPECIFIED -> a null body has no tokens. MAINTAINER: fac55782529b (CAMEL-25043,
  signed off by Claus Ibsen) "a message without a body has no tokens instead of failing with a NullPointerException".
- L1.lang.tokenize.sametoken: UNSPECIFIED -> the same start and end token is refused (IllegalArgumentException).
  CODE: fac55782529b (CAMEL-25043) "a pair with the same start and end token is refused when the route is created",
  TokenPairExpressionIterator.checkTokensDiffer.
- Harness (not rules): the exchange is now built on a started DefaultCamelContext (on a context that is not
  started DefaultMessage uses a HashMap for headers, which made header names case-sensitive: 100 false
  mismatches); the generator no longer builds an exchange variable named `global:k` (that name sets a global
  variable in Camel).

## L3 onException (main session)
- 2026-10-26 | L3.onException, L3.onException.select, L3.onException.outcome, L3.redelivery.headers (new) | - ->
  rules from exception-clause.adoc 171-197, exception-handling-patterns.adoc 60-74 / 414-418 / 527-539,
  defaulterrorhandler.adoc 14-25, dead-letter-channel.adoc 573-584 | DOC.
- 2026-10-26 | L3.redelivery.headers-after (new) | UNSPECIFIED -> handled/continued remove the redelivery headers
  (also before the block); not handled: false/0 without redelivery, in the block and after; with clauses only | CODE |
  probes harness/probes/EhProbe.java (7 configurations, attempt counting).
- 2026-10-26 | L3.errorHandler.composite-failure surface | wrapper exceptions with no matching clause got false/0
  headers -> no headers at the composite node | FIX | runs/oe3-real random-61-2239.
- 2026-10-26 | L2.split.item | an onException-handled split message is a success -> UNSPECIFIED with stopOnException |
  FIX | runs/oe1 random-61-2246 (Camel stops the parent); without stopOnException the probe confirms success.
- 2026-10-26 | L2.multicast.branch | a handled copy counts as a reply -> UNSPECIFIED | FIX | runs/oe4-real
  random-63-3282 (the handled status travels with the last reply).
- 2026-10-26 | L3.doTry.escape.real (Real mode) | - -> exceptions out of a doTry in a route with clauses are
  UNSPECIFIED in Real mode | CODE | findings/2026-10-26-dotry-escaping-exception-handled-when-nested.md.
- 2026-10-26 | run_case clause_unconfigured | - -> a clause without steps or options makes the case UNSPECIFIED | CODE |
  OnExceptionDefinition.validateConfiguration ("is not configured").
- 2026-10-26 | L2.aggregate.null-key (new) | null correlation key: UNSPECIFIED -> fails with CamelExchangeException |
  CODE | [M:aggregate.correlationExpression] says only "an Exception is thrown"; AggregateProcessor ("Invalid correlation
  key"); runs/agg3-real: 134 of 134.
- 2026-10-26 | L2.loop, L2.loop.count, L2.loop.while (new) | - -> loop-eip.adoc 9-47, 183-255, model/loop.json | DOC;
  the count goes through L0 conversion (Convert.conv_of _ TInteger).
- 2026-10-26 | L2.loop.count-failure (new) | RuntimeCamelException -> its subclass TypeConversionException caused by
  NumberFormatException | CODE | loop-eip.adoc 46-47 names the superclass; runs/loop1 101 of 101.
- 2026-10-26 | L2.idempotent, L2.idempotent.completion, L2.lb.roundRobin, L2.lb.failover (new) | - -> rules from
  idempotentConsumer-eip.adoc 11-19 / 62-65 / 120-123, roundRobinLoadBalancer-eip.adoc 9-12, failoverLoadBalancer-eip.adoc
  78-80, model/loadbalancer/failoverLoadBalancer.json | DOC.
- 2026-10-26 | L2.lb.failover, L2.loop (copy) | attempts/iterations carry variables and properties back -> UNSPECIFIED
  when an attempt/copy-iteration changes them | FIX | runs/ic1-real, ic3-real, ic6-real (Camel keeps the caller's).
- 2026-10-26 | L2.aggregate.output-order (new) | output completes before the caller goes on -> no rule when the output
  has a doTry/direct call or the aggregator is inside a doTry | CODE | harness/probes/AggOrderProbe.java, runs/ic4-real,
  ic5-real.
- 2026-10-26 | loop_copy | a copy-mode iteration had a fresh unit of work -> the same unit of work (ids kept) | FIX |
  runs/ic6-real random-111-2898.
- 2026-10-26 | L2.routingSlip, L2.routingSlip.uris, L2.dynamicRouter, L2.convertBodyTo (new) | - -> routingSlip-eip.adoc
  33-101, dynamicRouter-eip.adoc 31-36 / 112-115 / 171-175, model/convertBodyTo.json + L0 Convert rules | DOC.
- 2026-10-26 | L2.idempotent.completion | a handled exception keeps the id -> removes it | DOC-BUG |
  IdempotentOnCompletion.onComplete (deliberate, commented); harness/probes/IdemHandledProbe.java; runs/lang1-real.
- 2026-10-26 | L2.expr.lang (new) | routes use Simple only -> also constant/header/exchangeProperty/variable (L1 Lang) |
  DOC (via L1).
- 2026-10-26 | L0 exn | + suppressed exceptions; L3.doFinally.pending adds the doFinally exception as suppressed
  [DT.227-229] | FIX | needed to model the failover finding.
- 2026-10-26 | L2.lb.failover.suppressed.real (Real mode) | - -> failover also on a monitored class among the suppressed
  exceptions | CODE | findings/2026-10-26-failover-monitors-suppressed-exceptions.md.
- 2026-10-26 | L2.split.item | a successful split message did not complete its unit of work -> it does (a handled
  exception in the message removes its idempotent ids, L2.idempotent.completion.handled) | FIX | runs/xml2-real
  random-142-3742 (same with the model API).
- 2026-10-26 | L6.xml.* (new, theories/L6/Xml.v) | - -> the XML DSL rendering of the route model (model JSON kinds,
  java-xml-io-dsl.adoc 33-44, #class: references) | DOC; L6 differential: every route case also loaded as XML.
- 2026-10-26 | L6.yaml.* (new, theories/L6/Yaml.v) | - -> the YAML DSL rendering (flow style) of the route model
  (yaml-dsl.adoc 22-36, model JSON names, #class:) | DOC; every route case also loaded as YAML.
- 2026-10-26 | L4.ctx.stop / L4.ctx.stop.cleared: route statuses after a context stop "Stopped" -> not documented (?), RouteRemoved events of the stop ignored; FIX (CCJ.77-78 "clear internal state/cache" does not say the routes stay; Camel removes them: getRoute null, RouteRemovedEvent; runs/l4-try first 50 cases).
- 2026-10-26 | L4.stop.reverse-order: reverse of the chronological order of the start operations -> reverse of the startup order numbers; DOC-BUG (doc-bug entry below; Camel: DefaultShutdownStrategy.doShutdown and AbstractCamelContext.stopAllRoutes sort by RouteStartupOrder.getStartupOrder, reversed, "stop all routes in reverse order that they were started"; RouteShutdownReverseOrderTest / RouteShutdownNotReverseOrderTest pin the startupOrder meaning; GS.138-139, SDJ.31-34, RSJ.29-31 say the same).
- 2026-10-26 | L4.ctx.start.clash: FailedToStartRouteException only when every clashing route is auto-started -> on any clash among all routes (context autoStartup true); FIX (CFG.183 "unique among all routes in your CamelContext"; Camel: 142 of 142 recorded cases).
- 2026-10-26 | New Real-mode deltas L4.order.renumber.real, L4.route.start.clash.real, L4.rc.startAll.clash.real; CODE, finding 2026-10-26-l4-startuporder-renumbered-on-restart.md.
- 2026-10-26 | rules_deterministic (new, theories/L2/Determinism.v) | - -> theorem: every L2/L3 relation has at most one outcome, both modes (closed) | proof, no rule change.
- 2026-10-26 | L3.dlc, L3.dlc.result, L3.dlc.original-boundary, L3.dlc.direct, L3.dlc.step-failure (new) | - -> dead letter channel as the program's error handler (ehconf, x_orig on the exchange): moved to the dead letter endpoint, complete, original message per unit of work | DOC + CODE (DlcProbe: caller result, no redelivery headers).
- 2026-10-26 | L3.dlc.clause-redelivery (new) | - -> with a dead letter channel, a matching clause without steps (not continued) leaves the failure to it; handled set on such a clause: no rule | DOC (exception-redelivery.adoc 17-62); found by runs/dlc1-real (3 Real mismatches), DlcEmptyClauseProbe.
- 2026-10-26 | L3.doFinally.after-complete (new; BFRun) | the doFinally steps of a complete exchange did not run (halted) -> they run, then the exchange is complete again | FIX (DlcDoTryDirectProbe); Real delta L3.doFinally.after-complete.real for finding 2026-10-26-dofinally-only-first-step-after-handled-direct.md.
- 2026-10-26 | L6.xml.errorHandler, L6.yaml.errorHandler (new) | - -> route-level errorHandler/deadLetterChannel rendering (error-handler.adoc 259-268, 315-327) | DOC.
- 2026-10-26 | L3.onCompletion, .trigger, .before (new; boc, runoc proved sound) | - -> route scoped onCompletion on the first route: always/onCompleteOnly/onFailureOnly, onWhen, AfterConsumer (copy, caller unchanged) / BeforeConsumer (caller gets the steps' message), useOriginalMessage | DOC + CODE (OnCompletionProbe: handled and stop are success).
- 2026-10-26 | L3.dlc.clause-redelivery.real, L3.onCompletion.before-original.real (Real deltas) | - -> findings 2026-10-26-dlc-useoriginal-lost-with-onexception-redelivery.md, 2026-10-26-oncompletion-beforeconsumer-useoriginal-inout.md | CODE.
- 2026-10-26 | oncompletion_deterministic (new theorem, Determinism.v) | - -> onCompletion has at most one outcome | proof.
- 2026-10-26 | L3.onCompletion.alias.real (Real delta) | - -> finding 2026-10-26-oncompletion-copy-aliases-original-message.md (an AfterConsumer onCompletion with useOriginalMessage changes the caller's exchange after a DLC useOriginalMessage move) | CODE.
- 2026-10-26 | L3.retryWhile, L3.onRedelivery, L3.onRedelivery.reset (new; clause fields c_retry, c_onredel; redeliveries, after_redelivery, block_input_n, eh_outcome_n) | - -> retryWhile decides the redeliveries (counter from 1, no max counter header), onRedelivery before each redelivery (Camel restores the message each time: one call's changes remain) | DOC + CODE (RetryWhileProbe); retryWhile with an inherited maximumRedeliveries: no rule (doc conflict, doc-bugs.md).
- 2026-10-26 | L3.doFinally.pending (BFPending) | an exchange completed in a doFinally with an exception pending had a rule -> no rule (complete and failed at once: not documented) | FIX (runs/rw2-real rw-602-939).
- 2026-10-26 | harness: a HANG is reported (summary "hangs N", a HANG line in .mism.tsv) whatever the rules say about the case; the send worker is a daemon thread | harness fix (notes/combo.md: 114 of 115 hangs were hidden as UNSPECIFIED).
