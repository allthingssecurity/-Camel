import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import static org.apache.camel.builder.Builder.constant;
/** onCompletion useOriginalMessage ("Will use the original input message when an Exchange for this on completion",
 *  model onCompletion.useOriginalMessage) in BeforeConsumer mode (oncompletion.adoc 418-421), InOnly vs InOut. */
public class OcBeforeOriginalProbe {
  static void run(boolean before, ExchangePattern mep, boolean transform) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      RouteDefinition r = from("direct:a");
      OnCompletionDefinition o = r.onCompletion().useOriginalMessage();
      if (before) o.modeBeforeConsumer();
      o.to("mock:oc").end();
      if (transform) r.transform(constant("changed")).setHeader("h", constant("changed"));
      else r.setBody(constant("changed")).setHeader("h", constant("changed"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", mep, e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
    MockEndpoint d = c.getEndpoint("mock:oc", MockEndpoint.class);
    String got = d.getExchanges().isEmpty() ? "(none)" : d.getExchanges().get(0).getMessage().getBody() + " / h=" + d.getExchanges().get(0).getMessage().getHeader("h");
    System.out.printf("%-14s %-6s %-9s oc sees: %-26s caller gets: %s / h=%s%n", before ? "BeforeConsumer" : "AfterConsumer", mep, transform ? "transform" : "setBody", got,
        x.getMessage().getBody(), x.getMessage().getHeader("h"));
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean tr : new boolean[] {false, true})
      for (boolean b : new boolean[] {false, true}) for (ExchangePattern m : new ExchangePattern[] {ExchangePattern.InOnly, ExchangePattern.InOut}) run(b, m, tr);
  }
}
