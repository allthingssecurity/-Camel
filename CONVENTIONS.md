# Conventions (all layers)

## Pin
Docs and code under test are apache/camel `aa63c0a4cb94` (see PIN). Cite the snapshot in `docs/` (same lines as
upstream at the pin). Never cite a line you have not read in `docs/`.

## Citations
Each file starts with a legend of short page names, e.g.
`[TC] docs/docs/user-manual/modules/ROOT/pages/type-converter.adoc`, and rules cite `[TC.120-134]` (line range).
Javadoc citations: `[EXJ.88]` for `docs/core/camel-api/src/main/java/org/apache/camel/Exchange.java` line 88.

## Rule tags (machine-counted by tools/status.py)
Put a tag comment right before each rule (a Definition/Fixpoint/Inductive constructor group that encodes documented
behaviour), on its own line:

    (*! R <layer>.<area>.<name> <TAG> [CITE...] *)

`<TAG>` is one of:
- `DOC` written from the cited doc lines (default). If real Camel disagrees and the doc is clear, the rule STAYS;
  the disagreement is a code-bug candidate (write findings/<date>-<slug>.md).
- `DOC-BUG` the doc is wrong, Camel is right (deliberate per git history / JIRA / tests); log in findings/doc-bugs.md.
- `CODE` docs silent; real behaviour adopted, cite class/method + commit/JIRA. Reviewed as a group.
- `MAINTAINER` a maintainer stated the intent (link). Outranks DOC.
- `FIX` our own mistake corrected.
Every change of an existing rule gets a CHANGELOG.md line: rule id, old -> new, tag, evidence.

Helpers with no documentation content get no tag.

## UNSPECIFIED
Where the docs are silent or contradict themselves, the rule returns the "unspecified" result of its type with a
short reason string (e.g. `Uns "type-converter: Double -> Integer rounding not documented"`); never guess. Prefix
gap reasons with the page short name so they can be grouped. A case whose expected result is UNSPECIFIED is counted
by the differential harness, never compared (but what Camel does is recorded, so CODE rules can be adopted later).

## Documented examples
Every example in a doc page that falls in a rule's scope becomes an `Example doc_<name> : ... . Proof. vm_compute.
reflexivity. Qed.` If the rule cannot reproduce a doc example, say so in a comment and in findings/doc-bugs.md (if the
example is wrong) — do not bend the rule.

## Values
`L0/Value.v` (`val`): VNull, VStr, VInt (Java Integer), VLong, VDbl (Double held in quarters: VDbl q = q/4),
VBool, VList (List of String). Canonical text (shared with the Java harness): `N`, `S<pct-encoded utf8>`,
`I<int>`, `L<long>`, `D<quarters>`, `B1`/`B0`, `A<count>.<pct>,<pct>,...` (the count tells `[]`, `A0.`, from
`[""]`, `A1.`; changed 2026-10-26). Extend only by adding a constructor AND its
canonical text in both Value.v and harness/Canon.java.

## Ownership (parallel work)
One owner per file. Owners: theories/L0/Convert.v (type conversion), theories/L1/Placeholder.v and
theories/L1/Lang.v (non-Simple languages), the rest (Exchange, Simple adapter, routes, interpreter, extraction,
harness) by the main session. Add your file to `_RocqProject`; `make` must pass. Do not edit files you do not own;
put requests for the owner in your report.

## Machine limits
At most 2 heavy jobs on this Mac across all sessions. JVMs: `nice`, `-Xmx512m` for probes, `-Xmx2g` max. Rocq
compiles above 1 GB: hold `../.mvn-lock` (mkdir to take, rmdir to release). No Docker, no downloads, no git stash,
nothing posted. Keep free disk > 15 GB (`df -h /System/Volumes/Data`); write nothing large.

## Practices taken from basis.ai "Ship your interpreters" (2026-10-26)
Their setup: the interpreter binary is the truth; an LLM writes big-step rules; a Lean refinement proof (both
directions) against the RISC-V binary is the check; the rules are bent to match the binary, accidents included.
Ours differs on purpose: the docs are the truth and disagreements are findings. What we adopt:
1. Readable rules are inductive relations (`Inductive bigstep ...`, one constructor per documented rule, citing it);
   the executable interpreter is a separate function PROVED sound against the relation (`interp = Ok o -> bigstep o`)
   and, where it can be, complete. Extraction then runs code that is checked against the readable rules, not trusted.
   Nondeterministic EIPs (parallel multicast, aggregation timing) are relations with several allowed outcomes; the
   harness checks Camel's outcome is allowed AND (strictness, the other direction) that each allowed outcome class is
   seen in real runs, or the rule is too permissive and gets a note.
2. Two modes of one semantics: `Doc` (the rules as documented) and `Real` (= Doc + the CODE rules + the open findings as
   explicit deltas, each naming its finding file). Differential in Real mode must be 0 mismatches (regression oracle:
   a new mismatch is a Camel change or a spec bug); Doc-mode mismatches are the findings. Real is what tools built on
   the spec (checkers, generators of tests) should use, as in their "build on the validated semantics".
3. Tests are not enough: every rule carries a hit counter in differential runs; STATUS reports rules never hit or
   only hit by UNSPECIFIED cases. Generators include limit families (long names, Integer/Long bounds, empty, deep
   nesting, many headers), since the bugs live where nobody wrote a test (their 63-byte truncation).
4. Non-vacuity: every proved property and every refinement theorem states a hypothesis; show it is satisfiable on real
   programs (an `Example` that meets it), as they did for `Loaded`.
5. Small trusted surface, listed in TRUST.md: what sits outside the check (Java route builder, canonical printer,
   case parser, the extraction mappings), as they list the unverified parser.
6. Helper facts about the JDK/library (String.compareTo, regex, BigDecimal) are proved in the Rocq JVM model or
   listed as assumptions; never trusted silently (their false LLM lemmas about realloc/exit).
7. Full refinement of all of Camel is out of reach (their 1 855-line C interpreter took ~140k lines and a month);
   refinement proofs are selective (chosen methods on bytecode via ../rocq-jvm-threads), and STATUS says which.
