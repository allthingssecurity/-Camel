import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
public class SplitAbortProbe {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      from("direct:max").split(body()).maxFailedRecords(1)
          .setHeader("item", simple("${body}")).setBody(constant("changed")).throwException(new IllegalStateException("boom")).end()
          .to("mock:after");
      from("direct:stop").split(body()).stopOnException()
          .setHeader("item", simple("${body}")).setBody(constant("changed")).throwException(new IllegalStateException("boom")).end()
          .to("mock:after");
      from("direct:max2").split(body()).maxFailedRecords(2)
          .setHeader("item", simple("${body}")).setBody(constant("changed")).throwException(new IllegalStateException("boom")).end()
          .to("mock:after");
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (String ep : new String[] {"direct:max", "direct:max2", "direct:stop"}) {
      Exchange x = t.send(ep, e -> { e.getMessage().setBody("a,b,c"); e.getMessage().setHeader("orig", "yes"); });
      System.out.println(ep + " body=" + x.getMessage().getBody() + " headers=" + x.getMessage().getHeaders()
          + " exception=" + x.getException());
    }
    c.stop();
  }
}
