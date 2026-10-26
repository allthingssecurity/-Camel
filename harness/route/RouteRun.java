import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

import org.apache.camel.*;
import org.apache.camel.component.mock.MockEndpoint;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.*;
import org.apache.camel.model.language.SimpleExpression;
import org.apache.camel.spi.BrowsableVariableRepository;
import org.apache.camel.spi.VariableRepository;
import org.apache.camel.spi.VariableRepositoryFactory;

/**
 * Differential runner for the L2 route oracle (oracle/route/driver). Reads cases (id, routes, sends, expected,
 * family), builds the routes with the Camel model API on a fresh DefaultCamelContext, runs the sends with a
 * ProducerTemplate, prints Camel's result in the oracle's canonical text and compares, send by send.
 * An expected "U:why" (UNSPECIFIED) send is counted, never compared; what Camel did is written to the unspec file.
 * usage: RouteRun <cases.tsv> <out-prefix>   (writes <out-prefix>.mism.tsv, <out-prefix>.unspec.tsv)
 * Trust base (TRUST.md): the s-expression reader, the model building, the canonical printer.
 */
public class RouteRun {
    static final int[] LASTINFLIGHT = {0};
    static java.util.concurrent.ExecutorService WORKER = java.util.concurrent.Executors.newSingleThreadExecutor();
    // ---- encoding (CONVENTIONS.md / driver.ml) ----
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

    static Object dec(String v) {
        char k = v.charAt(0);
        String r = v.substring(1);
        switch (k) {
            case 'N': return null;
            case 'S': return unpct(r);
            case 'I': return Integer.valueOf(r);
            case 'L': return Long.valueOf(r);
            case 'D': return Integer.parseInt(r) / 4.0d;
            case 'B': return r.equals("1");
            case 'A': {   // A<count>.<item>,<item>,... (the count tells [] from [""])
                int dot = r.indexOf('.');
                int n = Integer.parseInt(r.substring(0, dot));
                List<String> l = new ArrayList<>();
                if (n > 0) for (String x : r.substring(dot + 1).split(",", -1)) l.add(unpct(x));
                if (l.size() != n) throw new IllegalArgumentException("list count " + r);
                return l;
            }
            default: throw new IllegalArgumentException(v);
        }
    }

    static String canon(Object v) {
        if (v == null) return "N";
        if (v instanceof String s) return "S" + pct(s);
        if (v instanceof Integer i) return "I" + i;
        if (v instanceof Long l) return "L" + l;
        if (v instanceof Double d) {
            double q = d * 4;
            return q == Math.rint(q) && !Double.isInfinite(q) ? "D" + (long) q : "D?" + pct(d.toString());
        }
        if (v instanceof Boolean b) return b ? "B1" : "B0";
        if (v instanceof List<?> l) {
            StringBuilder b = new StringBuilder("A" + l.size() + ".");
            for (int i = 0; i < l.size(); i++) {
                if (i > 0) b.append(',');
                Object x = l.get(i);
                if (!(x instanceof String)) return "X" + pct(v.getClass().getName() + "<" + (x == null ? "null" : x.getClass().getName()) + ">");
                b.append(pct((String) x));
            }
            return b.toString();
        }
        return "X" + pct(v.getClass().getName());
    }

    /** name:value pairs sorted by the lower-cased name (then the name), as driver.ml kvs. */
    static String kvs(Map<String, Object> m, boolean dropCamel) {
        List<Map.Entry<String, Object>> l = new ArrayList<>();
        for (Map.Entry<String, Object> e : m.entrySet()) {
            if (dropCamel && e.getKey().startsWith("Camel")) continue; // internal properties (TRUST.md)
            l.add(e);
        }
        l.sort((a, b) -> {
            int c = a.getKey().toLowerCase(Locale.ROOT).compareTo(b.getKey().toLowerCase(Locale.ROOT));
            return c != 0 ? c : a.getKey().compareTo(b.getKey());
        });
        StringBuilder b = new StringBuilder();
        for (Map.Entry<String, Object> e : l) {
            if (b.length() > 0) b.append(',');
            b.append(pct(e.getKey())).append(':').append(canon(e.getValue()));
        }
        return b.toString();
    }

