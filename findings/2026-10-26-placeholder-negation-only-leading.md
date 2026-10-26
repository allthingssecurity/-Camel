# Property placeholders: {{!key}} is only negated when it starts the whole text

Status: code-bug candidate (L1 placeholder differential, theories/L1/Placeholder.v). Camel aa63c0a4cb94.
Severity guess: low-medium. Inside a longer text the negation is either an error or, worse, silently dropped.

## Rule and doc lines

- `L1.ph.negate` DOC: "If a property placeholder is a boolean value, then it is possible to negate (reverse) the value
  by using `!` as prefix in the key." (using-propertyplaceholder.adoc line 126; example lines 147, 160, 178, 187-188).
  Nothing limits it to a text made of that one placeholder.

## Real Camel (flag=true, b=B)

    resolvePropertyPlaceholders("{{!flag}}")        -> "false"   (agrees)
    resolvePropertyPlaceholders("x={{!flag}}")      -> IllegalArgumentException: Property with key [!flag] not found
    resolvePropertyPlaceholders("{{!flag}}-{{b}}")  -> "true-B"  (negation silently dropped; expected "false-B")
    a property a={{!flag}} used as {{a}}            -> IllegalArgumentException: Property with key [!flag] not found

Differential: 46 cases (ph-forms, ph-exh, ph-nested), all of this shape; 36 leading-negation cases agree.

## Minimal reproducer

    DefaultCamelContext c = new DefaultCamelContext();
    Properties p = new Properties(); p.setProperty("flag", "true"); p.setProperty("b", "B");
    c.getPropertiesComponent().setInitialProperties(p); c.start();
    c.resolvePropertyPlaceholders("{{!flag}}-{{b}}");   // "true-B"
    c.resolvePropertyPlaceholders("x={{!flag}}");       // IllegalArgumentException

## Cause

`PropertiesComponent.parseUri` (camel-base, lines 383-397 at the pin) tests `key.startsWith(NEGATE_PREFIX)` on the
whole input text (NEGATE_PREFIX = "{{!"), strips the `!`, parses the whole text, and negates the whole answer only if
it is exactly true/false. `DefaultPropertiesParser` itself does not know the `!` prefix, so a `{{!key}}` anywhere
else is looked up as the key "!key".

## Evidence it is deliberate?

PropertiesComponentNegateTest only uses the whole-text form `autoStartup("{{!integration.ftpEnabled}}")`. No other
test, no JIRA in the local history (root 025f7cb97232).
