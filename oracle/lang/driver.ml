(* Oracle driver for L1/Placeholder.v and L1/Lang.v: generates cases (bounded-exhaustive over small alphabets plus
   seeded random), asks the extracted rules (langspec.ml) for the documented result, and prints one case per line:
     #ENV <k=v;...>                                      (first line: the fixed OS environment of the run)
     id TAB PH TAB penv TAB text TAB expected TAB family  (a placeholder text)
     id TAB E|Q TAB lexp TAB lenv TAB expected TAB family (a language expression / predicate)
   Values and texts use the canonical text of CONVENTIONS.md (N, S<pct>, I, L, D<quarters>, B1/B0, A<pct>,...).
   expected: a value, E<pct exception simple name> (E alone: fails, class not documented), U<pct reason>.
   No semantics here: the generator and this printer are harness code; the rules are only in the .v files.
   usage: driver <family|all> <seed> <random-count> *)
open Langspec

let cl (s : string) : char list = List.init (String.length s) (String.get s)
let sc (l : char list) : string = String.init (List.length l) (List.nth l)
let z = Big_int_Z.big_int_of_int

let pct (s : string) : string =
  let b = Buffer.create (String.length s * 2) in
  String.iter (fun c ->
    match c with
    | 'A'..'Z' | 'a'..'z' | '0'..'9' -> Buffer.add_char b c
    | _ -> Buffer.add_string b (Printf.sprintf "%%%02X" (Char.code c))) s;
  Buffer.contents b

let enc_val = function
  | VNull -> "N"
  | VStr s -> "S" ^ pct (sc s)
  | VInt i -> "I" ^ Big_int_Z.string_of_big_int i
  | VLong i -> "L" ^ Big_int_Z.string_of_big_int i
  | VDbl q -> "D" ^ Big_int_Z.string_of_big_int q
  | VBool b -> if b then "B1" else "B0"
  | VList l -> "A" ^ string_of_int (List.length l) ^ "." ^ String.concat "," (List.map (fun s -> pct (sc s)) l)

let enc_pres = function PV s -> "S" ^ pct (sc s) | PFail e -> "E" ^ pct (sc e) | PUns w -> "U" ^ pct w
let enc_lres = function LV v -> enc_val v | LErr e -> "E" ^ pct (sc e) | LUns0 w -> "U" ^ pct w

let enc_kv pre (l : kv) = List.map (fun (k, v) -> pre ^ pct (sc k) ^ "=" ^ pct (sc v)) l
let enc_penv (p : penv) : string =
  String.concat ";" (enc_kv "o." p.pe_override @ enc_kv "s." p.pe_sys @ enc_kv "i." p.pe_initial
                     @ (if p.pe_nested then [] else ["nested=0"]) @ (if p.pe_fallback then [] else ["fallback=0"]))
let enc_vals pre l = List.map (fun (k, v) -> pre ^ pct (sc k) ^ "=" ^ enc_val v) l
let enc_reg = function RgExpr v -> "X" ^ enc_val v | RgPred b -> if b then "P1" else "P0" | RgOther v -> "O" ^ enc_val v
let enc_lenv (x : lenv) : string =
  String.concat ";"
    (("body=" ^ enc_val x.le_body) :: enc_vals "h." x.le_headers @ enc_vals "p." x.le_xprops @ enc_vals "v." x.le_vars
     @ enc_vals "g." x.le_gvars
     @ List.concat_map (fun (g, l) -> List.map (fun (k, v) -> "gr." ^ pct (sc g) ^ "." ^ pct (sc k) ^ "=" ^ enc_val v) l) x.le_groups
     @ List.map (fun (k, r) -> "r." ^ pct (sc k) ^ "=" ^ enc_reg r) x.le_reg
     @ enc_kv "pp.i." x.le_pp.pe_initial)
