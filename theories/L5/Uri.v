(** * L5a: the generic component / endpoint contract. An endpoint URI, read against a component's documented option
    table, gives the endpoint's option values or a documented failure.

    Written from the documentation of apache/camel aa63c0a4cb94 (PIN), not from the code. The per-component tables are
    generated data (Model.v, GenCatalog.v); the rules here are generic and hand-written. Legend (paths under docs/):
      [CMP]  docs/user-manual/modules/ROOT/pages/component.adoc
      [URIS] docs/user-manual/modules/ROOT/pages/uris.adoc
      [END]  docs/user-manual/modules/ROOT/pages/endpoint.adoc
      [WC]   docs/user-manual/modules/ROOT/pages/writing-components.adoc
      [PB]   docs/user-manual/modules/ROOT/pages/property-binding.adoc
      [BT]   docs/user-manual/modules/ROOT/pages/body-types.adoc
      [CRMP] docs/user-manual/modules/ROOT/pages/camel-report-maven-plugin.adoc
      [MCP]  docs/user-manual/modules/ROOT/pages/camel-jbang-mcp.adoc
      [TUIA] docs/user-manual/modules/ROOT/pages/camel-jbang-tui-ai-agents.adoc
      [UG32] docs/user-manual/modules/ROOT/pages/camel-3x-upgrade-guide-3_2.adoc
      [C3MG] docs/user-manual/modules/ROOT/pages/camel-3-migration-guide.adoc
      [CEO]  docs/components/modules/ROOT/partials/component-endpoint-options.adoc
      [CCJ]  catalog/camel-catalog/src/main/java/org/apache/camel/catalog/CamelCatalog.java (javadoc)
      [PVR]  core/camel-api/src/main/java/org/apache/camel/catalog/PropertiesValidationResult.java (javadoc)
      [CJ:x] the component JSON x (Model.v)

    Two readers of a URI are specified. [run_ep]: what [CamelContext.getEndpoint(uri)] gives, the endpoint's option
    values or the exception ([CMP.7], [CMP.16-17]). [cat_validate], [cat_props], [cat_asuri], [cat_name]: what the
    catalog's URI tools give ([CCJ.510-636]: endpointProperties, validateEndpointProperties, asEndpointUri,
    endpointComponentName). Both share the lexical rules (section 2), the path rules (section 3) and the option rules
    (sections 4-5); they differ where the docs say different things about them (marked).

    The readable rules are the relations [creates] and [validates] (section 7, 8), one constructor per documented
    outcome; [run_ep] and [cat_validate] compute them and are proved sound ([run_ep_sound], [cat_validate_sound]).
    The interpreters also return the ids of the rules they used (coverage counters, no semantic role). *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Convert Exchange.
From CamelSpec.L5 Require Import Model.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** 1. Helpers (no documentation content) *)

Definition bind0 {A B : Type} (x : r0 A) (f : A -> r0 B) : r0 B :=
  match x with Ok0 a => f a | Uns0 w => Uns0 w end.
(** The text before the first [c] and the text after it. *)
Fixpoint upto (c : ascii) (s : chars) : option (chars * chars) :=
  match s with
  | [] => None
  | x :: s' => if ceq x c then Some ([], s') else
                 match upto c s' with Some (a, b) => Some (x :: a, b) | None => None end
  end.
Definition has (c : ascii) (s : chars) : bool := existsb (fun x => ceq x c) s.
Definition is_alnum (c : ascii) : bool := is_letter c || is_digit c || ceq c "_"%char.
Definition isnil {A : Type} (l : list A) : bool := match l with [] => true | _ => false end.
Fixpoint memc (s : chars) (l : list chars) : bool := match l with [] => false | x :: l' => ceqs s x || memc s l' end.

(** The documented exceptions of endpoint creation. *)
Definition NSEE : string := "org.apache.camel.NoSuchEndpointException".
Definition RFE : string := "org.apache.camel.ResolveEndpointFailedException".

(** ** 2. Lexical rules: scheme, path, query parameters, values *)

(*! R L5.uri.scheme DOC [CMP.16-17] [CMP.101] *)
(** "The URI scheme (that is, the part before [:]) specifies the name of a component" [CMP.16-17]; "when Camel
    extracts the component name from the parameter, it looks for the first ':'" [CMP.101]. *)
Definition split_scheme (u : chars) : option (chars * chars) := upto ":"%char u.

(*! R L5.uri.double-slash DOC [END.200] [END.109] [TIM.21-22] [TIM.79] *)
(** [scheme://x] is the same endpoint as [scheme:x]: the timer URI format is [timer:name[?options]] [TIM.21-22] and its
    example [timer://foo?fixedRate=true&period=60000] [TIM.79] (also [END.200], [END.109]) names the timer [foo].
    Read from the examples; no page says it in words. *)
Definition strip_slashes (r : chars) : chars := match r with "/"%char :: "/"%char :: r' => r' | _ => r end.

(** A query value as written: [RAW(...)] / [RAW{...}] or plain text. *)
Inductive pval : Type := PRaw (s : chars) | PText (s : chars).

(*! R L5.uri.params DOC [URIS.13-19] [END.184-185] *)
(** "The URI contains endpoint configurations as context-path and query parameters" [URIS.13]; "the [&] is used to
    separate the parameters" [END.184-185]; each parameter is [name=value] [URIS.18-19]. A parameter without [=], an
    empty one ([&&], a trailing [&]), a [?] or [=] inside a plain value: not documented. *)
(*! R L5.uri.raw DOC [END.219-220] [END.222-232] [END.276-277] [END.279] *)
(** "You can define parameter value to be raw using the following syntax [RAW(value)], e.g. the value starts with
    [RAW(] and then ends with the parenthesis [)]" [END.219-220]; its [&] and [?] do not end it (the example
    [password=RAW(se+re?t&23)&binary=true], "the actual password would be as typed" [END.232, END.276-277]). A [)] in
    the value closes it ("The parser will interpret the [)] as closing the RAW function" [END.279]); what the text after
    such a [)] then is, is not documented. [RAW{...}] lets the value contain [)] [END.279]. *)
Definition raw_close (open close : ascii) (v : chars) : option chars :=
  match v with
  | "R"%char :: "A"%char :: "W"%char :: o :: r => if ceq o open then Some r else None
  | _ => None
  end.
Definition plain_value (v : chars) : r0 chars :=
  if has "?"%char v then Uns0 "END: a '?' in a value outside RAW() (encoding not documented)"
  else if has "="%char v then Uns0 "END: a '=' in a value outside RAW() (encoding not documented)"
  else Ok0 v.
Fixpoint split_params (fuel : nat) (q : chars) : r0 (list (chars * pval)) :=
  match fuel with
  | O => Uns0 "fuel"
  | S f =>
    let fin (r : chars) (k : list (chars * pval) -> list (chars * pval)) : r0 (list (chars * pval)) :=
      match r with
      | [] => Ok0 (k [])
      | "&"%char :: r' => bind0 (split_params f r') (fun ps => Ok0 (k ps))
      | _ => Uns0 "END.279: text after the ')' or '}' that closes RAW"
      end in
    match q with
    | [] => Ok0 []
    (*! R L5.uri.empty-param DOC [UG423.1852-1857] *)
    (* "An empty query parameter, such as from [delay=250&&period=500], is now ignored" [UG423.1854-1856] *)
    | "&"%char :: q' => split_params f q'
    | _ =>
      match upto "="%char q with
      | None => Uns0 "URIS: a query parameter without '='"
      | Some (n, rest) =>
        if has "&"%char n then Uns0 "URIS: a query parameter without '='"
        else if isnil n then Uns0 "URIS: an empty parameter name"
        else
          match raw_close "("%char ")"%char rest, raw_close "{"%char "}"%char rest with
          | Some body, _ =>
              match upto ")"%char body with
              | Some (v, r) => fin r (fun ps => (n, PRaw v) :: ps)
              | None => Uns0 "END: RAW( without a closing ')'"
              end
          | None, Some body =>
              match upto "}"%char body with
              | Some (v, r) => fin r (fun ps => (n, PRaw v) :: ps)
              | None => Uns0 "END: RAW{ without a closing '}'"
              end
          | None, None =>
              match upto "&"%char rest with
              | None => bind0 (plain_value rest) (fun v => Ok0 [(n, PText v)])
              | Some (v, r) =>
                  bind0 (plain_value v) (fun v' => bind0 (split_params f r) (fun ps => Ok0 ((n, PText v') :: ps)))
              end
          end
      end
    end
  end.

