import java.util.*;
import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** What the docs leave open for the dead letter channel: what the caller gets back, which headers and properties the
 *  dead letter message has, the original message across direct: and inside split, and DLC + onException. */
public class DlcProbe {
  static String show(Exchange x) {
    Map<String, Object> ps = new TreeMap<>();
    x.getProperties().forEach((k, v) -> { if (!k.startsWith("Camel")) ps.put(k, v); });
    return "body=" + x.getMessage().getBody() + " headers=" + new TreeMap<>(x.getMessage().getHeaders()) + " props=" + ps
        + " exc=" + (x.getException() == null ? "-" : x.getException().getClass().getSimpleName())
        + " caught=" + (x.getProperty(Exchange.EXCEPTION_CAUGHT) == null ? "-" : x.getProperty(Exchange.EXCEPTION_CAUGHT, Exception.class).getClass().getSimpleName());
  }
  static void run(String name, RouteBuilder rb) throws Exception {
    CamelContext c = new DefaultCamelContext(); c.addRoutes(rb); c.start();
    MockEndpoint dead = c.getEndpoint("mock:dead", MockEndpoint.class);
    MockEndpoint after = c.getEndpoint("mock:after", MockEndpoint.class);
    Exchange x = c.createProducerTemplate().send("direct:a", e -> { e.getMessage().setBody("in"); e.getMessage().setHeader("g", "0"); e.setProperty("p", "0"); });
    System.out.println(name);
    System.out.println("  caller: " + show(x));
    for (Exchange d : dead.getExchanges()) System.out.println("  dead:   " + show(d));
    System.out.println("  after-count=" + after.getReceivedCounter());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (int n : new int[] {0, 1}) for (String uo : new String[] {"none", "msg", "body"}) {
      run("plain n=" + n + " uo=" + uo, new RouteBuilder() { public void configure() {
        var dlc = deadLetterChannel("mock:dead").maximumRedeliveries(n).redeliveryDelay(0);
        if (uo.equals("msg")) dlc.useOriginalMessage(); if (uo.equals("body")) dlc.useOriginalBody();
        errorHandler(dlc);
        from("direct:a").setBody(constant("b1")).setHeader("h", constant("1")).setProperty("q", constant("1"))
          .throwException(new IllegalStateException("x")).to("mock:after"); }});
      run("direct n=" + n + " uo=" + uo, new RouteBuilder() { public void configure() {
        var dlc = deadLetterChannel("mock:dead").maximumRedeliveries(n).redeliveryDelay(0);
        if (uo.equals("msg")) dlc.useOriginalMessage(); if (uo.equals("body")) dlc.useOriginalBody();
        errorHandler(dlc);
        from("direct:a").setBody(constant("b0")).to("direct:b").setBody(constant("caller-after")).to("mock:after");
        from("direct:b").setBody(constant("b1")).setHeader("h", constant("1")).throwException(new IllegalStateException("x")); }});
      run("split n=" + n + " uo=" + uo, new RouteBuilder() { public void configure() {
        var dlc = deadLetterChannel("mock:dead").maximumRedeliveries(n).redeliveryDelay(0);
        if (uo.equals("msg")) dlc.useOriginalMessage(); if (uo.equals("body")) dlc.useOriginalBody();
        errorHandler(dlc);
        from("direct:a").setBody(constant("x,y")).split(body().tokenize(","))
            .setBody(simple("${body}-1")).setHeader("h", constant("1"))
            .filter(simple("${body} == 'x-1'")).throwException(new IllegalStateException("x")).end()
          .end().to("mock:after"); }});
    }
    for (String hd : new String[] {"unset", "true", "false", "continued"}) {
      run("onException " + hd, new RouteBuilder() { public void configure() {
        errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
        var oe = onException(IllegalStateException.class).setHeader("oe", constant("1"));
        if (hd.equals("true")) oe.handled(true); if (hd.equals("false")) oe.handled(false); if (hd.equals("continued")) oe.continued(true);
        from("direct:a").setBody(constant("b1")).throwException(new IllegalStateException("x")).to("mock:after"); }});
    }
    run("onException other class", new RouteBuilder() { public void configure() {
      errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      onException(java.io.IOException.class).handled(true);
      from("direct:a").setBody(constant("b1")).throwException(new IllegalStateException("x")).to("mock:after"); }});
    run("doTry inside", new RouteBuilder() { public void configure() {
      errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      from("direct:a").doTry().throwException(new IllegalStateException("x")).doFinally().setHeader("f", constant("1")).end().to("mock:after"); }});
  }
}
