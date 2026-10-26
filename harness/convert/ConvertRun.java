import java.io.*;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.util.*;

import org.apache.camel.*;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.support.DefaultExchange;

/**
 * Differential harness for theories/L0/Convert.v: reads the cases printed by oracle/convert/driver
 * (id TAB api TAB type TAB value TAB expected), runs each on real Camel and compares.
 *
 * Pass 1 runs the cases in order on one CamelContext, pass 2 in reverse order on a second one (the registry
 * caches misses, so a result that depends on earlier conversions shows up as ORDER). Expected forms: see
 * oracle/convert/driver.ml. Verdicts: OK / MISMATCH (exact expected), POK / PMISMATCH (set of allowed outcomes),
 * UNS (UNSPECIFIED: Camel's outcome is recorded, not compared).
 *
 * usage: ConvertRun <cases.tsv> <results.tsv>; prints a summary on stdout.
 */
public class ConvertRun {

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

    static Object decode(String t) {
        char k = t.charAt(0);
        String r = t.substring(1);
        switch (k) {
            case 'N': return null;
            case 'S': return unpct(r);
            case 'I': return Integer.valueOf(r);
            case 'L': return Long.valueOf(r);
            case 'D': return Long.parseLong(r) / 4.0;
            case 'B': return r.equals("1");
            case 'A': {   // A<count>.<item>,<item>,... (the count tells [] from [""])
                int dot = r.indexOf('.');
                int n = Integer.parseInt(r.substring(0, dot));
                List<String> l = new ArrayList<>();
                if (n > 0) for (String x : r.substring(dot + 1).split(",", -1)) l.add(unpct(x));
                if (l.size() != n) throw new IllegalArgumentException("list count " + r);
                return l;
            }
            default: throw new IllegalArgumentException("value " + t);
        }
    }

    static Class<?> type(String n) throws ClassNotFoundException {
        switch (n) {
            case "int": return int.class;
            case "long": return long.class;
            case "double": return double.class;
            case "boolean": return boolean.class;
            default: return Class.forName(n);
        }
    }

    static Class<?> wrapper(Class<?> c) {
        if (c == int.class) return Integer.class;
        if (c == long.class) return Long.class;
        if (c == double.class) return Double.class;
        if (c == boolean.class) return Boolean.class;
        return c;
    }

    /** Canonical text of a returned value. */
    static String got(Object r) {
        if (r == null) return "NULL";
        if (r instanceof String s) return "VS" + pct(s);
        if (r instanceof Integer i) return "VI" + i;
        if (r instanceof Long l) return "VL" + l;
        if (r instanceof Double d) {
            boolean negZero = d == 0.0 && 1 / d < 0;
            if (!negZero && !d.isNaN() && !d.isInfinite()) {
                BigDecimal q = new BigDecimal(d).multiply(BigDecimal.valueOf(4));
                if (q.stripTrailingZeros().scale() <= 0) return "VD" + q.toBigIntegerExact();
            }
            return "Ojava.lang.Double:" + pct(d.toString());
        }
        if (r instanceof Boolean b) return b ? "VB1" : "VB0";
        if (r instanceof BigDecimal bd) return "Z" + bd.unscaledValue() + ":" + bd.scale();
        if (r instanceof List<?> l && l.stream().allMatch(x -> x instanceof String)) {
            StringBuilder b = new StringBuilder("VA" + l.size() + ".");
            for (int i = 0; i < l.size(); i++) { if (i > 0) b.append(','); b.append(pct((String) l.get(i))); }
            return b.toString();
        }
        String s = String.valueOf(r);
        if (s.length() > 80) s = s.substring(0, 80);
        return "O" + r.getClass().getName() + ":" + pct(s);
    }

    record Outcome(Object value, Throwable exc) {
        String text() {
            if (exc != null) {
                String m = String.valueOf(exc.getMessage());
                if (m.length() > 100) m = m.substring(0, 100);
                return "X" + exc.getClass().getName() + ":" + pct(m);
            }
            return got(value);
        }
    }

