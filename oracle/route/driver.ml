(* driver.ml: generator and printer for the L2 route oracle. No semantics here: the expected result of every case
   is computed by the extracted rules (routespec.ml, Route.run_case, proved sound against the rules in Route.v).
   usage: [MODE=real] driver <family> <seed> <count> [hits-file]   (MODE=real: the Real mode of Route.v)
   hits-file: rule id <TAB> number of compared (not UNSPECIFIED) sends whose derivation used it.
   Output, one case per line (TAB separated): id, routes, sends, expected, family.
   Encoding (shared with harness/route/RouteRun.java): every atom is percent-encoded (only [A-Za-z0-9] is kept),
   so the separators ( ) space ; , = : | [ ] never occur inside an atom. *)
open Routespec

let of_chars (l : char list) : string = String.init (List.length l) (List.nth l)
let chars (s : string) : char list = List.init (String.length s) (String.get s)

let pct (s : string) : string =
  let b = Buffer.create (String.length s) in
  String.iter (fun c ->
      if (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') then Buffer.add_char b c
      else Buffer.add_string b (Printf.sprintf "%%%02X" (Char.code c))) s;
  Buffer.contents b
let pc l = pct (of_chars l)

(* canonical value text (CONVENTIONS.md) *)
let canon (v : val0) : string =
  match v with
  | VNull -> "N"
  | VStr s -> "S" ^ pc s
  | VInt z -> "I" ^ Big_int_Z.string_of_big_int z
  | VLong z -> "L" ^ Big_int_Z.string_of_big_int z
  | VDbl q -> "D" ^ Big_int_Z.string_of_big_int q
  | VBool b -> if b then "B1" else "B0"
  | VList l -> "A" ^ string_of_int (List.length l) ^ "." ^ String.concat "," (List.map pc l)

let kvs (l : (char list * val0) list) : string =
  let l = List.map (fun (k, v) -> (of_chars k, v)) l in
  let l = List.sort (fun (a, _) (b, _) -> compare (String.lowercase_ascii a, a) (String.lowercase_ascii b, b)) l in
  String.concat "," (List.map (fun (k, v) -> pct k ^ ":" ^ canon v) l)

let snap ?(unk = false) (x : exchange) : string =
  Printf.sprintf "b=%s;h=%s;p=%s;v=%s;e=%s" (canon x.x_msg.m_body) (kvs x.x_msg.m_headers) (kvs x.x_props)
    (kvs x.x_vars)
    (if unk then "?" else match x.x_exn with
      | None -> "-"
      | Some e -> (if exn_class e = [ '?' ] then "?" else pc (exn_class e)) ^ ":" ^ (if exn_msg e = [ '?' ] then "?" else pc (exn_msg e)))

let sres_text (r : sres) : string =
  match r with
  | SUns w -> "U:" ^ pct w
  | SDone (t, x, _) ->
      "[" ^ String.concat "|" (List.map (fun (EvMock (n, y, u)) -> pc n ^ "=" ^ snap ~unk:u y) t) ^ "]" ^ snap x

(* ---- printing routes and sends ---- *)
let ex (e : expr) =
  match e with
  | XSimple p -> "(simple " ^ pc (render p) ^ ")"
  | XLang (XConstant (t, _, _)) -> "(constant " ^ pc t ^ ")"
  | XLang (XHeader (n, _)) -> "(header " ^ pc n ^ ")"
  | XLang (XProp (n, _)) -> "(exchangeProperty " ^ pc n ^ ")"
  | XLang (XVar (n, _)) -> "(variable " ^ pc n ^ ")"
  | XLang _ -> failwith "language not generated"
let pst = function StNone -> "none" | StLatest -> "latest" | StOriginal -> "original" | StGroupedBody -> "groupedBody"
let rec pstep (s : step) : string =
  match s with
  | SSetBody e -> "(setBody " ^ ex e ^ ")"
  | STransform e -> "(transform " ^ ex e ^ ")"
  | SSetHeader (k, e) -> "(setHeader " ^ pc k ^ " " ^ ex e ^ ")"
  | SSetProperty (k, e) -> "(setProperty " ^ pc k ^ " " ^ ex e ^ ")"
  | SSetVariable (k, e) -> "(setVariable " ^ pc k ^ " " ^ ex e ^ ")"
  | SRemoveHeader k -> "(removeHeader " ^ pc k ^ ")"
  | SRemoveHeaders (p, xs) -> "(removeHeaders " ^ pc p ^ String.concat "" (List.map (fun x -> " " ^ pc x) xs) ^ ")"
  | SRemoveProperty k -> "(removeProperty " ^ pc k ^ ")"
  | SRemoveVariable k -> "(removeVariable " ^ pc k ^ ")"
  | SFilter (p, b) -> "(filter " ^ ex p ^ psteps b ^ ")"
  | SChoice (ws, o) ->
      "(choice" ^ String.concat "" (List.map (fun (p, b) -> " (when " ^ ex p ^ psteps b ^ ")") ws)
      ^ (match o with None -> "" | Some b -> " (otherwise" ^ psteps b ^ ")") ^ ")"
  | SPipeline b -> "(pipeline" ^ psteps b ^ ")"
  | STo (EDirect n) -> "(toDirect " ^ pc n ^ ")"
  | STo (EMock n) -> "(toMock " ^ pc n ^ ")"
  | SStop -> "(stop)"
  | SThrow (c, m) -> "(throw " ^ pc c ^ " " ^ pc m ^ ")"
  | SDoTry (b, cs, f) ->
      "(doTry (body" ^ psteps b ^ ")"
      ^ String.concat "" (List.map (fun ((ts, w), ss) ->
            " (catch (ex" ^ String.concat "" (List.map (fun t -> " " ^ pc t) ts) ^ ") "
            ^ (match w with None -> "(none)" | Some p -> ex p) ^ psteps ss ^ ")") cs)
      ^ (match f with None -> "" | Some ss -> " (finally" ^ psteps ss ^ ")") ^ ")"
  | SSplit (e, o, b) ->
      let opt = function None -> "-" | Some n -> string_of_int n in
      Printf.sprintf "(split %s (opts %s %s %s %s %s)%s)" (ex e) (if o.sp_stop then "1" else "0") (opt o.sp_group)
        (pc o.sp_delim) (opt o.sp_maxfail) (pst o.sp_strat) (psteps b)
  | SAggregate (o, b) ->
      let opt = function None -> "-" | Some n -> string_of_int n in
      let b01 x = if x then "1" else "0" in
      Printf.sprintf "(aggregate %s %s %s %s %s %s %s %s %s %s%s)" (pc o.ago_id) (ex o.ago_corr) (pst o.ago_strat) (opt o.ago_size)
        (match o.ago_pred with None -> "(none)" | Some p -> ex p) (b01 o.ago_eager)
        (b01 o.ago_close) (b01 o.ago_timeout) (b01 o.ago_discard) (b01 o.ago_force) (psteps b)
  | SIdem (id, e, sk, eg, b) ->
      "(idempotent " ^ pc id ^ " " ^ ex e ^ " " ^ (if sk then "1" else "0") ^ " " ^ (if eg then "1" else "0") ^ psteps b ^ ")"
  | SLB (id, LBRoundRobin, b) -> "(lb " ^ pc id ^ " roundRobin" ^ psteps b ^ ")"
  | SLB (id, LBFailover (exs, mx), b) ->
      "(lb " ^ pc id ^ " failover (ex" ^ String.concat "" (List.map (fun t -> " " ^ pc t) exs) ^ ") "
      ^ Big_int_Z.string_of_big_int mx ^ psteps b ^ ")"
  | SRoutingSlip (e, d) -> "(routingSlip " ^ ex e ^ " " ^ pc d ^ ")"
  | SDynamicRouter (e, d) -> "(dynamicRouter " ^ ex e ^ " " ^ pc d ^ ")"
  | SConvertBody (t, m) -> "(convertBodyTo " ^ pct (jname t) ^ " " ^ (if m then "1" else "0") ^ ")"
  | SLoop (e, cp, dw, b) -> "(loop " ^ ex e ^ " " ^ (if cp then "1" else "0") ^ " " ^ (if dw then "1" else "0") ^ psteps b ^ ")"
  | SMulticast (st, bs) -> "(multicast " ^ pst st ^ psteps bs ^ ")"
  | SRecipientList (st, e, d) -> "(recipientList " ^ pst st ^ " " ^ ex e ^ " " ^ pc d ^ ")"
and psteps b = String.concat "" (List.map (fun s -> " " ^ pstep s) b)
let pclause (k : clause) =
  "(onException (ex" ^ String.concat "" (List.map (fun t -> " " ^ pc t) k.c_ex) ^ ") "
  ^ (match k.c_when with None -> "(none)" | Some p -> ex p) ^ " "
  ^ (match k.c_handled with None -> "-" | Some true -> "1" | Some false -> "0") ^ " "
  ^ (if k.c_continued then "1" else "0") ^ " " ^ string_of_int k.c_redeliveries ^ " "
  ^ (match k.c_retry with None -> "(none)" | Some p -> ex p) ^ " " ^ (if k.c_onredel then "1" else "0") ^ " "
  ^ (match k.c_scope with None -> "(scope)" | Some r -> "(scope " ^ pc r ^ ")") ^ psteps k.c_steps ^ ")"
let pclauses cs = "(clauses" ^ String.concat "" (List.map (fun k -> " " ^ pclause k) cs) ^ ")"
(* the program's error handler: nothing for the default one, (eh dlc <mock> <redeliveries> none|msg|body) *)
let peh = function
  | EHDefault -> []
  | EHDlc (q, n, uo) -> [ Printf.sprintf "(eh dlc %s %d %s)" (pc q) n (match uo with UONone -> "none" | UOMessage -> "msg" | UOBody -> "body") ]
(* the onCompletion of the first route: (onCompletion always|complete|failure <when|(none)> after|before 0|1 <steps>) *)
let poc = function
  | None -> []
  | Some o -> [ "(onCompletion " ^ (match o.oc_trig with OcAlways -> "always" | OcComplete -> "complete" | OcFailure -> "failure") ^ " "
                ^ (match o.oc_when with None -> "(none)" | Some p -> ex p) ^ " " ^ (if o.oc_before then "before" else "after") ^ " "
                ^ (if o.oc_orig then "1" else "0") ^ psteps o.oc_steps ^ ")" ]
let proute (r : route) = "(route " ^ pc r.r_id ^ " " ^ pc r.r_from ^ psteps r.r_steps ^ ")"
let is_tick (s : send) = s.s_to = chars "~wait" || s.s_to = chars "~stop"
let psend (s : send) =
  if s.s_to = chars "~wait" then "(wait)" else if s.s_to = chars "~stop" then "(stop)" else
  "(send " ^ pc s.s_to ^ " " ^ (match s.s_mep with InOnly -> "InOnly" | InOut -> "InOut") ^ " " ^ canon s.s_body
  ^ String.concat "" (List.map (fun (k, v) -> " (h " ^ pc k ^ " " ^ canon v ^ ")") s.s_headers) ^ ")"

(* ---- generator ---- *)
let pick l = List.nth l (Random.int (List.length l))
let hkeys = [ "a"; "A"; "b"; "B1" ]
let pkeys = [ "p"; "P" ]
let vkeys = [ "v"; "w" ]
let gkeys = [ "global:g" ]
let texts = [ "x"; "y"; "ab"; "1" ]
let lists = [ "a,b"; "a,b,c"; "x;y"; "1,2,3,4,5" ]
let throwables = [ "java.lang.IllegalArgumentException"; "java.lang.IllegalStateException"; "java.io.IOException";
                   "java.lang.NumberFormatException" ]
let catchables = throwables @ [ "java.lang.Exception"; "java.lang.RuntimeException" ]
let s_ x = VStr (chars x)
let agg_counter = ref 0
let gen_strat () = match Random.int 6 with 0 -> StLatest | 1 -> StOriginal | 2 -> StGroupedBody | _ -> StNone
let gen_val () =
  match Random.int 16 with
  | 0 -> VNull
  | 1 -> VInt (Big_int_Z.big_int_of_int (Random.int 3))
  | 2 | 3 | 4 -> s_ (pick lists)
  | 5 | 6 -> VList (List.init (Random.int 4) (fun _ -> chars (pick texts)))
  | _ -> s_ (pick texts)

let gen_fn () =
  match Random.int 5 with
  | 0 -> FBody
  | 1 | 2 -> FHeader (0, chars (pick hkeys))
  | 3 -> FProp (0, chars (pick pkeys))
  | _ -> FVar (chars (pick vkeys))

let gen_lang () : lexp =
  match Random.int 4 with
  | 0 -> XConstant (chars (pick texts), None, true)
  | 1 -> XHeader (chars (pick hkeys), true)
  | 2 -> XProp (chars (pick pkeys), true)
  | _ -> XVar (chars (pick vkeys), true)
let gen_expr () : expr =
  match Random.int 7 with
  | 0 -> XSimple (PExpr [ TText (chars (pick texts)) ])
  | 1 | 2 -> XSimple (PExpr [ TFn (false, gen_fn ()) ])
  | 3 -> XSimple (PExpr [ TText (chars (pick texts)); TFn (false, gen_fn ()) ])
  | 4 -> XSimple (PExpr [ TFn (false, gen_fn ()); TText (chars "-"); TFn (false, gen_fn ()) ])
  | _ -> XLang (gen_lang ())

let gen_pred () : expr =
  if Random.int 8 = 0 then XLang (match Random.int 2 with 0 -> XHeader (chars (pick hkeys), true) | _ -> XProp (chars (pick pkeys), true))
  else
  let op = pick [ OEq; ONe; OContains; OStarts ] in
  XSimple (PPred (PS (ACmp (LFn (gen_fn ()), op, RLit (LQ (chars (pick texts)))), PNil)))

(* [calls]: the direct routes this route may call (only later ones, so there are no cycles) *)
let agt_bias = ref 1
let has_timed = ref false   (* the program has an aggregator with completionTimeout or forceCompletionOnStop *)
let rec gen_steps depth calls n = List.init n (fun _ -> gen_step depth calls)
and gen_step depth calls : step =
  let leaf () =
    match Random.int 16 with
    | 0 -> SSetBody (gen_expr ())
    | 1 -> STransform (gen_expr ())
    | 2 | 3 -> SSetHeader (chars (pick hkeys), gen_expr ())
    | 4 -> SSetProperty (chars (pick pkeys), gen_expr ())
    | 5 -> SSetVariable (chars (pick (vkeys @ gkeys)), gen_expr ())
    | 6 -> SRemoveHeader (chars (pick hkeys))
    | 7 -> SRemoveHeaders (chars (pick [ "*"; "a*"; "B*"; "b" ]), (if Random.bool () then [] else [ chars "a" ]))
    | 8 -> SRemoveProperty (chars (pick pkeys))
    | 9 -> SRemoveVariable (chars (pick [ "v"; "*" ]))
    | 10 | 11 | 12 -> STo (EMock (chars (pick [ "m1"; "m2" ])))
    | 13 -> if Random.int 3 = 0 then SStop else STo (EMock (chars "m1"))
    | 14 -> if Random.int 2 = 0 then SThrow (chars (pick throwables), chars (pick texts))
            else SSetHeader (chars "a", gen_expr ())
    | _ -> (match calls with [] -> STo (EMock (chars "m2")) | _ -> STo (EDirect (chars (pick calls))))
  in
  if depth <= 0 then leaf ()
  else
    match Random.int 13 with
    | 0 -> SFilter (gen_pred (), gen_steps (depth - 1) calls (1 + Random.int 2))
    | 1 ->
        let ws = List.init (1 + Random.int 2) (fun _ -> (gen_pred (), gen_steps (depth - 1) calls (1 + Random.int 2))) in
        SChoice (ws, if Random.bool () then Some (gen_steps (depth - 1) calls (1 + Random.int 2)) else None)
    | 2 when Random.int 3 = 0 -> SPipeline (gen_steps (depth - 1) calls (1 + Random.int 2))
    | 11 ->
        (match Random.int 3 with
         | 0 ->
             let dests = List.map (fun n -> "direct:" ^ n) calls @ [ "mock:m1"; "mock:m2" ] in
             let d = pick [ ","; ";" ] in
             SRoutingSlip (XSimple (PExpr [ TText (chars (String.concat d (List.init (1 + Random.int 3) (fun _ -> pick dests)))) ]), chars d)
         | 1 -> SPipeline [ SSetHeader (chars "dest", XSimple (PExpr [ TText (chars "direct:rdyn") ]));
                            SDynamicRouter (XSimple (PExpr [ TFn (false, FHeader (0, chars "dest")) ]), chars ",") ]
         | _ -> SConvertBody (pick [ TString; TInteger; TLong; TDouble; TBoolean ], Random.int 3 > 0))
    | 10 ->
        incr agg_counter;
        let id = "node" ^ string_of_int !agg_counter in
        if Random.bool () then
          SIdem (chars id, XSimple (PExpr [ TFn (false, (if Random.int 3 = 0 then FBody else FHeader (0, chars (pick [ "a"; "b" ])))) ]),
                 Random.int 4 > 0, Random.int 6 > 0, gen_steps (depth - 1) calls (1 + Random.int 2))
        else
          let branch () = if Random.int 3 = 0 then SPipeline [ STo (EMock (chars "m1")); SThrow (chars (pick throwables), chars "lb") ]
                          else match gen_step (depth - 1) calls with
                               | SLB _ as l -> SPipeline [ l ]   (* a load balancer directly inside one is not a route *)
                               | st -> st in
          let bs = List.init (2 + Random.int 2) (fun _ -> branch ()) in
          if Random.bool () then SLB (chars id, LBRoundRobin, bs)
          else SLB (chars id, LBFailover ((if Random.bool () then [] else [ chars (pick catchables) ]),
                                          Big_int_Z.big_int_of_int (pick [ -1; -1; 0; 1 ])), bs)
    | 9 ->
        if Random.int 3 = 0 then
          (* while: the body only grows (append x), so it ends in Camel too *)
          SLoop (XSimple (PPred (PS (ACmp (LFn FBody, ONContains, RLit (LQ (chars "xxx"))), PNil))), false, true,
                 [ STransform (XSimple (PExpr [ TFn (false, FBody); TText (chars "x") ])); STo (EMock (chars "m1")) ])
        else
          SLoop ((if Random.int 4 = 0 then XSimple (PExpr [ TFn (false, FHeader (0, chars (pick hkeys))) ])
                  else XSimple (PExpr [ TText (chars (pick [ "0"; "1"; "2"; "3"; "x" ])) ])),
                 Random.bool (), false, gen_steps (depth - 1) calls (1 + Random.int 2))
    | 8 ->
        incr agg_counter;
        (* completionTimeout (abstract time: the wait sends) on 1 aggregator in 3 (family agt: 2 in 3) *)
        let timeout = Random.int 3 < !agt_bias in
        let size = if Random.int 4 = 0 then None else Some (1 + Random.int 3) in
        let size = if timeout && Random.int 3 = 0 then None else size in
        let pred = if (size = None && not timeout) || Random.int 4 = 0 then Some (gen_pred ()) else None in
        SAggregate ({ ago_id = chars ("agg" ^ string_of_int !agg_counter);
                      ago_corr = XSimple (PExpr [ TFn (false, FHeader (0, chars (pick [ "a"; "b"; "a"; "B1" ]))) ]);
                      ago_strat = (if Random.bool () then StLatest else StGroupedBody);
                      ago_size = size; ago_pred = pred; ago_eager = Random.int 3 = 0; ago_close = Random.int 3 = 0;
                      ago_timeout = timeout; ago_discard = timeout && Random.int 3 = 0;
                      ago_force = (let f = Random.int 3 = 0 in if f || timeout then has_timed := true; f) },
                    gen_steps (depth - 1) calls (1 + Random.int 2))
    | 7 ->
        if Random.bool () then SMulticast (gen_strat (), gen_steps (depth - 1) calls (2 + Random.int 2))
        else
          let dests = List.map (fun n -> "direct:" ^ n) calls @ [ "mock:m1"; "mock:m2" ] in
          let d = pick [ ","; ";" ] in
          let us = List.init (1 + Random.int 3) (fun _ -> pick dests) in
          SRecipientList (gen_strat (), XSimple (PExpr [ TText (chars (String.concat d us)) ]), chars d)
    | 5 | 6 ->
        let e = if Random.int 6 > 0 then XSimple (PExpr [ TFn (false, FBody) ]) else XSimple (PExpr [ TFn (false, FHeader (0, chars (pick hkeys))) ]) in
        let body = gen_steps (depth - 1) calls (1 + Random.int 3) in
        let body = if Random.int 3 = 0 then body @ [ SFilter (gen_pred (), [ SThrow (chars (pick throwables), chars "s") ]) ] else body in
        let maxf = if Random.int 3 = 0 then Some (1 + Random.int 3) else None in
        let stop = maxf = None && Random.int 3 = 0 in
        SSplit (e, { sp_stop = stop; sp_group = (if Random.int 4 = 0 then Some (1 + Random.int 3) else None);
                     sp_delim = chars (pick [ ","; ","; ";"; "false" ]); sp_maxfail = maxf;
                     sp_strat = (if maxf = None && not stop then gen_strat () else StNone) }, body)
    | 3 | 4 ->
        let body = gen_steps (depth - 1) calls (1 + Random.int 3) in
        let body = if Random.int 3 = 0 then body else body @ [ SThrow (chars (pick throwables), chars (pick texts)) ] in
        let nc = Random.int 3 in
        let cs = List.init nc (fun _ ->
            ((List.init (1 + Random.int 2) (fun _ -> chars (pick catchables)),
              (if Random.int 3 = 0 then Some (gen_pred ()) else None)),
             gen_steps (depth - 1) calls (1 + Random.int 2))) in
        let fin = if nc = 0 || Random.bool () then Some (gen_steps (depth - 1) calls (1 + Random.int 2)) else None in
        SDoTry (body, cs, fin)
    | _ -> leaf ()

(* steps of an onException block: no throw, no direct call (an exception inside the block is UNSPECIFIED) *)
let gen_block () =
  List.init (Random.int 3) (fun _ ->
      match Random.int 5 with
      | 0 -> STransform (gen_expr ())
      | 1 -> SSetBody (gen_expr ())
      | 2 -> SSetHeader (chars (pick hkeys), gen_expr ())
      | _ -> STo (EMock (chars (pick [ "m1"; "m2" ]))))
let gen_eh () = if Random.int 3 = 0 then EHDlc (chars "dead", Random.int 3, pick [ UONone; UOMessage; UOBody ]) else EHDefault
let gen_oc () : oncomp option =
  if Random.int 3 <> 0 then None
  else Some { oc_trig = pick [ OcAlways; OcComplete; OcFailure ]; oc_when = (if Random.int 3 = 0 then Some (gen_pred ()) else None);
              oc_before = Random.bool (); oc_orig = Random.int 4 = 0;
              oc_steps = (match gen_block () with [] -> [ STo (EMock (chars "m1")) ] | b -> b) }
let rw_bias = ref 4   (* family rw: retryWhile / onRedelivery on every second clause *)
let gen_clauses () : clause list =
  if Random.int 3 = 0 then []
  else
    List.init (1 + Random.int 3) (fun _ ->
        let h, k = match Random.int 5 with
          | 0 | 1 -> (Some true, false) | 2 -> (Some false, false) | 3 -> (None, true) | _ -> (None, false) in
        { c_ex = List.init (1 + Random.int 2) (fun _ -> chars (pick catchables));
          c_when = (if Random.int 4 = 0 then Some (gen_pred ()) else None);
          c_handled = h; c_continued = k;
          c_redeliveries = (if Random.int 3 = 0 then 1 + Random.int 2 else 0);
          c_steps = gen_block ();
          c_retry = None; c_onredel = false; c_scope = None })
    |> List.map (fun k ->
        (* retryWhile: always bounded by the redelivery counter ("${header.CamelRedeliveryCounter} < N", maybe && a
           predicate), never with maximumRedeliveries (which would add the max counter header) *)
        let k = if Random.int !rw_bias = 0 then
            let bound = ACmp (LFn (FHeader (0, chars "CamelRedeliveryCounter")), OLt, RLit (LNum (Big_int_Z.big_int_of_int (Random.int 4)))) in
            let rest = if Random.bool () then PNil
              else match gen_pred () with
                | XSimple (PPred (PS (a, PNil))) -> PCons (LAnd, a, PNil)
                | _ -> PNil in
            { k with c_retry = Some (XSimple (PPred (PS (bound, rest)))); c_redeliveries = 0 }
          else k in
        if Random.int !rw_bias = 0 then { k with c_onredel = true } else k)

let gen_case () : clause list * route list * send list =
  let nr = 1 + Random.int 3 in
  let names = List.init nr (fun i -> "r" ^ string_of_int i) in
  let routes =
    List.mapi (fun i nm ->
        let later = List.filteri (fun j _ -> j > i) names in
        { r_id = chars nm; r_from = chars nm; r_steps = gen_steps 2 later (1 + Random.int 5) }) names
  in
  let sends =
    List.init (1 + Random.int 3) (fun _ ->
        let hs = List.sort_uniq (fun (a, _) (b, _) -> compare (String.lowercase_ascii a) (String.lowercase_ascii b))
            (if Random.bool () then List.map (fun k -> (k, s_ (pick texts))) [ "a"; "b"; "B1" ]
             else List.init (Random.int 3) (fun _ -> (pick hkeys, gen_val ()))) in
        { s_to = chars "r0"; s_mep = (if Random.bool () then InOnly else InOut); s_body = gen_val ();
          s_headers = List.map (fun (k, v) -> (chars k, v)) hs })
  in
  (* the dynamic router's destination: it removes the header the router reads, so the router ends *)
  let rdyn = { r_id = chars "rdyn"; r_from = chars "rdyn";
               r_steps = [ SRemoveHeader (chars "dest"); STo (EMock (chars "m2")) ] } in
  (gen_clauses (), routes @ [ rdyn ], sends)

(* family agt: focused programs for abstract time (L2.aggregate.timeout): aggregators keyed by a String header *)
let gen_agt_case () : clause list * route list * send list =
  has_timed := true;
  let agg () =
    incr agg_counter;
    let timeout = Random.int 4 > 0 in
    let size = if Random.bool () then Some (2 + Random.int 2) else None in
    let size = if size = None && not timeout then Some 2 else size in
    SAggregate ({ ago_id = chars ("agg" ^ string_of_int !agg_counter);
                  ago_corr = XSimple (PExpr [ TFn (false, FHeader (0, chars (pick [ "a"; "b" ]))) ]);
                  ago_strat = (if Random.bool () then StLatest else StGroupedBody);
                  ago_size = size; ago_pred = None; ago_eager = false; ago_close = Random.int 4 = 0;
                  ago_timeout = timeout; ago_discard = timeout && Random.int 3 = 0; ago_force = Random.int 3 = 0 },
                [ STransform (XSimple (PExpr [ TFn (false, FBody); TText (chars "!") ])); STo (EMock (chars "m1")) ]) in
  let r0 = { r_id = chars "r0"; r_from = chars "r0";
             r_steps = (if Random.bool () then [ SSetHeader (chars "B1", XSimple (PExpr [ TText (chars "t") ])) ] else [])
                       @ [ agg () ] @ (if Random.int 3 = 0 then [ agg () ] else []) @ [ STo (EMock (chars "m2")) ] } in
  let sends = List.init (2 + Random.int 4) (fun _ ->
      { s_to = chars "r0"; s_mep = InOnly; s_body = s_ (pick [ "p"; "q"; "r" ]);
        s_headers = [ (chars "a", s_ (pick [ "x"; "y" ])); (chars "b", s_ (pick [ "x"; "y" ])) ] }) in
  ([], [ r0 ], sends)

let hits : (string, int) Hashtbl.t = Hashtbl.create 64
let count_hits rs =
  List.iter (function
      | SDone (_, _, h) -> List.iter (fun r -> Hashtbl.replace hits r (1 + try Hashtbl.find hits r with Not_found -> 0))
                             (List.sort_uniq compare h)
      | SUns _ -> ()) rs

let () =
  let fam = Sys.argv.(1) and seed = int_of_string Sys.argv.(2) and count = int_of_string Sys.argv.(3) in
  Random.init seed;
  if fam = "rw" then rw_bias := 2;
  if fam = "agt" then agt_bias := 2;
  for i = 1 to count do
    has_timed := false;
    let clauses, routes, sends = if fam = "combo" then Combo.gen_case () else if fam = "agt" then gen_agt_case () else gen_case () in
    (* abstract time (L2.aggregate.timeout): a wait after some sends, maybe a stop at the end *)
    let tick n = { s_to = chars n; s_mep = InOnly; s_body = VNull; s_headers = [] } in
    let sends = if not !has_timed then sends
      else List.concat_map (fun s -> if Random.int 2 = 0 then [ s; tick "~wait" ] else [ s ]) sends
           @ (if Random.int 2 = 0 then [ tick "~stop" ] else []) in
    (* route scoped clauses (L3.onException.scope): one in 4 (family scope: one in 2), on one of the program's routes *)
    let clauses = List.map (fun k -> if Random.int (if fam = "scope" then 2 else 4) = 0
                                     then { k with c_scope = Some (pick (List.map (fun r -> r.r_id) routes)) } else k) clauses in
    let eh = if fam = "dlc" then EHDlc (chars "dead", Random.int 3, pick [ UONone; UOMessage; UOBody ]) else gen_eh () in
    let clauses = if fam = "dlc" && Random.bool () then [] else clauses in
    let oc = if fam = "oc" || Random.int 2 = 0 then gen_oc () else None in
    let rs, g = run_case (Sys.getenv_opt "MODE" = Some "real") clauses eh oc 400 routes g0 sends in
    count_hits rs;
    let rtext i r = match r, List.nth_opt sends i with
      | SDone (tt, _, _), Some s when is_tick s ->
          "W[" ^ String.concat "|" (List.sort compare (List.map (fun (EvMock (n, y, u)) -> pc n ^ "=" ^ snap ~unk:u y) tt)) ^ "]"
      | _ -> sres_text r in
    let expected = String.concat " " (List.mapi rtext rs) ^ " G=" ^ kvs g.g_global in
    Printf.printf "%s-%d-%d\t%s\t%s\t%s\t%s\t%s\t%s\n" fam seed i (String.concat " " (pclauses clauses :: peh eh @ poc oc @ List.map proute routes))
      (String.concat " " (List.map psend sends)) expected fam (pc (xml_program clauses eh oc routes)) (if List.exists (fun k -> k.c_scope <> None) clauses then "-" else pc (yaml_program clauses eh oc routes))
  done
  ;
  if Array.length Sys.argv > 4 then begin
    let oc = open_out Sys.argv.(4) in
    Hashtbl.iter (fun r n -> Printf.fprintf oc "%s\t%d\n" r n) hits;
    close_out oc
  end
