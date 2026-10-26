import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.support.processor.idempotent.MemoryIdempotentRepository;
public class IdemHandledProbe {
  static int entered;
  public static void main(String[] a) throws Exception {
    for (String mode : new String[] {"handled", "notHandled", "noFailure"}) {
      entered = 0;
      CamelContext c = new DefaultCamelContext();
      c.addRoutes(new RouteBuilder() { public void configure() {
        if (!mode.equals("noFailure")) onException(IllegalStateException.class).handled(mode.equals("handled"));
        var r = from("direct:a").idempotentConsumer(header("id"), MemoryIdempotentRepository.memoryIdempotentRepository(100))
          .process(e -> entered++);
        if (!mode.equals("noFailure")) r.throwException(new IllegalStateException("x"));
      }});
      c.start();
      ProducerTemplate t = c.createProducerTemplate();
      Exchange x1 = t.send("direct:a", e -> e.getMessage().setHeader("id", "1"));
      Exchange x2 = t.send("direct:a", e -> e.getMessage().setHeader("id", "1"));
      System.out.println(mode + ": entered the block " + entered + " times; first exchange failed=" + (x1.getException() != null));
      c.stop();
    }
  }
}
