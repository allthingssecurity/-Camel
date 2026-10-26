# CamelSpec: a formal specification of Apache Camel in Rocq

CamelSpec writes down what the Apache Camel documentation says Camel does as inductive rules in the
[Rocq](https://rocq-prover.org) proof assistant. It then checks real Camel against those rules on many thousands of
generated routes.

The rules come from the docs, not from the code. Where real Camel does something else, either the docs or the code is
wrong, and each such case is recorded as a finding.

Camel under test: `apache/camel` at commit `aa63c0a4cb94` (see [PIN](PIN)).

## How it works, on one tiny example

Take the documented `filter` EIP: "similar to `if (predicate) { block }`". In Rocq it becomes two rules. Each rule
carries the doc lines it comes from:

```coq
(*! R L2.filter.true DOC [FI.19-20] [FI.255] [M:filter.6] [M:filter.25] *)
| BFilterT : forall g x p body g' x' t, eval_pred x p = PB true -> bss g x body g' x' t ->
    bs1 g x (SFilter p body) g' x' t
(*! R L2.filter.false DOC [FI.19-20] [FI.257-259] [M:filter.25] *)
| BFilterF : forall g x p body, eval_pred x p = PB false -> bs1 g x (SFilter p body) g x []
```

How to read the rule names:

- `bs1 g x s g' x' t` reads "step `s` takes exchange `x` (global state `g`) to `x'` (`g'`) and emits the trace `t`".
- `[FI.19-20]` means lines 19-20 of `docs/.../filter-eip.adoc`.

How one route gets checked:

1. **Interpreter.** A Rocq function `run` computes the same relation. The theorem `run_sound` proves that every result
   `run` gives is derivable from the rules.
2. **Oracle.** `run` is extracted to OCaml. The driver generates a random program, for example
   `from direct:r0 → filter ${header.a} == 1 { setBody "x"; to mock:m1 }`, with sends like `{a=1}` and `{a=2}`. It then
   prints the expected trace: `mock:m1` receives `"x"` once, and the second send leaves the body unchanged.
3. **Real Camel.** `harness/route/RouteRun.java` builds the same routes in Camel at the pin, sends the same exchanges,
   and prints what actually happened (mock receipts, final body/headers/properties/variables, exception) in the same
   text form.
4. **Compare.** Equal text means agree. A difference is a mismatch. Every mismatch is traced to a cause: a spec bug
   (fixed and tagged `FIX`), a doc bug (`DOC-BUG`) or a Camel bug (a finding).

The same cases also run through the XML DSL and the YAML DSL. The L6 rules render each program as XML and YAML text,
Camel loads that text, and the result must be the same trace.

## Rule tags

Each rule is tagged with where it comes from:

| tag | meaning |
|---|---|
| `DOC` | stated by the Camel documentation (cited by file and line) |
| `DOC-BUG` | the docs are wrong or silent and the rule follows the code; listed in [findings/doc-bugs.md](findings/doc-bugs.md) |
| `CODE` | the docs are silent; the rule follows a probe of real Camel |
| `FIX` | a spec mistake found by the differential and corrected |
| `UNSPECIFIED` | the docs give no answer: the oracle says so, and the case is counted but not compared |

There are two modes:

- **Doc** mode is the rules as documented.
- **Real** mode is Doc plus every open finding written as a delta.

A Real-mode run must show 0 disagreements. Doc-mode disagreements are exactly the open findings.

## Layers

| layer | what | files |
|---|---|---|
| L0 | values, headers (case-insensitive), properties, variables and their scopes, exceptions, type conversion | `theories/L0/` |
| L1 | Simple language, property placeholders, constant/header/exchangeProperty/variable/ref/tokenize | `theories/L1/` |
| L2 | routes and EIPs: set/remove, filter, choice, pipeline, stop, to, split, multicast, recipientList, aggregate, loop, idempotentConsumer, loadBalance (round robin, failover), routingSlip, dynamicRouter, convertBodyTo | `theories/L2/Route.v` |
| L3 | errors: doTry/doCatch/doFinally, onException (selection, onWhen, handled, continued, redelivery), default error handler | `theories/L2/Route.v` |
| L4 | context and route lifecycle: start/stop/suspend/resume, RouteController, startupOrder, autoStartup, events and statuses | `theories/L4/` |
| L5 | endpoint URIs and options for all 415 catalog components; endpoint creation, catalog validation | `theories/L5/` |
| L6 | XML and YAML DSL as renderings of the route model | `theories/L6/` |

[STATUS.md](STATUS.md) is generated. It holds the rule counts per tag, the documented examples proved by
`vm_compute`, the theorems, the differential runs, rule coverage, and an honest scope section listing what is *not*
covered.

## The mathematics

Besides the soundness of each interpreter (`run_sound`, `run_ep_sound`, `cat_validate_sound`, L4 `step_sound` and
`step_complete`), these are proved, and none of them uses an axiom:

- **Determinism** (`rules_deterministic`, theories/L2/Determinism.v): in both modes, every program and every exchange
  have at most one outcome under the L2/L3 rules. The outcome is the final state, the exchange and the trace. The
  proof is one mutual induction over all 11 relations. If two documented rules could both apply with different
  results, the docs would give two answers to one question, and the oracle would silently pick one. The theorem says
  no such pair exists.

- **Pipeline law** (`pipeline_app_split`, `pipeline_app_join`): running steps `a ++ b` is exactly running `a`, then
  `b` on the result, with the traces concatenated.
- **Lifecycle** (`stop_reverses_start`): a context stop right after a start stops the routes in reverse start order.
- **Halting** (`halted_no_progress`): an exchange that is stopped or failed passes through the remaining steps
  unchanged.
- **Idempotent consumer** (`idempotent_duplicate_skipped`): a message whose id is already in the repository is skipped.
- **Aggregator** (`aggregate_size_invariant`, `aggregate_emits_at_size`): with `completionSize n`, no group ever holds
  `n` or more exchanges, and a group is emitted exactly when its `n`-th exchange arrives. A non-vacuity example shows
  that the hypotheses can be met.
- **Redelivery** (`redelivery_counter_exact`, `redelivery_counter_bounded`): when the failure is neither handled nor
  continued, the `CamelRedeliveryCounter` header the caller sees equals `maximumRedeliveries` (every attempt was
  made), so it never exceeds it.
- **Conversion**: `tryConvertTo` never throws, and the `mandatory*` variants never return null.

## Findings so far

Each one has a doc citation, a minimal reproducer and a probe in [findings/](findings/):

- A blocking send never returns: routing slip + nested doTry/doFinally + onException with redelivery. Minimized to a
  plain Java DSL route. It also hangs on 4.22.1 and 4.23.0.
- The failover load balancer fails over on a *suppressed* exception and swallows the real failure.
- An exception escaping a doTry is handled by onException only when the doTry is nested in another EIP.
- Split with maxFailedRecords: on abort, the exchange carries the failed item's message, not the original.
- Type conversion:
  - `getBody(Object.class)` on a null body returns the Message itself.
  - `getMandatoryBody(int.class)` on a null body returns 0.
  - Mandatory conversion to BigDecimal/BigInteger returns null.
- Placeholders: escaped brackets are handled inconsistently, and `{{!key}}` is negated only at the start.
- Tokenize: the token is a regular expression even with `regex=false`.
- Endpoint and components:
  - Options written in another case are accepted but lost.
  - `seda` offerTimeout ignores the duration syntax.
  - `seda size=Integer.MAX_VALUE` is ignored.
  - The `timer` option `pattern` is not kept.
  - The catalog reports a missing path part as an invalid value.
- Lifecycle:
  - A route without startupOrder is renumbered on every start, which gives spurious FailedToStartRouteException.
  - Resume after suspend of a stopped route reports Started, but the route does not consume.
- Doc bugs: [findings/doc-bugs.md](findings/doc-bugs.md).

These are candidates. They have not been filed with the Camel project yet.

## Building and running

Requirements:

- Rocq 9.3 with OCaml and zarith
- JDK 21
- a git checkout of `apache/camel` at `../camel` that contains the pinned commit
- the third-party jars in `~/.m2`, from a normal Camel Maven build

Nothing is downloaded by the scripts. The build steps:

```bash
make            # compile the spec (seconds)
make oracle     # extract the L2/L3 interpreter to OCaml and build oracle/route/driver
make camel      # compile Camel core + 7 components + XML DSL at the pin (harness/build-camel.sh, 1-2 min)
bash harness/build-yaml.sh   # YAML DSL at the pin (for DSL=yaml)
```

Run a differential with `harness/route/run.sh <label> <family> <seed> <count>`:

```bash
bash harness/route/run.sh doc1 random 1 5000                    # Doc mode, model API
MODE=real bash harness/route/run.sh real1 random 1 5000         # Real mode: must print mismatch 0
MODE=real DSL=xml bash harness/route/run.sh xml1 random 1 5000  # same cases through the XML DSL
MODE=real DSL=yaml bash harness/route/run.sh yaml1 random 1 5000
make status                                                     # regenerate STATUS.md
```

Mismatches and an UNSPECIFIED sample land in `runs/<label>/`. Use `tools/minimize.py <case-line> <pattern>` to shrink a
failing case. The other harnesses are `harness/convert`, `harness/lang`, `harness/l5` and `harness/l4`, each with its
own `run.sh`.

## Layout

```
theories/        the spec (Common, L0..L6), Props.v (theorems), *Extract.v (extraction)
oracle/          extracted OCaml + generators/printers (driver.ml) per layer; BUILD-INFO hashes the inputs
harness/         Java harnesses run against Camel at the pin; probes/ holds the single-question probes
docs/            the Camel docs at the pin (git archive), cited by line
findings/        candidate Camel bugs and doc bugs
notes/           working notes per layer
tools/           status.py, minimize.py, gen_l5.py, classify.py
KICKOFF.md       the plan; CONVENTIONS.md: tags, provenance, practices; TRUST.md: what no proof covers
```

## What is trusted

[TRUST.md](TRUST.md) lists everything that sits outside the check:

- extraction
- the generators and printers
- the Java harness and its filters
- the javac build of Camel
- the doc snapshot
- how clauses and executors are set up in the harness

A differential agreement is evidence, not a proof that Camel refines the spec.

The method follows the "ship your interpreters" practice: inductive rules, an interpreter proved sound against them,
rule hit counters, non-vacuity examples, and no silently trusted facts.

## License note

`docs/` is unmodified Apache Camel content (a `git archive` of the pinned commit). It is © The Apache Software
Foundation, licensed under the Apache License 2.0. Apache Camel is a trademark of the ASF. This project is not
affiliated with or endorsed by the ASF.
