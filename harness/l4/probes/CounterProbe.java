import java.lang.reflect.Field;
import java.util.*;
import org.apache.camel.*;
import org.apache.camel.builder.RouteBuilder;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.impl.engine.AbstractCamelContext;
import org.apache.camel.spi.RouteStartupOrder;

/** Probe (reads Camel internals by reflection, for the Real-mode model only): the auto startupOrder counter and the
 *  RouteStartupOrder list after each operation. */
public class CounterProbe {
    static Object mgr;
    static int counter() throws Exception {
        Field f = mgr.getClass().getDeclaredField("defaultRouteStartupOrder"); f.setAccessible(true); return f.getInt(mgr);
    }
    static void show(CamelContext c, String what) throws Exception {
        StringBuilder b = new StringBuilder(String.format("%-16s next=%d list:", what, counter()));
        for (RouteStartupOrder o : c.getCamelContextExtension().getRouteStartupOrder())
            b.append(' ').append(o.getRoute().getRouteId()).append('=').append(o.getStartupOrder());
        System.out.println(b);
    }
    interface Op { void run(DefaultCamelContext c) throws Exception; }
    public static void main(String[] a) throws Exception {
        boolean ctxAuto = a.length == 0 || !a[0].equals("noauto");
        DefaultCamelContext c = new DefaultCamelContext();
        c.disableJMX();
        c.setAutoStartup(ctxAuto);
        Field mf = AbstractCamelContext.class.getDeclaredField("internalRouteStartupManager"); mf.setAccessible(true);
        mgr = mf.get(c);
        c.addRoutes(new RouteBuilder() { public void configure() {
            from("direct:a").routeId("A").to("mock:a");
            from("direct:b").routeId("B").to("mock:b");
            from("direct:n").routeId("N").autoStartup(false).to("mock:n");
            from("direct:x").routeId("X").startupOrder(5).to("mock:x");
        }});
        show(c, "added");
        LinkedHashMap<String, Op> ops = new LinkedHashMap<>();
        ops.put("start", x -> x.start());
        ops.put("suspendRoute A", x -> x.getRouteController().suspendRoute("A"));
        ops.put("resumeRoute A", x -> x.getRouteController().resumeRoute("A"));
        ops.put("ctx suspend", x -> x.suspend());
        ops.put("ctx resume", x -> x.resume());
        ops.put("startRoute N", x -> x.getRouteController().startRoute("N"));
        ops.put("stopRoute A", x -> x.getRouteController().stopRoute("A"));
        ops.put("startRoute A", x -> x.getRouteController().startRoute("A"));
        ops.put("stopRoute B", x -> x.getRouteController().stopRoute("B"));
        ops.put("startAll", x -> x.getRouteController().startAllRoutes());
        ops.put("stopAll", x -> x.getRouteController().stopAllRoutes());
        ops.put("startAll2", x -> x.getRouteController().startAllRoutes());
        ops.put("stopRoute X", x -> x.getRouteController().stopRoute("X"));
        ops.put("remove X", x -> x.removeRoute("X"));
        ops.put("stop", x -> x.stop());
        for (Map.Entry<String, Op> e : ops.entrySet()) {
            try { e.getValue().run(c); show(c, e.getKey()); }
            catch (Exception ex) { System.out.println(e.getKey() + ": " + ex); }
        }
    }
}
