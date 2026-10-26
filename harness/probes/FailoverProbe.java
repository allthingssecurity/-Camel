import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
public class FailoverProbe {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      // monitored: IllegalArgumentException only; the first output throws an IOException (not monitored)
      from("direct:plain").loadBalance().failover(IllegalArgumentException.class)
          .throwException(new java.io.IOException("x")).to("mock:second").end().to("mock:after");
      from("direct:dotry").loadBalance().failover(IllegalArgumentException.class)
          .doTry().setBody(constant("changed")).throwException(new java.io.IOException("x")).doFinally().to("mock:fin").end()
          .to("mock:second").end().to("mock:after");
      from("direct:dotryAll").loadBalance().failover()
          .doTry().throwException(new java.io.IOException("x")).doFinally().to("mock:fin").end()
          .to("mock:second").end().to("mock:after");
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (String ep : new String[] {"plain", "dotry", "dotryAll"}) {
      for (String m : new String[] {"second", "after", "fin"}) c.getEndpoint("mock:" + m, org.apache.camel.component.mock.MockEndpoint.class).reset();
      Exchange x = t.send("direct:" + ep, e -> e.getMessage().setBody("in"));
      System.out.println(ep + ": body=" + x.getMessage().getBody() + " exception=" + x.getException()
          + " second=" + c.getEndpoint("mock:second", org.apache.camel.component.mock.MockEndpoint.class).getReceivedCounter()
          + " after=" + c.getEndpoint("mock:after", org.apache.camel.component.mock.MockEndpoint.class).getReceivedCounter());
    }
    c.stop();
  }
}
