(* combo.ml: the "combo" generator family of the L2 route oracle (campaign item 3).
   Only decides which cases exist (TRUST.md 2); the expected results still come from the extracted rules.
   It generates COMBINATIONS, not single features:
   - nesting depth 3-4 (r0), 2-3 (the called routes);
   - every EIP the rules support (split, multicast, recipientList, aggregate, loop, idempotentConsumer, loadBalance
     roundRobin and failover, routingSlip, dynamicRouter, filter, choice, pipeline, to direct:) inside every
     error-handling construct (doTry/doCatch/doFinally, onException handled/continued/redelivery) and the other way
     round;
   - routes that call each other through direct:, routing slips and recipient lists, entering the same route several
     times on one exchange (only later routes are called: no cycles, so every send ends in the rules and in Camel).
   Bias (the shape of the routing-slip hang, findings/2026-10-26-hang-routingslip-dotry-redelivery-lost-callback.md):
   an error plus redelivery, a call that crosses a direct:/slip/recipient-list boundary, and doFinally blocks that
   call other routes. One case in three is a "shape" case: an entry EIP that enters r1 twice, r1 a nested
   doTry/doFinally whose finally calls r2, r2 a doTry around one callback EIP, and a clause with redelivery. *)
open Routespec

let chars (s : string) : char list = List.init (String.length s) (String.get s)
let pick l = List.nth l (Random.int (List.length l))
let one_in n = Random.int n = 0
let range lo hi = lo + Random.int (hi - lo + 1)

let throwables = [ "java.lang.IllegalArgumentException"; "java.lang.IllegalStateException"; "java.io.IOException";
                   "java.lang.NumberFormatException" ]
let catchables = throwables @ [ "java.lang.Exception"; "java.lang.RuntimeException" ]
let texts = [ "x"; "y"; "ab"; "1" ]
let hkeys = [ "a"; "b" ]

let txt t = XSimple (PExpr [ TText (chars t) ])
let fn f = XSimple (PExpr [ TFn (false, f) ])
let hdr k = FHeader (0, chars k)
let body_x = XSimple (PExpr [ TFn (false, FBody); TText (chars "x") ])
let mock n = STo (EMock (chars n))
let direct n = STo (EDirect (chars n))
let throw_ () = SThrow (chars (pick throwables), chars (pick texts))

let ids = ref 0
let fresh p = incr ids; chars (p ^ string_of_int !ids)

let pred () =
  let f = match Random.int 5 with 0 -> FBody | 1 -> FProp (0, chars "p") | _ -> hdr (pick hkeys) in
  XSimple (PPred (PS (ACmp (LFn f, pick [ OEq; ONe; ONe; OContains; OStarts ], RLit (LQ (chars (pick texts)))), PNil)))
(* almost always true: the headers only take the values in [texts] *)
let pred_true () = XSimple (PPred (PS (ACmp (LFn (hdr (pick hkeys)), ONe, RLit (LQ (chars "zz"))), PNil)))

let strat () = match Random.int 6 with 0 -> StLatest | 1 -> StOriginal | 2 -> StGroupedBody | _ -> StNone

let split_opts () =
  let maxf = if one_in 4 then Some (range 1 2) else None in
  let stop = maxf = None && one_in 3 in
  { sp_stop = stop; sp_group = (if one_in 5 then Some (range 1 2) else None); sp_delim = chars (pick [ ","; ","; ";" ]);
    sp_maxfail = maxf; sp_strat = (if maxf = None && not stop then strat () else StNone) }

let agg_opts () =
  { ago_id = fresh "agg"; ago_corr = fn (hdr (pick [ "a"; "b" ])); ago_strat = pick [ StLatest; StGroupedBody ];
    ago_size = Some (range 1 2); ago_pred = None; ago_eager = false; ago_close = false }

let failover () = LBFailover ((if Random.bool () then [] else [ chars (pick catchables) ]),
                              Big_int_Z.big_int_of_int (pick [ -1; -1; 0; 1 ]))

(* a destination list that enters the same direct: route more than once *)
let dest_text calls d =
  let one () =
    match calls with
    | _ :: _ when Random.int 4 > 0 -> "direct:" ^ pick calls
    | _ -> pick [ "mock:m1"; "mock:m2" ] in
  let l = List.init (range 1 3) (fun _ -> one ()) in
  let l = match calls, l with c :: _, [ x ] when one_in 2 -> [ x; "direct:" ^ c ] | _ -> l in
  String.concat d l

