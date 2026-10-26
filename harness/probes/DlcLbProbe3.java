import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** As DlcLbProbe2, with the dead letter channel set on the route (route-level errorHandler, as the XML/YAML DSL
 *  <route><errorHandler> of error-handler.adoc 259-268 and the harness do) next to route-scoped onException. */
public class DlcLbProbe3 {
  static void run(String name, boolean nfe, int n, boolean orig, String shape) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      var dlc = deadLetterChannel("mock:dead").maximumRedeliveries(n).redeliveryDelay(0);
      if (orig) dlc.useOriginalMessage();
      var r = from("direct:a").errorHandler(dlc);
      if (nfe) r.onException(NumberFormatException.class).continued(true).end();
      r.onException(Exception.class).handled(true).to("mock:oe").end();
      switch (shape) {
        case "lb-pipeline" -> r.loadBalance().roundRobin().pipeline().throwException(new IllegalArgumentException("x")).end().end();
        case "lb" -> r.loadBalance().roundRobin().throwException(new IllegalArgumentException("x")).end();
        case "pipeline" -> r.pipeline().throwException(new IllegalArgumentException("x")).end();
        case "filter" -> r.filter(constant(true)).throwException(new IllegalArgumentException("x")).end();
        case "split" -> r.split(constant("a,b")).throwException(new IllegalArgumentException("x")).end();
        case "plain" -> r.throwException(new IllegalArgumentException("x"));
      }
      r.to("mock:after");
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    int dead = c.getEndpoint("mock:dead", MockEndpoint.class).getReceivedCounter();
    int oe = c.getEndpoint("mock:oe", MockEndpoint.class).getReceivedCounter();
    System.out.printf("%-44s oe=%d dead=%d exc=%s%n", name, oe, dead, x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (String s : new String[] {"plain", "pipeline", "filter", "split", "lb", "lb-pipeline"})
      for (boolean nfe : new boolean[] {false, true})
        for (int n : new int[] {0, 2})
          for (boolean o : new boolean[] {false, true})
            run(s + (nfe ? " +nfe" : "") + " n=" + n + (o ? " orig" : ""), nfe, n, o, s);
  }
}
