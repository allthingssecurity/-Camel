# A route without startupOrder gets a new number on every start: spurious FailedToStartRouteException

Layer L4 (lifecycle). Camel at the pin (apache/camel aa63c0a4cb94, 4.24.0-SNAPSHOT), HotSpot 21. Severity: low
(spurious, often transient start failure; shutdown order of late-started routes).

## Rule and doc lines

Rule `L4.order.auto-assign` (theories/L4/Lifecycle.v, `assign`), from
docs/user-manual/modules/ROOT/pages/configuring-route-startup-ordering-and-autostartup.adoc:

- 188-191: "Normally you should also use numbers that are lower than 1000, as routes without an explicit
  `startupOrder` definition will have a number starting from 1000 auto assigned."
- 193-196: "However, you can also use higher numbers than 1000 (to avoid collisions with those auto assigned
  numbers) to specify the last routes to start up. Normally, the usage of numbers starting from 10000 should be safe
  for the purpose."
- 339-342 and 429-434 (examples): each route without startupOrder gets one number (1000, 1001, ... in the order the
  routes are defined).
- 18-52: with `autoStartup=false` on the context, start the routes later with
  `getRouteController().startAllRoutes()`.

So a route without startupOrder has one number, and an explicit number above the auto-assigned range (or from
10000) does not clash with it.

## What Camel does

`InternalRouteStartupManager.doPrepareRouteToBeStarted` assigns `defaultRouteStartupOrder++` (a counter of the
context, from 1000) each time a route without startupOrder is prepared to be started: at the context start (for
every route, also the ones with autoStartup=false, and also when the context has autoStartup=false), and again on
every `startRoute`, `startAllRoutes`, `resumeRoute`, context `suspend` and `resume` of such a route. The new number
is then checked by `doCheckStartupOrderClash` against every route in `getRouteStartupOrder()` (routes started
before, also the ones stopped since, which stay in that list) and against the routes started in the same batch. When
it equals another route's number the start fails with
`FailedToStartRouteException: ... Route startup order clash. Route B already has startupOrder 1001 configured which
this route have as well`, although neither route has a clashing configuration. The number kept in
`getRouteStartupOrder()` (used for the shutdown order) stays the one of the first start.

Measured (harness/l4/probes/OrderProbe.java, CounterProbe.java):

1. Routes A (no startupOrder) and B (startupOrder 1001): `start()` works (A=1000, B=1001); `stopRoute("A")`;
   `startRoute("A")` throws FailedToStartRouteException (A was given 1001).
2. Routes A (no startupOrder) and Z (startupOrder 10000, the doc's "should be safe" range): 8 999 stop/start cycles of
   A work; the 9 000th `startRoute("A")` throws FailedToStartRouteException (A was given 10000). Restarts of a route
   happen in normal operation: route policies (scheduled, throttling), the supervising route controller's restart
   attempts with backoff, JMX / Hawtio / `camel` CLI.
3. Context with autoStartup=false (the doc's pattern [CFG.18-52]), routes A (no startupOrder), B (startupOrder 0),
   C (startupOrder 1001): `start()`; `getRouteController().startAllRoutes()` throws FailedToStartRouteException (A
   was given 1000 at the context start and 1001 at startAllRoutes). Differential case limits-2-652.
4. The counter also moves on context suspend/resume and resumeRoute (CounterProbe: next=1003 after start, 1004 after
   resumeRoute A, 1006 after suspend, 1008 after resume), so a route with autoStartup=false started later gets a
   number such as 1008, not one of 1000..1000+n-1.

## Minimal reproducer

```java
DefaultCamelContext c = new DefaultCamelContext();
c.addRoutes(new RouteBuilder() { public void configure() {
    from("direct:a").routeId("A").to("mock:a");
    from("direct:b").routeId("B").startupOrder(1001).to("mock:b");
}});
c.start();
c.getRouteController().stopRoute("A");
c.getRouteController().startRoute("A");   // FailedToStartRouteException: Route startup order clash
```

## Differential evidence

Doc mode (rules as documented, after the DOC-BUG on the stop order, notes/l4.md): every Doc-mode mismatch of
runs/l4-doc is of this class (spurious FailedToStartRouteException on startRoute / startAllRoutes / resumeRoute, or a
stop order that follows the renumbered first-start number of a route started late). Real mode = Doc + this finding as
the delta `L4.order.renumber.real` / `L4.route.start.clash.real` / `L4.rc.startAll.clash.real`: 0 mismatches.

## History

The local clone's history starts at 025f7cb97232 (shallow), so the commit that introduced the counter cannot be
seen here. The comment at the list update ("we dont want to double add when restarting") shows restarts were
considered for the list but not for the number.

## Possible fix (for the Camel pipeline to judge)

Assign the auto number once per route: in `doPrepareRouteToBeStarted`, reuse the number of the route's existing
`RouteStartupOrder` entry (or a per-route map kept by InternalRouteStartupManager, cleared on removeRoute), and only
take `defaultRouteStartupOrder++` the first time. Then a restart cannot clash with routes it did not clash with at
the first start, and the 1000+ / 10000 advice of the docs holds.
