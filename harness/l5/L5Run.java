import java.io.*;
import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

import org.apache.camel.CamelContext;
import org.apache.camel.Component;
import org.apache.camel.Endpoint;
import org.apache.camel.catalog.DefaultCamelCatalog;
import org.apache.camel.catalog.EndpointValidationResult;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.spi.PropertyConfigurer;
import org.apache.camel.spi.PropertyConfigurerGetter;

/**
 * L5Run: the L5 differential on real Camel at the pin. Reads the oracle's cases (oracle/l5/driver), runs each one, and
 * compares with the expected text.
 *   api ep:     CamelContext.getEndpoint(uri); the endpoint's option values are read back with the component's endpoint
 *               PropertyConfigurer (query options) or the endpoint field of that name (path options).
 *   api v0/v1:  DefaultCamelCatalog.validateEndpointProperties(uri, false/true)
 *   api props:  DefaultCamelCatalog.endpointProperties(uri) (only the keys the spec names are compared)
 *   api asuri:  DefaultCamelCatalog.asEndpointUri(scheme, LinkedHashMap, false)
 *   api name:   DefaultCamelCatalog.endpointComponentName(uri)
 * Cases whose expected result is UNS are not compared; what Camel did is recorded per reason (out.uns).
 * usage: L5Run cases.tsv outPrefix
 */
