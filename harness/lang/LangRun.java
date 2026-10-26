import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;

import org.apache.camel.CamelContext;
import org.apache.camel.Exchange;
import org.apache.camel.Expression;
import org.apache.camel.Predicate;
import org.apache.camel.impl.DefaultCamelContext;
import org.apache.camel.model.language.*;
import org.apache.camel.reifier.language.ExpressionReifier;
import org.apache.camel.support.DefaultExchange;
import org.apache.camel.support.builder.ExpressionBuilder;
import org.apache.camel.support.builder.PredicateBuilder;

/**
 * Differential harness for L1/Placeholder.v and L1/Lang.v: reads the oracle's cases (oracle/lang/driver), runs each
 * on real Camel and compares the canonical text of the outcome with the expected one. UNSPECIFIED cases are counted
 * and Camel's outcome is recorded (grouped by reason), never compared.
 *   placeholders: a fresh DefaultCamelContext, override/initial properties on its PropertiesComponent, JVM system
 *                 properties set for the case, then context.resolvePropertyPlaceholders(text).
 *   languages:    the language's model definition (ConstantExpression, HeaderExpression, ..., TokenizerExpression with
 *                 the documented options), reified with ExpressionReifier into an Expression or a Predicate and
 *                 evaluated on a DefaultExchange built from the case.
 * usage: LangRun cases.tsv out-prefix   (writes out-prefix.mism.tsv, out-prefix.unspec.tsv, prints a summary)
 */
public class LangRun {

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

    static Object decVal(String t) {
        switch (t.charAt(0)) {
            case 'N': return null;
            case 'S': return unpct(t.substring(1));
            case 'I': return Integer.valueOf(t.substring(1));
            case 'L': return Long.valueOf(t.substring(1));
            case 'D': return Double.valueOf(Long.parseLong(t.substring(1)) / 4.0);
            case 'B': return t.charAt(1) == '1';
            case 'A': {   // A<count>.<item>,<item>,... (the count tells [] from [""])
                int dot = t.indexOf('.');
                int n = Integer.parseInt(t.substring(1, dot));
                List<String> l = new ArrayList<>();
                if (n > 0) for (String p : t.substring(dot + 1).split(",", -1)) l.add(unpct(p));
                if (l.size() != n) throw new IllegalArgumentException("list count " + t);
                return l;
            }
            default: throw new IllegalArgumentException("bad value " + t);
        }
    }

    static String encVal(Object v) {
        if (v == null) return "N";
        if (v instanceof String s) return "S" + pct(s);
        if (v instanceof Integer i) return "I" + i;
        if (v instanceof Long l) return "L" + l;
        if (v instanceof Double d) {
            double q = d * 4;
            if (q == Math.rint(q) && Math.abs(q) < 1e15) return "D" + (long) q;
            return "J" + "Double:" + pct(d.toString());
        }
        if (v instanceof Boolean b) return b ? "B1" : "B0";
        if (v instanceof Iterator<?> it) {
            List<Object> l = new ArrayList<>();
            it.forEachRemaining(l::add);
            return encList(l);
        }
        if (v instanceof List<?> l) return encList(l);
        return "J" + v.getClass().getSimpleName() + ":" + pct(String.valueOf(v));
    }

    static String encList(List<?> l) {
        StringBuilder b = new StringBuilder("A" + l.size() + ".");
        for (int i = 0; i < l.size(); i++) {
            Object o = l.get(i);
            if (!(o instanceof String)) return "J" + "ListOf" + (o == null ? "null" : o.getClass().getSimpleName()) + ":" + pct(String.valueOf(l));
            if (i > 0) b.append(',');
            b.append(pct((String) o));
        }
        return b.toString();
    }

    static String encExc(Throwable t) {
        StringBuilder b = new StringBuilder("E" + t.getClass().getSimpleName());
        Throwable c = t.getCause();
        int n = 0;
        while (c != null && c != t && n++ < 4) { b.append('/').append(c.getClass().getSimpleName()); t = c; c = c.getCause(); }
        return b.toString();
    }

    static String msgOf(Throwable t) {
        String m = String.valueOf(t.getMessage()).replace('\t', ' ').replace('\n', ' ').replace('\r', ' ');
        return m.length() > 160 ? m.substring(0, 160) : m;
    }

    static Map<String, String> kvs(String enc) {
        Map<String, String> m = new LinkedHashMap<>();
        if (enc.isEmpty()) return m;
        for (String p : enc.split(";")) {
            int i = p.indexOf('=');
            m.put(p.substring(0, i), p.substring(i + 1));
        }
        return m;
    }

    // ---------- placeholders ----------

