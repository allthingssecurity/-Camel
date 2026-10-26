(** * L4 lifecycle: the CamelContext and its routes as a state machine over explicit operations.

    A case is a program (the context's autoStartup and 1-4 routes, each with an id, an optional startupOrder and an
    autoStartup flag; every route consumes from [direct:<id>]) and a list of operations: context start / stop /
    suspend / resume, RouteController startRoute / stopRoute / suspendRoute / resumeRoute / startAllRoutes /
    stopAllRoutes, CamelContext removeRoute, and a message sent to [direct:<id>]. After every operation the observable
    outcome is: the result (no exception, a boolean, an exception class, or whether the message reached the route),
    the route events fired during the operation (RouteStarted / RouteStopped / RouteRemoved, recorded by an
    EventNotifier), the context status, and the status of every route of the program.

    The readable rules are the relation [lstep] (one constructor per documented rule, each citing its doc lines) and
    [ltrace] (a list of operations). The function [step] computes them; [step_sound] and [run_sound] prove that what it
    returns is derivable from the rules, and [step_complete] that every derivation is what it returns (so the rules are
    deterministic for given [real] and [sus]). Where the docs are silent [step] answers [SUns why] and the rules have no
    case.

    [sus]: whether the route's consumer supports suspension. The docs say a route is suspended if its consumer
    supports it and stopped otherwise [RCJ.199-204], [LC.62-65], but not whether the [direct] consumer does
    ([DC] is silent). Both outcomes are allowed: the oracle prints the expected trace for [sus = true] and for
    [sus = false]; a case agrees when Camel matches one of them (the harness records which, CONVENTIONS practice 1).

    [real]: the Real mode (CONVENTIONS practice 2); every use of it is a delta naming its finding file.

    Legend (paths under docs/):
      [LC]   docs/user-manual/modules/ROOT/pages/lifecycle.adoc
      [CFG]  docs/user-manual/modules/ROOT/pages/configuring-route-startup-ordering-and-autostartup.adoc
      [GS]   docs/user-manual/modules/ROOT/pages/graceful-shutdown.adoc
      [EN]   docs/user-manual/modules/ROOT/pages/event-notifier.adoc
      [CTX]  docs/user-manual/modules/ROOT/pages/camelcontext.adoc
      [RCJ]  core/camel-api/src/main/java/org/apache/camel/spi/RouteController.java
      [CCJ]  core/camel-api/src/main/java/org/apache/camel/CamelContext.java
      [CLJ]  core/camel-api/src/main/java/org/apache/camel/CamelContextLifecycle.java
      [RTJ]  core/camel-api/src/main/java/org/apache/camel/RuntimeConfiguration.java
      [SSJ]  core/camel-api/src/main/java/org/apache/camel/ServiceStatus.java
      [FSJ]  core/camel-api/src/main/java/org/apache/camel/FailedToStartRouteException.java
      [SDJ]  core/camel-api/src/main/java/org/apache/camel/spi/ShutdownStrategy.java
      [CEJ]  core/camel-api/src/main/java/org/apache/camel/spi/CamelEvent.java
      [RSJ]  core/camel-api/src/main/java/org/apache/camel/spi/RouteStartupOrder.java
      [DC]   components/camel-direct/src/main/docs/direct-component.adoc
      [DJ]   component-json/direct.json *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** Programs and operations *)

(** A route: its id (unique [CTX.44]), its startupOrder (an Integer [CFG.177-178]; [None]: not set) and its autoStartup
    (default true [CFG.58-59]). *)
