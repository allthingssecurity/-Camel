(* driver.ml: case generator and printer for the L5 oracle. No semantics here: the expected result of every case is
   computed by the extracted rules (l5spec.ml: Uri.run_ep, cat_validate, cat_props, cat_asuri, cat_name, proved sound
   in Uri.v) over the extracted generated catalog (GenCatalog.v).
   usage: [MODE=real] driver <level E|C> <family|all> <seed> <count> <hits-file>
     E: endpoint creation (CamelContext.getEndpoint) on the components compiled at the pin (Catalog.avail_pin)
     C: the catalog's URI tools (validateEndpointProperties with ignoreLenientProperties false/true, endpointProperties,
        asEndpointUri, endpointComponentName) on all components of the catalog
   hits-file: rule id <TAB> number of compared (not UNSPECIFIED) cases whose expected result used it.
   Output, one case per line (TAB separated): id, api, input (percent-encoded), expected, family.
   Expected texts (shared with harness/l5/L5Run.java and CatRun.java):
     OK <name>=<canon>|...   FAIL <exception class>   UNS <reason>
     REP U=<names>;R=<names>;I=<kind>:<name>:<value>,...   UNKCOMP
     PROPS <key>:<value>,...   URI <uri>   NAME <scheme>
   where names / keys / values are percent-encoded (only [A-Za-z0-9] kept) and lists are sorted. *)
open L5spec