(* a call across a boundary: to direct:, a routing slip or a recipient list *)
let call calls =
  match calls with
  | [] -> mock "m2"
  | _ ->
      let d = pick [ ","; ";" ] in
      (match Random.int 6 with
       | 0 | 1 | 2 -> direct (pick calls)
       | 3 | 4 -> SRoutingSlip (txt (dest_text calls d), chars d)
       | _ -> SRecipientList (strat (), txt (dest_text calls d), chars d))

(* the dynamic router goes to rdyn, which removes the header the router reads, so it ends *)
let dyn () = SPipeline [ SSetHeader (chars "dest", txt "direct:rdyn"); SDynamicRouter (fn (hdr "dest"), chars ",") ]

let leaf calls =
  match Random.int 20 with
  | 0 | 1 | 2 | 3 -> throw_ ()
  | 4 | 5 | 6 -> mock (pick [ "m1"; "m2" ])
  | 7 | 8 | 9 | 10 | 11 -> call calls
  | 12 -> dyn ()
  | 13 | 14 -> SSetHeader (chars (pick hkeys), pick [ txt (pick texts); fn FBody; fn (hdr "a") ])
  | 15 -> SSetBody (pick [ txt (pick [ "a,b"; "x" ]); fn (hdr "b"); body_x ])
  | 16 -> SSetProperty (chars "p", txt (pick texts))
  | 17 -> if one_in 3 then SStop else mock "m1"
  | 18 -> SConvertBody (pick [ TString; TInteger ], Random.bool ())
  | _ -> STransform body_x

(* [d]: the nesting depth left; [calls]: the direct: routes this route may call *)
let rec block d calls n = List.init n (fun _ -> step d calls)
and blk d calls = block (d - 1) calls (range 1 2)
and step d calls =
  if d <= 0 || one_in 6 then leaf calls
  else if Random.int 10 < 4 then error_construct d calls
  else eip d calls
and error_construct d calls =
  let body = block (d - 1) calls (range 1 3) in
  let body = if one_in 3 then body else body @ [ throw_ () ] in
  let nc = pick [ 0; 0; 1; 1; 2 ] in
  let cs = List.init nc (fun _ ->
      ((List.init (range 1 2) (fun _ -> chars (pick catchables)), (if one_in 4 then Some (pred ()) else None)),
       block (d - 1) calls (range 1 2))) in
  let fin = if nc = 0 || Random.int 3 > 0 then Some (finally_block (d - 1) calls) else None in
  SDoTry (body, cs, fin)
(* finally blocks: biased toward a call into another route *)
and finally_block d calls =
  if one_in 2 then call calls :: (if one_in 3 then [ step d calls ] else [])
  else if one_in 5 then [] else block d calls (range 1 2)
and lb_branch d calls =
  if one_in 3 then SPipeline [ mock "m1"; throw_ () ]
  else match step d calls with
    | SLB _ as l -> SPipeline [ l ]   (* a load balancer directly inside one is not a route *)
    | s -> s
and eip d calls =
  match Random.int 15 with
  | 0 -> SFilter (pred (), blk d calls)
  | 1 -> SChoice (List.init (range 1 2) (fun _ -> (pred (), blk d calls)), (if Random.bool () then Some (blk d calls) else None))
  | 2 -> SPipeline (blk d calls)
  | 3 | 4 ->
      let e = if Random.int 5 > 0 then fn FBody else fn (hdr (pick hkeys)) in
      SSplit (e, split_opts (), block (d - 1) calls (range 1 3))
  | 5 -> SMulticast (strat (), block (d - 1) calls (range 2 3))
  | 6 ->
      if one_in 4 then
        SLoop (XSimple (PPred (PS (ACmp (LFn FBody, ONContains, RLit (LQ (chars "xxx"))), PNil))), false, true,
               [ STransform body_x; mock "m1" ])
      else SLoop (txt (pick [ "1"; "2"; "2"; "3" ]), Random.bool (), false, blk d calls)
  | 7 -> SIdem (fresh "node", fn (pick [ FBody; hdr "a"; hdr "b" ]), Random.int 4 > 0, true, blk d calls)
  | 8 -> SLB (fresh "node", LBRoundRobin, List.init (range 2 3) (fun _ -> lb_branch (d - 1) calls))
  | 9 | 10 -> SLB (fresh "node", failover (), List.init (range 2 3) (fun _ -> lb_branch (d - 1) calls))
  | 11 -> SAggregate (agg_opts (), blk d calls)
  | 12 -> call calls
  | 13 -> dyn ()
  | _ -> SPipeline (blk d calls @ [ throw_ () ])

