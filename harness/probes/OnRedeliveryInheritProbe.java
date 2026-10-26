import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
/** Does onRedelivery on a clause (no maximumRedeliveries) inherit the error handler's maximumRedeliveries
 *  (exception-redelivery.adoc 21-25)? Dead letter channel with maximumRedeliveries 2. */
public class OnRedeliveryInheritProbe {
  static int[] attempts = {0};
  static void run(String mode, boolean redel, boolean delay, boolean steps) throws Exception {
    int[] calls = {0}; attempts[0] = 0;
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      errorHandler(deadLetterChannel("mock:dead").maximumRedeliveries(2).redeliveryDelay(0));
      var oe = onException(IllegalArgumentException.class);
      if (redel) oe.onRedelivery(e -> calls[0]++);
      if (delay) oe.redeliveryDelay(0);
      if (mode.equals("handled")) oe.handled(true); if (mode.equals("continued")) oe.continued(true);
      if (steps) oe.to("mock:oe");
      from("direct:a").process(e -> { attempts[0]++; throw new IllegalArgumentException("x"); });
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    System.out.printf("%-9s steps=%-5s onRedelivery=%-5s redeliveryDelay=%-5s calls=%d attempts=%d counter=%s%n", mode, steps, redel, delay, calls[0], attempts[0],
        x.getMessage().getHeader(Exchange.REDELIVERY_COUNTER));
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (String m : new String[] {"unset", "handled", "continued"})
      for (boolean s : new boolean[] {true, false}) for (boolean r : new boolean[] {false, true}) for (boolean d : new boolean[] {false, true})
        if (s || r || d || !m.equals("unset")) run(m, r, d, s);
  }
}
