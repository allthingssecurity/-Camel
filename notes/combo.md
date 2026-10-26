# The combo generator family (campaign item 3) and what it found (notes)

Owner: the combo agent. Files:
- oracle/route/combo.ml (the generator)
- the hook in oracle/route/driver.ml (`if fam = "combo" then Combo.gen_case ()`) and in oracle/build.sh (combo.ml on the
  compile line and in BUILD-INFO)
- harness/probes/{TryBlockLeakProbe, StaleRecipientsProbe, StaleSlipBlockRepro, ContinuedCalleeProbe}.java
- findings/2026-10-26-{routingslip-uses-stale-recipientlist-value, dotry-in-caller-disables-eip-error-handling-in-called-route, docatch-skipped-after-continued-failure-in-called-route}.md

## What combo generates

- **Random combinations (2 cases in 3).**
  - 3-4 routes. r0 nests to depth 3-4 and the called routes to depth 2-3.
  - At each level:
    - a leaf, with a bias toward throwException and toward calls (to direct:, a routing slip, or a recipient list
      whose list enters the same route several times);
    - or an error construct (40%): doTry with 0-2 doCatch blocks and a doFinally that is biased toward a call into
      another route;
    - or an EIP: filter, choice, pipeline, split, multicast, loop (count or while), idempotentConsumer (eager),
      loadBalance roundRobin or failover, aggregate (size 1-2), routing slip / recipient list / to direct:, or a
      dynamic router through rdyn.
  - Error constructs nest inside EIPs and the other way round.
  - 0-3 onException clauses with handled / continued / neither, redelivery 1-2 (always on the first clause), and an
    optional onWhen.
- **The hang shape (1 case in 3).**
  - An entry EIP that enters r1 twice: a slip with two r1 entries, a recipient list, multicast, loop, split, failover,
    pipeline, idempotent, or a dynamic router.
  - r1: a nested doTry/doFinally whose finally calls r2 through to / slip / recipient list / multicast, with
    variations (no outer doTry, inside a filter or split, or the error leaving r1).
  - r2: a doTry around one callback EIP (multicast, recipient list, split, loop, failover, round robin, aggregate,
    idempotent, filter, choice, a direct: call, and the known slip / dynamic router as positive controls).
  - A clause on the thrown class (or Exception) with redelivery.
- onException blocks never throw. They may call the route `reh`, which only holds callback EIPs over mocks.
  - An earlier version let them call a generated route that can fail. That recursed through the error handler without
    end (6 000-19 000 exchanges in flight, then an OOM): a user error, not a Camel bug.
- Only later routes are called, so there are no cycles. rdyn removes `dest` and sometimes throws.
- The sends always set the headers a and b. The body is `a,b`, `a,b,c` or a short text, never null.
- The driver's `gen_eh` (main session) adds a dead letter channel to 1 case in 3. That is what exposed the stale
  recipient-list value.

## Runs (Camel aa63c0a4cb94, HANG_S=4: harness timeout 4 s)

| run | mode / DSL | seed | cases | sends compared | mismatch | hangs | hangs by cause |
|---|---|---|---|---|---|---|---|
| combo-real1 | Real, model API | 11 | 3000 | 1088 | 6 (all DLC, see below) | 42 | 39 SLIP_PRODUCER, 3 stale recipient list |
| combo-xml1 | Real, XML DSL | 12 | 3000 | 1049 | 0 | 37 | 32 SLIP_PRODUCER, 5 stale recipient list |
| combo-yaml1 | Real, YAML DSL | 13 | 3000 | 1025 | 0 (1 setup = a HANG) | 36 | 33 SLIP_PRODUCER, 3 stale recipient list |
| combo-doc1 | Doc, model API | 31 | 3000 | 1257 | 64 | 26 | not classified (same mechanisms) |
| combo-ov2hunt | Real, model API, Camel + overlay 2 | 21 | 6000 | 2286 | 1 (doCatch finding) | 1 | not a hang: 44 s of exponential groupedBody growth (see below) |

How the hangs were classified:
- The unspec files in runs/combo-*/ are gzipped (the disk was at 15 GB free).
- Each HANG case was rerun with classpath overlays of patched Camel classes, compiled with javac against
  build/camel-<pin>/classes. They live in the scratchpad and are not in the repo; the patches are below.
