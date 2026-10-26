(* driver.ml: generator and printer for the L4 lifecycle oracle. No semantics here: the expected result of every
   operation is computed by the extracted rules (lifecyclespec.ml, Lifecycle.run_case, proved sound and complete
   against the rules lstep in theories/L4/Lifecycle.v).
   usage: [MODE=real] driver <family> <seed> <count> [hits-file]
   families: rand (small orders, some clashes), limits (orders at 0/-1/1000/1001/Integer bounds, odd and long ids),
             ops (8 operations, mostly route-level), guided (8 operations, each chosen among random candidates so that
             the rules (Doc, sus=true) do not call it UNSPECIFIED: deeper compared traces).
   Output, one case per line (TAB separated): id, program, operations, expected (sus=true), expected (sus=false), family.
   Encoding (shared with harness/l4/LifecycleRun.java): ids are percent-encoded (only [A-Za-z0-9] kept).
     program   A<0|1> then per route <id>:<order|N>:<auto 0|1>
     operation start stop suspend resume startAll stopAll rstart.<id> rstop.<id> rsuspend.<id> rresume.<id>
               remove.<id> send.<id>.<block 0|1>
     expected  per operation <res>/<events>/<ctx status>/<route statuses>, then U:<why> if an operation is UNSPECIFIED
               res K | B0 | B1 | E<class> | D1 (reached the route) | D0 (failed, exception class not compared)
               events * | L<ev,...>^<ev,...> (exactly these, in order, once the ^ ones are dropped) | G... (any order)
               ev S.<id> started, T.<id> stopped, R.<id> removed
               status Started Stopped Suspended - (getRoute null) ? (not documented, not compared) *)
open Lifecyclespec

let of_chars (l : char list) : string = String.init (List.length l) (List.nth l)
let chars (s : string) : char list = List.init (String.length s) (String.get s)

