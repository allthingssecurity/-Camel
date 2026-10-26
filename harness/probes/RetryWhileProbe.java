import java.util.*;
import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** retryWhile and onRedelivery on onException (exception-advanced.adoc 242-300, 393-425): order, counters, headers. */
public class RetryWhileProbe {
  static List<String> seen = Collections.synchronizedList(new ArrayList<>());
  static Processor onr = e -> { Object v = e.getMessage().getHeader("onr"); e.getMessage().setHeader("onr", (v == null ? "" : v.toString()) + "r");
    seen.add("onRedelivery(counter=" + e.getMessage().getHeader(Exchange.REDELIVERY_COUNTER) + ")"); };
  static void run(String name, String retry, int max, boolean redel, String mode) throws Exception {
    seen.clear(); int[] attempts = {0};
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      var oe = onException(IllegalArgumentException.class).redeliveryDelay(0);
      if (max >= 0) oe.maximumRedeliveries(max);
      if (retry != null) oe.retryWhile(simple(retry));
      if (redel) oe.onRedelivery(onr);
      if (mode.equals("handled")) oe.handled(true);
      if (mode.equals("continued")) oe.continued(true);
      oe.process(e -> seen.add("block headers=" + new TreeMap<>(e.getMessage().getHeaders())));
      from("direct:a").process(e -> { attempts[0]++; seen.add("attempt onr=" + e.getMessage().getHeader("onr") + " counter=" + e.getMessage().getHeader(Exchange.REDELIVERY_COUNTER)); })
        .throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    System.out.println(name + ": attempts=" + attempts[0] + " " + seen + " caller headers=" + new TreeMap<>(x.getMessage().getHeaders())
        + " exc=" + (x.getException() == null ? "-" : x.getException().getClass().getSimpleName()));
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    // note: the process step before the throw re-runs only if redelivery restarts there; it does not (point of failure)
    run("retry<3", "${header.CamelRedeliveryCounter} < 3", -1, false, "unhandled");
    run("retry<3 +onr", "${header.CamelRedeliveryCounter} < 3", -1, true, "unhandled");
    run("retry<3 +onr handled", "${header.CamelRedeliveryCounter} < 3", -1, true, "handled");
    run("retry<3 +onr continued", "${header.CamelRedeliveryCounter} < 3", -1, true, "continued");
    run("retry<3 max=1", "${header.CamelRedeliveryCounter} < 3", 1, false, "unhandled");
    run("retry<3 max=5", "${header.CamelRedeliveryCounter} < 3", 5, false, "unhandled");
    run("retry false", "${header.CamelRedeliveryCounter} < 1", -1, true, "unhandled");
    run("retry on onr", "${header.onr} == null || ${header.onr} == 'r'", -1, true, "unhandled");
    run("max=2 +onr", null, 2, true, "unhandled");
    run("max=0 +onr", null, 0, true, "unhandled");
  }
}
