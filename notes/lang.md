# L1 property placeholders and core languages: notes, changelog, doc bugs, UNSPECIFIED

Owner files: theories/L1/Placeholder.v, theories/L1/Lang.v, theories/L1/LangExtract.v, oracle/lang/,
harness/lang/. Run: `bash harness/lang/run-all.sh` (builds the oracle from the two .v files only, so another
track's broken file does not block it; generates 46126 cases; runs them on Camel aa63c0a4cb94 in one
`nice java -Xmx512m`, about 20 s; keeps only harness/lang/last-summary.txt, last-unspec.txt, last-disagreements.tsv).
The run sets a fixed OS environment (CSPEC_A, CSPEC_B, CSPEC_D_X, CSPEC_N, FOO_SERVICE_HOST/PORT,
BAR_SERVICE_HOST, cspec_lc; the driver's `the_env`, checked by LangRun against System.getenv).

## Scope

- Placeholder.v: `resolve : penv -> chars -> pres` (`PV text | PFail exc | PUns why`), the text form
  `context.resolvePropertyPlaceholders(text)`: `{{key}}`, defaults, `{{?key}}`, `{{!key}}`, `?nested=false`,
  escapes, nested values, `env:`, `sys:`, `service:` / `service.host:` / `service.port:`, layer precedence of
  override / OS environment / system / initial properties, the `nested-placeholder` and `default-fallback-enabled`
  switches. Out of scope: property files and locations, `bean:`, `boolean:`, Kubernetes, custom functions,
  third-party sources, Spring XML, the endpoint-URI form of optional placeholders.
- Lang.v: `eval` / `evalp : lenv -> lexp -> lres` (`LV val | LErr exc | LUns why`) for constant, header,
  exchangeProperty, variable, ref, tokenize over an abstract `lenv` (body, headers, exchange properties, exchange /
  global / group variables, registry of `RgExpr v | RgPred b | RgOther v`, placeholder `penv`). Options: trim,
  resultType (UNSPECIFIED pending L0/Convert.v), tokenize token / endToken / regex / xml / includeTokens / group /
  groupDelimiter / skipFirst / source / inheritNamespaceTagName (xml and inheritNamespaceTagName out of scope).
  Not modelled: resolveResource (generator leaves it unset), `resource:` loading, `route:` variables.
- Connecting `lenv` to the main session's Exchange model: header lookup is case-insensitive ([MJ.31-34, MJ.42]),
  exchange properties and variables exact (case-only matches UNSPECIFIED).

## Counts (2026-10-26)

- Rules: Placeholder.v 14 tagged (11 DOC, 2 FIX, 1 DOC-BUG); Lang.v 16 tagged (11 DOC, 2 FIX, 2 CODE,
  1 MAINTAINER). Doc examples proved by vm_compute: 14 in Placeholder.v, 12 in Lang.v (one of them states that the
  constant `resultType="int"` example [C.80-128] is UNSPECIFIED pending L0/Convert.v).
- Differential: 46126 cases: agree 16531, mismatch 1140, UNSPECIFIED 28455 (87 distinct reasons; Camel's outcome
  recorded per reason in harness/lang/last-unspec.txt). Most UNSPECIFIED cases come from the bounded-exhaustive
  families (ph-exh: every text of up to 4 atoms; tok-exh/tok-pairs: every body of up to 5 atoms), which are
  deliberately mostly outside the documented forms.
- Disagreements, all classified (harness/lang/last-disagreements.tsv):
  - 303 probable doc bug: `{{ key }}` (spaces) [PP.582] is not trimmed by Camel ("Property with key [ a ] not
    found"). Rule kept DOC (no git/JIRA evidence that not trimming is deliberate; history before 025f7cb97232 is
    not in the clone). See doc bugs below.
  - 550 code-bug candidates, escapes: findings/2026-10-26-placeholder-escape-handling.md (293 `\}}` kept when the
    text has no `{{`; 235 lone `\{{` fails; 13 `\{{x\` -> `{{x}}`; 9 `\\{{a?nested=false}}` loses the backslash).
  - 46 code-bug candidates, negation only at the start of the text:
    findings/2026-10-26-placeholder-negation-only-leading.md.
  - 241 code-bug candidates, tokenize: findings/2026-10-26-tokenize-token-always-regex.md (237 token treated as a
    regex with regex=false; 2 pair mode white-space start token; 2 pair mode null body vs CAMEL-25043's statement).
  - 0 our-mistake left (the FIX lines below were found and fixed in the runs).

## Changelog lines (for CHANGELOG.md; rule, old -> new, tag, evidence)

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

## Doc bugs (for findings/doc-bugs.md)

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

## UNSPECIFIED (top reasons; Camel's outcome in brackets, from harness/lang/last-unspec.txt)

- TK: an empty part (4342) [Camel's Scanner drops a leading and a trailing empty part: ",\n" -> ["\n"],
  " ;" -> [" "], ";\n;a " -> ["\n", "a "]; "" -> no part; parts between two tokens not yet looked at] - CODE
  candidate.
- PP: `}}` without `{{` (2861), `{{` without `}}` (2174), 3+ braces (951) [mostly IllegalArgumentException; a lone
  `}}` in a text without `{{` is returned as is].
- TK: an end token outside a pair (2374) [stops: no further parts]; a start token without an end (1174) [the
  pairs before it]; no pair (507) [no tokens].
- TK: group with pairs (1973), regex with an end token (1796) [endToken wins: pair mode], includeTokens without
  endToken (913) [IllegalArgumentException "requires endToken"], skipFirst with group (322) [outcomes recorded,
  not yet read].
- PC/PCJ precedence contradiction (777) [env > sys > override].
- SE: group not a positive number (729) [0: RuntimeExchangeException; text: TypeConversionException].
- TK: a token with white space at an end (628) [pair mode: IllegalArgumentException "must be specified and not
  empty"; plain mode: used as a regex].
- PF/PC: OS-variable name mapping (611 + 480) [Camel upper-cases and maps `.`/`-` to `_`, IOHelper
  .lookupEnvironmentVariable] - CODE candidate.
- out of scope: resource: (508); PR and names: empty name (756) [null], case-only property/variable names (354)
  [exact: null], `${ }` in a header/property/variable name (504) [evaluated as Simple] - CODE candidates.
- PP: `{{?key}}` missing in a text (110) [`{{?k}}` alone gives null, inside a text the empty string, some forms
  IllegalArgumentException]; negation of a non-boolean (136) [IllegalArgumentException or the value];
  cycle (98) [IllegalArgumentException].
- resultType pending L0/Convert.v: constant (136), ref (26), tokenize (1).

## Requests to other owners

- Main session (docs/ snapshot): add the pages these rules cite but that are not in docs/ yet (read with
  `git show aa63c0a4cb94:<path>` in ../camel): core/camel-base/src/main/docs/properties-component.adoc ([PC]);
  core/camel-api/src/main/java/org/apache/camel/CamelContext.java ([CCJ], resolvePropertyPlaceholders javadoc
  lines 1010-1024); core/camel-api/src/main/java/org/apache/camel/spi/PropertiesComponent.java ([PCJ]);
  catalog/camel-catalog/src/generated/resources/org/apache/camel/catalog/languages/{constant,header,
  exchangeProperty,variable,ref,tokenize}.json ([CJc] ... [CJt]; rendered into each language page by
  docs/components/modules/languages/partials/language-options.adoc, which could be added too).
- Value.v / harness/Canon.java owner: the canonical text `A<pct>,<pct>,...` encodes both the empty list and the
  list of one empty string as `A`. Lang.v avoids the case (empty parts are UNSPECIFIED) but a list-valued header
  could hit it. Suggest e.g. a count prefix (`A2:a,b`). harness/Canon.java does not exist yet; LangRun.java has its
  own encoder written to CONVENTIONS.md and should switch to Canon.java when it exists.
- L0/Convert.v owner: resultType of constant/ref/tokenize is UNSPECIFIED here until Convert.v gives the conversion
  of a String (constant text) to int/Integer/... ; Lang.v can then call it.
- STATUS.md / CHANGELOG.md / findings/doc-bugs.md: the lines above.