let oenc k = function None -> [] | Some s -> [k ^ "=" ^ pct (sc s)]
let benc k b = if b then [k ^ "=1"] else []
let enc_lexp (e : lexp) : string =
  String.concat ";" (match e with
    | XConstant (t, rt, tr) -> ["lang=constant"; "text=" ^ pct (sc t)] @ oenc "rt" rt @ benc "notrim" (not tr)
    | XHeader (t, tr) -> ["lang=header"; "text=" ^ pct (sc t)] @ benc "notrim" (not tr)
    | XProp (t, tr) -> ["lang=exchangeProperty"; "text=" ^ pct (sc t)] @ benc "notrim" (not tr)
    | XVar (t, tr) -> ["lang=variable"; "text=" ^ pct (sc t)] @ benc "notrim" (not tr)
    | XRef (t, rt, tr) -> ["lang=ref"; "text=" ^ pct (sc t)] @ oenc "rt" rt @ benc "notrim" (not tr)
    | XTokenize (o, rt) ->
      ["lang=tokenize"; "token=" ^ pct (sc o.tk_token)] @ oenc "end" o.tk_end @ benc "regex" o.tk_regex
      @ benc "xml" o.tk_xml @ benc "incl" o.tk_incl @ oenc "group" o.tk_group @ oenc "gdelim" o.tk_gdelim
      @ benc "skip" o.tk_skip @ oenc "source" o.tk_source @ oenc "inherit" o.tk_inherit @ oenc "rt" rt)

(* the fixed OS environment of a run (the runner script sets exactly these variables) *)
let the_env : kv = List.map (fun (k, v) -> (cl k, cl v))
  [ ("CSPEC_A", "alpha"); ("CSPEC_B", "beta"); ("CSPEC_D_X", "dash"); ("CSPEC_N", "{{a}}");
    ("FOO_SERVICE_HOST", "myserver"); ("FOO_SERVICE_PORT", "8888"); ("BAR_SERVICE_HOST", "barhost");
    ("cspec_lc", "lower") ]

let n = ref 0
let ph_case fam (p : penv) (text : string) =
  incr n;
  let p = { p with pe_env = the_env } in
  Printf.printf "%d\tPH\t%s\t%s\t%s\t%s\n" !n (enc_penv p) (pct text) (enc_pres (resolve p (cl text))) fam
let lang_case fam (pred : bool) (x : lenv) (e : lexp) =
  incr n;
  let x = { x with le_pp = { x.le_pp with pe_env = the_env } } in
  let r = if pred then evalp x e else eval x e in
  Printf.printf "%d\t%s\t%s\t%s\t%s\t%s\n" !n (if pred then "Q" else "E") (enc_lexp e) (enc_lenv x) (enc_lres r) fam

let kvl l = List.map (fun (k, v) -> (cl k, cl v)) l
let pe ?(o = []) ?(s = []) ?(i = []) ?(nested = true) ?(fallback = true) () : penv =
  { pe_override = kvl o; pe_env = []; pe_sys = kvl s; pe_initial = kvl i; pe_nested = nested; pe_fallback = fallback }

(* every word of length 1..n over an alphabet of atoms *)
let words_upto atoms n =
  let rec go k acc cur = if k > n then acc else
    let next = List.concat_map (fun w -> List.map (fun a -> w ^ a) atoms) cur in go (k + 1) (acc @ next) next in
  go 1 [] [""]

(* ---------- placeholder families ---------- *)

let fam_ph_exh () =
  let atoms = ["{{"; "}}"; "a"; "b"; ":"; "\\"; "?"; "!"; " "; "x"] in
  let p = pe ~i:[("a", "1"); ("b", "{{a}}"); ("x", "")] () in
  List.iter (fun w -> ph_case "ph-exh" p w) (words_upto atoms 4)

