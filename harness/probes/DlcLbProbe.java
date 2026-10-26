import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** Dead letter channel + onException + a failure inside a load balancer: is the onException clause used? */
public class DlcLbProbe {
  static void run(String name, boolean dlc, String where, String handled) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (dlc) errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      var oe = onException(IllegalArgumentException.class).to("mock:oe");
      if (handled.equals("true")) oe.handled(true); if (handled.equals("continued")) oe.continued(true);
      var r = from("direct:a").to("mock:before");
      switch (where) {
        case "plain" -> r.throwException(new IllegalArgumentException("x"));
        case "rr" -> r.loadBalance().roundRobin().pipeline().throwException(new IllegalArgumentException("x")).end().end();
        case "rr-direct" -> r.loadBalance().roundRobin().to("direct:b").end();
        case "failover" -> r.loadBalance().failover(java.io.IOException.class).pipeline().throwException(new IllegalArgumentException("x")).end().end();
        case "pipeline" -> r.pipeline().throwException(new IllegalArgumentException("x")).end();
        case "filter" -> r.filter(constant(true)).throwException(new IllegalArgumentException("x")).end();
        case "multicast" -> r.multicast().pipeline().throwException(new IllegalArgumentException("x")).end().end();
      }
      r.to("mock:after");
      from("direct:b").throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    int dead = c.getEndpoint("mock:dead", MockEndpoint.class).getReceivedCounter();
    int oe = c.getEndpoint("mock:oe", MockEndpoint.class).getReceivedCounter();
    int after = c.getEndpoint("mock:after", MockEndpoint.class).getReceivedCounter();
    System.out.printf("%-34s oe=%d dead=%d after=%d exc=%s%n", name, oe, dead, after,
        x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (String h : new String[] {"true", "unset", "continued"})
      for (String w : new String[] {"plain", "pipeline", "filter", "rr", "rr-direct", "failover", "multicast"})
        for (boolean d : new boolean[] {false, true})
          run((d ? "DLC " : "DEH ") + "handled=" + h + " " + w, d, w, h);
  }
}
