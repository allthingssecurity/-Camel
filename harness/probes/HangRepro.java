import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import java.util.concurrent.*;
/** Minimal reproducer: template.send(...) never returns (no Camel thread is working: a lost async callback). */
public class HangRepro {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      onException(IllegalStateException.class).handled(true).maximumRedeliveries(1).redeliveryDelay(0);
      from("direct:r0").routingSlip(constant("mock:m2,direct:r1,direct:r1"));
      from("direct:r1")
          .doTry()
              .doTry()
                  .throwException(new IllegalStateException("y"))
              .doFinally()
                  .to("direct:r2")
              .endDoTry()
          .endDoTry()
          .doFinally()
          .end();
      from("direct:r2").doTry().routingSlip(constant("mock:m1")).endDoTry().doFinally().end();
    }});
    c.start();
    ExecutorService w = Executors.newSingleThreadExecutor();
    Future<Exchange> f = w.submit(() -> c.createProducerTemplate().send("direct:r0", e -> e.getMessage().setBody("y")));
    try { f.get(5, TimeUnit.SECONDS); System.out.println("returned"); }
    catch (TimeoutException te) { System.out.println("HANG: send did not return within 5 s"); }
    System.exit(0);
  }
}
