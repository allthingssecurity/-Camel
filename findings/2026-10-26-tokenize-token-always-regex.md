# Tokenize language: the token is a regular expression even with regex=false (the default)

Status: code-bug candidate (L1 lang differential, theories/L1/Lang.v). Camel aa63c0a4cb94 (4.24.0-SNAPSHOT).
Severity guess: medium. A pipe- or dot-delimited text, a very common case, is split wrongly without any error:
`tokenize("|")` splits between every character, `tokenize(".")` gives only empty tokens, `tokenize("+")` fails.

## Rule and doc lines

- `L1.lang.tokenize` DOC: the parts are the texts between the tokens; `regex`: "If the token is a regular expression
  pattern.", default `false` (catalog tokenize.json line 30, rendered on tokenize-language.adoc by the
  `language-options` partial, line 27). So with the default the token is a literal text.
- Split EIP examples with literal tokens: split-eip.adoc lines 475 (`tokenize(",")`), 955 (`tokenize("@")`).

## Real Camel

    tokenize("|")  on "a|b"     -> ["a", "|", "b"]          (expected ["a|b"] split on "|": ["a", "b"])
    tokenize(".")  on "a.b.c"   -> ["", "", "", ""]          (expected ["a", "b", "c"])
    tokenize("+")  on "1+2"     -> PatternSyntaxException: Dangling meta character '+'   (expected ["1", "2"])
    tokenize("[")  on any text  -> PatternSyntaxException: Unclosed character class
    tokenize(",+") on "a,b"     -> ["a", "b"]                (expected ["a,b"]: ",+" does not occur)

Differential: 237 cases (families tok-meta, lang-rand), every one a token with a regex metacharacter and regex unset;
all 1540 tok-exh cases with regex-safe tokens agree.

## Minimal reproducer

    CamelContext c = new DefaultCamelContext(); c.start();
    Exchange ex = new DefaultExchange(c); ex.getMessage().setBody("a|b");
    Expression e = ExpressionReifier.reifier(c, new TokenizerExpression("|")).createExpression();
    e.evaluate(ex, Object.class)   // Iterator over "a", "|", "b"
    // same with from("direct:a").split(body().tokenize("|")) in the Java DSL (ValueBuilder.tokenize)

## Cause

`TokenizeLanguage.createExpression` picks `ExpressionBuilder.tokenizeExpression(source, token)` when `regex` is false,
which calls `ExchangeHelper.getScanner(exchange, value, token)`; `org.apache.camel.util.Scanner(String, String
pattern)` compiles the token with `Pattern.compile` (cachePattern). Nothing quotes the token (`Pattern.quote`), so the
plain mode and the regex mode (`regexTokenizeExpression`) both treat it as a pattern. The XML DSL's `token="\n"`
(tokenize-language.adoc lines 37-38, 59) works because the two characters `\n` are the regex for a new line, which
may be why the quirk went unnoticed; quoting the token would need `\n` (and `\t`, `\r`) mapped to the characters.

## Evidence it is deliberate?

None found. CAMEL-25043 (fac55782529b, "Tokenize language: fix bugs found in a deep review") did not touch it; no
test in core/camel-core/src/test/java/org/apache/camel/language/tokenizer uses a metacharacter token without regex.
The history before 025f7cb97232 (root of this clone) is not available: check JIRA for an older report before filing.

## Also seen (low, same area)

1. Pair mode with a white-space start token fails: `TokenizerExpression("\n")` + `setEndToken(";")` on "x\na;\nb;"
   -> IllegalArgumentException "startToken must be specified and not empty" (expected ["a", "b"]). Cause:
   `TokenPairExpressionIterator` checks `StringHelper.notEmpty(startToken)`, and `ObjectHelper.isEmpty` trims, so a
   new-line, tab or space token counts as empty. The plain mode accepts a new-line token (the documented use,
   tokenize-language.adoc lines 37-38). 2 cases.
2. Pair mode on a null body sets InvalidPayloadException ("No body available of type: java.io.InputStream") on the
   exchange; the plain and regex modes give no tokens, as CAMEL-25043 (fac55782529b) states for tokenize: "a message
   without a body has no tokens instead of failing with a NullPointerException". Rule `L1.lang.tokenize.nullbody`
   (MAINTAINER). 2 cases.
