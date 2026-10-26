import java.util.*;
import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import static org.apache.camel.builder.Builder.*;
/** What oncompletion.adoc leaves open: copy or same exchange, BeforeConsumer visibility, order, triggers. */
public class OnCompletionProbe {
  static List<String> log = Collections.synchronizedList(new ArrayList<>());
  static void run(String name, java.util.function.Consumer<RouteDefinition> body, java.util.function.Consumer<RouteDefinition> ocs, String mep) throws Exception {
    log.clear();
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      onException(IllegalStateException.class).handled(true);
      RouteDefinition r = from("direct:a");
      ocs.accept(r);
      body.accept(r);
      from("direct:b").setHeader("inB", constant("1")).to("mock:b");
      from("direct:bf").throwException(new IllegalArgumentException("b"));
    }});
    for (String m : new String[] {"m1", "oc1", "oc2", "b"}) c.getEndpoint("mock:" + m, MockEndpoint.class)
        .whenAnyExchangeReceived(x -> log.add(m + "{" + x.getMessage().getBody() + "," + new TreeMap<>(x.getMessage().getHeaders()) + "}"));
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", "InOut".equals(mep) ? ExchangePattern.InOut : ExchangePattern.InOnly,
        e -> { e.getMessage().setBody("in"); e.getMessage().setHeader("g", "0"); });
    log.add("RET{" + x.getMessage().getBody() + "," + new TreeMap<>(x.getMessage().getHeaders()) + ",exc=" + (x.getException() == null ? "-" : x.getException().getClass().getSimpleName()) + "}");
    Thread.sleep(200);
    System.out.println(name + ": " + log);
    c.stop();
  }
  static java.util.function.Consumer<RouteDefinition> oc(String trig, String mode, boolean orig) {
    return r -> {
      OnCompletionDefinition o = r.onCompletion();
      if (trig.equals("complete")) o.onCompleteOnly(); if (trig.equals("failure")) o.onFailureOnly();
      if (mode.equals("before")) o.modeBeforeConsumer();
      if (orig) o.useOriginalBody();
      o.setHeader("oc", constant("1")).setBody(simple("oc-${body}")).to("mock:oc1").end();
    };
  }
  public static void main(String[] a) throws Exception {
    java.util.function.Consumer<RouteDefinition> plain = r -> r.setBody(constant("b1")).setHeader("h", constant("1")).to("mock:m1");
    java.util.function.Consumer<RouteDefinition> fails = r -> r.setBody(constant("b1")).to("mock:m1").throwException(new IllegalArgumentException("x"));
    java.util.function.Consumer<RouteDefinition> handled = r -> r.setBody(constant("b1")).to("mock:m1").throwException(new IllegalStateException("x"));
    java.util.function.Consumer<RouteDefinition> stops = r -> r.setBody(constant("b1")).to("mock:m1").stop();
    java.util.function.Consumer<RouteDefinition> direct = r -> r.setBody(constant("b1")).to("direct:b").to("mock:m1");
    java.util.function.Consumer<RouteDefinition> split = r -> r.setBody(constant("x,y")).split(body().tokenize(",")).to("mock:m1").end();
    for (String mep : new String[] {"InOut", "InOnly"})
      for (String mode : new String[] {"after", "before"}) {
        run(mep + " " + mode + " always plain", plain, oc("always", mode, false), mep);
        run(mep + " " + mode + " always fails", fails, oc("always", mode, false), mep);
      }
    for (String trig : new String[] {"always", "complete", "failure"}) {
      run("trig=" + trig + " plain", plain, oc(trig, "after", false), "InOut");
      run("trig=" + trig + " fails", fails, oc(trig, "after", false), "InOut");
      run("trig=" + trig + " handled", handled, oc(trig, "after", false), "InOut");
      run("trig=" + trig + " stop", stops, oc(trig, "after", false), "InOut");
    }
    run("useOriginalBody", plain, oc("always", "after", true), "InOut");
    run("direct", direct, oc("always", "after", false), "InOut");
    run("split", split, oc("always", "after", false), "InOut");
    run("two ocs", plain, r -> { r.onCompletion().to("mock:oc1").end(); r.onCompletion().onCompleteOnly().to("mock:oc2").end(); }, "InOut");
    run("oc fails", plain, r -> r.onCompletion().to("mock:oc1").throwException(new IllegalArgumentException("oc")).to("mock:oc2").end(), "InOut");
  }
}
