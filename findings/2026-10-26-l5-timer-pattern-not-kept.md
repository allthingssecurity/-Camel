# timer: the documented endpoint option `pattern` is consumed by the component and not kept on the endpoint

Status: code-bug candidate (L5a endpoint differential). Camel aa63c0a4cb94.
Severity guess: low (backlog; the pattern is used to parse `time`, but the endpoint reports null for it).

## Rule and doc lines

- `L5.ep.ok` DOC: "If your component has options you can let it have public getters/setters and Camel will
  automatically set the properties when the endpoint is created" (writing-components.adoc lines 57-59); the timer
  table has the endpoint query option `pattern` ("Allows you to specify a custom Date pattern to use for setting the
  time option using URI syntax", docs/component-json/timer.json line 50).

## Real Camel

    timer:t?pattern=abc                 -> endpoint created, getPattern() = null (also through TimerEndpointConfigurer)
    timer:t?pattern=yyyy&time=2026      -> the pattern is used to parse time, getPattern() = null

Differential: 107 cases in runs/l5-doc (every case that sets pattern in its exact case).

## Cause

`TimerComponent.createEndpoint` line 104: `String pattern = getAndRemoveOrResolveReferenceParameter(parameters,
"pattern", String.class);` removes the parameter to parse `time`, and never calls `answer.setPattern(pattern)`, so
the endpoint (JMX, `camel get endpoint`, the configurer, endpoint dumps) shows no pattern.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
TimerEndpoint e = (TimerEndpoint) c.getEndpoint("timer:t?pattern=yyyy-MM-dd");
assertEquals("yyyy-MM-dd", e.getPattern());   // fails: null
```

## Possible fix

`answer.setPattern(pattern)` in `TimerComponent.createEndpoint`.