    static String snap(Exchange x) {
        Exception e = x.getException();
        return "b=" + canon(x.getMessage().getBody()) + ";h=" + kvs(x.getMessage().getHeaders(), false)
               + ";p=" + kvs(x.getProperties(), true) + ";v=" + kvs(x.getVariables(), false)
               + ";e=" + (e == null ? "-" : pct(e.getClass().getName()) + ":" + pct(String.valueOf(e.getMessage())));
    }

    // ---- s-expressions ----
    static final class Sx {
        final String atom; final List<Sx> kids;
        Sx(String a) { atom = a; kids = null; }
        Sx(List<Sx> k) { atom = null; kids = k; }
        String head() { return kids.get(0).atom; }
        String a(int i) { return unpct(kids.get(i).atom); }
    }

    static List<Sx> parseAll(String s) {
        int[] pos = {0};
        List<Sx> out = new ArrayList<>();
        skip(s, pos);
        while (pos[0] < s.length()) { out.add(parse(s, pos)); skip(s, pos); }
        return out;
    }

    static void skip(String s, int[] p) { while (p[0] < s.length() && s.charAt(p[0]) == ' ') p[0]++; }

    static Sx parse(String s, int[] p) {
        skip(s, p);
        if (s.charAt(p[0]) == '(') {
            p[0]++;
            List<Sx> k = new ArrayList<>();
            skip(s, p);
            while (s.charAt(p[0]) != ')') { k.add(parse(s, p)); skip(s, p); }
            p[0]++;
            return new Sx(k);
        }
        int st = p[0];
        while (p[0] < s.length() && s.charAt(p[0]) != ' ' && s.charAt(p[0]) != ')') p[0]++;
        return new Sx(s.substring(st, p[0]));
    }

    // ---- building routes ----
    static org.apache.camel.model.language.ExpressionDefinition expr(Sx e) {
        switch (e.head()) {
            case "simple": return new SimpleExpression(e.a(1));
            case "constant": return new org.apache.camel.model.language.ConstantExpression(e.a(1));
            case "header": return new org.apache.camel.model.language.HeaderExpression(e.a(1));
            case "exchangeProperty": return new org.apache.camel.model.language.ExchangePropertyExpression(e.a(1));
            case "variable": return new org.apache.camel.model.language.VariableExpression(e.a(1));
            default: throw new IllegalArgumentException(e.head());
        }
    }

    static void steps(Block parent, Sx s, int from) {
        for (int i = from; i < s.kids.size(); i++) parent.addOutput(step(s.kids.get(i)));
    }

