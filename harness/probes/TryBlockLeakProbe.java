import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;

/** findings/2026-10-26-dotry-in-caller-disables-eip-error-handling-in-called-route.md
 *  Does a doTry in the CALLER change how a routing slip / multicast / recipient list in the CALLED route redelivers?
 *  variant <caller> <eip>: caller = plain | doTry; eip = slip | multicast | recipientList | dynamicRouter */
public class TryBlockLeakProbe {
  public static void main(String[] a) throws Exception {
    for (String caller : new String[] {"plain", "doTryFinally", "doTryCatchOther", "doTryCatchAll"})
      for (String eip : new String[] {"slip", "multicast", "recipientList", "dynamicRouter", "enrichLike"})
        run(caller, eip);
    System.exit(0);
  }
  static void run(String caller, String eip) throws Exception {
    CamelContext c = new DefaultCamelContext();
    AtomicInteger failCalls = new AtomicInteger();
    c.addRoutes(new RouteBuilder() { public void configure() {
      onException(IllegalStateException.class).maximumRedeliveries(2).redeliveryDelay(0);
      switch (caller) {
        case "plain": from("direct:r0").to("direct:r1"); break;
        case "doTryFinally": from("direct:r0").doTry().to("direct:r1").doFinally().to("mock:fin").end(); break;
        case "doTryCatchOther": from("direct:r0").doTry().to("direct:r1").doCatch(java.io.IOException.class).to("mock:fin").end(); break;
        default: from("direct:r0").doTry().to("direct:r1").doCatch(Exception.class).to("mock:fin").end(); break;
      }
      switch (eip) {
        case "slip": from("direct:r1").routingSlip(constant("mock:m1,direct:fail")); break;
        case "multicast": from("direct:r1").multicast().to("mock:m1", "direct:fail").end(); break;
        case "recipientList": from("direct:r1").recipientList(constant("mock:m1,direct:fail")); break;
        case "dynamicRouter": from("direct:r1").dynamicRouter(method(TryBlockLeakProbe.class, "next")); break;
        default: from("direct:r1").to("mock:m1").to("direct:fail"); break;
      }
      // the failing output: a route without error handler (as an external endpoint whose producer throws)
      from("direct:fail").errorHandler(noErrorHandler()).process(e -> { failCalls.incrementAndGet(); throw new IllegalStateException("boom"); });
    }});
    c.start();
    MockEndpoint m1 = c.getEndpoint("mock:m1", MockEndpoint.class);
    ROUTER_CALLS.set(0);
    Exchange x = c.createProducerTemplate().send("direct:r0", e -> e.getMessage().setBody("b"));
    System.out.printf("%-16s %-14s mock:m1=%d fail-calls=%d router-calls=%d exception=%s%n", caller, eip, m1.getReceivedCounter(), failCalls.get(), ROUTER_CALLS.get(),
        x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  static final AtomicInteger ROUTER_CALLS = new AtomicInteger();
  public static String next(Exchange e) {
    ROUTER_CALLS.incrementAndGet();
    int n = e.getProperty("hops", 0, Integer.class);
    e.setProperty("hops", n + 1);
    return n == 0 ? "mock:m1" : n == 1 ? "direct:fail" : null;
  }
}
