import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
public class EhProbe {
  static void run(String name, RouteBuilder rb) throws Exception {
    CamelContext c = new DefaultCamelContext(); c.addRoutes(rb); c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    System.out.println(name + ": body=" + x.getMessage().getBody() + " headers=" + x.getMessage().getHeaders() + " exc=" + (x.getException() == null ? "-" : x.getException().getClass().getSimpleName()));
    c.stop();
  }
  static int n;
  public static void main(String[] a) throws Exception {
    for (String mode : new String[] {"handled", "notHandled", "continued"}) {
      n = 0;
      run("attempts-" + mode, new RouteBuilder() { public void configure() {
        var oe = onException(IllegalStateException.class).maximumRedeliveries(2).redeliveryDelay(0);
        if (mode.equals("handled")) oe.handled(true); if (mode.equals("continued")) oe.continued(true);
        oe.process(e -> System.out.println("  block sees " + e.getMessage().getHeaders()));
        from("direct:a").process(e -> { n++; throw new IllegalStateException("x"); }); }});
      System.out.println("  attempts=" + n);
    }
  }
}
