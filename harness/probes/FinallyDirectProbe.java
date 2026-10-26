import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
/** doTry-eip.adoc 227-229: an exception thrown in doFinally while one from doTry is pending: the original is kept. */
public class FinallyDirectProbe {
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      from("direct:inline").doTry().throwException(new java.io.IOException("orig")).doFinally()
          .throwException(new IllegalArgumentException("fin")).end();
      from("direct:viaDirect").doTry().throwException(new java.io.IOException("orig")).doFinally()
          .to("direct:fail").end();
      from("direct:fail").throwException(new IllegalArgumentException("fin"));
      from("direct:viaDirectDoTry").doTry().throwException(new java.io.IOException("orig")).doFinally()
          .to("direct:failTry").end();
      from("direct:failTry").doTry().throwException(new IllegalArgumentException("fin")).doCatch(java.io.IOException.class).to("mock:x").end();
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (String ep : new String[] {"inline", "viaDirect", "viaDirectDoTry"}) {
      Exchange x = t.send("direct:" + ep, e -> e.getMessage().setBody("in"));
      Exception ex = x.getException();
      System.out.println(ep + ": exception=" + ex + (ex != null && ex.getSuppressed().length > 0 ? " suppressed=" + ex.getSuppressed()[0] : ""));
    }
    c.stop();
  }
}
