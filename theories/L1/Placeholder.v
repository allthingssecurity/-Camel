(** * L1 Placeholder: Camel's property placeholders [{{key}}], written from the documentation only.

    Legend (apache/camel aa63c0a4cb94):
      [PP]  docs/docs/user-manual/modules/ROOT/pages/using-propertyplaceholder.adoc
      [PF]  docs/docs/user-manual/modules/ROOT/pages/property-placeholder-functions.adoc
      [PC]  core/camel-base/src/main/docs/properties-component.adoc
      [CCJ] core/camel-api/src/main/java/org/apache/camel/CamelContext.java (javadoc of resolvePropertyPlaceholders)
      [PCJ] core/camel-api/src/main/java/org/apache/camel/spi/PropertiesComponent.java (javadoc)
    [PC], [CCJ] and [PCJ] are not in the docs/ snapshot yet: they were read with [git show aa63c0a4cb94:<path>] in
    ../camel (same commit as PIN); the main session is asked to add them to docs/ (notes/lang.md).

    What is modelled: the text form [context.resolvePropertyPlaceholders(text)] [PP.522-562, CCJ.1010-1024]: text,
    placeholders, defaults, the optional [?] and negated [!] forms, [?nested=false], escaping, nested values, the
    [env:], [sys:] and [service:]/[service.host:]/[service.port:] functions, and the precedence of the property
    layers that can be given as explicit inputs (override, OS environment, JVM system properties, initial
    properties). The OS environment and the system properties are explicit inputs ([pe_env], [pe_sys]); nothing here
    reads a real OS.

    Out of scope (answer [PUns "out of scope: ..."]): property files and locations [PC.21-117] (parsing of
    .properties text), the [bean:] function (needs a registry and camel-bean [PF.262-300]), the [boolean:] function
    (needs Simple over properties [PF.95-174]), the Kubernetes functions [PF.302-661], custom functions
    [PF.664-741], third-party sources [PP.728-752], Spring XML [PP.587-718], cloud secrets [PP.565-584] and the
    endpoint-URI form of optional placeholders [PP.105-122] (an option is dropped from a URI: that is the endpoint
    layer's business). *)
From Stdlib Require Import ZArith String Ascii List Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

From CamelSpec.Common Require Import Text.

(** ** 1. Inputs and results *)

Definition kv := list (chars * chars).
Fixpoint klookup (k : chars) (l : kv) : option chars :=
  match l with [] => None | (k', v) :: l' => if ceqs k k' then Some v else klookup k l' end.

(** The property layers given as explicit inputs, and the two component switches that change resolution:
    [nested-placeholder] (default true [PC.140]) and [default-fallback-enabled] (default true [PC.128]). *)
Record penv : Type := mkPE {
  pe_override : kv;     (* PropertiesComponent.setOverrideProperties [PCJ.276-278, PC.141-142] *)
  pe_env : kv;          (* the OS environment variables *)
  pe_sys : kv;          (* the JVM system properties *)
  pe_initial : kv;      (* PropertiesComponent.setInitialProperties [PCJ.263-265, PC.135-136] *)
  pe_nested : bool;     (* setNestedPlaceholder [PP.425-431] *)
  pe_fallback : bool }. (* default-fallback-enabled [PC.128] *)
Definition penv0 (initial : kv) : penv := mkPE [] [] [] initial true true.

(** [PV s]: the resolved text. [PFail exc]: resolution fails with an exception of class [exc] (simple name); an empty
    [exc] means "fails, the class is not documented". [PUns why]: UNSPECIFIED. *)
Inductive pres : Type :=
| PV (s : chars)
| PFail (exc : chars)
| PUns (why : string).

(*! R L1.ph.missing-exception DOC [CCJ.1016-1019] *)
(** An error resolving a placeholder is an [IllegalArgumentException] [CCJ.1018-1019, PCJ.83]. *)
Definition iae : pres := PFail (str "IllegalArgumentException").

Definition pbind (r : pres) (k : chars -> pres) : pres :=
  match r with PV s => k s | o => o end.

(** ** 2. Lexing: placeholder brackets and escapes *)

Definition bsl : ascii := "\"%char.
Definition lbr : ascii := "{"%char.
Definition rbr : ascii := "}"%char.
Definition OPEN : chars := [lbr; lbr].
Definition CLOSE : chars := [rbr; rbr].

Inductive tok : Type :=
| TC (c : ascii)        (* a character of text *)
| TOpen                 (* {{ *)
| TClose                (* }} *)
| TLit (s : chars)      (* an escaped bracket pair, kept as text *)
| TBad (why : string).  (* a form the docs do not cover *)

Fixpoint bs_run (s : chars) : nat * chars :=
  match s with c :: r => if ceq c bsl then let (n, t) := bs_run r in (S n, t) else (O, s) | [] => (O, []) end.

(*! R L1.ph.syntax DOC [PP.21-33, PCJ.58-66] *)
(** A placeholder is opened by [{{] and closed by [}}] [PP.24, PCJ.61, PCJ.66]. *)
(*! R L1.ph.escape DOC [PP.436-449] *)
(** [\{{] and [\}}] are not brackets: they stand for the text [{{] and [}}] [PP.440]. A second backslash in front
    escapes the first, which is then a backslash, and the brackets are brackets again [PP.449]. A backslash anywhere
    else is text (the docs give it no other meaning). UNSPECIFIED: three or more backslashes before brackets, and
    three or more braces in a row (which pair is the bracket). *)
Fixpoint lex (fuel : nat) (s : chars) : list tok :=
  match fuel with
  | O => []
  | S f =>
    match s with
    | [] => []
    | c :: r =>
      if ceq c bsl then
        let '(n, rest) := bs_run s in
        if prefix OPEN rest || prefix CLOSE rest then
          if prefix [lbr; lbr; lbr] rest || prefix [rbr; rbr; rbr] rest then [TBad "PP: an escape before three braces"]
          else match n with
               | 1 => TLit (firstn 2 rest) :: lex f (skipn 2 rest)
               | 2 => TC bsl :: (if prefix OPEN rest then TOpen else TClose) :: lex f (skipn 2 rest)
               | _ => [TBad "PP: three or more backslashes before {{ or }}"]
               end
        else map TC (repeat_c bsl n) ++ lex f rest
      else if prefix [lbr; lbr; lbr] s || prefix [rbr; rbr; rbr] s then [TBad "PP: three or more braces in a row"]
      else if prefix OPEN s then TOpen :: lex f (skipn 2 s)
      else if prefix CLOSE s then TClose :: lex f (skipn 2 s)
      else TC c :: lex f r
    end
  end.

Inductive seg : Type := SText (s : chars) | SPh (c : chars) | SBad (why : string).

(** Segments: text, and placeholders whose content is plain characters. UNSPECIFIED: a [{{] without its [}}], a
    [}}] without a [{{], a placeholder inside a placeholder key (the docs only nest through property values
    [PP.320-330]), an escape inside a placeholder. *)
Fixpoint ph_body (ts : list tok) (acc : chars) : option (chars * list tok) + string :=
  match ts with
  | [] => inr "PP: {{ without }}"
  | TC c :: r => ph_body r (acc ++ [c])
  | TClose :: r => inl (Some (acc, r))
  | TOpen :: _ => inr "PP: a placeholder inside a placeholder key"
  | TLit _ :: _ => inr "PP: an escape inside a placeholder"
  | TBad w :: _ => inr w
  end.
Fixpoint segs (fuel : nat) (ts : list tok) : list seg :=
  match fuel with
  | O => []
  | S f =>
    match ts with
    | [] => []
    | TC c :: r => SText [c] :: segs f r
    | TLit s :: r => SText s :: segs f r
    | TClose :: _ => [SBad "PP: }} without {{"]
    | TBad w :: _ => [SBad w]
    | TOpen :: r =>
        match ph_body r [] with
        | inl (Some (c, r')) => SPh c :: segs f r'
        | inl None => [SBad "PP: {{ without }}"]
        | inr w => [SBad w]
        end
    end
  end.
Definition parse (s : chars) : list seg := segs (S (length s)) (lex (S (length s)) s).
Definition has_brackets (s : chars) : bool := occurs OPEN s || occurs CLOSE s.
Definition has_escape (s : chars) : bool := occurs [bsl; lbr; lbr] s || occurs [bsl; rbr; rbr] s.

(** ** 3. Looking up a property key *)

Definition is_keyc (c : ascii) : bool :=
  is_letter c || is_digit c || ceq c "."%char || ceq c "-"%char || ceq c "_"%char.
(** Keys the rules talk about: letters, digits, [.], [-], [_] (all the doc examples, e.g. [file.uri],
    [integration.ftpEnabled], [my-property]). Other characters in a key: UNSPECIFIED. *)
Definition good_key (k : chars) : bool := match k with [] => false | _ => forallb is_keyc k end.
(** The OS-variable spelling of a key (upper case, [.] and [-] as [_]); used only to say UNSPECIFIED. *)
Definition env_spelling (k : chars) : chars :=
  map (fun c => if ceq c "."%char || ceq c "-"%char then "_"%char else upc c) k.

Inductive lk : Type := LFound (v : chars) (fromos : bool) | LMissing | LUns (why : string).

(*! R L1.ph.precedence FIX [PCJ.42-43, PCJ.276-278, PC.131-133, PC.141-142, PC.145-147, PC.135-136] *)
(** The layers, first match wins: the OS environment, then the JVM system properties (their default mode "override"
    makes them "override any existing properties", the environment being checked first [PC.131-133, PC.145-147]);
    then the override properties, which "take precedence and will use first" [PC.141, PCJ.276], over the initial
    properties [PC.135-136, PCJ.263]. UNSPECIFIED: a key in the override properties and in the environment or the
    system properties: the docs contradict themselves (override properties are "the highest priority" [PCJ.42-43],
    the environment and system modes override "any existing properties" [PC.131-133, PC.145-147]); a key that is not
    written as an OS variable (upper case, [_]) when the environment has it or its OS-variable spelling (is a key
    mapped to a variable name?).
    FIX 2026-10-26 (CHANGELOG): was "override first", which resolved the contradiction by picking a side. *)
Definition lookup_key (pe : penv) (k : chars) : lk :=
  let inenv := klookup k (pe_env pe) in
  let insys := klookup k (pe_sys pe) in
  match klookup k (pe_override pe), inenv, insys with
  | Some _, Some _, _ | Some _, _, Some _ =>
      LUns "PC/PCJ contradict: override properties (highest priority) vs OS environment / system properties (override mode)"
  | _, _, _ =>
    if negb (ceqs (env_spelling k) k) &&
       (match inenv with Some _ => true | None => false end ||
        match klookup (env_spelling k) (pe_env pe) with Some _ => true | None => false end)
    then LUns "PC: a key not written as an OS variable, and an OS variable of that name or spelling: is it mapped?"
    else
    match inenv with
    | Some v => LFound v true
    | None =>
      match insys with
           | Some v => LFound v true
           | None => match klookup k (pe_override pe) with
                     | Some v => LFound v false
                     | None => match klookup k (pe_initial pe) with Some v => LFound v false | None => LMissing end
                     end
           end
    end
  end.

(** ** 4. One placeholder *)

Fixpoint split_colon (s : chars) : chars * option chars :=
  match s with
  | [] => ([], None)
  | c :: r => if ceq c ":"%char then ([], Some r) else let (a, b) := split_colon r in (c :: a, b)
  end.

(*! R L1.ph.nested DOC [PP.320-330, PC.140, PP.369-372, PP.425-431] *)
(** A value found for a key is itself resolved (nested placeholders) [PP.320-330], unless nesting is off for this key
    ([?nested=false] [PP.369-372]) or on the component [PP.425-431, PC.140]; then the value is used as it is.
    UNSPECIFIED: a cycle of keys; a value from the OS environment or the system properties that contains brackets
    (the nesting examples are property values); escapes in a value that is not resolved. *)
Definition use_value (rec : list chars -> chars -> pres) (pe : penv) (seen : list chars) (k : chars)
    (nested : bool) (v : chars) (fromos : bool) : pres :=
  if nested && pe_nested pe then
    if existsb (ceqs k) seen then PUns "PP: a cycle of nested placeholders"
    else if fromos && has_brackets v then PUns "PP: placeholders inside an OS variable or system property value"
    else rec (k :: seen) v
  else if has_escape v then PUns "PP: escapes in a value that is not resolved (nested=false)"
  else PV v.

(*! R L1.ph.default DOC [PP.83-93, PF.56-67, PC.128] *)
(** A missing key with a default: the default, "the text after the colon" [PP.85-93]; the first colon after the key
    (defaults may contain colons: [{{env:SOMENAME:log:foo}}] has the default [log:foo] [PF.56-67]). A missing key
    without a default is an error [CCJ.1018-1019]. *)
Definition missing (def : option chars) : pres :=
  match def with Some d => PV d | None => iae end.

(*! R L1.ph.env FIX [PF.8, PF.16-27, PF.56-67, PC.54-68] *)
(** [env:NAME]: the OS environment variable [NAME] [PF.8]; a missing [NAME] with a dash is looked up with an
    underscore instead [PC.65-68]. UNSPECIFIED: a name that is not written as an OS variable (lower case letters or
    a dot): the docs do not say whether it is mapped (all their examples are upper case). FIX 2026-10-26: [env.NAME]
    removed ([PC.56] is about property file locations, not placeholders); a lower-case name was looked up as it is. *)
Definition f_env (pe : penv) (name : chars) (def : option chars) : pres :=
  if negb (good_key name) then PUns "PF: env: variable name characters"
  else if negb (ceqs (replace_all (str "-") (str "_") (env_spelling name)) (replace_all (str "-") (str "_") name))
  then PUns "PF: env: a name not written as an OS variable (upper case, _): is it mapped?"
  else
  let found := fun v => if has_brackets v then PUns "PF: placeholders inside an OS variable value" else PV v in
  match klookup name (pe_env pe) with
  | Some v => found v
  | None =>
    match (if occurs (str "-") name then klookup (replace_all (str "-") (str "_") name) (pe_env pe) else None) with
    | Some v => found v
    | None => missing def
    end
  end.

(*! R L1.ph.sys DOC [PF.9, PF.16-27, PF.56-67, PC.41-52] *)
(** [sys:name]: the JVM system property [name] [PF.9, PC.49-52]. *)
Definition f_sys (pe : penv) (name : chars) (def : option chars) : pres :=
  if negb (good_key name) then PUns "PF: sys: property name characters"
  else match klookup name (pe_sys pe) with
       | Some v => if has_brackets v then PUns "PF: placeholders inside a system property value" else PV v
       | None => missing def
       end.

(*! R L1.ph.service DOC-BUG [PF.12-14, PF.176-260] *)
(** [service:NAME] is [host:port] from the variables [NAME_SERVICE_HOST] and [NAME_SERVICE_PORT] [PF.176-188] (the
    docs write [hostname : port] [PF.176]; the URI example [http://{{service:FOO}}/myapp] [PF.200] needs it without
    spaces); [service.host:] gives the host only, [service.port:] the port only [PF.13-14]; a default is used when
    the service is not defined [PF.226-236]. DOC-BUG 2026-10-26: [PF.13] names the host function [service.name];
    Camel's function is [service.host] (ServiceHostPropertiesFunction.getName(), pinned by
    PropertiesComponentServiceHostTest and PropertiesComponentServiceHostPortTest); [service.name:] is a plain key. UNSPECIFIED: a name that is not upper case (is it mapped?), and a
    service with only one of the two variables. *)
Definition is_envc (c : ascii) : bool := is_upper c || is_digit c || ceq c "_"%char.
Definition f_service (pe : penv) (part : nat) (name : chars) (def : option chars) : pres :=
  if negb (match name with [] => false | _ => forallb is_envc name end) then PUns "PF: service: a name that is not upper case"
  else
  let h := klookup (name ++ str "_SERVICE_HOST") (pe_env pe) in
  let p := klookup (name ++ str "_SERVICE_PORT") (pe_env pe) in
  match part with
  | 0 => match h, p with
         | Some hv, Some pv => PV (hv ++ ":"%char :: pv)
         | None, None => missing def
         | _, _ => PUns "PF: service: only one of _SERVICE_HOST and _SERVICE_PORT is set"
         end
  | 1 => match h with Some hv => PV hv | None => missing def end
  | _ => match p with Some pv => PV pv | None => missing def end
  end.

(*! R L1.ph.optional DOC [PP.95-122] *)
(** [{{?key}}]: optional [PP.97-103]; if the key exists its value is used [PP.105]. UNSPECIFIED: a missing optional
    key in a text (the docs describe only how an endpoint URI drops the option [PP.105-122]). *)
(*! R L1.ph.negate DOC [PP.124-188] *)
(** [{{!key}}]: the boolean value reversed [PP.126, PP.187-188]. UNSPECIFIED: a value that is not [true]/[false], a
    missing key, and the prefix combined with a default or another form. *)
(*! R L1.ph.trim-key DOC [PP.582] *)
(** White space around the content of a placeholder is not part of it: [{{ my-property }}] reads [my-property]
    [PP.582]. *)
(*! R L1.ph.functions DOC [PF.6-14, PF.664-668] *)
(** The text before the first colon names a function if it is one of the built-in functions [PF.8-14]; otherwise it
    is the key and the rest is the default [PP.85-93]. With [default-fallback-enabled] false there is no default:
    the whole text is the key [PC.128]. *)
Definition ph (rec : list chars -> chars -> pres) (pe : penv) (seen : list chars) (c : chars) : pres :=
  let k := trim c in
  let plain := fun (key : chars) (nested : bool) (def : option chars) =>
    if negb (good_key key) then PUns "PP: key characters (only letters, digits, . - _ are covered)"
    else match lookup_key pe key with
         | LFound v os => use_value rec pe seen key nested v os
         | LMissing => missing def
         | LUns w => PUns w
         end in
  match k with
  | [] => PUns "PP: an empty placeholder"
  | "?"%char :: k' =>
      if negb (good_key k') then PUns "PP: an optional placeholder combined with another form"
      else match lookup_key pe k' with
           | LFound v os => use_value rec pe seen k' true v os
           | LMissing => PUns "PP: a missing optional placeholder in a text (only endpoint URIs are documented)"
           | LUns w => PUns w
           end
  | "!"%char :: k' =>
      if negb (good_key k') then PUns "PP: a negated placeholder combined with another form"
      else match lookup_key pe k' with
           | LFound v os =>
               pbind (use_value rec pe seen k' true v os) (fun s =>
                 if ceqs s (str "true") then PV (str "false")
                 else if ceqs s (str "false") then PV (str "true")
                 else PUns "PP: negating a value that is not true or false")
           | LMissing => PUns "PP: a missing negated placeholder"
           | LUns w => PUns w
           end
  | _ =>
    if suffix (str "?nested=false") k then
      let key := firstn (length k - 13) k in
      if negb (good_key key) then PUns "PP: ?nested=false combined with another form"
      else plain key false None
    else if occurs (str "?") k then PUns "PP: a question mark inside a placeholder"
    else if negb (pe_fallback pe) then
      (if occurs (str ":") k then PUns "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
       else plain k true None)
    else
    let '(name, rest) := split_colon k in
    if ceqs name (str "env") then
      match rest with Some r => let '(n, d) := split_colon r in f_env pe n d | None => PUns "PF: env without a name" end
    else if ceqs name (str "sys") then
      match rest with Some r => let '(n, d) := split_colon r in f_sys pe n d | None => PUns "PF: sys without a name" end
    else if ceqs name (str "service") || ceqs name (str "service.host") || ceqs name (str "service.port") then
      let part := if ceqs name (str "service") then 0 else if ceqs name (str "service.host") then 1 else 2 in
      match rest with Some r => let '(n, d) := split_colon r in f_service pe part n d | None => PUns "PF: service without a name" end
    else if ceqs name (str "bean") then PUns "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
    else if ceqs name (str "boolean") then PUns "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
    else if negb (good_key name) then PUns "PP: key characters (only letters, digits, . - _ are covered)"
    else plain name true rest
  end.

(** ** 5. A text *)

(*! R L1.ph.text DOC [PP.522-562, PP.451-503] *)
(** The text with every placeholder replaced by its value, the rest copied as it is [PP.542-562]; a placeholder
    can appear several times [PP.451-503]. *)
Fixpoint res_text (fuel : nat) (pe : penv) (seen : list chars) (s : chars) : pres :=
  match fuel with
  | O => PUns "PP: nesting deeper than the model's bound"
  | S f =>
    fold_right (fun sg acc =>
      match sg with
      | SText t => pbind acc (fun r => PV (t ++ r))
      | SBad w => PUns w
      | SPh c => match ph (res_text f pe) pe seen c with
                 | PV v => pbind acc (fun r => PV (v ++ r))
                 | o => match acc with PUns w => PUns w | _ => o end
                 end
      end) (PV []) (parse s)
  end.
Definition resolve (pe : penv) (s : chars) : pres := res_text 16 pe [] s.

(** ** 6. The documented examples (checked by [vm_compute]) *)

Definition kvs (l : list (string * string)) : kv := map (fun '(k, v) => (str k, str v)) l.
Definition rs (l : list (string * string)) (s : string) : pres := resolve (penv0 (kvs l)) (str s).
Definition ok (s : string) : pres := PV (str s).

(** [PP.547-562]: two placeholders in a sentence. *)
Example doc_greeting :
  rs [("greeting", "Hi"); ("cool", "awesome")] "{{greeting}} Camel user, Camel is {{cool}} dont you think?"
  = ok "Hi Camel user, Camel is awesome dont you think?".
Proof. vm_compute. reflexivity. Qed.
(** [PP.75-80, PP.28-33]: a whole URI. *)
Example doc_file_uri :
  rs [("file.uri", "file:/var/orders/inbox?recursive=true")] "{{file.uri}}" = ok "file:/var/orders/inbox?recursive=true".
Proof. vm_compute. reflexivity. Qed.
(** [PP.240-253, PP.281-318]: part of a URI. *)
Example doc_parts :
  rs [("buf", "8192"); ("where", "cheese")] "file:outbox?bufferSize={{buf}}" = ok "file:outbox?bufferSize=8192" /\
  rs [("cool.end", "mock:result"); ("where", "cheese")] "mock:{{where}}" = ok "mock:cheese".
Proof. vm_compute. split; reflexivity. Qed.
(** [PP.85-93]: the default is used when the key does not exist. *)
Example doc_default : rs [] "{{file.url:/some/path}}" = ok "/some/path".
Proof. vm_compute. reflexivity. Qed.
(** [PP.320-330]: nested, [cool.concat] refers to [cool.foo]. *)
Example doc_nested : rs [("cool.foo", "result"); ("cool.concat", "mock:{{cool.foo}}")] "{{cool.concat}}" = ok "mock:result".
Proof. vm_compute. reflexivity. Qed.
(** [PP.369-423]: [?nested=false] gives the JSON value as it is. *)
Example doc_nested_false :
  rs [("myQuery", "{""query"":{""match_all"":{}}}")] "{{myQuery?nested=false}}" = ok "{""query"":{""match_all"":{}}}".
Proof. vm_compute. reflexivity. Qed.
(** [PP.436-449]: the escaped value of [PP.446] (in the .properties file [\\}}] is the text [\}}]) resolves to the
    JSON query; and [\{{ property-name \}}] is the text [{{ property-name }}] [PP.440]. *)
Example doc_escape :
  rs [("myQuery", "{""query"":{""match_all"":{}\}}")] "{{myQuery}}" = ok "{""query"":{""match_all"":{}}}" /\
  rs [] "\{{ property-name \}}" = ok "{{ property-name }}".
Proof. vm_compute. split; reflexivity. Qed.
(** [PP.124-188]: [{{!integration.ftpEnabled}}] reverses [true]. *)
Example doc_negate :
  rs [("integration.ftpEnabled", "true")] "{{integration.ftpEnabled}}" = ok "true" /\
  rs [("integration.ftpEnabled", "true")] "{{!integration.ftpEnabled}}" = ok "false".
Proof. vm_compute. split; reflexivity. Qed.
(** [PP.451-503]: one placeholder used twice. *)
Example doc_multiple :
  rs [("cool.start", "direct:start"); ("cool.showid", "true"); ("cool.result", "result")]
     "log:{{cool.start}}?showBodyType=false&showExchangeId={{cool.showid}}"
  = ok "log:direct:start?showBodyType=false&showExchangeId=true".
Proof. vm_compute. reflexivity. Qed.
(** [PP.582]: [{{ my-property }}]. *)
Example doc_spaces : rs [("my-property", "Camel 4.8")] "{{ my-property }}" = ok "Camel 4.8".
Proof. vm_compute. reflexivity. Qed.
(** [PF.56-67, PF.163-172]: env and sys with defaults that contain colons, a missing variable. *)
Example doc_env_sys_default :
  rs [] "{{env:SOMENAME:log:foo}}" = ok "log:foo" /\
  rs [] "{{sys:MyJvmPropertyName:log:bar}}" = ok "log:bar" /\
  rs [] "{{env:MY_SERVER_NAME:localhost}}" = ok "localhost".
Proof. vm_compute. repeat split. Qed.
Definition pe_os (env sys : list (string * string)) : penv := mkPE [] (kvs env) (kvs sys) [] true true.
(** [PF.176-188, PF.200]: [service:FOO] (host function [service.host], DOC-BUG of [PF.13]) with FOO_SERVICE_HOST=myserver, FOO_SERVICE_PORT=8888; the default when
    the service is not defined [PF.226-236]. *)
Example doc_service :
  let pe := pe_os [("FOO_SERVICE_HOST", "myserver"); ("FOO_SERVICE_PORT", "8888")] [] in
  resolve pe (str "http://{{service:FOO}}/myapp") = ok "http://myserver:8888/myapp" /\
  resolve pe (str "{{service.host:FOO}}") = ok "myserver" /\
  resolve pe (str "{{service.port:FOO}}") = ok "8888" /\
  resolve (pe_os [] []) (str "http://{{service:FOO:localhost:8080}}/myapp") = ok "http://localhost:8080/myapp".
Proof. vm_compute. repeat split. Qed.
(** [PC.60-75]: [{{env:APP_HOME}}] and a second placeholder in the same text; [APP-HOME] falls back to
    [APP_HOME] [PC.65-68]. *)
Example doc_env_location :
  let pe := mkPE [] (kvs [("APP_HOME", "/opt/app")]) [] (kvs [("prop.name", "foo")]) true true in
  resolve pe (str "file:{{env:APP_HOME}}/etc/{{prop.name}}.properties") = ok "file:/opt/app/etc/foo.properties" /\
  resolve pe (str "{{env:APP-HOME}}") = ok "/opt/app".
Proof. vm_compute. split; reflexivity. Qed.
(** [CCJ.1018-1019]: a missing key without a default fails with IllegalArgumentException. *)
Example doc_missing : rs [] "{{nope}}" = PFail (str "IllegalArgumentException").
Proof. vm_compute. reflexivity. Qed.