    static ProcessorDefinition<?> step(Sx s) {
        switch (s.head()) {
            case "setBody": { SetBodyDefinition d = new SetBodyDefinition(); d.setExpression(expr(s.kids.get(1))); return d; }
            case "transform": { TransformDefinition d = new TransformDefinition(); d.setExpression(expr(s.kids.get(1))); return d; }
            case "setHeader": return new SetHeaderDefinition(s.a(1), expr(s.kids.get(2)));
            case "setProperty": return new SetPropertyDefinition(s.a(1), expr(s.kids.get(2)));
            case "setVariable": return new SetVariableDefinition(s.a(1), expr(s.kids.get(2)));
            case "removeHeader": return new RemoveHeaderDefinition(s.a(1));
            case "removeHeaders": {
                String[] ex = new String[s.kids.size() - 2];
                for (int i = 2; i < s.kids.size(); i++) ex[i - 2] = s.a(i);
                return ex.length == 0 ? new RemoveHeadersDefinition(s.a(1)) : new RemoveHeadersDefinition(s.a(1), ex);
            }
            case "removeProperty": return new RemovePropertyDefinition(s.a(1));
            case "removeVariable": return new RemoveVariableDefinition(s.a(1));
            case "filter": { FilterDefinition d = new FilterDefinition(expr(s.kids.get(1))); steps(d, s, 2); return d; }
            case "choice": {
                ChoiceDefinition c = new ChoiceDefinition();
                for (int i = 1; i < s.kids.size(); i++) {
                    Sx b = s.kids.get(i);
                    if (b.head().equals("when")) { WhenDefinition w = new WhenDefinition(expr(b.kids.get(1))); steps(w, b, 2); c.addOutput(w); }
                    else { OtherwiseDefinition o = new OtherwiseDefinition(); steps(o, b, 1); c.addOutput(o); }
                }
                return c;
            }
            case "pipeline": { PipelineDefinition d = new PipelineDefinition(); steps(d, s, 1); return d; }
            case "toDirect": return new ToDefinition("direct:" + s.a(1));
            case "toMock": return new ToDefinition("mock:" + s.a(1));
            case "stop": return new StopDefinition();
            case "throw": { ThrowExceptionDefinition d = new ThrowExceptionDefinition(); d.setExceptionType(s.a(1)); d.setMessage(s.a(2)); return d; }
            case "aggregate": {
                AggregateDefinition d = new AggregateDefinition(expr(s.kids.get(2)));
                AggregationStrategy st = strategy(s.kids.get(3).atom);
                if (st != null) d.aggregationStrategy(st);
                if (!s.kids.get(4).atom.equals("-")) d.completionSize(Integer.parseInt(s.kids.get(4).atom));
                Sx p = s.kids.get(5);
                if (!p.head().equals("none")) d.completionPredicate(expr(p));
                if (s.kids.get(6).atom.equals("1")) d.eagerCheckCompletion();
                if (s.kids.get(7).atom.equals("1")) d.closeCorrelationKeyOnCompletion(0);
                // the aggregated output runs in the caller's thread (aggregate-eip.adoc 46-47; TRUST.md)
                d.executorService(new org.apache.camel.util.concurrent.SynchronousExecutorService());
                steps(d, s, 8);
                return d;
            }
            case "routingSlip": {
                RoutingSlipDefinition<?> d = new RoutingSlipDefinition<>(expr(s.kids.get(1)));
                d.setUriDelimiter(s.a(2));
                return d;
            }
            case "dynamicRouter": {
                DynamicRouterDefinition<?> d = new DynamicRouterDefinition<>(expr(s.kids.get(1)));
                d.setUriDelimiter(s.a(2));
                return d;
            }
            case "convertBodyTo": {
                ConvertBodyDefinition d = new ConvertBodyDefinition(s.a(1));
                d.setMandatory(s.kids.get(2).atom.equals("1") ? "true" : "false");
                return d;
            }
            case "idempotent": {
                IdempotentConsumerDefinition d = new IdempotentConsumerDefinition(expr(s.kids.get(2)),
                        org.apache.camel.support.processor.idempotent.MemoryIdempotentRepository.memoryIdempotentRepository(1000));
                d.setSkipDuplicate(s.kids.get(3).atom.equals("1") ? "true" : "false");
                d.setEager(s.kids.get(4).atom.equals("1") ? "true" : "false");
                steps(d, s, 5);
                return d;
            }
            case "lb": {
                LoadBalanceDefinition d = new LoadBalanceDefinition();
                int from;
                if (s.kids.get(2).atom.equals("roundRobin")) {
                    d.setLoadBalancerType(new org.apache.camel.model.loadbalancer.RoundRobinLoadBalancerDefinition());
                    from = 3;
                } else {
                    org.apache.camel.model.loadbalancer.FailoverLoadBalancerDefinition f = new org.apache.camel.model.loadbalancer.FailoverLoadBalancerDefinition();
                    List<String> ex = new ArrayList<>();
                    for (int j = 1; j < s.kids.get(3).kids.size(); j++) ex.add(s.kids.get(3).a(j));
                    if (!ex.isEmpty()) f.setExceptions(ex);
                    f.setMaximumFailoverAttempts(s.kids.get(4).atom);
                    d.setLoadBalancerType(f);
                    from = 5;
                }
                steps(d, s, from);
                return d;
            }
            case "loop": {
                LoopDefinition d = new LoopDefinition(expr(s.kids.get(1)));
                if (s.kids.get(2).atom.equals("1")) d.setCopy("true");
                if (s.kids.get(3).atom.equals("1")) d.setDoWhile("true");
                steps(d, s, 4);
                return d;
            }
            case "multicast": {
                MulticastDefinition d = new MulticastDefinition();
                AggregationStrategy st = strategy(s.kids.get(1).atom);
                if (st != null) d.aggregationStrategy(st);
                steps(d, s, 2);
                return d;
            }
            case "recipientList": {
                RecipientListDefinition<?> d = new RecipientListDefinition<>(expr(s.kids.get(2)));
                d.setDelimiter(s.a(3));
                AggregationStrategy st = strategy(s.kids.get(1).atom);
                if (st != null) d.aggregationStrategy(st);
                return d;
            }
            case "split": {
                SplitDefinition d = new SplitDefinition(expr(s.kids.get(1)));
                Sx o = s.kids.get(2);
                if (o.kids.get(1).atom.equals("1")) d.setStopOnException("true");
                if (!o.kids.get(2).atom.equals("-")) d.setGroup(o.kids.get(2).atom);
                d.setDelimiter(o.a(3));
                if (!o.kids.get(4).atom.equals("-")) d.setMaxFailedRecords(o.kids.get(4).atom);
                AggregationStrategy st = strategy(o.kids.get(5).atom);
                if (st != null) d.aggregationStrategy(st);
                steps(d, s, 3);
                return d;
            }
            case "doTry": {
                TryDefinition t = new TryDefinition();
                for (int i = 1; i < s.kids.size(); i++) {
                    Sx b = s.kids.get(i);
                    switch (b.head()) {
                        case "body": steps(t, b, 1); break;
                        case "catch": {
                            CatchDefinition c = new CatchDefinition();
                            List<String> ex = new ArrayList<>();
                            for (int j = 1; j < b.kids.get(1).kids.size(); j++) ex.add(b.kids.get(1).a(j));
                            c.setExceptions(ex);
                            Sx w = b.kids.get(2);
                            if (!w.head().equals("none")) c.setOnWhen(new OnWhenDefinition(expr(w)));
                            steps(c, b, 3);
                            t.addOutput(c);
                            break;
                        }
                        case "finally": { FinallyDefinition f = new FinallyDefinition(); steps(f, b, 1); t.addOutput(f); break; }
                        default: throw new IllegalArgumentException("doTry " + b.head());
                    }
                }
                return t;
            }
            default: throw new IllegalArgumentException("step " + s.head());
        }
    }

