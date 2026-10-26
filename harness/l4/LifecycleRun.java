import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;

import org.apache.camel.*;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.RouteDefinition;
import org.apache.camel.spi.CamelEvent;
import org.apache.camel.support.EventNotifierSupport;

/**
 * Differential runner for the L4 lifecycle oracle (oracle/l4/driver). Reads cases (id, program, operations, expected
 * for sus=true, expected for sus=false, family), builds the program on a fresh DefaultCamelContext (every route is
 * from("direct:<id>").routeId(id)[.startupOrder(n)].autoStartup(b).process(record)), applies the operations one by
 * one on a worker thread (10 s per operation, a hang is reported as HANG), and after each one prints the result, the
 * route events fired during it (RouteStarted/RouteStopped/RouteRemoved, from an EventNotifier), the context status
 * and every route's status (getRoute(id) == null gives "-"), in the oracle's text. A case agrees when the trace
 * matches one of the two expected traces (the oracle's two values of sus: does the direct consumer support
 * suspension); which one(s) matched is counted. An UNSPECIFIED operation ends the comparison of that alternative;
 * what Camel did there is written to the unspec file.
 * usage: LifecycleRun <cases.tsv> <out-prefix>   (writes <out-prefix>.mism.tsv, <out-prefix>.unspec.tsv)
 * Trust base (notes/l4.md): the case reader, the program building, the event recording, the printer, the comparison.
 */
public class LifecycleRun {
    static ExecutorService WORKER = Executors.newSingleThreadExecutor();
    static final long OP_TIMEOUT_S = Long.getLong("op.seconds", 10);

