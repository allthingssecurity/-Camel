import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** doFinally after a doTry body whose direct: call came back handled by the called route's error handler
 *  (dead letter channel, or onException(...).handled(true)): do all doFinally steps run (doFinally-eip / model
 *  doFinally: "steps to always execute after a doTry block completes, regardless of whether an exception was thrown
 *  or caught")? */
public class FinallyFirstStepProbe {
  static void run(String name, String eh, boolean fail) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (eh.equals("dlc")) errorHandler(deadLetterChannel("mock:dead").redeliveryDelay(0));
      if (eh.equals("handled")) onException(IllegalArgumentException.class).handled(true).to("mock:dead");
      from("direct:a")
        .doTry().to("direct:b")
        .doFinally().to("mock:f1").to("mock:f2").setHeader("f3", constant("yes")).to("mock:f4").end()
        .to("mock:end");
      var b = from("direct:b").setBody(constant("in-b"));
      if (fail) b.throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    Exchange x = c.createProducerTemplate().send("direct:a", e -> e.getMessage().setBody("in"));
    StringBuilder s = new StringBuilder();
    for (String m : new String[] {"dead", "f1", "f2", "f4", "end"}) s.append(m).append('=').append(c.getEndpoint("mock:" + m, MockEndpoint.class).getReceivedCounter()).append(' ');
    System.out.printf("%-28s %s f3header=%s exc=%s%n", name, s, x.getMessage().getHeader("f3"), x.getException() == null ? "-" : x.getException().getClass().getSimpleName());
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    run("no failure", "dlc", false);
    run("dlc, called route fails", "dlc", true);
    run("handled, called route fails", "handled", true);
  }
}
