(** * L2 routes: the route model, its big-step rules, and an interpreter proved sound against them.

    A route is a program and Camel is its interpreter (KICKOFF.md). The readable rules are the inductive relations
    [bss] (a list of steps), [bs1] (one step) and [bch] (the branches of a choice): one constructor per documented
    rule, each citing its doc lines. The function [run] computes them; [run_sound] proves that whatever [run] returns
    is derivable from the rules, so the extracted oracle is checked against the readable rules (CONVENTIONS.md,
    practice 1). Where the docs are silent [run] answers [OUns why] and the rules have no case.

    Legend (paths under docs/):
      [M:x.n]  model/x.json line n (the generated EIP model: option and eipIn/eipOut descriptions)
      [PL]  core/camel-core-engine/src/main/docs/modules/eips/pages/pipeline-eip.adoc
      [FI]  .../eips/pages/filter-eip.adoc         [CH] .../eips/pages/choice-eip.adoc
      [ST]  .../eips/pages/stop-eip.adoc           [TE] .../eips/pages/throwException-eip.adoc
      [SB]  .../eips/pages/setBody-eip.adoc        [TR] .../eips/pages/transform-eip.adoc
      [SH]  .../eips/pages/setHeader-eip.adoc      [SP] .../eips/pages/setProperty-eip.adoc
      [SV]  .../eips/pages/setVariable-eip.adoc    [RH] .../eips/pages/removeHeader-eip.adoc
      [RP]  .../eips/pages/removeProperty-eip.adoc [RV] .../eips/pages/removeVariable-eip.adoc
      [TO]  .../eips/pages/to-eip.adoc
      [EP]  docs/user-manual/modules/ROOT/pages/exchange-pattern.adoc
      [EH]  docs/user-manual/modules/ROOT/pages/error-handler.adoc
      [DT]  core/camel-core-engine/src/main/docs/modules/eips/pages/doTry-eip.adoc (L3)
      [EC]  docs/user-manual/modules/ROOT/pages/exception-clause.adoc (L3)
      [EHP] .../pages/exception-handling-patterns.adoc  [ER] .../pages/exception-redelivery.adoc
      [DEH] .../pages/defaulterrorhandler.adoc          [DLC] .../eips/pages/dead-letter-channel.adoc
      [OC]  docs/user-manual/modules/ROOT/pages/oncompletion.adoc
      [EXA] docs/user-manual/modules/ROOT/pages/exception-advanced.adoc
      [SPL] .../eips/pages/split-eip.adoc          [MCE] .../eips/pages/multicast-eip.adoc
      [RLE] .../eips/pages/recipientList-eip.adoc
      [AS]  core/camel-core-model/src/main/java/org/apache/camel/builder/AggregationStrategies.java (javadoc)
      [GBS] core/camel-core-processor/src/main/java/org/apache/camel/processor/aggregate/GroupedBodyAggregationStrategy.java
      [AGG] .../eips/pages/aggregate-eip.adoc      [LOOP] .../eips/pages/loop-eip.adoc
      [IC]  .../eips/pages/idempotentConsumer-eip.adoc
      [RRL] .../eips/pages/roundRobinLoadBalancer-eip.adoc  [FO] .../eips/pages/failoverLoadBalancer-eip.adoc
      [LBE] .../eips/pages/loadBalance-eip.adoc     [M:lb:x.n] model/loadbalancer/x.json line n
      [RS]  .../eips/pages/routingSlip-eip.adoc     [DR] .../eips/pages/dynamicRouter-eip.adoc
      [CB]  .../eips/pages/convertBodyTo-eip.adoc
      [DC]  components/camel-direct/src/main/docs/direct-component.adoc   [DJ] component-json/direct.json
      [MC]  components/camel-mock/src/main/docs/mock-component.adoc       [MJS] component-json/mock.json

    Scope of this first cut: the set/remove EIPs, transform, filter, choice, pipeline, stop, throwException, to
    direct: and to mock:, with the default error handler (no onException, no redelivery yet), and doTry / doCatch /
    doFinally (rules tagged L3). *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L1 Require Simple.
From CamelSpec.L0 Require Convert.
From CamelSpec.L1 Require Lang.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** Expressions (L1) as the routes use them *)

Inductive expr : Type :=
| XSimple (p : Simple.prog)
| XLang (e : Lang.lexp).   (* constant, header, exchangeProperty, variable, ref, tokenize (L1/Lang.v) *)

Inductive eres : Type := EV (v : val) | EUns (why : string).

Definition sview (x : exchange) : Simple.exch :=
  Simple.mkEx (m_body (x_msg x)) (m_headers (x_msg x)) (x_props x) (x_vars x).

(** A Simple program the L1 rules call an error is refused when the route is created, or fails when it runs; which
    one is not modelled yet, so a route using it is UNSPECIFIED here. A loose value (only its text documented) is
    UNSPECIFIED once it is stored, since its Java type becomes observable. *)
(*! R L2.expr.lang DOC L1.lang *)
(** The other core languages read the exchange through L1's environment: body, headers, properties, the exchange's
    variables (variables of other repositories, the registry and property placeholders are not connected yet: a
    variable name with a repository prefix is UNSPECIFIED here). An L1 error is UNSPECIFIED here (when it surfaces is
    not modelled), as for Simple. *)
Definition lenv_of (x : exchange) : Lang.lenv :=
  Lang.mkLE (m_body (x_msg x)) (m_headers (x_msg x)) (x_props x) (x_vars x) [] [] [] (Placeholder.penv0 []).
Definition lang_scoped (e : Lang.lexp) : bool :=
  match e with Lang.XVar n _ => existsb (fun c => ceq c ":"%char) n | Lang.XRef _ _ _ => true | _ => false end.
Definition eval_expr (x : exchange) (e : expr) : eres :=
  match e with
  | XLang l =>
      if lang_scoped l then EUns "L2: variable repositories / registry in a language expression not connected"
      else match Lang.eval (lenv_of x) l with
           | Lang.LV v => EV v
           | Lang.LErr _ => EUns "L2: a language error (startup vs runtime failure not modelled yet)"
           | Lang.LUns w => EUns w
           end
  | XSimple p =>
      match Simple.run (sview x) p with
      | Simple.RV v => EV v
      | Simple.RLoose _ => EUns "L2: a Simple value whose Java type is not documented is stored"
      | Simple.RErr => EUns "L2: Simple error (startup vs runtime failure not modelled yet)"
      | Simple.RUns w => EUns w
      end
  end.

Inductive pres : Type := PB (b : bool) | PUns (why : string).
Definition eval_pred (x : exchange) (e : expr) : pres :=
  match e with
  | XLang l =>
      if lang_scoped l then PUns "L2: variable repositories / registry in a language predicate not connected"
      else match Lang.evalp (lenv_of x) l with
           | Lang.LV (VBool b) => PB b
           | Lang.LV _ => PUns "L2: a language predicate gave a non-boolean"
           | Lang.LErr _ => PUns "L2: a language predicate error"
           | Lang.LUns w => PUns w
           end
  | XSimple p =>
      if Simple.is_predicate p then
        match eval_expr x e with
        | EV (VBool b) => PB b
        | EV _ => PUns "L2: a Simple predicate gave a non-boolean"
        | EUns w => PUns w
        end
      else PUns "L2: a Simple expression (not a predicate) used as a predicate"
  end.

(** ** Syntax *)

(** Split options modelled so far [M:split]: stopOnException, group, delimiter (one character, or "false"),
    maxFailedRecords. Not yet: aggregationStrategy, parallelProcessing, streaming, timeout, onPrepare,
    shareUnitOfWork, errorThreshold, watermarks. *)