    static String[] runPh(String penv, String text) throws Exception {
        Map<String, String> m = kvs(penv);
        Properties over = new Properties(), init = new Properties();
        List<String> sys = new ArrayList<>();
        boolean nested = true, fallback = true;
        for (Map.Entry<String, String> e : m.entrySet()) {
            String k = e.getKey();
            if (k.equals("nested")) nested = false;
            else if (k.equals("fallback")) fallback = false;
            else {
                String key = unpct(k.substring(2)), v = unpct(e.getValue());
                switch (k.charAt(0)) {
                    case 'o' -> over.setProperty(key, v);
                    case 'i' -> init.setProperty(key, v);
                    case 's' -> { System.setProperty(key, v); sys.add(key); }
                    default -> throw new IllegalArgumentException(k);
                }
            }
        }
        try (DefaultCamelContext ctx = new DefaultCamelContext()) {
            org.apache.camel.component.properties.PropertiesComponent pc =
                    (org.apache.camel.component.properties.PropertiesComponent) ctx.getPropertiesComponent();
            if (!over.isEmpty()) pc.setOverrideProperties(over);
            if (!init.isEmpty()) pc.setInitialProperties(init);
            pc.setNestedPlaceholder(nested);
            pc.setDefaultFallbackEnabled(fallback);
            ctx.start();
            try {
                String r = ctx.resolvePropertyPlaceholders(unpct(text));
                return new String[] { r == null ? "N" : "S" + pct(r), "" };
            } catch (Throwable t) {
                return new String[] { encExc(t), msgOf(t) };
            }
        } finally {
            for (String k : sys) System.clearProperty(k);
        }
    }

    // ---------- languages ----------

    static ExpressionDefinition model(Map<String, String> o) {
        String lang = o.get("lang");
        String text = o.containsKey("text") ? unpct(o.get("text")) : null;
        ExpressionDefinition d;
        switch (lang) {
            case "constant" -> d = new ConstantExpression(text);
            case "header" -> d = new HeaderExpression(text);
            case "exchangeProperty" -> d = new ExchangePropertyExpression(text);
            case "variable" -> d = new VariableExpression(text);
            case "ref" -> d = new RefExpression(text);
            case "tokenize" -> {
                TokenizerExpression t = new TokenizerExpression();
                t.setToken(unpct(o.get("token")));
                if (o.containsKey("end")) t.setEndToken(unpct(o.get("end")));
                if (o.containsKey("regex")) t.setRegex("true");
                if (o.containsKey("xml")) t.setXml("true");
                if (o.containsKey("incl")) t.setIncludeTokens("true");
                if (o.containsKey("group")) t.setGroup(unpct(o.get("group")));
                if (o.containsKey("gdelim")) t.setGroupDelimiter(unpct(o.get("gdelim")));
                if (o.containsKey("skip")) t.setSkipFirst("true");
                if (o.containsKey("source")) t.setSource(unpct(o.get("source")));
                if (o.containsKey("inherit")) t.setInheritNamespaceTagName(unpct(o.get("inherit")));
                d = t;
            }
            default -> throw new IllegalArgumentException(lang);
        }
        if (o.containsKey("rt")) ((TypedExpressionDefinition) d).setResultTypeName(unpct(o.get("rt")));
        if (o.containsKey("notrim")) d.setTrim("false");
        return d;
    }

    static String[] runLang(boolean pred, String lexp, String lenv) throws Exception {
        Map<String, String> o = kvs(lexp);
        try (DefaultCamelContext ctx = new DefaultCamelContext()) {
            Properties init = new Properties();
            for (Map.Entry<String, String> e : kvs(lenv).entrySet())
                if (e.getKey().startsWith("pp.i.")) init.setProperty(unpct(e.getKey().substring(5)), unpct(e.getValue()));
            if (!init.isEmpty()) ctx.getPropertiesComponent().setInitialProperties(init);
            ctx.start();
            Exchange ex = new DefaultExchange(ctx);
            for (Map.Entry<String, String> e : kvs(lenv).entrySet()) {
                String k = e.getKey(), v = e.getValue();
                if (k.equals("body")) ex.getMessage().setBody(decVal(v));
                else if (k.startsWith("h.")) ex.getMessage().setHeader(unpct(k.substring(2)), decVal(v));
                else if (k.startsWith("p.")) ex.setProperty(unpct(k.substring(2)), decVal(v));
                else if (k.startsWith("v.")) ex.setVariable(unpct(k.substring(2)), decVal(v));
                else if (k.startsWith("g.")) ex.setVariable("global:" + unpct(k.substring(2)), decVal(v));
                else if (k.startsWith("gr.")) {
                    String[] gk = k.substring(3).split("\\.");
                    ex.setVariable("group:" + unpct(gk[0]) + ":" + unpct(gk[1]), decVal(v));
                } else if (k.startsWith("r.")) {
                    String name = unpct(k.substring(2));
                    Object obj = switch (v.charAt(0)) {
                        case 'X' -> ExpressionBuilder.constantExpression(decVal(v.substring(1)));
                        case 'P' -> PredicateBuilder.constant(v.charAt(1) == '1');
                        case 'O' -> decVal(v.substring(1));
                        default -> throw new IllegalArgumentException(v);
                    };
                    ctx.getRegistry().bind(name, obj);
                } else if (k.startsWith("pp.i.")) { /* set before start */ }
                else throw new IllegalArgumentException(k);
            }
            try {
                ExpressionDefinition d = model(o);
                if (pred) {
                    Predicate p = ExpressionReifier.reifier(ctx, d).createPredicate();
                    return new String[] { p.matches(ex) ? "B1" : "B0", "" };
                } else {
                    Expression e = ExpressionReifier.reifier(ctx, d).createExpression();
                    Object r = e.evaluate(ex, Object.class);
                    if (ex.getException() != null) return new String[] { encExc(ex.getException()), msgOf(ex.getException()) };
                    return new String[] { encVal(r), "" };
                }
            } catch (Throwable t) {
                return new String[] { encExc(t), msgOf(t) };
            }
        }
    }