let of_chars (l : char list) : string = String.init (List.length l) (List.nth l)
let chars (s : string) : char list = List.init (String.length s) (String.get s)
let pct (s : string) : string =
  let b = Buffer.create (String.length s) in
  String.iter (fun c ->
      if (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') then Buffer.add_char b c
      else Buffer.add_string b (Printf.sprintf "%%%02X" (Char.code c))) s;
  Buffer.contents b
let pc l = pct (of_chars l)

let canon (v : val0) : string =
  match v with
  | VNull -> "N"
  | VStr s -> "S" ^ pc s
  | VInt z -> "I" ^ Big_int_Z.string_of_big_int z
  | VLong z -> "L" ^ Big_int_Z.string_of_big_int z
  | VDbl q -> "D" ^ Big_int_Z.string_of_big_int q
  | VBool b -> if b then "B1" else "B0"
  | VList l -> "A" ^ string_of_int (List.length l) ^ "." ^ String.concat "," (List.map pc l)
let bcanon = function BV v -> canon v | BEnum c -> "E" ^ pc c | BPre (k, v) -> "P" ^ pc k ^ ":" ^ pc v
let sorted l = List.sort_uniq compare l
let ikind = function IEnum -> "enum" | IBool -> "boolean" | IInt -> "integer" | INum -> "number" | IDur -> "duration"
                     | IOther -> "other"

let eres_text = function
  | EOk b -> "OK " ^ String.concat "|" (List.map (fun (k, v) -> pc k ^ "=" ^ bcanon v) b)
  | EFail c -> "FAIL " ^ c
  | EFailAny w -> "FAILANY " ^ w
  | EUns w -> "UNS " ^ w
let cvres_text = function
  | CvUnknownComp -> "UNKCOMP"
  | CvSyntax -> "SYNTAX"
  | CvRep (u, r, i) ->
      "REP U=" ^ String.concat "," (sorted (List.map pc u)) ^ ";R=" ^ String.concat "," (sorted (List.map pc r))
      ^ ";I=" ^ String.concat "," (sorted (List.map (fun ((k, n), v) -> ikind k ^ ":" ^ pc n ^ ":" ^ pc v) i))
  | CvUns w -> "UNS " ^ w
let cpres_text = function
  | CpProps kv -> "PROPS " ^ String.concat "," (List.map (fun (k, v) -> pc k ^ ":" ^ pc v) kv)
  | CpUns w -> "UNS " ^ w
let cares_text = function CaUri u -> "URI " ^ pc u | CaUns w -> "UNS " ^ w

(* ---- random choices ---- *)
let rs = ref (Random.State.make [| 0 |])
let rint n = Random.State.int !rs n
let pick l = List.nth l (rint (List.length l))
let chance p = rint 1000 < int_of_float (p *. 1000.)
let tok () =
  let n = 1 + rint 7 in
  String.init n (fun i -> if i = 0 then Char.chr (97 + rint 26) else
                   let k = rint 36 in if k < 26 then Char.chr (97 + k) else Char.chr (48 + k - 26))

(* path values are made unique (seda queues are shared by name within a CamelContext) *)
let uniq = ref 0
let qopts (c : comp) = List.filter (fun o -> o.o_kind = KParam && o.o_prefix = None) c.c_opts
let find_o (c : comp) n = List.find_opt (fun o -> o.o_name = n) c.c_opts

let good_value (o : opt) : string option =
  match o.o_ty with
  | TyString -> if o.o_jt = JString then Some (tok ()) else None
  | TyBoolean -> Some (pick [ "true"; "false" ])
  | TyInteger -> (match o.o_jt with
      | JPInt | JInt -> Some (pick [ "0"; "1"; "5"; "42"; "1000"; "-1"; "65535" ])
      | JPLong | JLong -> Some (pick [ "0"; "7"; "123456789012"; "-3"; "1000" ])
      | _ -> None)
  | TyNumber -> (match o.o_jt with JPDouble | JDouble -> Some (pick [ "2.5"; "10"; "0.25"; "-1.75" ]) | _ -> None)
  | TyDuration -> Some (pick [ "500"; "5s"; "1m30s"; "2h"; "45m"; "1h15m"; "3h45m58s"; "45minutes"; "10seconds";
                               "1hour"; "2h30s" ])
  | TyEnum -> if o.o_enum <> [] && not o.o_multienum then Some (pick o.o_enum) else None
  | _ -> None

let bad_value (o : opt) : string option =
  match o.o_ty with
  | TyBoolean -> Some (pick [ "yes"; "TRUE"; "1"; "abc"; "False"; "on" ])
  | TyInteger -> Some (pick [ "abc"; "12x"; "1.5"; "+5"; "007"; "2147483648"; "99999999999999999999"; "x"; "-0" ])
  | TyNumber -> Some (pick [ "abc"; "1e3"; "1,5"; "NaN"; "x" ])
  | TyDuration -> Some (pick [ "abc"; "5ms"; "1h%2015m"; "15m1h"; "-5"; "1.5h"; "5sec"; "4min"; "h"; "1d" ])
  | TyEnum -> if o.o_enum = [] then None else
      let e = pick o.o_enum in
      Some (pick [ "NotAValue"; String.lowercase_ascii e; String.uppercase_ascii e; e ^ "x";
                   String.concat "-" (String.split_on_char '_' (String.lowercase_ascii e)) ])
  | _ -> None

(* the path of a URI, filled by the syntax: [names] is how many leading names get a value *)
let path_value (c : comp) (n : string) : string =
  match find_o c n with
  (* component-specific (L5b, not in the L5a rules): endpoint creation looks the bean up in the registry (the harness
     binds myBean and otherBean), loads the class of class:, and resolves the language of controlbus:language: *)
  | _ when c.c_scheme = "bean" -> pick [ "myBean"; "otherBean" ]
  | Some o when c.c_scheme = "controlbus" && n = "language" ->
      ignore o; pick [ "simple"; "constant"; "header"; "exchangeProperty"; "tokenize"; "bean"; "variable" ]
  | Some o when o.o_ty = TyEnum && o.o_enum <> [] -> pick o.o_enum
  | Some o when o.o_ty = TyInteger -> string_of_int (1 + rint 9000)
  | _ -> if c.c_scheme = "class" then pick [ "java.lang.Object"; "java.util.ArrayList"; "java.lang.StringBuilder" ]
         else (incr uniq; (if chance 0.2 then tok () ^ "." ^ tok () else tok ()) ^ string_of_int !uniq)

let syntax_rest (c : comp) =
  let s = c.c_syntax in
  let i = String.index s ':' in
  let r = String.sub s (i + 1) (String.length s - i - 1) in
  if String.length r >= 2 && String.sub r 0 2 = "//" then String.sub r 2 (String.length r - 2) else r

let is_alnum ch = (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch = '_'

(* returns (path text, list of (name, value)) filling the first [k] names (all when k < 0) *)
let syn_toks (r : string) =
  let out = ref [] and cur = Buffer.create 16 in
  let flush () = if Buffer.length cur > 0 then (out := `N (Buffer.contents cur) :: !out; Buffer.clear cur) in
  String.iter (fun ch -> if is_alnum ch then Buffer.add_char cur ch else (flush (); out := `D ch :: !out)) r;
  flush (); List.rev !out
let make_path (c : comp) (k : int) : string * (string * string) list =
  let rec go toks idx acc vals =
    match toks with
    | `N n :: rest when k < 0 || idx < k -> let v = path_value c n in go rest (idx + 1) (acc ^ v) ((n, v) :: vals)
    | `D d :: (`N _ :: _ as rest) when k < 0 || idx < k -> go rest idx (acc ^ String.make 1 d) vals
    | _ -> (acc, List.rev vals) in
  go (syn_toks (syntax_rest c)) 0 "" []

let uri_of scheme slashes path params =
  scheme ^ ":" ^ (if slashes then "//" else "") ^ path
  ^ (if params = [] then "" else "?" ^ String.concat "&" (List.map (fun (k, v) -> k ^ "=" ^ v) params))

let some_opts (c : comp) n =
  let cands = List.filter (fun o -> good_value o <> None) (qopts c) in
  if cands = [] then [] else
    sorted (List.init n (fun _ -> (pick cands).o_name))
    |> List.map (fun nm -> match good_value (Option.get (find_o c nm)) with Some v -> (nm, v) | None -> (nm, "x"))
    |> List.sort (fun _ _ -> if chance 0.5 then 1 else -1)

let unknown_names = [ "zzUnknownOpt"; "notAnOption1"; "perid"; "fooBarBaz" ]
(* more values from $CAMELSPEC_PRIVATE/values.txt (one per line) when set: see the private note *)
let private_values =
  match Sys.getenv_opt "CAMELSPEC_PRIVATE" with
  | Some d when Sys.file_exists (Filename.concat d "values.txt") ->
      let ic = open_in (Filename.concat d "values.txt") in
      let rec go acc = match input_line ic with l -> go (if l = "" then acc else l :: acc) | exception End_of_file -> close_in ic; List.rev acc in
      go []
  | _ -> []
let enc_values = [ "a%20b"; "a+b"; "%41BC"; "a%zz"; "caf%C3%A9"; "a%3Db"; "a%2fb"; "%7e" ] @ private_values
let raw_values = [ "RAW(a+b&c)"; "RAW{x)y}"; "RAW()"; "RAW(a)b"; "RAW(abc"; "RAW(se+re?t&23)"; "RAW{a}"; "RAW(%41)" ]

(* ---- families ---- *)
type case = { api : string; input : string; family : string }

let gen_ep_case (fam : string) : case =
  let c = Option.get (find_comp catalog (str (pick avail_pin))) in
  let path, _ = make_path c (-1) in
  let sl = chance 0.25 in
  let mk ps = { api = "ep"; input = uri_of c.c_scheme sl path ps; family = fam } in
  let base () = some_opts c (rint 3) in
  let one_typed f = match List.filter (fun o -> f o <> None) (qopts c) with
    | [] -> base ()
    | os -> let o = pick os in [ (o.o_name, Option.get (f o)) ] in
  let strs = List.filter (fun o -> o.o_ty = TyString && o.o_jt = JString) (qopts c) in
  match fam with
  | "valid" -> mk (base ())
  | "unknown" -> mk (base () @ [ (pick unknown_names, tok ()) ])
  | "missing" -> { api = "ep"; input = c.c_scheme ^ ":" ^ (if chance 0.5 then "" else "?" ^
                     String.concat "&" (List.map (fun (k, v) -> k ^ "=" ^ v) (some_opts c 1))); family = fam }
  | "badtype" -> mk (one_typed bad_value)
  | "encoded" -> (match strs with
      | [] -> mk (base ())
      | os -> mk [ ((pick os).o_name, pick enc_values) ])
  | "raw" -> (match List.filter (fun o -> good_value o <> None) (qopts c) with
      | [] -> mk (base ())
      | os -> let o = pick os in
        mk [ (o.o_name, if o.o_ty = TyString then pick raw_values else "RAW(" ^ Option.get (good_value o) ^ ")") ])
  | "dup" -> (match base () with
      | (k, v) :: r -> mk ((k, v) :: r @ [ (k, Option.value ~default:v (good_value (Option.get (find_o c k)))) ])
      | [] -> mk (base ()))
  | "case" -> (match base () with
      | (k, v) :: r -> mk ((pick [ String.uppercase_ascii k; String.lowercase_ascii k; String.capitalize_ascii k ], v) :: r)
      | [] -> mk [])
  | "enumstyle" -> (match List.filter (fun o -> o.o_ty = TyEnum && o.o_enum <> []) (qopts c) with
      | [] -> mk (base ())
      | os -> let o = pick os in let e = pick o.o_enum in
        let low = String.lowercase_ascii e in
        mk [ (o.o_name, pick [ low; String.uppercase_ascii e; e; String.concat "-" (String.split_on_char '_' low);
                               String.concat "_" (String.split_on_char '-' (String.uppercase_ascii e)) ]) ])
  | "duration" -> (match List.filter (fun o -> o.o_ty = TyDuration) (qopts c) with
      | [] -> mk (base ())
      | os -> mk [ ((pick os).o_name, pick [ "45m"; "1h15m"; "2h30s"; "3h45m58s"; "45minutes"; "5sec"; "4min";
                                             "1h%2015m"; "15m1h"; "45ms"; "1.5h"; "-5"; "0"; "1hour"; "2hours";
                                             "1minute"; "30second"; "1h1h"; "100s"; "9223372036854775807" ]) ])
  | "prefix" -> (match List.filter (fun o -> o.o_multi && o.o_prefix <> None) c.c_opts with
      | [] -> mk (base ())
      | o :: _ -> let p = Option.get o.o_prefix in
        mk (pick [ [ (p ^ tok (), tok ()) ]; [ (p ^ "x", "1"); (p ^ "y", "2") ]; [ (p, "x") ]; [ (p ^ "x", "1"); (p ^ "x", "2") ] ]))
  | "limits" ->
      pick [
        (fun () -> mk (one_typed (fun o -> match o.o_ty, o.o_jt with
             | TyInteger, (JPInt | JInt) -> Some (pick [ "2147483647"; "-2147483648"; "2147483648"; "-2147483649" ])
             | TyInteger, (JPLong | JLong) -> Some (pick [ "9223372036854775807"; "-9223372036854775808"; "9223372036854775808" ])
             | _ -> None)));
        (fun () -> { api = "ep"; input = uri_of c.c_scheme false (String.make (100 + rint 200) 'a') []; family = fam });
        (fun () -> mk [ ((pick (qopts c)).o_name, "") ]);
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ path ^ "?"; family = fam });
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ path ^ "?" ^ (match base () with (k, v) :: _ -> k ^ "=" ^ v | [] -> "a=b") ^ "&"; family = fam });
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ path ^ "?a=1&&b=2"; family = fam });
        (fun () -> { api = "ep"; input = pick [ c.c_scheme; "zzzunknown"; "kafka" ]; family = fam });
        (fun () -> { api = "ep"; input = pick [ "kafka"; "zzzunknown"; "ftp"; "jms"; "file" ] ^ ":" ^ tok (); family = fam });
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ tok () ^ pick [ ":"; "/"; "%20"; "+"; "@"; "." ] ^ tok (); family = fam });
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":/" ^ path; family = fam });
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ path ^ "?" ^ String.make (60 + rint 100) 'q' ^ "=1"; family = fam });
        (fun () -> mk [ ((pick (qopts c)).o_name, pick [ "#bean:x"; "#type:java.lang.Object"; "#x"; "{{p}}" ]) ]);
        (fun () -> mk [ ((pick (qopts c)).o_name, "a?b") ]);
        (fun () -> mk [ ((pick (qopts c)).o_name, "a=b") ]);
        (fun () -> mk (base () @ [ ("hash", tok ()) ]));
        (fun () -> { api = "ep"; input = c.c_scheme ^ ":" ^ path ^ "?&" ^ (match base () with (k, v) :: _ -> k ^ "=" ^ v | [] -> "a=b"); family = fam });
      ] ()
  | _ -> failwith ("family " ^ fam)

let gen_cat_case (fam : string) : case =
  let c = pick catalog in
  let path, pvals = make_path c (-1) in
  let sl = chance 0.15 in
  let mkv ps = { api = (if chance 0.5 then "v0" else "v1"); input = uri_of c.c_scheme sl path ps; family = fam } in
  let base () = some_opts c (rint 3) in
  let one_typed f = match List.filter (fun o -> f o <> None) (qopts c) with
    | [] -> base ()
    | os -> let o = pick os in [ (o.o_name, Option.get (f o)) ] in
  match fam with
  | "valid" -> mkv (base ())
  | "unknown" -> if chance 0.1 then { api = "v0"; input = pick [ "zzzunknown"; "nosuchcomp" ] ^ ":" ^ tok (); family = fam }
                 else mkv (base () @ [ (pick unknown_names, tok ()) ])
  | "missing" ->
      let p1, _ = make_path c (if chance 0.5 then 0 else 1) in
      { api = "v0"; input = uri_of c.c_scheme false p1 (base ()); family = fam }
  | "badtype" -> mkv (one_typed bad_value)
  | "case" -> (match base () with
      | (k, v) :: r -> mkv ((String.uppercase_ascii k, v) :: r)
      | [] -> mkv [])
  | "dup" -> (match base () with (k, v) :: r -> mkv ((k, v) :: r @ [ (k, v) ]) | [] -> mkv [])
  | "props" -> { api = "props"; input = uri_of c.c_scheme sl path (base ()); family = fam }
  | "asuri" ->
      let qs = List.filter (fun (k, v) -> match find_o c k with
          | Some o -> o.o_def <> Some v && String.length v > 0 && String.for_all (fun ch -> is_alnum ch || ch = '.' || ch = '-') v
          | None -> false) (base ()) in
      let all = List.sort (fun _ _ -> if chance 0.5 then 1 else -1) (pvals @ qs) in
      { api = "asuri"; input = String.concat "|" (List.map pct (c.c_scheme :: List.concat_map (fun (k, v) -> [ k; v ]) all));
        family = fam }
  | "name" -> { api = "name"; input = pick [ uri_of c.c_scheme sl path (base ()); c.c_scheme; "a:b:c"; ":x" ]; family = fam }
  | _ -> failwith ("family " ^ fam)

let ep_fams = [ "valid"; "unknown"; "missing"; "badtype"; "encoded"; "raw"; "dup"; "case"; "enumstyle"; "duration";
                "prefix"; "limits" ]
let cat_fams = [ "valid"; "unknown"; "missing"; "badtype"; "case"; "dup"; "props"; "asuri"; "name" ]

let split_pipe s = List.map (fun x -> chars (Scanf.unescaped x)) (String.split_on_char '|' s)
let unpct s =
  let b = Buffer.create (String.length s) and i = ref 0 in
  while !i < String.length s do
    if s.[!i] = '%' then (Buffer.add_char b (Char.chr (int_of_string ("0x" ^ String.sub s (!i + 1) 2))); i := !i + 3)
    else (Buffer.add_char b s.[!i]; incr i)
  done; Buffer.contents b

(* MODE=real: the Real mode of Catalog.v (rules + open findings as deltas) *)
let real = (try Sys.getenv "MODE" with Not_found -> "") = "real"
let expected (c : case) : string * string list * bool =
  match c.api with
  | "ep" -> let r, h = (if real then run_real else run_pin) (chars c.input) in (eres_text r, h, (match r with EUns _ -> true | _ -> false))
  | "v0" | "v1" -> let r, h = (if real then cat_validate_real else cat_validate catalog) (c.api = "v1") (chars c.input) in
      (cvres_text r, h, (match r with CvUns _ -> true | _ -> false))
  | "props" -> let r, h = cat_props catalog (chars c.input) in (cpres_text r, h, (match r with CpUns _ -> true | _ -> false))
  | "asuri" ->
      (match List.map (fun x -> chars (unpct x)) (String.split_on_char '|' c.input) with
       | s :: kv ->
           let rec pairs = function k :: v :: r -> (k, v) :: pairs r | _ -> [] in
           let r, h = cat_asuri catalog s (pairs kv) in (cares_text r, h, (match r with CaUns _ -> true | _ -> false))
       | [] -> ("UNS empty", [], true))
  | "name" -> (match cat_name (chars c.input) with
      | Some s when String.contains c.input ':' -> ("NAME " ^ pc s, [ "L5.cat.name" ], false)
      | _ -> ("UNS CCJ: endpointComponentName of a URI without a scheme (not documented)", [], true))
  | _ -> failwith "api"

let () =
  let _ = split_pipe in
  let level = Sys.argv.(1) and fam = Sys.argv.(2) and seed = int_of_string Sys.argv.(3)
  and count = int_of_string Sys.argv.(4) and hitsf = Sys.argv.(5) in
  rs := Random.State.make [| seed |];
  let fams = if fam = "all" then (if level = "E" then ep_fams else cat_fams) else [ fam ] in
  let hits = Hashtbl.create 64 in
  for i = 0 to count - 1 do
    let f = List.nth fams (i mod List.length fams) in
    let c = if level = "E" then gen_ep_case f else gen_cat_case f in
    let exp, h, uns = expected c in
    if not uns then List.iter (fun r -> Hashtbl.replace hits r (1 + Option.value ~default:0 (Hashtbl.find_opt hits r)))
        (List.sort_uniq compare h);
    let inp = if c.api = "asuri" then c.input else pct c.input in
    Printf.printf "%s-%d\t%s\t%s\t%s\t%s\n" level i c.api inp exp c.family
  done;
  let oc = open_out hitsf in
  Hashtbl.iter (fun k v -> Printf.fprintf oc "%s\t%d\n" k v) hits;
  close_out oc
