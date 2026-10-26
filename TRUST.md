# What sits outside the check (CONVENTIONS practice 5)

A differential result is only as good as these pieces, which no proof covers:

1. **Rocq kernel and extraction** to OCaml (strings/ascii -> OCaml string/char, Z -> zarith, nat -> int: all lengths
   and fuel are small). `run_sound` is about the Rocq function; the extracted OCaml is trusted to compute the same.
2. **oracle/route/driver.ml**: the generator (only decides which cases exist) and the printer of the expected result
   (canonical text). A printer bug shows as a mismatch, not a silent agreement, unless it is mirrored in (3).
3. **harness/route/RouteRun.java**: the s-expression reader, the building of routes with the Camel model API
   (RouteDefinition, SetHeaderDefinition, ...; not the Java/YAML DSL, which is L6), the canonical printer, and two
   filters: exchange properties whose names start with `Camel` are dropped (Camel's internal properties; the
   generator never sets such names), and headers/properties/variables are compared as sets (order is not documented).
   Mock receipts are recorded in order with `MockEndpoint.whenAnyExchangeReceived` (a snapshot at receipt).
4. **The Camel build**: harness/build-camel.sh compiles the core modules and 7 components at the pin with javac
   (no Maven, no plugins); camel-util-json and third-party deps come from local 4.24.0-SNAPSHOT jars.
5. **Doc snapshot**: docs/ is `git archive` of the pin; citations are lines of these files.
6. **L1 Simple** inherits the trust notes of ossfuzz-track/RESULTS-ship-simple.md (its generator renders programs to
   text; the rules see the AST, Camel sees the text: `Simple.render` is part of the trust base).

7. **L5 (component contract)**, from notes/l5.md: (1) oracle/l5/driver.ml (generator; printers of expected text); (2) harness/l5/L5Run.java: option read-back through the component's endpoint PropertyConfigurer, the endpoint field for path options, the endpoint URI's path when that field is unset and the syntax has one name (direct keeps it in `key`); a path option that cannot be read is not compared (controlbus command); the registry binds `myBean`, `otherBean`; class names are three JDK classes; (3) harness/l5/build-catalog.sh: camel-catalog, core-catalog and tooling-model compiled with javac, with only the component JSONs and components.properties as resources; (4) tools/gen_l5.py (JSON -> Rocq data).
8. **onException clauses** are attached to every route as route-scoped copies (Camel's RouteBuilder-scoped clauses
   are applied to each route the same way); redeliveryDelay is set to 0 (time is not modelled).
9. **Aggregators** get a SynchronousExecutorService (aggregate-eip.adoc 46-47), so the output runs in the caller's
   thread; JDK exception class table (L0/Exchange.v jdk_super) is a list of JDK facts, not Camel docs.
10. **Sends run on a worker thread** (a blocking ProducerTemplate.send, as users call it) with a 10 s timeout, so a hang
    is reported (HANG) instead of stopping the run; an exchange still in flight when the case's context stops is
    reported on stderr (INFLIGHT). Every program has a fixed route `rdyn` (removes the `dest` header) so that generated
    dynamic routers end.
11. **L6 XML**: with -Ddsl=xml the harness loads the XML text rendered by L6/Xml.v (extracted) through Camel's
    RoutesLoader (camel-xml-io-dsl, compiled at the pin) instead of the model API; the registry has `syncExec` (a
    SynchronousExecutorService) for aggregators.
12. **L6 YAML**: with -Ddsl=yaml the harness loads the YAML text rendered by L6/Yaml.v (flow style, JSON syntax: the
    same node tree as block style) through camel-yaml-dsl compiled at the pin (harness/build-yaml.sh, snakeyaml-engine
    3.2 from ~/.m2).

13. **L4** oracle/l4/driver.ml: the generator (which cases exist; `guided` asks the extracted rules) and the printer of the
   expected text; the extraction of Lifecycle.run_case (theories/L4/LifecycleExtract.v).
14. **L4** harness/l4/LifecycleRun.java: the case reader; the program built with the model API (RouteDefinition with routeId,
   startupOrder, autoStartup, and a recording Processor as the only step; the context's setAutoStartup); the shutdown
   strategy timeout set to 1 s (documented option, no exchange is in flight at a stop); route events recorded by an
   EventNotifierSupport added before the start (only RouteStarted / RouteStopped / RouteRemoved, in notification
   order); route status = "-" when getRoute(id) is null, else getRouteController().getRouteStatus(id); context status
   = getStatus(); a message = ProducerTemplate.send to direct:<id>?block=false (or ?block=true&timeout=100), "routed"
   when the processor ran once and the exchange has no exception, "failed" when it has one and the processor did not
   run (the exception class is not compared); each operation runs on a worker thread with a 10 s timeout (HANG).
   The comparison: the expected "ignored" events are dropped from Camel's events before comparing, bag events are
   compared sorted, "?" fields are not compared, and a case agrees when one of the two sus traces matches.
15. **L4** harness/l4/probes/CounterProbe.java reads InternalRouteStartupManager.defaultRouteStartupOrder by reflection; it was
   used only to design the Real-mode delta, never in a comparison.
16. **L3 dead letter channel** (harness/route/RouteRun.java): the program's `(eh dlc <mock> <n> none|msg|body)` is a
   DeadLetterChannelDefinition (maximumRedeliveries n, redeliveryDelay 0, useOriginalMessage / useOriginalBody) set on
   every route with RouteDefinition.errorHandler (as the route-level `<errorHandler>` of error-handler.adoc 259-268),
   next to the route-scoped onException copies of item 8; mock:dead is recorded like mock:m1/m2.
17. **L3 onCompletion** (harness/route/RouteRun.java): the program's `(onCompletion always|complete|failure <onWhen>
   after|before 0|1 <steps>)` is an OnCompletionDefinition (onCompleteOnly / onFailureOnly / onWhen / mode /
   useOriginalMessage) added as an output of the first route only (route scope, the route the sends go to); the YAML
   DSL text puts it in a routeConfiguration the first route refers to (oncompletion.adoc 91).
18. **Hangs** (harness/route/RouteRun.java, amends item 10): a send that does not return within the timeout is
   counted as a hang and written to .mism.tsv, also when the rules call that case UNSPECIFIED (before 2026-10-26 such
   hangs were counted as UNSPECIFIED: notes/combo.md). A HANG can also be a 30 s direct: consumer timeout caused by a
   wrong destination (findings/2026-10-26-routingslip-uses-stale-recipientlist-value.md).
19. **onRedelivery**: the registry bean "onRedel" (the only processor the specs know) appends "r" to the header onr.
