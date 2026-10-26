import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import java.util.concurrent.*;

/** findings/2026-10-26-routingslip-uses-stale-recipientlist-value.md
 *  A recipient list whose expression is evaluated but which does not run leaves its value (exchange property
 *  CamelEvaluateExpressionResult) on the exchange; a later routing slip or recipient list then routes to THOSE
 *  endpoints instead of evaluating its own expression. */
public class StaleRecipientsProbe {
  public static void main(String[] a) throws Exception {
    for (String v : new String[] {"slip", "slip-noDLC", "slip-noFailure", "recipientList", "dynamicRouter", "slip-sameRoute", "slip-onException-handled"})
      run(v);
    System.exit(0);
  }
  static void run(String v) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (v.endsWith("onException-handled")) onException(Exception.class).handled(true).to("mock:handled");
      else if (!v.endsWith("noDLC")) errorHandler(deadLetterChannel("mock:dead"));
      if (v.equals("slip-sameRoute")) {
        // r0: doTry { to r3 (fails, dead letter) } doFinally { recipientList mock:a,mock:b ; ... } then a slip after
        from("direct:r0")
            .doTry().to("direct:r2").doFinally().routingSlip(constant("mock:slip")).end();
        from("direct:r2")
            .doTry().to("direct:r3").doFinally().recipientList(constant("mock:a,mock:b")).to("mock:fin").end();
      } else {
        var t = from("direct:r0").doTry().to("direct:r2").doFinally();
        if (v.startsWith("recipientList")) t.recipientList(constant("mock:slip"));
        else if (v.startsWith("dynamicRouter")) t.dynamicRouter(method(StaleRecipientsProbe.class, "once"));
        else t.routingSlip(constant("mock:slip"));
        t.end();
        from("direct:r2")
            .doTry().to("direct:r3").doFinally().recipientList(constant("mock:a,mock:b")).end();
      }
      if (v.equals("slip-noFailure")) from("direct:r3").to("mock:r3");
      else from("direct:r3").throwException(new java.io.IOException("r3 failed"));
    }});
    c.start();
    ExecutorService w = Executors.newSingleThreadExecutor();
    Future<Exchange> f = w.submit(() -> c.createProducerTemplate().send("direct:r0", e -> e.getMessage().setBody("b")));
    String res;
    try { Exchange x = f.get(5, TimeUnit.SECONDS); res = "exception=" + (x.getException() == null ? "-" : x.getException().getClass().getSimpleName()); }
    catch (TimeoutException te) { res = "HANG (5 s)"; }
    System.out.printf("%-26s mock:slip=%d mock:a=%d mock:b=%d mock:dead=%d %s%n", v, n(c, "slip"), n(c, "a"), n(c, "b"), n(c, "dead"), res);
    w.shutdownNow();
    c.stop();
  }
  static int n(CamelContext c, String m) { return c.getEndpoint("mock:" + m, MockEndpoint.class).getReceivedCounter(); }
  public static String once(Exchange e) { return e.getProperty("done") != null ? null : set(e); }
  static String set(Exchange e) { e.setProperty("done", true); return "mock:slip"; }
}
