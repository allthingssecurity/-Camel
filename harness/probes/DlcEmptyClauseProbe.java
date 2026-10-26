import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** Dead letter channel + an onException clause WITHOUT steps (only handled/continued/redelivery options). */
public class DlcEmptyClauseProbe {
  static void run(String name, boolean dlc, String h, boolean steps, int n) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (dlc) errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      var oe = onException(IllegalArgumentException.class);
      if (h.equals("true")) oe.handled(true); if (h.equals("false")) oe.handled(false); if (h.equals("continued")) oe.continued(true);
      if (n > 0) oe.maximumRedeliveries(n).redeliveryDelay(0);
      if (steps) oe.to("mock:oe");
      from("direct:a").setHeader("h", constant("1")).throwException(new IllegalArgumentException("x")).to("mock:after");
    }});
    try { c.start(); } catch (Exception e) { System.out.printf("%-40s start fails: %s%n", name, e.getClass().getSimpleName()); return; }
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    int dead = c.getEndpoint("mock:dead", MockEndpoint.class).getReceivedCounter();
    int oe = c.getEndpoint("mock:oe", MockEndpoint.class).getReceivedCounter();
    int after = c.getEndpoint("mock:after", MockEndpoint.class).getReceivedCounter();
    System.out.printf("%-40s oe=%d dead=%d after=%d exc=%s%n", name, oe, dead, after, x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean d : new boolean[] {false, true})
      for (String h : new String[] {"unset", "false", "true", "continued"})
        for (boolean s : new boolean[] {true, false})
          for (int n : new int[] {0, 2})
            run((d ? "DLC " : "DEH ") + h + (s ? " steps" : " no-steps") + " n=" + n, d, h, s, n);
  }
}
