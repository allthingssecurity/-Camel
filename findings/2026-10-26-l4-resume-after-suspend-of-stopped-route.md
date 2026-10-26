# suspendRoute of a stopped route, then resumeRoute: the route reports Started but does not consume

Layer L4 (lifecycle). Camel at the pin (apache/camel aa63c0a4cb94, 4.24.0-SNAPSHOT), HotSpot 21. Severity: low to
medium (a route that every status API reports as Started silently consumes nothing).
Found in the UNSPECIFIED recordings of the L4 differential (runs/l4-doc/*.unspec.tsv, reason "RCJ: suspendRoute of a
route that is not started"), confirmed by harness/l4/probes/SuspendStoppedProbe.java.

## Doc lines

The docs do not say what suspendRoute does to a stopped route (the spec calls it UNSPECIFIED), but they do say what
the statuses mean, and the end state contradicts them:

- core/camel-api/src/main/java/org/apache/camel/ServiceStatus.java 38-39: `Started` = "The service is started and
  ready"; 57-59: `isSuspendable()` is true only for `Started`.
- core/camel-api/src/main/java/org/apache/camel/spi/RouteController.java 196-209: suspendRoute suspends the route's
  consumers (or stops them); 228-236: resumeRoute "Resumes the given route if it has been previously suspended".
- components/camel-direct/src/main/docs/direct-component.adoc 16-17: a message to direct: is a "direct, synchronous
  invocation of any consumers"; component-json/direct.json 45: with no active consumer the producer fails.

## What Camel does

| step | getRouteStatus("A") | message to direct:a |
|---|---|---|
| start (A auto-started), stopRoute("A") | Stopped | DirectConsumerNotAvailableException |
| suspendRoute("A") (no exception) | Suspended | DirectConsumerNotAvailableException |
| resumeRoute("A") (no exception) | **Started** | **DirectConsumerNotAvailableException** |
| startRoute("A") | Started | routed |

The route service is marked Suspended although its consumer is stopped (ServiceStatus says only a Started service is
suspendable), and resumeRoute then marks it Started without starting the consumer. A later startRoute repairs it
(InternalRouteStartupManager.isStartable looks at the consumer's own status). For a route that was never started
(autoStartup=false) the same sequence ends with a consuming route, so the stop is what loses the consumer.

## Minimal reproducer

```java
DefaultCamelContext c = new DefaultCamelContext();
c.addRoutes(new RouteBuilder() { public void configure() { from("direct:a").routeId("A").to("mock:a"); } });
c.start();
RouteController rc = c.getRouteController();
rc.stopRoute("A");
rc.suspendRoute("A");                 // no exception; status Suspended
rc.resumeRoute("A");                  // no exception; status Started
c.createProducerTemplate().sendBody("direct:a?block=false", "x");   // DirectConsumerNotAvailableException
```

## Why it matters

Operators suspend and resume routes from JMX, Hawtio, the `camel` CLI (`camel cmd suspend-route` /
`resume-route`) and route policies; a stopped route that is suspended and resumed is then shown as Started (and
health checks see a started route) while nothing is consumed. Either suspendRoute should leave a stopped route alone
(or refuse), or resumeRoute should start the consumer.

## Spec status

No rule: the docs do not say what suspendRoute of a stopped route does (Lifecycle.v answers UNSPECIFIED there), so
this is not a Doc/Real disagreement; the finding is the contradiction with ServiceStatus. If the maintainers state
the intended behaviour, it becomes a MAINTAINER rule.