    /** The built-in strategies of org.apache.camel.builder.AggregationStrategies (a fresh instance each time). */
    static AggregationStrategy strategy(String name) {
        switch (name) {
            case "none": return null;
            case "latest": return org.apache.camel.builder.AggregationStrategies.useLatest();
            case "original": return org.apache.camel.builder.AggregationStrategies.useOriginal();
            case "groupedBody": return org.apache.camel.builder.AggregationStrategies.groupedBody();
            default: throw new IllegalArgumentException("strategy " + name);
        }
    }

    static OnExceptionDefinition onException(Sx k) {
        OnExceptionDefinition o = new OnExceptionDefinition();
        List<String> ex = new ArrayList<>();
        for (int j = 1; j < k.kids.get(1).kids.size(); j++) ex.add(k.kids.get(1).a(j));
        o.setExceptions(ex);
        Sx w = k.kids.get(2);
        if (!w.head().equals("none")) o.setOnWhen(new OnWhenDefinition(expr(w)));
        String h = k.kids.get(3).atom;
        if (!h.equals("-")) o.handled(h.equals("1"));
        if (k.kids.get(4).atom.equals("1")) o.continued(true);
        int n = Integer.parseInt(k.kids.get(5).atom);
        if (n > 0) o.maximumRedeliveries(n).redeliveryDelay(Long.getLong("redelivery.delay", 0));
        steps(o, k, 6);
        return o;
    }

    // ---- one case ----
    static List<String> runCase(String routes, String sends, List<String> events, String[] globals) throws Exception {
        return runCase(routes, sends, events, globals, null, null);
    }

