# rocq-camel-spec: a formal specification of Apache Camel in Rocq

Start a session with: "Read camel-lean/rocq-camel-spec/KICKOFF.md and do it".

## Goal
A readable, executable specification of the whole of Apache Camel in Rocq, written FROM THE DOCUMENTATION
(not from the code), and checked against the real Camel: every place where the real code and the spec disagree
is a code bug, a doc bug, or a gap in the docs (marked UNSPECIFIED, never guessed). Idea:
basis.ai/blog/ship-your-interpreters (a route is a program; Camel is its interpreter).

Ground truth for checking: real Camel on HotSpot (fast, millions of runs) and the Rocq JVM model running Camel's
real class files (../rocq-jvm-threads, docs/USING.md; kernel-checked runs and proofs).

## Layers (build bottom-up; each layer usable on its own)
| Layer | Scope | Source of rules |
|---|---|---|
| L0 Data | Exchange, Message, headers/properties/variables, exceptions, ExchangePattern, type conversion (TypeConverter contract, the converters' documented results) | camel-api javadoc, user manual: exchange, message, type-converter |
| L1 Languages | Simple (start from ../rocq-jvm-threads/theories/Ship/SimpleSpec.v), constant, header, exchangeProperty, variable, ref, tokenize, jsonpath easy syntax, property placeholders `{{ }}` | languages/*.adoc, simple-language.adoc, using-propertyplaceholder.adoc |
| L2 EIPs | all 117 EIP pages (camel-core-engine docs/modules/eips): split, aggregate, multicast, recipientList, routingSlip, dynamicRouter, filter, choice, wireTap, enrich/pollEnrich, idempotentConsumer, resequence, throttle, delay, loop, circuitBreaker, saga, ... | eips/pages/*.adoc + the 122 *Definition options |
| L3 Errors | error handlers (default, dead letter, no), redelivery policy, onException matching order, onCompletion, doTry/doCatch/doFinally, handled/continued, transactions (rollback semantics) | error-handler.adoc, exception-clause.adoc, transactional-client |
| L4 Lifecycle | CamelContext and Service lifecycle (start/stop/suspend/resume/shutdown, ordering, graceful shutdown), routes (add/remove/reload, startupOrder, autoStartup), route policies, endpoint/component/consumer/producer lifecycle and sharing, polling consumers, scheduling | lifecycle.adoc, graceful-shutdown.adoc, route-policy.adoc, endpoint.adoc, component.adoc |
| L5 Components | (a) a generic component contract (URI -> endpoint, options, consumer/producer behaviour, headers in/out) GENERATED from the 400+ catalog JSON files; (b) per-component documented behaviour, by usage: file, timer, seda/direct, http/platform-http, kafka, jms/amqp, sql/jdbc, aws2-s3/sqs, rest, ftp/sftp, then the rest | catalog JSON (camel-catalog .../components/*.json) + components/*/src/main/docs/*.adoc |
| L6 DSL | Java/YAML/XML DSL -> route model (the L2/L3 AST) | yaml-dsl, java-dsl docs |

## Per layer, the same 4 steps
1. Rules in Rocq (theories/<Layer>/...v), each citing the doc file and line; UNSPECIFIED where the docs are silent.
2. Executable: extraction (OCaml) of an interpreter of the spec ("route + input messages -> outputs, side
   effects as an event trace"); deterministic, with virtual time and seeded scheduling (reuse camel-test-dst's
   TimeSource ideas).
3. Differential: generated routes/expressions/option sets + messages, run on real Camel (HotSpot, camel-core
   in-JVM, stub components, no Docker) and on the spec; classify every disagreement (code bug / doc bug /
   UNSPECIFIED). Kernel-checked replay in the Rocq JVM model for counterexamples where the model can run them.
4. Proofs, selectively: properties of the spec (e.g. aggregator completes each correlation group exactly
   once; redelivery count bound; split+aggregate round trip), and refinement of chosen real methods against
   the spec on bytecode (like ../rocq-jvm-threads/theories/OssFuzz/OFMllpScan.v).

## Order and pace (aim: fast, in parallel tracks, within the Mac limits)
- Week 1: L0 + L1 (Simple from the existing spec, placeholders) + the spec interpreter skeleton + differential harness.
- Weeks 2-3: L2 core EIPs (split, aggregate, multicast, recipientList, filter, choice, enrich, idempotent, throttle,
  circuitBreaker) and L3 errors; L5a generator over all catalog JSONs.
- Weeks 3-5: L4 lifecycle; the rest of L2; L5b top-20 components; L6.
- Then: remaining components, proofs.
Track A = spec writing (light), Track B = differential runs (heavy), Track C = proofs. Max 2 heavy jobs on this Mac
(other sessions also run Camel hunts): JVMs -Xmx2g niced, Rocq compiles >1 GB hold ../.mvn-lock (mkdir/rmdir).

## Refining the spec (expected, continuous)
The first rules will be wrong or incomplete in places; the spec is refined after every differential run. Every
rule carries a provenance tag, and a rule may only change for one of these reasons:
- `DOC`: written from a doc line (the default). If real Camel disagrees and the doc is clear, the RULE STAYS and
  the disagreement is a code-bug candidate. Never bend a DOC rule to match the code just to clear a mismatch.
- `DOC-BUG`: Camel's behaviour is right (deliberate per git history / JIRA / PR discussion, tests pin it, users
  rely on it) and the doc is wrong: change the rule to the real behaviour, log the doc fix in findings/doc-bugs.md.
- `CODE`: the docs are silent (was UNSPECIFIED): take the real behaviour, citing the class/method and the
  commit or JIRA that introduced it; review these as a group, since they are where undocumented surprises live.
- `MAINTAINER`: a Camel maintainer stated the intended behaviour (JIRA/PR/dev@ link); this outranks DOC.
- `FIX`: our own spec mistake (misread doc, typo); no Camel finding.
Keep a CHANGELOG.md of rule changes (rule, old -> new, tag, evidence). After a Camel PR from a finding is merged,
re-run the differential for that layer to confirm the disagreement is gone. Releases change behaviour: rules may
carry a version range (e.g. "since 4.10"); differential runs record the Camel version they ran against.

## Findings
Bugs go to the Camel pipeline, not filed from here: write each to findings/<date>-<slug>.md (rule, doc line,
real-Camel result, minimal reproducer, which Camel versions); the Camel pipeline session turns them into
branches/JIRA after a red-team. Doc bugs: findings/doc-bugs.md. Findings that must not be public: outside the repository (see the private note).

## Rules
Local git only (no remote yet; ask the user before creating one). No Docker, no downloads, no git stash,
disk > 15 GB, nothing posted. STATUS.md at the root: per layer, rules written / UNSPECIFIED count / programs
run / disagreements by class / proofs. Be honest about coverage: never call a layer "specified" beyond what
the rules cover.
