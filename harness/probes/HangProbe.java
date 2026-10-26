import java.nio.file.*;
import java.util.*;
/** A blocking send that never returns (found by the L2 differential, minimized). Each variant removes one ingredient.
 *  Uses RouteRun's s-expression builder (the model API), one case per variant, 4 s hang timeout. */
public class HangProbe {
  public static void main(String[] a) throws Exception {
    String full = "(clauses (onException (ex java.lang.IllegalStateException) (none) 1 0 1)) "
      + "(route r0 r0 (routingSlip (simple mock:m2,direct:r1,direct:r1) ,)) "
      + "(route r1 r1 (doTry (body (doTry (body (throw java.lang.IllegalStateException y)) (finally (toDirect r2)))) (finally))) "
      + "(route r2 r2 (doTry (body (routingSlip (simple mock:m1) ;)) (finally)))";
    Map<String, String> v = new LinkedHashMap<>();
    v.put("full", full);
    v.put("noRedelivery", full.replace("1 0 1))", "1 0 0))"));
    v.put("notHandled", full.replace("(none) 1 0 1", "(none) - 0 1"));
    v.put("noClauses", full.replace("(clauses (onException (ex java.lang.IllegalStateException) (none) 1 0 1))", "(clauses)"));
    v.put("slipOnce", full.replace("mock:m2,direct:r1,direct:r1", "direct:r1"));
    v.put("toInsteadOfSlip", full.replace("(routingSlip (simple mock:m2,direct:r1,direct:r1) ,)", "(toDirect r1)"));
    v.put("noOuterDoTry", full.replace("(doTry (body (doTry (body (throw java.lang.IllegalStateException y)) (finally (toDirect r2)))) (finally))",
                                        "(doTry (body (throw java.lang.IllegalStateException y)) (finally (toDirect r2)))"));
    v.put("r2plainSlip", full.replace("(route r2 r2 (doTry (body (routingSlip (simple mock:m1) ;)) (finally)))", "(route r2 r2 (routingSlip (simple mock:m1) ;))"));
    v.put("r2doTryMock", full.replace("(routingSlip (simple mock:m1) ;)", "(toMock m1)"));
    for (var e : v.entrySet()) {
      Path f = Files.createTempFile("hang", ".tsv");
      Files.writeString(f, "h-" + e.getKey() + "\t" + e.getValue() + "\t(send r0 InOnly Sy)\t[]x G=\th\n");
      System.setProperty("hang.seconds", "4");
      java.io.PrintStream out = System.out; System.setOut(new java.io.PrintStream(java.io.OutputStream.nullOutputStream()));
      RouteRun.main(new String[] {f.toString(), f + ".o"});
      System.setOut(out);
      String m = Files.readString(Path.of(f + ".o.mism.tsv"));
      System.out.println(e.getKey() + ": " + (m.contains("HANG") ? "HANG" : "returns"));
    }
    System.exit(0);
  }
}
