import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** Minimized from runs/dlc1-real random-401-1056: which ingredients make Camel move the exchange to the dead letter
 *  queue although onException(Exception).handled(true) matches the failure inside a load balancer? */
public class DlcLbProbe2 {
  static void run(String name, boolean routeScoped, boolean nfeClause, int n, boolean orig, boolean lb, boolean pipe) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      var dlc = deadLetterChannel("mock:dead").maximumRedeliveries(n).redeliveryDelay(0);
      if (orig) dlc.useOriginalMessage();
      errorHandler(dlc);
      if (!routeScoped) {
        if (nfeClause) onException(NumberFormatException.class).continued(true);
        onException(Exception.class).handled(true).to("mock:oe");
      }
      var r = from("direct:a");
      if (routeScoped) {
        if (nfeClause) r.onException(NumberFormatException.class).continued(true).end();
        r.onException(Exception.class).handled(true).to("mock:oe").end();
      }
      if (lb && pipe) r.loadBalance().roundRobin().pipeline().throwException(new IllegalArgumentException("x")).end().end();
      else if (lb) r.loadBalance().roundRobin().throwException(new IllegalArgumentException("x")).end();
      else if (pipe) r.pipeline().throwException(new IllegalArgumentException("x")).end();
      else r.throwException(new IllegalArgumentException("x"));
      r.to("mock:after");
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    int dead = c.getEndpoint("mock:dead", MockEndpoint.class).getReceivedCounter();
    int oe = c.getEndpoint("mock:oe", MockEndpoint.class).getReceivedCounter();
    System.out.printf("%-60s oe=%d dead=%d exc=%s%n", name, oe, dead, x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean rs : new boolean[] {true, false})
      for (boolean nfe : new boolean[] {true, false})
        for (int n : new int[] {0, 2})
          for (boolean orig : new boolean[] {false, true})
            for (boolean lb : new boolean[] {true, false})
              for (boolean pipe : new boolean[] {true, false})
                run((rs ? "route-scoped " : "builder ") + (nfe ? "+nfe-continued " : "") + "n=" + n + (orig ? " orig" : "") + (lb ? " lb" : "") + (pipe ? " pipeline" : ""),
                    rs, nfe, n, orig, lb, pipe);
  }
}