let fam_ph_forms () =
  let vals = ["v"; "true"; "false"] in
  let layer_sets = [ []; ["o"]; ["s"]; ["i"]; ["o"; "s"]; ["o"; "i"]; ["s"; "i"]; ["o"; "s"; "i"] ] in
  let keys = ["a.b"; "CSPEC_A"; "cspec.a"; "cspec_lc"; "x-y"] in
  let forms k = [ k; k ^ ":dflt"; k ^ ":"; k ^ ":d:e"; "?" ^ k; "!" ^ k; k ^ "?nested=false"; " " ^ k ^ " ";
                  "sys:" ^ k; "sys:" ^ k ^ ":d"; "env:" ^ k; "env:" ^ k ^ ":d" ] in
  List.iter (fun k -> List.iter (fun ls -> List.iteri (fun vi v ->
      (* values differ per layer so the winner is visible; the negation forms need a plain true/false *)
      let mk l = if List.mem l ls then [(k, if vi = 0 then l ^ v else v)] else [] in
      let p = pe ~o:(mk "o") ~s:(mk "s") ~i:(mk "i") () in
      List.iter (fun f -> ph_case "ph-forms" p ("<{{" ^ f ^ "}}>"); ph_case "ph-forms" p ("{{" ^ f ^ "}}")) (forms k))
      vals) layer_sets) keys;
  let fns = [ "env:CSPEC_A"; "env:CSPEC_A:d"; "env:MISSING_X"; "env:MISSING_X:d:e"; "env.CSPEC_A"; "env.CSPEC_A:d";
              "env.MISSING_X:d"; "env:CSPEC_D-X"; "env:cspec_a"; "env:cspec_lc"; "env:CSPEC_N"; "env:"; "env";
              "sys:p.q"; "sys:p.q:d"; "sys:missing.q"; "sys:missing.q:d"; "sys:"; "service:FOO"; "service:FOO:h:1";
              "service.name:FOO"; "service.host:FOO"; "service.port:FOO"; "service:BAR"; "service:BAR:h:1"; "service.name:BAR";
              "service.port:BAR"; "service.host:BAR"; "service:NONE:localhost:8080"; "service:NONE"; "service.name:NONE:h";
              "service.host:NONE:h"; "env:CSPEC-D-X"; "env:CSPEC_D-X:d";
              "service:foo"; "bean:x.y"; "boolean:a == 'b'"; "configmap:x/y"; " env:CSPEC_A "; "env: CSPEC_A";
              "?env:CSPEC_A"; "!env:CSPEC_A"; "env:CSPEC_A?nested=false" ] in
  List.iter (fun sys -> List.iter (fun f -> ph_case "ph-fn" (pe ~s:sys ()) ("[{{" ^ f ^ "}}]")) fns)
    [ []; [("p.q", "sysv")]; [("p.q", "{{a}}")] ]

let fam_ph_nested () =
  let cfgs = [
    [("a", "{{b}}"); ("b", "{{c}}"); ("c", "v")];
    [("a", "{{a}}")];
    [("a", "{{b}}"); ("b", "{{a}}")];
    [("a", "x{{b:dd}}y"); ("b", "")];
    [("a", "x{{b:dd}}y")];
    [("a", "{{b}}"); ("b", "\\{{c\\}}")];
    [("a", "{\"q\":{\"m\":{}\\}}")];
    [("a", "{\"q\":{\"m\":{}}}")];
    [("a", "\\\\{{b}}"); ("b", "B")];
    [("a", "{{b}}-{{b}}"); ("b", "B")];
    [("a", "{{?b}}"); ("b", "B")];
    [("a", "{{!b}}"); ("b", "true")];
    [("a", "{{env:CSPEC_A}}")];
    [("a", "{{sys:p.q}}")];
    [("a:b", "colon")];
  ] in
  let texts = ["{{a}}"; "{{a?nested=false}}"; "<{{a}}|{{a}}>"; "{{a:b}}"; "{{ a }}"; "\\{{a}}"; "\\\\{{a}}";
               "\\{{a\\}}"; "{{a\\}}"; "{{a}}\\"; "a}}"; "{{a"; "{{{a}}}"; "{{a}}}"] in
  List.iter (fun c -> List.iter (fun (nested, fallback) -> List.iter (fun t ->
      ph_case "ph-nested" (pe ~i:c ~s:[("p.q", "sysv")] ~nested ~fallback ()) t) texts)
    [ (true, true); (false, true); (true, false) ]) cfgs