(* onException blocks: no throw; sometimes a call into the route reh, which never throws (a block that calls a
   route that fails again recurses through the error handler without end: a user error, not a Camel bug) *)
let clause_block () =
  List.init (Random.int 3) (fun _ ->
      match Random.int 8 with
      | 0 -> STransform body_x
      | 1 -> SSetBody (txt "eh")
      | 2 -> SSetHeader (chars "a", txt "eh")
      | 3 -> if Random.bool () then direct "reh" else SRoutingSlip (txt "direct:reh", chars ",")
      | _ -> mock (pick [ "m1"; "m2" ]))

(* the route that onException blocks call: callback EIPs over mocks only, nothing that can fail *)
let reh () =
  let one () = match Random.int 7 with
    | 0 -> SRoutingSlip (txt "mock:m1", chars ",")
    | 1 -> SMulticast (StNone, [ mock "m1"; mock "m2" ])
    | 2 -> SRecipientList (StNone, txt "mock:m1,mock:m2", chars ",")
    | 3 -> SLoop (txt "1", false, false, [ mock "m2" ])
    | 4 -> SLB (fresh "node", LBRoundRobin, [ mock "m1"; mock "m2" ])
    | 5 -> SSetHeader (chars "b", txt "eh")
    | _ -> mock "m1" in
  { r_id = chars "reh"; r_from = chars "reh"; r_steps = List.init (range 1 2) (fun _ -> one ()) }

let clause ?(cls = []) ?(redeliver = false) () =
  let h, k = match Random.int 6 with
    | 0 | 1 | 2 -> (Some true, false) | 3 -> (Some false, false) | 4 -> (None, true) | _ -> (None, false) in
  let c_ex = match cls with [] -> List.init (range 1 2) (fun _ -> chars (pick catchables)) | l -> List.map chars l in
  let red = if redeliver || Random.int 3 > 0 then range 1 2 else 0 in
  let st = clause_block () in
  let red = if st = [] && h = None && not k && red = 0 then 1 else red in   (* an unconfigured clause is refused *)
  { c_ex; c_when = (if one_in 6 then Some (pred ()) else None); c_handled = h; c_continued = k;
    c_redeliveries = red; c_steps = st; c_retry = None; c_onredel = false; c_scope = None }

let rdyn () =
  { r_id = chars "rdyn"; r_from = chars "rdyn";
    r_steps = [ SRemoveHeader (chars "dest") ] @ (if one_in 4 then [ throw_ () ] else []) @ [ mock "m2" ] }

let route nm steps = { r_id = chars nm; r_from = chars nm; r_steps = steps }

(* ---- random combinations ---- *)
let random_case () =
  let nr = range 3 4 in
  let names = List.init nr (fun i -> "r" ^ string_of_int i) in
  let routes = List.mapi (fun i nm ->
      let later = List.filteri (fun j _ -> j > i) names in
      let d = if i = 0 then range 3 4 else range 2 3 in
      route nm (block d later (range 1 3))) names in
  let ncl = pick [ 0; 0; 1; 1; 2; 3 ] in   (* no clause: more cases the rules decide *)
  let clauses = List.init ncl (fun i -> clause ~redeliver:(i = 0) ()) in
  (clauses, routes)

(* ---- the shape of the hang, with each ingredient varied ---- *)
let entry t =
  let d = "direct:" ^ t in
  match Random.int 10 with
  | 0 -> SRoutingSlip (txt (d ^ "," ^ d), chars ",")
  | 1 -> SRoutingSlip (txt ("mock:m2," ^ d ^ "," ^ d), chars ",")
  | 2 -> SRecipientList (strat (), txt (d ^ "," ^ d), chars ",")
  | 3 -> SMulticast (strat (), [ direct t; direct t ])
  | 4 -> SLoop (txt "2", Random.bool (), false, [ direct t ])
  | 5 -> SSplit (fn FBody, split_opts (), [ direct t ])
  | 6 -> SLB (fresh "node", failover (), [ direct t; direct t ])
  | 7 -> SPipeline [ direct t; direct t ]
  | 8 -> SIdem (fresh "node", fn (hdr "a"), true, true, [ direct t; SRoutingSlip (txt d, chars ",") ])
  | _ -> SPipeline [ SSetHeader (chars "dest", txt "direct:rdyn"); SDynamicRouter (fn (hdr "dest"), chars ","); direct t ]