(*! R L5.uri.decode DOC [END.213-217] *)
(** "the values is by default URI encoded" [END.213-214]: a plain value is percent-decoded. A plus sign "would be
    decimal encoded by default" [END.216-217], which does not say what it decodes to; a [%] not followed by two hex
    digits, and a byte outside printable ASCII, are not documented. *)
Definition hexv (c : ascii) : option nat :=
  let n := code c in
  if is_digit c then Some (n - 48)
  else if Nat.leb 65 n && Nat.leb n 70 then Some (n - 55)
  else if Nat.leb 97 n && Nat.leb n 102 then Some (n - 87) else None.
Fixpoint pdecode (s : chars) : r0 chars :=
  match s with
  | [] => Ok0 []
  | "%"%char :: a :: b :: r =>
      match hexv a, hexv b with
      | Some x, Some y =>
          let n := x * 16 + y in
          if Nat.leb 32 n && Nat.leb n 126 then bind0 (pdecode r) (fun t => Ok0 (ascii_of_nat n :: t))
          else Uns0 "END: a percent-encoded byte outside printable ASCII"
      | _, _ => Uns0 "END: '%' not followed by two hex digits"
      end
  | "%"%char :: _ => Uns0 "END: '%' not followed by two hex digits"
  (*! R L5.uri.plus-space CODE URISupport.parseQuery *)
  (* Docs silent ([END.216-217] "would be decimal encoded"): a '+' decodes to a space, as in form encoding
     (URISupport.parseQuery / URIScanner decode with URLDecoder; runs/l5-first: 50 of 50 accepted string values) *)
  | "+"%char :: r => bind0 (pdecode r) (fun t => Ok0 (" "%char :: t))
  | c :: r => bind0 (pdecode r) (fun t => Ok0 (c :: t))
  end.

(*! R L5.uri.raw-simple DOC [END.283-285] *)
(** [$simple{...}] inside [RAW(...)] is evaluated [END.283-285] (environment variables): not modelled. *)
Definition value_text (pv : pval) : r0 chars :=
  match pv with
  | PRaw s => if occurs (str "$simple{") s then Uns0 "END.283-285: $simple{} inside RAW() (Simple at endpoint creation) not modelled"
              else Ok0 s
  | PText s => pdecode s
  end.

(** The lexical reading of a whole URI. *)
Inductive lexres : Type :=
| LNoColon
| LLex (scheme path : chars) (ps : list (chars * pval))
| LSyntax (why : string)
| LUns (why : string).