public class L5Run {
    static String pct(String s) {
        StringBuilder b = new StringBuilder();
        for (byte x : s.getBytes(StandardCharsets.UTF_8)) {
            char c = (char) (x & 0xff);
            if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')) b.append(c);
            else b.append(String.format("%%%02X", x & 0xff));
        }
        return b.toString();
    }
    static String unpct(String s) {
        ByteArrayOutputStream o = new ByteArrayOutputStream();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            if (c == '%') { o.write(Integer.parseInt(s.substring(i + 1, i + 3), 16)); i += 2; } else o.write(c);
        }
        return o.toString(StandardCharsets.UTF_8);
    }
    static String canon(Object v) {
        if (v == null) return "N";
        if (v instanceof String s) return "S" + pct(s);
        if (v instanceof Integer i) return "I" + i;
        if (v instanceof Long l) return "L" + l;
        if (v instanceof Boolean b) return b ? "B1" : "B0";
        if (v instanceof Double d) { double q = d * 4; return q == Math.rint(q) && !Double.isInfinite(q) ? "D" + (long) q : "D?" + pct(d.toString()); }
        if (v instanceof Enum<?> e) return "E" + pct(e.name());
        return "X" + pct(v.getClass().getName());
    }

    static CamelContext ctx;
    static Map<String, Integer> unobs = new TreeMap<>();
    static DefaultCamelCatalog cat;

    static Object field(Object t, String name) throws Exception {
        for (Class<?> k = t.getClass(); k != null; k = k.getSuperclass()) {
            try { Field f = k.getDeclaredField(name); f.setAccessible(true); return f.get(t); } catch (NoSuchFieldException ignore) { }
        }
        throw new NoSuchFieldException(name);
    }
    static Object read(Endpoint e, String name) throws Exception {
        String scheme = e.getEndpointUri().substring(0, e.getEndpointUri().indexOf(':'));
        Component c = ctx.getComponent(scheme);
        PropertyConfigurer pc = c == null ? null : c.getEndpointPropertyConfigurer();
        if (pc instanceof PropertyConfigurerGetter g && g.getOptionType(name, false) != null) return g.getOptionValue(e, name, false);
        Object v = field(e, name);
        if (v == null) {
            // a path option whose field the endpoint does not set (direct keeps the path in `key`): when the syntax has
            // one path name, its value is the path of the endpoint's URI (TRUST.md)
            String syn = cat.componentModel(scheme) == null ? "" : cat.componentModel(scheme).getSyntax();
            String rest = syn.substring(syn.indexOf(':') + 1).replaceFirst("^//", "");
            if (rest.matches("[A-Za-z0-9_]+") && rest.equals(name)) {
                String u = e.getEndpointUri();
                String p = u.substring(u.indexOf(':') + 1).replaceFirst("^//", "");
                int q = p.indexOf('?');
                return q < 0 ? p : p.substring(0, q);
            }
            throw new NoSuchFieldException(name + " (field not set)");
        }
        return v;
    }

    static String exText(Throwable t) {
        StringBuilder b = new StringBuilder(t.getClass().getName());
        Throwable c = t.getCause();
        for (int i = 0; c != null && i < 3; i++, c = c.getCause()) b.append(" <- ").append(c.getClass().getName());
        String m = String.valueOf(t.getMessage());
        return b + " : " + (m.length() > 160 ? m.substring(0, 160) : m).replace('\t', ' ').replace('\n', ' ');
    }

    /** Runs an ep case: returns the comparison verdict ("" = agree) and the actual text. */
    static String[] runEp(String uri, String exp) {
        Endpoint e;
        try { e = ctx.getEndpoint(uri); }
        catch (Throwable t) {
            String act = "FAIL " + t.getClass().getName();
            boolean ok = exp.equals(act) || exp.startsWith("FAILANY");
            return new String[] { ok ? "" : "mismatch", act + " | " + exText(t) };
        }
        try {
            if (e == null) return new String[] { "mismatch", "NULL endpoint" };
            if (!exp.startsWith("OK")) return new String[] { "mismatch", "OK (endpoint " + e.getClass().getSimpleName() + ")" };
            StringBuilder act = new StringBuilder("OK");
            String verdict = "";
            String body = exp.length() > 3 ? exp.substring(3) : "";
            if (!body.isEmpty()) for (String ent : body.split("\\|")) {
                int eq = ent.indexOf('=');
                String name = unpct(ent.substring(0, eq)), want = ent.substring(eq + 1), got;
                try {
                    Object v = read(e, name);
                    if (want.startsWith("P")) {
                        String key = unpct(want.substring(1, want.indexOf(':')));
                        Object x = v instanceof Map<?, ?> m ? m.get(key) : null;
                        got = "P" + pct(key) + ":" + (x == null ? "<none>" : pct(String.valueOf(x)));
                    } else got = canon(v);
                } catch (Throwable t) {
                    // an option the endpoint does not hold (controlbus keeps no command): not observable, not compared
                    unobs.merge(e.getClass().getSimpleName() + "." + name, 1, Integer::sum);
                    continue;
                }
                if (!got.equals(want)) {
                    act.append(' ').append(pct(name)).append(": want ").append(want).append(" got ").append(got).append(';');
                    verdict = got.startsWith("NOREAD") && !verdict.equals("mismatch") ? "setup" : "mismatch";
                }
            }
            return new String[] { verdict, act.toString() };
        } finally {
            try { ctx.removeEndpoint(e); } catch (Throwable ignore) { }
        }
    }

    static String sortedCsv(Collection<String> c) {
        if (c == null) return "";
        List<String> l = new ArrayList<>();
        for (String s : c) l.add(pct(s));
        Collections.sort(l);
        return String.join(",", new LinkedHashSet<>(l));
    }
    static String validate(String uri, boolean ilp) {
        EndpointValidationResult r = cat.validateEndpointProperties(uri, ilp);
        if (r.getUnknownComponent() != null) return "UNKCOMP";
        if (r.getSyntaxError() != null) return "SYNTAX";
        if (r.getIncapable() != null) return "INCAPABLE " + r.getIncapable();
        List<String> inv = new ArrayList<>();
        Object[][] kinds = { { "enum", r.getInvalidEnum() }, { "boolean", r.getInvalidBoolean() }, { "integer", r.getInvalidInteger() },
                             { "number", r.getInvalidNumber() }, { "duration", r.getInvalidDuration() },
                             { "reference", r.getInvalidReference() }, { "map", r.getInvalidMap() }, { "array", r.getInvalidArray() } };
        for (Object[] k : kinds) {
            @SuppressWarnings("unchecked") Map<String, String> m = (Map<String, String>) k[1];
            if (m != null) for (Map.Entry<String, String> x : m.entrySet()) inv.add(k[0] + ":" + pct(x.getKey()) + ":" + pct(String.valueOf(x.getValue())));
        }
        Collections.sort(inv);
        return "REP U=" + sortedCsv(r.getUnknown()) + ";R=" + sortedCsv(r.getRequired()) + ";I=" + String.join(",", inv);
    }
    static String[] runProps(String uri, String exp) {
        Map<String, String> m;
        try { m = cat.endpointProperties(uri); } catch (Throwable t) { return new String[] { "mismatch", "FAIL " + exText(t) }; }
        if (!exp.startsWith("PROPS")) return new String[] { "mismatch", "PROPS " + m };
        String body = exp.length() > 6 ? exp.substring(6) : "";
        StringBuilder act = new StringBuilder("PROPS ");
        String verdict = "";
        Set<String> named = new HashSet<>();
        if (!body.isEmpty()) for (String kv : body.split(",")) {
            int i = kv.indexOf(':');
            String k = unpct(kv.substring(0, i)), want = kv.substring(i + 1);
            named.add(k);
            String got = m.containsKey(k) ? pct(String.valueOf(m.get(k))) : "<absent>";
            if (act.length() > 6) act.append(',');
            act.append(pct(k)).append(':').append(got);
            if (!got.equals(want)) verdict = "mismatch";
        }
        int extra = 0;
        for (String k : m.keySet()) if (!named.contains(k)) extra++;
        act.append(" (+").append(extra).append(" other keys)");
        return new String[] { verdict, act.toString() };
    }

    public static void main(String[] a) throws Exception {
        List<String> lines = Files.readAllLines(Path.of(a[0]));
        String out = a[1];
        ctx = new DefaultCamelContext();
        ctx.getRegistry().bind("myBean", new Object());
        ctx.getRegistry().bind("otherBean", new StringBuilder());
        ctx.start();
        cat = new DefaultCamelCatalog(true);
        int n = 0, cmp = 0, agree = 0, mism = 0, setup = 0, uns = 0;
        Map<String, int[]> perApi = new TreeMap<>();
        Map<String, Map<String, Integer>> unsLog = new TreeMap<>();
        Map<String, String> unsEx = new HashMap<>();
        try (PrintWriter mw = new PrintWriter(out + ".mismatches")) {
            for (String line : lines) {
                String[] f = line.split("\t", -1);
                String id = f[0], api = f[1], exp = f[3], fam = f[4];
                String input = api.equals("asuri") ? f[2] : unpct(f[2]);
                n++;
                String[] r;
                try {
                    switch (api) {
                        case "ep" -> r = runEp(input, exp);
                        case "v0", "v1" -> { String act = validate(input, api.equals("v1")); r = new String[] { act.equals(exp) ? "" : "mismatch", act }; }
                        case "props" -> r = runProps(input, exp);
                        case "asuri" -> {
                            String[] p = input.split("\\|", -1);
                            Map<String, String> m = new LinkedHashMap<>();
                            for (int i = 1; i + 1 < p.length; i += 2) m.put(unpct(p[i]), unpct(p[i + 1]));
                            String act = "URI " + pct(cat.asEndpointUri(unpct(p[0]), m, false));
                            r = new String[] { act.equals(exp) ? "" : "mismatch", act };
                        }
                        case "name" -> { String s = cat.endpointComponentName(input); String act = s == null ? "NULL" : "NAME " + pct(s);
                                         r = new String[] { act.equals(exp) ? "" : "mismatch", act }; }
                        default -> throw new IllegalStateException(api);
                    }
                } catch (Throwable t) { r = new String[] { "mismatch", "FAIL " + exText(t) }; }
                int[] pa = perApi.computeIfAbsent(api, k -> new int[4]);
                if (exp.startsWith("UNS")) {
                    uns++; pa[3]++;
                    String act = r[1].startsWith("OK") ? "OK" : r[1].startsWith("FAIL") ? r[1].split(" ")[0] + " " + r[1].split(" ")[1]
                               : r[1].length() > 80 ? r[1].substring(0, 80) : r[1];
                    unsLog.computeIfAbsent(api + "\t" + exp.substring(4), k -> new TreeMap<>()).merge(act, 1, Integer::sum);
                    unsEx.putIfAbsent(api + "\t" + exp.substring(4) + "\t" + act, input);
                    continue;
                }
                cmp++;
                if (r[0].isEmpty()) { agree++; pa[0]++; }
                else if (r[0].equals("setup")) { setup++; pa[2]++; mw.println(id + "\tSETUP\t" + fam + "\t" + input + "\t" + exp + "\t" + r[1]); }
                else { mism++; pa[1]++; mw.println(id + "\tMISMATCH\t" + fam + "\t" + input + "\t" + exp + "\t" + r[1]); }
            }
        }
        try (PrintWriter uw = new PrintWriter(out + ".uns")) {
            for (var e : unsLog.entrySet()) for (var x : e.getValue().entrySet())
                uw.println(e.getKey() + "\t" + x.getKey() + "\t" + x.getValue() + "\t" + unsEx.get(e.getKey() + "\t" + x.getKey()));
        }
        String sum = "ALL cases " + n + " compared " + cmp + " agree " + agree + " mismatch " + mism + " setup-error " + setup + " unspec " + uns;
        System.out.println(sum);
        try (PrintWriter sw = new PrintWriter(out + ".l5summary")) {
            sw.println(sum);
            sw.println("unobservable (not compared) " + unobs);
            for (var e : perApi.entrySet()) sw.println("api " + e.getKey() + " agree " + e.getValue()[0] + " mismatch " + e.getValue()[1]
                    + " setup-error " + e.getValue()[2] + " unspec " + e.getValue()[3]);
        }
        ctx.stop();
    }
}