(* one EIP that holds a callback, to run inside r2's doTry *)
let callback_eip next =
  match Random.int 13 with
  | 0 -> SMulticast (strat (), [ mock "m1"; mock "m2" ])
  | 1 -> SRecipientList (strat (), txt "mock:m1,mock:m2", chars ",")
  | 2 -> SSplit (fn FBody, split_opts (), [ mock "m1" ])
  | 3 -> SLoop (txt "2", Random.bool (), false, [ mock "m1" ])
  | 4 -> SLB (fresh "node", failover (), [ SPipeline [ mock "m1"; throw_ () ]; mock "m2" ])
  | 5 -> SLB (fresh "node", LBRoundRobin, [ mock "m1"; mock "m2" ])
  | 6 -> SAggregate ({ (agg_opts ()) with ago_size = Some 1 }, [ mock "m1" ])
  | 7 -> SIdem (fresh "node", fn (hdr "b"), Random.bool (), true, [ mock "m1" ])
  | 8 -> SFilter (pred_true (), [ mock "m1" ])
  | 9 -> (match next with Some r -> direct r | None -> mock "m1")
  | 10 -> SChoice ([ (pred (), [ mock "m1" ]) ], Some [ mock "m2" ])
  | 11 -> SRoutingSlip (txt "mock:m1", chars ",")   (* the known hang: a positive control *)
  | _ -> dyn ()                                     (* the known hang through a dynamic router *)

let finally_call t =
  match Random.int 5 with
  | 0 | 1 -> direct t
  | 2 -> SRoutingSlip (txt ("direct:" ^ t), chars ",")
  | 3 -> SRecipientList (strat (), txt ("direct:" ^ t), chars ",")
  | _ -> SMulticast (strat (), [ direct t ])

let shape_case () =
  let cls = pick throwables in
  let thrower = (if one_in 3 then [ mock "m1" ] else []) @ [ SThrow (chars cls, chars (pick texts)) ] in
  let catch_ () = [ ((List.init 1 (fun _ -> chars (pick catchables)), None), [ mock "m2" ]) ] in
  let inner = SDoTry (thrower, (if one_in 4 then catch_ () else []), Some [ finally_call "r2" ]) in
  let r1 = match Random.int 7 with
    | 0 | 1 -> [ SDoTry ([ inner ], [], Some []) ]
    | 2 -> [ inner ]
    | 3 -> [ SFilter (pred_true (), [ inner ]) ]
    | 4 -> [ SSplit (fn FBody, split_opts (), [ inner ]) ]
    | 5 -> [ SDoTry ([ inner ], catch_ (), Some [ mock "m1" ]) ]
    | _ -> [ SDoTry ([ callback_eip (Some "r3"); SThrow (chars cls, chars "y") ], [], Some []) ]   (* the error leaves r1 *)
  in
  let r1 = if one_in 3 then r1 @ [ mock "m1" ] else r1 in
  let cb = callback_eip (Some "r3") in
  let r2 = match Random.int 4 with
    | 0 | 1 -> [ SDoTry ([ cb ], [], Some []) ]
    | 2 -> [ cb ]
    | _ -> [ SDoTry ([ cb; throw_ () ], catch_ (), Some [ mock "m2" ]) ] in
  let r0 = (if one_in 3 then [ SSetHeader (chars "a", txt (pick texts)) ] else []) @ [ entry "r1" ]
           @ (if one_in 3 then [ mock "m1" ] else []) in
  let r3 = block 1 [] (range 1 2) in
  let c0 = clause ~cls:[ (if Random.bool () then cls else "java.lang.Exception") ] ~redeliver:true () in
  let clauses = c0 :: (if one_in 3 then [ clause () ] else []) in
  (clauses, [ route "r0" r0; route "r1" r1; route "r2" r2; route "r3" r3 ])

let sends () =
  List.init (range 1 3) (fun _ ->
      let hs = [ ("a", pick texts); ("b", pick texts) ] in   (* always set: idempotent ids and correlation keys *)
      { s_to = chars "r0"; s_mep = (if Random.bool () then InOnly else InOut);
        s_body = (match Random.int 6 with 0 | 1 | 2 -> VStr (chars "a,b") | 3 -> VStr (chars "a,b,c")
                                        | _ -> VStr (chars (pick texts)));
        s_headers = List.map (fun (k, v) -> (chars k, VStr (chars v))) hs })

let gen_case () : clause list * route list * send list =
  let clauses, routes = if one_in 3 then shape_case () else random_case () in
  (clauses, routes @ [ reh (); rdyn () ], sends ())