(*! R L5.uri.placeholder DOC [END.325-336] *)
(** Property placeholders [{{key}}] in a URI are resolved [END.325-336]; that is L1/Placeholder.v (another owner):
    pending, a URI with [{{] is UNSPECIFIED here. *)
(*! R L5.uri.query-start DOC [URIS.9-14] [END.139] *)
(** The context path is the text before [?], the query parameters follow it [URIS.9-14]. *)
(*! R L5.uri.syntax-errors CODE AbstractCamelContext.doGetEndpoint URISupport.parseQuery *)
(** Docs silent: Camel rejects as invalid syntax a URI with nothing after the [:] ([java.net.URI]: "Expected
    scheme-specific part") and a query that ends with [&] ("Invalid uri syntax: Trailing & marker found",
    URISupport); a [?] with nothing after it is ignored (runs/l5-first: 419 of 419, 51 of 51, 49 of 49). *)
Definition lex (u : chars) : lexres :=
  if occurs (str "{{") u then LUns "END.325-336: property placeholders in URIs: pending L1/Placeholder.v"
  else match split_scheme u with
       | None => LNoColon
       | Some (s, r) =>
           if isnil s then LUns "CMP: an empty scheme"
           else if isnil r then LSyntax "Expected scheme-specific part"
           else
             let r' := strip_slashes r in
             match upto "?"%char r' with
             | None => LLex s r' []
             | Some (p, q) =>
                 if isnil q then LLex s p []
                 else if suffix (str "&") q then LSyntax "Trailing & marker found"
                 else match split_params (S (length q)) q with
                      | Ok0 ps => LLex s p ps
                      | Uns0 w => LUns w
                      end
             end
       end.

(** ** 3. Path parameters, by the component's syntax *)

(** The names and the delimiters of a syntax such as [ftp:host:port/directoryName]: the text after the scheme and its
    [:] (and a leading [//]), cut into runs of letters and digits (the names) and the single characters between them. *)
Fixpoint syn_cut (s : chars) (cur : chars) : list chars * list ascii :=
  match s with
  | [] => ([rev cur], [])
  | c :: s' => if is_alnum c then syn_cut s' (c :: cur)
               else let '(ns, ds) := syn_cut s' [] in (rev cur :: ns, c :: ds)
  end.
Definition syn_tokens (syntax : chars) : list chars * list ascii :=
  match split_scheme syntax with
  | Some (_, r) => match strip_slashes r with [] => ([], []) | r' => syn_cut r' [] end
  | None => ([], [])
  end.

(*! R L5.path.syntax DOC [CEO.28-35] [URIS.13-14] [END.261-272] *)
(** "The {doctitle} endpoint is configured using URI syntax: {syntax} With the following path and query parameters"
    [CEO.28-35]: the path parameters are the names of the syntax, in order, separated by its delimiters. The kafka
    example: in [kafka:cheese?...] "the context-path is [cheese] which is the kafka topic" [URIS.13-14] (syntax
    [kafka:topic]). The last name takes the rest of the path. A shorter path fills the names from the left: the
    "expanded" form of [ftp:joe@myftpserver.com] is [host: joe@myftpserver.com] [END.261-272] (syntax
    [ftp:host:port/directoryName], [host] required). Not documented: a path that skips a delimiter but has a later
    one, an empty part, and a shorter path that gives a value to an optional name ([path_stage]; FIX 2026-10-26: the
    first version filled optional names from the left too, e.g. [jms:temp-queue] as destinationType, notes/l5.md). *)
Fixpoint fill (ns : list chars) (ds : list ascii) (p : chars) : r0 (list (chars * chars)) :=
  match ns with
  | [] => if isnil p then Ok0 [] else Uns0 "CEO: path text for a component whose syntax has no path"
  | [n] => if isnil p then Ok0 [] else Ok0 [(n, p)]
  | n :: ns' =>
      match ds with
      | [] => Uns0 "CEO: syntax with fewer delimiters than names"
      | d :: ds' =>
          match upto d p with
          | Some (a, b) => if isnil a then Uns0 "CEO: an empty path part"
                           else bind0 (fill ns' ds' b) (fun r => Ok0 ((n, a) :: r))
          | None => if existsb (fun d' => has d' p) ds'
                    then Uns0 "CEO: the path skips a delimiter of the syntax"
                    else if isnil p then Ok0 [] else Ok0 [(n, p)]
          end
      end
  end.

Definition find_opt (k : okind) (n : chars) (os : list opt) : option opt :=
  List.find (fun o => ceqs (str (o_name o)) n && match o_kind o, k with KPath, KPath | KParam, KParam => true | _, _ => false end) os.

(** The path values: each name of the syntax must be a path option of the table; a path value with [%] or [+] (the
    docs say how query values are encoded, not path values) is not documented. *)
Fixpoint path_opts (c : comp) (l : list (chars * chars)) : r0 (list (opt * chars)) :=
  match l with
  | [] => Ok0 []
  | (n, v) :: l' =>
      match find_opt KPath n (c_opts c) with
      | None => Uns0 "CEO: a syntax name that is not a path option of the table"
      | Some o => if has "%"%char v || has "+"%char v then Uns0 "CEO: '%' or '+' in a path value (path decoding not documented)"
                  else bind0 (path_opts c l') (fun r => Ok0 ((o, v) :: r))
      end
  end.
(** A shorter path: the doc example fills a required name ([host] of ftp is required [CJ:ftp.json]); which names a
    shorter path fills when one of the filled names is optional is not documented. *)
Definition path_stage (c : comp) (p : chars) : r0 (list (opt * chars)) :=
  let '(ns, ds) := syn_tokens (str (c_syntax c)) in
  bind0 (fill ns ds p) (fun l =>
    bind0 (path_opts c l) (fun pb =>
      if negb (isnil pb) && Nat.ltb (length pb) (length ns) && existsb (fun '(o, _) => negb (o_req o)) pb
      then Uns0 "CEO: a shorter path that gives a value to an optional name (which names it fills is not documented)"
      else Ok0 pb)).

(** ** 4. Option values, by the option's documented type

    [VOk b]: the option gets the value [b]. [VOkNR why]: a valid value whose stored form is not documented (accepted,
    not compared). [VBad why]: documented not to be a value of the option's type. [VUns why]: UNSPECIFIED. *)
Inductive bval : Type := BV (v : val) | BEnum (c : chars) | BPre (key v : chars).
Inductive vres : Type := VOk (b : bval) | VOkNR (why : string) | VBad (why : string) | VUns (why : string).

Definition of_conv (k : conv) : vres :=
  match k with
  | KV v => VOk (BV v)
  | KCannot w => VBad w
  | KUns w => VUns w
  | KNull => VUns "TC: null from text"
  | KDec _ => VUns "TC: BigDecimal for an option"
  end.

(*! R L5.val.integer DOC [CEO.9] [PB.14] L0.TC.to_integral *)
(** Options are set from their text by the type converter ([PB.14] "binding String valued properties", [WC.57-59] the
    setters): an option of type [integer] with javaType [int]/[Integer] or [long]/[Long] gets the conversion of the
    text (L0 Convert.v). Other integer javaTypes ([byte]) are not in L0. *)
Definition val_integer (o : opt) (s : chars) : vres :=
  match o_jt o with
  | JPInt | JInt => of_conv (conv_of (VStr s) TInteger)
  | JPLong | JLong => of_conv (conv_of (VStr s) TLong)
  | _ => VUns "CEO: an integer option whose javaType L0 does not convert to"
  end.

(*! R L5.val.number DOC [CEO.9] [PB.14] L0.TC.to_double *)
Definition val_number (o : opt) (s : chars) : vres :=
  match o_jt o with
  | JPDouble | JDouble => of_conv (conv_of (VStr s) TDouble)
  | _ => VUns "CEO: a number option whose javaType L0 does not convert to (Float)"
  end.

(*! R L5.val.boolean DOC [CEO.9] [PB.14] L0.TC.to_boolean *)
(** [true] / [false] (L0). For the catalog ([cat] true), a word that is neither, in any case, is not a boolean
    value: the catalog check reports "invalid values" [MCP.305-306]; at endpoint creation L0 leaves other texts
    UNSPECIFIED. *)
Definition val_boolean (cat : bool) (o : opt) (s : chars) : vres :=
  match o_jt o with
  | JPBool | JBool =>
      match of_conv (conv_of (VStr s) TBoolean) with
      | VUns w => if cat && wordy s && negb (ceqs (lower s) (str "true") || ceqs (lower s) (str "false"))
                  then VBad "MCP: a word that is not a boolean" else VUns w
      | r => r
      end
  | _ => VUns "CEO: a boolean option of another javaType"
  end.

(*! R L5.val.duration DOC [END.415-566] [CCJ.529-535] [CJ type duration] *)
(** "Some of the Camel components offers options to specify a time period, which must be entered in millisecond as
    unit ... In Camel you can configure this in a more readable syntax": [h], [m], [s] [END.425-431], mixed
    ([1h15m], [2h30s], [3h45m58s] [END.476-478]), and the long forms [hour(s)], [minute(s)], [second(s)]
    [END.528-534]. The options are those of JSON type [duration]. The catalog also takes [5sec] and [4min]
    ([CCJ.532] "such as 5000, 5s, 5sec, 4min, 4m30s, 1h"). Read as: groups of digits and a unit, the units in the
    order hours, minutes, seconds, each once; a plain number is milliseconds. Not documented: other spellings
    ([ms], spaces, fractions, units out of order), a negative number. A word is not a duration. *)
Definition unit_of (cat : bool) (u : chars) : option (nat * Z) :=
  let w := fun s => ceqs u (str s) in
  if w "h" || w "hour" || w "hours" then Some (0%nat, 3600000%Z)
  else if w "m" || w "minute" || w "minutes" || (cat && w "min") then Some (1%nat, 60000%Z)
  else if w "s" || w "second" || w "seconds" || (cat && w "sec") then Some (2%nat, 1000%Z)
  else None.
Fixpoint span (p : ascii -> bool) (s : chars) : chars * chars :=
  match s with [] => ([], []) | c :: s' => if p c then let '(a, b) := span p s' in (c :: a, b) else ([], s) end.
Fixpoint dur_groups (fuel : nat) (cat : bool) (minr : nat) (s : chars) : option Z :=
  match fuel with
  | O => None
  | S f =>
      let '(d, r) := span is_digit s in
      let '(u, r') := span is_letter r in
      if isnil d || isnil u then None else
      match unit_of cat u with
      | Some (k, ms) => if Nat.leb minr k then
                          let z := (digits_val d 0 * ms)%Z in
                          if isnil r' then Some z
                          else option_map (Z.add z) (dur_groups f cat (S k) r')
                        else None
      | None => None
      end
  end.
Definition val_duration (cat : bool) (o : opt) (s : chars) : vres :=
  let ms := match canon_int s with
            | Some z => if Z.ltb z 0 then inr "END: a negative duration" else inl z
            | None => match dur_groups 4 cat 0 s with
                      | Some z => inl z
                      | None => inr (if wordy s then "" else "END: duration text outside the documented syntax")
                      end
            end in
  match ms with
  | inr w => if String.eqb w "" then VBad "END: a word is not a duration" else VUns w
  | inl z =>
      match o_jt o with
      | JPLong | JLong => if in_long z then VOk (BV (VLong z)) else VUns "END: a duration beyond the Long range"
      | JPInt | JInt => if in_int z then VOk (BV (VInt z)) else VUns "END: a duration beyond the Integer range"
      | JDuration => VOkNR "CEO: a java.time.Duration option (val has no Duration)"
      | _ => VUns "CEO: a duration option of another javaType"
      end
  end.

(*! R L5.val.enum DOC [CEO.9] [BT.435-436] [TUIA.239] [MCP.305-306] *)
(** An option of type [enum] takes one of its listed values. "The values of an option compare in any case, and in any
    style of an enum constant, as Camel takes them: [convert-to-json], [convertToJson] and [CONVERT_TO_JSON] are one
    value" [BT.435-436]: compared without case, [-] and [_]. A value matching no listed value is not among the allowed
    ones [TUIA.239]. An enum class option gets the constant; a String option holding an enum value in another style:
    the stored text is not documented. A value matching several constants, and multi-value enums, are not documented. *)
Definition norm (s : chars) : chars := lower (filter (fun c => negb (ceq c "-"%char || ceq c "_"%char)) s).
Definition val_enum (o : opt) (s : chars) : vres :=
  if o_multienum o then VUns "CJ: a multiEnum option (several values) not documented" else
  match filter (fun e => ceqs (norm (str e)) (norm s)) (o_enum o) with
  | [] => VBad "TUIA: not among the allowed values"
  | [e] => match o_jt o with
           | JEnum => VOk (BEnum (str e))
           | JString => if ceqs (str e) s then VOk (BV (VStr s))
                        else VOkNR "BT.435: an enum value of a String option in another style (stored text not documented)"
           | _ => VOkNR "CEO: an enum value of an option whose javaType is not an enum class"
           end
  | _ => VUns "BT.435: the value matches several enum constants"
  end.

(*! R L5.val.string DOC [CEO.9] [PB.14] *)
(** A [string] option of javaType String gets the text. A [string] option of another javaType ([java.util.Date]),
    and [object] / [array] options from text, are not documented at endpoint creation; the catalog does not check the
    text of a [string] option (any text is a string). *)
Definition val_text (cat : bool) (o : opt) (s : chars) : vres :=
  match o_ty o, o_jt o with
  | TyString, JString => VOk (BV (VStr s))
  | TyString, _ => if cat then VOkNR "CEO: a string option of another javaType" else VUns "CEO: text for a string option of a non-String javaType"
  | _, _ => VUns "CEO: text for an option of type object or array"
  end.

(*! R L5.val.reference DOC [END.52-58] [END.99-128] [PB.20-24] *)
(** A value starting with [#] refers to the registry ([#bean:id], [#type:], [#class:], [#property:], [#autowired],
    [#valueAs(type):]) [END.52-58, END.99-128, PB.20-24]: the registry is not modelled. An empty value is not
    documented. *)
Definition bind_val (cat : bool) (o : opt) (s : chars) : vres :=
  match s with
  | [] => VUns "URIS: an empty value"
  | "#"%char :: _ => VUns "END.52-58: a registry reference (#bean:, #type:, #class:, ...) not modelled"
  | _ =>
      match o_ty o with
      | TyBoolean => val_boolean cat o s
      | TyInteger => val_integer o s
      | TyNumber => val_number o s
      | TyDuration => val_duration cat o s
      | TyEnum => val_enum o s
      | _ => val_text cat o s
      end
  end.

(** ** 5. Option names *)

Inductive nres : Type :=
| NOpt (o : opt) (exact : bool)
| NPre (o : opt) (key : chars)
| NLenient
| NUnknown
| NUns (why : string).

(*! R L5.opt.name DOC [CEO.53-67] [URIS.16-19] *)
(** A query parameter names a query option of the table [CEO.53-67]. *)
(*! R L5.opt.name-ignore-case DOC [PB.3-4] [PB.41] *)
(** Property binding, which configures endpoints [PB.3-4], has "ignore case - Whether to ignore case for property
    keys (will ignore by default)" [PB.41]: at endpoint creation a name in another case names the option. For the
    catalog this is not documented. *)
(*! R L5.opt.prefix DOC [MCP.314-315] [CJ multiValue prefix] *)
(** "the multi-value options that take any parameter with a prefix ([mail.*] of smtp)" [MCP.314-315]: a parameter
    whose name starts with the [prefix] of a multiValue option sets the entry (name without the prefix) of that option. *)
(*! R L5.opt.lenient DOC [CRMP.157] [CCJ.520-523] [CJ lenientProperties] *)
(** A component with lenient properties takes "properties that are not part of the component but in the uri"
    [CRMP.157] ("eg custom options" [CCJ.520]). *)
(*! R L5.opt.unknown DOC [WC.61-64] [CRMP.113-129] *)
(** Otherwise the name is unknown: "Camel will validate that all options are used. If not Camel will throw a
    [ResolveEndpointFailedException] stating which options are unknown" [WC.62-64]. Not documented: a path option
    given as a query parameter, a name with an [optionalPrefix] of the JSON (the 3.0 migration guide says the
    [consumer.] prefix is "no longer supported" [C3MG.206]), a name in another case that fits two options. *)
Definition resolve_name (cat : bool) (c : comp) (n : chars) : nres :=
  let qs := filter (fun o => match o_kind o with KParam => true | _ => false end) (c_opts c) in
  match List.find (fun o => ceqs (str (o_name o)) n) qs with
  | Some o => NOpt o true
  | None =>
    if existsb (fun o => ieq (str (o_name o)) n) (c_opts c) then
      match filter (fun o => ieq (str (o_name o)) n) qs with
      | [o] => if cat then NUns "PB.41: whether the catalog ignores the case of a name is not documented"
               else NOpt o false
      | [] => NUns "CEO: a path option given as a query parameter"
      | _ => NUns "PB.41: a name in another case that fits several options"
      end
    else
    match filter (fun o => o_multi o && match o_prefix o with
                                         | Some p => prefix (str p) n && Nat.ltb (length (str p)) (length n)
                                         | None => false end) qs with
    | [o] => NPre o (match o_prefix o with Some p => skipn (length (str p)) n | None => n end)
    | _ :: _ :: _ => NUns "MCP: a name that fits the prefix of several options"
    | [] =>
      if existsb (fun o => match o_oprefix o with
                           | Some p => prefix (str p) n && ieq (str (o_name o)) (skipn (length (str p)) n)
                           | None => false end) qs
      then NUns "C3MG.206: a name with the optionalPrefix of the JSON (not documented)"
      else if c_lenient c then NLenient else NUnknown
    end
  end.

(** The reading of one query parameter. *)
Inductive pres : Type :=
| PBind (o : opt) (exact : bool) (text : chars) (v : vres)
| PPre (o : opt) (key v : chars)
| PLen (n : chars)
| PUnk (n : chars)
| PUns (why : string).

(** For the catalog the decoding of values is not documented: only plain values without [%] and [+] are read. *)
Definition param_text (cat : bool) (pv : pval) : r0 chars :=
  if cat then match pv with
              | PText s => if has "%"%char s || has "+"%char s then Uns0 "CCJ: the catalog's decoding of values is not documented" else Ok0 s
              | PRaw _ => Uns0 "CCJ: RAW() values in the catalog are not documented"
              end
  else value_text pv.

(*! R L5.opt.hash DOC-BUG [UG423.1707-1708] DefaultComponent.createEndpoint 36f06e1370b7 *)
(** "A query parameter named [hash] in an endpoint uri ... is now kept as a regular parameter" [UG423.1707-1708],
    written by cf526fbe7625 (CAMEL-25108, 2026-09-28) and undone the next day by 36f06e1370b7 ("Always remove the hash
    parameter when creating an endpoint", test [testHashParameterIsRemoved]), which left the upgrade guide as it was:
    the parameter is removed, so it is never unknown (notes/l5.md). For the catalog: not documented. *)
Definition param_res (cat : bool) (c : comp) (np : chars * pval) : pres :=
  let '(n, pv) := np in
  if has "%"%char n || has "+"%char n then PUns "END: an encoded option name (not documented)" else
  if ceqs n (str "hash") then (if cat then PUns "UG423.1707: the hash parameter in the catalog (not documented)" else PLen n) else
  match resolve_name cat c n with
  | NOpt o ex => match param_text cat pv with Ok0 s => PBind o ex s (bind_val cat o s) | Uns0 w => PUns w end
  | NPre o k => match param_text cat pv with Ok0 s => if isnil s then PUns "URIS: an empty value" else PPre o k s | Uns0 w => PUns w end
  | NLenient => PLen n
  | NUnknown => PUnk n
  | NUns w => PUns w
  end.

(*! R L5.opt.duplicate DOC [URIS.16-19] *)
(** A URI that sets an option twice: not documented. *)
Fixpoint dup_names (seen : list chars) (rs : list pres) : bool :=
  match rs with
  | [] => false
  | PBind o _ _ _ :: r => let k := str (o_name o) in memc k seen || dup_names (k :: seen) r
  | PPre o key _ :: r => let k := str (o_name o) ++ "."%char :: key in memc k seen || dup_names (k :: seen) r
  | _ :: r => dup_names seen r
  end.

(** ** 6. Defaults and required options *)

(*! R L5.opt.default DOC [CEO.7-9] [CEO.17-22] *)
(** An option the URI does not set has the value of the table's Default column [CEO.8-9]. Without a default its value
    is not documented (not compared). *)
Definition given (pb : list (opt * chars)) (rs : list pres) (o : opt) : bool :=
  existsb (fun '(p, _) => String.eqb (o_name p) (o_name o)) pb ||
  existsb (fun r => match r with PBind p _ _ _ | PPre p _ _ => String.eqb (o_name p) (o_name o) | _ => false end) rs.
Fixpoint defaults (cat : bool) (pb : list (opt * chars)) (rs : list pres) (os : list opt) : list (chars * bval) :=
  match os with
  | [] => []
  | o :: os' =>
      let r := defaults cat pb rs os' in
      if given pb rs o then r else
      match o_def o, o_prefix o with
      | Some d, None => match bind_val cat o (str d) with VOk b => (str (o_name o), b) :: r | _ => r end
      | _, _ => r
      end
  end.

(*! R L5.opt.required DOC [CEO.13-67] [MCP.305-306] [PVR.150] *)
(** The required options (path or query) that the URI does not set. The catalog reports them ("missing path parts"
    [MCP.306], "a missing required option error" [PVR.150]); what endpoint creation does is not documented. *)
Definition missing (pb : list (opt * chars)) (rs : list pres) (os : list opt) : list opt :=
  filter (fun o => o_req o && negb (given pb rs o)) os.

(** ** 7. Endpoint creation: [CamelContext.getEndpoint(uri)] *)

(** [EFailAny why]: endpoint creation fails with an exception whose class is not documented (only used by the L5b
    constraints of Catalog.v). *)
Inductive eres : Type := EOk (b : list (chars * bval)) | EFail (cls : string) | EFailAny (why : string) | EUns (why : string).

(** The available components (those on the classpath) and their tables. *)
Definition find_comp (cat : list comp) (s : chars) : option comp := List.find (fun c => ceqs (str (c_scheme c)) s) cat.
Definition avail_comp (avail : list string) (cat : list comp) (s : chars) : option comp :=
  if existsb (fun a => ceqs (str a) s) avail then find_comp cat s else None.

Definition is_unk (r : pres) : bool := match r with PUnk _ => true | _ => false end.
(*! R L5.ep.bad-value CODE AbstractCamelContext.doGetEndpoint PropertyBindingSupport *)
(** Docs silent: a value that is not a value of a typed option (javaType a number, boolean, duration or Java enum)
    fails endpoint creation with [ResolveEndpointFailedException] (the conversion error is wrapped by
    AbstractCamelContext.doGetEndpoint; runs/l5-first: all 110 such cases). *)
Definition is_bad (r : pres) : bool :=
  match r with
  | PBind o _ _ (VBad _) => match o_jt o with JString | JOther => false | _ => true end
  | _ => false
  end.
(** A parameter reading that endpoint creation can complete. *)
Definition run_fine (r : pres) : bool :=
  match r with
  | PBind _ _ _ (VOk _ | VOkNR _) | PPre _ _ _ | PLen _ | PUnk _ => true
  | _ => is_bad r
  end.
Definition param_binds (rs : list pres) : list (chars * bval) :=
  flat_map (fun r => match r with
                     | PBind o _ _ (VOk b) => [(str (o_name o), b)]
                     | PPre o k v => [(str (o_name o), BPre k v)]
                     | _ => [] end) rs.
Definition path_binds (pb : list (opt * chars)) : r0 (list (chars * bval)) :=
  fold_right (fun '(o, v) acc => bind0 acc (fun l =>
    match bind_val false o v with
    | VOk b => Ok0 ((str (o_name o), b) :: l)
    | VOkNR _ => Ok0 l
    | VBad w | VUns w => Uns0 ("path value: " ++ w)%string
    end)) (Ok0 []) pb.

Section Endpoint.
Variable avail : list string.
Variable cat : list comp.

(** The component a URI without [:] names: the text before [?], or the whole URI. *)
Definition nocolon_scheme (u : chars) : chars := match upto "?"%char u with Some (a, _) => a | None => u end.

Inductive creates : chars -> eres -> Prop :=
(*! R L5.ep.no-colon DOC-BUG [UG32.444-449] AbstractCamelContext.doGetEndpoint *)
(** "Endpoint URIs without context path ... (eg [log]) ... Now this is not allowed and Camel will throw an
    [NoSuchEndpointException]" [UG32.444-449] (the 3.2 upgrade guide). DOC-BUG (2026-10-26, notes/l5.md): Camel at the
    pin deliberately takes the whole URI (the text before [?]) as the component name, "the uri may not contain a
    scheme such as a dynamic kamelet so we need to find the component name via the first text before : or ? mark"
    (AbstractCamelContext.doGetEndpoint, line 846-847): [direct] gives a direct endpoint, [log] fails for its missing
    path. Rule now: no component of that name gives [NoSuchEndpointException] (as [L5.ep.no-component]); a component
    of that name gets an empty path, which leaves its required path option missing (UNSPECIFIED, [L5.opt.required]). *)
| CrNoColon : forall u, lex u = LNoColon -> avail_comp avail cat (nocolon_scheme u) = None -> creates u (EFail NSEE)
(*! R L5.ep.no-component DOC [CMP.16-17] [MCP.236] [UG32.538-539] *)
(** A scheme with no component: [NoSuchEndpointException: No endpoint could be found for: kafka:myTopic] (the
    component's jar is missing) [MCP.236]; [getEndpoint] "throws [NoSuchEndpointException] directly" [UG32.538-539]. *)
| CrNoComp : forall u s p ps, lex u = LLex s p ps -> avail_comp avail cat s = None -> creates u (EFail NSEE)
(*! R L5.ep.syntax CODE AbstractCamelContext.doGetEndpoint *)
| CrSyntax : forall u w, lex u = LSyntax w -> creates u (EFail RFE)
| CrBad : forall u s p ps c pb pv,
    lex u = LLex s p ps -> avail_comp avail cat s = Some c ->
    forallb run_fine (map (param_res false c) ps) = true -> dup_names [] (map (param_res false c) ps) = false ->
    path_stage c p = Ok0 pb -> path_binds pb = Ok0 pv -> missing pb (map (param_res false c) ps) (c_opts c) = [] ->
    existsb is_bad (map (param_res false c) ps) = true ->
    creates u (EFail RFE)
(*! R L5.ep.unknown DOC [WC.61-64] *)
| CrUnknown : forall u s p ps c pb pv,
    lex u = LLex s p ps -> avail_comp avail cat s = Some c ->
    forallb run_fine (map (param_res false c) ps) = true -> dup_names [] (map (param_res false c) ps) = false ->
    path_stage c p = Ok0 pb -> path_binds pb = Ok0 pv -> missing pb (map (param_res false c) ps) (c_opts c) = [] ->
    existsb is_bad (map (param_res false c) ps) = false -> existsb is_unk (map (param_res false c) ps) = true ->
    creates u (EFail RFE)
(*! R L5.ep.ok DOC [CMP.7] [WC.57-59] [CEO.28-35] *)
(** "Camel will automatically set the properties when the endpoint is created" [WC.57-59]: the endpoint has the path
    values, the query values and, for the options not set, the defaults. *)
| CrOk : forall u s p ps c pb pv,
    lex u = LLex s p ps -> avail_comp avail cat s = Some c ->
    forallb run_fine (map (param_res false c) ps) = true -> dup_names [] (map (param_res false c) ps) = false ->
    path_stage c p = Ok0 pb -> path_binds pb = Ok0 pv -> missing pb (map (param_res false c) ps) (c_opts c) = [] ->
    existsb is_bad (map (param_res false c) ps) = false -> existsb is_unk (map (param_res false c) ps) = false ->
    creates u (EOk (pv ++ param_binds (map (param_res false c) ps) ++
                    defaults false pb (map (param_res false c) ps) (c_opts c))).

(** The rule ids a parameter reading used (coverage counters only). *)
Definition val_rule (o : opt) : string :=
  match o_ty o with
  | TyBoolean => "L5.val.boolean" | TyInteger => "L5.val.integer" | TyNumber => "L5.val.number"
  | TyDuration => "L5.val.duration" | TyEnum => "L5.val.enum" | _ => "L5.val.string"
  end.
Definition res_hits (r : pres) : list string :=
  match r with
  | PBind o ex _ _ => [if ex then "L5.opt.name" else "L5.opt.name-ignore-case"; val_rule o]
  | PPre _ _ _ => ["L5.opt.prefix"]
  | PLen _ => ["L5.opt.lenient"]
  | PUnk _ => ["L5.opt.unknown"]
  | PUns _ => []
  end.
Definition pval_hits (ps : list (chars * pval)) : list string :=
  "L5.uri.scheme" :: (if isnil ps then [] else ["L5.uri.query-start"; "L5.uri.params"]) ++
  flat_map (fun '(n, v) => match v with
                           | PRaw _ => ["L5.uri.raw"]
                           | PText t => "L5.uri.decode" :: (if has "+"%char t then ["L5.uri.plus-space"] else [])
                           end ++ (if ceqs n (str "hash") then ["L5.opt.hash"] else [])) ps.
(** Rule ids read off the URI text (coverage counters only). *)
Definition uri_hits (u : chars) : list string :=
  (if occurs (str "://") u then ["L5.uri.double-slash"] else []) ++
  (if occurs (str "&&") u || occurs (str "?&") u then ["L5.uri.empty-param"] else []).
Definition first_uns (rs : list pres) : option string :=
  match List.find (fun r => negb (run_fine r)) rs with
  | Some (PUns w) => Some w
  | Some (PBind o _ _ (VBad w)) => Some ("WC/PB: endpoint creation with a value that is not a value of the option's type (" ++ o_name o ++ "): outcome not documented")%string
  | Some (PBind _ _ _ (VUns w)) => Some w
  | _ => None
  end.

Definition run_ep (u : chars) : eres * list string :=
  match lex u with
  | LNoColon =>
      match avail_comp avail cat (nocolon_scheme u) with
      | None => (EFail NSEE, ["L5.ep.no-colon"])
      | Some _ => (EUns "UG32 (DOC-BUG): a URI without ':' naming a component (empty path, required path missing)", [])
      end
  | LSyntax _ => (EFail RFE, ["L5.ep.syntax"; "L5.uri.syntax-errors"])
  | LUns w => (EUns w, [])
  | LLex s p ps =>
    match avail_comp avail cat s with
    | None => (EFail NSEE, ["L5.uri.scheme"; "L5.ep.no-component"])
    | Some c =>
      let rs := map (param_res false c) ps in
      if negb (forallb run_fine rs) then
        (EUns (match first_uns rs with Some w => w | None => "L5: a parameter reading" end), [])
      else if dup_names [] rs then (EUns "URIS: an option set twice (not documented)", [])
      else match path_stage c p with
           | Uns0 w => (EUns w, [])
           | Ok0 pb =>
             match path_binds pb with
             | Uns0 w => (EUns w, [])
             | Ok0 pv =>
               match missing pb rs (c_opts c) with
               | _ :: _ => (EUns "CEO: endpoint creation with a required option missing (not documented)", [])
               | [] =>
                 let h := pval_hits ps ++ uri_hits u ++ ["L5.path.syntax"] ++ flat_map res_hits rs in
                 if existsb is_bad rs then (EFail RFE, h ++ ["L5.ep.bad-value"])
                 else if existsb is_unk rs then (EFail RFE, h ++ ["L5.ep.unknown"])
                 else (EOk (pv ++ param_binds rs ++ defaults false pb rs (c_opts c)),
                       h ++ ["L5.opt.default"; "L5.ep.ok"])
               end
             end
           end
    end
  end.

Definition not_uns (r : eres) : bool := match r with EUns _ => false | _ => true end.

Theorem run_ep_sound : forall u r h, run_ep u = (r, h) -> not_uns r = true -> creates u r.
Proof.
  intros u r h H N. unfold run_ep in H.
  destruct (lex u) as [|s p ps|w|w] eqn:L.
  - destruct (avail_comp avail cat (nocolon_scheme u)) eqn:A; inversion H; subst; [discriminate|]. now apply CrNoColon.
  - destruct (avail_comp avail cat s) as [c|] eqn:A.
    + destruct (forallb run_fine (map (param_res false c) ps)) eqn:F; simpl in H.
      * destruct (dup_names [] (map (param_res false c) ps)) eqn:D; [inversion H; subst; discriminate|].
        destruct (path_stage c p) as [pb|w] eqn:P; [|inversion H; subst; discriminate].
        destruct (path_binds pb) as [pv|w] eqn:PV; [|inversion H; subst; discriminate].
        destruct (missing pb (map (param_res false c) ps) (c_opts c)) as [|m ms] eqn:M;
          [|inversion H; subst; discriminate].
        destruct (existsb is_bad (map (param_res false c) ps)) eqn:BD.
        -- inversion H; subst. eapply CrBad; eauto.
        -- destruct (existsb is_unk (map (param_res false c) ps)) eqn:U; inversion H; subst.
           ++ eapply CrUnknown; eauto.
           ++ eapply CrOk; eauto.
      * inversion H; subst; discriminate.
    + inversion H; subst. eapply CrNoComp; eauto.
  - inversion H; subst. eapply CrSyntax; eauto.
  - inversion H; subst; discriminate.
Qed.

End Endpoint.

(** ** 8. The catalog's URI tools *)

(** The kinds of invalid values the catalog reports [PVR.174-260]. *)
Inductive ikind : Type := IEnum | IBool | IInt | INum | IDur | IOther.
Definition ikind_of (o : opt) : ikind :=
  match o_ty o with
  | TyEnum => IEnum | TyBoolean => IBool | TyInteger => IInt | TyNumber => INum | TyDuration => IDur | _ => IOther
  end.

(** [CvRep unknown required invalid]: the unknown option names, the missing required options, and the invalid values
    (kind, option, value text), each compared as a set. *)
Inductive cvres : Type :=
| CvUnknownComp
| CvRep (unknown required : list chars) (invalid : list (ikind * chars * chars))
| CvSyntax
| CvUns (why : string).

Definition cat_fine (r : pres) : bool :=
  match r with
  | PBind _ _ _ (VOk _ | VOkNR _ | VBad _) | PPre _ _ _ | PLen _ | PUnk _ => true
  | _ => false
  end.
(*! R L5.cat.stub CODE AbstractCamelCatalog.validateEndpointProperties *)
(** Docs silent: the catalog never reports an unknown option of the [stub] component, also with
    ignoreLenientProperties ("only add as error if the component is not lenient properties, or not stub component",
    AbstractCamelCatalog.validateEndpointProperties line 275-278, at the pin; runs/l5-first). *)
Definition cat_unknown (ilp : bool) (c : comp) (rs : list pres) : list chars :=
  if String.eqb (c_scheme c) "stub" then [] else
  flat_map (fun r => match r with PUnk n => [n] | PLen n => if ilp then [n] else [] | _ => [] end) rs.
Definition cat_invalid (pb : list (opt * chars)) (rs : list pres) : list (ikind * chars * chars) :=
  flat_map (fun '(o, v) => match bind_val true o v with VBad _ => [(ikind_of o, str (o_name o), v)] | _ => [] end) pb ++
  flat_map (fun r => match r with PBind o _ s (VBad _) => [(ikind_of o, str (o_name o), s)] | _ => [] end) rs.
Definition path_fine (pb : list (opt * chars)) : bool :=
  forallb (fun '(o, v) => match bind_val true o v with VUns _ => false | _ => true end) pb.
(** A required option with a default that is not set: whether that is "missing" is not documented. *)
Definition req_default (ms : list opt) : bool := existsb (fun o => match o_def o with Some _ => true | None => false end) ms.

Section Catalog.
Variable cat : list comp.

(*! R L5.cat.required-component-options CODE AbstractCamelCatalog.validateEndpointProperties *)
(** Docs silent: the catalog also reports the required component options without a default (the table of
    [componentProperties], set on the component, not in the URI [CCO.10-21]) that the URI does not set (an endpoint
    option of the same name in the URI counts) as missing: the loop "now check if all
    required values are there" of AbstractCamelCatalog.validateEndpointProperties runs over the endpoint and the
    component rows (at the pin; runs/l5-first). A possible false report for a component configured elsewhere
    (notes/l5.md). *)
Definition req_names (c : comp) (pb : list (opt * chars)) (rs : list pres) : list chars :=
  map (fun o => str (o_name o)) (missing pb rs (c_opts c)) ++
  filter (fun n => negb (existsb (fun '(o, _) => ceqs (str (o_name o)) n) pb ||
                         existsb (fun r => match r with PBind o _ _ _ => ceqs (str (o_name o)) n | _ => false end) rs))
         (map str (c_reqc c)).

(** [validateEndpointProperties(uri, ignoreLenientProperties)] [CCJ.545-557]. *)
Inductive validates (ilp : bool) : chars -> cvres -> Prop :=
(*! R L5.cat.unknown-component DOC [PVR.125] [CRMP.94] [CRMP.155] *)
| VaUnknownComp : forall u s p ps, lex u = LLex s p ps -> find_comp cat s = None -> validates ilp u CvUnknownComp
(*! R L5.cat.syntax CODE AbstractCamelCatalog.validateEndpointProperties *)
(** Docs silent ([PVR.113] "Adds a syntax error"): the URIs that endpoint creation rejects as invalid syntax. *)
| VaSyntax : forall u w, lex u = LSyntax w -> validates ilp u CvSyntax
(*! R L5.cat.validate DOC [CCJ.538-557] [MCP.305-306] [TUIA.238-240] [PVR.131] [PVR.150] [PVR.174-260] [CRMP.113-129] *)
(** "it checks a URI against the catalog: unknown options with the closest real names, invalid values, missing path
    parts" [MCP.305-306]; "values that are not among the allowed ones" [TUIA.239]; "ignoreLenientProperties ...
    When this is true, then the uri validation is stricter but would fail on properties that are not part of the
    component" [CCJ.548-551]. The doc example: [timer:foo?perid=5000] gives [perid  Unknown option] [CRMP.113-129]. *)
| VaRep : forall u s p ps c pb,
    lex u = LLex s p ps -> find_comp cat s = Some c -> c_api c = false ->
    forallb cat_fine (map (param_res true c) ps) = true -> dup_names [] (map (param_res true c) ps) = false ->
    path_stage c p = Ok0 pb -> path_fine pb = true ->
    req_default (missing pb (map (param_res true c) ps) (c_opts c)) = false ->
    validates ilp u (CvRep (cat_unknown ilp c (map (param_res true c) ps))
                           (req_names c pb (map (param_res true c) ps))
                           (cat_invalid pb (map (param_res true c) ps))).

Definition cat_validate (ilp : bool) (u : chars) : cvres * list string :=
  match lex u with
  | LNoColon => (CvUns "CCJ: a URI without ':' in the catalog (not documented)", [])
  | LSyntax _ => (CvSyntax, ["L5.cat.syntax"; "L5.uri.syntax-errors"])
  | LUns w => (CvUns w, [])
  | LLex s p ps =>
    match find_comp cat s with
    | None => (CvUnknownComp, ["L5.uri.scheme"; "L5.cat.unknown-component"])
    | Some c =>
      if c_api c then (CvUns "CEO.69-150: API components (apiName/methodName from the apis section) are not modelled", []) else
      let rs := map (param_res true c) ps in
      if negb (forallb cat_fine rs) then
        (CvUns (match List.find (fun r => negb (cat_fine r)) rs with
                | Some (PUns w) | Some (PBind _ _ _ (VUns w)) => w | _ => "L5: a parameter reading" end), [])
      else if dup_names [] rs then (CvUns "URIS: an option set twice (not documented)", [])
      else match path_stage c p with
           | Uns0 w => (CvUns w, [])
           | Ok0 pb =>
             if negb (path_fine pb) then (CvUns "CEO: a path value the catalog check does not document", [])
             else if req_default (missing pb rs (c_opts c)) then
               (CvUns "CEO: a required option with a default that is not set (missing or not: not documented)", [])
             else (CvRep (cat_unknown ilp c rs) (req_names c pb rs)
                         (cat_invalid pb rs),
                   pval_hits ps ++ uri_hits u ++ ["L5.path.syntax"; "L5.opt.required"; "L5.cat.validate"] ++
                   (if isnil (c_reqc c) then [] else ["L5.cat.required-component-options"]) ++
                   (if String.eqb (c_scheme c) "stub" then ["L5.cat.stub"] else []) ++ flat_map res_hits rs)
           end
    end
  end.

Definition cv_not_uns (r : cvres) : bool := match r with CvUns _ => false | _ => true end.

Theorem cat_validate_sound : forall ilp u r h, cat_validate ilp u = (r, h) -> cv_not_uns r = true -> validates ilp u r.
Proof.
  intros ilp u r h H N. unfold cat_validate in H.
  destruct (lex u) as [|s p ps|w|w] eqn:L;
    [inversion H; subst; discriminate| |inversion H; subst; eapply VaSyntax; eauto|inversion H; subst; discriminate].
  destruct (find_comp cat s) as [c|] eqn:F.
  - destruct (c_api c) eqn:API; [inversion H; subst; discriminate|].
    destruct (forallb cat_fine (map (param_res true c) ps)) eqn:FI; simpl in H; [|inversion H; subst; discriminate].
    destruct (dup_names [] (map (param_res true c) ps)) eqn:D; [inversion H; subst; discriminate|].
    destruct (path_stage c p) as [pb|w] eqn:P; [|inversion H; subst; discriminate].
    destruct (path_fine pb) eqn:PF; simpl in H; [|inversion H; subst; discriminate].
    destruct (req_default (missing pb (map (param_res true c) ps) (c_opts c))) eqn:RD;
      [inversion H; subst; discriminate|].
    inversion H; subst. eapply VaRep; eauto.
  - inversion H; subst. eapply VaUnknownComp; eauto.
Qed.

(*! R L5.cat.props DOC [CCJ.510-517] [END.86-90] [END.261-272] [URIS.13-19] *)
(** [endpointProperties(uri)]: "Parses the endpoint uri and constructs a key/value properties of each endpoint option"
    [CCJ.510-517]. The key/value form is the one of the YAML [parameters] [END.86-90, END.261-272]: path options by
    the syntax, query options by name, values as text (a [#bean:] reference stays text [END.90]). Entries for options
    the URI does not set (defaults) are not documented: only the entries of the URI are compared. Not documented:
    lenient and unknown parameters, prefix parameters, names in another case, encoded and RAW values. *)
Inductive cpres : Type := CpProps (kv : list (chars * chars)) | CpUns (why : string).
Definition cat_props (u : chars) : cpres * list string :=
  match lex u with
  | LNoColon => (CpUns "CCJ: a URI without ':'", [])
  | LSyntax w => (CpUns "CCJ: endpointProperties of a URI with invalid syntax", [])
  | LUns w => (CpUns w, [])
  | LLex s p ps =>
    match find_comp cat s with
    | None => (CpUns "CCJ: endpointProperties of an unknown component (not documented)", [])
    | Some c =>
      let rs := map (param_res true c) ps in
      let kv := flat_map (fun r => match r with PBind o true t _ => [(str (o_name o), t)] | _ => [] end) rs in
      if negb (forallb (fun r => match r with PBind _ true t _ => negb (isnil t) | _ => false end) rs)
      then (CpUns "CCJ: endpointProperties with a parameter that is not a plain option=value", [])
      else if dup_names [] rs then (CpUns "URIS: an option set twice (not documented)", [])
      else match path_stage c p with
           | Uns0 w => (CpUns w, [])
           | Ok0 pb => (CpProps (map (fun '(o, v) => (str (o_name o), v)) pb ++ kv),
                        pval_hits ps ++ ["L5.path.syntax"; "L5.cat.props"])
           end
    end
  end.

(*! R L5.cat.asuri DOC [CCJ.624-636] [CEO.28-35] *)
(** [asEndpointUri(scheme, properties, false)]: "Creates an endpoint uri in Java style from the information from the
    properties. The options are in the order of the properties when the map has one (such as a LinkedHashMap)"
    [CCJ.624-629]: the path options fill the syntax [CEO.28-35], the query options follow [?] joined by [&], in the
    order given. Not documented: a missing path option, a value equal to its default (kept or dropped), and values
    with characters other than letters, digits, [.], [-], [_]. *)
Inductive cares : Type := CaUri (u : chars) | CaUns (why : string).
Definition plain_tok (v : chars) : bool :=
  negb (isnil v) && forallb (fun c => is_alnum c || ceq c "."%char || ceq c "-"%char) v.
Fixpoint subst_syn (s : chars) (cur : chars) (pv : list (chars * chars)) : r0 chars :=
  let flush := fun (cur : chars) => if isnil cur then Ok0 [] else
                 match List.find (fun '(n, _) => ceqs n (rev cur)) pv with
                 | Some (_, v) => Ok0 v | None => Uns0 "CCJ: asEndpointUri without a path option" end in
  match s with
  | [] => flush cur
  | c :: s' => if is_alnum c then subst_syn s' (c :: cur) pv
               else bind0 (flush cur) (fun a => bind0 (subst_syn s' [] pv) (fun b => Ok0 (a ++ c :: b)))
  end.
(*! R L5.cat.asuri.secret-raw CODE AbstractCamelCatalog.wrapRAW *)
(** Docs silent: the value of a [secret] option (JSON) is written as [RAW(value)] ([RAW{value}] when it has a [)] and
    no [}]), unless it starts with [#], [RAW(] or [RAW{]: AbstractCamelCatalog.wrapRAW, "wrap secret values with RAW
    to avoid breaking URI encoding in case of encoded values" (at the pin; the local history starts after it). Seen
    in runs/l5-first: 5 of 5 asEndpointUri cases with a secret option. *)
Definition raw_secret (o : opt) (v : chars) : chars :=
  if o_secret o && negb (prefix (str "#") v || prefix (str "RAW(") v || prefix (str "RAW{") v) then
    (if has ")"%char v && negb (has "}"%char v) then str "RAW{" ++ v ++ str "}" else str "RAW(" ++ v ++ str ")")
  else v.
Definition cat_asuri (s : chars) (props : list (chars * chars)) : cares * list string :=
  match find_comp cat s with
  | None => (CaUns "CCJ: asEndpointUri of an unknown component", [])
  | Some c =>
    let os := map (fun '(n, v) => (List.find (fun o => ceqs (str (o_name o)) n) (c_opts c), n, v)) props in
    if negb (forallb (fun '(o, _, v) => match o with
                                        | Some o => plain_tok v && match o_def o with Some d => negb (ceqs (str d) v) | None => true end
                                        | None => false end) os)
    then (CaUns "CCJ: asEndpointUri with a value that is not a plain token, equals its default, or is not an option", [])
    else
      let pv := flat_map (fun '(o, n, v) => match o with Some o => match o_kind o with KPath => [(n, v)] | _ => [] end | None => [] end) os in
      let qv := flat_map (fun '(o, n, v) => match o with
                                            | Some o => match o_kind o with KParam => [(n, raw_secret o v)] | _ => [] end
                                            | None => [] end) os in
      match split_scheme (str (c_syntax c)) with
      | None => (CaUns "CJ: a syntax without ':'", [])
      | Some (_, rest) =>
        match subst_syn rest [] pv with
        | Uns0 w => (CaUns w, [])
        | Ok0 path =>
          (CaUri (s ++ ":"%char :: path ++
                  (if isnil qv then [] else "?"%char :: concat_with ["&"%char] (map (fun '(n, v) => n ++ "="%char :: v) qv))),
           ["L5.path.syntax"; "L5.cat.asuri"] ++
             (if existsb (fun '(o, _, _) => match o with Some o => o_secret o | None => false end) os
              then ["L5.cat.asuri.secret-raw"] else []))
        end
      end
  end.

End Catalog.

(*! R L5.cat.name DOC [CCJ.616-622] [CMP.16-17] [CMP.101] *)
(** [endpointComponentName(uri)]: "the component name (aka scheme), or null if not possible to determine"
    [CCJ.616-622]: the text before the first [:]. A URI without [:]: not documented. *)
Definition cat_name (u : chars) : option chars :=
  match split_scheme u with Some (s, _) => if isnil s then None else Some s | None => None end.
