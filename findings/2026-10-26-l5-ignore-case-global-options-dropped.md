# Endpoint options written in another case are accepted but lost (or bypass the component's checks)

Status: code-bug candidate (L5a endpoint differential, theories/L5/Uri.v). Camel aa63c0a4cb94.
Severity guess: medium-low (silent misconfiguration: no error, the value is not used; for seda a documented limit is
bypassed).

## Rule and doc lines

- `L5.opt.name-ignore-case` DOC: property binding, which configures endpoints ("Camel supports binding property
  values (key=value) in many places such as configuration of Camel components, endpoints", property-binding.adoc
  lines 3-4), has "_ignore case_ - Whether to ignore case for property keys (will ignore by default)" (line 41).
- `L5.b.seda.concurrent-limit` DOC: seda limitConcurrentConsumers "Whether to limit the number of concurrentConsumers
  to the maximum of 500. By default, an exception will be thrown if an endpoint is configured with a greater number"
  (docs/component-json/seda.json line 51).

## Real Camel

The generated configurers do match names in any case, so an option in another case is set and is not reported as
unknown. But options that `DefaultComponent.createEndpoint` or a component's `createEndpoint` read themselves with
`getAndRemoveParameter(parameters, "<exactName>", ...)` are only found in their exact case:

    direct:x?lazyStartProducer=true      -> lazyStartProducer = true
    direct:x?lazystartproducer=true      -> lazyStartProducer = false   (no error)
    direct:s8?BRIDGEERRORHANDLER=true    -> bridgeErrorHandler = false  (no error)
    seda:q?concurrentConsumers=1000      -> ResolveEndpointFailedException (limit 500, as documented)
    seda:q?ConcurrentConsumers=1000      -> endpoint with 1000 concurrent consumers (no error)

Differential (runs/l5-doc): 38 cases (lazyStartProducer / bridgeErrorHandler on bean, controlbus, direct, log, mock, seda, timer; seda
concurrentConsumers; all agree in the exact case.

## Cause

`DefaultComponent.createEndpoint(String, Map)` (camel-support, lines 146-176 at the pin) reads
`bridgeErrorHandler`, `lazyStartProducer` and `autowiredEnabled` with exact-name `getAndRemoveParameter`, lets the
component create the endpoint (whose `setProperties` sets the other-case key through the case-insensitive
configurer), and then overwrites the three values with what it read (`de.setLazyStartProducer(lazy)` etc.), i.e. the
defaults. `SedaComponent.createEndpoint` reads `concurrentConsumers` (and checks the 500 limit), `size`,
`offerTimeout`, `pollTimeout`, ... the same way, so the other-case key skips the check and is then set by the
configurer. Other components that read options with `getAndRemoveParameter` are likely affected the same way (not
checked: L5a only compiles direct, mock, seda, log, timer, bean, controlbus). History before 025f7cb97232 (root of the
local clone) not available.

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
DirectEndpoint e = (DirectEndpoint) c.getEndpoint("direct:x?LAZYSTARTPRODUCER=true");
assertTrue(e.isLazyStartProducer());              // fails: false
assertThrows(ResolveEndpointFailedException.class,
    () -> c.getEndpoint("seda:q?ConcurrentConsumers=1000"));   // fails: no exception
```

## Possible fix (for the pipeline to judge)

Make `getAndRemoveParameter` (or these call sites) match the key ignoring case, as the configurers do, or reject a key
that only differs in case.
