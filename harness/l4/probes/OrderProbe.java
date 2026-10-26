import java.util.*;
import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.spi.RouteStartupOrder;

/** Probe: the startup order numbers Camel assigns to routes without startupOrder, after each operation. */
public class OrderProbe {
    static void show(CamelContext c, String what) {
        StringBuilder b = new StringBuilder(what + ":");
        for (RouteStartupOrder o : c.getCamelContextExtension().getRouteStartupOrder())
            b.append(' ').append(o.getRoute().getRouteId()).append('=').append(o.getStartupOrder());
        System.out.println(b);
    }
    public static void main(String[] a) throws Exception {
        // 1. a route without startupOrder (A) and one with startupOrder 1001 (B): restart A
        DefaultCamelContext c = new DefaultCamelContext();
        c.disableJMX();
        c.addRoutes(new RouteBuilder() { public void configure() {
            from("direct:a").routeId("A").to("mock:a");
            from("direct:b").routeId("B").startupOrder(1001).to("mock:b");
        }});
        c.start(); show(c, "start");
        c.getRouteController().stopRoute("A"); show(c, "stopRoute A");
        try { c.getRouteController().startRoute("A"); show(c, "startRoute A"); }
        catch (Exception e) { System.out.println("startRoute A: " + e); }
        c.stop();
        // 2. restarting an auto-ordered route many times: its number grows past 10000 ("should be safe" [CFG.195-196])
        c = new DefaultCamelContext();
        c.disableJMX();
        c.addRoutes(new RouteBuilder() { public void configure() {
            from("direct:a").routeId("A").to("mock:a");
            from("direct:z").routeId("Z").startupOrder(10000).to("mock:z");
        }});
        c.start();
        int i = 0;
        try {
            for (i = 0; i < 9100; i++) { c.getRouteController().stopRoute("A"); c.getRouteController().startRoute("A"); }
            System.out.println("9100 restarts ok"); show(c, "after");
        } catch (Exception e) { System.out.println("restart " + (i + 1) + " of A: " + e); }
        c.stop();
        // 3. suspend/resume of a route and of the context: numbers
        c = new DefaultCamelContext();
        c.disableJMX();
        c.addRoutes(new RouteBuilder() { public void configure() {
            from("direct:a").routeId("A").to("mock:a");
            from("direct:b").routeId("B").to("mock:b");
            from("direct:n").routeId("N").autoStartup(false).to("mock:n");
        }});
        c.start(); show(c, "start");
        c.getRouteController().suspendRoute("A"); show(c, "suspendRoute A");
        c.getRouteController().resumeRoute("A"); show(c, "resumeRoute A");
        c.suspend(); show(c, "ctx suspend"); c.resume(); show(c, "ctx resume");
        c.getRouteController().startRoute("N"); show(c, "startRoute N");
        c.stop();
    }
}
