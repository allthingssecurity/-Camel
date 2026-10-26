# An exception escaping a doTry is handled by onException only when the doTry is nested in another EIP

Status: code-bug candidate (or doc bug: the pipeline decides), L3 route differential, rules L3.doTry.uncaught /
L3.errorHandler.default / L3.doTry.escape.real. Camel aa63c0a4cb94.
Severity guess: medium (the same doTry block behaves differently with respect to onException, redelivery and the dead
letter channel depending on whether it is wrapped in a filter/choice/pipeline; an onException(...).handled(true) can
silently turn a failing exchange into a successful one, or not).

## Doc lines (docs/core/camel-core-engine/src/main/docs/modules/eips/pages/doTry-eip.adoc)
- 22-27: "When using doTry ... doCatch ... doFinally, the regular Camel Error Handler is not in use; meaning any
  onException or the likes does not trigger."
- 221-225: "An exception that is not caught by any doCatch (or an exception that is thrown in a doCatch or doFinally
  block) is not handled by the route error handler: onException, redelivery and the dead letter channel are not in use
  for the steps of a doTry ... doCatch ... doFinally block. The exception is thrown from the doTry, and the exchange
  fails."
Lines 221-229 were written by a maintainer in 9ca2736acd4d (CAMEL-25114, "doTry, doCatch and doFinally: fix bugs found
in a deep review", 2026-09-28), so they state the intended behaviour; no test of that commit pins the uncaught case
(DoTryEdgeCasesTest covers a dead letter channel with the exception caught by an outer doCatch).

## Real Camel (harness/probes/EhProbe.java)
    onException(IllegalStateException.class).handled(true).transform(constant("eh"));
    from("direct:a").doTry().throwException(new IllegalStateException("x")).doFinally().to("mock:f").end().to("mock:after");
      -> body=in exc=IllegalStateException                      (as documented: not handled)
    from("direct:a").pipeline().doTry()...same...end().end()   -> body=eh exc=-   (handled by onException)
    from("direct:a").filter(constant(true)).doTry()...         -> body=eh exc=-
    from("direct:a").choice().when(constant(true)).doTry()...  -> body=eh exc=-
    doCatch rethrowing: top-level -> exc=IllegalStateException; inside a filter -> body=eh exc=-
With no matching clause the nested case also gets CamelRedelivered=false / CamelRedeliveryCounter=0 headers (the
error handler processed it at the enclosing node); the top-level case does not.

Differential: Doc mode (the documented rule) disagrees in every generated case where an exception escapes a doTry
nested in filter/choice/pipeline in a route with onException clauses (runs/oe5: part of the 110 Doc-mode
disagreements of 5 000 cases; the Real mode leaves these cases UNSPECIFIED and shows 0 disagreements).

## Likely cause (for the red-team)
The error handler wraps each node's processor in a channel. A doTry that is a direct step of the route is not wrapped
(TryReifier / the "doTry has its own error handler" special case), but the enclosing filter/choice/pipeline node is,
so an exception that leaves the doTry is processed by the enclosing node's error handler.

## Minimal reproducer
    onException(IllegalStateException.class).handled(true);
    from("direct:a").filter(constant(true)).doTry().throwException(new IllegalStateException("x")).doFinally().end().end();
    Exchange r = template.send("direct:a", e -> {});
    assertNotNull(r.getException());   // fails: handled by onException
