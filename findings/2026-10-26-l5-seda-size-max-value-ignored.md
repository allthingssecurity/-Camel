# seda: size=2147483647 (Integer.MAX_VALUE) is taken as "not set" and the queue gets the default capacity 1000

Status: code-bug candidate (L5a endpoint differential, limit family). Camel aa63c0a4cb94.
Severity guess: low (backlog; an explicit, documented value is silently replaced).

## Rule and doc lines

- `L5.ep.ok` / `L5.val.integer` DOC: size "The maximum capacity of the SEDA queue (i.e., the number of messages it can
  hold)", type integer, javaType int, default 1000 (docs/component-json/seda.json line 28); options are set from the
  URI (writing-components.adoc lines 57-59).

## Real Camel

    seda:q1?size=2147483647   -> endpoint size 1000, queue capacity 1000 (no error, no warning)
    seda:q2?size=5000         -> size 5000

Differential: 1 case (limits family, runs/l5-first E-2495).

## Cause

`SedaEndpoint.getQueue` line 251: `Integer size = (getSize() == Integer.MAX_VALUE || getSize() ==
SedaConstants.QUEUE_SIZE) ? null : getSize();` uses MAX_VALUE (and 1000) as the marker for "use the existing queue or
the component default", then `setSize(ref.getSize())`. So a URI that asks for the largest queue gets the default one;
and an explicit `size=1000` also reuses an existing queue of another size instead of failing with "Cannot use existing
queue ... does not match given queue size".

## Minimal reproducer

```java
CamelContext c = new DefaultCamelContext(); c.start();
SedaEndpoint e = (SedaEndpoint) c.getEndpoint("seda:q1?size=2147483647");
assertEquals(Integer.MAX_VALUE, e.getSize());   // fails: 1000
```