(** The built-in aggregation strategies of org.apache.camel.builder.AggregationStrategies modelled so far [AS]:
    useLatest ("Use the latest incoming exchange"), useOriginal ("Use the original exchange"), groupedBody ("a single
    combined Exchange holding all the aggregated bodies in a List" [GBS]). [StNone]: no strategy configured. *)
Inductive strat : Type := StNone | StLatest | StOriginal | StGroupedBody.
Record split_opts : Type := mkSplit {
  sp_stop : bool; sp_group : option nat; sp_delim : chars; sp_maxfail : option nat; sp_strat : strat }.

(** Aggregate options modelled so far [M:aggregate]: the node id (the generator names each aggregator), correlation
    expression, strategy, completionSize, completionPredicate, eagerCheckCompletion, closeCorrelationKeyOnCompletion
    (unbounded). The output runs in the caller's thread (a SynchronousExecutorService [AGG.46-47], set by the harness).
    Not yet: timeouts and intervals (time), repositories, batch consumers, controllers, optimistic locking. *)
Record agg_opts : Type := mkAgg {
  ago_id : chars; ago_corr : expr; ago_strat : strat; ago_size : option nat; ago_pred : option expr;
  ago_eager : bool; ago_close : bool }.

(** Load balancers modelled so far: round robin, and failover in its default mode (not round robin, not sticky),
    with the monitored exceptions and maximumFailoverAttempts ([M:lb:failoverLoadBalancer]). *)
Inductive lbkind : Type := LBRoundRobin | LBFailover (exs : list chars) (maxf : Z).

Inductive endpoint : Type :=
| EDirect (name : chars)
| EMock (name : chars).

Inductive step : Type :=
| SSetBody (e : expr)
| STransform (e : expr)
| SSetHeader (k : chars) (e : expr)
| SSetProperty (k : chars) (e : expr)
| SSetVariable (k : chars) (e : expr)
| SRemoveHeader (k : chars)
| SRemoveHeaders (pat : chars) (excl : list chars)
| SRemoveProperty (k : chars)
| SRemoveVariable (k : chars)
| SFilter (p : expr) (body : list step)
| SChoice (whens : list (expr * list step)) (other : option (list step))
| SPipeline (body : list step)
| STo (ep : endpoint)
| SStop
| SThrow (cls msg : chars)
| SDoTry (body : list step) (catches : list (list chars * option expr * list step)) (fin : option (list step))
| SSplit (e : expr) (o : split_opts) (body : list step)
| SMulticast (st : strat) (branches : list step)
| SRecipientList (st : strat) (e : expr) (delim : chars)
| SAggregate (o : agg_opts) (body : list step)
| SLoop (e : expr) (copy dowhile : bool) (body : list step)
| SIdem (id : chars) (e : expr) (skip eager : bool) (body : list step)
| SLB (id : chars) (k : lbkind) (branches : list step)
| SRoutingSlip (e : expr) (delim : chars)
| SDynamicRouter (e : expr) (delim : chars)
| SConvertBody (t : Convert.jtype) (mandatory : bool).

(** A route consumes from [direct:r_from]. *)
Record route : Type := mkRoute { r_id : chars; r_from : chars; r_steps : list step }.

(** An onException clause [EC.3-9, M:onException]: the exception classes, an optional onWhen, handled, continued,
    maximumRedeliveries (with redeliveryDelay 0: delays are time, not modelled yet), and the steps of its block. The
    clauses of a program apply to all its routes (RouteBuilder scope [EC.154-158]), or to one route (c_scope). *)
Record clause : Type := mkClause {
  c_ex : list chars; c_when : option expr; c_handled : option bool; c_continued : bool;
  c_redeliveries : nat; c_steps : list step;
  c_retry : option expr;    (* retryWhile [EXA.393-425] *)
  c_onredel : bool;         (* onRedeliveryRef to the harness's fixed processor (L3.onRedelivery) *)
  c_scope : option chars }. (* None: global (RouteBuilder scope); Some r: in route r [EC.152-161, EXA.10-140] *)

(** The error handler of the program's routes [EH.25-47]: the default error handler, or a dead letter channel
    [DLC.25-31] with its dead letter endpoint (a mock here), maximumRedeliveries (redeliveryDelay 0) and which message
    is moved: the current one, the original input message (useOriginalMessage), or the original body with the current
    headers (useOriginalBody) [DLC.230-291, M:deadLetterChannel]. Error handlers are "inherited on each routing rule
    within a single RouteBuilder" [EH.44-47]: one for all the routes of a program. *)
Inductive uomode : Type := UONone | UOMessage | UOBody.
Inductive ehconf : Type := EHDefault | EHDlc (dlq : chars) (n : nat) (uo : uomode).

(** A route scoped onCompletion [OC.35-49, M:onCompletion]: when it triggers (always, onCompleteOnly, onFailureOnly
    [OC.115-119]), an optional onWhen [OC.254-258], the mode (BeforeConsumer or the default AfterConsumer
    [OC.407-421]), useOriginalMessage [M:onCompletion.useOriginalMessage] and its steps. One per program, on the route
    the sends go to (the first route); parallelProcessing is not modelled (default false [OC.25]). *)
Inductive octrig : Type := OcAlways | OcComplete | OcFailure.
Record oncomp : Type := mkOc { oc_trig : octrig; oc_when : option expr; oc_before : bool; oc_orig : bool; oc_steps : list step }.

(** What the harness observes: an exchange received by a mock endpoint (mock keeps a copy of what it received:
    copyOnExchange defaults to true [MJS: copyOnExchange], [MC.487]). [exn_unknown]: whether the exchange shows the
    exception at that point is not documented (inside doFinally while an exception is pending), so the harness does not
    compare that field. *)
Inductive event : Type := EvMock (name : chars) (x : exchange) (exn_unknown : bool).
Definition unknown_exn (t : list event) : list event := map (fun '(EvMock n y _) => EvMock n y true) t.

(** ** doCatch selection (L3)

    "The doCatch blocks are tried in the order they are defined, and the first doCatch that matches is used (the same
    as in Java). For each doCatch, the exception and its causes are matched ..., and the onWhen predicate (if any) must
    also be true" [DT.211-213]. throwException makes an exception without a cause; Camel's wrappers (split) have one. *)
Fixpoint any_instance (c : chars) (ts : list chars) : r0 bool :=
  match ts with
  | [] => Ok0 false
  | t :: r => match instance_of c t with Ok0 true => Ok0 true | Ok0 false => any_instance c r | Uns0 w => Uns0 w end
  end.
Fixpoint chain_instance (es : list exn) (ts : list chars) : r0 bool :=
  match es with
  | [] => Ok0 false
  | e :: r => match any_instance (exn_class e) ts with
              | Ok0 true => Ok0 true | Ok0 false => chain_instance r ts | Uns0 w => Uns0 w end
  end.
(*! R L3.doCatch.select DOC [DT.211-213] [M:doCatch.6] *)
Fixpoint select_catch (x : exchange) (e : exn) (cs : list (list chars * option expr * list step))
  : r0 (option (list step)) :=
  match cs with
  | [] => Ok0 None
  | (ts, w, ss) :: r =>
      match chain_instance (exn_chain e) ts with
      | Uns0 why => Uns0 why
      | Ok0 false => select_catch x e r
      | Ok0 true =>
          match w with
          | None => Ok0 (Some ss)
          | Some p => match eval_pred x p with
                      | PB true => Ok0 (Some ss) | PB false => select_catch x e r | PUns why => Uns0 why end
          end
      end
  end.
(** ** Split: the items, and the sub-exchanges *)

(*! R L2.split.items DOC [SPL.82-96] [M:split.delimiter] *)
(** A List is split by element [SPL.87], a String "by comma as separator" [SPL.93] (or by the [delimiter] option;
    "false" turns splitting off [M:split.delimiter]); any other type is "not split, ... used as-is", one message
    [SPL.95-96]. Not documented: null, the empty String, empty items between two delimiters, white space around
    items (the generator uses none), delimiters of several characters. *)
Definition split_items (o : split_opts) (v : val) : r0 (list val) :=
  match v with
  | VList l => Ok0 (map VStr l)
  | VStr s =>
      if ceqs (sp_delim o) (str "false") then Ok0 [VStr s]
      else match sp_delim o with
           | [d] => match s with
                    | [] => Uns0 "SPL: splitting the empty String not documented"
                    | _ => let parts := split_on d s in
                           if existsb (fun p => match p with [] => true | _ => false end) parts
                           then Uns0 "SPL: empty items between delimiters not documented"
                           else Ok0 (map VStr parts)
                    end
           | _ => Uns0 "SPL: delimiter of several characters not modelled"
           end
  | VNull => Uns0 "SPL: splitting null not documented"
  | _ => Ok0 [v]
  end.
Fixpoint chunk_f (fuel n : nat) (l : list chars) : list (list chars) :=
  match fuel, l with
  | O, _ | _, [] => []
  | S f, _ => firstn n l :: chunk_f f n (skipn n l)
  end.
Fixpoint texts (l : list val) : option (list chars) :=
  match l with [] => Some [] | VStr s :: r => option_map (cons s) (texts r) | _ => None end.
(*! R L2.split.group DOC [SPL.1088-1090] [SPL.1135-1136] [M:split.group] *)
(** "Groups N split messages into a single message with a java.util.List body"; 7 items in groups of 3 give 3
    messages [SPL.1135-1136]. *)
Definition group_items (o : split_opts) (l : list val) : r0 (list val) :=
  match sp_group o with
  | None => Ok0 l
  | Some O => Uns0 "SPL: group 0 not documented"
  | Some n => match texts l with
              | Some ts => Ok0 (map VList (chunk_f (length ts) n ts))
              | None => Uns0 "SPL: group of items that are not all Strings (List element kinds) not modelled"
              end
  end.
(*! R L2.split.copy DOC [SPL.13] [SPL.1683-1686] [MCE.398-399] *)
(** Each item is processed as its own message [SPL.13, SPL.15]; Split is based on Multicast [SPL.1683-1686], which
    sends a (shallow) copy of the exchange [MCE.398-399]: headers and properties are copied, the body is the item. *)
Definition sub_of (x : exchange) (v : val) : exchange :=
  mkX (mkMsg v (m_headers (x_msg x))) (x_props x) (x_vars x) (x_mep x) None false (x_eh x) false false []
      (Some (mkMsg v (m_headers (x_msg x)))) (x_route x) (x_cont x).
(*! R L2.split.failure-wrapped DOC-BUG [M:split.stopOnException] [M:split.maxFailedRecords] MulticastProcessor *)
(** The exception that stops a split: [M:split.maxFailedRecords] says "a org.apache.camel.CamelExchangeException is
    thrown"; [M:split.stopOnException] says "the caused exception will be thrown". Camel throws, in both cases, a
    CamelExchangeException whose cause is the item's exception (MulticastProcessor: "wrap in exception to explain
    where it failed"), pinned by SplitterStopOnExceptionTest:53 and MulticastStopOnExceptionTest:56; the
    stopOnException text is the doc bug (notes/main.md). Its message is not documented ("?" is not compared). *)
Definition cee (e : exn) : exn := mkExn (str "org.apache.camel.CamelExchangeException") (str "?") (Some e).
Definition has_maxfail (o : split_opts) : bool := match sp_maxfail o with Some _ => true | None => false end.

(** ** Multicast and recipient list: copies, and "the last reply" *)

(*! R L2.multicast.copy DOC [MCE.9-10] [MCE.398-401] [M:multicast.6] *)
(** "routing the same message to a number of endpoints" [MCE.9-10]: each output gets a (shallow) copy of the
    exchange [MCE.398-401]; "By default ... the next multicasted message is processed only when the previous is
    finished" [MCE.82-84]. *)
(*! R L3.dlc.original-boundary DOC [DLC.335-342] *)
(** "splitter, multicast, will create a new unit of work boundary for the messages in their sub-route (i.e., the
    split message)" [DLC.340-342]: a split item and a multicast (or recipient list: a multicast to a dynamic list,
    [RLE.4]) copy start their own unit of work, whose original message is the one they start with; a loop copy and the
    exchange passed through direct: stay in the caller's unit of work [DLC.337-338]. *)
Definition copy_of (x : exchange) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) None false (x_eh x) false false [] (Some (x_msg x)) (x_route x) (x_cont x).
(*! R L2.multicast.last-reply DOC [M:multicast.aggregationStrategy] [M:multicast.40] [M:recipientList.42] *)
(** "By default Camel uses the last reply as the outgoing message" [M:multicast.aggregationStrategy]; recipient list:
    "The reply of the last recipient, unless an aggregationStrategy is set" [M:recipientList.42]. The message (body
    and headers) of the last copy replaces the message; what happens to exchange properties set in a copy is not
    documented (no rule when a copy changed them). *)
Definition last_reply (x y : exchange) : exchange :=
  with_msg x (x_msg y).
(** Equal header/property sets (order ignored). *)
Definition kvin (k : chars) (v : val) (l : list (chars * val)) : bool := existsb (fun '(k', v') => ceqs k k' && veqb v v') l.
Definition kvset_eqb (a b : list (chars * val)) : bool :=
  Nat.eqb (length a) (length b) && forallb (fun '(k, v) => kvin k v b) a.
Fixpoint last_of (l : list exchange) : option exchange :=
  match l with [] => None | [y] => Some y | _ :: r => last_of r end.
(*! R L2.strategy.result DOC [AS] [GBS] [M:split.aggregationStrategy] [M:multicast.aggregationStrategy] *)
(** The outgoing exchange after a split/multicast/recipient list from the results of its copies, in order. With no
    strategy: the original for split [SPL.380], the last reply for multicast and recipient list
    [M:multicast.aggregationStrategy, M:recipientList.42]. useLatest: the last result's message; useOriginal: the
    original; groupedBody: a List of the bodies (as List of String here). Which headers and properties the combined
    exchange keeps is not documented: UNSPECIFIED (None) unless every result has the original's headers and
    properties. No result at all with useLatest/groupedBody: not documented. *)
Definition strat_result (split : bool) (st : strat) (x : exchange) (acc : list exchange) : option exchange :=
  let same_props := forallb (fun y => kvset_eqb (x_props y) (x_props x)) acc in
  let same_hdrs := forallb (fun y => kvset_eqb (m_headers (x_msg y)) (m_headers (x_msg x))) acc in
  match st with
  | StNone => if split then Some x
              else match last_of acc with Some y => if same_props then Some (with_msg x (x_msg y)) else None | None => None end
  | StOriginal => Some x
  | StLatest => match last_of acc with Some y => if same_props then Some (with_msg x (x_msg y)) else None | None => None end
  | StGroupedBody =>
      match acc, texts (map (fun y => m_body (x_msg y)) acc) with
      | _ :: _, Some ts => if same_props && same_hdrs then Some (set_body x (VList ts)) else None
      | _, _ => None
      end
  end.

(** ** Aggregate: the pure part of one step (correlation, strategy, completion) *)
Fixpoint agget (k : chars) (l : list (chars * agroup)) : option agroup :=
  match l with [] => None | (k', a) :: r => if ceqs k k' then Some a else agget k r end.
Fixpoint agput (k : chars) (a : agroup) (l : list (chars * agroup)) : list (chars * agroup) :=
  match l with [] => [(k, a)] | (k', a') :: r => if ceqs k k' then (k', a) :: r else (k', a') :: agput k a r end.
Fixpoint agdel (k : chars) (l : list (chars * agroup)) : list (chars * agroup) :=
  match l with [] => [] | (k', a') :: r => if ceqs k k' then agdel k r else (k', a') :: agdel k r end.
Fixpoint aglget (k : chars) (l : list (chars * list (chars * agroup))) : list (chars * agroup) :=
  match l with [] => [] | (k', v) :: r => if ceqs k k' then v else aglget k r end.
Fixpoint aglset (k : chars) (v : list (chars * agroup)) (l : list (chars * list (chars * agroup))) :=
  match l with [] => [(k, v)] | (k', v') :: r => if ceqs k k' then (k', v) :: r else (k', v') :: aglset k v r end.
Fixpoint clget (k : chars) (l : list (chars * list chars)) : list chars :=
  match l with [] => [] | (k', v) :: r => if ceqs k k' then v else clget k r end.
Fixpoint clset (k : chars) (v : list chars) (l : list (chars * list chars)) : list (chars * list chars) :=
  match l with [] => [(k, v)] | (k', v') :: r => if ceqs k k' then (k', v) :: r else (k', v') :: clset k v r end.
Definition with_groups (g : gstate) (id : chars) (f : list (chars * agroup) -> list (chars * agroup)) : gstate :=
  mkG (g_global g) (g_route g) (g_group g) (aglset id (f (aglget id (g_agg g))) (g_agg g)) (g_closed g) (g_cnt g).
Definition close_key (g : gstate) (id k : chars) : gstate :=
  mkG (g_global g) (g_route g) (g_group g) (g_agg g) (clset id (k :: clget id (g_closed g)) (g_closed g)) (g_cnt g).
Definition is_closed (g : gstate) (id k : chars) : bool := existsb (ceqs k) (clget id (g_closed g)).
(** The aggregated exchange is its own exchange: no exception, not stopped, the error handler in use. *)
Definition fresh (x : exchange) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) None false true false false [] None (x_route x) (x_cont x).

(** Whether steps contain a doTry, or a direct call (which may lead to one). *)
Fixpoint sdt (s : step) : bool :=
  let fix l (ss : list step) : bool := match ss with [] => false | x :: r => sdt x || l r end in
  let fix lw (ws : list (expr * list step)) : bool := match ws with [] => false | (_, b) :: r => l b || lw r end in
  let fix lc (cs : list (list chars * option expr * list step)) : bool :=
    match cs with [] => false | (_, b) :: r => l b || lc r end in
  match s with
  | SDoTry _ _ _ => true
  | STo (EDirect _) => true
  | SFilter _ b | SPipeline b | SSplit _ _ b | SAggregate _ b | SLoop _ _ _ b | SIdem _ _ _ _ b => l b
  | SMulticast _ b | SLB _ _ b => l b
  | SChoice ws o => lw ws || match o with Some b => l b | None => false end
  | _ => false
  end.
Definition lsdt (ss : list step) : bool := existsb sdt ss.

Inductive agres : Type :=
| AgCont (g : gstate)                    (* aggregated; the group is not complete *)
| AgEmit (g : gstate) (agx : exchange)   (* complete: the aggregated exchange goes through the steps *)
| AgFail (e : exn)
| AgUns (why : string).

Definition same_as_first (ins : list exchange) : bool :=
  match ins with
  | [] => true
  | y :: r => forallb (fun z => kvset_eqb (m_headers (x_msg z)) (m_headers (x_msg y)) && kvset_eqb (x_props z) (x_props y)) r
  end.
(*! R L2.aggregate.step DOC [AGG.22-23] [AGG.51-52] [AGG.244-280] [M:aggregate.correlationExpression] [M:aggregate.completionSize] [M:aggregate.completionPredicate] [M:aggregate.eagerCheckCompletion] [M:aggregate.closeCorrelationKeyOnCompletion] [AS] [GBS] *)
(** "Messages with the same correlation key are aggregated together, using an AggregationStrategy" [AGG.22-23];
    the strategy is mandatory [AGG.61-62] and so is a completion [AGG.280] (route creation fails otherwise: not modelled,
    UNSPECIFIED). completionSize: "after X aggregated exchanges its complete" [AGG.256-257]; completionPredicate runs
    "when a new exchange is aggregated" [AGG.258-259], against the aggregated exchange, or the incoming one with
    eagerCheckCompletion [M:aggregate.eagerCheckCompletion]; "the first that triggers wins" [AGG.274-277]. A closed key
    (closeCorrelationKeyOnCompletion): "Late arriving exchanges with a closed correlation key will throw a
    ClosedCorrelationKeyException". A key that "cannot be evaluated" throws "an Exception" (class not documented:
    UNSPECIFIED). useLatest keeps the latest incoming exchange; groupedBody a List of the bodies; which headers and
    properties the groupedBody exchange has is not documented (UNSPECIFIED unless all incoming agree). *)
Definition agg_step (x : exchange) (g : gstate) (o : agg_opts) : agres :=
  match ago_strat o with
  | StNone => AgUns "AGG: no aggregation strategy (mandatory; refused at route creation) not modelled"
  | StOriginal => AgUns "AGG: useOriginal in an aggregator (which exchange is 'original') not documented"
  | st =>
  match ago_size o, ago_pred o with
  | None, None => AgUns "AGG: no completion (mandatory; refused at route creation) not modelled"
  | _, _ =>
  match eval_expr x (ago_corr o) with
  | EUns w => AgUns w
  | EV v =>
  match v, text_of v with
  | VNull, _ =>
      (*! R L2.aggregate.null-key CODE AggregateProcessor.doProcess ("Invalid correlation key") *)
      (* [M:aggregate.correlationExpression]: "If the correlation key cannot be evaluated an Exception is thrown"; the
         class is not documented: Camel throws a CamelExchangeException (runs/agg3-real: 134 of 134 recorded). *)
      AgFail (mkExn (str "org.apache.camel.CamelExchangeException") (str "?") None)
  | _, None => AgUns "AGG: correlation key that is a List not modelled"
  | _, Some k =>
  if ago_close o && is_closed g (ago_id o) k
  then AgFail (mkExn (str "org.apache.camel.processor.aggregate.ClosedCorrelationKeyException") (str "?") None)
  else
  let old := agget k (aglget (ago_id o) (g_agg g)) in
  let n := match old with Some a => S (ag_n a) | None => 1 end in
  let ins := match old with Some a => ag_in a | None => [] end ++ [x] in
  let agx := match st with
             | StGroupedBody => match texts (map (fun y => m_body (x_msg y)) ins), ins with
                                | Some ts, y :: _ => Some (set_body (fresh y) (VList ts))
                                | _, _ => None end
             | _ => Some (fresh x)
             end in
  match agx with
  | None => AgUns "AGG: groupedBody of bodies that are not all Strings not modelled"
  | Some agx =>
  if negb (match st with StGroupedBody => same_as_first ins | _ => true end)
  then AgUns "AGG: groupedBody of exchanges with different headers/properties (which ones it keeps) not documented"
  else
  let by_size := match ago_size o with Some s => Nat.leb s n | None => false end in
  match match ago_pred o with
        | None => PB false
        | Some p => eval_pred (if ago_eager o then x else agx) p
        end with
  | PUns w => AgUns w
  | PB by_pred =>
      if by_size || by_pred then
        let g1 := with_groups g (ago_id o) (agdel k) in
        AgEmit (if ago_close o then close_key g1 (ago_id o) k else g1) agx
      else AgCont (with_groups g (ago_id o) (agput k (mkAG agx n ins)))
  end end end end end end.

(*! R L2.loop.count DOC [LOOP.43-47] [M:loop.expression] L0.TC *)
(** The number of iterations: the expression's result "is converted to an integer" [M:loop.expression]; it "must
    evaluate to an int, otherwise a RuntimeCamelException is thrown" [LOOP.46-47]. The conversion is L0's (Convert.v).
    A negative count, and a null result, are not documented. *)
Inductive lcount : Type := LcN (n : nat) | LcFail | LcUns (why : string).
Definition loop_count (v : val) : lcount :=
  match v with
  | VNull => LcUns "LOOP: a null loop count not documented"
  | _ => match Convert.conv_of v Convert.TInteger with
         | Convert.KV (VInt z) => if Z.ltb z 0 then LcUns "LOOP: a negative loop count not documented" else LcN (Z.to_nat z)
         | Convert.KCannot _ => LcFail
         | Convert.KUns w => LcUns w
         | _ => LcUns "LOOP: the loop count converts to something other than an Integer"
         end
  end.
(*! R L2.loop.count-failure CODE TypeConverter (Integer.valueOf), runs/loop1 *)
(** [LOOP.46-47] says "a RuntimeCamelException is thrown"; Camel throws its subclass TypeConversionException
    (TypeConversionException.java: extends RuntimeCamelException), caused by the NumberFormatException of the text
    conversion (runs/loop1: 101 of 101; an onException for NumberFormatException matches it through the cause). *)
(** A copy-mode iteration starts from a copy of the original exchange [LOOP.30-31] but stays in the same unit of work
    (only Split/Multicast make a new one [SPL.1513-1514]): the idempotent ids added so far are kept (FIX, runs/ic6-real
    random-111-2898). *)
Definition loop_copy (orig cur : exchange) : exchange :=
  let c := copy_of orig in
  mkX (x_msg c) (x_props c) (x_vars c) (x_mep c) (x_exn c) (x_stop c) (x_eh c) (x_seen c) (x_done c) (x_uow cur) (x_orig cur) (x_route cur) (x_cont cur).
Definition rce : exn := mkExn (str "org.apache.camel.TypeConversionException") (str "?")
                          (Some (mkExn (str "java.lang.NumberFormatException") (str "?") None)).

(** ** Idempotent consumer and load balancers: helpers *)
Definition add_key (g : gstate) (id k : chars) : gstate := close_key g id k.
Definition add_uow (x : exchange) (id k : chars) : exchange :=
  mkX (x_msg x) (x_props x) (x_vars x) (x_mep x) (x_exn x) (x_stop x) (x_eh x) (x_seen x) (x_done x) ((id, k) :: x_uow x) (x_orig x) (x_route x) (x_cont x).
Definition remove_key (g : gstate) (idk : chars * chars) : gstate :=
  let '(id, k) := idk in
  mkG (g_global g) (g_route g) (g_group g) (g_agg g)
      (clset id (filter (fun k' => negb (ceqs k k')) (clget id (g_closed g))) (g_closed g)) (g_cnt g).
(*! R L2.idempotent.completion DOC [IC.16-19] [M:idempotentConsumer.removeOnFailure] [SPL.1513-1514] *)
(** "On completion Camel will remove the message id from the repository if the Exchange failed, otherwise it stays
    there" [IC.18-19] (removeOnFailure defaults to true): at the end of the unit of work (the end of a send; a split
    message has its own unit of work [SPL.1513-1514]). An exception handled by onException is not a failure. *)
(*! R L2.idempotent.completion.handled DOC-BUG IdempotentOnCompletion.onComplete *)
(** [IC.18-19] says the id is removed "if the Exchange failed"; an exception handled by onException makes the exchange
    "succeed" [DEH.22-23], yet Camel removes the id then too, deliberately: IdempotentOnCompletion.onComplete, "the
    exchange did not process successfully but was failure handled ... We should thus not consider it as complete"
    (probe harness/probes/IdemHandledProbe.java). The rule follows Camel; the doc gap is in findings/doc-bugs.md. *)
Definition complete_uow (real : bool) (g : gstate) (x : exchange) : gstate :=
  if (match x_exn x with Some _ => true | None => false end) || x_done x
  then fold_left remove_key (x_uow x) g else g.
Fixpoint cntget (k : chars) (l : list (chars * nat)) : nat :=
  match l with [] => 0 | (k', n) :: r => if ceqs k k' then n else cntget k r end.
Fixpoint cntset (k : chars) (n : nat) (l : list (chars * nat)) : list (chars * nat) :=
  match l with [] => [(k, n)] | (k', m) :: r => if ceqs k k' then (k', n) :: r else (k', m) :: cntset k n r end.
Definition bump (g : gstate) (id : chars) : gstate :=
  mkG (g_global g) (g_route g) (g_group g) (g_agg g) (g_closed g) (cntset id (S (cntget id (g_cnt g))) (g_cnt g)).
(** The exchange is the same as before a failed attempt (exception aside): failing over is then documented. *)
Definition same_state (y x : exchange) : bool :=
  veqb (m_body (x_msg y)) (m_body (x_msg x)) && kvset_eqb (m_headers (x_msg y)) (m_headers (x_msg x)) &&
  kvset_eqb (x_props y) (x_props x) && kveqb (x_vars y) (x_vars x).
Definition fo_attempts (n : nat) (maxf : Z) : nat :=
  if Z.ltb maxf 0 then n else Nat.min n (S (Z.to_nat maxf)).
(** "A list of class names for specific exceptions to monitor. If no exceptions are configured then all exceptions are
    monitored" [M:lb:failoverLoadBalancer.exception]; whether the causes count is not documented (UNSPECIFIED). *)
(*! R L2.lb.failover.suppressed.real CODE findings/2026-10-26-failover-monitors-suppressed-exceptions.md *)
(** Real-mode delta: Camel also fails over when a monitored class is only among the SUPPRESSED exceptions
    (ObjectHelper.getException checks them first). *)
Definition fo_monitored (real : bool) (exs : list chars) (e : exn) : r0 bool :=
  match exs with
  | [] => Ok0 true
  | _ => match e with
         | mkExnS c _ None sup =>
             match any_instance c exs with
             | Ok0 true => Ok0 true
             | Ok0 false => if real then chain_instance sup exs else Ok0 false
             | Uns0 w => Uns0 w
             end
         | _ => Uns0 "FO: monitored exceptions and causes not documented"
         end
  end.

(*! R L2.recipientList.uris DOC [M:recipientList.expression] [M:recipientList.delimiter] [RLE.4] *)
(** The expression gives "a comma-separated string, a Collection, or an Iterator of endpoint URIs"
    [M:recipientList.expression], with the [delimiter] option. Here only [direct:] and [mock:] URIs are modelled;
    any other URI, an empty one, or a null result is UNSPECIFIED (invalid-endpoint handling: not yet). *)
Definition uri_of (u : chars) : option endpoint :=
  match strip (str "direct:") u with
  | Some ((_ :: _) as n) => Some (EDirect n)
  | _ => match strip (str "mock:") u with Some ((_ :: _) as n) => Some (EMock n) | _ => None end
  end.
Fixpoint uris_of (l : list chars) : r0 (list endpoint) :=
  match l with
  | [] => Ok0 []
  | u :: r => match uri_of u, uris_of r with
              | Some e, Ok0 es => Ok0 (e :: es)
              | None, _ => Uns0 "RLE: recipient URI other than direct:/mock: (or empty) not modelled"
              | _, Uns0 w => Uns0 w
              end
  end.
Definition recipients (delim : chars) (v : val) : r0 (list endpoint) :=
  match v with
  | VStr s => match delim with
              | [d] => uris_of (split_on d s)
              | _ => if ceqs delim (str "false") then uris_of [s] else Uns0 "RLE: delimiter of several characters not modelled"
              end
  | VList l => uris_of l
  | _ => Uns0 "RLE: recipient expression result other than String or List not modelled"
  end.

(*! R L2.routingSlip.uris DOC [RS.37-39] [RS.81] [RS.90-101] [M:routingSlip.uriDelimiter] *)
(** The slip: "a comma-delimited string of endpoint URIs" (the uriDelimiter option), or a Collection [RS.81,
    RS.92-101]; "A slip can be empty, meaning that the message will not be routed anywhere" [RS.39]. Only direct:/mock:
    URIs are modelled (as for the recipient list). *)
Definition slip_of (delim : chars) (v : val) : r0 (list endpoint) :=
  match v with
  | VStr [] => Ok0 []
  | VList [] => Ok0 []
  | VNull => Uns0 "RS: a null slip not documented"
  | _ => recipients delim v
  end.
(** The exception of a mandatory conversion that is not possible: its class is one of two (TypeConversionException
    when the converter fails, NoTypeConversionAvailableException when there is none [M:convertBodyTo.mandatory]); the
    harness compares only that the exchange failed (class and message "?"). *)
Definition any_exn : exn := mkExn (str "?") (str "?") None.
(*! R L2.convertBodyTo DOC [CB.9] [M:convertBodyTo.mandatory] [M:convertBodyTo.24] L0.TC *)
(** The body converted by L0's rules (Convert.v): mandatory (the default) like mandatoryConvertTo but failing when
    "conversion is not possible" [M:convertBodyTo.mandatory]; not mandatory like convertTo, "null may be returned if
    conversion is not possible" [M:convertBodyTo.mandatory, M:convertBodyTo.24]. Outcomes that L0 leaves open stay
    UNSPECIFIED. *)
Inductive cbres : Type := CbBody (v : val) | CbFail | CbUns (why : string).
Definition convert_body (t : Convert.jtype) (mandatory : bool) (v : val) : cbres :=
  match Convert.conv_of v t, mandatory with
  | Convert.KV w, _ => CbBody w
  | Convert.KCannot _, true => CbFail
  | Convert.KNull, false => CbBody VNull
  | Convert.KDec _, _ => CbUns "CB: a BigDecimal body is not a modelled value"
  | Convert.KUns w, _ => CbUns w
  | Convert.KCannot _, false => CbUns "CB: convertTo of a value that cannot be converted: null or TypeConversionException (L0)"
  | Convert.KNull, true => CbUns "CB: mandatory conversion of null: outcome not documented (L0)"
  end.


(** "the original exception is kept and the exception from the doFinally block is added as a suppressed exception"
    [DT.227-229]. *)
Definition keep_pending (e : exn) (x' : exchange) : exchange :=
  set_exn x' (Some (match x_exn x' with Some e2 => add_suppressed e e2 | None => e end)).
Definition keep (p : option exn) (x : exchange) : exchange :=
  match p with Some e => set_exn x (Some e) | None => x end.

(** ** The rules *)

(** The routing of an exchange stops once it failed or was marked stopped. *)
Definition halted (x : exchange) : bool :=
  x_stop x || x_done x || match x_exn x with Some _ => true | None => false end.

Section Rules.
Variable P : list route.
(** [real]: the Real mode of CONVENTIONS practice 2. False: the rules as documented (Doc). True: Doc plus the open
    findings as explicit deltas, each naming its finding file, so that a differential run in Real mode shows only
    NEW disagreements. Every use of [real] below is such a delta. *)
Variable real : bool.
(*! R L2.split.abort-result.real CODE findings/2026-10-26-split-maxfailedrecords-abort-returns-item-message.md *)
(** Real-mode delta: on an abort by maxFailedRecords Camel returns the MESSAGE (body and headers) of the failed
    sub-exchange with the wrapped exception, not the original message, and MERGES the sub-exchange's properties into
    the original's: a property set in the failing item is there afterwards, one removed in it is still there too
    (runs/enc-real: random-41-1967, random-41-3291). *)
Definition merge_props (base over : list (chars * val)) : list (chars * val) :=
  fold_left (fun acc '(k, v) => pset k v acc) over base.
(** ** onException: which clause handles an exception (L3) *)
Variable C : list clause.
Variable EHc : ehconf.
Definition is_dlc : bool := match EHc with EHDlc _ _ _ => true | EHDefault => false end.

(** Distance from class [c] up to [t] in the class table: [Some 0] when equal, [None] when [t] is not a superclass. *)
Fixpoint dist_f (fuel : nat) (c t : chars) : r0 (option nat) :=
  match fuel with
  | O => Uns0 "L0: class hierarchy deeper than the table"
  | S f => if ceqs c t then match jdk_super t with Some _ => Ok0 (Some O) | None => Uns0 "L0: exception class outside the table" end
           else match jdk_super c with
                | None => Uns0 "L0: exception class outside the table"
                | Some None => match jdk_super t with Some _ => Ok0 None | None => Uns0 "L0: exception class outside the table" end
                | Some (Some p) => match dist_f f p t with Ok0 d => Ok0 (option_map S d) | Uns0 w => Uns0 w end
                end
  end.
Definition lt2 (a b : nat * nat) : bool :=
  Nat.ltb (fst a) (fst b) || (Nat.eqb (fst a) (fst b) && Nat.ltb (snd a) (snd b)).
Definition eq2 (a b : nat * nat) : bool := Nat.eqb (fst a) (fst b) && Nat.eqb (snd a) (snd b).
Definition best (a b : option (nat * nat)) : option (nat * nat) :=
  match a, b with Some p, Some q => Some (if lt2 q p then q else p) | Some p, None => Some p | None, q => q end.
(** The score of a clause: the closest (distance, nesting index) over the exception chain (root cause first, index 0)
    and the clause's classes. *)
Fixpoint score_cls (c : chars) (i : nat) (ts : list chars) : r0 (option (nat * nat)) :=
  match ts with
  | [] => Ok0 None
  | t :: r => match dist_f 20 c t, score_cls c i r with
              | Ok0 d, Ok0 b => Ok0 (best (option_map (fun d => (d, i)) d) b)
              | Uns0 w, _ | _, Uns0 w => Uns0 w
              end
  end.
Fixpoint score_chain (es : list exn) (i : nat) (ts : list chars) : r0 (option (nat * nat)) :=
  match es with
  | [] => Ok0 None
  | e :: r => match score_cls (exn_class e) i ts, score_chain r (S i) ts with
              | Ok0 a, Ok0 b => Ok0 (best a b)
              | Uns0 w, _ | _, Uns0 w => Uns0 w
              end
  end.
(*! R L3.onException.select DOC [EC.171-197] *)
(** "Camel tests the thrown exception, and each of its causes ... instanceof ... An exact match is preferred, otherwise
    the onException clause that has an exception that is the closest super class ... The closest match wins, across
    the thrown exception and all its causes ... When two clauses are equally close, the match on the most nested cause
    (bottom) wins ... An onException with an onWhen predicate only matches when the predicate is true ... If the same
    exception is configured in more than one onException (in the same scope, without onWhen), then the last one
    configured is used" [EC.177-197]. Equally close clauses where one has an onWhen: not documented. *)
Fixpoint candidates (x : exchange) (e : exn) (cs : list clause) : r0 (list ((nat * nat) * bool * clause)) :=
  match cs with
  | [] => Ok0 []
  | k :: r =>
      match score_chain (exn_chain e) 0 (c_ex k), candidates x e r with
      | Uns0 w, _ | _, Uns0 w => Uns0 w
      | Ok0 None, Ok0 l => Ok0 l
      | Ok0 (Some sc), Ok0 l =>
          match c_when k with
          | None => Ok0 ((sc, false, k) :: l)
          | Some p => match eval_pred x p with
                      | PB true => Ok0 ((sc, true, k) :: l)
                      | PB false => Ok0 l
                      | PUns w => Uns0 w
                      end
          end
      end
  end.
Fixpoint min_score (l : list ((nat * nat) * bool * clause)) : option (nat * nat) :=
  match l with [] => None | (sc, _, _) :: r => best (Some sc) (min_score r) end.
(** The clauses that apply in the exchange's route: the global ones, and the ones of that route [EXA.84-121]. *)
Definition in_scope (x : exchange) (k : clause) : bool :=
  match c_scope k with None => true | Some r => ceqs r (x_route x) end.
Definition is_route_scoped (k : clause) : bool := match c_scope k with Some _ => true | None => false end.
(** Whether route [rid] has clauses at all (global ones, or its own): the error handler of that route has exception
    policies (the CODE rules L3.redelivery.headers-after and the "with clauses" UNSPECIFIED classes are about this). *)
Definition has_clauses (rid : chars) : bool :=
  existsb (fun k => match c_scope k with None => true | Some r => ceqs r rid end) C.
(** Within one scope: the closest; equally close: the last configured, with onWhen not documented. *)
Definition pick_tied (l : list ((nat * nat) * bool * clause)) (m : nat * nat) : r0 (option clause) :=
  let tied := filter (fun '(sc, _, _) => eq2 sc m) l in
  match tied with
  | [(_, _, k)] => Ok0 (Some k)
  | _ => if existsb (fun '(_, w, _) => w) tied then Uns0 "EC: equally close onException clauses with onWhen"
         else match rev tied with (_, _, k) :: _ => Ok0 (Some k) | [] => Ok0 None end
  end.
(*! R L3.onException.scope DOC [EC.152-161] [EC.185-197] [EXA.84-121] [EXA.141-148] *)
(** "The closest match wins" across all the clauses that apply; "When an onException in a route and an onException
    in the RouteBuilder (context scoped) are equally close, then the one in the route wins" [EC.189-191]; "the last
    one configured is used" is within "the same scope" [EC.194-196]. Equally close by distance but not by the nesting
    of the cause, across the two scopes: the two tie rules [EC.187-191] do not say which comes first (no rule). *)
Definition select_clause (x : exchange) (e : exn) : r0 (option clause) :=
  match candidates x e (filter (in_scope x) C) with
  | Uns0 w => Uns0 w
  | Ok0 l =>
      let lr := filter (fun '(_, _, k) => is_route_scoped k) l in
      let lg := filter (fun '(_, _, k) => negb (is_route_scoped k)) l in
      match min_score lr, min_score lg with
      | None, None => Ok0 None
      | Some mr, None => pick_tied lr mr
      | None, Some mg => pick_tied lg mg
      | Some mr, Some mg =>
          if Nat.ltb (fst mr) (fst mg) then pick_tied lr mr
          else if Nat.ltb (fst mg) (fst mr) then pick_tied lg mg
          else if Nat.eqb (snd mr) (snd mg) then pick_tied lr mr
          else Uns0 "EC: route and global clauses equally close by class but not by the nested cause (tie rules' order not documented)"
      end
  end.
(** Whether the route's error handler would act on an exception at this point (a clause matches it, or the error
    handler is a dead letter channel, which handles every exception no clause takes [DLC.21]): then the routing below
    needs a rule. *)
Definition clause_matches (x : exchange) : bool :=
  match x_exn x with
  | Some e => match select_clause x e with Ok0 None => is_dlc | _ => true end
  | None => false
  end.
(*! R L3.redelivery.headers DOC [DLC.573-584] [EXJ.279-281] [ER.18-19] [ER.110-126] [DEH.5-8] *)
(** Redelivery starts at the point of failure [ER.110-126]: a throwException fails again on each attempt, so after
    maximumRedeliveries attempts it is exhausted. "When a message is redelivered ... the following headers" with the
    state [DLC.575-584]: CamelRedelivered (Boolean), CamelRedeliveryCounter (the current attempt),
    CamelRedeliveryMaxCounter (the maximum configured) [EXJ.279-281]. No redelivery: no headers (absent). *)
Definition redelivery_headers (n : nat) (x : exchange) : exchange :=
  match n with
  | O => x
  | S _ => map_headers (fun hs => hset (str "CamelRedeliveryMaxCounter") (VInt (Z.of_nat n))
                                   (hset (str "CamelRedeliveryCounter") (VInt (Z.of_nat n))
                                   (hset (str "CamelRedelivered") (VBool true) hs))) x
  end.
(*! R L3.onException.outcome DOC [EHP.60-74] [EHP.414-418] [EHP.527-539] [DEH.18-23] [M:onException.handled] *)
(** After the onException block: continued resumes the route after the failing step [EHP.416-418, EHP.536-539];
    handled ends the routing successfully, the response being "whatever this onException block produces"
    [M:onException.handled, EHP.65-67, DEH.22-23]; otherwise the exception is "propagated back to the caller"
    [DEH.18-19]. The block runs with the exception cleared [EHP.70-71]. EHP.68-69 says "If you don't set a response,
    the caller gets an empty body": we follow [M:onException.handled] / EHP.67 (the body as the block leaves it) and
    note the conflict (notes/main.md). Both handled and continued true: not documented (no rule). *)
(*! R L3.redelivery.headers-after CODE RedeliveryErrorHandler (probe harness/probes/EhProbe.java, 2026-10-26) *)
(** Not documented (the docs only say what is added "When a message is redelivered" [DLC.575-576]); Camel, when the
    route has onException clauses: a handled or continued exchange has none of the three headers afterwards (even
    after redeliveries); an exchange whose exception goes back to the caller has CamelRedelivered=false and
    CamelRedeliveryCounter=0 when it was not redelivered (added after the onException block, which sees none of
    them). Adopted as CODE rules from probes (handled, continued, not handled, no match, with/without redelivery). *)
Definition drop_redelivery_headers (x : exchange) : exchange :=
  map_headers (fun hs => hremove (str "CamelRedeliveryMaxCounter") (hremove (str "CamelRedeliveryCounter")
                         (hremove (str "CamelRedelivered") hs))) x.
Definition not_redelivered_headers (n : nat) (x : exchange) : exchange :=
  match n with
  | O => map_headers (fun hs => hset (str "CamelRedeliveryCounter") (VInt 0) (hset (str "CamelRedelivered") (VBool false) hs)) x
  | S _ => x
  end.
Definition eh_outcome_n (k : clause) (n : nat) (x : exchange) (e : exn) (y : exchange) : option exchange :=
  if c_continued k then
    match c_handled k with Some true => None | _ => Some (set_cont (drop_redelivery_headers (set_eh y (x_eh x))) true) end
  else match c_handled k with
       | Some true => Some (drop_redelivery_headers (set_done (set_eh y (x_eh x)) true))
       | _ => Some (set_seen (set_exn (not_redelivered_headers n (set_eh y (x_eh x))) (Some e)) true)
       end.
Definition eh_outcome (k : clause) (x : exchange) (e : exn) (y : exchange) : option exchange :=
  if c_continued k then
    match c_handled k with Some true => None | _ => Some (drop_redelivery_headers (set_eh y (x_eh x))) end
  else match c_handled k with
       | Some true => Some (drop_redelivery_headers (set_done (set_eh y (x_eh x)) true))
       | _ => Some (set_seen (set_exn (not_redelivered_headers (c_redeliveries k) (set_eh y (x_eh x))) (Some e)) true)
       end.
(** What the onException block sees: the redelivery headers, except with handled or continued, where Camel removes
    them before the block runs (CODE as above: 3 attempts are made in all three modes; only the not-handled block sees
    CamelRedelivered=true and the counters, or false and 0 without redelivery). *)
Definition block_input (k : clause) (x : exchange) : exchange :=
  if c_continued k || match c_handled k with Some true => true | _ => false end then x
  else match c_redeliveries k with O => not_redelivered_headers 0 x | n => redelivery_headers n x end.
(*! R L3.retryWhile DOC [EXA.393-425] [DLC.583-584] [M:onException.retryWhile] *)
(** "Camel will redeliver until the predicate returns false"; the redelivery counter "is the redelivery attempt, will
    start from 1" [EXA.396-397, EXA.421]; retryWhile "will overrule" the maximum redeliveries [EXA.405-407]; the
    CamelRedeliveryMaxCounter header "is absent if you use retryWhile" [DLC.583-584]. The predicate is evaluated on
    the failed exchange with CamelRedelivered=true and CamelRedeliveryCounter=k for the k-th redelivery. A predicate
    still true after 10 redeliveries: redelivery forever (not modelled, the generator bounds the counter). *)
Fixpoint retry_n (fuel k : nat) (p : expr) (x : exchange) : r0 nat :=
  match fuel with
  | O => Uns0 "EXA: retryWhile still true after 10 redeliveries (redelivery forever: not modelled)"
  | S f =>
      match eval_pred (map_headers (fun hs => hset (str "CamelRedeliveryCounter") (VInt (Z.of_nat k))
                                               (hset (str "CamelRedelivered") (VBool true) hs)) x) p with
      | PB true => match retry_n f (S k) p x with Ok0 n => Ok0 (S n) | Uns0 w => Uns0 w end
      | PB false => Ok0 O
      | PUns w => Uns0 w
      end
  end.
(** With retryWhile (and so a redelivery option on the clause), the clause inherits the error handler's
    maximumRedeliveries [ER.21-25]; whether the max counter header then shows it conflicts with [DLC.583-584]: no rule
    when that inherited maximum is not 0 (Camel shows it: runs/rw1-real random-601-2900; doc-bugs.md). *)
(*! R L3.redelivery.stepless-inherit DOC-BUG [ER.17-19] ExceptionPolicy.createRedeliveryPolicy *)
(** [ER.17-19]: "By default, any Exception Clause will not redeliver! (as it sets the maximumRedeliveries option to
    0)". Camel does that only for a clause with steps; a clause without steps (and without maximumRedeliveries) uses the
    error handler's policy, so it redelivers as the error handler does (ExceptionPolicy.createRedeliveryPolicy 114-128,
    "this is the behavior Camel has always had"; harness/probes/OnRedeliveryInheritProbe.java: 3 attempts under a dead
    letter channel with maximumRedeliveries 2, also on 4.22.1 and 4.23.0). The doc text is the bug (doc-bugs.md). *)
Definition eh_max : nat := match EHc with EHDlc _ n _ => n | EHDefault => O end.
Definition redeliveries (k : clause) (x : exchange) : r0 nat :=
  match c_retry k with
  | None => Ok0 (match c_redeliveries k, c_steps k with O, [] => eh_max | n, _ => n end)
  | Some p => match EHc with
              | EHDlc _ (S _) _ => Uns0 "ER/DLC: retryWhile with a maximumRedeliveries inherited from the error handler (max counter header: docs conflict)"
              | _ => retry_n 10 1 p x
              end
  end.
(*! R L3.onRedelivery DOC [EXA.242-253] [DLC.345-396] [M:onException.onRedeliveryRef] *)
(** "a processor that is invoked before each redelivery attempt. Can be used to change the exchange before it is
    redelivered" [M:onException.onRedeliveryRef]. The harness's processor (the registry bean "onRedel") appends "r" to
    the header onr. *)
(*! R L3.onRedelivery.reset CODE harness/probes/RetryWhileProbe.java *)
(** Not documented: whether the changes of one onRedelivery call are still there at the next. Camel restores the
    message before each redelivery (probe: 2 redeliveries, 2 calls, onr="r"): after n >= 1 redeliveries the exchange
    is the failed one with one call's changes. *)
Definition onr_apply (x : exchange) : exchange :=
  let s := match hget (str "onr") (m_headers (x_msg x)) with VStr t => t | _ => [] end in
  map_headers (hset (str "onr") (VStr (s ++ str "r"))) x.
Definition after_redelivery (k : clause) (n : nat) (x : exchange) : exchange :=
  match n with O => x | S _ => if c_onredel k then onr_apply x else x end.
Definition redelivery_headers_rw (rw : bool) (n : nat) (x : exchange) : exchange :=
  if rw then map_headers (fun hs => hset (str "CamelRedeliveryCounter") (VInt (Z.of_nat n)) (hset (str "CamelRedelivered") (VBool true) hs)) x
  else redelivery_headers n x.
(** [block_input] with the number of redeliveries made and whether retryWhile decided it. *)
Definition block_input_n (k : clause) (n : nat) (x : exchange) : exchange :=
  let x := after_redelivery k n x in
  if c_continued k || match c_handled k with Some true => true | _ => false end then x
  else match n with O => not_redelivered_headers 0 x | _ => redelivery_headers_rw (match c_retry k with Some _ => true | None => false end) n x end.
(** A new exception that surfaces at a composite step (a split/multicast wrapper) and that no clause matches goes
    on to the caller; it gets no redelivery headers there (runs/oe3-real random-61-2239). *)
Definition surface (x : exchange) : exchange :=
  match x_exn x with Some _ => if x_eh x then set_seen x true else x | None => x end.
(** The default outcome (no clause matches): the exception goes back; with clauses in the route, the
    not-redelivered headers are added (CODE, as above). *)
Definition default_failed (x : exchange) (e : exn) : exchange :=
  let x1 := set_seen (set_exn x (Some e)) (x_eh x) in
  if x_eh x && has_clauses (x_route x) then not_redelivered_headers 0 x1 else x1.
(*! R L3.dlc DOC [DLC.21] [DLC.184-228] [DLC.230-291] [M:deadLetterChannel.useOriginalMessage] [M:deadLetterChannel.useOriginalBody] *)
(** "Unlike the default error handler, the dead letter channel will, by default, handle exceptions and move the
    failed messages to the dead letter queue" [DLC.21]; "When all attempts of redelivery have failed, the Exchange is
    moved to the dead letter queue. The exchange is then complete, and from the client point of view, the message is
    done being processed" [DLC.186-188]; it "will clear the caused exception ... and the client will not notice the
    failure" [DLC.226-228]. The message moved is the current one, or with useOriginalMessage "the original incoming
    message" (body and headers), with useOriginalBody the original body "and does not change the message headers"
    [DLC.230-291]; exchange properties are not part of the message (kept). An unknown original (the output of an
    aggregator): no rule. *)
(*! R L3.dlc.result CODE harness/probes/DlcProbe.java *)
(** Not documented: what the caller gets (the docs only say it "will not notice the failure") and whether the
    redelivery headers stay. Camel (probe: maximumRedeliveries 0 and 1, all three modes, plain / direct / split): the
    caller gets the exchange that was moved (the same message), and neither has the redelivery headers (as for a
    handled onException, L3.redelivery.headers-after). *)
Definition dlc_msg (uo : uomode) (x : exchange) : option message :=
  match uo with
  | UONone => Some (x_msg x)
  | UOMessage => x_orig x
  | UOBody => option_map (fun o => mkMsg (m_body o) (m_headers (x_msg x))) (x_orig x)
  end.
Definition dlc_out (uo : uomode) (x : exchange) : option exchange :=
  option_map (fun m => drop_redelivery_headers (set_done (with_msg (set_exn x None) m) true)) (dlc_msg uo x).
(*! R L3.dlc.clause-redelivery DOC [ER.17-31] [ER.43-62] [DLC.140] *)
(** An onException clause with no steps configures the redelivery "on a per exception type basis" [ER.27-28]
    (maximumRedeliveries on the clause [ER.43-62]); "Only when all redelivery attempts have failed, then the message
    is moved to the dead letter queue" [DLC.140]: with a dead letter channel, such a clause (not continued) leaves
    the failure to it. With handled set explicitly on such a clause, the docs give two answers (handled: "only the steps
    in this onException block execute" [M:onException.handled]; the dead letter channel handles): no rule (Camel moves
    the exchange to the dead letter queue in both cases, harness/probes/DlcEmptyClauseProbe.java). *)
(** A failure of a step (not a throwException: a bad loop count, a failed conversion, a closed correlation key) that
    no clause takes, with a dead letter channel: moved as in L3.dlc. *)
Definition dlc_fail (x : exchange) (e : exn) : option (exchange * list event) :=
  if x_eh x then
    match select_clause (set_exn x (Some e)) e, EHc with
    | Ok0 None, EHDlc q _ uo => option_map (fun x' => (x', [EvMock q x' false])) (dlc_out uo x)
    | _, _ => None
    end
  else None.
Lemma dlc_fail_matches : forall x e p, dlc_fail x e = Some p -> (x_eh x && clause_matches (set_exn x (Some e))) = true.
Proof.
  intros x e p H. unfold dlc_fail in H. destruct (x_eh x); [|discriminate]. simpl.
  unfold clause_matches, is_dlc. simpl.
  destruct (select_clause (set_exn x (Some e)) e) as [[k|]|w]; try discriminate.
  destruct EHc; [discriminate|reflexivity].
Qed.
Definition dlc_takes (k : clause) : bool :=
  is_dlc && match c_steps k with [] => negb (c_continued k) | _ => false end.
(** An exception out of a doTry is not handled again [DT.223-225]. *)
Definition seen_if_failed (x : exchange) : exchange :=
  match x_exn x with Some _ => set_seen x true | None => x end.

Definition abort_result (x y : exchange) (e : exn) : exchange :=
  if real then set_exn (map_props (fun ps => merge_props ps (x_props y)) (with_msg x (x_msg y))) (Some (cee e))
  else set_exn x (Some (cee e)).
Definition find_route (n : chars) : option route := List.find (fun r => ceqs (r_from r) n) P.

Inductive bss : gstate -> exchange -> list step -> gstate -> exchange -> list event -> Prop :=
(*! R L2.pipeline.nil DOC [PL.131-132] *)
| BNil : forall g x, bss g x [] g x []
(*! R L2.pipeline.halt DOC [EH.29-32] [M:stop.6] [M:throwException.24] *)
(** A failed exchange propagates back to the caller with the default error handler [EH.29-32]; a stopped one goes
    "without sending it to any further steps" [M:stop.6]. *)
| BHalt : forall g x s ss, halted x = true -> bss g x (s :: ss) g x []
(*! R L2.pipeline.seq DOC [PL.131-132] [PL.82-83] *)
(** The output of a step is the input of the next [PL.131-132]; several outputs are a pipeline [PL.82-83]. *)
(*! R L3.errorHandler.composite-failure DOC [EH.29-32] *)
(** A new exception that surfaces at a composite step (a split or multicast wrapper) where the route's error handler is
    in use and a clause would match it: how that step is retried/handled is not modelled (no rule). *)
| BCons : forall g x s ss g1 x1 t1 g2 x2 t2,
    halted x = false -> bs1 g x s g1 x1 t1 ->
    (x_eh x1 && negb (x_seen x1) && clause_matches x1) = false ->
    bss g1 (surface x1) ss g2 x2 t2 -> bss g x (s :: ss) g2 x2 (t1 ++ t2)
with bs1 : gstate -> exchange -> step -> gstate -> exchange -> list event -> Prop :=
(*! R L2.setBody DOC [M:setBody.24] [EP.24-26] *)
| BSetBody : forall g x e v, eval_expr x e = EV v -> bs1 g x (SSetBody e) g (set_body x v) []
(*! R L2.transform DOC [M:transform.24] [EP.24-26] *)
(** [TR.95-98] and [SB.91-94] say transform sets the OUT message and setBody follows the exchange pattern; [EP.24-26]
    says both "always operate on the current message body regardless of the exchange pattern". We take [EP] (the
    later, explicit statement) and record the conflict in notes/main.md as a doc-bug candidate. *)
| BTransform : forall g x e v, eval_expr x e = EV v -> bs1 g x (STransform e) g (set_body x v) []
(*! R L2.setHeader DOC [SH.9] [M:setHeader.23] L0.headers.first-name-kept *)
| BSetHeader : forall g x k e v, ascii_name k = true -> eval_expr x e = EV v ->
    bs1 g x (SSetHeader k e) g (map_headers (hset k v) x) []
(*! R L2.setProperty DOC [SP.9-11] [M:setProperty.23] L0.props.null-removes *)
| BSetProperty : forall g x k e v, eval_expr x e = EV v -> bs1 g x (SSetProperty k e) g (map_props (pput k v) x) []
(*! R L2.setVariable DOC [SV.9] [M:setVariable.23] L0.vars.scope *)
| BSetVariable : forall g x k e v x' g', eval_expr x e = EV v -> var_set x g k v = Ok0 (x', g') ->
    bs1 g x (SSetVariable k e) g' x' []
(*! R L2.removeHeader DOC [RH.9] [M:removeHeader.22] L0.headers.remove *)
| BRemoveHeader : forall g x k, ascii_name k = true -> bs1 g x (SRemoveHeader k) g (map_headers (hremove k) x) []
(*! R L2.removeHeaders DOC [M:removeHeaders.23] L0.headers.remove-pattern *)
| BRemoveHeaders : forall g x pat excl hs, hremove_pat pat excl (m_headers (x_msg x)) = Ok0 hs ->
    bs1 g x (SRemoveHeaders pat excl) g (map_headers (fun _ => hs) x) []
(*! R L2.removeProperty DOC [RP.9] [M:removeProperty.22] *)
| BRemoveProperty : forall g x k, bs1 g x (SRemoveProperty k) g (map_props (premove k) x) []
(*! R L2.removeVariable DOC [RV.9] [RV.64] [M:removeVariable.22] *)
| BRemoveVariable : forall g x k x' g', var_remove x g k = Ok0 (x', g') -> bs1 g x (SRemoveVariable k) g' x' []
(*! R L2.filter.true DOC [FI.19-20] [FI.255] [M:filter.6] [M:filter.25] *)
(** "similar to [if (predicate) { block }]"; it only applies to its children [FI.19-20, FI.255]. *)
| BFilterT : forall g x p body g' x' t, eval_pred x p = PB true -> bss g x body g' x' t ->
    bs1 g x (SFilter p body) g' x' t
(*! R L2.filter.false DOC [FI.19-20] [FI.257-259] [M:filter.25] *)
| BFilterF : forall g x p body, eval_pred x p = PB false -> bs1 g x (SFilter p body) g x []
(*! R L2.choice DOC [CH.9-12] [M:choice.25] [M:when.23] [M:otherwise.22] *)
| BChoice : forall g x ws o g' x' t, bch g x ws o g' x' t -> bs1 g x (SChoice ws o) g' x' t
(*! R L2.pipeline.block DOC [PL.138] [M:pipeline.23] *)
| BPipeline : forall g x body g' x' t, bss g x body g' x' t -> bs1 g x (SPipeline body) g' x' t
(*! R L2.to.mock DOC [MC.487] [MJS: copyOnExchange] *)
(** Sending to a mock endpoint records (a copy of) the exchange and leaves it unchanged. *)
| BToMock : forall g x n, bs1 g x (STo (EMock n)) g x [EvMock n x false]
(*! R L2.to.direct DOC [DC.16-19] [TO.22] [EH.29-32] *)
(** "direct, synchronous invocation of any consumers when a producer sends a message exchange" [DC.16-17]: the
    route consuming from [direct:n] runs on the exchange, and the caller continues with what it ends with; a failure
    propagates back [EH.29-32]. A missing consumer blocks then fails [DJ: block, failIfNoConsumers, timeout]: not
    modelled. *)
(*! R L2.to.direct.stop-propagates CODE Pipeline.process PipelineHelper.continueProcessing *)
(** A stop inside the called route: the docs do not say what the caller does. In Camel the stop mark is on the
    exchange ([setRouteStop], checked by [Pipeline.process] line 91 and [PipelineHelper.continueProcessing] line 67
    at every step), so the caller stops too; adopted as a CODE rule (runs/third: 52 of 52 cases). The rule needs
    nothing extra: the caller's pipeline halts by [BHalt]. *)
(*! R L3.direct.boundary DOC [DC.16-19] [EH.29-32] *)
(** The called route has its own error handler (in use even when the caller is inside a doTry). What the caller does
    when the called route handled an exception (handled ends "being routed"), or when a failure comes back for
    which a clause matches in the caller, is not documented: no rule. *)
(*! R L3.doTry.escape.direct.real CODE findings/2026-10-26-dotry-escaping-exception-handled-when-nested.md *)
(** Real-mode delta: an exception that escaped a doTry in a called route without clauses comes back to a caller
    route that has clauses: Camel's error handler of the caller processes it (runs/sc1-real scope-701-1355): no rule. *)
| BToDirect : forall g x n r g' x' t, find_route n = Some r -> bss g (set_route (set_eh x true) (r_id r)) (r_steps r) g' x' t ->
    x_done x' = false -> clause_matches x' = false ->
    (real && match x_exn x' with Some _ => true | None => false end && x_seen x' && has_clauses (x_route x)
     && negb (has_clauses (r_id r))) = false ->
    bs1 g x (STo (EDirect n)) g' (set_route (set_eh x' (x_eh x)) (x_route x)) t
(*! R L3.dlc.direct DOC [DLC.186-188] [DLC.337-338] *)
(** The called route's dead letter channel moved the exchange: "The exchange is then complete, and from the client
    point of view, the message is done being processed" [DLC.186-188] (the unit of work spans the direct: call     [DLC.337-338]): the caller does not route it further. With clauses in the program the exchange could also have
    been handled by a clause (not documented, L3.direct.boundary): only without clauses. *)
| BToDirectDLC : forall g x n r g' x' t q k uo, find_route n = Some r -> bss g (set_route (set_eh x true) (r_id r)) (r_steps r) g' x' t ->
    x_done x' = true -> EHc = EHDlc q k uo -> has_clauses (r_id r) = false ->
    bs1 g x (STo (EDirect n)) g' (set_route (set_eh x' (x_eh x)) (x_route x)) t
(*! R L2.stop DOC [ST.9-13] [M:stop.6] [M:stop.21] *)
| BStop : forall g x, bs1 g x SStop g (set_stop x true) []
(*! R L2.throwException DOC [TE.9-13] [TE.29] [M:throwException.24] *)
(*! R L3.errorHandler.default DOC [DEH.14-19] [EH.29-32] *)
(** No clause handles the exception (or the error handler is not in use): it propagates back to the caller. *)
| BThrow : forall g x c m,
    (x_eh x = false \/ (select_clause (set_exn x (Some (mkExn c m None))) (mkExn c m None) = Ok0 None /\ EHc = EHDefault)) ->
    bs1 g x (SThrow c m) g (default_failed x (mkExn c m None)) []
(** With a dead letter channel, an exception no clause takes is moved to the dead letter endpoint (L3.dlc); the
    redelivery attempts before (at the point of failure [ER.110-126]) fail again the same way. *)
| BThrowDLC : forall g x c m q n uo x',
    x_eh x = true -> select_clause (set_exn x (Some (mkExn c m None))) (mkExn c m None) = Ok0 None ->
    EHc = EHDlc q n uo -> dlc_out uo x = Some x' ->
    bs1 g x (SThrow c m) g x' [EvMock q x' false]
(*! R L3.dlc.clause-redelivery.real CODE findings/2026-10-26-dlc-useoriginal-lost-with-onexception-redelivery.md *)
(** Real-mode delta: then Camel moves the current message (useOriginalMessage/Body of the dead letter channel is
    replaced by the clause's, unset). *)
| BThrowDLCClause : forall g x c m k q n uo x' r,
    x_eh x = true -> select_clause (set_exn x (Some (mkExn c m None))) (mkExn c m None) = Ok0 (Some k) ->
    redeliveries k (set_exn x (Some (mkExn c m None))) = Ok0 r ->
    dlc_takes k = true -> c_handled k = None -> EHc = EHDlc q n uo ->
    dlc_out (if real then UONone else uo) (after_redelivery k r x) = Some x' ->
    bs1 g x (SThrow c m) g x' [EvMock q x' false]
(*! R L3.onException DOC [EC.3-9] [EHP.60-74] [ER.18-19] [DEH.20-25] *)
| BThrowEH : forall g x c m k g' y t x' r,
    x_eh x = true -> select_clause (set_exn x (Some (mkExn c m None))) (mkExn c m None) = Ok0 (Some k) ->
    redeliveries k (set_exn x (Some (mkExn c m None))) = Ok0 r ->
    dlc_takes k = false ->
    bss g (set_eh (block_input_n k r x) false) (c_steps k) g' y t ->
    x_stop y = false -> x_exn y = None -> x_done y = false ->
    eh_outcome_n k r x (mkExn c m None) y = Some x' ->
    bs1 g x (SThrow c m) g' x' t
(*! R L3.doTry DOC [DT.9-27] [M:doTry.24] *)
(** "its own error handler and mimics how try/catch/finally works in Java" [DT.26-27]: the steps run, then what
    happens depends on how they ended ([baft]). *)
(*! R L2.loop DOC [LOOP.9] [LOOP.25-33] [M:loop.32] *)
(** "default mode ... the same Exchange instance throughout the looping. So the result from the previous iteration
    will be used for the next iteration"; "copy mode ... a copy of the original Exchange in each iteration"
    [LOOP.27-31]; the outcome is "What the last iteration ends with" [M:loop.32]. A failed or stopped iteration ends the
    loop (the exchange is halted, L2.pipeline.halt). *)
| BLoop : forall g x e cp body v n g' x' t, eval_expr x e = EV v -> loop_count v = LcN n ->
    blp g x cp body n x g' x' t -> bs1 g x (SLoop e cp false body) g' x' t
| BLoopFail : forall g x e cp body v, eval_expr x e = EV v -> loop_count v = LcFail ->
    (x_eh x && clause_matches (set_exn x (Some rce))) = false ->
    bs1 g x (SLoop e cp false body) g (default_failed x rce) []
(*! R L2.loop.while DOC [LOOP.33] [LOOP.250-255] [M:loop.doWhile] *)
(** "In the while mode, then the Loop EIP will keep looping until the expression evaluates to false or null"
    (default mode only here: while with copy is not modelled). *)
(*! R L3.dlc.step-failure DOC [DLC.21] [DLC.186-188] *)
| BLoopFailDLC : forall g x e cp body v x' t, eval_expr x e = EV v -> loop_count v = LcFail ->
    dlc_fail x rce = Some (x', t) -> bs1 g x (SLoop e cp false body) g x' t
| BLoopWhile : forall g x e body g' x' t, blw g x e body g' x' t -> bs1 g x (SLoop e false true body) g' x' t
(*! R L2.idempotent DOC [IC.11-19] [IC.62-65] [IC.120-123] [M:idempotentConsumer.32] *)
(** The id of the message is the expression's value; "A message with an id that is already in the repository is
    skipped" [IC.64-65], "acts like a Message Filter" [IC.13-14]: the exchange goes on after the block with "the body
    as it was for a duplicate message" [M:idempotentConsumer.32]; with skipDuplicate false it goes through the block
    too [IC.122-123]. "Camel will add the message id eagerly" [IC.16-17] (eager, the default). A null id, and
    eager=false, are not modelled. *)
| BIdemDup : forall g x id e eg body v k, eval_expr x e = EV v -> text_of v = Some k -> is_closed g id k = true ->
    bs1 g x (SIdem id e true eg body) g x []
| BIdemDupRun : forall g x id e eg body v k g' x' t, eval_expr x e = EV v -> text_of v = Some k ->
    is_closed g id k = true -> bss g x body g' x' t -> bs1 g x (SIdem id e false eg body) g' x' t
| BIdemNew : forall g x id e sk body v k g' x' t, eval_expr x e = EV v -> text_of v = Some k ->
    is_closed g id k = false -> bss (add_key g id k) (add_uow x id k) body g' x' t ->
    bs1 g x (SIdem id e sk true body) g' x' t
(*! R L2.lb.roundRobin DOC [RRL.9-12] [LBE.20] [M:loadBalance.24] *)
(** "The exchanges are selected in a round-robin fashion" [RRL.11]: the n-th exchange through this load balancer goes
    to output (n mod size); the outcome is "What the output the load balancer chose ends with" [M:loadBalance.24]. *)
| BRoundRobin : forall g x id bs b g' x' t, (match bs with [] => false | _ => true end) = true ->
    nth_error bs (Nat.modulo (cntget id (g_cnt g)) (length bs)) = Some b ->
    bs1 (bump g id) x b g' x' t -> bs1 g x (SLB id LBRoundRobin bs) g' x' t
(*! R L2.lb.failover DOC [FO.9-10] [FO.78-80] [M:lb:failoverLoadBalancer] *)
(** "In the default mode, the fail-over load balancer will always start with the first processor ... And in case this
    fails, then try the next, until either it succeeded or all of them failed. If all failed, then Camel will throw the
    caused exception" [FO.78-80]; maximumFailoverAttempts: "-1 ... never give up", "0 to never failover", "3 to
    failover at most 3 times" [M:lb:failoverLoadBalancer.maximumFailoverAttempts]. *)
| BFailover : forall g x id exs maxf bs g' x' t, (match bs with [] => false | _ => true end) = true ->
    bfo g x exs (fo_attempts (length bs) maxf) bs g' x' t -> bs1 g x (SLB id (LBFailover exs maxf) bs) g' x' t
(*! R L2.routingSlip DOC [RS.33-37] [RS.82] [RS.87-88] [M:routingSlip.30] *)
(** "The message will be routed in a pipeline fashion, i.e., one after the other" [RS.82]; the slip is computed
    "beforehand ... only computed once" [RS.87]; the outcome is "What the last endpoint of the slip leaves". *)
| BRoutingSlip : forall g x e d v eps g' x' t, eval_expr x e = EV v -> slip_of d v = Ok0 eps ->
    bss g x (map STo eps) g' x' t -> bs1 g x (SRoutingSlip e d) g' x' t
(*! R L2.dynamicRouter DOC [DR.31-33] [DR.112-115] [DR.171-175] [M:dynamicRouter.expression] *)
(** "similar to the Routing Slip EIP, but with the slip evaluated dynamically on-the-fly" [DR.31-32]: the expression
    "is called iteratively until it returns null to indicate the end of routing" [M:dynamicRouter.expression]; each
    result may hold several endpoints, comma separated [DR.174-175]. *)
| BDynamicRouter : forall g x e d g' x' t, bdr g x e d g' x' t -> bs1 g x (SDynamicRouter e d) g' x' t
| BConvertBody : forall g x ty m w, convert_body ty m (m_body (x_msg x)) = CbBody w ->
    bs1 g x (SConvertBody ty m) g (set_body x w) []
| BConvertBodyFail : forall g x ty m, convert_body ty m (m_body (x_msg x)) = CbFail ->
    (x_eh x && clause_matches (set_exn x (Some any_exn))) = false ->
    bs1 g x (SConvertBody ty m) g (default_failed x any_exn) []
(*! R L2.aggregate DOC [M:aggregate.60] [AGG.18] *)
(** "The message goes on with its body as it was; the aggregated message goes through the steps" [M:aggregate.60].
    What a failure, a stop or a handled exception inside the steps does (in the caller's thread) is not documented: no
    rule. *)
| BConvertBodyFailDLC : forall g x ty m x' t, convert_body ty m (m_body (x_msg x)) = CbFail ->
    dlc_fail x any_exn = Some (x', t) -> bs1 g x (SConvertBody ty m) g x' t
| BAggCont : forall g x o body g', agg_step x g o = AgCont g' -> bs1 g x (SAggregate o body) g' x []
(*! R L2.aggregate.output-order CODE harness/probes/AggOrderProbe.java *)
(** The output runs "in the same thread that called the aggregator" [AGG.46-47]; that it completes before the
    incoming exchange goes on is what Camel does for plain steps (probe), but not when the steps contain a doTry
    (runs/ic4-real random-107-2263: the output's events come after the caller's), nor when the aggregator itself is
    inside a doTry (runs/ic5-real random-109-596): no rule for those. *)
| BAggEmit : forall g x o body g1 agx g2 y t, agg_step x g o = AgEmit g1 agx -> lsdt body = false -> x_eh x = true ->
    bss g1 agx body g2 y t ->
    x_exn y = None -> x_stop y = false -> x_done y = false -> bs1 g x (SAggregate o body) g2 x t
| BAggFail : forall g x o body e, agg_step x g o = AgFail e -> (x_eh x && clause_matches (set_exn x (Some e))) = false ->
    bs1 g x (SAggregate o body) g (default_failed x e) []
| BAggFailDLC : forall g x o body e x' t, agg_step x g o = AgFail e -> dlc_fail x e = Some (x', t) ->
    bs1 g x (SAggregate o body) g x' t
(** The steps of the block, the doCatch and doFinally blocks run without the route's error handler [DT.22-27,
    DT.223-225]; an exception out of the doTry is not handled again. *)
(*! R L3.doTry.escape.real CODE findings/2026-10-26-dotry-escaping-exception-handled-when-nested.md *)
(** Real-mode delta: an exception out of a doTry nested in a filter/choice/pipeline is handled by the route's
    onException in Camel (not when the doTry is a step of the route itself): the Real mode leaves an escaping
    exception that a clause matches UNSPECIFIED (no rule) instead of modelling the nesting. *)
| BDoTry : forall g x body cs fin g1 x1 t1 g2 x2 t2, bss g (set_eh x false) body g1 x1 t1 ->
    baft g1 x1 cs fin g2 x2 t2 ->
    (real && x_eh x && (has_clauses (x_route x) || is_dlc) && match x_exn x2 with Some _ => true | None => false end) = false ->
    bs1 g x (SDoTry body cs fin) g2 (set_eh (seen_if_failed x2) (x_eh x)) (t1 ++ t2)
(*! R L2.split DOC [SPL.13-15] [SPL.380] [M:split.6] *)
(** The split value is computed from the expression; its items (grouped, if [group]) are processed one by one
    ([bsp]); "The Splitter will by default return the original input message" [SPL.380]. *)
| BSplit : forall g x e o body v l0 l g' x' t, eval_expr x e = EV v -> split_items o v = Ok0 l0 ->
    group_items o l0 = Ok0 l -> bsp g x o body l 0 [] g' x' t -> bs1 g x (SSplit e o body) g' x' t
(*! R L2.multicast DOC [MCE.9-10] [MCE.82-84] [MCE.147-153] *)
| BMulticast : forall g x st bs g' x' t, (match bs with [] => false | _ => true end) = true ->
    bmc g x st (map (fun b => [b]) bs) [] g' x' t -> bs1 g x (SMulticast st bs) g' x' t
(*! R L2.recipientList DOC [RLE.4] [M:recipientList.6] *)
| BRecipientList : forall g x st e d v eps g' x' t, eval_expr x e = EV v -> recipients d v = Ok0 eps ->
    (match eps with [] => false | _ => true end) = true ->
    bmc g x st (map (fun ep => [STo ep]) eps) [] g' x' t -> bs1 g x (SRecipientList st e d) g' x' t
with bmc : gstate -> exchange -> strat -> list (list step) -> list exchange -> gstate -> exchange -> list event -> Prop :=
(*! R L2.multicast.done DOC [M:multicast.aggregationStrategy] L2.strategy.result *)
| BMDone : forall g x st acc x', strat_result false st x acc = Some x' -> bmc g x st [] acc g x' []
(*! R L2.multicast.branch DOC [MCE.82-84] [MCE.398-401] *)
(** One copy, processed to its end. A failure in a copy (with or without stopOnException), a stop, and changes of
    exchange properties or variables in a copy are not documented for the default (no aggregation strategy): no rule. *)
| BMBranch : forall g x st b bs acc g1 y t1 g2 x2 t2, bss g (copy_of x) b g1 y t1 -> x_stop y = false ->
    x_done y = false ->
    x_exn y = None -> kveqb (x_vars y) (x_vars x) = true -> kveqb (x_props y) (x_props x) = true ->
    bmc g1 x st bs (acc ++ [y]) g2 x2 t2 -> bmc g x st (b :: bs) acc g2 x2 (t1 ++ t2)
with bsp : gstate -> exchange -> split_opts -> list step -> list val -> nat -> list exchange -> gstate -> exchange ->
           list event -> Prop :=
(*! R L2.split.done DOC [SPL.380] [SPL.1269-1271] *)
(** All items done: the original message goes on. With failures but no threshold and no stopOnException, the docs
    only say processing continues [SPL.1441-1448]: whether the exchange then fails is not documented (no rule). With
    a threshold not reached, the item exceptions are "cleared from sub-exchanges after being recorded" [SPL.1269-1271]:
    the original goes on without an exception. *)
| BSpDone : forall g x o body n acc x', (Nat.eqb n 0 || has_maxfail o) = true ->
    strat_result true (sp_strat o) x acc = Some x' -> bsp g x o body [] n acc g x' []
(*! R L2.split.item DOC [SPL.13] [SPL.1441-1447] *)
(** An item without failure. Its sub-exchange must not have changed exchange variables or stopped: whether variables
    are copied or shared, and what a stop inside a split message does, are not documented (no rule). *)
| BSpOk : forall g x o body v vs n acc g1 y t1 g2 x2 t2, bss g (sub_of x v) body g1 y t1 -> x_stop y = false ->
    (x_done y && (sp_stop o || match sp_strat o with StNone => false | _ => true end)) = false ->
    kveqb (x_vars y) (x_vars x) = true -> x_exn y = None -> bsp (complete_uow real g1 y) x o body vs n (acc ++ [y]) g2 x2 t2 ->
    bsp g x o body (v :: vs) n acc g2 x2 (t1 ++ t2)
(*! R L2.split.stopOnException DOC [SPL.1450-1453] [SPL.1508-1509] [M:split.stopOnException] *)
(** "stops further split processing ... and the caused exception will be thrown" [M:split.stopOnException]. *)
| BSpStop : forall g x o body v vs n acc g1 y t1 e, bss g (sub_of x v) body g1 y t1 -> x_stop y = false ->
    kveqb (x_vars y) (x_vars x) = true -> x_exn y = Some e -> sp_stop o = true -> sp_strat o = StNone ->
    bsp g x o body (v :: vs) n acc (complete_uow real g1 y) (set_exn x (Some (cee e))) t1
(*! R L2.split.maxFailedRecords.abort DOC [SPL.1150-1152] [SPL.1203-1204] [M:split.maxFailedRecords] *)
(** "When the threshold is reached, the splitter stops and sets an exception on the exchange" [SPL.1151-1152]; with
    5, "the first 4 failures are tolerated ... When the 5th failure occurs, the splitter stops" [SPL.1203-1204]; the
    exception is "a org.apache.camel.CamelExchangeException" [M:split.maxFailedRecords]. The model text says "When
    the count is exceeded" and the page also says "stops when either threshold is exceeded" [SPL.1263-1264]: we follow
    the explicit example (reached); the conflict is in notes/main.md. *)
| BSpAbort : forall g x o body v vs n acc g1 y t1 e m, bss g (sub_of x v) body g1 y t1 -> x_stop y = false ->
    kveqb (x_vars y) (x_vars x) = true -> x_exn y = Some e -> sp_stop o = false -> sp_maxfail o = Some m ->
    sp_strat o = StNone -> Nat.leb m (S n) = true -> bsp g x o body (v :: vs) n acc (complete_uow real g1 y) (abort_result x y e) t1
(*! R L2.split.failure.continue DOC [SPL.1441-1447] [SPL.1150-1151] *)
| BSpCont : forall g x o body v vs n acc g1 y t1 e g2 x2 t2, bss g (sub_of x v) body g1 y t1 -> x_stop y = false ->
    kveqb (x_vars y) (x_vars x) = true -> x_exn y = Some e -> sp_stop o = false -> sp_strat o = StNone ->
    match sp_maxfail o with Some m => Nat.leb m (S n) = false | None => True end ->
    bsp (complete_uow real g1 y) x o body vs (S n) acc g2 x2 t2 -> bsp g x o body (v :: vs) n acc g2 x2 (t1 ++ t2)
with bdr : gstate -> exchange -> expr -> chars -> gstate -> exchange -> list event -> Prop :=
| BDrHalt : forall g x e d, halted x = true -> bdr g x e d g x []
| BDrEnd : forall g x e d, halted x = false -> eval_expr x e = EV VNull -> bdr g x e d g x []
| BDrStep : forall g x e d v eps g1 y t1 g2 x2 t2, halted x = false -> eval_expr x e = EV v ->
    (match v with VNull => false | _ => true end) = true -> slip_of d v = Ok0 eps ->
    bss g x (map STo eps) g1 y t1 -> bdr g1 y e d g2 x2 t2 -> bdr g x e d g2 x2 (t1 ++ t2)
with bfo : gstate -> exchange -> list chars -> nat -> list step -> gstate -> exchange -> list event -> Prop :=
(** One attempt. A failure with onException clauses in the route (inheritErrorHandler), a stop or a handled exception
    in an attempt, and failing over after an attempt that changed the exchange, are not documented: no rule. *)
| BFoOk : forall g x exs k b bs g1 y t, bs1 g x b g1 y t -> x_exn y = None -> x_stop y = false -> x_done y = false ->
    kveqb (x_vars y) (x_vars x) && kvset_eqb (x_props y) (x_props x) = true -> bfo g x exs (S k) (b :: bs) g1 y t
| BFoNext : forall g x exs k b b' bs g1 y t1 e g2 z t2, bs1 g x b g1 y t1 -> x_exn y = Some e ->
    has_clauses (x_route x) = false -> fo_monitored real exs e = Ok0 true -> same_state y x = true ->
    bfo g1 x exs (S k) (b' :: bs) g2 z t2 -> bfo g x exs (S (S k)) (b :: b' :: bs) g2 z (t1 ++ t2)
| BFoLast : forall g x exs k b bs g1 y t e, bs1 g x b g1 y t -> x_exn y = Some e ->
    has_clauses (x_route x) = false ->
    (match fo_monitored real exs e with Ok0 false => true | _ => false end || Nat.eqb k 0 ||
     match bs with [] => true | _ => false end) = true ->
    bfo g x exs (S k) (b :: bs) g1 y t
with blp : gstate -> exchange -> bool -> list step -> nat -> exchange -> gstate -> exchange -> list event -> Prop :=
| BLpDone : forall g x cp body orig, blp g x cp body O orig g x []
| BLpHalt : forall g x cp body n orig, halted x = true -> blp g x cp body (S n) orig g x []
| BLpIter : forall g x (cp : bool) body n orig g1 y t1 g2 x2 t2, halted x = false ->
    bss g (if cp then loop_copy orig x else x) body g1 y t1 ->
    (cp && negb (kveqb (x_vars y) (x_vars orig) && kvset_eqb (x_props y) (x_props orig))) = false ->
    blp g1 y cp body n orig g2 x2 t2 ->
    blp g x cp body (S n) orig g2 x2 (t1 ++ t2)
with blw : gstate -> exchange -> expr -> list step -> gstate -> exchange -> list event -> Prop :=
| BLwStop : forall g x e body, halted x = false -> eval_pred x e = PB false -> blw g x e body g x []
| BLwHalt : forall g x e body, halted x = true -> blw g x e body g x []
| BLwIter : forall g x e body g1 y t1 g2 x2 t2, halted x = false -> eval_pred x e = PB true ->
    bss g x body g1 y t1 -> blw g1 y e body g2 x2 t2 -> blw g x e body g2 x2 (t1 ++ t2)
with baft : gstate -> exchange -> list (list chars * option expr * list step) -> option (list step) ->
            gstate -> exchange -> list event -> Prop :=
(*! R L3.doTry.stop DOC [DT.233-234] *)
(** "Using stop() inside the doTry or doCatch block stops routing the message, and the doFinally block is not
    executed" [DT.233-234]. *)
| BAStop : forall g x cs fin, x_stop x = true -> baft g x cs fin g x []
(*! R L3.doTry.ok DOC [DT.26-27] [M:doFinally.6] *)
| BAOk : forall g x cs fin g' x' t, x_stop x = false -> x_exn x = None -> bfin g x None fin g' x' t ->
    baft g x cs fin g' x' t
(*! R L3.doCatch.caught DOC [DT.211-213] [DT.26-27] [M:doTry.24] *)
(** The matching doCatch runs on the exchange with the exception caught (no longer failed); an exception thrown in it
    is the one pending for doFinally and is thrown from the doTry [DT.223-225]. *)
(*! R L3.doCatch.after-continued.real CODE findings/2026-10-26-docatch-skipped-after-continued-failure-in-called-route.md *)
(** Real-mode delta: after an exception was continued on the exchange (in a called route or earlier in the same
    route), Camel 4.23 / the pin skips a matching doCatch (EXCEPTION_HANDLED, CAMEL-25115): no rule in Real mode. *)
| BACaught : forall g x cs fin e ss g1 x1 t1 g2 x2 t2, x_stop x = false -> x_exn x = Some e ->
    select_catch x e cs = Ok0 (Some ss) -> (real && x_cont x) = false -> bss g (set_exn x None) ss g1 x1 t1 -> x_stop x1 = false ->
    bfin g1 (set_exn x1 None) (x_exn x1) fin g2 x2 t2 -> baft g x cs fin g2 x2 (t1 ++ t2)
(*! R L3.doCatch.stop DOC [DT.233-234] *)
| BACaughtStop : forall g x cs fin e ss g1 x1 t1, x_stop x = false -> x_exn x = Some e ->
    select_catch x e cs = Ok0 (Some ss) -> (real && x_cont x) = false -> bss g (set_exn x None) ss g1 x1 t1 -> x_stop x1 = true ->
    baft g x cs fin g1 x1 t1
(*! R L3.doTry.uncaught DOC [DT.223-225] *)
(** "An exception that is not caught by any doCatch ... The exception is thrown from the doTry, and the exchange
    fails" [DT.223-225]; doFinally still runs [M:doFinally.6, DT.227-229]. *)
| BAUncaught : forall g x cs fin e g' x' t, x_stop x = false -> x_exn x = Some e -> select_catch x e cs = Ok0 None ->
    bfin g (set_exn x None) (Some e) fin g' x' t -> baft g x cs fin g' x' t
with bfin : gstate -> exchange -> option exn -> option (list step) -> gstate -> exchange -> list event -> Prop :=
(*! R L3.doTry.no-finally DOC [DT.223-225] *)
| BFNone : forall g x p, bfin g x p None g (keep p x) []
(*! R L3.doFinally.run DOC [M:doFinally.6] *)
(** "steps to always execute after a doTry block completes, regardless of whether an exception was thrown or
    caught" [M:doFinally.6]. *)
(*! R L3.doFinally.after-complete DOC [M:doFinally.6] [DLC.186-188] *)
(** "always execute after a doTry block completes" [M:doFinally.6] also when the exchange came back complete from a
    route whose error handler moved it (L3.dlc.direct): the steps run (on the exchange as not complete), and afterwards
    it is complete again, so the route does not go on [DLC.186-188] (harness/probes/DlcDoTryDirectProbe.java: the
    doFinally runs, the steps after the doTry do not, for a dead letter channel and a handled onException alike). *)
(*! R L3.doFinally.after-complete.real CODE findings/2026-10-26-dofinally-only-first-step-after-handled-direct.md *)
(** Real-mode delta: Camel runs only the first doFinally step then (the errorHandlerHandled mark stops the block's
    pipeline): no rule in Real mode. *)
| BFRun : forall g x fs g' x' t, (real && x_done x) = false -> bss g (set_done x false) fs g' x' t ->
    bfin g x None (Some fs) g' (set_done x' (x_done x || x_done x')) t
(*! R L3.doFinally.pending DOC [M:doFinally.6] [DT.223-229] *)
(** With an exception pending, the steps still run; afterwards the pending exception is thrown, and if the doFinally
    steps threw too, "the original exception is kept and the exception from the doFinally block is added as a
    suppressed exception" [DT.227-229]. Whether the steps see the pending exception on the exchange is not documented
    (events marked [exn_unknown]); a stop inside doFinally while an exception is pending is not documented (no rule). *)
(** An exchange completed inside the doFinally (a called route's error handler moved it, L3.dlc.direct) while an
    exception is pending: complete and failed at once, not documented (no rule; Camel then runs only the first step
    of an enclosing doCatch: runs/rw2-real rw-602-939, the cause of
    findings/2026-10-26-dofinally-only-first-step-after-handled-direct.md). *)
| BFPending : forall g x e fs g' x' t, bss g x fs g' x' t -> x_stop x' = false -> x_done x' = false ->
    bfin g x (Some e) (Some fs) g' (keep_pending e x') (unknown_exn t)
with bch : gstate -> exchange -> list (expr * list step) -> option (list step) -> gstate -> exchange -> list event -> Prop :=
(*! R L2.choice.first-match DOC [CH.9-12] [M:choice.25] *)
(** The first [when] whose predicate holds runs; then no other branch. *)
| BCWhenT : forall g x p ss ws o g' x' t, eval_pred x p = PB true -> bss g x ss g' x' t ->
    bch g x ((p, ss) :: ws) o g' x' t
| BCWhenF : forall g x p ss ws o g' x' t, eval_pred x p = PB false -> bch g x ws o g' x' t ->
    bch g x ((p, ss) :: ws) o g' x' t
(*! R L2.choice.otherwise DOC [M:otherwise.6] [M:otherwise.22] *)
| BCOther : forall g x ss g' x' t, bss g x ss g' x' t -> bch g x [] (Some ss) g' x' t
(*! R L2.choice.none DOC [M:choice.25] *)
(** No branch ran: "the body as it was when no branch ran" [M:choice.25]. *)
| BCNone : forall g x, bch g x [] None g x [].

(** ** onCompletion (L3): what happens when a send's exchange is complete *)
(*! R L3.onCompletion DOC [OC.35-43] [OC.115-119] [OC.187-189] [M:onCompletion.onCompleteOnly] [M:onCompletion.onFailureOnly] *)
(** "when the original Exchange is complete. Camel spins off a copy of the Exchange and routes it ... similar to a
    Wire Tap ... we did not want the onCompletion route to interfere with the original route" [OC.37-43]: the
    caller's exchange is unchanged; the steps' events come after the route's. It triggers always, or only when the
    exchange "completed successfully (no errors)" / "ended with failure (exception ...)" [M:onCompletion]; onWhen
    "to only trigger if matching predicate" [OC.22]. With useOriginalMessage the copy has the original message.
    What the steps see of the exception, and an exception or a stop in the steps, are not documented: the copy has
    no exception and no error handler (an exception in the steps: no rule). *)
(*! R L3.onCompletion.trigger CODE harness/probes/OnCompletionProbe.java *)
(** Not documented: whether a handled exception or a stop is a success. Camel: both trigger onCompleteOnly, neither
    onFailureOnly (as "no errors" reads: the exchange has no exception). *)
(*! R L3.onCompletion.before DOC [OC.418-421] *)
(** BeforeConsumer "allows the onCompletion to modify the Exchange, such as adding special headers" [OC.418-421]:
    the caller gets the message the steps leave (probe: body and headers; exception kept). Changes of properties or
    variables: not documented (no rule). *)
Definition oc_failed (x : exchange) : bool := match x_exn x with Some _ => true | None => false end.
Definition oc_trig_ok (k : octrig) (x : exchange) : bool :=
  match k with OcAlways => true | OcComplete => negb (oc_failed x) | OcFailure => oc_failed x end.
Definition oc_fires (o : oncomp) (x : exchange) : pres :=
  if oc_trig_ok (oc_trig o) x then match oc_when o with None => PB true | Some p => eval_pred x p end else PB false.
Definition oc_input (o : oncomp) (x : exchange) : option exchange :=
  option_map (fun m => set_eh (set_seen (set_done (set_stop (set_exn (with_msg x m) None) false) false) false) false)
             (if oc_orig o then x_orig x else Some (x_msg x)).
Inductive boc : option oncomp -> gstate -> exchange -> gstate -> exchange -> list event -> Prop :=
| BOcNone : forall g x, boc None g x g x []
| BOcSkip : forall o g x, oc_fires o x = PB false -> boc (Some o) g x g x []
(*! R L3.onCompletion.alias.real CODE findings/2026-10-26-oncompletion-copy-aliases-original-message.md *)
| BOcAfter : forall o g x y0 g' y t, oc_fires o x = PB true -> oc_before o = false ->
    (real && oc_orig o && x_done x && match EHc with EHDlc _ _ UOMessage => true | _ => false end) = false ->
    oc_input o x = Some y0 ->
    bss g y0 (oc_steps o) g' y t -> x_exn y = None -> x_stop y = false -> x_done y = false ->
    boc (Some o) g x g' x t
(*! R L3.onCompletion.before-original.real CODE findings/2026-10-26-oncompletion-beforeconsumer-useoriginal-inout.md *)
| BOcBefore : forall o g x y0 g' y t, oc_fires o x = PB true -> oc_before o = true ->
    (real && oc_orig o) = false -> oc_input o x = Some y0 ->
    bss g y0 (oc_steps o) g' y t -> x_exn y = None -> x_stop y = false -> x_done y = false ->
    (kveqb (x_vars y) (x_vars y0) && kvset_eqb (x_props y) (x_props y0)) = true ->
    boc (Some o) g x g' (with_msg x (x_msg y)) t.

(** ** The interpreter *)

(** [ODone] also carries the ids of the rules used ([h]); they are coverage counters for the differential runs
    (CONVENTIONS practice 3) and play no part in the semantics or in [run_sound]. *)
Inductive out : Type :=
| ODone (g : gstate) (x : exchange) (t : list event) (h : list string)
| OUns (why : string).

Definition seqo (o : out) (k : gstate -> exchange -> list event -> list string -> out) : out :=
  match o with ODone g x t h => k g x t h | OUns w => OUns w end.
Definition tag (r : string) (o : out) : out :=
  match o with ODone g x t h => ODone g x t (r :: h) | OUns w => OUns w end.
Definition done1 (r : string) (g : gstate) (x : exchange) : out := ODone g x [] [r].

Fixpoint run (fuel : nat) (g : gstate) (x : exchange) (ss : list step) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match ss with
      | [] => done1 "L2.pipeline.nil" g x
      | s :: ss' =>
          if halted x then done1 "L2.pipeline.halt" g x
          else seqo (run1 f g x s) (fun g1 x1 t1 h1 =>
                 if x_eh x1 && negb (x_seen x1) && clause_matches x1
                 then OUns "EH: a new exception at a composite step that an onException clause matches (retry/handling there not modelled)"
                 else seqo (run f g1 (surface x1) ss') (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) ("L2.pipeline.seq" :: h1 ++ h2)))
      end
  end
with run1 (fuel : nat) (g : gstate) (x : exchange) (s : step) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match s with
      | SSetBody e => match eval_expr x e with EV v => done1 "L2.setBody" g (set_body x v) | EUns w => OUns w end
      | STransform e => match eval_expr x e with EV v => done1 "L2.transform" g (set_body x v) | EUns w => OUns w end
      | SSetHeader k e =>
          if ascii_name k then
            match eval_expr x e with EV v => done1 "L2.setHeader" g (map_headers (hset k v) x) | EUns w => OUns w end
          else OUns "L0: header name outside printable ASCII"
      | SSetProperty k e =>
          match eval_expr x e with EV v => done1 "L2.setProperty" g (map_props (pput k v) x) | EUns w => OUns w end
      | SSetVariable k e =>
          match eval_expr x e with
          | EV v => match var_set x g k v with Ok0 (x', g') => done1 "L2.setVariable" g' x' | Uns0 w => OUns w end
          | EUns w => OUns w
          end
      | SRemoveHeader k =>
          if ascii_name k then done1 "L2.removeHeader" g (map_headers (hremove k) x)
          else OUns "L0: header name outside printable ASCII"
      | SRemoveHeaders pat excl =>
          match hremove_pat pat excl (m_headers (x_msg x)) with
          | Ok0 hs => done1 "L2.removeHeaders" g (map_headers (fun _ => hs) x)
          | Uns0 w => OUns w
          end
      | SRemoveProperty k => done1 "L2.removeProperty" g (map_props (premove k) x)
      | SRemoveVariable k =>
          match var_remove x g k with Ok0 (x', g') => done1 "L2.removeVariable" g' x' | Uns0 w => OUns w end
      | SFilter p body =>
          match eval_pred x p with
          | PB true => tag "L2.filter.true" (run f g x body)
          | PB false => done1 "L2.filter.false" g x
          | PUns w => OUns w
          end
      | SChoice ws o => tag "L2.choice" (runch f g x ws o)
      | SPipeline body => tag "L2.pipeline.block" (run f g x body)
      | STo (EMock n) => ODone g x [EvMock n x false] ["L2.to.mock"]
      | STo (EDirect n) =>
          match find_route n with
          | None => OUns "DC: send to direct: without a consumer (block/timeout not modelled)"
          | Some r => seqo (run f g (set_route (set_eh x true) (r_id r)) (r_steps r)) (fun g' x' t h =>
                        if x_done x' then
                          match EHc with
                          | EHDlc _ _ _ => if has_clauses (r_id r) then OUns "EH: an exception handled in a route called by direct: (does the caller continue?) not documented"
                                           else ODone g' (set_route (set_eh x' (x_eh x)) (x_route x)) t ("L2.to.direct" :: "L3.dlc.direct" :: h)
                          | EHDefault => OUns "EH: an exception handled in a route called by direct: (does the caller continue?) not documented"
                          end
                        else if clause_matches x' then OUns "EH: a failure from a route called by direct: that a clause of the caller matches: not documented"
                        else if real && match x_exn x' with Some _ => true | None => false end && x_seen x' && has_clauses (x_route x)
                                && negb (has_clauses (r_id r))
                        then OUns "REAL: an exception out of a doTry in a called route without clauses, back in a caller with clauses (finding)"
                        else ODone g' (set_route (set_eh x' (x_eh x)) (x_route x)) t ("L2.to.direct" :: "L3.direct.boundary" :: (if existsb is_route_scoped C then "L3.onException.scope" :: h else h)))
          end
      | SStop => done1 "L2.stop" g (set_stop x true)
      | SThrow c m =>
          let e := mkExn c m None in
          let xe := set_exn x (Some e) in
          if x_eh x then
            match select_clause xe e with
            | Uns0 w => OUns w
            | Ok0 None =>
                match EHc with
                | EHDefault => ODone g (default_failed x e) [] ["L2.throwException"; "L3.errorHandler.default"; "L3.redelivery.headers-after"]
                | EHDlc q _ uo => match dlc_out uo x with
                                  | Some x' => ODone g x' [EvMock q x' false] ["L2.throwException"; "L3.dlc"; "L3.dlc.result"; "L3.dlc.original-boundary"]
                                  | None => OUns "DLC: the original message of an aggregator's output is not documented"
                                  end
                end
            | Ok0 (Some k) =>
                match redeliveries k xe with
                | Uns0 w => OUns w
                | Ok0 r =>
                if dlc_takes k then
                  match c_handled k, EHc with
                  | None, EHDlc q _ uo =>
                      match dlc_out (if real then UONone else uo) (after_redelivery k r x) with
                      | Some x' => ODone g x' [EvMock q x' false] ["L2.throwException"; "L3.onException.select"; "L3.dlc.clause-redelivery"; "L3.dlc"; "L3.dlc.result"]
                      | None => OUns "DLC: the original message of an aggregator's output is not documented"
                      end
                  | None, EHDefault => OUns "impossible"
                  | Some _, _ => OUns "DLC: handled set on an onException without steps, with a dead letter channel: not documented"
                  end
                else
                seqo (run f g (set_eh (block_input_n k r x) false) (c_steps k)) (fun g' y t h =>
                  if x_stop y then OUns "EHP: stop inside an onException block not documented"
                  else match x_exn y with
                       | Some _ => OUns "EHP: an exception inside an onException block not modelled"
                       | None => if x_done y then OUns "EHP: handled inside an onException block"
                                 else match eh_outcome_n k r x e y with
                                      | Some x' => ODone g' x' t ("L2.throwException" :: "L3.onException" :: "L3.onException.select" ::
                                                     "L3.onException.outcome" :: (match r with O => h | S _ => "L3.redelivery.headers" ::
                                                       (match c_retry k with Some _ => "L3.retryWhile" :: h | None => h end) end)
                                                     ++ (if c_onredel k then ["L3.onRedelivery"; "L3.onRedelivery.reset"] else []))
                                      | None => OUns "EHP: handled and continued both true not documented"
                                      end
                       end)
                end
            end
          else ODone g (default_failed x e) [] ["L2.throwException"; "L3.errorHandler.default"]
      | SDoTry body cs fin =>
          seqo (run f g (set_eh x false) body) (fun g1 x1 t1 h1 =>
            seqo (runaft f g1 x1 cs fin) (fun g2 x2 t2 h2 =>
              if real && x_eh x && (has_clauses (x_route x) || is_dlc) && match x_exn x2 with Some _ => true | None => false end
              then OUns "REAL: an exception out of a doTry in a route with onException clauses (processed by the error handler when the doTry is nested: finding)"
              else ODone g2 (set_eh (seen_if_failed x2) (x_eh x)) (t1 ++ t2) ("L3.doTry" :: h1 ++ h2)))
      | SMulticast st bs =>
          match bs with [] => OUns "MCE: multicast without outputs" | _ =>
            tag "L2.multicast" (runmc f g x st (map (fun b => [b]) bs) []) end
      | SRecipientList st e d =>
          match eval_expr x e with
          | EUns w => OUns w
          | EV v => match recipients d v with
                    | Uns0 w => OUns w
                    | Ok0 [] => OUns "RLE: no recipients"
                    | Ok0 eps => tag "L2.recipientList" (tag "L2.recipientList.uris" (runmc f g x st (map (fun ep => [STo ep]) eps) []))
                    end
          end
      | SLoop e cp dw body =>
          if dw then
            if cp then OUns "LOOP: while mode with copy not modelled"
            else tag "L2.loop.while" (runlw f g x e body)
          else
            match eval_expr x e with
            | EUns w => OUns w
            | EV v => match loop_count v with
                      | LcUns w => OUns w
                      | LcN n => tag "L2.loop" (tag "L2.loop.count" (runlp f g x cp body n x))
                      | LcFail => if x_eh x && clause_matches (set_exn x (Some rce))
                                  then match dlc_fail x rce with
                                       | Some (x', t) => ODone g x' t ["L2.loop"; "L2.loop.count-failure"; "L3.dlc.step-failure"; "L3.dlc"]
                                       | None => OUns "LOOP: a bad loop count that an onException clause matches: not modelled" end
                                  else ODone g (default_failed x rce) [] ["L2.loop"; "L2.loop.count"]
                      end
            end
      | SRoutingSlip e d =>
          match eval_expr x e with
          | EUns w => OUns w
          | EV v => match slip_of d v with
                    | Uns0 w => OUns w
                    | Ok0 eps => tag "L2.routingSlip" (tag "L2.routingSlip.uris" (run f g x (map STo eps)))
                    end
          end
      | SDynamicRouter e d => tag "L2.dynamicRouter" (rundr f g x e d)
      | SConvertBody ty m =>
          match convert_body ty m (m_body (x_msg x)) with
          | CbBody w => done1 "L2.convertBodyTo" g (set_body x w)
          | CbUns w => OUns w
          | CbFail => if x_eh x && clause_matches (set_exn x (Some any_exn))
                      then match dlc_fail x any_exn with
                           | Some (x', t) => ODone g x' t ["L2.convertBodyTo"; "L3.dlc.step-failure"; "L3.dlc"]
                           | None => OUns "CB: a failed conversion that an onException clause matches: class not documented" end
                      else ODone g (default_failed x any_exn) [] ["L2.convertBodyTo"]
          end
      | SIdem id e sk eg body =>
          match eval_expr x e with
          | EUns w => OUns w
          | EV v => match text_of v with
                    | None => OUns "IC: a null (or List) message id not modelled"
                    | Some k =>
                        if is_closed g id k then
                          if sk then ODone g x [] ["L2.idempotent"] else tag "L2.idempotent" (run f g x body)
                        else if eg then tag "L2.idempotent" (tag "L2.idempotent.completion" (run f (add_key g id k) (add_uow x id k) body))
                        else OUns "IC: eager=false not modelled"
                    end
          end
      | SLB id k bs =>
          match bs with
          | [] => OUns "LBE: a load balancer without outputs"
          | _ => match k with
                 | LBRoundRobin =>
                     match nth_error bs (Nat.modulo (cntget id (g_cnt g)) (length bs)) with
                     | Some b => tag "L2.lb.roundRobin" (run1 f (bump g id) x b)
                     | None => OUns "impossible"
                     end
                 | LBFailover exs maxf => tag "L2.lb.failover" (runfo f g x exs (fo_attempts (length bs) maxf) bs)
                 end
          end
      | SAggregate o body =>
          match agg_step x g o with
          | AgUns w => OUns w
          | AgCont g' => ODone g' x [] ["L2.aggregate"; "L2.aggregate.step"]
          | AgEmit g1 agx =>
              if lsdt body || negb (x_eh x) then OUns "AGG: when the output of an aggregator (with a doTry/direct call, or inside a doTry) completes, relative to the caller, is not documented" else
              seqo (run f g1 agx body) (fun g2 y t h =>
                match x_exn y with
                | Some _ => OUns "AGG: a failure in the steps of an aggregator not documented"
                | None => if x_stop y || x_done y then OUns "AGG: a stop or handled exception in the steps of an aggregator not documented"
                          else ODone g2 x t ("L2.aggregate" :: "L2.aggregate.step" :: "L2.aggregate.emit" :: h)
                end)
          | AgFail e => if x_eh x && clause_matches (set_exn x (Some e))
                        then match dlc_fail x e with
                             | Some (x', t) => ODone g x' t ["L2.aggregate"; "L2.aggregate.fail"; "L3.dlc.step-failure"; "L3.dlc"]
                             | None => OUns "AGG: a closed correlation key that an onException clause matches: not modelled" end
                        else ODone g (default_failed x e) [] ["L2.aggregate"; "L2.aggregate.step"; "L2.aggregate.fail"]
          end
      | SSplit e o body =>
          match eval_expr x e with
          | EUns w => OUns w
          | EV v => match split_items o v with
                    | Uns0 w => OUns w
                    | Ok0 l0 => match group_items o l0 with
                                | Uns0 w => OUns w
                                | Ok0 l => tag "L2.split" (tag "L2.split.items" (tag "L2.split.copy"
                                             (match sp_group o with Some _ => tag "L2.split.group" (runsp f g x o body l 0 [])
                                              | None => runsp f g x o body l 0 [] end)))
                                end
                    end
          end
      end
  end
with runmc (fuel : nat) (g : gstate) (x : exchange) (st : strat) (bs : list (list step)) (acc : list exchange)
  {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match bs with
      | [] => match strat_result false st x acc with
              | Some x' => ODone g x' [] ["L2.multicast.done"; "L2.multicast.last-reply"; "L2.strategy.result"]
              | None => OUns "AS: the outgoing exchange of this aggregation strategy (headers/properties kept, or no result) is not documented" end
      | b :: bs' =>
          seqo (run f g (copy_of x) b) (fun g1 y t1 h1 =>
            if x_stop y then OUns "MCE: stop inside a multicast/recipient copy not documented"
            else if x_done y then OUns "MCE: an exception handled (onException) in a multicast/recipient copy: effect on the result not documented"
            else match x_exn y with
                 | Some _ => OUns "MCE: a multicast/recipient copy failed (default aggregation): not documented"
                 | None =>
                     if negb (kveqb (x_vars y) (x_vars x)) then OUns "MCE: variables set in a multicast/recipient copy not documented"
                     else if negb (kveqb (x_props y) (x_props x)) then OUns "MCE: properties set in a multicast/recipient copy: effect on the result not documented"
                     else seqo (runmc f g1 x st bs' (acc ++ [y])) (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) ("L2.multicast.branch" :: "L2.multicast.copy" :: h1 ++ h2))
                 end)
      end
  end
with runsp (fuel : nat) (g : gstate) (x : exchange) (o : split_opts) (body : list step) (l : list val) (n : nat)
  (acc : list exchange) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match l with
      | [] => if Nat.eqb n 0 || has_maxfail o then
                match strat_result true (sp_strat o) x acc with
                | Some x' => ODone g x' [] ["L2.split.done"; "L2.strategy.result"]
                | None => OUns "AS: the outgoing exchange of this aggregation strategy (headers/properties kept, or no result) is not documented"
                end
              else OUns "SPL: a split message failed, no stopOnException, no threshold: whether the exchange fails is not documented"
      | v :: vs =>
          seqo (run f g (sub_of x v) body) (fun g1 y t1 h1 =>
            if x_stop y then OUns "SPL: stop inside a split message not documented"
            else if x_done y && (sp_stop o || match sp_strat o with StNone => false | _ => true end)
            then OUns "SPL: an exception handled (onException) in a split message with stopOnException or a strategy: not documented"
            else if negb (kveqb (x_vars y) (x_vars x)) then OUns "SPL: exchange variables set inside a split message (copied or shared) not documented"
            else match x_exn y with
                 | None => seqo (runsp f (complete_uow real g1 y) x o body vs n (acc ++ [y])) (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) ("L2.split.item" :: h1 ++ h2))
                 | Some e =>
                     if match sp_strat o with StNone => false | _ => true end
                     then OUns "AS: a split message failed with an aggregation strategy: not modelled"
                     else if sp_stop o then ODone (complete_uow real g1 y) (set_exn x (Some (cee e))) t1 ("L2.split.stopOnException" :: "L2.split.failure-wrapped" :: h1)
                     else match sp_maxfail o with
                          | Some m => if Nat.leb m (S n) then ODone (complete_uow real g1 y) (abort_result x y e) t1
                                        ("L2.split.maxFailedRecords.abort" :: "L2.split.failure-wrapped" ::
                                         (if real then "L2.split.abort-result.real" :: h1 else h1))
                                      else seqo (runsp f (complete_uow real g1 y) x o body vs (S n) acc) (fun g2 x2 t2 h2 =>
                                             ODone g2 x2 (t1 ++ t2) ("L2.split.failure.continue" :: h1 ++ h2))
                          | None => seqo (runsp f (complete_uow real g1 y) x o body vs (S n) acc) (fun g2 x2 t2 h2 =>
                                      ODone g2 x2 (t1 ++ t2) ("L2.split.failure.continue" :: h1 ++ h2))
                          end
                 end)
      end
  end
with rundr (fuel : nat) (g : gstate) (x : exchange) (e : expr) (d : chars) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      if halted x then ODone g x [] []
      else match eval_expr x e with
           | EUns w => OUns w
           | EV VNull => ODone g x [] []
           | EV v => match slip_of d v with
                     | Uns0 w => OUns w
                     | Ok0 eps => seqo (run f g x (map STo eps)) (fun g1 y t1 h1 =>
                                    seqo (rundr f g1 y e d) (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) (h1 ++ h2)))
                     end
           end
  end
with runfo (fuel : nat) (g : gstate) (x : exchange) (exs : list chars) (k : nat) (bs : list step) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match k, bs with
      | S k', b :: bs' =>
          seqo (run1 f g x b) (fun g1 y t1 h1 =>
            match x_exn y with
            | None => if x_stop y || x_done y then OUns "FO: a stop or handled exception in a failover attempt not documented"
                      else if negb (kveqb (x_vars y) (x_vars x) && kvset_eqb (x_props y) (x_props x))
                      then OUns "FO: variables/properties changed in a failover attempt (Camel keeps the caller's: runs/ic1-real, ic6-real) not documented"
                      else ODone g1 y t1 h1
            | Some e =>
                if has_clauses (x_route x) then OUns "FO: a failover attempt failing in a route with onException clauses (inheritErrorHandler) not modelled" else
                (
                    match fo_monitored real exs e with
                    | Uns0 w => OUns w
                    | Ok0 mon =>
                        match k', bs' with
                        | S _, _ :: _ =>
                            if mon then
                              if same_state y x then seqo (runfo f g1 x exs k' bs') (fun g2 z t2 h2 => ODone g2 z (t1 ++ t2) (h1 ++ h2))
                              else OUns "FO: failing over after an attempt that changed the exchange not documented"
                            else ODone g1 y t1 h1
                        | _, _ => ODone g1 y t1 h1
                        end
                    end)
            end)
      | _, _ => OUns "FO: no attempt left"
      end
  end
with runlp (fuel : nat) (g : gstate) (x : exchange) (cp : bool) (body : list step) (n : nat) (orig : exchange)
  {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match n with
      | O => ODone g x [] []
      | S m => if halted x then ODone g x [] []
               else seqo (run f g (if cp then loop_copy orig x else x) body) (fun g1 y t1 h1 =>
                      if cp && negb (kveqb (x_vars y) (x_vars orig) && kvset_eqb (x_props y) (x_props orig))
                      then OUns "LOOP: variables/properties changed in a copy-mode iteration (Camel keeps the original's) not documented"
                      else seqo (runlp f g1 y cp body m orig) (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) (h1 ++ h2)))
      end
  end
with runlw (fuel : nat) (g : gstate) (x : exchange) (e : expr) (body : list step) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      if halted x then ODone g x [] []
      else match eval_pred x e with
           | PUns w => OUns w
           | PB false => ODone g x [] []
           | PB true => seqo (run f g x body) (fun g1 y t1 h1 =>
                          seqo (runlw f g1 y e body) (fun g2 x2 t2 h2 => ODone g2 x2 (t1 ++ t2) (h1 ++ h2)))
           end
  end
with runaft (fuel : nat) (g : gstate) (x : exchange) (cs : list (list chars * option expr * list step))
  (fin : option (list step)) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      if x_stop x then done1 "L3.doTry.stop" g x
      else match x_exn x with
           | None => tag "L3.doTry.ok" (runfin f g x None fin)
           | Some e =>
               match select_catch x e cs with
               | Uns0 w => OUns w
               | Ok0 None => tag "L3.doTry.uncaught" (runfin f g (set_exn x None) (Some e) fin)
               | Ok0 (Some ss) =>
                   if real && x_cont x then OUns "REAL: a doCatch after an exception was continued on the exchange is skipped (finding)" else
                   seqo (run f g (set_exn x None) ss) (fun g1 x1 t1 h1 =>
                     if x_stop x1 then ODone g1 x1 t1 ("L3.doCatch.stop" :: "L3.doCatch.select" :: h1)
                     else seqo (runfin f g1 (set_exn x1 None) (x_exn x1) fin) (fun g2 x2 t2 h2 =>
                            ODone g2 x2 (t1 ++ t2) ("L3.doCatch.caught" :: "L3.doCatch.select" :: h1 ++ h2)))
               end
           end
  end
with runfin (fuel : nat) (g : gstate) (x : exchange) (p : option exn) (fin : option (list step)) {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match fin with
      | None => done1 "L3.doTry.no-finally" g (keep p x)
      | Some fs =>
          if real && x_done x && match p with None => true | Some _ => false end
          then OUns "REAL: doFinally after a handled direct: call runs only its first step (finding)" else
          seqo (run f g (match p with None => set_done x false | Some _ => x end) fs) (fun g' x' t h =>
            match p with
            | None => ODone g' (set_done x' (x_done x || x_done x')) t ("L3.doFinally.run" :: (if x_done x then "L3.doFinally.after-complete" :: h else h))
            | Some e => if x_stop x' then OUns "DT: stop inside doFinally while an exception is pending"
                        else if x_done x' then OUns "DT: the exchange completed (dead letter channel in a called route) in a doFinally while an exception is pending: not documented"
                        else ODone g' (keep_pending e x') (unknown_exn t) ("L3.doFinally.pending" :: h)
            end)
      end
  end
with runch (fuel : nat) (g : gstate) (x : exchange) (ws : list (expr * list step)) (o : option (list step))
  {struct fuel} : out :=
  match fuel with
  | O => OUns "fuel"
  | S f =>
      match ws with
      | [] => match o with Some ss => tag "L2.choice.otherwise" (run f g x ss) | None => done1 "L2.choice.none" g x end
      | (p, ss) :: ws' =>
          match eval_pred x p with
          | PB true => tag "L2.choice.first-match" (run f g x ss)
          | PB false => runch f g x ws' o
          | PUns w => OUns w
          end
      end
  end.

(** ** Soundness: what [run] computes is derivable by the rules *)

Lemma seqo_done : forall o k g x t h,
  seqo o k = ODone g x t h -> exists g1 x1 t1 h1, o = ODone g1 x1 t1 h1 /\ k g1 x1 t1 h1 = ODone g x t h.
Proof. intros [g1 x1 t1 h1|w] k g x t h H; simpl in H; [exists g1, x1, t1, h1; auto | discriminate]. Qed.
Lemma tag_done : forall r o g x t h, tag r o = ODone g x t h -> exists h1, o = ODone g x t h1.
Proof. intros r [g1 x1 t1 h1|w] g x t h H; simpl in H; inversion H; subst; eauto. Qed.

Theorem run_sound : forall fuel,
  (forall g x ss g' x' t h, run fuel g x ss = ODone g' x' t h -> bss g x ss g' x' t) /\
  (forall g x s g' x' t h, run1 fuel g x s = ODone g' x' t h -> bs1 g x s g' x' t) /\
  (forall g x st bs acc g' x' t h, runmc fuel g x st bs acc = ODone g' x' t h -> bmc g x st bs acc g' x' t) /\
  (forall g x o body l n acc g' x' t h, runsp fuel g x o body l n acc = ODone g' x' t h -> bsp g x o body l n acc g' x' t) /\
  (forall g x e d g' x' t h, rundr fuel g x e d = ODone g' x' t h -> bdr g x e d g' x' t) /\
  (forall g x exs k bs g' x' t h, runfo fuel g x exs k bs = ODone g' x' t h -> bfo g x exs k bs g' x' t) /\
  (forall g x cp body n orig g' x' t h, runlp fuel g x cp body n orig = ODone g' x' t h -> blp g x cp body n orig g' x' t) /\
  (forall g x e body g' x' t h, runlw fuel g x e body = ODone g' x' t h -> blw g x e body g' x' t) /\
  (forall g x cs fin g' x' t h, runaft fuel g x cs fin = ODone g' x' t h -> baft g x cs fin g' x' t) /\
  (forall g x p fin g' x' t h, runfin fuel g x p fin = ODone g' x' t h -> bfin g x p fin g' x' t) /\
  (forall g x ws o g' x' t h, runch fuel g x ws o = ODone g' x' t h -> bch g x ws o g' x' t).
Proof.
  induction fuel as [|f [IHs [IH1 [IHmc [IHsp [IHdr [IHfo [IHlp [IHlw [IHa [IHf IHc]]]]]]]]]]]; [repeat split; intros; discriminate|].
  repeat split.
  - intros g x ss g' x' t h H. destruct ss as [|s ss']; simpl in H.
    + inversion H; subst. constructor.
    + destruct (halted x) eqn:Hh.
      * inversion H; subst. now apply BHalt.
      * apply seqo_done in H as [g1 [x1 [t1 [h1 [H1 H2]]]]].
        destruct (x_eh x1 && negb (x_seen x1) && clause_matches x1) eqn:Hc; [discriminate|].
        apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]].
        inversion H4; subst. eapply BCons; eauto.
  - intros g x s g' x' t h H. destruct s; simpl in H.
    + destruct (eval_expr x e) eqn:E; inversion H; subst. now constructor.
    + destruct (eval_expr x e) eqn:E; inversion H; subst. now constructor.
    + destruct (ascii_name k) eqn:A; [|discriminate].
      destruct (eval_expr x e) eqn:E; inversion H; subst. now constructor.
    + destruct (eval_expr x e) eqn:E; inversion H; subst. now constructor.
    + destruct (eval_expr x e) eqn:E; [|discriminate].
      destruct (var_set x g k v) as [[x1 g1]|w] eqn:V; inversion H; subst. eapply BSetVariable; eauto.
    + destruct (ascii_name k) eqn:A; inversion H; subst. now constructor.
    + destruct (hremove_pat pat excl (m_headers (x_msg x))) eqn:R; inversion H; subst. now constructor.
    + inversion H; subst. constructor.
    + destruct (var_remove x g k) as [[x1 g1]|w] eqn:V; inversion H; subst. now constructor.
    + destruct (eval_pred x p) as [[|]|w] eqn:E; [| |discriminate].
      * apply tag_done in H as [h1 H]. eapply BFilterT; eauto.
      * inversion H; subst. now apply BFilterF.
    + apply tag_done in H as [h1 H]. eapply BChoice; eauto.
    + apply tag_done in H as [h1 H]. eapply BPipeline; eauto.
    + destruct ep as [n|n].
      * destruct (find_route n) as [r|] eqn:F; [|discriminate].
        apply seqo_done in H as [g1 [x1 [t1 [h1 [H1 H2]]]]].
        destruct (x_done x1) eqn:Hd.
        -- destruct EHc as [|q k uo] eqn:He; [discriminate|]. destruct (has_clauses (r_id r)) eqn:HC; [discriminate|].
           inversion H2; subst. eapply BToDirectDLC; eauto.
        -- destruct (clause_matches x1) eqn:Hm; [discriminate|].
           destruct (real && match x_exn x1 with Some _ => true | None => false end && x_seen x1 && has_clauses (x_route x)
                     && negb (has_clauses (r_id r))) eqn:Hrr; [discriminate|].
           inversion H2; subst. eapply BToDirect; eauto.
      * inversion H; subst. constructor.
    + inversion H; subst. constructor.
    + destruct (x_eh x) eqn:Heh.
      * destruct (select_clause (set_exn x (Some (mkExn cls msg None))) (mkExn cls msg None)) as [[k|]|w] eqn:Sel; [| |discriminate].
        -- destruct (redeliveries k (set_exn x (Some (mkExn cls msg None)))) as [r|w] eqn:Rd; [|discriminate].
           destruct (dlc_takes k) eqn:Dt.
           { destruct (c_handled k) as [hb|] eqn:Hk; [discriminate|].
             destruct EHc as [|q n uo] eqn:He; [discriminate|].
             destruct (dlc_out (if real then UONone else uo) (after_redelivery k r x)) as [xo|] eqn:Ho; [|discriminate].
             inversion H; subst. eapply BThrowDLCClause; eauto. }
           apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
           destruct (x_stop y) eqn:Hs; [discriminate|].
           destruct (x_exn y) as [e'|] eqn:Hx; [discriminate|].
           destruct (x_done y) eqn:Hd; [discriminate|].
           destruct (eh_outcome_n k r x (mkExn cls msg None) y) as [xo|] eqn:Ho; [|discriminate].
           inversion H2; subst. eapply BThrowEH; eauto.
        -- destruct EHc as [|q n uo] eqn:He.
           ++ inversion H; subst. apply BThrow. right. split; [exact Sel|exact He].
           ++ destruct (dlc_out uo x) as [xo|] eqn:Ho; [|discriminate].
              inversion H; subst. eapply BThrowDLC; eauto.
      * inversion H; subst. apply BThrow. left. exact Heh.
    + apply seqo_done in H as [g1 [x1 [t1 [h1 [H1 H2]]]]].
      apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]].
      destruct (real && x_eh x && (has_clauses (x_route x) || is_dlc) && match x_exn x2 with Some _ => true | None => false end) eqn:Hr; [discriminate|].
      inversion H4; subst. eapply BDoTry; eauto.
    + destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
      destruct (split_items o v) as [l0|w] eqn:I; [|discriminate].
      destruct (group_items o l0) as [l|w] eqn:G; [|discriminate].
      apply tag_done in H as [h1 H]. apply tag_done in H as [h2 H]. apply tag_done in H as [h3 H].
      destruct (sp_group o); [apply tag_done in H as [h4 H]|]; eapply BSplit; eauto.
    + lazymatch goal with |- bs1 _ _ (SMulticast _ ?bb) _ _ _ => destruct bb as [|b0 bs0]; [discriminate|] end.
      apply tag_done in H as [h1 H]. eapply BMulticast; [reflexivity|eauto].
    + destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
      destruct (recipients delim v) as [[|ep eps]|w] eqn:R; try discriminate.
      apply tag_done in H as [h1 H]. apply tag_done in H as [h2 H].
      eapply BRecipientList; [eauto|eauto|reflexivity|eauto].
    + destruct (agg_step x g o) as [g1|g1 agx|e|w] eqn:A.
      * inversion H; subst. now apply BAggCont.
      * destruct (lsdt body || negb (x_eh x)) eqn:Ld; [discriminate|].
        apply Bool.orb_false_iff in Ld as [Ld Le]. apply Bool.negb_false_iff in Le.
        apply seqo_done in H as [g2 [y [t1 [h1 [H1 H2]]]]].
        destruct (x_exn y) as [e|] eqn:Hx; [discriminate|].
        destruct (x_stop y || x_done y) eqn:Hsd; [discriminate|].
        apply Bool.orb_false_iff in Hsd as [Hs Hd].
        inversion H2; subst. eapply BAggEmit; eauto.
      * destruct (x_eh x && clause_matches (set_exn x (Some e))) eqn:Hm.
        { destruct (dlc_fail x e) as [[xd td]|] eqn:Hd; [|discriminate]. inversion H; subst. eapply BAggFailDLC; eauto. }
        inversion H; subst. now apply BAggFail.
      * discriminate.
    + destruct dowhile.
      * destruct copy; [discriminate|]. apply tag_done in H as [h1 H]. eapply BLoopWhile; eauto.
      * destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
        destruct (loop_count v) as [n| |w] eqn:L.
        -- apply tag_done in H as [h1 H]. apply tag_done in H as [h2 H]. eapply BLoop; eauto.
        -- destruct (x_eh x && clause_matches (set_exn x (Some rce))) eqn:Hm.
           { destruct (dlc_fail x rce) as [[xd td]|] eqn:Hd; [|discriminate]. inversion H; subst. eapply BLoopFailDLC; eauto. }
           inversion H; subst. eapply BLoopFail; eauto.
        -- discriminate.
    + destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
      destruct (text_of v) as [k|] eqn:T; [|discriminate].
      destruct (is_closed g id k) eqn:Cl.
      * destruct skip.
        -- inversion H; subst. eapply BIdemDup; eauto.
        -- apply tag_done in H as [h1 H]. eapply BIdemDupRun; eauto.
      * destruct eager; [|discriminate].
        apply tag_done in H as [h1 H]. apply tag_done in H as [h2 H]. eapply BIdemNew; eauto.
    + destruct branches as [|b0 bs0]; [discriminate|].
      destruct k as [|exs maxf].
      * destruct (nth_error (b0 :: bs0) (Nat.modulo (cntget id (g_cnt g)) (length (b0 :: bs0)))) as [b|] eqn:N; [|discriminate].
        apply tag_done in H as [h1 H]. eapply BRoundRobin; [reflexivity|eauto|eauto].
      * apply tag_done in H as [h1 H]. eapply BFailover; [reflexivity|eauto].
    + destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
      destruct (slip_of delim v) as [eps|w] eqn:Sl; [|discriminate].
      apply tag_done in H as [h1 H]. apply tag_done in H as [h2 H]. eapply BRoutingSlip; eauto.
    + apply tag_done in H as [h1 H]. eapply BDynamicRouter; eauto.
    + lazymatch goal with |- bs1 _ _ (SConvertBody ?ty ?mm) _ _ _ =>
        destruct (convert_body ty mm (m_body (x_msg x))) as [w| |w] eqn:Cb end.
      * inversion H; subst. now apply BConvertBody.
      * destruct (x_eh x && clause_matches (set_exn x (Some any_exn))) eqn:Hm.
        { destruct (dlc_fail x any_exn) as [[xd td]|] eqn:Hd; [|discriminate]. inversion H; subst. eapply BConvertBodyFailDLC; eauto. }
        inversion H; subst. now apply BConvertBodyFail.
      * discriminate.
  - intros g x st bs acc g' x' t h H. simpl in H. destruct bs as [|b bs'].
    + destruct (strat_result false st x acc) as [xr|] eqn:R; [|discriminate]. inversion H; subst. now constructor.
    + apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
      destruct (x_stop y) eqn:Hs; [discriminate|].
      destruct (x_done y) eqn:Hd; [discriminate|].
      destruct (x_exn y) as [e|] eqn:Hx; [discriminate|].
      destruct (kveqb (x_vars y) (x_vars x)) eqn:Hv; [|discriminate].
      destruct (kveqb (x_props y) (x_props x)) eqn:Hp; [|discriminate]. simpl in H2.
      apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst. eapply BMBranch; eauto.
  - intros g x o body l n acc g' x' t h H. simpl in H. destruct l as [|v vs].
    + destruct (Nat.eqb n 0 || has_maxfail o) eqn:D; [|discriminate].
      destruct (strat_result true (sp_strat o) x acc) as [xr|] eqn:R; [|discriminate].
      inversion H; subst. now apply BSpDone.
    + apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
      destruct (x_stop y) eqn:Hs; [discriminate|].
      destruct (x_done y && (sp_stop o || match sp_strat o with StNone => false | _ => true end)) eqn:Hds; [discriminate|].
      destruct (kveqb (x_vars y) (x_vars x)) eqn:Hv; [|discriminate]. simpl in H2.
      destruct (x_exn y) as [e|] eqn:Hx.
      * destruct (sp_strat o) eqn:Hstr; try discriminate.
        destruct (sp_stop o) eqn:Hst.
        -- inversion H2; subst. eapply BSpStop; eauto.
        -- destruct (sp_maxfail o) as [m|] eqn:Hm.
           ++ destruct (Nat.leb m (S n)) eqn:Hl.
              ** inversion H2; subst. eapply BSpAbort; eauto.
              ** apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst.
                 eapply BSpCont; eauto. rewrite Hm. exact Hl.
           ++ apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst.
              eapply BSpCont; eauto. rewrite Hm. exact I.
      * apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst. eapply BSpOk; eauto.
  - intros g x e d g' x' t h H. simpl in H. destruct (halted x) eqn:Hh.
    + inversion H; subst. now apply BDrHalt.
    + destruct (eval_expr x e) as [v|w] eqn:E; [|discriminate].
      destruct v; try (inversion H; subst; now apply BDrEnd);
      (destruct (slip_of d _) as [eps|w] eqn:Sl; [|discriminate];
       apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]];
       apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]; inversion H4; subst;
       eapply BDrStep; [exact Hh|exact E|reflexivity|exact Sl|eapply IHs; exact H1|eapply IHdr; exact H3]).
  - intros g x exs k bs g' x' t h H. simpl in H. destruct k as [|k']; [discriminate|]. destruct bs as [|b bs']; [discriminate|].
    apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
    destruct (x_exn y) as [e|] eqn:Hx.
    + destruct (has_clauses (x_route x)) eqn:HC; [discriminate|].
      destruct (fo_monitored real exs e) as [mon|w] eqn:Mo; [|discriminate].
      destruct k' as [|k''].
      * simpl in H2. inversion H2; subst. eapply BFoLast; [eapply IH1; exact H1|exact Hx|exact HC|]. rewrite Mo. destruct mon; reflexivity.
      * destruct bs' as [|b' bs''].
        -- simpl in H2. inversion H2; subst. eapply BFoLast; [eapply IH1; exact H1|exact Hx|exact HC|]. rewrite Mo. destruct mon; simpl; rewrite ?Bool.orb_true_r; reflexivity.
        -- destruct mon.
           ++ destruct (same_state y x) eqn:Ss; [|discriminate].
              apply seqo_done in H2 as [g2 [z [t2 [h2 [H3 H4]]]]]. inversion H4; subst.
              eapply BFoNext; [eapply IH1; exact H1|exact Hx|exact HC|exact Mo|exact Ss|eapply IHfo; exact H3].
           ++ inversion H2; subst. eapply BFoLast; [eapply IH1; exact H1|exact Hx|exact HC|]. rewrite Mo. reflexivity.
    + destruct (x_stop y || x_done y) eqn:Sd; [discriminate|]. apply Bool.orb_false_iff in Sd as [Hs Hd].
      destruct (kveqb (x_vars y) (x_vars x) && kvset_eqb (x_props y) (x_props x)) eqn:Hv; [|discriminate].
      inversion H2; subst. eapply BFoOk; eauto.
  - intros g x cp body n orig g' x' t h H. simpl in H. destruct n as [|m].
    + inversion H; subst. constructor.
    + destruct (halted x) eqn:Hh.
      * inversion H; subst. now apply BLpHalt.
      * apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
        destruct (cp && negb (kveqb (x_vars y) (x_vars orig) && kvset_eqb (x_props y) (x_props orig))) eqn:Hc; [discriminate|].
        apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst. eapply BLpIter; eauto.
  - intros g x e body g' x' t h H. simpl in H. destruct (halted x) eqn:Hh.
    + inversion H; subst. now apply BLwHalt.
    + destruct (eval_pred x e) as [[|]|w] eqn:E; [| |discriminate].
      * apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
        apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]]. inversion H4; subst. eapply BLwIter; eauto.
      * inversion H; subst. now apply BLwStop.
  - intros g x cs fin g' x' t h H. simpl in H. destruct (x_stop x) eqn:Hs.
    + inversion H; subst. now apply BAStop.
    + destruct (x_exn x) as [e|] eqn:Hx.
      * destruct (select_catch x e cs) as [[ss|]|w] eqn:Sel; [| |discriminate].
        -- destruct (real && x_cont x) eqn:Rc; [discriminate|].
           apply seqo_done in H as [g1 [x1 [t1 [h1 [H1 H2]]]]].
           destruct (x_stop x1) eqn:Hs1.
           ++ inversion H2; subst. eapply BACaughtStop; eauto.
           ++ apply seqo_done in H2 as [g2 [x2 [t2 [h2 [H3 H4]]]]].
              inversion H4; subst. eapply BACaught; eauto.
        -- apply tag_done in H as [h1 H]. eapply BAUncaught; eauto.
      * apply tag_done in H as [h1 H]. eapply BAOk; eauto.
  - intros g x p fin g' x' t h H. simpl in H. destruct fin as [fs|].
    + destruct (real && x_done x && match p with None => true | Some _ => false end) eqn:Hrd; [discriminate|].
      apply seqo_done in H as [g1 [x1 [t1 [h1 [H1 H2]]]]].
      destruct p as [e|].
      * destruct (x_stop x1) eqn:Hs1; [discriminate|]. destruct (x_done x1) eqn:Hd1; [discriminate|].
        inversion H2; subst. eapply BFPending; eauto.
      * simpl in H1. rewrite Bool.andb_true_r in Hrd. inversion H2; subst. eapply BFRun; eauto.
    + inversion H; subst. constructor.
  - intros g x ws o g' x' t h H. destruct ws as [|[p ss] ws']; simpl in H.
    + destruct o as [ss|].
      * apply tag_done in H as [h1 H]. eapply BCOther; eauto.
      * inversion H; subst. constructor.
    + destruct (eval_pred x p) as [[|]|w] eqn:E; [| |discriminate].
      * apply tag_done in H as [h1 H]. eapply BCWhenT; eauto.
      * eapply BCWhenF; eauto.
Qed.

Definition runoc (fuel : nat) (oc : option oncomp) (g : gstate) (x : exchange) : out :=
  match oc with
  | None => ODone g x [] []
  | Some o =>
      match oc_fires o x with
      | PUns w => OUns w
      | PB false => ODone g x [] ["L3.onCompletion"; "L3.onCompletion.trigger"]
      | PB true =>
          match oc_input o x with
          | None => OUns "OC: the original message of an aggregator's output is not documented"
          | Some y0 =>
              if oc_before o && real && oc_orig o
              then OUns "REAL: BeforeConsumer + useOriginalMessage can see the current message (InOut, or after a transform: finding)" else
              if negb (oc_before o) && real && oc_orig o && x_done x && match EHc with EHDlc _ _ UOMessage => true | _ => false end
              then OUns "REAL: the onCompletion copy shares the original message the dead letter channel put on the exchange (finding)" else
              seqo (run fuel g y0 (oc_steps o)) (fun g' y t h =>
                match x_exn y with
                | Some _ => OUns "OC: an exception in the onCompletion steps (it does not interfere with the caller [OC.42-43]; not modelled)"
                | None => if x_stop y || x_done y then OUns "OC: a stop in the onCompletion steps not documented"
                          else if oc_before o then
                            if kveqb (x_vars y) (x_vars y0) && kvset_eqb (x_props y) (x_props y0)
                            then ODone g' (with_msg x (x_msg y)) t ("L3.onCompletion" :: "L3.onCompletion.trigger" :: "L3.onCompletion.before" :: h)
                            else OUns "OC: BeforeConsumer steps that change properties or variables: not documented"
                          else ODone g' x t ("L3.onCompletion" :: "L3.onCompletion.trigger" :: h)
                end)
          end
      end
  end.
Lemma runoc_sound : forall fuel oc g x g' x' t h, runoc fuel oc g x = ODone g' x' t h -> boc oc g x g' x' t.
Proof.
  intros fuel oc g x g' x' t h H. destruct oc as [o|]; simpl in H; [|inversion H; subst; constructor].
  destruct (oc_fires o x) as [[|]|w] eqn:F; [|inversion H; subst; now apply BOcSkip|discriminate].
  destruct (oc_input o x) as [y0|] eqn:I; [|discriminate].
  destruct (oc_before o && real && oc_orig o) eqn:Rb; [discriminate|].
  destruct (negb (oc_before o) && real && oc_orig o && x_done x && match EHc with EHDlc _ _ UOMessage => true | _ => false end) eqn:Ra; [discriminate|].
  apply seqo_done in H as [g1 [y [t1 [h1 [H1 H2]]]]].
  apply (proj1 (run_sound fuel)) in H1.
  destruct (x_exn y) eqn:Ex; [discriminate|].
  destruct (x_stop y) eqn:Hs; [discriminate|]. destruct (x_done y) eqn:Hd; [discriminate|].
  destruct (oc_before o) eqn:B.
  - destruct (kveqb (x_vars y) (x_vars y0) && kvset_eqb (x_props y) (x_props y0)) eqn:K; [|discriminate].
    simpl in Rb. inversion H2; subst. eapply BOcBefore; eauto.
  - simpl in Ra. inversion H2; subst. eapply BOcAfter; eauto.
Qed.

End Rules.

(** ** Running a case: several sends, one after another, sharing the context-wide state (global, route and group
    variables persist between exchanges [VAR.18-20]) *)

Record send : Type := mkSend { s_to : chars; s_mep : mep; s_body : val; s_headers : list (chars * val) }.

Inductive sres : Type :=
| SDone (t : list event) (x : exchange) (h : list string)
| SUns (why : string).

(** A clause with no steps and no option (handled, continued, redelivery): Camel refuses the route at creation
    ("is not configured", OnExceptionDefinition.validateConfiguration); not documented: the whole case is UNSPECIFIED. *)
Definition clause_unconfigured (k : clause) : bool :=
  match c_steps k, c_handled k, c_continued k, c_redeliveries k, c_retry k, c_onredel k with
  | [], None, false, O, None, false => true | _, _, _, _, _, _ => false end.

Fixpoint run_case_ (real : bool) (C : list clause) (E : ehconf) (OC : option oncomp) (fuel : nat) (P : list route) (g : gstate) (ss : list send) : list sres * gstate :=
  match ss with
  | [] => ([], g)
  | s :: ss' =>
      match find_route P (s_to s) with
      | None => ([SUns "DC: send to direct: without a consumer"], g)
      | Some r =>
          match run P real C E fuel g (set_route (new_exchange (s_mep s) (s_body s) (s_headers s)) (r_id r)) (r_steps r) with
          | ODone g' x t h =>
              (* the onCompletion is on the first route (the one the sends go to): route scope *)
              let oc := match P with r0 :: _ => if ceqs (r_from r0) (s_to s) then OC else None | [] => None end in
              match runoc P real C E fuel oc g' x with
              | ODone g2 x2 t2 h2 =>
                  let '(rs, g'') := run_case_ real C E OC fuel P (complete_uow real g2 x2) ss' in (SDone (t ++ t2) x2 (h ++ h2) :: rs, g'')
              | OUns w => ([SUns w], g)
              end
          | OUns w => ([SUns w], g)   (* later sends depend on the state: stop at the first UNSPECIFIED one *)
          end
      end
  end.
Definition run_case (real : bool) (C : list clause) (E : ehconf) (OC : option oncomp) (fuel : nat) (P : list route) (g : gstate) (ss : list send)
  : list sres * gstate :=
  if existsb clause_unconfigured C
  then ([SUns "EC: onException without steps or options (refused at route creation; not documented)"], g)
  else if match OC with Some o => match oc_steps o with [] => true | _ => false end | None => false end
  then ([SUns "OC: onCompletion without steps (refused at route creation: no children; not documented)"], g)
  else run_case_ real C E OC fuel P g ss.

(** ** Examples from the docs *)

Definition sx (s : string) : expr := XSimple (Simple.PExpr [Simple.TText (str s)]).
Definition sbody : expr := XSimple (Simple.PExpr [Simple.TFn false Simple.FBody]).
Definition hdr_is (k v : string) : expr :=
  XSimple (Simple.PPred (Simple.PS (Simple.ACmp (Simple.LFn (Simple.FHeader 0 (str k))) Simple.OEq
                                                 (Simple.RLit (Simple.LQ (str v)))) Simple.PNil)).
Definition bodyof (o : out) : option val := match o with ODone _ x _ _ => Some (m_body (x_msg x)) | _ => None end.
Definition mocks (o : out) : list chars := match o with ODone _ _ t _ => map (fun '(EvMock n _ _) => n) t | _ => [] end.
Definition exnof (o : out) : option (option chars) :=
  match o with ODone _ x _ _ => Some (option_map exn_class (x_exn x)) | _ => None end.

(** [FI.255-259]: a gold message goes to mock:gold and mock:all, a non-gold one only to mock:all. *)
Definition gold_route : list step :=
  [SFilter (hdr_is "type" "gold") [STo (EMock (str "gold"))]; STo (EMock (str "all"))].
Example doc_filter_gold :
  mocks (run [] false [] EHDefault 10 g0 (new_exchange InOnly VNull [(str "type", VStr (str "gold"))]) gold_route)
  = [str "gold"; str "all"].
Proof. vm_compute. reflexivity. Qed.
Example doc_filter_not_gold :
  mocks (run [] false [] EHDefault 10 g0 (new_exchange InOnly VNull [(str "type", VStr (str "silver"))]) gold_route)
  = [str "all"].
Proof. vm_compute. reflexivity. Qed.
(** [FI.261-262]: with stop inside the filter, a gold message does not reach mock:all. *)
Example doc_filter_stop :
  mocks (run [] false [] EHDefault 10 g0 (new_exchange InOnly VNull [(str "type", VStr (str "gold"))])
             [SFilter (hdr_is "type" "gold") [STo (EMock (str "gold")); SStop]; STo (EMock (str "all"))])
  = [str "gold"].
Proof. vm_compute. reflexivity. Qed.
(** Non-vacuity of [run_sound] (CONVENTIONS practice 4): the rules derive the gold example. *)
Example rules_derive_gold : exists g' x' t,
  bss [] false [] EHDefault g0 (new_exchange InOnly VNull [(str "type", VStr (str "gold"))]) gold_route g' x' t.
Proof.
  destruct (run [] false [] EHDefault 10 g0 (new_exchange InOnly VNull [(str "type", VStr (str "gold"))]) gold_route) eqn:E.
  - exists g, x, t. apply (proj1 (run_sound [] false [] EHDefault 10) _ _ _ _ _ _ h). exact E.
  - vm_compute in E. discriminate.
Qed.

(** [DT.211-213]: the doCatch blocks are tried in order; the first that matches is used. *)
Definition io : chars := str "java.io.IOException".
Example doc_docatch_in_order :
  bodyof (run [] false [] EHDefault 20 g0 (new_exchange InOnly VNull [])
    [SDoTry [SThrow io (str "boom")]
            [([io], None, [SSetBody (sx "io")]); ([str "java.lang.Exception"], None, [SSetBody (sx "ex")])] None])
  = Some (VStr (str "io")).
Proof. vm_compute. reflexivity. Qed.
(** [DT.223-225] with [M:doFinally.6]: not caught, doFinally runs, the exchange fails with the exception. *)
Example doc_uncaught_finally :
  let o := run [] false [] EHDefault 20 g0 (new_exchange InOnly VNull [])
    [SDoTry [SThrow (str "java.lang.IllegalStateException") (str "x")] [([io], None, [])]
            (Some [STo (EMock (str "fin"))])] in
  (mocks o, exnof o) = ([str "fin"], Some (Some (str "java.lang.IllegalStateException"))).
Proof. vm_compute. reflexivity. Qed.
(** [DT.233-234]: stop inside doTry: doFinally is not executed. *)
Example doc_stop_skips_finally :
  mocks (run [] false [] EHDefault 20 g0 (new_exchange InOnly VNull [])
    [SDoTry [SStop] [([io], None, [])] (Some [STo (EMock (str "fin"))]); STo (EMock (str "after"))]) = [].
Proof. vm_compute. reflexivity. Qed.
(** [DT.227-229]: an exception in doFinally while one is pending: the original is kept. *)
Example doc_finally_keeps_original :
  exnof (run [] false [] EHDefault 20 g0 (new_exchange InOnly VNull [])
    [SDoTry [SThrow io (str "a")] [] (Some [SThrow (str "java.lang.IllegalStateException") (str "b")])])
  = Some (Some io).
Proof. vm_compute. reflexivity. Qed.

(** [SPL.1135-1136]: 7 items in groups of 3 give 3 messages, the last with one item. *)
Definition seven : val := VStr (str "1,2,3,4,5,6,7").
Example doc_split_group_seven :
  match run [] false [] EHDefault 30 g0 (new_exchange InOnly seven [])
          [SSplit sbody (mkSplit false (Some 3) (str ",") None StNone) [STo (EMock (str "m"))]] with
  | ODone _ _ t _ => map (fun '(EvMock _ y _) => m_body (x_msg y)) t | _ => [] end
  = [VList [str "1"; str "2"; str "3"]; VList [str "4"; str "5"; str "6"]; VList [str "7"]].
Proof. vm_compute. reflexivity. Qed.
(** [SPL.1203-1204]: with maxFailedRecords 5, the 5th failure stops the split (items 6.. are not processed). *)
Example doc_split_max_failed_5 :
  let o := run [] false [] EHDefault 60 g0 (new_exchange InOnly (VStr (str "a,b,c,d,e,f,g")) [])
          [SSplit sbody (mkSplit false None (str ",") (Some 5) StNone)
             [STo (EMock (str "m")); SThrow (str "java.lang.IllegalStateException") (str "x")]] in
  (length (mocks o), exnof o) = (5%nat, Some (Some (str "org.apache.camel.CamelExchangeException"))).
Proof. vm_compute. reflexivity. Qed.
(** [SPL.380]: by default the split returns the original input message. *)
Example doc_split_returns_original :
  bodyof (run [] false [] EHDefault 30 g0 (new_exchange InOnly (VStr (str "a,b")) [])
            [SSplit sbody (mkSplit false None (str ",") None StNone) [SSetBody (sx "changed")]])
  = Some (VStr (str "a,b")).
Proof. vm_compute. reflexivity. Qed.

(** onException examples (L3). *)
Definition iae : chars := str "java.lang.IllegalArgumentException".
Definition nfe : chars := str "java.lang.NumberFormatException".
Definition cl (ts : list chars) (h : option bool) (k : bool) (n : nat) (ss : list step) : clause :=
  mkClause ts None h k n ss None false None.
Definition failing : list step := [SSetBody (sx "x"); SThrow iae (str "boom"); STo (EMock (str "after"))].
Definition runC (C : list clause) (ss : list step) : out := run [] false C EHDefault 30 g0 (new_exchange InOut VNull []) ss.
(** [EHP.60-67]: handled: the route stops, the response is what the block produces, no exception to the caller. *)
Example doc_handled :
  let o := runC [cl [iae] (Some true) false 0 [STransform (sx "handled")]] failing in
  (bodyof o, exnof o, mocks o) = (Some (VStr (str "handled")), Some None, []).
Proof. vm_compute. reflexivity. Qed.
(** [EHP.416-418]: continued: the block runs, then the route goes on after the failing step. *)
Example doc_continued :
  let o := runC [cl [iae] None true 0 [SSetHeader (str "h") (sx "c")]] failing in
  (exnof o, mocks o) = (Some None, [str "after"]).
Proof. vm_compute. reflexivity. Qed.
(** [DEH.18-19]: neither handled nor continued: the block runs and the exception goes back to the caller. *)
Example doc_not_handled :
  exnof (runC [cl [iae] None false 0 [STo (EMock (str "eh"))]] failing) = Some (Some iae).
Proof. vm_compute. reflexivity. Qed.
(** [EC.215-228]: the closest super class wins: a NumberFormatException goes to the IllegalArgumentException clause,
    not the Exception one. *)
Example doc_closest_match :
  bodyof (runC [cl [str "java.lang.Exception"] (Some true) false 0 [STransform (sx "ex")];
                cl [iae] (Some true) false 0 [STransform (sx "iae")]]
               [SThrow nfe (str "n")]) = Some (VStr (str "iae")).
Proof. vm_compute. reflexivity. Qed.
(** [EC.194-197]: the same exception in two clauses: the last one configured is used. *)
Example doc_last_configured :
  bodyof (runC [cl [iae] (Some true) false 0 [STransform (sx "first")];
                cl [iae] (Some true) false 0 [STransform (sx "second")]] failing) = Some (VStr (str "second")).
Proof. vm_compute. reflexivity. Qed.
(** [DLC.575-584]: after 2 redeliveries CamelRedelivered=true and the counters at 2 (not handled: the exception goes
    back with the headers; handled would drop them, L3.redelivery.headers-after). *)
Example doc_redelivery_headers :
  match runC [cl [iae] None false 2 []] failing with
  | ODone _ x _ _ => (hget (str "CamelRedelivered") (m_headers (x_msg x)), hget (str "CamelRedeliveryCounter") (m_headers (x_msg x)))
  | _ => (VNull, VNull) end = (VBool true, VInt 2).
Proof. vm_compute. reflexivity. Qed.
(** [DT.22-27]: inside doTry the error handler is not in use: the doCatch gets the exception, not the clause. *)
Example doc_dotry_bypasses_onexception :
  bodyof (runC [cl [iae] (Some true) false 0 [STransform (sx "eh")]]
               [SDoTry [SThrow iae (str "b")] [([iae], None, [STransform (sx "catch")])] None]) = Some (VStr (str "catch")).
Proof. vm_compute. reflexivity. Qed.

(** Aggregation strategies on split [GBS], [AS]. *)
Example doc_split_grouped_body :
  bodyof (run [] false [] EHDefault 30 g0 (new_exchange InOnly (VStr (str "a,b")) [])
            [SSplit sbody (mkSplit false None (str ",") None StGroupedBody) [STransform (XSimple (Simple.PExpr [Simple.TText (str "x"); Simple.TFn false Simple.FBody]))]])
  = Some (VList [str "xa"; str "xb"]).
Proof. vm_compute. reflexivity. Qed.
Example doc_split_use_latest :
  bodyof (run [] false [] EHDefault 30 g0 (new_exchange InOnly (VStr (str "a,b")) [])
            [SSplit sbody (mkSplit false None (str ",") None StLatest) [STransform (XSimple (Simple.PExpr [Simple.TText (str "x"); Simple.TFn false Simple.FBody]))]])
  = Some (VStr (str "xb")).
Proof. vm_compute. reflexivity. Qed.

(** Aggregate [AGG.256-257, M:aggregate.60]: with completionSize 3 and groupedBody, the third exchange with the same
    key completes the group: the aggregated exchange (a List of the 3 bodies) goes through the steps, while each
    incoming exchange goes on with its body as it was. *)
Definition hid : expr := XSimple (Simple.PExpr [Simple.TFn false (Simple.FHeader 0 (str "id"))]).
Definition agg3 : list route :=
  [mkRoute (str "r0") (str "r0")
     [SAggregate (mkAgg (str "a1") hid StGroupedBody (Some 3) None false false) [STo (EMock (str "out"))];
      STo (EMock (str "after"))]].
Definition snd1 (b : string) : send := mkSend (str "r0") InOnly (VStr (str b)) [(str "id", VStr (str "1"))].
Example doc_aggregate_size_3 :
  map (fun r => match r with SDone t _ _ => map (fun '(EvMock n y _) => (n, m_body (x_msg y))) t | SUns _ => [] end)
      (fst (run_case false [] EHDefault None 50 agg3 g0 [snd1 "A"; snd1 "B"; snd1 "C"]))
  = [[(str "after", VStr (str "A"))];
     [(str "after", VStr (str "B"))];
     [(str "out", VList [str "A"; str "B"; str "C"]); (str "after", VStr (str "C"))]].
Proof. vm_compute. reflexivity. Qed.

(** [LOOP.185-247]: with copy, each iteration starts from the original "A" and mock:loop receives "AB" each time;
    without copy it receives "AB", "ABB", "ABBB". *)
Definition appendB : step := STransform (XSimple (Simple.PExpr [Simple.TFn false Simple.FBody; Simple.TText (str "B")])).
Definition three : expr := sx "3".
Definition loop_bodies (cp : bool) : list val :=
  match run [] false [] EHDefault 40 g0 (new_exchange InOnly (VStr (str "A")) []) [SLoop three cp false [appendB; STo (EMock (str "loop"))]] with
  | ODone _ _ t _ => map (fun '(EvMock _ y _) => m_body (x_msg y)) t | _ => [] end.
Example doc_loop_copy : loop_bodies true = [VStr (str "AB"); VStr (str "AB"); VStr (str "AB")].
Proof. vm_compute. reflexivity. Qed.
Example doc_loop_default : loop_bodies false = [VStr (str "AB"); VStr (str "ABB"); VStr (str "ABBB")].
Proof. vm_compute. reflexivity. Qed.

(** [IC.62-65]: the second message with the same id is skipped (it does not reach mock:result), and goes on after the
    block. [RRL.11]: round robin over two outputs alternates. [FO.78-80]: failover tries the next output; if all fail,
    the exchange fails with the exception. *)
Definition idem_route : list route :=
  [mkRoute (str "r0") (str "r0") [SIdem (str "idem1") hid true true [STo (EMock (str "result"))]; STo (EMock (str "after"))]].
Definition mocks_of (rs : list sres) : list (list chars) :=
  map (fun r => match r with SDone t _ _ => map (fun '(EvMock n _ _) => n) t | SUns _ => [] end) rs.
Example doc_idempotent_duplicate :
  mocks_of (fst (run_case false [] EHDefault None 50 idem_route g0 [snd1 "A"; snd1 "B"]))
  = [[str "result"; str "after"]; [str "after"]].
Proof. vm_compute. reflexivity. Qed.
Definition rr_route : list route :=
  [mkRoute (str "r0") (str "r0") [SLB (str "lb1") LBRoundRobin [STo (EMock (str "a")); STo (EMock (str "b"))]]].
Example doc_round_robin :
  mocks_of (fst (run_case false [] EHDefault None 50 rr_route g0 [snd1 "A"; snd1 "B"; snd1 "C"])) = [[str "a"]; [str "b"]; [str "a"]].
Proof. vm_compute. reflexivity. Qed.
Example doc_failover :
  let o := run [] false [] EHDefault 30 g0 (new_exchange InOnly VNull [])
             [SLB (str "lb2") (LBFailover [] (-1)) [SThrow io (str "down"); STo (EMock (str "service2"))]] in
  (mocks o, exnof o) = ([str "service2"], Some None).
Proof. vm_compute. reflexivity. Qed.
Example doc_failover_all_failed :
  exnof (run [] false [] EHDefault 30 g0 (new_exchange InOnly VNull [])
           [SLB (str "lb3") (LBFailover [] (-1)) [SThrow io (str "1"); SThrow iae (str "2")]]) = Some (Some iae).
Proof. vm_compute. reflexivity. Qed.

(** [RS.81-82]: a comma-delimited slip routes in pipeline fashion; [RS.39]: an empty slip routes nowhere.
    [DR.112-115, M:dynamicRouter.expression]: the router repeats until the expression gives null.
    [CB.9, M:convertBodyTo.mandatory]: the body converted to Integer. *)
Example doc_routing_slip :
  mocks (run [] false [] EHDefault 30 g0 (new_exchange InOnly VNull []) [SRoutingSlip (sx "mock:a,mock:b") (str ",")])
  = [str "a"; str "b"].
Proof. vm_compute. reflexivity. Qed.
Example doc_routing_slip_empty :
  mocks (run [] false [] EHDefault 30 g0 (new_exchange InOnly VNull [(str "slip", VStr [])])
           [SRoutingSlip (XSimple (Simple.PExpr [Simple.TFn false (Simple.FHeader 0 (str "slip"))])) (str ",");
            STo (EMock (str "after"))])
  = [str "after"].
Proof. vm_compute. reflexivity. Qed.
Definition dest : expr := XSimple (Simple.PExpr [Simple.TFn false (Simple.FHeader 0 (str "dest"))]).
Example doc_dynamic_router :
  mocks (run [mkRoute (str "rd") (str "rd") [SRemoveHeader (str "dest"); STo (EMock (str "hop"))]] false [] EHDefault 40 g0
           (new_exchange InOnly VNull [(str "dest", VStr (str "direct:rd"))]) [SDynamicRouter dest (str ",")])
  = [str "hop"].
Proof. vm_compute. reflexivity. Qed.
Example doc_convert_body_integer :
  bodyof (run [] false [] EHDefault 10 g0 (new_exchange InOnly (VStr (str "5")) []) [SConvertBody Convert.TInteger true])
  = Some (VInt 5).
Proof. vm_compute. reflexivity. Qed.