let fam_ph_rand seed count =
  let st = Random.State.make [| seed |] in
  let pick l = List.nth l (Random.State.int st (List.length l)) in
  let keys = ["a"; "b"; "c"; "a.b"; "CSPEC_A"; "x-y"] in
  let vals = ["1"; "v w"; ""; "{{a}}"; "{{c}}"; "true"; "x:y"; "\\{{z\\}}"; "{{b:q}}"] in
  for _ = 1 to count do
    let layer () = List.filter_map (fun k -> if Random.State.int st 3 = 0 then Some (k, pick vals) else None) keys in
    let p = pe ~o:(if Random.State.int st 4 = 0 then layer () else []) ~s:(if Random.State.int st 4 = 0 then layer () else [])
              ~i:(layer ()) ~nested:(Random.State.int st 8 <> 0) () in
    let piece () = match Random.State.int st 6 with
      | 0 | 1 -> pick ["x"; " "; "/"; ":"; "?"; "&"; "-"]
      | 2 -> "{{" ^ pick keys ^ "}}"
      | 3 -> "{{" ^ pick keys ^ ":" ^ pick ["d"; ""; "e:f"] ^ "}}"
      | 4 -> "{{" ^ pick ["?"; "!"; " "; "env:"; "sys:"] ^ pick keys ^ pick [""; "?nested=false"; " "] ^ "}}"
      | _ -> pick ["\\{{"; "\\}}"; "\\\\"; "{"; "}"] in
    let len = 1 + Random.State.int st 5 in
    ph_case "ph-rand" p (String.concat "" (List.init len (fun _ -> piece ())))
  done

(* ---------- language families ---------- *)

let sv s = VStr (cl s)
let lv l = VList (List.map cl l)
let kvv l = List.map (fun (k, v) -> (cl k, v)) l
let lx ?(body = VNull) ?(h = []) ?(p = []) ?(v = []) ?(g = []) ?(gr = []) ?(reg = []) ?(pp = []) () : lenv =
  { le_body = body; le_headers = kvv h; le_xprops = kvv p; le_vars = kvv v; le_gvars = kvv g;
    le_groups = List.map (fun (n, l) -> (cl n, kvv l)) gr; le_reg = List.map (fun (k, r) -> (cl k, r)) reg;
    le_pp = pe ~i:pp () }

let some_vals = [sv "x"; VInt (z 5); VLong (z 7); VDbl (z 10); VBool true; VBool false; lv ["m:a"; "m:b"]; sv ""; sv "true"]

let fam_names () =
  let names = ["foo"; "FOO"; " foo "; "Foo"; "bar"; ""; "  "; "{{a}}"; "resource:x"; "a b"; "${x}"; "\nfoo\t"] in
  let envs =
    List.concat_map (fun v -> [ lx ~h:[("foo", v)] (); lx ~p:[("foo", v)] (); lx ~v:[("foo", v)] ();
                                lx ~h:[("Foo", v)] ~p:[("foo", sv "prop")] () ]) some_vals
    @ [ lx (); lx ~h:[("foo", VNull)] ~p:[("foo", sv "p")] (); lx ~h:[("foo", sv "1"); ("FOO", sv "2")] ();
        lx ~p:[("Foo", sv "P")] (); lx ~v:[("Foo", sv "V")] (); lx ~h:[("bar", sv "B")] ~p:[("foo", sv "pf")] () ] in
  List.iter (fun x -> List.iter (fun nm -> List.iter (fun tr ->
      List.iter (fun pred ->
        lang_case "names" pred x (XHeader (cl nm, tr));
        lang_case "names" pred x (XProp (cl nm, tr));
        lang_case "names" pred x (XVar (cl nm, tr))) [false; true]) [true; false]) names) envs

let fam_var () =
  let names = ["global:k"; "group:t:k"; "group:u:k"; "route:r:k"; "route:k"; "x:k"; "exchange:k"; "k"; "global:K";
               "group:t"; " global:k "] in
  let envs = [ lx ~v:[("k", sv "ex")] ~g:[("k", sv "gl")] ~gr:[("t", [("k", sv "gt")])] ();
               lx (); lx ~g:[("K", sv "GL")] () ] in
  List.iter (fun x -> List.iter (fun nm -> List.iter (fun pred -> lang_case "var" pred x (XVar (cl nm, true))) [false; true]) names) envs

let fam_const () =
  let texts = ["the value"; " a "; ""; "{{a}}"; " {{a}} "; "{{a}}x"; "\\{{a\\}}"; "resource:file:none.txt"; "a}}";
               "{{nope}}"; "{{nope:d}}"; "\n x \t"; "90210"; "true"; "{{sp}}"; "{{myQuery?nested=false}}"; "${body}"] in
  let pp = [("a", "A"); ("sp", " s "); ("myQuery", "{\"query\":{\"match_all\":{}}}")] in
  List.iter (fun t -> List.iter (fun tr -> List.iter (fun rt -> List.iter (fun pred ->
      lang_case "const" pred (lx ~pp ()) (XConstant (cl t, Option.map cl rt, tr)))
      [false; true]) [None; Some "int"; Some "java.lang.String"]) [true; false]) texts

