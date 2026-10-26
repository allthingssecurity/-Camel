import org.apache.camel.*;
import org.apache.camel.builder.AggregationStrategies;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.util.concurrent.SynchronousExecutorService;
/** Sends from the main thread through an aggregator (SynchronousExecutorService) whose output has a doTry; a watchdog
 *  reports if a send does not return within 5 s. Variants: completion size 1/2, doTry in output / aggregate in doTry. */
public class AggHangProbe {
  static volatile long started;
  public static void main(String[] a) throws Exception {
    Thread wd = new Thread(() -> { while (true) { try { Thread.sleep(500); } catch (InterruptedException e) { return; }
      if (started > 0 && System.currentTimeMillis() - started > 5000) { System.out.println("HANG in variant " + a[0]);
        Thread.getAllStackTraces().forEach((t, st) -> { if (t.getName().equals("main")) for (StackTraceElement el : st) System.out.println("  " + el); });
        System.exit(2); } } });
    wd.setDaemon(true); wd.start();
    CamelContext c = new DefaultCamelContext();
    String v = a[0];
    c.addRoutes(new RouteBuilder() { public void configure() {
      if (v.equals("outputDoTry")) {
        from("direct:a").aggregate(header("id"), AggregationStrategies.useLatest()).completionSize(1).executorService(new SynchronousExecutorService())
          .doTry().throwException(new IllegalStateException("x")).doCatch(Exception.class).to("mock:c").end().end()
          .to("mock:after");
      } else if (v.equals("aggInDoTry")) {
        from("direct:a").doTry().aggregate(header("id"), AggregationStrategies.useLatest()).completionSize(1).executorService(new SynchronousExecutorService())
          .to("mock:out").end().throwException(new IllegalStateException("y")).endDoTry().doCatch(Exception.class).to("mock:c").end().to("mock:after");
      } else {
        from("direct:a").doTry().throwException(new IllegalArgumentException("y")).doCatch(Exception.class)
          .aggregate(header("id"), AggregationStrategies.useLatest()).completionSize(1).executorService(new SynchronousExecutorService())
          .throwException(new java.io.IOException("x")).end().end().to("mock:after");
      }
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    for (int i = 0; i < 2000; i++) { started = System.currentTimeMillis(); t.send("direct:a", e -> e.getMessage().setHeader("id", "1")); }
    started = 0;
    System.out.println("no hang in variant " + v + " (2000 sends); inflight at end " + c.getInflightRepository().size());
    c.stop();
  }
}