    static boolean agrees(String exp, String act) {
        if (exp.equals(act)) return true;
        if (exp.startsWith("E") && act.startsWith("E")) {
            if (exp.length() == 1) return true;
            String top = act.substring(1).split("/")[0];
            return top.equals(unpct(exp.substring(1)));
        }
        return false;
    }

    static String kind(String act) {
        if (act.startsWith("E")) return act;
        return act.length() > 40 ? act.substring(0, 40) + "..." : act;
    }

    public static void main(String[] a) throws Exception {
        List<String> lines = Files.readAllLines(Path.of(a[0]));
        String envLine = lines.get(0);
        if (!envLine.startsWith("#ENV ")) throw new IllegalStateException("no #ENV line");
        for (Map.Entry<String, String> e : kvs(envLine.substring(5)).entrySet()) {
            String k = unpct(e.getKey()), v = unpct(e.getValue());
            if (!v.equals(System.getenv(k))) throw new IllegalStateException("OS environment " + k + " is not " + v + " (run via run.sh)");
        }
        // per family: agree, mismatch, unspec
        Map<String, int[]> fam = new TreeMap<>();
        // unspec: family|reason|actual-kind -> count, first example
        Map<String, Integer> uns = new TreeMap<>();
        Map<String, String> unsEx = new HashMap<>();
        try (PrintWriter mism = new PrintWriter(a[1] + ".mism.tsv", StandardCharsets.UTF_8)) {
            for (String line : lines.subList(1, lines.size())) {
                String[] f = line.split("\t", -1);
                String id = f[0], mode = f[1], expected = f[4], family = f[5];
                String[] act = mode.equals("PH") ? runPh(f[2], f[3]) : runLang(mode.equals("Q"), f[2], f[3]);
                int[] c = fam.computeIfAbsent(family, k -> new int[3]);
                if (expected.startsWith("U")) {
                    c[2]++;
                    String key = family + "\t" + unpct(expected.substring(1)) + "\t" + kind(act[0]);
                    uns.merge(key, 1, Integer::sum);
                    unsEx.putIfAbsent(key, id + "\t" + f[2] + "\t" + f[3] + "\t" + act[0] + "\t" + act[1]);
                } else if (agrees(expected, act[0])) c[0]++;
                else {
                    c[1]++;
                    mism.println(line + "\t" + act[0] + "\t" + act[1]);
                }
            }
        }
        try (PrintWriter u = new PrintWriter(a[1] + ".unspec.tsv", StandardCharsets.UTF_8)) {
            u.println("# family\treason\tcamel-outcome\tcount\tfirst-example(id penv/lexp text/lenv actual msg)");
            for (Map.Entry<String, Integer> e : uns.entrySet()) u.println(e.getKey() + "\t" + e.getValue() + "\t" + unsEx.get(e.getKey()));
        }
        int[] t = new int[3];
        System.out.println("family\tagree\tmismatch\tunspecified");
        for (Map.Entry<String, int[]> e : fam.entrySet()) {
            int[] c = e.getValue();
            System.out.println(e.getKey() + "\t" + c[0] + "\t" + c[1] + "\t" + c[2]);
            for (int i = 0; i < 3; i++) t[i] += c[i];
        }
        System.out.println("TOTAL\t" + t[0] + "\t" + t[1] + "\t" + t[2]);
    }
}
