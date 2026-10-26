import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import static org.apache.camel.builder.Builder.constant;
/** Minimized from runs/oc1-real oc-501-2748: onCompletion(useOriginalMessage) after a doTry whose body changed the
 *  message. Which message does the onCompletion get? (model onCompletion.useOriginalMessage: "Will use the original
 *  input message".) Also the dead letter channel's useOriginalMessage after a change inside a doTry. */
public class OcOriginalDoTryProbe {
  static void run(String name, String where, boolean before, String what) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      RouteDefinition r = from("direct:a");
      OnCompletionDefinition o = r.onCompletion().useOriginalMessage();
      if (before) o.modeBeforeConsumer();
      o.to("mock:oc").end();
      switch (where) {
        case "before-doTry" -> { change(r, what); r.doTry().to("mock:x").doFinally().to("mock:y").end(); }
        case "in-doTry" -> { var t = r.doTry(); change(t, what); t.doFinally().to("mock:y").end(); }
        case "in-doTry-empty-finally" -> { var t = r.doTry(); change(t, what); t.doFinally().end(); }
        case "in-doTry-catch" -> { var t = r.doTry(); change(t, what); t.doCatch(Exception.class).to("mock:y").end(); }
        case "in-doFinally" -> { r.doTry().to("mock:x").doFinally(); change(r, what); r.end(); }
        case "in-filter" -> { var f = r.filter(constant(true)); change(f, what); f.end(); }
      }
    }});
    c.start();
    c.createProducerTemplate().send("direct:a", e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
    MockEndpoint d = c.getEndpoint("mock:oc", MockEndpoint.class);
    String got = d.getExchanges().isEmpty() ? "(none)" : d.getExchanges().get(0).getMessage().getBody() + " / h=" + d.getExchanges().get(0).getMessage().getHeader("h");
    System.out.printf("%-8s %-24s %-8s oc sees: %s%n", before ? "before" : "after", where, what, got);
    c.stop();
  }
  static void change(ProcessorDefinition<?> p, String what) {
    if (what.equals("header")) p.setHeader("h", constant("changed"));
    if (what.equals("body")) p.setBody(constant("changed"));
    if (what.equals("both")) p.setBody(constant("changed")).setHeader("h", constant("changed"));
  }
  public static void main(String[] a) throws Exception {
    for (boolean b : new boolean[] {false, true})
      for (String w : new String[] {"before-doTry", "in-doTry", "in-doTry-empty-finally", "in-doTry-catch", "in-doFinally", "in-filter"})
        for (String what : new String[] {"header", "body"}) run(w, w, b, what);
  }
}
