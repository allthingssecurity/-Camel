import org.apache.camel.*;
import org.apache.camel.builder.AggregationStrategies;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.util.concurrent.SynchronousExecutorService;
import java.util.*;
public class AggOrderProbe {
  static List<String> trace = Collections.synchronizedList(new ArrayList<>());
  public static void main(String[] a) throws Exception {
    CamelContext c = new DefaultCamelContext();
    c.addRoutes(new RouteBuilder() { public void configure() {
      from("direct:a").aggregate(header("id"), AggregationStrategies.useLatest()).completionSize(1).executorService(new SynchronousExecutorService())
          .process(e -> trace.add("out:" + e.getMessage().getBody())).end()
          .process(e -> trace.add("after1")).to("direct:b").process(e -> trace.add("after2"));
      from("direct:b").process(e -> trace.add("inB"));
      from("direct:s").split(body()).aggregate(header("id"), AggregationStrategies.useLatest()).completionSize(1).executorService(new SynchronousExecutorService())
          .process(e -> trace.add("sout:" + e.getMessage().getBody())).end().process(e -> trace.add("item:" + e.getMessage().getBody())).end()
          .process(e -> trace.add("afterSplit"));
    }});
    c.start();
    ProducerTemplate t = c.createProducerTemplate();
    t.send("direct:a", e -> { e.getMessage().setBody("X"); e.getMessage().setHeader("id", "1"); });
    trace.add("--- send returned");
    t.send("direct:s", e -> { e.getMessage().setBody("p,q"); e.getMessage().setHeader("id", "1"); });
    trace.add("--- send returned");
    System.out.println(String.join("\n", trace));
    c.stop();
  }
}
