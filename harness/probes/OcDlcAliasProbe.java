import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import static org.apache.camel.builder.Builder.constant;
/** runs/oc2-dlc-real dlc-503-3848: an AfterConsumer onCompletion (a copy that must not "interfere with the original
 *  route", oncompletion.adoc 37-43) changes the caller's exchange, when both it and the dead letter channel use the
 *  original message. */
public class OcDlcAliasProbe {
  static void run(boolean dlcOrig, boolean ocOrig, boolean fail) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      var d = deadLetterChannel("mock:dead"); if (dlcOrig) d.useOriginalMessage(); errorHandler(d);
      RouteDefinition r = from("direct:a");
      OnCompletionDefinition o = r.onCompletion(); if (ocOrig) o.useOriginalMessage();
      o.setBody(constant("oc-mutated")).setHeader("h", constant("oc")).end();
      r.setBody(constant("changed"));
      if (fail) r.throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("original"));
    MockEndpoint dead = c.getEndpoint("mock:dead", MockEndpoint.class);
    System.out.printf("dlc.useOriginal=%-5s oc.useOriginal=%-5s fails=%-5s caller gets: %-12s h=%-5s dead got: %s%n", dlcOrig, ocOrig, fail,
        x.getMessage().getBody(), x.getMessage().getHeader("h"), dead.getExchanges().isEmpty() ? "-" : dead.getExchanges().get(0).getMessage().getBody());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean f : new boolean[] {true, false}) for (boolean d : new boolean[] {true, false}) for (boolean o : new boolean[] {true, false}) run(d, o, f);
  }
}