let pct (s : string) : string =
  let b = Buffer.create (String.length s) in
  String.iter (fun c ->
      if (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') then Buffer.add_char b c
      else Buffer.add_string b (Printf.sprintf "%%%02X" (Char.code c))) s;
  Buffer.contents b
let pc l = pct (of_chars l)

(* ---- printing ---- *)
let pev = function EStarted k -> "S." ^ pc k | EStopped k -> "T." ^ pc k | ERemoved k -> "R." ^ pc k
let pevs l = String.concat "," (List.map pev l)
let pevobs = function
  | EvAny -> "*"
  | EvSeq (l, ign) -> "L" ^ pevs l ^ "^" ^ pevs ign
  | EvBag (l, ign) -> "G" ^ pevs l ^ "^" ^ pevs ign
let pvst = function VStarted -> "Started" | VStopped -> "Stopped" | VSuspended -> "Suspended" | VAbsent -> "-" | VUnknown -> "?"
let pres = function
  | ROk -> "K" | RBool b -> if b then "B1" else "B0" | RExn c -> "E" ^ pc c | RSent d -> if d then "D1" else "D0"
let pobs (o : obs) =
  pres o.o_res ^ "/" ^ pevobs o.o_evs ^ "/" ^ pvst o.o_ctx ^ "/"
  ^ String.concat "," (List.map (fun (k, v) -> pc k ^ "=" ^ pvst v) o.o_st)
let pexp ((l, u) : (obs * string) list * string option) =
  String.concat " " (List.map (fun (o, _) -> pobs o) l @ (match u with None -> [] | Some w -> [ "U:" ^ pct w ]))
let pprog (p : prog) =
  String.concat " " (("A" ^ if p.p_auto then "1" else "0")
    :: List.map (fun r -> pc r.rd_id ^ ":" ^ (match r.rd_order with None -> "N" | Some z -> Big_int_Z.string_of_big_int z)
                          ^ ":" ^ if r.rd_auto then "1" else "0") p.p_routes)
let pop = function
  | OStart -> "start" | OStop -> "stop" | OSuspend -> "suspend" | OResume -> "resume"
  | OStartAll -> "startAll" | OStopAll -> "stopAll"
  | ORStart k -> "rstart." ^ pc k | ORStop k -> "rstop." ^ pc k | ORSuspend k -> "rsuspend." ^ pc k
  | ORResume k -> "rresume." ^ pc k | ORemove k -> "remove." ^ pc k
  | OSend (k, b) -> "send." ^ pc k ^ "." ^ if b then "1" else "0"

(* ---- generation ---- *)
let pick l = List.nth l (Random.int (List.length l))
let z = Big_int_Z.big_int_of_int
let zs s = Big_int_Z.big_int_of_string s

let gen_case fam : prog * op list =
  let nr = 1 + Random.int 4 in
  let ids =
    List.init nr (fun i ->
        if fam = "limits" && Random.int 3 = 0 then
          pick [ "r" ^ string_of_int i ^ String.make 60 'x'; "route-" ^ string_of_int i; "my.route_" ^ string_of_int i;
                 "R" ^ string_of_int i ]
        else "r" ^ string_of_int i) in
  let order () =
    if Random.int 2 = 0 then None
    else if fam = "limits" || (fam = "guided" && Random.bool ()) then
      Some (pick [ z 0; z (-1); z 1; z 999; z 1000; z 1001; z 1500; z 12345; zs "2147483647"; zs "-2147483648" ])
    else Some (z (pick [ 1; 2; 3; 5; 10; 999 ])) in
  let routes = List.map (fun i -> { rd_id = chars i; rd_order = order (); rd_auto = Random.int 5 > 0 }) ids in
  let p = { p_auto = Random.int 7 > 0; p_routes = routes } in
  let rid () = chars (if Random.int 10 = 0 then "zz" else pick ids) in
  let n = if fam = "ops" || fam = "guided" then 8 else 1 + Random.int 8 in
  let one () =
    match Random.int (if fam = "ops" then 22 else 26) with
    | 0 | 1 | 2 -> ORStart (rid ()) | 3 | 4 | 5 -> ORStop (rid ()) | 6 | 7 -> ORSuspend (rid ())
    | 8 | 9 -> ORResume (rid ()) | 10 | 11 -> ORemove (rid ()) | 12 | 13 | 14 | 15 -> OSend (rid (), Random.int 8 = 0)
    | 16 -> OStartAll | 17 -> OStopAll | 18 | 19 -> OSuspend | 20 | 21 -> OResume
    | 22 | 23 -> OStop | _ -> OStart in
  let ops =
    if fam = "guided" then
      (* guided: each operation is the first of up to 8 random candidates whose expected result (rules, Doc mode,
         sus=true) is not UNSPECIFIED; the rules are only asked, the driver adds no semantics *)
      let rec go acc k =
        if k = 0 then List.rev acc
        else
          let rec try_ c =
            let o = if acc = [] && Random.int 10 > 0 then OStart else one () in
            if c = 0 || snd (run_case false true p (List.rev (o :: acc))) = None then o else try_ (c - 1) in
          go (try_ 8 :: acc) (k - 1) in
      go [] n
    else List.init n (fun i -> if i = 0 && Random.int 10 > 0 then OStart else one ()) in
  (p, ops)

let hits : (string, int) Hashtbl.t = Hashtbl.create 64
let count_hits (l, _) =
  List.iter (fun (_, h) ->
      List.iter (fun r -> if r <> "" then Hashtbl.replace hits r (1 + try Hashtbl.find hits r with Not_found -> 0))
        (String.split_on_char ' ' h)) l

let () =
  let fam = Sys.argv.(1) and seed = int_of_string Sys.argv.(2) and count = int_of_string Sys.argv.(3) in
  let real = Sys.getenv_opt "MODE" = Some "real" in
  Random.init seed;
  for i = 1 to count do
    let p, ops = gen_case fam in
    let et = run_case real true p ops and ef = run_case real false p ops in
    count_hits et; count_hits ef;
    Printf.printf "%s-%d-%d\t%s\t%s\t%s\t%s\t%s\n" fam seed i (pprog p) (String.concat " " (List.map pop ops))
      (pexp et) (pexp ef) fam
  done;
  if Array.length Sys.argv > 4 then begin
    let oc = open_out Sys.argv.(4) in
    Hashtbl.iter (fun r n -> Printf.fprintf oc "%s\t%d\n" r n) hits;
    close_out oc
  end
