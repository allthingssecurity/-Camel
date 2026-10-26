(** * L6 YAML DSL: the documented YAML form of the L2/L3 route model.

    As for L6/Xml.v: a rendering of the route model, loaded by Camel's YAML DSL and required to behave as the L2 rules
    say. Legend (paths under docs/):
      [YML] dsl/camel-yaml-dsl/camel-yaml-dsl/src/main/docs/yaml-dsl.adoc
      [M:x] model/x.json (option names; "expression" options take a language object, "outputs" are [steps])
      [SPL] .../eips/pages/split-eip.adoc (#class:)
      [EH]  docs/user-manual/modules/ROOT/pages/error-handler.adoc; [M:deadLetterChannel] model/deadLetterChannel.json
    The text is YAML in flow style (JSON syntax, which YAML includes): the parser gives the same node tree as the block
    style of the doc examples (TRUST.md). String escaping is JSON's, not Camel documentation. *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L0 Require Convert.
From CamelSpec.L1 Require Simple Lang.
From CamelSpec.L2 Require Import Route.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

Definition s (x : string) : chars := str x.
Definition dq : ascii := ascii_of_nat 34.
Definition bsl : ascii := ascii_of_nat 92.
Definition hex1 (n : nat) : ascii := if Nat.ltb n 10 then ascii_of_nat (48 + n) else ascii_of_nat (87 + n).
Fixpoint jesc (t : chars) : chars :=
  match t with
  | [] => []
  | c :: r =>
      let n := nat_of_ascii c in
      (if ceq c dq then [bsl; dq] else if ceq c bsl then [bsl; bsl]
       else if Nat.ltb n 32 then s "\u00" ++ [hex1 (Nat.div n 16); hex1 (Nat.modulo n 16)]
       else [c]) ++ jesc r
  end.
Definition jstr (t : chars) : chars := [dq] ++ jesc t ++ [dq].
Definition kv (k : string) (v : chars) : chars := jstr (s k) ++ s ":" ++ v.
Fixpoint commas (l : list chars) : chars := match l with [] => [] | [x] => x | x :: r => x ++ s "," ++ commas r end.
Definition obj (fields : list chars) : chars := s "{" ++ commas fields ++ s "}".
Definition arr (items : list chars) : chars := s "[" ++ commas items ++ s "]".
Definition btxt (b : bool) : chars := if b then s "true" else s "false".
Definition ntxt (n : nat) : chars := ztext (Z.of_nat n).

(*! R L6.yaml.expression DOC [YML.22-34] [M:filter] *)
(** An expression is an object keyed by its language ([YML.27-28]: [expression: {simple: "..."}]). *)
Definition yexpr (e : expr) : chars :=
  match e with
  | XSimple p => obj [kv "simple" (jstr (Simple.render p))]
  | XLang (Lang.XConstant t _ _) => obj [kv "constant" (jstr t)]
  | XLang (Lang.XHeader n _) => obj [kv "header" (jstr n)]
  | XLang (Lang.XProp n _) => obj [kv "exchangeProperty" (jstr n)]
  | XLang (Lang.XVar n _) => obj [kv "variable" (jstr n)]
  | XLang _ => obj []
  end.
Definition exprf (e : expr) : chars := kv "expression" (yexpr e).

(*! R L6.yaml.strategy DOC [SPL.408] *)
Definition strat_f (st : strat) : list chars :=
  match st with
  | StNone => []
  | StLatest => [kv "aggregationStrategy" (jstr (s "#class:org.apache.camel.processor.aggregate.UseLatestAggregationStrategy"))]
  | StOriginal => [kv "aggregationStrategy" (jstr (s "#class:org.apache.camel.processor.aggregate.UseOriginalAggregationStrategy"))]
  | StGroupedBody => [kv "aggregationStrategy" (jstr (s "#class:org.apache.camel.processor.aggregate.GroupedBodyAggregationStrategy"))]
  end.
Definition uri (ep : endpoint) : chars :=
  match ep with EDirect n => s "direct:" ++ n | EMock n => s "mock:" ++ n end.
Fixpoint joinc (l : list chars) : chars :=
  match l with [] => [] | [x] => x | x :: r => x ++ s "," ++ joinc r end.
Definition step1 (name : string) (fields : list chars) : chars := obj [kv name (obj fields)].

(*! R L6.yaml.steps DOC [YML.22-34] [M:setHeader] [M:filter] [M:choice] [M:doTry] [M:doCatch] [M:split] [M:aggregate] [M:loop] [M:idempotentConsumer] [M:loadBalance] [M:routingSlip] [M:convertBodyTo] *)
(** Each step is a one-key object named after its EIP, its options as keys, the expression under [expression] and the
    outputs under [steps] ([YML.26-31]). *)
Fixpoint ystep (st : step) : chars :=
  let fix ysteps (l : list step) : list chars := match l with [] => [] | x :: r => ystep x :: ysteps r end in
  let stepsf (l : list step) : chars := kv "steps" (arr (ysteps l)) in
  let fix ywhens (ws : list (expr * list step)) : list chars :=
    match ws with [] => [] | (p, b) :: r => obj [exprf p; stepsf b] :: ywhens r end in
  let fix ycatches (cs : list (list chars * option expr * list step)) : list chars :=
    match cs with
    | [] => []
    | (ts, w, b) :: r =>
        obj ([kv "exception" (arr (map jstr ts))] ++
             (match w with Some p => [kv "onWhen" (obj [exprf p])] | None => [] end) ++ [stepsf b]) :: ycatches r
    end in
  match st with
  | SSetBody e => step1 "setBody" [exprf e]
  | STransform e => step1 "transform" [exprf e]
  | SSetHeader k e => step1 "setHeader" [kv "name" (jstr k); exprf e]
  | SSetProperty k e => step1 "setProperty" [kv "name" (jstr k); exprf e]
  | SSetVariable k e => step1 "setVariable" [kv "name" (jstr k); exprf e]
  | SRemoveHeader k => step1 "removeHeader" [kv "name" (jstr k)]
  | SRemoveHeaders p xs => step1 "removeHeaders" ([kv "pattern" (jstr p)] ++ match xs with [] => [] | _ => [kv "excludePattern" (jstr (joinc xs))] end)
  | SRemoveProperty k => step1 "removeProperty" [kv "name" (jstr k)]
  | SRemoveVariable k => step1 "removeVariable" [kv "name" (jstr k)]
  | SFilter p b => step1 "filter" [exprf p; stepsf b]
  | SChoice ws o => step1 "choice" ([kv "when" (arr (ywhens ws))] ++ match o with Some b => [kv "otherwise" (obj [stepsf b])] | None => [] end)
  | SPipeline b => step1 "pipeline" [stepsf b]
  | STo ep => step1 "to" [kv "uri" (jstr (uri ep))]
  | SStop => step1 "stop" []
  | SThrow c m => step1 "throwException" [kv "exceptionType" (jstr c); kv "message" (jstr m)]
  | SDoTry b cs f =>
      step1 "doTry" ([stepsf b] ++ (match cs with [] => [] | _ => [kv "doCatch" (arr (ycatches cs))] end) ++
                     match f with Some fb => [kv "doFinally" (obj [stepsf fb])] | None => [] end)
  | SSplit e o b =>
      step1 "split" ([exprf e] ++ (if sp_stop o then [kv "stopOnException" (s "true")] else []) ++
                     (match sp_group o with Some n => [kv "group" (ntxt n)] | None => [] end) ++
                     [kv "delimiter" (jstr (sp_delim o))] ++
                     (match sp_maxfail o with Some n => [kv "maxFailedRecords" (ntxt n)] | None => [] end) ++
                     strat_f (sp_strat o) ++ [stepsf b])
  | SMulticast stg b => step1 "multicast" (strat_f stg ++ [stepsf b])
  | SRecipientList stg e d => step1 "recipientList" ([exprf e; kv "delimiter" (jstr d)] ++ strat_f stg)
  | SAggregate o b =>
      step1 "aggregate" ([kv "correlationExpression" (yexpr (ago_corr o))] ++
                         (match ago_pred o with Some p => [kv "completionPredicate" (yexpr p)] | None => [] end) ++
                         strat_f (ago_strat o) ++
                         (match ago_size o with Some n => [kv "completionSize" (ntxt n)] | None => [] end) ++
                         (if ago_eager o then [kv "eagerCheckCompletion" (s "true")] else []) ++
                         (if ago_close o then [kv "closeCorrelationKeyOnCompletion" (s "0")] else []) ++
                         [kv "executorService" (jstr (s "syncExec")); stepsf b])
  | SLoop e cp dw b =>
      step1 "loop" ([exprf e] ++ (if cp then [kv "copy" (s "true")] else []) ++ (if dw then [kv "doWhile" (s "true")] else []) ++ [stepsf b])
  | SIdem _ e sk eg b =>
      step1 "idempotentConsumer" [exprf e; kv "idempotentRepository" (jstr (s "#class:org.apache.camel.support.processor.idempotent.MemoryIdempotentRepository"));
                                  kv "skipDuplicate" (btxt sk); kv "eager" (btxt eg); stepsf b]
  | SLB _ LBRoundRobin b => step1 "loadBalance" [kv "roundRobinLoadBalancer" (obj []); stepsf b]
  | SLB _ (LBFailover exs mx) b =>
      step1 "loadBalance" [kv "failoverLoadBalancer" (obj ((match exs with [] => [] | _ => [kv "exception" (arr (map jstr exs))] end) ++
                                                           [kv "maximumFailoverAttempts" (jstr (ztext mx))])); stepsf b]
  | SRoutingSlip e d => step1 "routingSlip" [exprf e; kv "uriDelimiter" (jstr d)]
  | SDynamicRouter e d => step1 "dynamicRouter" [exprf e; kv "uriDelimiter" (jstr d)]
  | SConvertBody t m => step1 "convertBodyTo" [kv "type" (jstr (str (Convert.jname t))); kv "mandatory" (btxt m)]
  end.
Definition ysteps (l : list step) : chars := arr (map ystep l).

(*! R L6.yaml.onException DOC [YML.36] [M:onException] [M:redeliveryPolicy] *)
(** [onException] is a top-level entry [YML.36] (the RouteBuilder scope of the program's clauses). *)
Definition yclause (k : clause) : chars :=
  obj [kv "onException" (obj (
    [kv "exception" (arr (map jstr (c_ex k)))] ++
    (match c_when k with Some p => [kv "onWhen" (obj [exprf p])] | None => [] end) ++
    (match c_redeliveries k with O => [] | n => [kv "redeliveryPolicy" (obj [kv "maximumRedeliveries" (ntxt n); kv "redeliveryDelay" (jstr (s "0"))])] end) ++
    (match c_handled k with Some b => [kv "handled" (obj [kv "constant" (jstr (btxt b))])] | None => [] end) ++
    (if c_continued k then [kv "continued" (obj [kv "constant" (jstr (s "true"))])] else []) ++
    [kv "steps" (ysteps (c_steps k))]))].

(*! R L6.yaml.routes DOC [YML.22-36] *)
(*! R L6.yaml.errorHandler DOC [EH.315-327] [M:deadLetterChannel] *)
(** The route's error handler as in the YAML tab of [EH.315-327]. *)
Definition yeh (E : ehconf) : list chars :=
  match E with
  | EHDefault => []
  | EHDlc q n uo =>
      [kv "errorHandler" (obj [kv "deadLetterChannel" (obj (
         [kv "deadLetterUri" (jstr (s "mock:" ++ q))] ++
         match uo with UONone => [] | UOMessage => [kv "useOriginalMessage" (s "true")] | UOBody => [kv "useOriginalBody" (s "true")] end ++
         [kv "redeliveryPolicy" (obj [kv "maximumRedeliveries" (ntxt n); kv "redeliveryDelay" (jstr (s "0"))])]))])]
  end.
(*! R L6.yaml.onCompletion DOC [OC.91] [OC.95-112] [M:onCompletion] *)
(** "In YAML a route scoped onCompletion is declared in a routeConfiguration that the route refers to" [OC.91]. *)
Definition yoc (o : oncomp) : chars :=
  obj [kv "routeConfiguration" (obj [kv "id" (jstr (s "ocConfig"));
    kv "onCompletion" (arr [obj [kv "onCompletion" (obj (
      (match oc_trig o with OcAlways => [] | OcComplete => [kv "onCompleteOnly" (jstr (s "true"))]
                         | OcFailure => [kv "onFailureOnly" (jstr (s "true"))] end) ++
      (if oc_before o then [kv "mode" (jstr (s "BeforeConsumer"))] else []) ++
      (if oc_orig o then [kv "useOriginalMessage" (jstr (s "true"))] else []) ++
      (match oc_when o with Some p => [kv "onWhen" (obj [exprf p])] | None => [] end) ++
      [kv "steps" (ysteps (oc_steps o))]))]])])].
Definition yroute (E : ehconf) (rc : bool) (r : route) : chars :=
  obj [kv "route" (obj ([kv "id" (jstr (r_id r))] ++ yeh E ++
                        (if rc then [kv "routeConfigurationId" (jstr (s "ocConfig"))] else []) ++
                        [kv "from" (obj [kv "uri" (jstr (s "direct:" ++ r_from r)); kv "steps" (ysteps (r_steps r))])]))].
Definition yaml_program (C : list clause) (E : ehconf) (OC : option oncomp) (P : list route) : chars :=
  arr (map yclause C ++ (match OC with Some o => [yoc o] | None => [] end) ++
       match P with [] => [] | r0 :: rs => yroute E (match OC with Some _ => true | None => false end) r0 :: map (yroute E false) rs end).