    static String pct(String s) {
        StringBuilder b = new StringBuilder();
        for (byte x : s.getBytes(StandardCharsets.UTF_8)) {
            int c = x & 0xff;
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) b.append((char) c);
            else b.append(String.format("%%%02X", c));
        }
        return b.toString();
    }

    static String unpct(String s) {
        ByteArrayOutputStream o = new ByteArrayOutputStream();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '%') { o.write(Integer.parseInt(s.substring(i + 1, i + 3), 16)); i += 2; }
            else o.write(c);
        }
        return o.toString(StandardCharsets.UTF_8);
    }

    static final class Rt { String id; Integer order; boolean auto; }

    /** Runs one case; returns the observed token per operation (fewer if an operation hung). */
    static List<String> runCase(String prog, String ops) throws Exception {
        String[] p = prog.split(" ");
        boolean ctxAuto = p[0].equals("A1");
        List<Rt> rts = new ArrayList<>();
        for (int i = 1; i < p.length; i++) {
            String[] f = p[i].split(":");
            Rt r = new Rt();
            r.id = unpct(f[0]);
            r.order = f[1].equals("N") ? null : Integer.valueOf(f[1]);
            r.auto = f[2].equals("1");
            rts.add(r);
        }
        final List<String> events = Collections.synchronizedList(new ArrayList<>());
        final List<String> delivered = Collections.synchronizedList(new ArrayList<>());
        DefaultCamelContext ctx = new DefaultCamelContext();
        ctx.disableJMX();
        ctx.setAutoStartup(ctxAuto);
        // graceful shutdown timeout: 1 s (documented option [GS.20-23]); no exchange is ever in flight at a stop
        ctx.getShutdownStrategy().setTimeout(1);
        ctx.getManagementStrategy().addEventNotifier(new EventNotifierSupport() {
            @Override
            public void notify(CamelEvent e) {
                if (e instanceof CamelEvent.RouteStartedEvent r) events.add("S." + pct(r.getRoute().getRouteId()));
                else if (e instanceof CamelEvent.RouteStoppedEvent r) events.add("T." + pct(r.getRoute().getRouteId()));
                else if (e instanceof CamelEvent.RouteRemovedEvent r) events.add("R." + pct(r.getRoute().getRouteId()));
            }
        });
        List<RouteDefinition> defs = new ArrayList<>();
        for (Rt r : rts) {
            RouteDefinition d = new RouteDefinition("direct:" + r.id);
            d.routeId(r.id);
            if (r.order != null) d.startupOrder(r.order);
            d.autoStartup(r.auto);
            final String id = r.id;
            d.process(x -> delivered.add(id));
            defs.add(d);
        }
        ctx.addRouteDefinitions(defs);
        final ProducerTemplate[] tpl = {null};
        List<String> out = new ArrayList<>();
        boolean hung = false;
        try {
            for (String o : ops.split(" ")) {
                events.clear();
                delivered.clear();
                Future<String> fut = WORKER.submit(() -> {
                    try {
                        return apply(ctx, o, tpl, delivered);
                    } catch (Throwable t) {
                        return "E" + pct(t.getClass().getName());
                    }
                });
                String res;
                try {
                    res = fut.get(OP_TIMEOUT_S, TimeUnit.SECONDS);
                } catch (TimeoutException te) {
                    WORKER.shutdownNow();
                    WORKER = Executors.newSingleThreadExecutor();
                    out.add("HANG");
                    hung = true;
                    break;
                }
                List<String> ev;
                synchronized (events) { ev = new ArrayList<>(events); }
                StringBuilder sts = new StringBuilder();
                for (Rt r : rts) {
                    if (sts.length() > 0) sts.append(',');
                    String v;
                    try {
                        v = ctx.getRoute(r.id) == null ? "-" : String.valueOf(ctx.getRouteController().getRouteStatus(r.id));
                    } catch (Throwable t) { v = "X" + pct(t.getClass().getName()); }
                    sts.append(pct(r.id)).append('=').append(v);
                }
                out.add(res + "/L" + String.join(",", ev) + "/" + ctx.getStatus() + "/" + sts);
            }
        } finally {
            if (!hung) {
                Future<?> f = WORKER.submit(() -> { try { if (tpl[0] != null) tpl[0].stop(); ctx.stop(); } catch (Throwable t) { } });
                try { f.get(OP_TIMEOUT_S, TimeUnit.SECONDS); } catch (TimeoutException te) {
                    System.err.println("STOP-HANG at end of case");
                    WORKER.shutdownNow(); WORKER = Executors.newSingleThreadExecutor();
                }
            }
        }
        return out;
    }

    static String apply(DefaultCamelContext ctx, String o, ProducerTemplate[] tpl, List<String> delivered) throws Exception {
        String[] f = o.split("\\.");
        String id = f.length > 1 ? unpct(f[1]) : null;
        switch (f[0]) {
            case "start": ctx.start(); return "K";
            case "stop": ctx.stop(); return "K";
            case "suspend": ctx.suspend(); return "K";
            case "resume": ctx.resume(); return "K";
            case "startAll": ctx.getRouteController().startAllRoutes(); return "K";
            case "stopAll": ctx.getRouteController().stopAllRoutes(); return "K";
            case "rstart": ctx.getRouteController().startRoute(id); return "K";
            case "rstop": ctx.getRouteController().stopRoute(id); return "K";
            case "rsuspend": ctx.getRouteController().suspendRoute(id); return "K";
            case "rresume": ctx.getRouteController().resumeRoute(id); return "K";
            case "remove": return ctx.removeRoute(id) ? "B1" : "B0";
            case "send": {
                if (tpl[0] == null) tpl[0] = ctx.createProducerTemplate();
                // block=false: fail at once; block=true with a short timeout (documented options [DJ.44-46])
                String uri = "direct:" + id + (f[2].equals("1") ? "?block=true&timeout=100" : "?block=false");
                Exchange x = tpl[0].send(uri, ex -> ex.getMessage().setBody("x"));
                boolean failed = x.getException() != null;
                int n = delivered.size();
                if (!failed && n == 1) return "D1";
                if (failed && n == 0) return "D0";
                return "DX" + n + (failed ? pct(x.getException().getClass().getName()) : "");
            }
            default: throw new IllegalArgumentException(o);
        }
    }

    // ---- comparison ----
    static List<String> evlist(String s) {
        List<String> l = new ArrayList<>();
        if (!s.isEmpty()) l.addAll(Arrays.asList(s.split(",")));
        return l;
    }

    /** Does the observed token match the expected one (expected never starts with "U:")? */
    static boolean same(String exp, String got) {
        if (got.equals("HANG")) return false;
        String[] e = exp.split("/", -1), g = got.split("/", -1);
        if (e.length != 4 || g.length != 4) return false;
        if (!e[0].equals(g[0])) return false;
        if (!e[1].equals("*")) {
            int hat = e[1].indexOf('^');
            List<String> want = evlist(e[1].substring(1, hat));
            Set<String> ign = new HashSet<>(evlist(e[1].substring(hat + 1)));
            List<String> have = new ArrayList<>();
            for (String x : evlist(g[1].substring(1))) if (!ign.contains(x)) have.add(x);
            if (e[1].charAt(0) == 'G') { Collections.sort(want); Collections.sort(have); }
            if (!want.equals(have)) return false;
        }
        if (!e[2].equals("?") && !e[2].equals(g[2])) return false;
        String[] es = e[3].split(",", -1), gs = g[3].split(",", -1);
        if (es.length != gs.length) return false;
        for (int i = 0; i < es.length; i++) {
            if (es[i].endsWith("=?")) { if (!gs[i].startsWith(es[i].substring(0, es[i].length() - 1))) return false; }
            else if (!es[i].equals(gs[i])) return false;
        }
        return true;
    }

    /** -1: agrees (up to the first UNSPECIFIED op); else the index of the first mismatching op. */
    static int compare(String[] exp, List<String> got, int[] cmp) {
        for (int i = 0; i < exp.length; i++) {
            if (exp[i].startsWith("U:")) return -1;
            cmp[0]++;
            if (i >= got.size() || !same(exp[i], got.get(i))) return i;
        }
        return -1;
    }

    public static void main(String[] a) throws Exception {
        long t0 = System.currentTimeMillis();
        int total = 0, agree = 0, mism = 0, err = 0, unspec = 0, onlyT = 0, onlyF = 0, both = 0, opsCmp = 0, opsRun = 0;
        Map<String, Integer> unspecWhy = new TreeMap<>();
        try (BufferedReader in = Files.newBufferedReader(Path.of(a[0]));
             PrintWriter mw = new PrintWriter(Files.newBufferedWriter(Path.of(a[1] + ".mism.tsv")));
             PrintWriter uw = new PrintWriter(Files.newBufferedWriter(Path.of(a[1] + ".unspec.tsv")))) {
            String line;
            while ((line = in.readLine()) != null) {
                String[] f = line.split("\t", -1);
                total++;
                String[] eT = f[3].split(" "), eF = f[4].split(" ");
                List<String> got;
                long c0 = System.currentTimeMillis();
                try {
                    got = runCase(f[1], f[2]);
                } catch (Exception e) {
                    err++;
                    mw.println(f[0] + "\tSETUP\t" + e.getClass().getName() + ":" + pct(String.valueOf(e.getMessage())) + "\t" + f[1] + "\t" + f[2]);
                    continue;
                }
                long dt = System.currentTimeMillis() - c0;
                if (dt > 3000) System.err.println("SLOW " + dt + "ms " + f[0]);
                opsRun += got.size();
                int[] cT = {0}, cF = {0};
                int mT = compare(eT, got, cT), mF = compare(eF, got, cF);
                boolean okT = mT < 0, okF = mF < 0;
                if (okT || okF) {
                    agree++;
                    opsCmp += Math.max(okT ? cT[0] : 0, okF ? cF[0] : 0);
                    if (okT && okF) both++; else if (okT) onlyT++; else onlyF++;
                    // UNSPECIFIED: recorded (with what Camel did) for the agreeing alternative(s)
                    String[] e = okT ? eT : eF;
                    for (int i = 0; i < e.length; i++)
                        if (e[i].startsWith("U:")) {
                            unspec++;
                            String why = unpct(e[i].substring(2));
                            // at most 50 recorded examples per reason (what Camel did there), to keep run files small
                            if (unspecWhy.merge(why, 1, Integer::sum) <= 50) uw.println(f[0] + "\t" + why + "\t" + (i < got.size() ? got.get(i) : "?") + "\t" + f[1] + "\t" + f[2]
                                       + "\t" + String.join(" ", got));
                        }
                } else {
                    mism++;
                    mw.println(f[0] + "\tT@" + mT + "\t" + (mT < got.size() ? got.get(mT) : "?") + "\t" + eT[mT]
                               + "\tF@" + mF + "\t" + (mF < got.size() ? got.get(mF) : "?") + "\t" + eF[mF]
                               + "\t" + f[1] + "\t" + f[2] + "\t" + String.join(" ", got));
                }
            }
        }
        WORKER.shutdownNow();
        System.out.printf("ALL cases %d ops-run %d ops-compared %d agree %d mismatch %d setup-error %d unspec-cases %d"
                          + " (agree with sus=true only %d, sus=false only %d, both %d) (%.1fs)%n",
                total, opsRun, opsCmp, agree, mism, err, unspec, onlyT, onlyF, both, (System.currentTimeMillis() - t0) / 1000.0);
        unspecWhy.forEach((k, v) -> System.out.println("  U " + v + "\t" + k));
    }
}