    /** With xml != null (L6, -Ddsl=xml), the routes are loaded from that XML DSL text (rendered by L6/Xml.v) instead
     *  of being built with the model API. */
    static List<String> runCase(String routes, String sends, List<String> events, String[] globals, String xml, String dsl) throws Exception {
        DefaultCamelContext ctx = new DefaultCamelContext();
        ctx.disableJMX();
        ctx.getRegistry().bind("syncExec", new org.apache.camel.util.concurrent.SynchronousExecutorService());
        if (xml != null) {
            org.apache.camel.support.PluginHelper.getRoutesLoader(ctx)
                .loadRoutes(org.apache.camel.support.ResourceHelper.fromString("yaml".equals(dsl) ? "memory:routes.yaml" : "memory:routes.xml", xml));
            return runSends(ctx, sends, events, globals);
        }
        List<RouteDefinition> defs = new ArrayList<>();
        Sx clauses = null;
        for (Sx r : parseAll(routes)) {
            if (r.head().equals("clauses")) { clauses = r; continue; }
            RouteDefinition d = new RouteDefinition("direct:" + r.a(2));
            d.routeId(r.a(1));
            // the program's onException clauses, as route-scoped copies on every route (TRUST.md)
            if (clauses != null) for (int i = 1; i < clauses.kids.size(); i++) d.addOutput(onException(clauses.kids.get(i)));
            steps(d, r, 3);
            defs.add(d);
        }
        ctx.addRouteDefinitions(defs);
        return runSends(ctx, sends, events, globals);
    }

    static List<String> runSends(DefaultCamelContext ctx, String sends, List<String> events, String[] globals) throws Exception {
        ctx.getShutdownStrategy().setTimeout(1);
        ctx.start();
        List<String> out = new ArrayList<>();
        try {
            for (String m : new String[] {"m1", "m2"}) {
                MockEndpoint me = ctx.getEndpoint("mock:" + m, MockEndpoint.class);
                me.whenAnyExchangeReceived(x -> events.add(pct(m) + "=" + snap(x)));
            }
            ProducerTemplate t = ctx.createProducerTemplate();
            for (Sx s : parseAll(sends)) {
                events.clear();
                ExchangePattern p = s.kids.get(2).atom.equals("InOut") ? ExchangePattern.InOut : ExchangePattern.InOnly;
                Object body = dec(s.kids.get(3).atom);
                Map<String, Object> hs = new LinkedHashMap<>();
                for (int i = 4; i < s.kids.size(); i++) hs.put(s.kids.get(i).a(1), dec(s.kids.get(i).kids.get(2).atom));
                // a blocking send (as users call it), on a worker thread so that a hang is detected (10 s)
                java.util.concurrent.Future<Exchange> fut = WORKER.submit(() -> t.send("direct:" + s.a(1), p, ex -> {
                    ex.getMessage().setBody(body); ex.getMessage().getHeaders().putAll(hs); }));
                Exchange x;
                try {
                    x = fut.get(Long.getLong("hang.seconds", 10), java.util.concurrent.TimeUnit.SECONDS);
                } catch (java.util.concurrent.TimeoutException te) {
                    WORKER.shutdownNow();
                    WORKER = java.util.concurrent.Executors.newSingleThreadExecutor();
                    throw new IllegalStateException("HANG: the exchange did not complete within 10 s");
                }
                out.add("[" + String.join("|", events) + "]" + snap(x));
            }
            VariableRepository g = ctx.getCamelContextExtension().getContextPlugin(VariableRepositoryFactory.class)
                    .getVariableRepository("global");
            globals[0] = g instanceof BrowsableVariableRepository b ? kvs(b.getVariables(), false) : "?";
        } finally {
            int inflight = ctx.getInflightRepository().size();
            if (inflight > 0) { System.err.println("INFLIGHT " + inflight + " at stop"); LASTINFLIGHT[0] = inflight; }
            ctx.stop();
        }
        return out;
    }

    /** A raw '?' in the expected text (percent-encoding never produces one) is UNSPECIFIED there: it matches any
     *  run of field characters, e.g. "e=?" (any exception field) or "e=org...CamelExchangeException:?" (any message). */
    static boolean same(String exp, String got) {
        if (exp.indexOf('?') < 0) return exp.equals(got);
        StringBuilder re = new StringBuilder();
        String[] parts = exp.split("\\?", -1);
        for (int i = 0; i < parts.length; i++) {
            if (i > 0) re.append("[^;|\\]\\[ ]*");
            re.append(java.util.regex.Pattern.quote(parts[i]));
        }
        return got.matches(re.toString());
    }

