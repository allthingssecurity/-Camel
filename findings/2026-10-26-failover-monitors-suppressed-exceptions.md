# Failover load balancer fails over on a *suppressed* exception, and swallows the real (unmonitored) failure

Status: code-bug candidate (L2 route differential, rule L2.lb.failover; Real mode found it). Camel aa63c0a4cb94.
Severity guess: low-medium (silent: an exception the load balancer is NOT configured to fail over on is dropped, and
the exchange succeeds through the next output, whenever a cleanup step of the failed attempt threw a monitored one).

## Rule and doc lines
- failoverLoadBalancer-eip.adoc 225-228 and model/loadbalancer/failoverLoadBalancer.json `exception`: "A list of class
  names for specific exceptions to monitor" — failover only for those; 78-80: "If all failed, then Camel will throw the
  caused exception which means the Exchange is failed".
- doTry-eip.adoc 227-229: an exception thrown in doFinally while one is pending: "the original exception is kept and the
  exception from the doFinally block is added as a suppressed exception".
- doTry-eip.adoc 211-213 and exception-clause.adoc 177-178 match "the exception and its causes" — doCatch and onException
  do NOT look at suppressed exceptions (verified below), the failover load balancer does.

## Real Camel (harness/probes/FailoverFinallyProbe.java, SuppressedMatchProbe.java)
    from("direct:a").loadBalance().failover(IllegalArgumentException.class)
        .doTry().throwException(new IOException("orig")).doFinally().throwException(new IllegalArgumentException("fin")).end()
        .to("mock:second").end().to("mock:after");
    -> exception=null, mock:second=1, mock:after=1   (expected: IOException "orig", no failover)
    same with the doFinally failing through to("direct:fail"): the same.
    doCatch(IllegalArgumentException) / onException(IllegalArgumentException) on the same IOException: not matched
    (correct, documented).

## Where
FailOverLoadBalancer.shouldFailOver (core-processor, line ~121-140) uses `exchange.getException(exception)` for each
monitored class; ObjectHelper.getException (camel-util ~1264) checks `exception.getSuppressed()` FIRST, then the cause
chain. The suppressed check makes the load balancer treat cleanup failures as the failure.

## Minimal reproducer
    Exchange r = template.send("direct:a", e -> e.getMessage().setBody("in"));
    assertInstanceOf(IOException.class, r.getException());   // fails: null, the second output ran

Differential: runs/lang3-real random-135-4539 (failover monitoring IllegalArgumentException; the attempt's doFinally
called a route that threw IllegalArgumentException; Camel failed over and the route went on).
