import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
/** Dead letter channel with useOriginalMessage (dead-letter-channel.adoc 230-333: "If we want to manually retry, we
 *  can move the JMS message from the failed to the input queue, with no problem as the message is the same as the
 *  original we received"), plus a per-exception redelivery override without steps (exception-redelivery.adoc 27-62):
 *  which message reaches the dead letter queue? */
public class DlcOriginalViaClauseProbe {
  static void run(String name, String clause, String uo) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      var dlc = deadLetterChannel("mock:dead").redeliveryDelay(0);
      if (uo.equals("msg")) dlc.useOriginalMessage(); if (uo.equals("body")) dlc.useOriginalBody();
      errorHandler(dlc);
      switch (clause) {
        case "none" -> {}
        case "redelivery" -> onException(IllegalArgumentException.class).maximumRedeliveries(2).redeliveryDelay(0);
        case "redelivery0" -> onException(IllegalArgumentException.class).maximumRedeliveries(0);
        case "other-class" -> onException(java.io.IOException.class).maximumRedeliveries(2).redeliveryDelay(0);
      }
      from("direct:a").setBody(constant("changed")).setHeader("h", constant("changed"))
          .throwException(new IllegalArgumentException("x"));
    }});
    c.start();
    c.createProducerTemplate().send("direct:a", e -> { e.getMessage().setBody("original"); e.getMessage().setHeader("h", "original"); });
    MockEndpoint d = c.getEndpoint("mock:dead", MockEndpoint.class);
    String got = d.getExchanges().isEmpty() ? "(none)" : d.getExchanges().get(0).getMessage().getBody() + " / h=" + d.getExchanges().get(0).getMessage().getHeader("h");
    System.out.printf("%-14s %-12s dead: %s%n", "uo=" + uo, clause, got);
    c.stop();
  }
  public static void main(String[] a) throws Exception {
    for (String uo : new String[] {"msg", "body", "none"})
      for (String cl : new String[] {"none", "other-class", "redelivery", "redelivery0"}) run(uo + cl, cl, uo);
  }
}