    public static void main(String[] a) throws Exception {
        long t0 = System.currentTimeMillis();
        int total = 0, agree = 0, mism = 0, unspec = 0, err = 0, sendsCmp = 0;
        Map<String, Integer> unspecWhy = new TreeMap<>();
        try (BufferedReader in = Files.newBufferedReader(Path.of(a[0]));
             PrintWriter mw = new PrintWriter(Files.newBufferedWriter(Path.of(a[1] + ".mism.tsv")));
             PrintWriter uw = new PrintWriter(Files.newBufferedWriter(Path.of(a[1] + ".unspec.tsv")))) {
            String line;
            while ((line = in.readLine()) != null) {
                String[] f = line.split("\t", -1);
                total++;
                String[] exp = f[3].split(" ");
                String expG = exp[exp.length - 1];
                List<String> got;
                String[] globals = {""};
                long c0 = System.currentTimeMillis();
                try {
                    String dsl = System.getProperty("dsl");
                    String text = "xml".equals(dsl) && f.length > 5 ? unpct(f[5]) : "yaml".equals(dsl) && f.length > 6 ? unpct(f[6]) : null;
                    got = runCase(f[1], f[2], new ArrayList<>(), globals, text, dsl);
                    long dt = System.currentTimeMillis() - c0;
                    if (dt > 2000) System.err.println("SLOW " + dt + "ms " + f[0]);
                    if (LASTINFLIGHT[0] > 0) { System.err.println("  ^ case " + f[0]); LASTINFLIGHT[0] = 0; }
                } catch (Exception e) {
                    if (exp[0].startsWith("U:")) {   // the rules call the case UNSPECIFIED (e.g. refused at route creation)
                        unspec++;
                        unspecWhy.merge(unpct(exp[0].substring(2)), 1, Integer::sum);
                        uw.println(f[0] + "\t" + exp[0] + "\tSETUP:" + e.getClass().getName() + "\t" + f[1] + "\t" + f[2]);
                        agree++;
                        continue;
                    }
                    err++;
                    mw.println(f[0] + "\tSETUP\t" + e.getClass().getName() + ":" + pct(String.valueOf(e.getMessage())) + "\t" + f[3] + "\t" + f[1] + "\t" + f[2]);
                    continue;
                }
                boolean ok = true, sawU = false;
                for (int i = 0; i < exp.length - 1; i++) {
                    if (exp[i].startsWith("U:")) {
                        sawU = true;
                        unspec++;
                        unspecWhy.merge(unpct(exp[i].substring(2)), 1, Integer::sum);
                        uw.println(f[0] + "\t" + exp[i] + "\t" + (i < got.size() ? got.get(i) : "?") + "\t" + f[1] + "\t" + f[2]);
                        break;
                    }
                    sendsCmp++;
                    if (i >= got.size() || !same(exp[i], got.get(i))) {
                        ok = false;
                        mw.println(f[0] + "\tSEND" + i + "\t" + (i < got.size() ? got.get(i) : "?") + "\t" + exp[i] + "\t" + f[1] + "\t" + f[2]);
                        break;
                    }
                }
                if (ok && !sawU && !expG.equals("G=" + globals[0])) {
                    ok = false;
                    mw.println(f[0] + "\tGLOBAL\tG=" + globals[0] + "\t" + expG + "\t" + f[1] + "\t" + f[2]);
                }
                if (ok) agree++; else mism++;
            }
        }
        WORKER.shutdownNow();
        System.out.printf("ALL cases %d sends-compared %d agree %d mismatch %d setup-error %d unspec-sends %d (%.1fs)%n",
                total, sendsCmp, agree, mism, err, unspec, (System.currentTimeMillis() - t0) / 1000.0);
        unspecWhy.forEach((k, v) -> System.out.println("  U " + v + "\t" + k));
    }
}
