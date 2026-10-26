What the rules cover today, and nothing more:
- L0: headers (case-insensitive lookup, first name kept, remove, remove by exact/wildcard pattern), properties,
  variables (exchange/global/route/group scopes, `*` removal), null values (CODE), exceptions with causes and a JDK
  class table, the exchange record; type conversion between String/Integer/Long/Double/Boolean/List/null and the
  API variants (convertTo, mandatory, try, getBody/getHeader/getProperty) (L0/Convert.v). Not: message ids,
  timestamps, attachments, streams, BigDecimal values, dates, regex name patterns.
- L1: Simple (ported from SimpleSpec), property placeholders (L1/Placeholder.v), constant/header/exchangeProperty/
  variable/ref/tokenize (L1/Lang.v; tokenize XML modes out of scope). Routes take Simple or constant/header/exchangeProperty/variable
  expressions (L2 expr = XSimple | XLang).
- L2: 18 step kinds (set/remove body/header/property/variable, transform, filter, choice, pipeline, stop,
  throwException, to direct:, to mock:, split [items, group, delimiter, stopOnException, maxFailedRecords],
  multicast and recipientList [sequential, default "last reply", direct:/mock: recipients], aggregation strategies
  useLatest/useOriginal/groupedBody, aggregate [correlation, useLatest/groupedBody, completionSize/Predicate, eager,
  closed keys, synchronous output]). Not: aggregate timeouts/intervals/repositories, parallel processing, streaming,
  errorThreshold, custom strategies, and ~90 other EIPs.
- L3: doTry/doCatch/doFinally (ordered catch with causes, onWhen, stop, pending exception in doFinally); onException
  (RouteBuilder-scoped clauses: closest-match selection, onWhen, handled, continued, maximumRedeliveries with the
  redelivery headers) with the default error handler. Not: dead letter channel, route-scoped vs global ties,
  useOriginalMessage, retryWhile, onRedelivery, onCompletion, transactions.
- L5: the generic endpoint contract (L5/Uri.v, Catalog.v): URI lexing, RAW(), percent-decoding, path parameters by
  the component syntax, option names/values/defaults/required by the catalog JSON of all 415 components (generated
  tables), endpoint creation and the catalog validation tools; run against 7 compiled components (direct, mock, seda,
  timer, log, bean, controlbus). Not: component behaviour beyond endpoint creation.
- L6: XML (camel-xml-io-dsl) and YAML (camel-yaml-dsl) renderings of the L2/L3 route model; every generated case is
  also loaded from both texts and must give the same trace. Not: the Java DSL builder API surface, Spring XML.
- L4: context and route lifecycle over direct: routes (L4/Lifecycle.v): context start/stop/suspend/resume and
  autoStartup, RouteController start/stop/suspend/resume/startAll/stopAll, removeRoute, startupOrder (explicit, auto
  from 1000, clashes), stop in reverse startup order, route events and statuses, messages to started/stopped routes.
  Not: graceful-shutdown timeouts, in-flight exchanges at a stop, supervising route controller, other consumers.
- Proofs: run_sound (the extracted interpreter computes only what the L2/L3 rules derive), with a non-vacuity
  example; L0 conversion lemmas (tryConvertTo never throws, mandatory never null); L2/Props.v: the pipeline law
  (running a ++ b is running a then b), a halted exchange makes no progress, an idempotent duplicate is skipped,
  the aggregator never holds a group of completionSize or more and emits exactly at it, the redelivery counter is
  exact and bounded; L5 run_ep_sound, cat_validate_sound, lenient_no_rfe; L4 step_sound/step_complete, stop_reverses_start;
  L2/Determinism.v: every route has at most one outcome (all 11 relations, both modes). No refinement proof against Camel's
  bytecode yet.
- Modes: Doc (the rules as documented) and Real (Doc + open findings as deltas); Real-mode runs must show 0
  disagreements.
