import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** A route called by direct: fails and its dead letter channel moves the exchange ("The exchange is then complete,
 *  and from the client point of view, the message is done being processed", dead-letter-channel.adoc 186-188).
 *  Does the caller go on routing that exchange? Plain caller vs caller inside doTry / doCatch / doFinally / filter. */
public class DlcDoTryDirectProbe {
  static void run(String name, String shape, boolean dlc) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (dlc) errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      else onException(IllegalArgumentException.class).handled(true).to("mock:dead");
      var r = from("direct:a");
      switch (shape) {
        case "plain" -> r.to("direct:b").to("mock:after");
        case "filter" -> r.filter(constant(true)).to("direct:b").to("mock:after").end();
        case "doTry" -> r.doTry().to("direct:b").to("mock:after").doFinally().to("mock:fin").end();
        case "doTry-catch" -> r.doTry().to("direct:b").to("mock:after").doCatch(Exception.class).to("mock:catch").endDoTry();
        case "doCatch" -> r.doTry().throwException(new IllegalStateException("s")).doCatch(IllegalStateException.class).to("direct:b").to("mock:after").endDoTry();
        case "doFinally" -> r.doTry().setBody(constant("t")).doFinally().to("direct:b").to("mock:after").end();
      }
      r.to("mock:end");
      from("direct:b").setBody(constant("in-b")).throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    int dead = c.getEndpoint("mock:dead", MockEndpoint.class).getReceivedCounter();
    int after = c.getEndpoint("mock:after", MockEndpoint.class).getReceivedCounter();
    int end = c.getEndpoint("mock:end", MockEndpoint.class).getReceivedCounter();
    int fin = c.getEndpoint("mock:fin", MockEndpoint.class).getReceivedCounter();
    System.out.printf("%-34s dead=%d after=%d fin=%d end=%d body=%s exc=%s%n", name, dead, after, fin, end, x.getMessage().getBody(),
        x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (boolean d : new boolean[] {true, false})
      for (String s : new String[] {"plain", "filter", "doTry", "doTry-catch", "doCatch", "doFinally"})
        run((d ? "DLC " : "onException-handled ") + s, s, d);
  }
}