Record rdef : Type := mkR { rd_id : chars; rd_order : option Z; rd_auto : bool }.
(** The context's autoStartup [CFG.13-16, RTJ.195-203] and the routes in the order they are defined. *)
Record prog : Type := mkP { p_auto : bool; p_routes : list rdef }.

Inductive op : Type :=
| OStart | OStop | OSuspend | OResume                    (* CamelContext [CLJ.36-53, CLJ.118-126] *)
| ORStart (id : chars) | ORStop (id : chars)              (* RouteController [RCJ.144-159] *)
| ORSuspend (id : chars) | ORResume (id : chars)          (* RouteController [RCJ.196-236] *)
| ORemove (id : chars)                                    (* CamelContext.removeRoute [CCJ.676-699] *)
| OStartAll | OStopAll                                    (* RouteController [RCJ.87-99] *)
| OSend (id : chars) (block : bool).                      (* a message to direct:<id> (block=false, or block=true
                                                             with a short timeout) [DJ.44-46] *)

(** ** State *)

(** The context: [CNew] (built, not started), started, suspended, stopped, or [CFailed] (its start failed; what state
    it is in then is not documented). *)
Inductive cstat : Type := CNew | CStarted | CSuspended | CStopped | CFailed.

(** A route: [RNew] never started (its status is not documented), started, stopped, [RSusStop] (stopped by a
    suspendRoute because it does not support suspension: [sus = false]), suspended, [RCtxSusp] (suspended, or
    stopped when [sus = false], by the context's suspend), removed, or [RUnk] (not documented). *)
Inductive rstat : Type := RNew | RStarted | RStopped | RSusStop | RSuspended | RCtxSusp | RGone | RUnk.

(** [s_nums]: the startup order number of every route started so far (and not removed), sorted by number: the order
    the stop rules reverse. [s_next]: the next number to auto-assign (used by the Real mode only). *)
Record st : Type := mkS { s_ctx : cstat; s_rs : list (chars * rstat); s_nums : list (chars * Z); s_next : Z }.

Definition init (P : prog) : st := mkS CNew (map (fun r => (rd_id r, RNew)) (p_routes P)) [] 1000.

(** ** Observations *)

(** Route events [CEJ.541-558, CEJ.508] (the EventNotifier [EN.3]). [EvSeq l ign]: the events are exactly [l] in
    this order once every event in [ign] (not documented there; it may occur or not) is dropped. [EvBag]: the same
    but in any order. [EvAny]: not documented. *)
Inductive ev : Type := EStarted (id : chars) | EStopped (id : chars) | ERemoved (id : chars).
Inductive evobs : Type := EvSeq (l ign : list ev) | EvBag (l ign : list ev) | EvAny.

(** The result of an operation: no exception, a boolean (removeRoute), an exception class, or for a message whether
    it reached the route ([true]) or failed with an exception, whose class is not documented ([false]). *)
Inductive ores : Type := ROk | RBool (b : bool) | RExn (cls : chars) | RSent (delivered : bool).

(** Statuses as observed: ServiceStatus names [SSJ.31-47], [VAbsent] (CamelContext.getRoute gives null [CCJ.612-616])
    and [VUnknown] (not documented, not compared). *)
Inductive vst : Type := VStarted | VStopped | VSuspended | VAbsent | VUnknown.
Record obs : Type := mkO { o_res : ores; o_evs : evobs; o_ctx : vst; o_st : list (chars * vst) }.

(*! R L4.status.context DOC [CLJ.142-147] [SSJ.31-47] [CCJ.75-80] *)
(** The context is Started after start, Suspended after suspend, Stopped after stop; before its first start and after
    a failed start its status is not documented. *)
Definition vctx (c : cstat) : vst :=
  match c with CStarted => VStarted | CStopped => VStopped | CSuspended => VSuspended | _ => VUnknown end.
(*! R L4.status.route DOC [RCJ.136-142] [SSJ.31-47] [RCJ.199-204] [CCJ.612-616] [CCJ.677] *)
(** A route that a stop / suspend-without-support made stopped is Stopped [RCJ.204]; a suspended one Suspended; a
    removed one is gone (getRoute is null); a route that was never started has no documented status. *)
Definition vroute (sus : bool) (r : rstat) : vst :=
  match r with
  | RStarted => VStarted
  | RStopped | RSusStop => VStopped
  | RSuspended => VSuspended
  | RCtxSusp => if sus then VSuspended else VStopped
  | RGone => VAbsent
  | RNew | RUnk => VUnknown
  end.
Definition observe (sus : bool) (r : ores) (e : evobs) (s : st) : obs :=
  mkO r e (vctx (s_ctx s)) (map (fun '(k, w) => (k, vroute sus w)) (s_rs s)).

(** ** Helpers (no documentation content) *)

Fixpoint rget (id : chars) (l : list (chars * rstat)) : option rstat :=
  match l with [] => None | (k, v) :: t => if ceqs k id then Some v else rget id t end.
Definition rmap (f : chars -> rstat -> rstat) (l : list (chars * rstat)) : list (chars * rstat) :=
  map (fun '(k, w) => (k, f k w)) l.
Definition rset (id : chars) (v : rstat) (l : list (chars * rstat)) : list (chars * rstat) :=
  rmap (fun k w => if ceqs k id then v else w) l.
Definition mark (ids : list chars) (v : rstat) (l : list (chars * rstat)) : list (chars * rstat) :=
  rmap (fun k w => if existsb (ceqs k) ids then v else w) l.
Definition is_gone (r : rstat) : bool := match r with RGone => true | _ => false end.
Definition is_started (r : rstat) : bool := match r with RStarted => true | _ => false end.
(** Started or suspended: what a stop stops. *)
Definition running (r : rstat) : bool := match r with RStarted | RSuspended => true | _ => false end.
(** Not started and not suspended: what a start starts. *)
Definition idle (r : rstat) : bool := match r with RNew | RStopped | RSusStop => true | _ => false end.
Definition stopped_r (r : rstat) : bool := match r with RStopped | RSusStop => true | _ => false end.
Definition blocked (r : rstat) : bool := match r with RSuspended | RCtxSusp | RUnk => true | _ => false end.
Definition no_consumer (r : option rstat) : bool :=
  match r with None | Some (RNew | RStopped | RSusStop | RGone) => true | _ => false end.
Fixpoint nodup_ids (l : list chars) : bool :=
  match l with [] => true | x :: t => negb (existsb (ceqs x) t) && nodup_ids t end.
Definition stat_is (s : st) (f : rstat -> bool) (k : chars) : bool :=
  match rget k (s_rs s) with Some w => f w | None => false end.
Definition ids_with (f : rstat -> bool) (s : st) : list chars := map fst (filter (fun '(_, w) => f w) (s_rs s)).
Fixpoint zget (id : chars) (l : list (chars * Z)) : option Z :=
  match l with [] => None | (k, v) :: t => if ceqs k id then Some v else zget id t end.
Definition listed (id : chars) (l : list (chars * Z)) : bool := existsb (fun '(k, _) => ceqs k id) l.
Definition unlist (id : chars) (l : list (chars * Z)) : list (chars * Z) := filter (fun '(k, _) => negb (ceqs k id)) l.
Fixpoint insert (x : chars * Z) (l : list (chars * Z)) : list (chars * Z) :=
  match l with [] => [x] | y :: t => if Z.leb (snd x) (snd y) then x :: y :: t else y :: insert x t end.
Definition list_num (l : list (chars * Z)) (x : chars * Z) : list (chars * Z) := if listed (fst x) l then l else insert x l.

(** ** Startup order *)

(*! R L4.order.auto-assign DOC [CFG.188-191] [CFG.339-342] [CFG.429-434] *)
(** "routes without an explicit startupOrder definition will have a number starting from 1000 auto assigned"
    [CFG.188-190]; the examples [CFG.339-342, CFG.429-434] assign them in the order the routes are defined: 1000,
    1001, ... One number per route (Real mode: [L4.order.renumber.real]). *)
Fixpoint assign (n : Z) (rs : list rdef) : list (chars * Z) :=
  match rs with
  | [] => []
  | r :: t => match rd_order r with
              | Some z => (rd_id r, z) :: assign n t
              | None => (rd_id r, n) :: assign (n + 1) t
              end
  end.
Definition nauto (P : prog) : Z :=
  Z.of_nat (length (filter (fun r => match rd_order r with None => true | _ => false end) (p_routes P))).
(** An explicit startupOrder equal to an auto-assigned number: the docs warn about such collisions [CFG.193-196]
    but do not say what happens (UNSPECIFIED). *)
Definition collision (P : prog) : bool :=
  existsb (fun r => match rd_order r with
                    | Some z => Z.leb 1000 z && Z.ltb z (Z.add 1000 (nauto P))
                    | None => false end) (p_routes P).
(** The routes whose explicit startupOrder another route also has [CFG.183-186]. *)
Definition clashing (P : prog) : list chars :=
  map rd_id (filter (fun r => match rd_order r with
                              | Some z => Nat.ltb 1 (length (filter (fun q => match rd_order q with
                                                                               | Some z' => Z.eqb z z'
                                                                               | None => false end) (p_routes P)))
                              | None => false end) (p_routes P)).
(*! R L4.order.sort DOC [CFG.177-181] [RCJ.33-34] [RSJ.29-31] *)
(** "Camel then sorts the routes before starting time. The routes with the lowest startupOrder are started first,
    and the ones with the highest are started last" [CFG.179-181]. *)
Definition sorted_pairs (P : prog) : list (chars * Z) := fold_right insert [] (assign 1000 (p_routes P)).
Definition auto_of (P : prog) (id : chars) : bool := existsb (fun r => ceqs (rd_id r) id && rd_auto r) (p_routes P).
(*! R L4.autoStartup DOC [CFG.10-16] [CFG.38-40] [CFG.58-59] [RTJ.195-203] *)
(** The routes a context start starts: none when the context's autoStartup is false ("that takes precedence and
    no routes is started" [RTJ.198-199]), else those whose own autoStartup is true [CFG.58-59], in startup order. *)
Definition start_pairs (P : prog) : list (chars * Z) :=
  if p_auto P then filter (fun x => auto_of P (fst x)) (sorted_pairs P) else [].
Definition to_start (P : prog) : list chars := map fst (start_pairs P).
Definition fixed_num (P : prog) (id : chars) : Z := match zget id (assign 1000 (p_routes P)) with Some z => z | None => 0 end.
Definition explicit (P : prog) (id : chars) : option Z :=
  match List.find (fun r => ceqs (rd_id r) id) (p_routes P) with Some r => rd_order r | None => None end.

(*! R L4.order.renumber.real CODE findings/2026-10-26-l4-startuporder-renumbered-on-restart.md *)
(** Real mode: a route without a startupOrder gets a NEW number (the context's counter, from 1000, incremented on
    every start or resume of such a route: InternalRouteStartupManager.doPrepareRouteToBeStarted) each time it is
    started; the number kept for the stop order is the one of its first start, the new one is checked for a clash
    against every route started before (also stopped ones) and against the routes started with it. Doc mode: the one
    number of [assign]. *)
Definition prep (real : bool) (P : prog) (nx : Z) (id : chars) : Z * Z :=
  match explicit P id with
  | Some z => (z, nx)
  | None => if real then (nx, Z.add nx 1) else (fixed_num P id, nx)
  end.
Fixpoint prep_all (real : bool) (P : prog) (nx : Z) (ids : list chars) : list (chars * Z) * Z :=
  match ids with
  | [] => ([], nx)
  | i :: t => let '(n, nx1) := prep real P nx i in let '(l, nx2) := prep_all real P nx1 t in ((i, n) :: l, nx2)
  end.
Definition clash_with (x : chars * Z) (l : list (chars * Z)) : bool :=
  existsb (fun '(k, z) => negb (ceqs k (fst x)) && Z.eqb z (snd x)) l.
Fixpoint batch_clash (l nums : list (chars * Z)) : bool :=
  match l with [] => false | x :: t => clash_with x nums || clash_with x t || batch_clash t nums end.
Definition count_auto (P : prog) (ids : list chars) : Z :=
  Z.of_nat (length (filter (fun i => match explicit P i with None => true | _ => false end) ids)).
(** Real mode: a context suspend / resume also takes a number for each such route it suspends / resumes. *)
Definition adv (real : bool) (P : prog) (ids : list chars) : Z := if real then count_auto P ids else 0.

(** ** Post-states and events *)

(*! R L4.stop.reverse-order DOC-BUG [CFG.209] [CFG.436-438] [GS.16-18] [GS.136-140] [SDJ.31-34] [RSJ.29-31] *)
(** "Apache Camel will stop the routes in the reverse order that they were started" [CFG.209]: Camel stops them in
    the reverse order of their startup order numbers ("You can configure the order in which routes should be
    started, and thus also the same order they are being shutdown" [GS.138-139]; DefaultShutdownStrategy and
    stopAllRoutes sort by RouteStartupOrder.getStartupOrder, reversed, as RouteShutdownReverseOrderTest pins), not in
    the reverse of the order of the start operations: the two differ once a route is started on its own after the
    context start (DOC-BUG 2026-10-26, notes/l4.md; was: reverse chronological order). *)
Definition stop_seq (s : st) (f : rstat -> bool) : list ev :=
  rev (map EStopped (filter (stat_is s f) (map fst (s_nums s)))).
Definition run_ctx (sus : bool) (r : rstat) : bool := match r with RStarted | RSuspended => true | RCtxSusp => sus | _ => false end.
(** A stop of all routes also "stops" the routes that are not running: whether that fires a RouteStoppedEvent
    ("Fired when a route has been stopped" [CEJ.557]) is not documented, so those events are ignored. *)
Definition idle_ign (f : rstat -> bool) (s : st) : list ev := map EStopped (ids_with (fun w => negb (f w) && negb (is_gone w)) s).
(*! R L4.ctx.stop.cleared FIX [CLJ.45-47] [CCJ.77-78] [LC.29-32] *)
(** The context's stop "will stop all routes/components/endpoints etc. and clear internal state/cache" [CCJ.77-78]:
    whether the routes are still there afterwards (and with which status) is not documented, nor whether a
    RouteRemovedEvent fires for them (FIX 2026-10-26: was "Stopped"; Camel removes them, runs/l4-try). *)
Definition ctx_stopped_state (s : st) : st :=
  mkS CStopped (rmap (fun _ w => if is_gone w then RGone else RUnk) (s_rs s)) [] (s_next s).
Definition removed_ign (s : st) : list ev := map ERemoved (ids_with (fun w => negb (is_gone w)) s).
Definition failed_state (s : st) : st := mkS CFailed (rmap (fun _ _ => RUnk) (s_rs s)) [] (s_next s).
Definition set_route (s : st) (id : chars) (v : rstat) : st := mkS (s_ctx s) (rset id v (s_rs s)) (s_nums s) (s_next s).
Definition susp_rs (s : st) : list (chars * rstat) := rmap (fun _ w => if is_started w then RCtxSusp else w) (s_rs s).
(** Context resume: the routes the suspend suspended are started again; what happens to the others is not
    documented ([RUnk]; their events are ignored). *)
Definition wake (s : st) : list chars := ids_with (fun w => match w with RCtxSusp => true | _ => false end) s.
Definition unk_ids (s : st) : list chars := ids_with (fun w => match w with RCtxSusp | RGone => false | _ => true end) s.
Definition resume_rs (s : st) : list (chars * rstat) :=
  rmap (fun _ w => match w with RCtxSusp => RStarted | RGone => RGone | _ => RUnk end) (s_rs s).
Definition unk_ign (s : st) : list ev := flat_map (fun k => [EStarted k; EStopped k]) (unk_ids s).
Definition stop_all_rs (s : st) : list (chars * rstat) := rmap (fun _ w => if is_gone w then RGone else RStopped) (s_rs s).
Definition FTSRE : chars := str "org.apache.camel.FailedToStartRouteException".
Definition ctx_running (c : cstat) : bool := match c with CStarted | CSuspended => true | _ => false end.
(** The routes startAllRoutes starts, in the order they are defined. *)
Definition idle_ids (P : prog) (s : st) : list chars := filter (stat_is s idle) (map rd_id (p_routes P)).

(** ** The rules *)

Inductive lstep (real sus : bool) (P : prog) : st -> op -> ores -> evobs -> st -> Prop :=
(*! R L4.ctx.start DOC [LC.10-13] [CFG.177-181] [CFG.58-59] [RTJ.198-199] [CLJ.36-43] [CEJ.541] *)
(** Starting the context starts the routes to start ([to_start]) in startup order, one RouteStartedEvent each. *)
| LStart : forall s, s_ctx s = CNew -> collision P = false -> clashing P = [] ->
    lstep real sus P s OStart ROk (EvSeq (map EStarted (to_start P)) [])
      (mkS CStarted (mark (to_start P) RStarted (s_rs s)) (start_pairs P) (Z.add 1000 (nauto P)))
(*! R L4.ctx.start.clash FIX [CFG.183-186] [FSJ.24-25] *)
(** "All startupOrder defined must be unique among all routes in your CamelContext. Otherwise, if there are clashes
    in startupOrder numbers among routes, the routes will fail to start up throwing
    org.apache.camel.FailedToStartRouteException" [CFG.183-186]: among ALL routes, also those with autoStartup=false
    (FIX 2026-10-26: was only when every clashing route is auto-started, a misreading of "among all routes"). When
    the context's autoStartup is false no route starts up, and when such a clash fails is not documented
    (UNSPECIFIED). *)
| LStartClash : forall s, s_ctx s = CNew -> collision P = false -> clashing P <> [] -> p_auto P = true ->
    lstep real sus P s OStart (RExn FTSRE) EvAny (failed_state s)
(*! R L4.ctx.stop DOC [CLJ.45-53] [CCJ.77-78] [LC.29-32] [CFG.209] [GS.16-18] *)
(** Stopping the context "will stop all routes" [CLJ.46], in the reverse startup order [L4.stop.reverse-order]. *)
| LStop : forall s, ctx_running (s_ctx s) = true ->
    lstep real sus P s OStop ROk (EvSeq (stop_seq s (run_ctx sus)) (idle_ign (run_ctx sus) s ++ removed_ign s))
      (ctx_stopped_state s)
(*! R L4.ctx.suspend DOC [CCJ.79] [CCJ.83-84] [LC.39-42] [RCJ.199-204] *)
(** Suspending the context suspends the started routes ("only suspend/stop routes using the same Graceful
    Shutdown" [LC.39-41]): suspended if they support it (no route event: there is no route suspended event
    [CEJ.489-558]), otherwise stopped, in the reverse startup order. *)
| LSuspendS : forall s, s_ctx s = CStarted -> sus = true ->
    lstep real sus P s OSuspend ROk (EvSeq [] [])
      (mkS CSuspended (susp_rs s) (s_nums s) (Z.add (s_next s) (adv real P (ids_with is_started s))))
| LSuspendN : forall s, s_ctx s = CStarted -> sus = false ->
    lstep real sus P s OSuspend ROk (EvSeq (stop_seq s is_started) [])
      (mkS CSuspended (susp_rs s) (s_nums s) (Z.add (s_next s) (adv real P (ids_with is_started s))))
(*! R L4.ctx.resume DOC [CCJ.80] [CLJ.123-126] [LC.39-42] [RCJ.229-231] *)
(** Resuming the context ("to resume after a suspended execution" [CCJ.80]) starts the routes its suspend
    suspended again (without events when they were suspended; with RouteStartedEvents, order not documented, when
    they were stopped instead [RCJ.231]). *)
| LResumeS : forall s, s_ctx s = CSuspended -> sus = true ->
    lstep real sus P s OResume ROk (EvSeq [] (unk_ign s)) (mkS CStarted (resume_rs s) (s_nums s) (Z.add (s_next s) (adv real P (wake s))))
| LResumeN : forall s, s_ctx s = CSuspended -> sus = false ->
    lstep real sus P s OResume ROk (EvBag (map EStarted (wake s)) (unk_ign s))
      (mkS CStarted (resume_rs s) (s_nums s) (Z.add (s_next s) (adv real P (wake s))))
(*! R L4.route.start DOC [RCJ.144-150] [RTJ.199-201] [CFG.36-52] [CEJ.541] *)
(** startRoute starts a route that was stopped or never started (the way to start a route that was not
    auto-started [RTJ.199-201]). *)
| LRStart : forall s id r n nx, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> idle r = true ->
    prep real P (s_next s) id = (n, nx) -> real && clash_with (id, n) (s_nums s) = false ->
    lstep real sus P s (ORStart id) ROk (EvSeq [EStarted id] [])
      (mkS CStarted (rset id RStarted (s_rs s)) (list_num (s_nums s) (id, n)) nx)
(*! R L4.route.start.clash.real CODE findings/2026-10-26-l4-startuporder-renumbered-on-restart.md *)
| LRStartClash : forall s id r n nx, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> idle r = true ->
    prep real P (s_next s) id = (n, nx) -> real && clash_with (id, n) (s_nums s) = true ->
    lstep real sus P s (ORStart id) (RExn FTSRE) EvAny (mkS CStarted (rset id RUnk (s_rs s)) (s_nums s) nx)
(*! R L4.route.stop DOC [RCJ.152-159] [GS.184-192] [CEJ.557] *)
| LRStop : forall s id r, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> running r = true ->
    lstep real sus P s (ORStop id) ROk (EvSeq [EStopped id] []) (set_route s id RStopped)
(*! R L4.route.stop.idle DOC [RCJ.152-159] [CEJ.557] *)
(** stopRoute of a route that is not running leaves it stopped; whether an event fires is not documented. *)
| LRStopIdle : forall s id r, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> idle r = true ->
    lstep real sus P s (ORStop id) ROk (EvSeq [] [EStopped id]) (set_route s id RStopped)
(*! R L4.route.suspend DOC [RCJ.196-209] [LC.62-65] *)
(** suspendRoute of a started route: suspended if the route supports it, "If the route does not support
    suspension the route will be stopped instead" [RCJ.204]. *)
| LRSuspendS : forall s id, s_ctx s = CStarted -> rget id (s_rs s) = Some RStarted -> sus = true ->
    lstep real sus P s (ORSuspend id) ROk (EvSeq [] []) (set_route s id RSuspended)
| LRSuspendN : forall s id, s_ctx s = CStarted -> rget id (s_rs s) = Some RStarted -> sus = false ->
    lstep real sus P s (ORSuspend id) ROk (EvSeq [EStopped id] []) (set_route s id RSusStop)
(*! R L4.route.resume DOC [RCJ.228-236] *)
(** resumeRoute "Resumes the given route if it has been previously suspended"; "If the route does not support
    suspension the route will be started instead" [RCJ.229-231]. Whether resuming fires a RouteStartedEvent is not
    documented (ignored). *)
| LRResumeS : forall s id, s_ctx s = CStarted -> rget id (s_rs s) = Some RSuspended -> sus = true ->
    lstep real sus P s (ORResume id) ROk (EvSeq [] [EStarted id])
      (mkS CStarted (rset id RStarted (s_rs s)) (s_nums s) (Z.add (s_next s) (adv real P [id])))
| LRResumeN : forall s id n nx, s_ctx s = CStarted -> rget id (s_rs s) = Some RSusStop -> sus = false ->
    prep real P (s_next s) id = (n, nx) -> real && clash_with (id, n) (s_nums s) = false ->
    lstep real sus P s (ORResume id) ROk (EvSeq [EStarted id] [])
      (mkS CStarted (rset id RStarted (s_rs s)) (list_num (s_nums s) (id, n)) nx)
| LRResumeNClash : forall s id n nx, s_ctx s = CStarted -> rget id (s_rs s) = Some RSusStop -> sus = false ->
    prep real P (s_next s) id = (n, nx) -> real && clash_with (id, n) (s_nums s) = true ->
    lstep real sus P s (ORResume id) (RExn FTSRE) EvAny (mkS CStarted (rset id RUnk (s_rs s)) (s_nums s) nx)
(*! R L4.route.remove DOC [CCJ.676-699] [CEJ.508] *)
(** removeRoute: "the route must be stopped before it can be removed"; true if removed, false "if the route could not
    be removed because it's not stopped" [CCJ.677, CCJ.695-696]. A removed route fires RouteRemovedEvent. *)
| LRemove : forall s id r, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> stopped_r r = true ->
    lstep real sus P s (ORemove id) (RBool true) (EvSeq [ERemoved id] [EStopped id])
      (mkS CStarted (rset id RGone (s_rs s)) (unlist id (s_nums s)) (s_next s))
| LRemoveNo : forall s id r, s_ctx s = CStarted -> rget id (s_rs s) = Some r -> running r = true ->
    lstep real sus P s (ORemove id) (RBool false) (EvSeq [] []) s
(*! R L4.rc.startAll DOC [RCJ.87-92] [RCJ.33-34] [CFG.50-51] *)
(** startAllRoutes "Starts all the routes which currently is not started" [RCJ.88], in startup order [RCJ.33-34]
    (UNSPECIFIED when a route is suspended: is it "not started"?). *)
| LStartAll : forall s prs nx, s_ctx s = CStarted -> existsb (fun '(_, w) => blocked w) (s_rs s) = false ->
    prep_all real P (s_next s) (idle_ids P s) = (prs, nx) -> real && batch_clash prs (s_nums s) = false ->
    lstep real sus P s OStartAll ROk (EvSeq (map EStarted (map fst (fold_right insert [] prs))) [])
      (mkS CStarted (mark (idle_ids P s) RStarted (s_rs s)) (fold_left list_num prs (s_nums s)) nx)
(*! R L4.rc.startAll.clash.real CODE findings/2026-10-26-l4-startuporder-renumbered-on-restart.md *)
| LStartAllClash : forall s prs nx, s_ctx s = CStarted -> existsb (fun '(_, w) => blocked w) (s_rs s) = false ->
    prep_all real P (s_next s) (idle_ids P s) = (prs, nx) -> real && batch_clash prs (s_nums s) = true ->
    lstep real sus P s OStartAll (RExn FTSRE) EvAny (mkS CStarted (mark (idle_ids P s) RUnk (s_rs s)) (s_nums s) nx)
(*! R L4.rc.stopAll DOC [RCJ.94-99] [CFG.209] *)
| LStopAll : forall s, s_ctx s = CStarted ->
    lstep real sus P s OStopAll ROk (EvSeq (stop_seq s running) (idle_ign running s))
      (mkS CStarted (stop_all_rs s) (s_nums s) (s_next s))
(*! R L4.send.started DOC [DC.16-19] *)
(** A message to a started route is routed by it ("direct, synchronous invocation of any consumers" [DC.16-17]). *)
| LSendOk : forall s id b, s_ctx s = CStarted -> rget id (s_rs s) = Some RStarted ->
    lstep real sus P s (OSend id b) (RSent true) (EvSeq [] []) s
(*! R L4.send.no-consumer DOC [DJ.44-46] *)
(** A message to direct:<id> with no active consumer (the route is not started, removed, or unknown) fails with an
    exception: failIfNoConsumers defaults to true [DJ.45]; with block=true it first waits for the timeout [DJ.44,46]. *)
| LSendNone : forall s id b, s_ctx s = CStarted -> no_consumer (rget id (s_rs s)) = true ->
    lstep real sus P s (OSend id b) (RSent false) (EvSeq [] []) s.

Inductive ltrace (real sus : bool) (P : prog) : st -> list op -> list obs -> st -> Prop :=
| LTNil : forall s, ltrace real sus P s [] [] s
| LTCons : forall s o r e s1 os obs s2, lstep real sus P s o r e s1 -> ltrace real sus P s1 os obs s2 ->
    ltrace real sus P s (o :: os) (observe sus r e s1 :: obs) s2.

(** ** The interpreter *)

Inductive sres : Type := SOk (r : ores) (e : evobs) (s' : st) (hit : string) | SUns (why : string).

Definition route_op (s : st) (id : chars) (k : rstat -> sres) : sres :=
  match s_ctx s with
  | CStarted =>
      match rget id (s_rs s) with
      | None | Some RGone => SUns "RCJ: an operation on a route id that is unknown or removed: not documented"
      | Some RUnk => SUns "LC: a route whose status is not documented here (after a context resume or a failed start)"
      | Some r => k r
      end
  | _ => SUns "RCJ: a route operation while the context is not started: not documented"
  end.

(** Starting one route (startRoute, and resumeRoute of a route that was stopped instead of suspended). *)
Definition start1 (real : bool) (P : prog) (s : st) (id : chars) (hit : string) : sres :=
  let '(n, nx) := prep real P (s_next s) id in
  if real && clash_with (id, n) (s_nums s)
  then SOk (RExn FTSRE) EvAny (mkS CStarted (rset id RUnk (s_rs s)) (s_nums s) nx) "L4.route.start.clash.real"
  else SOk ROk (EvSeq [EStarted id] []) (mkS CStarted (rset id RStarted (s_rs s)) (list_num (s_nums s) (id, n)) nx)
         (match explicit P id with None => if real then String.append hit " L4.order.renumber.real" else hit | Some _ => hit end).

Definition step (real sus : bool) (P : prog) (s : st) (o : op) : sres :=
  match o with
  | OStart =>
      match s_ctx s with
      | CNew =>
          if collision P then SUns "CFG: an explicit startupOrder equal to an auto-assigned one (from 1000): not documented"
          else match clashing P with
               | [] => SOk ROk (EvSeq (map EStarted (to_start P)) [])
                         (mkS CStarted (mark (to_start P) RStarted (s_rs s)) (start_pairs P) (Z.add 1000 (nauto P))) "L4.ctx.start L4.order.auto-assign L4.order.sort L4.autoStartup"
               | _ :: _ =>
                   if p_auto P
                   then SOk (RExn FTSRE) EvAny (failed_state s) "L4.ctx.start.clash"
                   else SUns "CFG: a startupOrder clash while the context's autoStartup is false: when it fails is not documented"
               end
      | CStopped => SUns "LC: start after stop is a cold start that is not guaranteed to work [LC.37-38]"
      | CFailed => SUns "LC: the state after a failed start is not documented"
      | _ => SUns "CLJ: start of a started or suspended context: not documented"
      end
  | OStop =>
      if ctx_running (s_ctx s)
      then SOk ROk (EvSeq (stop_seq s (run_ctx sus)) (idle_ign (run_ctx sus) s ++ removed_ign s)) (ctx_stopped_state s) "L4.ctx.stop L4.stop.reverse-order L4.ctx.stop.cleared"
      else SUns "CLJ: stop of a context that is not started or suspended: not documented"
  | OSuspend =>
      match s_ctx s with
      | CStarted =>
          let s' := mkS CSuspended (susp_rs s) (s_nums s) (Z.add (s_next s) (adv real P (ids_with is_started s))) in
          if sus then SOk ROk (EvSeq [] []) s' "L4.ctx.suspend"
          else SOk ROk (EvSeq (stop_seq s is_started) []) s' "L4.ctx.suspend L4.stop.reverse-order"
      | _ => SUns "CLJ: suspend of a context that is not started: not documented"
      end
  | OResume =>
      match s_ctx s with
      | CSuspended =>
          let s' := mkS CStarted (resume_rs s) (s_nums s) (Z.add (s_next s) (adv real P (wake s))) in
          if sus then SOk ROk (EvSeq [] (unk_ign s)) s' "L4.ctx.resume"
          else SOk ROk (EvBag (map EStarted (wake s)) (unk_ign s)) s' "L4.ctx.resume"
      | _ => SUns "CLJ: resume of a context that is not suspended: not documented"
      end
  | ORStart id => route_op s id (fun r =>
      if idle r then start1 real P s id "L4.route.start"
      else SUns "RCJ: startRoute of a started or suspended route: not documented ('if it has been previously stopped')")
  | ORStop id => route_op s id (fun r =>
      if running r then SOk ROk (EvSeq [EStopped id] []) (set_route s id RStopped) "L4.route.stop"
      else if idle r then SOk ROk (EvSeq [] [EStopped id]) (set_route s id RStopped) "L4.route.stop.idle"
      else SUns "RCJ: stopRoute in this route state: not documented")
  | ORSuspend id => route_op s id (fun r =>
      match r with
      | RStarted =>
          if sus then SOk ROk (EvSeq [] []) (set_route s id RSuspended) "L4.route.suspend"
          else SOk ROk (EvSeq [EStopped id] []) (set_route s id RSusStop) "L4.route.suspend"
      | _ => SUns "RCJ: suspendRoute of a route that is not started: not documented"
      end)
  | ORResume id => route_op s id (fun r =>
      match r, sus with
      | RSuspended, true =>
          SOk ROk (EvSeq [] [EStarted id]) (mkS CStarted (rset id RStarted (s_rs s)) (s_nums s) (Z.add (s_next s) (adv real P [id])))
            "L4.route.resume"
      | RSusStop, false => start1 real P s id "L4.route.resume"
      | _, _ => SUns "RCJ: resumeRoute of a route that was not suspended: not documented"
      end)
  | ORemove id => route_op s id (fun r =>
      if stopped_r r
      then SOk (RBool true) (EvSeq [ERemoved id] [EStopped id]) (mkS CStarted (rset id RGone (s_rs s)) (unlist id (s_nums s)) (s_next s))
             "L4.route.remove"
      else if running r then SOk (RBool false) (EvSeq [] []) s "L4.route.remove"
      else SUns "CCJ: removeRoute of a route that was never started: its status is not documented")
  | OStartAll =>
      match s_ctx s with
      | CStarted =>
          if existsb (fun '(_, w) => blocked w) (s_rs s)
          then SUns "RCJ: startAllRoutes with a suspended route or a route of undocumented status"
          else let '(prs, nx) := prep_all real P (s_next s) (idle_ids P s) in
               if real && batch_clash prs (s_nums s)
               then SOk (RExn FTSRE) EvAny (mkS CStarted (mark (idle_ids P s) RUnk (s_rs s)) (s_nums s) nx) "L4.rc.startAll.clash.real"
               else SOk ROk (EvSeq (map EStarted (map fst (fold_right insert [] prs))) [])
                      (mkS CStarted (mark (idle_ids P s) RStarted (s_rs s)) (fold_left list_num prs (s_nums s)) nx)
                      (if real then "L4.rc.startAll L4.order.sort L4.order.renumber.real" else "L4.rc.startAll L4.order.sort")
      | _ => SUns "RCJ: a route operation while the context is not started: not documented"
      end
  | OStopAll =>
      match s_ctx s with
      | CStarted => SOk ROk (EvSeq (stop_seq s running) (idle_ign running s)) (mkS CStarted (stop_all_rs s) (s_nums s) (s_next s))
                      "L4.rc.stopAll L4.stop.reverse-order"
      | _ => SUns "RCJ: a route operation while the context is not started: not documented"
      end
  | OSend id b =>
      match s_ctx s with
      | CStarted =>
          match rget id (s_rs s) with
          | Some RStarted => SOk (RSent true) (EvSeq [] []) s "L4.send.started"
          | Some RSuspended => SUns "DC: a message to a route that is suspended: not documented"
          | Some RUnk => SUns "LC: a route whose status is not documented here (after a context resume or a failed start)"
          | r => if no_consumer r then SOk (RSent false) (EvSeq [] []) s "L4.send.no-consumer"
                 else SUns "DC: a message to a route in this state: not documented"
          end
      | _ => SUns "DC: a message while the context is not started: not documented"
      end
  end.

(** A case: the results of the operations, stopping at the first UNSPECIFIED one (the state after it is unknown). *)
Fixpoint run_ops (real sus : bool) (P : prog) (s : st) (os : list op) : list (obs * string) * option string :=
  match os with
  | [] => ([], None)
  | o :: t =>
      match step real sus P s o with
      | SOk r e s' h => let '(l, u) := run_ops real sus P s' t in ((observe sus r e s', String.append h " L4.status.context L4.status.route") :: l, u)
      | SUns w => ([], Some w)
      end
  end.
Definition run_case (real sus : bool) (P : prog) (os : list op) : list (obs * string) * option string :=
  if nodup_ids (map rd_id (p_routes P)) then run_ops real sus P (init P) os
  else ([], Some "CCJ: two routes with the same id (one replaces the other) not modelled").

(** ** Soundness and completeness *)

Lemma start1_sound : forall real sus P s id r h r' e s' h',
  s_ctx s = CStarted -> rget id (s_rs s) = Some r -> idle r = true ->
  start1 real P s id h = SOk r' e s' h' -> lstep real sus P s (ORStart id) r' e s'.
Proof.
  intros real sus P s id r h r' e s' h' C G I H. unfold start1 in H.
  destruct (prep real P (s_next s) id) as [n nx] eqn:Pr.
  destruct (real && clash_with (id, n) (s_nums s)) eqn:Cl; inversion H; subst.
  - eapply LRStartClash; eauto.
  - eapply LRStart; eauto.
Qed.
Lemma start1_sound_resume : forall real P s id h r' e s' h',
  s_ctx s = CStarted -> rget id (s_rs s) = Some RSusStop ->
  start1 real P s id h = SOk r' e s' h' -> lstep real false P s (ORResume id) r' e s'.
Proof.
  intros real P s id h r' e s' h' C G H. unfold start1 in H.
  destruct (prep real P (s_next s) id) as [n nx] eqn:Pr.
  destruct (real && clash_with (id, n) (s_nums s)) eqn:Cl; inversion H; subst.
  - eapply LRResumeNClash; eauto.
  - eapply LRResumeN; eauto.
Qed.

Theorem step_sound : forall real sus P s o r e s' h,
  step real sus P s o = SOk r e s' h -> lstep real sus P s o r e s'.
Proof.
  intros real sus P s o r e s' h H.
  destruct o; simpl in H.
  - destruct (s_ctx s) eqn:C; try discriminate.
    destruct (collision P) eqn:Co; [discriminate|].
    destruct (clashing P) as [|c cs] eqn:Cl.
    + inversion H; subst. now apply LStart.
    + destruct (p_auto P) eqn:A; [|discriminate].
      inversion H; subst. apply LStartClash; auto. rewrite Cl. discriminate.
  - destruct (ctx_running (s_ctx s)) eqn:C; [|discriminate]. inversion H; subst. now apply LStop.
  - destruct (s_ctx s) eqn:C; try discriminate. destruct sus; inversion H; subst.
    + now apply LSuspendS. + now apply LSuspendN.
  - destruct (s_ctx s) eqn:C; try discriminate. destruct sus; inversion H; subst.
    + now apply LResumeS. + now apply LResumeN.
  - unfold route_op in H. destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G; [|discriminate].
    destruct w; simpl in H; try discriminate; eapply start1_sound; eauto.
  - unfold route_op in H. destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G; [|discriminate].
    destruct w; simpl in H; try discriminate; inversion H; subst;
      first [eapply LRStop; eauto; reflexivity | eapply LRStopIdle; eauto; reflexivity].
  - unfold route_op in H. destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G; [|discriminate].
    destruct w; simpl in H; try discriminate; destruct sus; inversion H; subst.
    + now apply LRSuspendS. + now apply LRSuspendN.
  - unfold route_op in H. destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G; [|discriminate].
    destruct w; simpl in H; try discriminate; destruct sus; try discriminate.
    + eapply start1_sound_resume; eauto.
    + inversion H; subst. now apply LRResumeS.
  - unfold route_op in H. destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G; [|discriminate].
    destruct w; simpl in H; try discriminate; inversion H; subst;
      first [eapply LRemove; eauto; reflexivity | eapply LRemoveNo; eauto; reflexivity].
  - destruct (s_ctx s) eqn:C; try discriminate.
    destruct (existsb (fun '(_, w) => blocked w) (s_rs s)) eqn:B; [discriminate|].
    destruct (prep_all real P (s_next s) (idle_ids P s)) as [prs nx] eqn:Pr.
    destruct (real && batch_clash prs (s_nums s)) eqn:Cl; inversion H; subst.
    + eapply LStartAllClash; eauto. + eapply LStartAll; eauto.
  - destruct (s_ctx s) eqn:C; try discriminate. inversion H; subst. now apply LStopAll.
  - destruct (s_ctx s) eqn:C; try discriminate.
    destruct (rget id (s_rs s)) as [w|] eqn:G.
    + destruct w; try discriminate; simpl in H; inversion H; subst;
        first [now apply LSendOk | apply LSendNone; auto; rewrite G; reflexivity].
    + simpl in H. inversion H; subst. apply LSendNone; auto. rewrite G. reflexivity.
Qed.

Theorem step_complete : forall real sus P s o r e s',
  lstep real sus P s o r e s' -> exists h, step real sus P s o = SOk r e s' h.
Proof.
  intros real sus P s o r e s' H.
  destruct H; simpl; unfold route_op, start1; try subst sus.
  - rewrite H, H0, H1. eauto.
  - rewrite H, H0. destruct (clashing P) eqn:Cl; [contradiction|]. rewrite H2. eauto.
  - rewrite H. eauto.
  - rewrite H. eauto.
  - rewrite H. eauto.
  - rewrite H. eauto.
  - rewrite H. eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; rewrite H2, H3; eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; rewrite H2, H3; eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; eauto.
  - rewrite H, H0. simpl. eauto.
  - rewrite H, H0. simpl. eauto.
  - rewrite H, H0. simpl. eauto.
  - rewrite H, H0. simpl. rewrite H2, H3. eauto.
  - rewrite H, H0. simpl. rewrite H2, H3. eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; eauto.
  - rewrite H, H0. destruct r; simpl in H1; try discriminate; simpl; eauto.
  - rewrite H, H0, H1, H2. eauto.
  - rewrite H, H0, H1, H2. eauto.
  - rewrite H. eauto.
  - rewrite H, H0. eauto.
  - rewrite H. destruct (rget id (s_rs s)) as [[]|]; simpl in H0; try discriminate; simpl; eauto.
Qed.

Theorem run_sound : forall real sus P os s l u,
  run_ops real sus P s os = (l, u) -> exists s', ltrace real sus P s (firstn (length l) os) (map fst l) s'.
Proof.
  induction os as [|o os IH]; intros s l u H; simpl in H.
  - inversion H; subst. exists s. constructor.
  - destruct (step real sus P s o) as [r e s1 h|w] eqn:E.
    + destruct (run_ops real sus P s1 os) as [l1 u1] eqn:R. inversion H; subst.
      destruct (IH s1 l1 _ R) as [s2 T]. exists s2. simpl.
      eapply LTCons; [eapply step_sound; exact E | exact T].
    + inversion H; subst. exists s. constructor.
Qed.

(** ** A property: a context stopped right after its start stops the routes in the reverse order of their
    RouteStartedEvents [CFG.209] (both modes, both values of [sus]). *)

Lemma ceqs_eq : forall a b, ceqs a b = true -> a = b.
Proof.
  induction a as [|x a IH]; destruct b as [|y b]; simpl; try discriminate; auto.
  intro H. apply Bool.andb_true_iff in H as [H1 H2]. unfold ceq in H1. apply Ascii.eqb_eq in H1. subst.
  f_equal. now apply IH.
Qed.
Lemma ceqs_refl : forall a, ceqs a a = true.
Proof. induction a; simpl; auto. rewrite IHa. unfold ceq. rewrite Ascii.eqb_refl. reflexivity. Qed.
Lemma rget_rmap : forall f k l, rget k (rmap f l) = option_map (f k) (rget k l).
Proof.
  intros f k l. induction l as [|[k' w] t IH]; simpl; auto.
  destruct (ceqs k' k) eqn:E; auto. apply ceqs_eq in E. subst. reflexivity.
Qed.
Lemma rget_in : forall k (l : list (chars * rstat)), In k (map fst l) -> exists w, rget k l = Some w.
Proof.
  intros k l. induction l as [|[k' w] t IH]; simpl; [tauto|]. intros [E|I].
  - subst. rewrite ceqs_refl. eauto.
  - destruct (ceqs k' k); eauto.
Qed.
Lemma in_insert : forall x y l, In x (map fst (insert y l)) -> fst y = x \/ In x (map fst l).
Proof.
  intros x y l. induction l as [|z t IH]; simpl; [tauto|].
  destruct (Z.leb (snd y) (snd z)); simpl; [tauto|]. intros [E|I]; [tauto|]. destruct (IH I); tauto.
Qed.
Lemma in_sort : forall x l, In x (map fst (fold_right insert [] l)) -> In x (map fst l).
Proof.
  intros x l. induction l as [|y t IH]; simpl; [tauto|]. intro I. apply in_insert in I as [E|I]; [tauto|]. right; auto.
Qed.
Lemma assign_keys : forall n rs, map fst (assign n rs) = map rd_id rs.
Proof. intros n rs. revert n. induction rs as [|r t IH]; intro n; simpl; auto. destruct (rd_order r); simpl; f_equal; auto. Qed.
Lemma to_start_ids : forall P k, In k (to_start P) -> In k (map rd_id (p_routes P)).
Proof.
  intros P k. unfold to_start, start_pairs. destruct (p_auto P); simpl; [|tauto].
  intro I. apply in_map_iff in I as [[k' z] [E I]]. simpl in E. subst. apply filter_In in I as [I _].
  rewrite <- (assign_keys 1000). apply in_sort. apply in_map_iff. eexists; split; [|exact I]; reflexivity.
Qed.

Definition stop_of (e : ev) : ev := match e with EStarted k => EStopped k | x => x end.
Theorem stop_reverses_start : forall real sus P s1 e1 r2 e2 s2,
  lstep real sus P (init P) OStart ROk e1 s1 -> lstep real sus P s1 OStop r2 e2 s2 ->
  exists l ign, e1 = EvSeq l [] /\ e2 = EvSeq (rev (map stop_of l)) ign.
Proof.
  intros real sus P s1 e1 r2 e2 s2 H1 H2. inversion H1; subst.
  assert (F : filter (stat_is (mkS CStarted (mark (to_start P) RStarted (s_rs (init P))) (start_pairs P)
                                   (Z.add 1000 (nauto P))) (run_ctx sus)) (to_start P) = to_start P).
  { apply forallb_filter_id. apply forallb_forall. intros k I. unfold stat_is. simpl. unfold mark.
    rewrite rget_rmap. destruct (rget_in k (map (fun r => (rd_id r, RNew)) (p_routes P))) as [w G].
    - rewrite map_map. simpl. now apply to_start_ids.
    - rewrite G. simpl. assert (existsb (ceqs k) (to_start P) = true) as -> .
      { apply existsb_exists. exists k. split; auto. apply ceqs_refl. }
      reflexivity. }
  inversion H2; subst. exists (map EStarted (to_start P)). eexists. split; [reflexivity|].
  unfold stop_seq. simpl s_nums. change (map fst (start_pairs P)) with (to_start P). rewrite F.
  rewrite map_map. reflexivity.
Qed.

(** ** Examples from the docs (vm_compute) *)

Definition rt (id : string) (o : option Z) (a : bool) : rdef := mkR (str id) o a.
Definition evs_of (u : list (obs * string) * option string) : list evobs := map (fun '(ob, _) => o_evs ob) (fst u).
Definition results_of (u : list (obs * string) * option string) : list ores := map (fun '(ob, _) => o_res ob) (fst u).
Definition sts_of (u : list (obs * string) * option string) : list (list (chars * vst)) := map (fun '(ob, _) => o_st ob) (fst u).

(** [CFG.347-434]: direct:start (auto), seda:foo (1), direct:bar (12345), seda:bar (auto) start in the order seda:foo,
    direct:start, seda:bar, direct:bar. Route ids name the URIs. *)
Definition cfg_last : prog :=
  mkP true [rt "start" None true; rt "foo" (Some 1%Z) true; rt "bar" (Some 12345%Z) true; rt "sedabar" None true].
Example doc_startup_order_last :
  evs_of (run_case false true cfg_last [OStart])
  = [EvSeq [EStarted (str "foo"); EStarted (str "start"); EStarted (str "sedabar"); EStarted (str "bar")] []].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.213-268]: seda:foo (1) is started before direct:start (2). *)
Example doc_startup_order_two :
  evs_of (run_case false true (mkP true [rt "foo" (Some 1%Z) true; rt "start" (Some 2%Z) true]) [OStart])
  = [EvSeq [EStarted (str "foo"); EStarted (str "start")] []].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.270-342]: direct:bar has no startupOrder, gets 1000 and is started last. *)
Example doc_startup_order_mixed :
  evs_of (run_case false false (mkP true [rt "foo" (Some 1%Z) true; rt "start" (Some 2%Z) true; rt "bar" None true]) [OStart])
  = [EvSeq [EStarted (str "foo"); EStarted (str "start"); EStarted (str "bar")] []].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.209, CFG.436-438, GS.18]: the routes are stopped in the reverse order they were started. *)
Example doc_stop_reverse :
  evs_of (run_case false true cfg_last [OStart; OStop]) =
  [EvSeq [EStarted (str "foo"); EStarted (str "start"); EStarted (str "sedabar"); EStarted (str "bar")] [];
   EvSeq [EStopped (str "bar"); EStopped (str "sedabar"); EStopped (str "start"); EStopped (str "foo")]
         (map ERemoved [str "start"; str "foo"; str "bar"; str "sedabar"])].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.183-186]: a startupOrder clash fails the start with FailedToStartRouteException. *)
Example doc_clash :
  results_of (run_case false true (mkP true [rt "a" (Some 1%Z) true; rt "b" (Some 1%Z) true]) [OStart]) = [RExn FTSRE].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.18-52]: with autoStartup=false on the context no route is started; startAllRoutes starts them. *)
Example doc_context_no_autostartup :
  evs_of (run_case false true (mkP false [rt "foo" None true; rt "bar" None true]) [OStart; OStartAll])
  = [EvSeq [] []; EvSeq [EStarted (str "foo"); EStarted (str "bar")] []].
Proof. vm_compute. reflexivity. Qed.
(** [CFG.56-83]: a route with autoStartup=false is not started with the context; the others are. *)
Example doc_route_no_autostartup :
  evs_of (run_case false true (mkP true [rt "special" None false; rt "other" None true]) [OStart])
  = [EvSeq [EStarted (str "other")] []].
Proof. vm_compute. reflexivity. Qed.
(** [CCJ.677, CCJ.695-696]: removeRoute of a started route gives false; once stopped it is removed (getRoute null). *)
Example doc_remove_must_be_stopped :
  let u := run_case false true (mkP true [rt "r" None true]) [OStart; ORemove (str "r"); ORStop (str "r"); ORemove (str "r")] in
  (results_of u, last (sts_of u) []) = ([ROk; RBool false; ROk; RBool true], [(str "r", VAbsent)]).
Proof. vm_compute. reflexivity. Qed.
(** [RCJ.204]: a route that does not support suspension is stopped instead ([sus = false]). *)
Example doc_suspend_stop_instead :
  let u := run_case false false (mkP true [rt "r" None true]) [OStart; ORSuspend (str "r")] in
  (evs_of u, last (sts_of u) []) = ([EvSeq [EStarted (str "r")] []; EvSeq [EStopped (str "r")] []], [(str "r", VStopped)]).
Proof. vm_compute. reflexivity. Qed.
(** [CFG.193-196] read with the Real mode: with a route at 1001, restarting a route that has no startupOrder fails
    (Real) while the docs give it its one number 1000 (Doc). The reproducer of the finding. *)
Definition renum : prog := mkP true [rt "A" None true; rt "B" (Some 1001%Z) true].
Example real_restart_clash :
  (results_of (run_case false true renum [OStart; ORStop (str "A"); ORStart (str "A")]),
   results_of (run_case true true renum [OStart; ORStop (str "A"); ORStart (str "A")]))
  = ([ROk; ROk; ROk], [ROk; ROk; RExn FTSRE]).
Proof. vm_compute. reflexivity. Qed.

(** Non-vacuity of [stop_reverses_start] (CONVENTIONS practice 4): its hypotheses hold for the doc program. *)
Example stop_reverses_start_nonvacuous : exists e1 r2 e2 s1 s2,
  lstep false true cfg_last (init cfg_last) OStart ROk e1 s1 /\ lstep false true cfg_last s1 OStop r2 e2 s2.
Proof.
  do 5 eexists. split.
  - apply LStart; vm_compute; reflexivity.
  - apply LStop. vm_compute. reflexivity.
Qed.
(** Non-vacuity of [run_sound]: the interpreter derives a whole trace for the doc program. *)
Example run_sound_nonvacuous : exists s', ltrace false true cfg_last (init cfg_last) [OStart; OStop]
  (map fst (fst (run_ops false true cfg_last (init cfg_last) [OStart; OStop]))) s'.
Proof.
  destruct (run_ops false true cfg_last (init cfg_last) [OStart; OStop]) as [l u] eqn:E.
  destruct (run_sound _ _ _ _ _ _ _ E) as [s' T]. exists s'.
  vm_compute in E. inversion E; subst. exact T.
Qed.
