# L0 type conversion (theories/L0/Convert.v): notes, changelog, doc bugs, UNSPECIFIED

Owner files: theories/L0/Convert.v, theories/L0/ConvertExtract.v, oracle/convert/, harness/convert/.
Run: `bash harness/convert/run.sh` (builds the oracle, prints the cases, runs them on Camel aa63c0a4cb94 in one
`nice java -Xmx512m`, about 10 s; keeps harness/convert/last-summary.txt and last-disagreements.tsv only).

## Scope

Values: the kinds of `val` (null, String, Integer, Long, Double in quarters, Boolean, List of String).
Types: String, Integer, Long, Double, Boolean, int, long, double, boolean, Number, BigDecimal, java.util.List,
Object. API: `TypeConverter.convertTo`, `mandatoryConvertTo`, `tryConvertTo`; `Message.getBody(type)`,
`getMandatoryBody(type)`, `getHeader(name, type)`; `Exchange.getProperty(name, type)`.
Not in scope: the exchange-taking variants (same documented results; not run), `getVariable` (same javadoc as
getProperty), the convertBodyTo/convertHeaderTo/convertVariableTo EIPs (L2; their `mandatory` option text is cited
in a finding), byte[]/InputStream/File/XML/charsets (no `val` kind), custom and fallback converters.

Result forms: `CV v` exact value (Java class of its kind), `CDec d` a BigDecimal equal to d, `CNull`, `CFail cls`
(instance of), `COneOf outcomes why` (only the set of outcomes is documented: some value of the type, null, a
documented exception), `CUns why`.

## Counts (2026-10-26)

- Rules: 20 tagged (17 DOC, 2 DOC-BUG, 1 CODE). Lemmas: 3 (tryConvertTo never throws; mandatoryConvertTo and
  getMandatoryBody never null). Doc examples: 14 `Example doc_*` by vm_compute (one is the 0.25 stand-in for the
  0.1 example, which `val` cannot hold).
