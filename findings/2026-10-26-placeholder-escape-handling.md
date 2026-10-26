# Property placeholders: escaped brackets \{{ and \}} are handled inconsistently

Status: code-bug candidates (L1 placeholder differential, theories/L1/Placeholder.v). Camel aa63c0a4cb94.
Severity guess: low (backlog): corner cases of the escape syntax; one corrupts text silently (3).

## Rule and doc lines

- `L1.ph.escape` DOC: "it is possible to escape the double curly brackets with a backslash character like for example
  `\{{ property-name \}}`. This way, it won't be interpreted as a property placeholder to resolve and will be resolved
  as `{{ property-name }}`." (using-propertyplaceholder.adoc line 440); the example value escapes only the closing
  brackets: `{"query":{"match_all":{}\\}}` (line 446); "add another backslash in front of it to escape it, it will
  then be seen as a backslash" (line 449).

## Real Camel (resolvePropertyPlaceholders; b=B, a={{b}})

1. An escaped `\}}` in a text that has no unescaped `{{` is not unescaped:
       "x\}}"       -> "x\}}"     (expected "x}}");   "{{b}}\}}" -> "B}}" (agrees)
   Cause: the text is returned unchanged when it holds no placeholder, so `PropertiesComponent.unescape` never runs.
   The doc example (line 446) works only because that value is reached through a placeholder. 293 cases.
2. An escaped `\{{` without an escaped `\}}` fails:
       "\{{x"       -> IllegalArgumentException: Missing {{ from the text: \{{x}}     (expected "{{x")   235 cases.
3. ... and with a trailing backslash it corrupts the text:
       "\{{x\"      -> "{{x}}"    (expected "{{x\": the lone backslash became "}}")   13 cases.
4. An escaped backslash before a placeholder whose value begins with `{{` (nested=false) loses the backslash:
       "\\{{a?nested=false}}"   -> "{{b}}"   (expected "\{{b}}"; with "\\{{b}}" Camel gives "\B", which agrees)
   Cause: the parser turns `\\` into `\`, and the final `unescape` then reads that `\` with the value's `{{` as an
   escape. 9 cases.

## Minimal reproducer

    DefaultCamelContext c = new DefaultCamelContext();
    Properties p = new Properties(); p.setProperty("a", "{{b}}"); p.setProperty("b", "B");
    c.getPropertiesComponent().setInitialProperties(p); c.start();
    c.resolvePropertyPlaceholders("x\\}}");                    // "x\}}"
    c.resolvePropertyPlaceholders("\\{{x");                    // IllegalArgumentException
    c.resolvePropertyPlaceholders("\\{{x\\");                  // "{{x}}"
    c.resolvePropertyPlaceholders("\\\\{{a?nested=false}}");   // "{{b}}"

## Evidence it is deliberate?

CAMEL-24813 (4067ca25bde1) fixed unescape() dropping a trailing backslash and pinned trailing `\n`, `\t`, `\`, `\{`,
`\}` and lone/double/triple backslashes inside values (PropertiesComponentEscapedTest); CAMEL-25110 (9285996c3096)
reworked the parser. None of the four forms above is tested. History before 025f7cb97232 is not in this clone.