let fam_ref () =
  let reg = [ ("e", RgExpr (sv "ev")); ("eb", RgExpr (VBool true)); ("en", RgExpr VNull); ("el", RgExpr (lv ["a"; "b"]));
              ("pt", RgPred true); ("pf", RgPred false); ("o", RgOther (sv "bean")); ("Up", RgExpr (sv "u")) ] in
  let names = ["e"; "eb"; "en"; "el"; "pt"; "pf"; "o"; "up"; "UP"; "missing"; " e "; ""; "{{a}}"] in
  List.iter (fun nm -> List.iter (fun rt -> List.iter (fun pred ->
      lang_case "ref" pred (lx ~reg ()) (XRef (cl nm, Option.map cl rt, true))) [false; true]) [None; Some "java.lang.String"]) names

let tko ?end_ ?(regex = false) ?(xml = false) ?(incl = false) ?group ?gdelim ?(skip = false) ?source ?inh t =
  { tk_token = cl t; tk_end = Option.map cl end_; tk_regex = regex; tk_xml = xml; tk_incl = incl;
    tk_group = Option.map cl group; tk_gdelim = Option.map cl gdelim; tk_skip = skip; tk_source = Option.map cl source;
    tk_inherit = Option.map cl inh }

let fam_tok_exh () =
  let bodies = "" :: words_upto ["a"; ","; ";"] 5 in
  let opts = [ tko ","; tko ";"; tko ",;"; tko ~regex:true "[,;]"; tko ~regex:true "[,;]+"; tko ~regex:true ",+";
               tko ~regex:true "a"; tko ~skip:true ","; tko ~group:"2" ","; tko ~group:"2" ~gdelim:"|" ",";
               tko ~group:"1" ","; tko ~group:"0" ","; tko ~group:"x" ","; tko ~group:"2" ~skip:true ",";
               tko ~regex:true ~group:"2" "[,;]"; tko ~regex:true ~group:"2" ~gdelim:"+" "[,;]";
               tko ~incl:true ","; tko ~regex:true ~skip:true "[,;]+" ] in
  List.iter (fun b -> List.iter (fun o -> lang_case "tok-exh" false (lx ~body:(sv b) ()) (XTokenize (o, None))) opts) bodies

let fam_tok_pairs () =
  let bodies = "" :: words_upto ["["; "]"; "a"; "b"] 5 in
  let opts = [ tko ~end_:"]" "["; tko ~end_:"]" ~incl:true "["; tko ~end_:"]" ~skip:true "[";
               tko ~end_:"]" ~group:"2" "["; tko ~end_:"[" "["; tko ~end_:"]" ~regex:true "[" ] in
  List.iter (fun b -> List.iter (fun o -> lang_case "tok-pairs" false (lx ~body:(sv b) ()) (XTokenize (o, None))) opts) bodies

