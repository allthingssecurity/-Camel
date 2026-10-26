import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;

/** findings/2026-10-26-docatch-skipped-after-continued-failure-in-called-route.md
 *  A route calls another route (to / routingSlip / dynamicRouter / recipientList) whose failure an onException with
 *  continued(true) deals with. "continued: the exception is ignored and routing continues" -- does the CALLER go on? */
public class ContinuedCalleeProbe {
  public static void main(String[] a) throws Exception {
    for (String eh : new String[] {"continued", "handled"})
      for (String call : new String[] {"none", "to-calleeOk", "to", "routingSlip", "dynamicRouter", "recipientList"})
        for (boolean inTry : new boolean[] {false, true})
          run(eh, call, inTry);
    System.exit(0);
  }
  static void run(String eh, String call, boolean inTry) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (eh.equals("continued")) onException(NumberFormatException.class).continued(true);
      else onException(NumberFormatException.class).handled(true);
      ProcessorDefinition<?> r = from("direct:r2");
      org.apache.camel.model.TryDefinition t = null;
      if (inTry) { t = ((RouteDefinition) r).doTry(); r = t; }
      switch (call) {
        case "none": break;
        case "to-calleeOk": r.to("direct:calleeOk"); break;
        case "to": r.to("direct:callee"); break;
        case "routingSlip": r.routingSlip(constant("direct:callee")); break;
        case "recipientList": r.recipientList(constant("direct:callee")); break;
        default: r.setHeader("dest", constant("direct:callee")); r.dynamicRouter(header("dest")); break;
      }
      r.to("mock:next");
      r.throwException(new IllegalStateException("after the call"));
      if (inTry) t.doCatch(IllegalStateException.class).to("mock:catch").end();
      from("direct:calleeOk").to("mock:calleeEnd");
      from("direct:callee").removeHeader("dest").throwException(new NumberFormatException("in callee")).to("mock:calleeEnd");
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:r2", e -> e.getMessage().setBody("b"));
    System.out.printf("%-9s %-13s doTry=%-5s calleeEnd=%d next=%d catch=%d exception=%s%n", eh, call, inTry, n(c, "calleeEnd"), n(c, "next"), n(c, "catch"),
        x.getException() == null ? "-" : x.getException().getClass().getSimpleName() + ":" + x.getException().getMessage());
    c.stop();
  }
  static int n(CamelContext c, String m) { return c.getEndpoint("mock:" + m, MockEndpoint.class).getReceivedCounter(); }
}