- overlay 1: RoutingSlip restores the previous SLIP_PRODUCER in `done()`, and RoutingSlipProcessor fails the exchange
  when the property is missing (the red-team's fix sketch plus the hardening).
- overlay 2: overlay 1, plus `RoutingSlip.process` ignores `CamelEvaluateExpressionResult`.
- overlay 3: overlay 2, plus CatchProcessor.java:135 checks `Boolean.TRUE.equals(...)`.
- A hang that is gone with overlay 1 is the known finding. One that is gone only with overlay 2 is the stale
  recipient-list value.

## Harness observations (for the main session; trust base, TRUST.md 3 and 10)

1. **A HANG is hidden when the case's first send is UNSPECIFIED.**
   - `RouteRun.main` catches the exception that the HANG timeout throws. When `exp[0]` starts with `U:`, it counts the
     case as UNSPECIFIED, and the unspec file gets `SETUP:java.lang.IllegalStateException`.
   - 114 of the 115 hangs in the three stock Real runs were reported this way, and none in the summary line.
   - My scanner greps the unspec file for that SETUP text. Suggestion: report HANG separately from the first-send
     UNSPECIFIED check.
2. **When `main` dies with an exception** (an OutOfMemoryError in the runaway case above), `WORKER` (not a daemon) keeps
   the JVM alive, and run.sh never returns. Suggestion: make the worker thread a daemon, or shutdownNow in a finally.
3. **"HANG" is not always a lost callback.** In the stale-recipient-list cases, the send blocks for 30 s (the direct:
   consumer timeout) and then returns. With the 4-10 s harness timeout this shows as HANG; the cause is a wrong
   destination.
4. The INFLIGHT line's `^ case` label belongs to the next case when the case with the in-flight exchange ended in HANG
   (the label is printed only on a normal return).

## Spec / rules notes (no change made to Route.v)

- **The 6 Real-mode mismatches of combo-real1 all involve the dead letter channel**: combo-11-143, 591, 1505, 1834,
  2225, 2923 (runs/combo-real1/combo-11.mism.tsv).
  - They ran while the main session was adding L3.dlc and the harness's `(eh ...)` reading, so they may be stale.
  - The same seeds through XML and YAML (seeds 12, 13), run after the harness update, had 0 mismatches.
  - Patterns: mock:dead receives the exchange more often in Camel than in the rules (591: twice vs once; 1505: 3 vs 1;
    2923: three dead events, the split items, vs one). In 143, Camel moves the exchange to the DLC on a failed
    mandatory convertBodyTo where the rules do not. In 1834 and 2225, the final exception and dead events differ.
  - Related Camel behaviour that the rules may need (probes in this session, not findings of mine):
    - When a route called by direct: has a dead letter channel, each route's DLC can deliver the same exchange; one
      send can reach mock:dead 3 times (StaleSlipBlockRepro variants, `r2 to r3`).
    - After a handled failure in a called route, the caller's doFinally runs only its first step (the main session's
      FinallyFirstStepProbe).
- **Doc mode (combo-doc1)**: 64 mismatches.
  - The driver changed under the run (onCompletion, retryWhile, onRedelivery), so only 26 of the 64 programs could be
    regenerated identically with MODE=real.
  - All 26 agree in Real mode: 19 through the nested-doTry delta, 2 through the doFinally-first-step delta, 2 through
    the onCompletion BeforeConsumer delta, and 3 compared and equal.
  - The other 38 have the same classify.py shapes (mostly `ev.e,final.h` and event counts after nested doTry blocks)
    but were not rechecked.
- **combo-21-4948 is not a hang.**
  - A multicast with groupedBody in a route that the same exchange enters about 20 times (nested doFinally blocks that
    call it) turns the body into nested lists, and a split re-splits them.
  - The send takes 44 s at 700% CPU (GC), then returns. That is generator-made exponential data, not a Camel bug.
  - The generator could avoid groupedBody in routes that are called more than twice.
- `fuel` (400): `U:fuel` did not occur in the final runs. A first draft of the generator, with null bodies and
  deeper blocks, reached it in 14 of 2 000 cases.
- No new Real-mode disagreement that is a spec bug was found. The two combo mismatches outside the DLC work are Camel
  bugs: combo-21-188 (doCatch skipped, findings/2026-10-26-docatch-skipped-...) and the stale recipient-list value
  (which the rules cannot see: the harness reports it as HANG under an UNSPECIFIED first send).
- The rules' failover with maximumFailoverAttempts -1 tries each branch once (`fo_attempts`). That agrees with Camel's
  non-round-robin failover, which stops at the last endpoint (FailOverLoadBalancer.java:244-261).

## Overlay patches (to rebuild the classifier)

```
RoutingSlip.processExchange: Object prev = ex.getProperty(SLIP_PRODUCER); ex.setProperty(SLIP_PRODUCER, p);
  ... done(): if (prev != null) ex.setProperty(SLIP_PRODUCER, prev); else ex.removeProperty(SLIP_PRODUCER);
RoutingSlipProcessor.process: if (producer == null) { exchange.setException(new IllegalStateException(..)); callback.done(true); return true; }
RoutingSlip.process (overlay 2): Object slip = null;   // instead of exchange.removeProperty(EVALUATE_EXPRESSION_RESULT)
CatchProcessor.process (overlay 3): if (Boolean.TRUE.equals(exchange.getProperty(EXCEPTION_HANDLED))) { ... }
```
Compile: `javac -d <ov> -cp build/camel-<pin>/classes:$(cat build/camel-<pin>/deps.cp) RoutingSlip.java CatchProcessor.java`
(sources copied from build/camel-<pin>/src). Then run RouteRun with `-cp <ov>:build/harness-route:...`.
