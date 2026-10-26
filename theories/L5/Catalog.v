(** * L5a on the real tables: the generic rules of Uri.v applied to the generated catalog of the pin, the documented
    URI examples (proved by computation), and properties of the rules.

    Legend: as Uri.v, plus
      [TIM]  components/camel-timer/src/main/docs/timer-component.adoc
      [LOGC] components/camel-log/src/main/docs/log-component.adoc
      [SEDA] components/camel-seda/src/main/docs/seda-component.adoc
      [CB]   components/camel-controlbus/src/main/docs/controlbus-component.adoc
      [BEAN] components/camel-bean/src/main/docs/bean-component.adoc
      [CLS]  components/camel-bean/src/main/docs/class-component.adoc *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Convert Exchange.
From CamelSpec.L5 Require Import Model GenCatalog Uri.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** The components compiled at the pin for the endpoint-level differential (harness/build-camel.sh): camel-direct,
    -mock, -seda, -log, -timer, -bean (schemes bean and class) and -controlbus. *)
Definition avail_pin : list string := ["direct"; "mock"; "seda"; "log"; "timer"; "bean"; "class"; "controlbus"].

(** ** L5b constraints met at the pin

    The generic contract (Uri.v) reads only the option tables. A few components document more in an option's
    description, or check values the table does not restrict; where the endpoint-level differential met them they are
    listed here, so that L5a does not claim an endpoint the component itself refuses. Each is a component rule (L5b)
    or an UNSPECIFIED case. *)
