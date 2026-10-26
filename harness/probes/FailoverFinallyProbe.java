import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** Failover monitoring IllegalArgumentException only; the attempt fails with IOException (kept by doFinally), while an
 *  IllegalArgumentException was thrown in its doFinally (suppressed). The IOException is not monitored: no failover,
 *  the exchange fails with it (failoverLoadBalancer-eip.adoc 225-228, doTry-eip.adoc 227-229). */
public class FailoverFinallyProbe {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      from("direct:a").loadBalance().failover(IllegalArgumentException.class)
          .doTry().throwException(new java.io.IOException("orig")).doFinally().to("direct:fail").end()
          .to("mock:second").end().to("mock:after");
      from("direct:fail").throwException(new IllegalArgumentException("fin"));
      from("direct:b").loadBalance().failover(IllegalArgumentException.class)
          .doTry().throwException(new java.io.IOException("orig")).doFinally().throwException(new IllegalArgumentException("fin")).end()
          .to("mock:second").end().to("mock:after");
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (String ep : new String[] {"a", "b"}) {
      c.getEndpoint("mock:second", MockEndpoint.class).reset(); c.getEndpoint("mock:after", MockEndpoint.class).reset();
      Exchange x = t.send("direct:" + ep, e -> e.getMessage().setBody("in"));
      System.out.println(ep + ": exception=" + x.getException() + " failedOverTo second=" + c.getEndpoint("mock:second", MockEndpoint.class).getReceivedCounter()
          + " after=" + c.getEndpoint("mock:after", MockEndpoint.class).getReceivedCounter());
    }
    c.stop();
  }
}
