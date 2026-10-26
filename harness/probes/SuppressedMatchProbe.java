import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
/** An IOException carrying a suppressed IllegalArgumentException (from a doFinally). doTry-eip.adoc 211-213 and
 *  exception-clause.adoc 177-178 match "the exception and its causes" only: a clause for IllegalArgumentException
 *  should not match. */
public class SuppressedMatchProbe {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      onException(IllegalArgumentException.class).handled(true).setBody(constant("onException(IAE) matched"));
      from("direct:docatch").doTry()
            .doTry().throwException(new java.io.IOException("orig")).doFinally().throwException(new IllegalArgumentException("fin")).end()
          .endDoTry().doCatch(IllegalArgumentException.class).setBody(constant("doCatch(IAE) matched")).end();
      from("direct:onexception").to("direct:inner");
      from("direct:inner").errorHandler(noErrorHandler())
          .doTry().throwException(new java.io.IOException("orig")).doFinally().throwException(new IllegalArgumentException("fin")).end();
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (String ep : new String[] {"docatch", "onexception"}) {
      Exchange x = t.send("direct:" + ep, e -> e.getMessage().setBody("in"));
      System.out.println(ep + ": body=" + x.getMessage().getBody() + " exception=" + x.getException());
    }
    c.stop();
  }
}
