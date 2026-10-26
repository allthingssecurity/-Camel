(** * L0 Exchange: messages, headers, exchange properties, variables, the exchange pattern, the caught exception.

    Written from the documentation at the pin (PIN). Legend (paths under docs/):
      [MJ]   core/camel-api/src/main/java/org/apache/camel/Message.java (javadoc and @Metadata descriptions)
      [EXJ]  core/camel-api/src/main/java/org/apache/camel/Exchange.java
      [MSG]  core/camel-core-engine/src/main/docs/modules/eips/pages/message.adoc
      [EXA]  docs/user-manual/modules/ROOT/pages/exchange.adoc
      [EP]   docs/user-manual/modules/ROOT/pages/exchange-pattern.adoc
      [VAR]  docs/user-manual/modules/ROOT/pages/variables.adoc
      [UG23] docs/user-manual/modules/ROOT/pages/camel-4x-upgrade-guide-4_23.adoc
      [RHS]  core/camel-core-engine/src/main/docs/modules/eips/pages/removeHeaders-eip.adoc
      [RHD]  the @Metadata of RemoveHeadersDefinition.pattern (core-model, line 51; the generated model/removeHeaders.json
             drops its '*', see notes/main.md)
      [CCD]  ClaimCheckDefinition.java line 171 (core-model javadoc of the shared pattern-matching rule)
      [RVAR] core/camel-core-engine/src/main/docs/modules/eips/pages/removeVariable-eip.adoc

    Not modelled here: message ids and timestamps [MSG.18-25] (not observable by the harness), attachments, the
    deprecated OUT message (see L2 transform), stream bodies, custom HeadersMapFactory [MJ.31-34]. *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** Names

    The harness only builds names of printable ASCII. Case-insensitive comparison of other characters is not
    documented (Java's rules for non-ASCII case folding are outside the docs), so a header name outside printable
    ASCII makes the operation UNSPECIFIED; [ascii_name] is the guard the interpreter checks. *)
Definition ascii_name (k : chars) : bool := forallb (fun c => Nat.leb 32 (code c) && Nat.leb (code c) 126) k.
Definition ieq (a b : chars) : bool := ceqs (lower a) (lower b).

(** ** Results of L0 operations that may be UNSPECIFIED *)
Inductive r0 (A : Type) : Type := Ok0 (a : A) | Uns0 (why : string).
Arguments Ok0 {A} a.
Arguments Uns0 {A} why.

(** ** Headers

    A message holds a body and headers [MSG.14-17]. *)
(*! R L0.headers.ci DOC [MJ.31-34] [MJ.42] [MJ.150] [UG23.1823-1824] *)
(** Headers are a case-insensitive map [MJ.31-34]: looking a header up ignores the case of the name [MJ.42, MJ.150,
    UG23.1823]; absent means null [MJ.111-114]. *)
Fixpoint hget (k : chars) (hs : list (chars * val)) : val :=
  match hs with [] => VNull | (k', v) :: r => if ieq k k' then v else hget k r end.
Fixpoint hhas (k : chars) (hs : list (chars * val)) : bool :=
  match hs with [] => false | (k', _) :: r => ieq k k' || hhas k r end.

(*! R L0.headers.first-name-kept DOC [UG23.1818-1824] [MJ.231-232] *)
(** Setting a header that exists under another case replaces the value and keeps the first name it was set with
    [UG23.1823-1824]; iterating the headers gives the names in their original case [MJ.231-232]. The ORDER of the
    headers when iterated is not documented: the harness compares headers as a set of (name, value) pairs. *)
Fixpoint hset (k : chars) (v : val) (hs : list (chars * val)) : list (chars * val) :=
  match hs with
  | [] => [(k, v)]
  | (k', v') :: r => if ieq k k' then (k', v) :: r else (k', v') :: hset k v r
  end.

(*! R L0.headers.null-kept CODE DefaultMessage.setHeader *)
(** Setting a header to null: the docs do not say whether the name stays. Camel keeps it with a null value
    ([DefaultMessage.setHeader]: [getHeaders().put(name, value)], camel-support at the pin); adopted as a CODE rule
    (runs/first, 2026-10-26). Contrast properties and variables below. [hset] already keeps it. *)

(*! R L0.headers.remove DOC [MJ.194-197] [MJ.31-34] *)
(** Removing a header by name (case-insensitively, the map being case-insensitive). *)
Fixpoint hremove (k : chars) (hs : list (chars * val)) : list (chars * val) :=
  match hs with [] => [] | (k', v') :: r => if ieq k k' then hremove k r else (k', v') :: hremove k r end.

(** ** Name patterns (removeHeaders, removeProperties, removeVariable "*")

    [RHS.26-31]: "match by exact name; match by wildcard; match by regular expression", in that order; [RHD]: "exact
    match, wildcard (pattern ends with [star]), and regular expression (all case-insensitive)"; [CCD]: the wildcard matches
    when "pattern ends with a [star] and the name starts with the pattern". The regular-expression dialect is not
    documented (presumably java.util.regex): a pattern that is neither an exact name nor a wildcard and contains a
    regex metacharacter is UNSPECIFIED here. *)
Definition is_meta (c : ascii) : bool :=
  existsb (fun m => ceq c m) (str ".[]()+?^$|\{}").
(*! R L0.pattern.match DOC [RHS.26-31] [RHD] [CCD] *)
Definition pmatch (pat name : chars) : r0 bool :=
  if ieq pat name then Ok0 true
  else match rev pat with
       | "*"%char :: rp =>
           (* the wildcard: the name starts with the pattern without its '*', case-insensitively [RHD] *)
           let p := rev rp in
           if prefix (lower p) (lower name) then Ok0 true
           else if existsb is_meta p then Uns0 "RHS: wildcard pattern that is also a regex"
           else Ok0 false
       | _ => if existsb is_meta pat then Uns0 "RHS: regex dialect of name patterns not documented"
              else Ok0 false
       end.
(** Exclude patterns are comma separated [RHD: excludePattern]. *)
Fixpoint any_match (pats : list chars) (name : chars) : r0 bool :=
  match pats with
  | [] => Ok0 false
  | p :: r => match pmatch p name with
              | Ok0 true => Ok0 true
              | Ok0 false => any_match r name
              | Uns0 w => Uns0 w
              end
  end.
(*! R L0.headers.remove-pattern DOC [RHS.9-10] [RHS.26-31] [RHD] [MJ.214-219] *)
Fixpoint hremove_pat (pat : chars) (excl : list chars) (hs : list (chars * val)) : r0 (list (chars * val)) :=
  match hs with
  | [] => Ok0 []
  | (k, v) :: r =>
      match pmatch pat k, any_match excl k, hremove_pat pat excl r with
      | Ok0 m, Ok0 x, Ok0 r' => Ok0 (if m && negb x then r' else (k, v) :: r')
      | Uns0 w, _, _ | _, Uns0 w, _ | _, _, Uns0 w => Uns0 w
      end
  end.

(** ** Exchange properties and variables *)

(** Exchange properties are a map on the exchange [EXJ.33-34, EXJ.390-393, EXJ.451]. Unlike headers, the docs never
    call them case-insensitive; the rule below is the plain Map reading (exact names). *)
(*! R L0.props.exact DOC [EXJ.33-34] [EXJ.390-393] [EXJ.425] [EXJ.434-437] *)
Fixpoint pget (k : chars) (ps : list (chars * val)) : val :=
  match ps with [] => VNull | (k', v) :: r => if ceqs k k' then v else pget k r end.
Fixpoint pset (k : chars) (v : val) (ps : list (chars * val)) : list (chars * val) :=
  match ps with [] => [(k, v)] | (k', v') :: r => if ceqs k k' then (k', v) :: r else (k', v') :: pset k v r end.
Fixpoint premove (k : chars) (ps : list (chars * val)) : list (chars * val) :=
  match ps with [] => [] | (k', v') :: r => if ceqs k k' then premove k r else (k', v') :: premove k r end.
(*! R L0.props.null-removes CODE AbstractExchange.setProperty AbstractVariableRepository.setVariable *)
(** Setting a property or a variable to null: the docs only say "Sets a property" with a [@Nullable] value
    [EXJ.479-490, EXJ.592-594]. Camel removes the name ([AbstractExchange.setProperty], [AbstractVariableRepository.
    setVariable], the same in RouteVariableRepository and GroupVariableRepository, each with the comment "if the
    value is null, we just remove the key from the map"); adopted as a CODE rule (runs/first, 2026-10-26: 14 of 14
    mismatches). *)
Definition pput (k : chars) (v : val) (ps : list (chars * val)) : list (chars * val) :=
  match v with VNull => premove k ps | _ => pset k v ps end.

(** Variables [VAR.7-22]: by default private to the exchange [VAR.17, VAR.22]; a name [global:k] addresses the
    single context-wide repository [VAR.20, VAR.54-67], [route:id:k] the per-route one [VAR.79-95], [group:g:k] a
    named group [VAR.96-114]. The docs do not say whether variable names are case-sensitive: exact names here
    (Map reading), as for properties. *)
Inductive vscope : Type := VExchange | VGlobal | VRoute (rid : chars) | VGroup (g : chars).
Definition strip (p s : chars) : option chars := if prefix p s then Some (skipn (length p) s) else None.
Fixpoint split_colon (s : chars) : option (chars * chars) :=
  match s with
  | [] => None
  | c :: r => if ceq c ":"%char then Some ([], r)
              else match split_colon r with Some (a, b) => Some (c :: a, b) | None => None end
  end.
(*! R L0.vars.scope DOC [VAR.15-22] [VAR.54-67] [VAR.79-114] *)
Definition vname (k : chars) : r0 (vscope * chars) :=
  match strip (str "global:") k with
  | Some r => Ok0 (VGlobal, r)
  | None =>
  match strip (str "route:") k with
  | Some r => match split_colon r with Some (rid, n) => Ok0 (VRoute rid, n)
              | None => Uns0 "VAR: route: variable name without a route id" end
  | None =>
  match strip (str "group:") k with
  | Some r => match split_colon r with Some (g, n) => Ok0 (VGroup g, n)
              | None => Uns0 "VAR: group: variable name without a group" end
  | None =>
  match strip (str "header:") k with
  | Some _ => Uns0 "VAR: header: variables (received headers) are read-only and set by VariableReceive only [VAR.378-381]"
  | None => Ok0 (VExchange, k)
  end end end end.

(** ** Equality of values (helpers, no documentation content) *)
Fixpoint ceqsl (a b : list chars) : bool :=
  match a, b with [], [] => true | x :: a', y :: b' => ceqs x y && ceqsl a' b' | _, _ => false end.
Definition veqb (a b : val) : bool :=
  match a, b with
  | VNull, VNull => true
  | VStr x, VStr y => ceqs x y
  | VInt x, VInt y | VLong x, VLong y | VDbl x, VDbl y => Z.eqb x y
  | VBool x, VBool y => Bool.eqb x y
  | VList x, VList y => ceqsl x y
  | _, _ => false
  end.
Fixpoint kveqb (a b : list (chars * val)) : bool :=
  match a, b with
  | [], [] => true
  | (k, v) :: a', (k', v') :: b' => ceqs k k' && veqb v v' && kveqb a' b'
  | _, _ => false
  end.

(** ** Exceptions and the exchange pattern *)

(** A caught exception: its class name and message. The class hierarchy (for onException matching, L3) is a table
    in L3, not here. *)
(** An exception: class, message, cause, and the exceptions suppressed into it (Throwable.addSuppressed; the doFinally
    rule adds one [doTry-eip.adoc 227-229]). *)
Inductive exn : Type := mkExnS (cls : chars) (msg : chars) (cause : option exn) (suppressed : list exn).
Definition mkExn (c m : chars) (cause : option exn) : exn := mkExnS c m cause [].
Definition exn_class (e : exn) : chars := match e with mkExnS c _ _ _ => c end.
Definition exn_msg (e : exn) : chars := match e with mkExnS _ m _ _ => m end.
Definition exn_suppressed (e : exn) : list exn := match e with mkExnS _ _ _ s => s end.
Definition add_suppressed (e s : exn) : exn := match e with mkExnS c m k l => mkExnS c m k (l ++ [s]) end.
(** The exception and its causes, the root cause first (the order doCatch and onException match in [DT.212]). *)
Fixpoint exn_chain (e : exn) : list exn :=
  match e with mkExnS _ _ None _ => [e] | mkExnS _ _ (Some c) _ => exn_chain c ++ [e] end.

(** The class hierarchy of the exception classes the harness throws and catches. These are JDK facts (the Java SE API
    docs), not Camel documentation: an assumption of the harness, listed in TRUST.md (CONVENTIONS practice 6). A class
    outside the table makes a match UNSPECIFIED. *)
Definition jdk_super (c : chars) : option (option chars) :=
  let isc s := ceqs c (str s) in
  if isc "java.lang.Throwable" then Some None
  else if isc "java.lang.Exception" then Some (Some (str "java.lang.Throwable"))
  else if isc "java.lang.RuntimeException" then Some (Some (str "java.lang.Exception"))
  else if isc "java.io.IOException" then Some (Some (str "java.lang.Exception"))
  else if isc "java.lang.IllegalArgumentException" then Some (Some (str "java.lang.RuntimeException"))
  else if isc "java.lang.IllegalStateException" then Some (Some (str "java.lang.RuntimeException"))
  else if isc "java.lang.NumberFormatException" then Some (Some (str "java.lang.IllegalArgumentException"))
  else if isc "org.apache.camel.RuntimeCamelException" then Some (Some (str "java.lang.RuntimeException"))
                                                                     (* RuntimeCamelException.java:35 *)
  else if isc "org.apache.camel.TypeConversionException" then Some (Some (str "org.apache.camel.RuntimeCamelException"))
  else if isc "org.apache.camel.CamelException" then Some (Some (str "java.lang.Exception"))      (* CamelException.java:30 *)
  else if isc "org.apache.camel.CamelExchangeException" then Some (Some (str "org.apache.camel.CamelException"))
  else if isc "org.apache.camel.processor.aggregate.ClosedCorrelationKeyException"
    then Some (Some (str "org.apache.camel.CamelExchangeException"))   (* ClosedCorrelationKeyException.java:27 *)
                                                                         (* CamelExchangeException.java:32 *)
  else None.
(** [instance_of c t]: an exception of class [c] is an instance of [t]. *)
Fixpoint instance_of_f (fuel : nat) (c t : chars) : r0 bool :=
  match fuel with
  | O => Uns0 "L0: class hierarchy deeper than the table"
  | S f => if ceqs c t then match jdk_super t with Some _ => Ok0 true | None => Uns0 "L0: exception class outside the table" end
           else match jdk_super c with
                | None => Uns0 "L0: exception class outside the table"
                | Some None => match jdk_super t with Some _ => Ok0 false | None => Uns0 "L0: exception class outside the table" end
                | Some (Some p) => instance_of_f f p t
                end
  end.
Definition instance_of (c t : chars) : r0 bool := instance_of_f 10 c t.

(*! R L0.pattern.mep DOC [EP.12-17] [EXJ.49] *)
Inductive mep : Type := InOnly | InOut.

(** ** The exchange

    One message per exchange: [getMessage()] [MJ.40]. The exception that caused a failure is stored on the exchange
    [EXJ.36, EXJ.137]. The route-stop mark [stop-eip.adoc, EXJ setRouteStop] is a flag. Context-wide state
    (global/route/group variables) is not part of the exchange: see [gstate]. *)
Record message : Type := mkMsg { m_body : val; m_headers : list (chars * val) }.
(** Flags of the routing state, not of the message (the harness never prints them); [x_uow] is the unit of work's
    list of idempotent ids to remove "On completion ... if the Exchange failed" [idempotentConsumer-eip.adoc 18-19].
    Three flags:
    [x_eh]: the route's error handler is in use for the current step (false for the steps of a doTry block
    [doTry-eip.adoc 22-27, 223-225]); [x_seen]: the current exception has already been through an error handler or
    out of a doTry (it propagates without being handled again); [x_done]: an onException with handled(true) ended the
    routing ("the Exchange will succeed, but not continue being routed" [defaulterrorhandler.adoc 22-23]). *)
Record exchange : Type := mkX {
  x_msg : message;
  x_props : list (chars * val);
  x_vars : list (chars * val);
  x_mep : mep;
  x_exn : option exn;
  x_stop : bool;
  x_eh : bool;
  x_seen : bool;
  x_done : bool;
  x_uow : list (chars * chars);    (* ids this unit of work added to idempotent repositories: (node, key) *)
  x_orig : option message;         (* the original input message of the unit of work (dead-letter-channel.adoc 335-342); None: unknown *)
  x_route : chars;                 (* the id of the route the exchange is in (route scoped onException, exception-clause.adoc 152-161) *)
  x_cont : bool }.                  (* an exception was continued on this exchange (Real-mode delta of a finding, L2/Route.v) *)

(** An aggregation group: the aggregated exchange so far, how many exchanges it holds, and the incoming exchanges. *)
Record agroup : Type := mkAG { ag_x : exchange; ag_n : nat; ag_in : list exchange }.
(** Context-wide state: the global/route/group variable repositories [VAR.15-22], and per aggregator (by node id) its
    groups by correlation key and its closed keys (the aggregate EIP's default in-memory repository). *)
Record gstate : Type := mkG {
  g_global : list (chars * val);
  g_route : list (chars * list (chars * val));
  g_group : list (chars * list (chars * val));
  g_agg : list (chars * list (chars * agroup));
  g_closed : list (chars * list chars);
  g_cnt : list (chars * nat) }.   (* per node counters (round robin load balancer) *)
Definition g0 : gstate := mkG [] [] [] [] [] [].

Definition new_exchange (m : mep) (body : val) (hs : list (chars * val)) : exchange :=
  mkX (mkMsg body hs) [] [] m None false true false false [] (Some (mkMsg body hs)) [] false.

Definition set_route (x : exchange) (r : chars) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) r (x_cont x).
Definition set_cont (x : exchange) (b : bool) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) b.
Definition with_msg (x : exchange) (m : message) : exchange :=
  mkX m (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition set_body (x : exchange) (v : val) : exchange := with_msg x (mkMsg v (m_headers (x_msg x))).
Definition map_headers (f : list (chars * val) -> list (chars * val)) (x : exchange) : exchange :=
  with_msg x (mkMsg (m_body (x_msg x)) (f (m_headers (x_msg x)))).
Definition map_props (f : list (chars * val) -> list (chars * val)) (x : exchange) : exchange :=
  mkX (x_msg x) (f (x_props x)) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition map_vars (f : list (chars * val) -> list (chars * val)) (x : exchange) : exchange :=
  mkX (x_msg x) (x_props x) (f (x_vars x)) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
(** A new exception (or none): not seen by an error handler yet. *)
Definition set_exn (x : exchange) (e : option exn) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) e (x_stop x) (x_eh x) false (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition set_stop (x : exchange) (b : bool) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) b (x_eh x) (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition set_eh (x : exchange) (b : bool) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) b (x_seen x) (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition set_seen (x : exchange) (b : bool) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) b (x_done x) (x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition set_done (x : exchange) (b : bool) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) b (x_uow x) (x_orig x) (x_route x) (x_cont x).

Fixpoint aget (k : chars) (l : list (chars * list (chars * val))) : list (chars * val) :=
  match l with [] => [] | (k', v) :: r => if ceqs k k' then v else aget k r end.
Fixpoint aset (k : chars) (v : list (chars * val)) (l : list (chars * list (chars * val))) :=
  match l with [] => [(k, v)] | (k', v') :: r => if ceqs k k' then (k', v) :: r else (k', v') :: aset k v r end.

(** Reading and writing a variable in its scope. *)
Definition var_get (x : exchange) (g : gstate) (k : chars) : r0 val :=
  match vname k with
  | Uns0 w => Uns0 w
  | Ok0 (VExchange, n) => Ok0 (pget n (x_vars x))
  | Ok0 (VGlobal, n) => Ok0 (pget n (g_global g))
  | Ok0 (VRoute rid, n) => Ok0 (pget n (aget rid (g_route g)))
  | Ok0 (VGroup gr, n) => Ok0 (pget n (aget gr (g_group g)))
  end.
Definition var_set (x : exchange) (g : gstate) (k : chars) (v : val) : r0 (exchange * gstate) :=
  match vname k with
  | Uns0 w => Uns0 w
  | Ok0 (VExchange, n) => Ok0 (map_vars (pput n v) x, g)
  | Ok0 (VGlobal, n) => Ok0 (x, mkG (pput n v (g_global g)) (g_route g) (g_group g) (g_agg g) (g_closed g) (g_cnt g))
  | Ok0 (VRoute rid, n) => Ok0 (x, mkG (g_global g) (aset rid (pput n v (aget rid (g_route g))) (g_route g)) (g_group g) (g_agg g) (g_closed g) (g_cnt g))
  | Ok0 (VGroup gr, n) => Ok0 (x, mkG (g_global g) (g_route g) (aset gr (pput n v (aget gr (g_group g))) (g_group g)) (g_agg g) (g_closed g) (g_cnt g))
  end.
(*! R L0.vars.remove-all DOC [RVAR.64] *)
(** removeVariable with the name [*] removes all variables of the exchange [RVAR.64]. Other wildcard names are not
    documented for variables. *)
Definition var_remove (x : exchange) (g : gstate) (k : chars) : r0 (exchange * gstate) :=
  if ceqs k (str "*") then Ok0 (map_vars (fun _ => []) x, g)
  else if existsb (fun c => ceq c "*"%char) k then Uns0 "RVAR: wildcard variable names other than * not documented"
  else match vname k with
  | Uns0 w => Uns0 w
  | Ok0 (VExchange, n) => Ok0 (map_vars (premove n) x, g)
  | Ok0 (VGlobal, n) => Ok0 (x, mkG (premove n (g_global g)) (g_route g) (g_group g) (g_agg g) (g_closed g) (g_cnt g))
  | Ok0 (VRoute rid, n) => Ok0 (x, mkG (g_global g) (aset rid (premove n (aget rid (g_route g))) (g_route g)) (g_group g) (g_agg g) (g_closed g) (g_cnt g))
  | Ok0 (VGroup gr, n) => Ok0 (x, mkG (g_global g) (g_route g) (aset gr (premove n (aget gr (g_group g))) (g_group g)) (g_agg g) (g_closed g) (g_cnt g))
  end.

(** ** Documented examples *)
Example doc_header_lookup_ignores_case :
  hget (str "content-type") (hset (str "Content-Type") (VStr (str "text/plain")) []) = VStr (str "text/plain").
Proof. vm_compute. reflexivity. Qed.
(** [UG23.1823-1824]: set as [content-type], then as [Content-Type]: one header, under the first name. *)
Example doc_header_first_name_kept :
  hset (str "Content-Type") (VInt 2) (hset (str "content-type") (VInt 1) []) = [(str "content-type", VInt 2)].
Proof. vm_compute. reflexivity. Qed.
(** [RHS.74-76]: [Camel*] removes the headers that start with Camel. *)
Example doc_remove_camel_headers :
  hremove_pat (str "Camel*") [] [(str "CamelFileName", VInt 1); (str "foo", VInt 2)] = Ok0 [(str "foo", VInt 2)].
Proof. vm_compute. reflexivity. Qed.
(** [RHS.33-35]: [*] removes all headers. *)
Example doc_remove_all_headers :
  hremove_pat (str "*") [] [(str "a", VInt 1); (str "B", VInt 2)] = Ok0 [].
Proof. vm_compute. reflexivity. Qed.
(** [VAR.62-67]: [global:myGlobalKey] is set in the global repository, not on the exchange. *)
Example doc_global_variable :
  match var_set (new_exchange InOnly VNull []) g0 (str "global:myGlobalKey") (VInt 7) with
  | Ok0 (x, g) => (x_vars x, pget (str "myGlobalKey") (g_global g))
  | Uns0 _ => ([], VNull) end = ([], VInt 7).
Proof. vm_compute. reflexivity. Qed.
