# seda offerTimeout does not take the documented duration syntax (5s, 1m30s, 45minutes)

Status: code-bug candidate (L5a endpoint differential). Camel aa63c0a4cb94.
Severity guess: low-medium (fails fast at startup with a NumberFormatException; the documented syntax is refused).

## Rule and doc lines

- `L5.val.duration` DOC: "Some of the Camel components offers options to specify a time period, which must be
  entered in millisecond as unit ... In Camel you can configure this in a more readable syntax" (endpoint.adoc lines
  415-431: h, m, s; lines 476-478 mixed units; lines 528-534 long forms). The seda JSON marks offerTimeout as
  `"type": "duration"` (docs/component-json/seda.json, `offerTimeout`), and the endpoint field has
  `@UriParam(javaType = "java.time.Duration")` (SedaEndpoint line 135).

## Real Camel

    seda:a?timeout=5s          -> timeout = 5000          (also a duration option of seda: works)
    seda:a?offerTimeout=5000   -> offerTimeout = 5000
    seda:a?offerTimeout=5s     -> ResolveEndpointFailedException <- TypeConversionException <- NumberFormatException
    seda:a?offerTimeout=45m / 1h15m / 45minutes / 100s   -> the same

Differential: 47 cases in runs/l5-doc, all with a readable duration for offerTimeout.

## Cause

`SedaComponent.createEndpoint` line 274: `long offerTimeout = getAndRemoveParameter(parameters, "offerTimeout",
long.class, defaultOfferTimeout);` converts the text to `long` directly; the generated `SedaEndpointConfigurer`
(line 51) would convert through `java.time.Duration` (`property(camelContext, java.time.Duration.class,
value).toMillis()`), as it does for `timeout`, but it never sees the parameter. History before 025f7cb97232 not
available.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
SedaEndpoint e = (SedaEndpoint) c.getEndpoint("seda:a?offerTimeout=5s");   // throws ResolveEndpointFailedException
assertEquals(5000, e.getOfferTimeout());
```

## Possible fix (for the pipeline to judge)

Read the parameter as `java.time.Duration` (then `toMillis()`), or leave it to the configurer and apply the component
default only when it is absent.