    static Outcome exec(CamelContext ctx, String api, Class<?> t, Object v) {
        TypeConverter tc = ctx.getTypeConverter();
        try {
            Object r;
            switch (api) {
                case "convertTo": r = tc.convertTo(t, v); break;
                case "mandatoryConvertTo": r = tc.mandatoryConvertTo(t, v); break;
                case "tryConvertTo": r = tc.tryConvertTo(t, v); break;
                case "getBody": {
                    Exchange ex = new DefaultExchange(ctx);
                    ex.getIn().setBody(v);
                    r = ex.getIn().getBody(t);
                    break;
                }
                case "getMandatoryBody": {
                    Exchange ex = new DefaultExchange(ctx);
                    ex.getIn().setBody(v);
                    r = ex.getIn().getMandatoryBody(t);
                    break;
                }
                case "getHeader": {
                    Exchange ex = new DefaultExchange(ctx);
                    if (v != null) ex.getIn().setHeader("h", v);
                    r = ex.getIn().getHeader("h", t);
                    break;
                }
                case "getProperty": {
                    Exchange ex = new DefaultExchange(ctx);
                    if (v != null) ex.setProperty("p", v);
                    r = ex.getProperty("p", t);
                    break;
                }
                default: throw new IllegalArgumentException(api);
            }
            return new Outcome(r, null);
        } catch (Throwable e) {
            return new Outcome(null, e);
        }
    }

    static boolean matchOne(String alt, Outcome o, Class<?> t) throws ClassNotFoundException {
        if (alt.equals("ANYV")) return o.exc == null && o.value != null && wrapper(t).isInstance(o.value);
        if (alt.equals("NULL")) return o.exc == null && o.value == null;
        if (alt.startsWith("X")) return o.exc != null && Class.forName(alt.substring(1)).isInstance(o.exc);
        if (alt.startsWith("Z")) {
            if (o.exc != null || !(o.value instanceof BigDecimal bd)) return false;
            String[] p = alt.substring(1).split(":");
            BigDecimal e = new BigDecimal(new BigInteger(p[0]), Integer.parseInt(p[1]));
            return e.compareTo(bd) == 0;
        }
        if (alt.startsWith("V")) return o.exc == null && got(o.value).equals(alt);
        throw new IllegalArgumentException("alt " + alt);
    }

    public static void main(String[] a) throws Exception {
        List<String[]> cases = new ArrayList<>();
        try (BufferedReader r = new BufferedReader(new FileReader(a[0]))) {
            for (String l; (l = r.readLine()) != null; ) if (!l.isBlank()) cases.add(l.split("\t", -1));
        }
        CamelContext c1 = new DefaultCamelContext();
        c1.start();
        CamelContext c2 = new DefaultCamelContext();
        c2.start();
        Outcome[] o1 = new Outcome[cases.size()], o2 = new Outcome[cases.size()];
        for (int i = 0; i < cases.size(); i++) {
            String[] f = cases.get(i);
            o1[i] = exec(c1, f[1], type(f[2]), decode(f[3]));
        }
        for (int i = cases.size() - 1; i >= 0; i--) {
            String[] f = cases.get(i);
            o2[i] = exec(c2, f[1], type(f[2]), decode(f[3]));
        }
        Map<String, Integer> count = new TreeMap<>();
        Map<String, Map<String, Integer>> uns = new TreeMap<>();
        try (PrintWriter w = new PrintWriter(new FileWriter(a[1]))) {
            for (int i = 0; i < cases.size(); i++) {
                String[] f = cases.get(i);
                Class<?> t = type(f[2]);
                String exp = f[4];
                Outcome o = o1[i];
                String gt = o.text();
                String verdict;
                if (exp.startsWith("U")) verdict = "UNS";
                else if (exp.startsWith("P")) {
                    String[] alts = exp.split("\\|");
                    boolean ok = false;
                    for (int j = 1; j < alts.length; j++) ok |= matchOne(alts[j], o, t);
                    verdict = ok ? "POK" : "PMISMATCH";
                } else verdict = matchOne(exp, o, t) ? "OK" : "MISMATCH";
                if (!o1[i].text().equals(o2[i].text())) verdict += "+ORDER";
                count.merge(verdict, 1, Integer::sum);
                String why = exp.startsWith("U") ? exp.substring(1)
                        : exp.startsWith("P") ? exp.substring(1, exp.indexOf('|')) : "";
                if (!why.isEmpty()) {
                    String gk = gt.startsWith("X") ? gt.substring(0, gt.indexOf(':')) : gt.startsWith("V") ? gt.substring(0, 2) + "*" : gt;
                    if (gk.startsWith("O")) gk = gk.substring(0, gk.indexOf(':'));
                    uns.computeIfAbsent(unpct(why), k -> new TreeMap<>()).merge(gk, 1, Integer::sum);
                }
                w.println(String.join("\t", f[0], f[1], f[2], f[3], exp, gt, verdict,
                        o2[i].text().equals(gt) ? "" : "rev=" + o2[i].text()));
            }
        }
        System.out.println("camel " + c1.getVersion() + "  cases " + cases.size());
        count.forEach((k, v) -> System.out.println("  " + k + " " + v));
        System.out.println("Outcomes by UNSPECIFIED / partial reason:");
        uns.forEach((k, m) -> System.out.println("  " + k + " -> " + m));
        c1.stop();
        c2.stop();
    }
}
