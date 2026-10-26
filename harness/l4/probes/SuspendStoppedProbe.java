import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.spi.RouteController;
import org.apache.camel.impl.DefaultCamelContext;

/** Probe: suspendRoute of a stopped (or never started) route, then resumeRoute: the status and whether the route
 *  consumes. usage: SuspendStoppedProbe [noauto] */
public class SuspendStoppedProbe {
    static String send(CamelContext c) {
        Exchange x = c.createProducerTemplate().send("direct:a?block=false", e -> e.getMessage().setBody("x"));
        return x.getException() == null ? "routed" : x.getException().getClass().getSimpleName();
    }
    public static void main(String[] a) throws Exception {
        boolean noauto = a.length > 0;
        DefaultCamelContext c = new DefaultCamelContext();
        c.disableJMX();
        c.addRoutes(new RouteBuilder() { public void configure() {
            from("direct:a").routeId("A").autoStartup(!noauto).to("mock:a"); } });
        c.start();
        RouteController rc = c.getRouteController();
        if (!noauto) { rc.stopRoute("A"); System.out.println("stopRoute    -> " + rc.getRouteStatus("A") + ", message " + send(c)); }
        else System.out.println("not started  -> " + rc.getRouteStatus("A") + ", message " + send(c));
        rc.suspendRoute("A"); System.out.println("suspendRoute -> " + rc.getRouteStatus("A") + ", message " + send(c));
        rc.resumeRoute("A");  System.out.println("resumeRoute  -> " + rc.getRouteStatus("A") + ", message " + send(c));
        rc.startRoute("A");   System.out.println("startRoute   -> " + rc.getRouteStatus("A") + ", message " + send(c));
        rc.stopRoute("A");    System.out.println("stopRoute    -> " + rc.getRouteStatus("A") + ", message " + send(c));
        rc.startRoute("A");   System.out.println("startRoute   -> " + rc.getRouteStatus("A") + ", message " + send(c));
        c.stop();
    }
}
