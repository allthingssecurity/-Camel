(** * L6 XML DSL: the documented XML form of the L2/L3 route model.

    The L6 rule is a rendering: the route model of L2/Route.v (and its onException clauses) written as an XML DSL
    file. Loading that file in Camel must give routes that behave as the L2 rules say (the L6 differential runs every
    generated case through this text instead of the model API, and compares with the same expected trace).
    Legend (paths under docs/):
      [XIO] dsl/camel-xml-io-dsl/src/main/docs/java-xml-io-dsl.adoc
      [M:x] model/x.json: the "kind" of each option: "attribute" is an XML attribute, "element" / "expression" a
            child element, "outputs" the steps as child elements (the EIP pages show the same in their XML tabs)
      [SPL] core/camel-core-engine/src/main/docs/modules/eips/pages/split-eip.adoc (the #class: reference syntax)
      [EH]  docs/user-manual/modules/ROOT/pages/error-handler.adoc; [M:deadLetterChannel] model/deadLetterChannel.json
    XML escaping of text and attribute values is XML itself, not Camel documentation (TRUST.md). *)
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
Fixpoint xesc (t : chars) : chars :=
  match t with
  | [] => []
  | c :: r =>
      (if ceq c "&"%char then s "&amp;" else if ceq c "<"%char then s "&lt;" else if ceq c ">"%char then s "&gt;"
       else if ceq c (ascii_of_nat 34) then s "&quot;" else if ceq c "'"%char then s "&apos;" else [c]) ++ xesc r
  end.
Definition attr (k : string) (v : chars) : chars := s " " ++ s k ++ s "=""" ++ xesc v ++ s """".
Definition elem (tag : string) (attrs : chars) (body : chars) : chars :=
  s "<" ++ s tag ++ attrs ++ s ">" ++ body ++ s "</" ++ s tag ++ s ">".
Definition empty (tag : string) (attrs : chars) : chars := s "<" ++ s tag ++ attrs ++ s "/>".
Definition btxt (b : bool) : chars := if b then s "true" else s "false".
Definition ntxt (n : nat) : chars := ztext (Z.of_nat n).

(*! R L6.xml.expression DOC [M:setHeader] [XIO.33-41] *)
(** An expression is a child element named after its language, with the expression text as content ([XIO.36-38]:
    [<setBody><constant>Hello Camel!</constant></setBody>]); header/exchangeProperty/variable take the name. *)
Definition xexpr (e : expr) : chars :=
  match e with
  | XSimple p => elem "simple" [] (xesc (Simple.render p))
  | XLang (Lang.XConstant t _ _) => elem "constant" [] (xesc t)
  | XLang (Lang.XHeader n _) => elem "header" [] (xesc n)
  | XLang (Lang.XProp n _) => elem "exchangeProperty" [] (xesc n)
  | XLang (Lang.XVar n _) => elem "variable" [] (xesc n)
  | XLang _ => s "<!-- not rendered -->"
  end.

(*! R L6.xml.strategy DOC [SPL.408] [M:split.aggregationStrategy] *)
(** "we can refer to the FQN class name with #class: syntax" [SPL.408]: a new instance per reference. *)
Definition strat_attr (st : strat) : chars :=
  match st with
  | StNone => []
  | StLatest => attr "aggregationStrategy" (s "#class:org.apache.camel.processor.aggregate.UseLatestAggregationStrategy")
  | StOriginal => attr "aggregationStrategy" (s "#class:org.apache.camel.processor.aggregate.UseOriginalAggregationStrategy")
  | StGroupedBody => attr "aggregationStrategy" (s "#class:org.apache.camel.processor.aggregate.GroupedBodyAggregationStrategy")
  end.
Definition uri (ep : endpoint) : chars :=
  match ep with EDirect n => s "direct:" ++ n | EMock n => s "mock:" ++ n end.
Fixpoint joinc (l : list chars) : chars :=
  match l with [] => [] | [x] => x | x :: r => x ++ s "," ++ joinc r end.

(*! R L6.xml.steps DOC [M:setHeader] [M:removeHeaders] [M:throwException] [M:filter] [M:choice] [M:doTry] [M:doCatch] [M:split] [M:multicast] [M:recipientList] [M:aggregate] [M:loop] [M:idempotentConsumer] [M:loadBalance] [M:routingSlip] [M:dynamicRouter] [M:convertBodyTo] *)
(** Each step is the element of its EIP; options of kind "attribute" are attributes, the expression and the outputs
    are child elements (the "kind" of each option in model/<eip>.json). *)
Fixpoint xstep (st : step) : chars :=
  let fix xsteps (l : list step) : chars := match l with [] => [] | x :: r => xstep x ++ xsteps r end in
  let fix xwhens (ws : list (expr * list step)) : chars :=
    match ws with [] => [] | (p, b) :: r => elem "when" [] (xexpr p ++ xsteps b) ++ xwhens r end in
  let fix xcatches (cs : list (list chars * option expr * list step)) : chars :=
    match cs with
    | [] => []
    | (ts, w, b) :: r =>
        elem "doCatch" [] (concat_with [] (map (fun t => elem "exception" [] (xesc t)) ts) ++
                          (match w with Some p => elem "onWhen" [] (xexpr p) | None => [] end) ++ xsteps b) ++ xcatches r
    end in
  match st with
  | SSetBody e => elem "setBody" [] (xexpr e)
  | STransform e => elem "transform" [] (xexpr e)
  | SSetHeader k e => elem "setHeader" (attr "name" k) (xexpr e)
  | SSetProperty k e => elem "setProperty" (attr "name" k) (xexpr e)
  | SSetVariable k e => elem "setVariable" (attr "name" k) (xexpr e)
  | SRemoveHeader k => empty "removeHeader" (attr "name" k)
  | SRemoveHeaders p xs => empty "removeHeaders" (attr "pattern" p ++ match xs with [] => [] | _ => attr "excludePattern" (joinc xs) end)
  | SRemoveProperty k => empty "removeProperty" (attr "name" k)
  | SRemoveVariable k => empty "removeVariable" (attr "name" k)
  | SFilter p b => elem "filter" [] (xexpr p ++ xsteps b)
  | SChoice ws o => elem "choice" [] (xwhens ws ++ match o with Some b => elem "otherwise" [] (xsteps b) | None => [] end)
  | SPipeline b => elem "pipeline" [] (xsteps b)
  | STo ep => empty "to" (attr "uri" (uri ep))
  | SStop => empty "stop" []
  | SThrow c m => empty "throwException" (attr "exceptionType" c ++ attr "message" m)
  | SDoTry b cs f => elem "doTry" [] (xsteps b ++ xcatches cs ++ match f with Some fb => elem "doFinally" [] (xsteps fb) | None => [] end)
  | SSplit e o b =>
      elem "split" ((if sp_stop o then attr "stopOnException" (s "true") else []) ++
                    (match sp_group o with Some n => attr "group" (ntxt n) | None => [] end) ++
                    attr "delimiter" (sp_delim o) ++
                    (match sp_maxfail o with Some n => attr "maxFailedRecords" (ntxt n) | None => [] end) ++
                    strat_attr (sp_strat o))
           (xexpr e ++ xsteps b)
  | SMulticast stg b => elem "multicast" (strat_attr stg) (xsteps b)
  | SRecipientList stg e d => elem "recipientList" (attr "delimiter" d ++ strat_attr stg) (xexpr e)
  | SAggregate o b =>
      elem "aggregate" (strat_attr (ago_strat o) ++
                        (match ago_size o with Some n => attr "completionSize" (ntxt n) | None => [] end) ++
                        (if ago_eager o then attr "eagerCheckCompletion" (s "true") else []) ++
                        (if ago_close o then attr "closeCorrelationKeyOnCompletion" (s "0") else []) ++
                        attr "executorService" (s "syncExec"))
           (elem "correlationExpression" [] (xexpr (ago_corr o)) ++
            (match ago_pred o with Some p => elem "completionPredicate" [] (xexpr p) | None => [] end) ++ xsteps b)
  | SLoop e cp dw b =>
      elem "loop" ((if cp then attr "copy" (s "true") else []) ++ (if dw then attr "doWhile" (s "true") else []))
           (xexpr e ++ xsteps b)
  | SIdem _ e sk eg b =>
      elem "idempotentConsumer" (attr "idempotentRepository" (s "#class:org.apache.camel.support.processor.idempotent.MemoryIdempotentRepository") ++
                                 attr "skipDuplicate" (btxt sk) ++ attr "eager" (btxt eg))
           (xexpr e ++ xsteps b)
  | SLB _ LBRoundRobin b => elem "loadBalance" [] (empty "roundRobinLoadBalancer" [] ++ xsteps b)
  | SLB _ (LBFailover exs mx) b =>
      elem "loadBalance" [] (elem "failoverLoadBalancer" (attr "maximumFailoverAttempts" (ztext mx))
                                  (concat_with [] (map (fun t => elem "exception" [] (xesc t)) exs)) ++ xsteps b)
  | SRoutingSlip e d => elem "routingSlip" (attr "uriDelimiter" d) (xexpr e)
  | SDynamicRouter e d => elem "dynamicRouter" (attr "uriDelimiter" d) (xexpr e)
  | SConvertBody t m => empty "convertBodyTo" (attr "type" (str (Convert.jname t)) ++ attr "mandatory" (btxt m))
  end.
Definition xsteps (l : list step) : chars := concat_with [] (map xstep l).

(*! R L6.xml.onException DOC [M:onException] [M:redeliveryPolicy] *)
(** A clause is an [onException] element at the start of the route: [exception] elements, [onWhen], a
    [redeliveryPolicy] element, [handled]/[continued] as expressions (here constants), and the steps. *)
Definition xclause (k : clause) : chars :=
  elem "onException" []
    (concat_with [] (map (fun t => elem "exception" [] (xesc t)) (c_ex k)) ++
     (match c_when k with Some p => elem "onWhen" [] (xexpr p) | None => [] end) ++
     (match c_redeliveries k with O => [] | n => empty "redeliveryPolicy" (attr "maximumRedeliveries" (ntxt n) ++ attr "redeliveryDelay" (s "0")) end) ++
     (match c_handled k with Some b => elem "handled" [] (elem "constant" [] (btxt b)) | None => [] end) ++
     (if c_continued k then elem "continued" [] (elem "constant" [] (s "true")) else []) ++
     xsteps (c_steps k)).

(*! R L6.xml.routes DOC [XIO.33-44] [M:route] [M:from] *)
(** [<routes xmlns="http://camel.apache.org/schema/xml-io">] holding [<route id>] elements, each starting with
    [<from uri>] [XIO.33-41]; the program's clauses are written into every route (route-scoped copies, as the
    model-API harness does: TRUST.md 8). *)
(*! R L6.xml.errorHandler DOC [EH.259-268] [M:deadLetterChannel] *)
(** The route's error handler as in [EH.259-268]: [<errorHandler><deadLetterChannel deadLetterUri>] with a
    [redeliveryPolicy] and the useOriginalMessage / useOriginalBody attributes [M:deadLetterChannel]; nothing for the
    default error handler. *)
Definition xeh (E : ehconf) : chars :=
  match E with
  | EHDefault => []
  | EHDlc q n uo =>
      elem "errorHandler" [] (elem "deadLetterChannel" (attr "deadLetterUri" (s "mock:" ++ q) ++
                                match uo with UONone => [] | UOMessage => attr "useOriginalMessage" (s "true")
                                            | UOBody => attr "useOriginalBody" (s "true") end)
        (empty "redeliveryPolicy" (attr "maximumRedeliveries" (ntxt n) ++ attr "redeliveryDelay" (s "0"))))
  end.
Definition xroute (C : list clause) (E : ehconf) (r : route) : chars :=
  elem "route" (attr "id" (r_id r))
       (xeh E ++ empty "from" (attr "uri" (s "direct:" ++ r_from r)) ++ concat_with [] (map xclause C) ++ xsteps (r_steps r)).
Definition xml_program (C : list clause) (E : ehconf) (P : list route) : chars :=
  elem "routes" (attr "xmlns" (s "http://camel.apache.org/schema/xml-io")) (concat_with [] (map (xroute C E) P)).