let fam_tok_misc () =
  let nlb = "a\nb\nc" in
  let toks = ["\n"; "\\n"; " "; " ,"; "\\t"; "${body}"; "{{a}}"; ""; "\r\n"; "b"] in
  List.iter (fun t -> List.iter (fun b ->
      lang_case "tok-token" false (lx ~body:(sv b) ~pp:[("a", ",")] ()) (XTokenize (tko t, None)))
      [nlb; "a b c"; "a\r\nb"; "a,b"]) toks;
  List.iter (fun t -> List.iter (fun b ->
      lang_case "tok-meta" false (lx ~body:(sv b) ()) (XTokenize (tko t, None));
      lang_case "tok-meta" false (lx ~body:(sv b) ()) (XTokenize (tko ~regex:true t, None)))
      ["a.b|c+d[e*f"; "x..y"; "p+q"; "abc"]) ["."; "|"; "+"; "["; "*"; ".."; "\\."; "c+"];
  List.iter (fun (t, e) -> List.iter (fun incl ->
      lang_case "tok-token" false (lx ~body:(sv "x\na;\nb;") ()) (XTokenize (tko ~end_:e ~incl t, None)))
      [false; true]) [("\n", ";"); ("\\n", ";"); ("a", "\n"); (" ", ";"); ("<", " ")];
  List.iter (fun g -> lang_case "tok-token" false (lx ~body:(sv "l1\nl2\nl3\nl4\nl5") ()) (XTokenize (tko ~group:g "\\n", None)))
    ["1"; "2"; "3"; "1000"; "-1"; "${header.n}"];
  let bodies = [VInt (z 1234); VBool true; VDbl (z 10); VLong (z (-12)); lv ["a,b"; "c"]; VNull; sv "a,b"] in
  let srcs = [None; Some ""; Some "variable:v"; Some "header:h"; Some "header:H"; Some "property:p"; Some "v";
              Some "header:pp"; Some "x:y"; Some "missing"] in
  List.iter (fun b -> List.iter (fun s -> List.iter (fun e ->
      let x = lx ~body:b ~h:[("h", b)] ~p:[("p", b); ("pp", b)] ~v:[("v", b)] () in
      let o = match e with None -> tko ?source:s "," | Some e -> tko ?source:s ~end_:e "a" in
      lang_case "tok-src" false x (XTokenize (o, None))) [None; Some "b"]) srcs) bodies;
  List.iter (fun o -> lang_case "tok-misc" false (lx ~body:(sv "<a>1</a>") ()) (XTokenize (o, None)))
    [ tko ~xml:true "a"; tko ~inh:"r" ~end_:"</a>" "<a>"; tko ~end_:"</a>" "<a>" ];
  lang_case "tok-misc" false (lx ~body:(sv "a,b") ()) (XTokenize (tko ",", Some (cl "java.lang.String")));
  lang_case "tok-misc" true (lx ~body:(sv "a,b") ()) (XTokenize (tko ",", None))

let fam_lang_rand seed count =
  let st = Random.State.make [| seed + 7 |] in
  let pick l = List.nth l (Random.State.int st (List.length l)) in
  for _ = 1 to count do
    let b = String.concat "" (List.init (Random.State.int st 8) (fun _ -> pick ["a"; "b"; ","; ";"; "["; "]"; " "; "\n"])) in
    let opt l = if Random.State.bool st then Some (pick l) else None in
    let o = tko ?end_:(opt ["]"; ";"; "b"]) ~regex:(Random.State.int st 4 = 0) ~incl:(Random.State.int st 4 = 0)
              ?group:(opt ["1"; "2"; "3"]) ?gdelim:(opt ["|"; ""]) ~skip:(Random.State.int st 3 = 0)
              (pick [","; ";"; "["; "a"; "[,;]"; ",+"; "\\n"; " "]) in
    lang_case "lang-rand" false (lx ~body:(sv b) ()) (XTokenize (o, None))
  done

let () =
  let fam = if Array.length Sys.argv > 1 then Sys.argv.(1) else "all" in
  let seed = if Array.length Sys.argv > 2 then int_of_string Sys.argv.(2) else 1 in
  let cnt = if Array.length Sys.argv > 3 then int_of_string Sys.argv.(3) else 2000 in
  print_string ("#ENV " ^ String.concat ";" (List.map (fun (k, v) -> pct (sc k) ^ "=" ^ pct (sc v)) the_env) ^ "\n");
  let all = fam = "all" in
  if all || fam = "ph-exh" then fam_ph_exh ();
  if all || fam = "ph-forms" then fam_ph_forms ();
  if all || fam = "ph-nested" then fam_ph_nested ();
  if all || fam = "ph-rand" then fam_ph_rand seed cnt;
  if all || fam = "names" then fam_names ();
  if all || fam = "var" then fam_var ();
  if all || fam = "const" then fam_const ();
  if all || fam = "ref" then fam_ref ();
  if all || fam = "tok-exh" then fam_tok_exh ();
  if all || fam = "tok-pairs" then fam_tok_pairs ();
  if all || fam = "tok-misc" || fam = "tok-token" || fam = "tok-src" || fam = "tok-meta" then fam_tok_misc ();
  if all || fam = "lang-rand" then fam_lang_rand seed cnt
