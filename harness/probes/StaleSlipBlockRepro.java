import org.apache.camel.*;
import org.apache.camel.builder.AggregationStrategies;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import org.apache.camel.model.language.ConstantExpression;
import org.apache.camel.model.loadbalancer.FailoverLoadBalancerDefinition;
import java.util.*;
import java.util.concurrent.*;

/** findings/2026-10-26-routingslip-uses-stale-recipientlist-value.md (the campaign case, combo-11-1902 minimized)
 *  The send blocks for 30 s (the direct: consumer timeout), because the routing slip goes to the recipient list's value: a dead letter channel with redelivery, a failover load balancer whose doTry's
 *  doFinally runs a routing slip into a route with nested doTry/doFinally/doCatch and a recipient list into a failing
 *  route. Built with the Camel model API (nested doTry blocks do not type-check in the fluent Java DSL).
 *  usage: StaleSlipBlockRepro [variant]   (variants: see main) */
public class StaleSlipBlockRepro {
  static ProcessorDefinition<?> thr(Exception e) { ThrowExceptionDefinition d = new ThrowExceptionDefinition(); d.setException(e); return d; }
  static TryDefinition tryOf(List<ProcessorDefinition<?>> body, Class<? extends Throwable> catchCls, List<ProcessorDefinition<?>> catchBody,
                             List<ProcessorDefinition<?>> fin) {
    TryDefinition t = new TryDefinition();
    for (ProcessorDefinition<?> p : body) t.addOutput(p);
    if (catchCls != null) { CatchDefinition c = new CatchDefinition(); c.setExceptionClasses(List.of(catchCls)); for (ProcessorDefinition<?> p : catchBody) c.addOutput(p); t.addOutput(c); }
    if (fin != null) { FinallyDefinition f = new FinallyDefinition(); for (ProcessorDefinition<?> p : fin) f.addOutput(p); t.addOutput(f); }
    return t;
  }
  static ProcessorDefinition<?> slip(String s) { return new RoutingSlipDefinition<>(new ConstantExpression(s)); }
  static ProcessorDefinition<?> rl(String s, String strategy) {
    RecipientListDefinition<?> d = new RecipientListDefinition<>(new ConstantExpression(s)); d.setDelimiter(";");
    if (strategy.equals("original")) d.aggregationStrategy(AggregationStrategies.useOriginal());
    return d;
  }
  static ProcessorDefinition<?> to(String u) { return new ToDefinition(u); }

  public static void main(String[] a) throws Exception {
    String v = a.length > 0 ? a[0] : "min";
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (!v.equals("defaultEH"))
        errorHandler(deadLetterChannel("mock:dead").maximumRedeliveries(v.equals("dlc0") ? 0 : 1).redeliveryDelay(0));
      // r0: failover { doTry { throw ISE } doFinally { routingSlip direct:r2 } }
      ProcessorDefinition<?> r0inner = tryOf(List.of(thr(new IllegalStateException("ab"))), null, null,
          List.of(v.equals("toInsteadOfSlip") ? to("direct:r2") : slip("direct:r2")));
      RouteDefinition r0 = from("direct:r0");
      if (v.equals("noFailover")) r0.addOutput(r0inner);
      else {
        LoadBalanceDefinition lb = new LoadBalanceDefinition();
        FailoverLoadBalancerDefinition f = new FailoverLoadBalancerDefinition(); f.setMaximumFailoverAttempts("0");
        lb.setLoadBalancerType(f); lb.addOutput(r0inner); r0.addOutput(lb);
      }
      // r2: doTry { doTry { throw ISE } doFinally { doTry { throw IAE } doFinally { to r3 } } }
      //     doCatch(RuntimeException) { doTry { to mock:m2 } doFinally { recipientList direct:r3;mock:m1;direct:r3 } }
      ProcessorDefinition<?> fin2 = tryOf(List.of(thr(new IllegalArgumentException("ab"))), null, null, List.of(to("direct:r3")));
      ProcessorDefinition<?> mid = tryOf(List.of(thr(new IllegalStateException("1"))), null, null,
          v.equals("noInnerFinally") ? List.of() : List.of(fin2));
      String list = v.equals("rlR3") ? "direct:r3" : v.equals("rlR3R3") ? "direct:r3;direct:r3" : "direct:r3;mock:m1;direct:r3";
      ProcessorDefinition<?> inCatch = tryOf(List.of(to("mock:m2")), null, null, List.of(rl(list, v.equals("rlNoStrategy") ? "none" : "original")));
      from("direct:r2").addOutput(tryOf(List.of(mid), RuntimeException.class, List.of(inCatch), null));
      from("direct:r3").addOutput(thr(new java.io.IOException("ab")));
    }});
    c.start();
    ExecutorService w = Executors.newSingleThreadExecutor();
    Future<Exchange> f = w.submit(() -> c.createProducerTemplate().send("direct:r0", e -> e.getMessage().setBody("a,b")));
    try { Exchange x = f.get(Long.getLong("wait", 5), TimeUnit.SECONDS); System.out.printf("%-16s returned, exception=%s%n", v, x.getException()); }
    catch (TimeoutException te) { System.out.printf("%-16s HANG: send did not return within 5 s; inflight=%d%n", v, c.getInflightRepository().size()); }
    System.exit(0);
  }
}
