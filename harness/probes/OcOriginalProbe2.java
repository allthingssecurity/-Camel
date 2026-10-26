import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
/** runs/oc1-real oc-501-2748: onCompletion(useOriginalMessage) sees the current message. Ingredients. */
public class OcOriginalProbe2 {
  static void run(String name, boolean dlc, boolean dlcOrig, String fin, boolean before) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (dlc) { var d = deadLetterChannel("mock:dead"); if (dlcOrig) d.useOriginalMessage(); errorHandler(d); }
      RouteDefinition r = from("direct:a");
      OnCompletionDefinition o = r.onCompletion().useOriginalMessage();
      if (before) o.modeBeforeConsumer();
      o.to("mock:oc").end();
      var t = r.doTry().setHeader("h", constant("changed")).setBody(constant("changed"));
      switch (fin) {
        case "loopcopy-stop" -> t.doFinally().loop(1).copy().stop().end().end();
        case "stop" -> t.doFinally().stop().end();
        case "loopcopy" -> t.doFinally().loop(1).copy().to("mock:x").end().end();
        case "plain" -> t.doFinally().to("mock:x").end();
      }
      r.to("mock:after");
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
    MockEndpoint d = c.getEndpoint("mock:oc", MockEndpoint.class);
    String got = d.getExchanges().isEmpty() ? "(none)" : d.getExchanges().get(0).getMessage().getBody() + " / h=" + d.getExchanges().get(0).getMessage().getHeader("h");
    System.out.printf("%-44s oc sees: %-24s after=%d%n", name, got, c.getEndpoint("mock:after", MockEndpoint.class).getReceivedCounter());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (String f : new String[] {"plain", "stop", "loopcopy", "loopcopy-stop"})
      for (int e = 0; e < 3; e++)
        for (boolean b : new boolean[] {false, true})
          run(f + (e == 0 ? " deh" : e == 1 ? " dlc" : " dlc+orig") + (b ? " before" : " after"), e > 0, e == 2, f, b);
  }
}
