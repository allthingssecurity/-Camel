# Catalog: a missing path part is also reported as an invalid value ("") of its option

Status: code-bug candidate (L5a catalog differential, `CamelCatalog.validateEndpointProperties`). Camel aa63c0a4cb94.
Severity guess: low (backlog; tooling noise: one error is reported twice, as missing and as invalid).

## Rule and doc lines

- `L5.cat.validate` DOC: the catalog check reports "unknown options with the closest real names, invalid values,
  missing path parts" (camel-jbang-mcp.adoc lines 305-306); "values that are not among the allowed ones"
  (camel-jbang-tui-ai-agents.adoc line 239). A path part that is not there is missing, not an invalid value.
- `PropertiesValidationResult` javadoc: `addRequired` "Adds a missing required option error" (line 150),
  `addInvalidEnum` "Adds an invalid enum value error" (line 174).

## Real Camel

    validateEndpointProperties("alibaba-kms:?numberOfBytes=42")   -> required [operation, region]; invalidEnum {operation=""}
    validateEndpointProperties("openai:?maxTokens=1")             -> required [operation];         invalidEnum {operation=""}
    validateEndpointProperties("smpp:?transactionTimer=1000")     -> invalidInteger {port=""}

Differential: 86 cases in runs/l5-doc (every URI with an empty path whose syntax has an enum or integer path
option).

## Cause

`AbstractCamelCatalog.endpointProperties` gives the missing path names an empty value, and
`validateEndpointProperties` then checks that empty value against the enum / integer type (as well as reporting it
required, lines 323-325).

## Minimal reproducer

```java
EndpointValidationResult r = new DefaultCamelCatalog().validateEndpointProperties("openai:?maxTokens=1");
assertNull(r.getInvalidEnum());    // fails: {operation=}
```
