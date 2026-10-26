import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
/** onCompletion useOriginalMessage ("Will use the original input message when an Exchange for this on completion",
 *  model onCompletion.useOriginalMessage): which message does the onCompletion see after various EIPs? */
public class OcOriginalProbe {
  static void run(String name, String shape, boolean before) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      RouteDefinition r = from("direct:a");
      OnCompletionDefinition o = r.onCompletion().useOriginalMessage();
      if (before) o.modeBeforeConsumer();
      o.to("mock:oc").end();
      r.setBody(constant("changed")).setHeader("h", constant("changed"));
      switch (shape) {
        case "plain" -> {}
        case "multicast" -> r.multicast().to("mock:m1").to("mock:m2").end();
        case "split" -> r.split(constant("p,q")).to("mock:m1").end();
        case "recipientList" -> r.recipientList(constant("mock:m1,mock:m2"));
        case "loop-copy" -> r.loop(2).copy().to("mock:m1").end();
        case "loop" -> r.loop(2).to("mock:m1").end();
        case "doTry" -> r.doTry().to("mock:m1").doFinally().to("mock:m2").end();
        case "direct" -> r.to("direct:b");
        case "enrich-like-wiretap" -> r.wireTap("mock:m1");
      }
    }});
    c.addRoutes(new RouteBuilder() { public void configure() { from("direct:b").setHeader("hb", constant("b")); }});
    c.start();
    c.createProducerTemplate().send("direct:a", e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
    Thread.sleep(100);
    MockEndpoint d = c.getEndpoint("mock:oc", MockEndpoint.class);
    String got = d.getExchanges().isEmpty() ? "(none)" : d.getExchanges().get(0).getMessage().getBody() + " / h=" + d.getExchanges().get(0).getMessage().getHeader("h");
    System.out.printf("%-8s %-20s oc sees: %s%n", before ? "before" : "after", shape, got);
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean b : new boolean[] {false, true})
      for (String s : new String[] {"plain", "multicast", "split", "recipientList", "loop-copy", "loop", "doTry", "direct", "enrich-like-wiretap"}) run(s, s, b);
  }
}