- Cases: 69 values x 13 types x 7 methods = 6279. Exact expectation 2672 (OK 2667, MISMATCH 5); outcome-set
  expectation 3603 (POK 3589, PMISMATCH 14); fully UNSPECIFIED 4. No result changed between the forward and the
  reverse run order (the registry's miss cache did not show).
- 70 distinct UNSPECIFIED / partial reasons (counts are cases, all methods):
  560 Boolean from text other than true/false; 441 List from a non-List; 266 Boolean from a number;
  84+84 Integer/Long from decimal text; 5 x 72 which of null / TypeConversionException (or which exception) for a
  word such as "abc" (convertTo, mandatoryConvertTo, getBody, getHeader, getProperty); 70 Integer from a number out
  of range; 70 Integer from integer text out of range; 6 x 70 a number type from a List; 56 each Integer/Long/Double
  from exponent or other text; 56 Integer from a Double with a fraction; 42 String from a Double; 42 Double from a
  long beyond 2^53 / from text a Double does not hold exactly; 35 String from a List; then blank text, white space,
  plus sign, leading zeros, hex, Boolean sources, BigDecimal from exponent/other text (14-28 each); 28+14 MODEL
  (a decimal that is not a whole number of quarters); 9 mandatoryConvertTo(null) for a reference type; 4 getBody of
  a null body as a primitive (the docs contradict themselves).

## Disagreements (last run: 19 cases, 3 findings, 0 spec mistakes left)

| Cases | Class | Where |
|---|---|---|
| 14 | code-bug candidate | findings/2026-10-26-tc-bigdecimal-biginteger-mandatory-null.md: mandatoryConvertTo / getMandatoryBody (and convertBodyTo, mandatory=true) to BigDecimal/BigInteger give null for a Boolean/List/Date |
| 1 | code-bug candidate | findings/2026-10-26-getbody-object-null-body-returns-message.md: getBody(Object.class) of a null body returns the Message |
| 4 | code-bug candidate | findings/2026-10-26-getmandatorybody-null-primitive.md: getMandatoryBody(int/long/double/boolean) of a null body gives 0/false |

Resolved in the first refinement round (run 1 had 322 disagreements):
- 48 FIX: a long-range decimal text ("9223372036854775807") to Double: the first rule gave the exact value, which
  no Double holds (rounding is not documented). Rule `to_double`.
- 48 DOC-BUG: "1e5"/"1e3" to Number gives a Double, not an Integer. Rule `to_number_exponent`.
- 2 DOC-BUG: getHeader / getProperty of an absent name as `boolean` give false. Rule `absent_boolean`.
- 187 FIX: getProperty of "abc" etc. to a number type throws TypeConversionException; the first rule answered null
  ("null if it cannot be converted" read as covering converter errors). Rule `api_getProperty`.
- 23 FIX (harness): Double results beyond 9e15 quarters were printed as `O...` instead of `D...`.

## CHANGELOG lines (for the main session's CHANGELOG.md)

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

## Doc bugs / doc gaps (for findings/doc-bugs.md)

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

## UNSPECIFIED: what Camel does (recorded, not compared; CODE candidates to review as a group)

convertTo on the pool (same for the other methods modulo null/exception mapping; full table in
harness/convert/last-summary.txt):
- String from Double: Java `Double.toString` ("2.5", "0.0", "4.294967296E9"). String from List: `toString` ("[a, b]").
- Integer/Long from text: `-0`, `007`, `+1` accepted (Java parse); white space, `1.0`, exponent, hex, `#10`,
  out-of-range text, words -> TypeConversionException. Empty / blank text -> TypeConversionException.
- Integer from a Long out of range: silent wrap-around (2147483648L -> -2147483648, Long.MAX -> -1).
  Integer/Long from a Double: truncation (2.5 -> 2, -1.5 -> -1), saturation (2^32 -> Integer.MAX). Surprising;
  worth a look by the pipeline before adopting as CODE.
- Double from text: Java `Double.parseDouble` (`" 7 "` -> 7.0, `+1`, `1E5`, `NaN`, `Infinity` accepted; `-0` ->
  -0.0); hex -> TypeConversionException.
- Boolean from text: `true`/`false` in any case (`TRUE`, `True`); everything else (`yes`, `on`, `1`, `abc`) has no
  conversion: `Boolean.class` -> null (mandatoryConvertTo: NoTypeConversionAvailableException), but `boolean.class`
  -> TypeConversionException from convertTo / mandatoryConvertTo / getBody / getHeader / getProperty (null from
  tryConvertTo, as UG423.2089-2090 says). The same split for a Long or Double to Boolean / boolean.
- Boolean from an Integer: `value > 0` (0 and -1 -> false, 1 and 42 -> true); from a Long or Double: no converter
  (null). Inconsistent between Integer and Long.
- Number from text: `-0`, `007`, `+1` -> Integer; `1E5` -> Double; text beyond the Long range -> TypeConversionException.
- BigDecimal from text: Java `new BigDecimal(text)` (`1e3` -> 1E+3, `+1`, `007`); blank, white space, words ->
  TypeConversionException. From Boolean/List: null (see the BigDecimal finding).
- List from a non-List value: no converter (null; mandatory -> NoTypeConversionAvailableException).
- mandatoryConvertTo(reference type, null): NoTypeConversionAvailableException.
- getBody(primitive) of a null body: 0 / false.

## Requests for files I do not own

- L0/Value.v: no BigDecimal kind; results use `CDec` (in Convert.v) instead. If later layers need BigDecimal values
  as inputs, a `VDec` kind with canonical text `Z<unscaled>:<scale>` (as the harness prints it) would do.
- CONVENTIONS.md / Value.v canonical text: `A` is both the empty list and the list of one empty String (`A` +
  pct("") = `A`). The convert pool avoids lists with empty Strings. Suggest e.g. `A` for [] and `A,` prefix... or a
  length prefix (`A2:a,b`).
- CONVENTIONS.md mentions harness/Canon.java; it does not exist yet. harness/convert/ConvertRun.java has its own
  copy of pct/decode (same encoding as ship-simple); it can switch to Canon.java when it exists.
- Citation outside docs/: the convertBodyTo option text is in camel-core-model .../model/convertBodyTo.json, symlinked
  from docs/core/camel-core-engine/src/main/docs/modules/eips/examples/json/ but not copied into docs/ (dangling
  symlink); cited from build/camel-aa63c0a4cb94/src in a finding. Suggest copying the eips/examples/json targets into
  docs/ (they are rendered on the EIP pages).
- L1/Simple.v `typed` (`string:` of a Double uses dbltext, `boolean:` only of lower-case true/false): the TC spec calls
  both UNSPECIFIED; Camel gives `Double.toString` (matches dbltext for small quarters, not for 2^32: "4.294967296E9")
  and accepts TRUE/True. Not a Simple.v error by itself (Simple's typed prefixes may not use the converter the same
  way), only a cross-check for the Simple owner.
- STATUS.md (main session): L0 conversion: 20 rules / 70 UNSPECIFIED reasons / 6279 cases / 3 code-bug candidates,
  0 open spec mistakes / 0 proofs beyond 3 lemmas.