Definition bfind (n : string) (b : list (chars * bval)) : option bval :=
  option_map snd (List.find (fun '(k, _) => ceqs k (str n)) b).
Definition bint (n : string) (b : list (chars * bval)) : option Z :=
  match bfind n b with Some (BV (VInt z)) => Some z | _ => None end.
(*! R L5.b.seda.concurrent-limit DOC [CJ:seda.json.51] [CJ:seda.json.47] *)
(** limitConcurrentConsumers: "Whether to limit the number of concurrentConsumers to the maximum of 500. By default, an
    exception will be thrown if an endpoint is configured with a greater number" [CJ:seda.json.51]. *)
(*! R L5.b.group-size DOC [CJ:log.json.42] [CJ:mock.json.45] *)
(** log groupSize, mock reportGroup: "a group size for throughput logging" [CJ:log.json.42]; a size that is not
    positive is not documented. *)
(*! R L5.b.class-bean-properties DOC [CJ:class.json.41] *)
(** class: [bean.*] "Used for configuring additional properties on the bean" [CJ:class.json.41]: which properties the
    created bean has is not in the table. *)
(*! R L5.b.seda.size DOC [CJ:seda.json.28] *)
(** seda size: "The maximum capacity of the SEDA queue"; a size that is not positive is not documented. *)
(*! R L5.b.registry DOC [BEAN.24] [CLS.27] *)
(** bean: "beanName can be any string used to look up the bean in the Registry" [BEAN.24]; class: "the fully qualified
    class name to create and use as bean" [CLS.27]. What endpoint creation does when there is no such bean or class is
    not documented; the harness registry holds [pin_beans], and [pin_classes] are on its classpath. *)
Definition pin_beans : list string := ["myBean"; "otherBean"].
Definition pin_classes : list string := ["java.lang.Object"; "java.util.ArrayList"; "java.lang.StringBuilder"].
Definition bnonpos (n : string) (b : list (chars * bval)) : bool :=
  match bfind n b with Some (BV (VInt z)) | Some (BV (VLong z)) => Z.leb z 0 | _ => false end.
Definition bstr_in (n : string) (l : list string) (b : list (chars * bval)) : bool :=
  match bfind n b with Some (BV (VStr v)) => existsb (fun x => ceqs (str x) v) l | _ => false end.
(*! R L5.b.seda.virtual-threads DOC [CJ:seda.json.47] *)
(** concurrentConsumers: "When virtualThreadPerTask is enabled, this becomes a concurrency limit (0 = unlimited) and
    defaults to 0 instead of 1" [CJ:seda.json.47]. *)
Definition seda_vt (ps : list (chars * pval)) (b : list (chars * bval)) : list (chars * bval) :=
  match bfind "virtualThreadPerTask" b with
  | Some (BV (VBool true)) =>
      if existsb (fun '(n, _) => ieq n (str "concurrentConsumers")) ps then b
      else map (fun '(k, v) => if ceqs k (str "concurrentConsumers") then (k, BV (VInt 0)) else (k, v)) b
  | _ => b
  end.
Definition l5b (s : chars) (b : list (chars * bval)) : option (eres * string) :=
  if ceqs s (str "seda") then
    if bnonpos "size" b then Some (EUns "CJ:seda.json.28: a queue size that is not positive (not documented)", "L5.b.seda.size") else
    match bint "concurrentConsumers" b, bfind "limitConcurrentConsumers" b with
    | Some z, Some (BV (VBool true)) =>
        if Z.ltb 500 z then Some (EFailAny "CJ:seda.json.51: more than 500 concurrentConsumers with limitConcurrentConsumers", "L5.b.seda.concurrent-limit")
        else None
    | _, _ => None
    end
  else if ceqs s (str "log") then
    if bnonpos "groupSize" b || bnonpos "groupInterval" b || bnonpos "groupDelay" b
    then Some (EUns "CJ:log.json.42: a group size, interval or delay that is not positive (not documented)", "L5.b.group-size") else None
  else if ceqs s (str "mock") then
    if bnonpos "reportGroup" b then Some (EUns "CJ:mock.json.45: a report group that is not positive (not documented)", "L5.b.group-size") else None
  else if ceqs s (str "bean") then
    if bstr_in "beanName" pin_beans b then None else Some (EUns "BEAN.24: a bean name that is not in the registry (not documented)", "L5.b.registry")
  else if ceqs s (str "class") then
    if negb (bstr_in "beanName" pin_classes b) then Some (EUns "CLS.27: a class name that is not a loadable class (not documented)", "L5.b.registry")
    else if existsb (fun '(_, v) => match v with BPre _ _ => true | _ => false end) b
    then Some (EUns "CJ:class.json.41: bean.* sets properties of the created bean (not in the table)", "L5.b.class-bean-properties")
    else None
  else None.

(*! R L5.b.log.logmask-default DOC-BUG [CJ:log.json.44] LogEndpoint.logMask *)
(** log logMask: the table's Default is [false] [CJ:log.json.44], but the option is a [java.lang.Boolean] that is
    unset (null) unless the URI sets it, and then the CamelContext's logMask applies ("logMask != null ? logMask :
    getCamelContext().isLogMask()", LogEndpoint line 318): deliberate, the Default column simplifies it (notes/l5.md,
    doc bug). Rule: an unset logMask is not compared. Seen in runs/l5-first: 749 of 749 log endpoints. *)
Definition log_mask (ps : list (chars * pval)) (b : list (chars * bval)) : list (chars * bval) :=
  if existsb (fun '(n, _) => ieq n (str "logMask")) ps then b
  else filter (fun '(k, _) => negb (ceqs k (str "logMask"))) b.

(** Endpoint creation at the pin: the generic rules, then the L5b constraints. *)
Definition run_pin (u : chars) : eres * list string :=
  let '(r, h) := run_ep avail_pin catalog u in
  match r, lex u with
  | EOk b0, LLex s _ ps =>
      let b := if ceqs s (str "seda") then seda_vt ps b0
               else if ceqs s (str "log") then log_mask ps b0 else b0 in
      let h' := match bfind "virtualThreadPerTask" b0 with
                | Some (BV (VBool true)) => if ceqs s (str "seda") then h ++ ["L5.b.seda.virtual-threads"] else h
                | _ => h end in
      let h'' := if ceqs s (str "log") && negb (existsb (fun '(n, _) => ieq n (str "logMask")) ps)
                 then h' ++ ["L5.b.log.logmask-default"] else h' in
      match l5b s b with Some (r', id) => (r', h'' ++ [id]) | None => (EOk b, h'') end
  | _, _ => (r, h)
  end.

Definition ep (s : string) : eres := fst (run_pin (str s)).
Definition ep_with (a : list string) (s : string) : eres := fst (run_ep a catalog (str s)).
Definition bget (n : string) (r : eres) : option bval :=
  match r with EOk b => option_map snd (List.find (fun '(k, _) => ceqs k (str n)) b) | _ => None end.
Definition is_uns (r : eres) : bool := match r with EUns _ => true | _ => false end.
Definition vs (s : string) : bval := BV (VStr (str s)).
Definition props (s : string) : option (list (string * string)) :=
  match fst (cat_props catalog (str s)) with
  | CpProps kv => Some (map (fun '(k, v) => (string_of_list_ascii k, string_of_list_ascii v)) kv)
  | CpUns _ => None
  end.
Definition validate (s : string) : cvres := fst (cat_validate catalog false (str s)).

(** ** Documented examples *)

(** [END.200]: [timer://myTimer?fixedRate=true&delay=0&period=2000]. *)
Example doc_timer_mytimer :
  let r := ep "timer://myTimer?fixedRate=true&delay=0&period=2000" in
  (bget "timerName" r, bget "fixedRate" r, bget "delay" r, bget "period" r)
  = (Some (vs "myTimer"), Some (BV (VBool true)), Some (BV (VLong 0)), Some (BV (VLong 2000))).
Proof. vm_compute. reflexivity. Qed.
(** [TIM.79]: "a route that generates an event every 60 seconds". *)
Example doc_timer_60s :
  let r := ep "timer://foo?fixedRate=true&period=60000" in (bget "timerName" r, bget "period" r)
  = (Some (vs "foo"), Some (BV (VLong 60000))).
Proof. vm_compute. reflexivity. Qed.
(** [END.442], [END.476-478], [END.542]: the readable durations. *)
Example doc_period_45m : bget "period" (ep "timer:foo?period=45m") = Some (BV (VLong 2700000)).
Proof. vm_compute. reflexivity. Qed.
Example doc_period_1h15m : bget "period" (ep "timer:foo?period=1h15m") = Some (BV (VLong 4500000)).
Proof. vm_compute. reflexivity. Qed.
Example doc_period_2h30s : bget "period" (ep "timer:bar?period=2h30s") = Some (BV (VLong 7230000)).
Proof. vm_compute. reflexivity. Qed.
Example doc_period_3h45m58s : bget "period" (ep "timer:bar?period=3h45m58s") = Some (BV (VLong 13558000)).
Proof. vm_compute. reflexivity. Qed.
Example doc_period_45minutes : bget "period" (ep "timer:foo?period=45minutes") = Some (BV (VLong 2700000)).
Proof. vm_compute. reflexivity. Qed.
(** The default of an option not set [CEO.8]: the timer period is 1000 [CJ:timer.json.44]. *)
Example doc_period_default : bget "period" (ep "timer:foo") = Some (BV (VLong 1000)).
Proof. vm_compute. reflexivity. Qed.
(** [LOGC.53]: [log:org.apache.camel.example?level=DEBUG]. *)
Example doc_log_level :
  let r := ep "log:org.apache.camel.example?level=DEBUG" in (bget "loggerName" r, bget "level" r)
  = (Some (vs "org.apache.camel.example"), Some (vs "DEBUG")).
Proof. vm_compute. reflexivity. Qed.
(** [SEDA.176]: [seda:stageName?concurrentConsumers=5]. *)
Example doc_seda_stage :
  let r := ep "seda:stageName?concurrentConsumers=5" in (bget "name" r, bget "concurrentConsumers" r)
  = (Some (vs "stageName"), Some (BV (VInt 5))).
Proof. vm_compute. reflexivity. Qed.
(** [CB]: [controlbus:route?routeId=foo&action=start]. *)
Example doc_controlbus_route :
  let r := ep "controlbus:route?routeId=foo&action=start" in (bget "command" r, bget "routeId" r, bget "action" r)
  = (Some (vs "route"), Some (vs "foo"), Some (vs "start")).
Proof. vm_compute. reflexivity. Qed.
(** [URIS.9-19]: [kafka:cheese?brokers=mykafka:1234&clientId=foo]: the context path [cheese] is the topic, and two
    query parameters. Both readers agree. *)
Example doc_kafka_uri_props :
  props "kafka:cheese?brokers=mykafka:1234&clientId=foo"
  = Some [("topic", "cheese"); ("brokers", "mykafka:1234"); ("clientId", "foo")].
Proof. vm_compute. reflexivity. Qed.
Example doc_kafka_uri_endpoint :
  let r := ep_with ["kafka"] "kafka:cheese?brokers=mykafka:1234&clientId=foo" in
  (bget "topic" r, bget "brokers" r, bget "clientId" r) = (Some (vs "cheese"), Some (vs "mykafka:1234"), Some (vs "foo")).
Proof. vm_compute. reflexivity. Qed.
(** [END.232], [END.261-272], [END.276-277]: the RAW password, "as typed", and the expanded form ([host]). *)
Example doc_ftp_raw_password :
  let r := ep_with ["ftp"] "ftp:joe@myftpserver.com?password=RAW(se+re?t&23)&binary=true" in
  (bget "host" r, bget "password" r, bget "binary" r)
  = (Some (vs "joe@myftpserver.com"), Some (vs "se+re?t&23"), Some (BV (VBool true))).
Proof. vm_compute. reflexivity. Qed.
(** [END.279]: [RAW{se+re)t&23}] keeps the [)]; with [RAW(...)] the same password is not documented. *)
Example doc_raw_brace :
  bget "password" (ep_with ["ftp"] "ftp:joe@myftpserver.com?password=RAW{se+re)t&23}&binary=true")
  = Some (vs "se+re)t&23").
Proof. vm_compute. reflexivity. Qed.
Example doc_raw_paren_corner :
  is_uns (ep_with ["ftp"] "ftp:joe@myftpserver.com?password=RAW(se+re)t&23)&binary=true") = true.
Proof. vm_compute. reflexivity. Qed.
(** [END.23-24]: [file:messages/foo] and [jms:queue:foo]; [END.263-265]: [file:inbox] is [directoryName: inbox]. *)
Example doc_file_jms_paths :
  (props "file:messages/foo", props "jms:queue:foo", props "file:inbox")
  = (Some [("directoryName", "messages/foo")], Some [("destinationType", "queue"); ("destinationName", "foo")],
     Some [("directoryName", "inbox")]).
Proof. vm_compute. reflexivity. Qed.
(** [END.68], [END.86-90]: a [#bean:] reference is the option's text in the key/value form. *)
Example doc_file_bean_ref :
  props "file:messages/foo?sorter=#bean:mySpecialFileSorter"
  = Some [("directoryName", "messages/foo"); ("sorter", "#bean:mySpecialFileSorter")].
Proof. vm_compute. reflexivity. Qed.
(** [END.109]: a [#class:] reference with constructor arguments. *)
Example doc_file_class_ref :
  props "file://inbox?sorter=#class:com.foo.MySpecialSorter(10, 'Hello world', true)"
  = Some [("directoryName", "inbox"); ("sorter", "#class:com.foo.MySpecialSorter(10, 'Hello world', true)")].
Proof. vm_compute. reflexivity. Qed.
(** [CMP.11], [CMP.98]: [pop3://john.smith@mailserv.example.com?password=myPassword] (syntax [pop3:host:port]). *)
Example doc_pop3 :
  props "pop3://john.smith@mailserv.example.com?password=myPassword"
  = Some [("host", "john.smith@mailserv.example.com"); ("password", "myPassword")].
Proof. vm_compute. reflexivity. Qed.
(** [CRMP.113-129]: the typo [perid] is an unknown option; [CRMP.105] the correct URI validates. At endpoint
    creation the typo fails with [ResolveEndpointFailedException] [WC.62-64]. *)
Example doc_validate_perid : validate "timer:foo?perid=5000" = CvRep [str "perid"] [] [].
Proof. vm_compute. reflexivity. Qed.
Example doc_validate_period : validate "timer:foo?period=5000" = CvRep [] [] [].
Proof. vm_compute. reflexivity. Qed.
Example doc_endpoint_perid : ep "timer:foo?perid=5000" = EFail RFE.
Proof. vm_compute. reflexivity. Qed.
(** [MCP.236]: [kafka:myTopic] without the kafka component. *)
Example doc_kafka_missing : ep "kafka:myTopic" = EFail NSEE.
Proof. vm_compute. reflexivity. Qed.
(** [UG32.444-449]: "an endpoint URI without a context path, such as [log]" gives [NoSuchEndpointException]. The rule
    no longer reproduces this doc example ([L5.ep.no-colon] is DOC-BUG, notes/l5.md): [log] names the log component,
    whose required path is then missing (UNSPECIFIED); a URI without [:] that names no component still gives
    [NoSuchEndpointException]. *)
Example doc_no_context_path_log : is_uns (ep "log") = true.
Proof. vm_compute. reflexivity. Qed.
Example doc_no_context_path_unknown : ep "zzzunknown" = EFail NSEE.
Proof. vm_compute. reflexivity. Qed.
(** [END.128]: the example [file://inbox?idempontentRepository=#type:...] misspells [idempotentRepository]
    [CJ:file.json]; as written it names an unknown option (doc bug, notes/l5.md). *)
Example doc_idempotent_typo :
  validate "file://inbox?idempontentRepository=#type:org.apache.camel.spi.IdempotentRepository"
  = CvRep [str "idempontentRepository"] [] [].
Proof. vm_compute. reflexivity. Qed.
(** [END.139]: [direct:start?paramA=1&paramB=2] only illustrates XML escaping; the direct component has no such options
    [CJ:direct.json], so the URI as written fails (notes/l5.md). *)
Example doc_direct_xml_escaping : ep "direct:start?paramA=1&paramB=2" = EFail RFE.
Proof. vm_compute. reflexivity. Qed.
(** [BT.435-436]: an enum value in another style is the same value. *)
Example doc_enum_any_style :
  (bget "exchangePattern" (ep "timer:a?exchangePattern=in-out"), bget "runLoggingLevel" (ep "timer:a?runLoggingLevel=warn"))
  = (Some (BEnum (str "InOut")), Some (BEnum (str "WARN"))).
Proof. vm_compute. reflexivity. Qed.
(** [CCJ.624-629]: asEndpointUri in the order of the properties. *)
Example doc_asuri_order :
  fst (cat_asuri catalog (str "timer") [(str "period", str "5000"); (str "timerName", str "foo"); (str "delay", str "10")])
  = CaUri (str "timer:foo?period=5000&delay=10").
Proof. vm_compute. reflexivity. Qed.

(** ** Properties *)

(** Non-vacuity of [run_ep_sound] (CONVENTIONS practice 4): the rules derive the [END.200] endpoint. *)
Example rules_derive_timer : exists r, creates avail_pin catalog (str "timer://myTimer?fixedRate=true&delay=0&period=2000") r
  /\ r <> EFail NSEE.
Proof.
  destruct (run_ep avail_pin catalog (str "timer://myTimer?fixedRate=true&delay=0&period=2000")) as [r h] eqn:E.
  exists r. split.
  - apply (run_ep_sound _ _ _ _ _ E). vm_compute in E. inversion E; subst. reflexivity.
  - vm_compute in E. inversion E; subst. discriminate.
Qed.
Example rules_derive_perid : validates catalog false (str "timer:foo?perid=5000") (CvRep [str "perid"] [] []).
Proof.
  destruct (cat_validate catalog false (str "timer:foo?perid=5000")) as [r h] eqn:E.
  pose proof (cat_validate_sound _ _ _ _ _ E) as S. vm_compute in E. inversion E; subst. apply S. reflexivity.
Qed.

(** A component with lenient properties never reports an unknown option: [param_res] gives no [PUnk]. *)
Lemma resolve_unknown_strict : forall cat c n, resolve_name cat c n = NUnknown -> c_lenient c = false.
Proof.
  intros cat c n H. unfold resolve_name in H.
  repeat match type of H with
         | context [match ?x with _ => _ end] => let E := fresh in destruct x eqn:E
         | context [if ?x then _ else _] => let E := fresh in destruct x eqn:E
         end; try discriminate; reflexivity.
Qed.
Lemma lenient_no_unknown : forall cat c np, c_lenient c = true -> is_unk (param_res cat c np) = false.
Proof.
  intros cat c [n pv] L. unfold param_res.
  destruct (has "%"%char n || has "+"%char n); [reflexivity|].
  destruct (ceqs n (str "hash")); [destruct cat; reflexivity|].
  destruct (resolve_name cat c n) eqn:R; try reflexivity.
  - destruct (param_text cat pv); reflexivity.
  - destruct (param_text cat pv); [destruct (isnil _)|]; reflexivity.
  - apply resolve_unknown_strict in R. congruence.
Qed.
(** ... so, unless a value is bad ([L5.ep.bad-value]), a lenient component never fails with
    [ResolveEndpointFailedException]. *)
Theorem lenient_no_rfe : forall avail cat u c s p ps h,
  lex u = LLex s p ps -> avail_comp avail cat s = Some c -> c_lenient c = true ->
  existsb is_bad (map (param_res false c) ps) = false ->
  run_ep avail cat u <> (EFail RFE, h).
Proof.
  intros avail cat u c s p ps h L A Len B H. unfold run_ep in H. rewrite L, A in H. rewrite B in H.
  assert (E : forall l, existsb is_unk (map (param_res false c) l) = false).
  { induction l as [|np l IH]; [reflexivity|]. simpl. rewrite lenient_no_unknown by exact Len. exact IH. }
  rewrite (E ps) in H.
  repeat match type of H with
         | context [match ?x with _ => _ end] => destruct x
         | context [if ?x then _ else _] => destruct x
         end; discriminate.
Qed.
(** Non-vacuity: mock is lenient [CJ:mock.json.22], and an unknown name is accepted. *)
Example lenient_mock : c_lenient c_mock = true /\ bget "name" (ep "mock:x?zzNotAnOption=1") = Some (vs "x").
Proof. vm_compute. split; reflexivity. Qed.

(** ** Real mode (CONVENTIONS practice 2): the rules plus the open findings as explicit deltas

    [run_real] is [run_pin] with what Camel at the pin does where a finding says it disagrees with the docs; each delta
    names its finding. Differential runs in Real mode must show no disagreement (a new one is a Camel change or a spec
    bug). [cat_validate_real] likewise for the catalog. *)
Definition exact_given (n : string) (ps : list (chars * pval)) : bool := existsb (fun '(k, _) => ceqs k (str n)) ps.
Definition other_case (n : string) (ps : list (chars * pval)) : bool :=
  existsb (fun '(k, _) => ieq k (str n) && negb (ceqs k (str n))) ps.
Definition set_b (n : string) (v : bval) (b : list (chars * bval)) : list (chars * bval) :=
  map (fun '(k, x) => if ceqs k (str n) then (k, v) else (k, x)) b.
Definition has_text_value (p : chars -> bool) (ps : list (chars * pval)) : bool :=
  existsb (fun '(_, v) => match v with PText t => p t | PRaw _ => false end) ps.

Definition run_real (u : chars) : eres * list string :=
  match lex u with
  | LLex s _ ps =>
    (* findings/2026-10-26-l5-seda-offertimeout-duration: a readable duration for offerTimeout fails *)
    if ceqs s (str "seda") && existsb (fun '(k, v) => ceqs k (str "offerTimeout") &&
                                   match v with PText t | PRaw t => negb (all_digits t) end) ps
         && match fst (run_pin u) with EOk _ => true | _ => false end
    then (EFail RFE, ["REAL.seda-offertimeout"])
    else
    let '(r, h) := run_pin u in
    match r with
    | EFailAny w =>
        (* findings/2026-10-26-l5-ignore-case-global-options-dropped: the 500 limit is only checked in the exact case *)
        if exact_given "concurrentConsumers" ps then (r, h)
        else match run_ep avail_pin catalog u with (EOk b, _) => (EOk b, h ++ ["REAL.case-name"]) | x => x end
    | EOk b =>
        (* findings/2026-10-26-l5-ignore-case-global-options-dropped: the global options in another case are reset *)
        (* (not for class:, whose component sets the options after DefaultComponent does: runs/l5-real) *)
        let b1 := fold_right (fun '(n, d) acc => if other_case n ps && negb (exact_given n ps) && negb (ceqs s (str "class"))
                                                 then set_b n d acc else acc) b
                    [("bridgeErrorHandler", BV (VBool false)); ("lazyStartProducer", BV (VBool false));
                     ("autowiredEnabled", BV (VBool true))] in
        (* findings/2026-10-26-l5-timer-pattern-not-kept: the endpoint does not hold pattern *)
        (* (only in the exact case: the component removes "pattern" by exact name, runs/l5-real) *)
        let b2 := if ceqs s (str "timer") && exact_given "pattern" ps then set_b "pattern" (BV VNull) b1 else b1 in
        (* findings/2026-10-26-l5-seda-size-max-value-ignored: size 2147483647 means "not set" *)
        let b3 := if ceqs s (str "seda") && match bfind "size" b2 with Some (BV (VInt z)) => Z.eqb z 2147483647 | _ => false end
                  then set_b "size" (BV (VInt 1000)) b2 else b2 in
        (EOk b3, h)
    | _ => (r, h)
    end
  | _ => run_pin u
  end.

(** findings/2026-10-26-l5-catalog-missing-path-reported-invalid: with an empty path, every path option of a typed
    kind is also reported invalid with the value "". *)
Definition cat_validate_real (ilp : bool) (u : chars) : cvres * list string :=
  match cat_validate catalog ilp u, lex u with
  | (CvRep un rq inv, h), LLex s [] _ =>
      match find_comp catalog s with
      | Some c =>
          if existsb (fun o => match o_kind o, ikind_of o with KPath, IOther => false | KPath, _ => true | _, _ => false end) (c_opts c)
          then (CvUns "REAL: findings/2026-10-26-l5-catalog-missing-path-reported-invalid.md (which options: not modelled)", [])
          else (CvRep un rq inv, h)
      | None => (CvRep un rq inv, h)
      end
  | r, _ => r
  end.
