(** * L1 Lang: the non-Simple core languages (constant, header, exchangeProperty, variable, ref, tokenize), written
    from the documentation only.

    Legend (apache/camel aa63c0a4cb94; pages under docs/core/camel-core-languages/src/main/docs/modules/languages/pages/
    unless a path is given):
      [C]  constant-language.adoc          [H]  header-language.adoc       [XP] exchangeProperty-language.adoc
      [V]  variable-language.adoc          [R]  ref-language.adoc          [TK] tokenize-language.adoc
      [SE] docs/core/camel-core-engine/src/main/docs/modules/eips/pages/split-eip.adoc
      [VA] docs/docs/user-manual/modules/ROOT/pages/variables.adoc
      [PR] docs/docs/user-manual/modules/ROOT/pages/predicate.adoc
      [PP] docs/docs/user-manual/modules/ROOT/pages/using-propertyplaceholder.adoc
      [MJ] docs/core/camel-api/src/main/java/org/apache/camel/Message.java
      [EXJ] docs/core/camel-api/src/main/java/org/apache/camel/Exchange.java
      [CJc] [CJh] [CJx] [CJv] [CJr] [CJt]: catalog/camel-catalog/src/generated/resources/org/apache/camel/catalog/languages/
           {constant,header,exchangeProperty,variable,ref,tokenize}.json. Each language page renders its option table
           and its "body types" from this file ([include::partial$language-options.adoc[]], e.g. [C.23-25]), so these
           lines are documentation. Not in the docs/ snapshot yet: read with [git show aa63c0a4cb94:<path>] in
           ../camel; the main session is asked to add them (notes/lang.md).

    Each language is an expression (and, where the docs say so, a predicate) evaluated over an abstract environment
    [lenv] (body, headers, exchange properties, variables, registry, property placeholders), not over a full
    exchange; the main session connects [lenv] to its Exchange model. Where a result depends on type conversion (the
    [resultType] option) the rule is UNSPECIFIED pending L0/Convert.v.

    Common options: [trim] (default true: "trim the source code to remove leading and trailing whitespaces and line
    breaks" [CJc.28, CJh.27, CJx.27, CJv.27, CJr.29]) and [resolveResource] (default false; not modelled, the
    generator leaves it unset). The [resource:] prefix on the expression text, "always resolved" [CJc.29], loads a
    file or classpath resource: out of scope. *)
From Stdlib Require Import ZArith String Ascii List Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value.
From CamelSpec.L1 Require Import Placeholder.

(** ** 1. Environment and results *)

(** A registry entry, as far as the ref language can tell: an [Expression] whose value is [v], a [Predicate] whose
    answer is [b], or another bean (with its value). *)
Inductive regobj : Type := RgExpr (v : val) | RgPred (b : bool) | RgOther (v : val).

Record lenv : Type := mkLE {
  le_body : val;
  le_headers : list (chars * val);
  le_xprops : list (chars * val);                    (* exchange properties *)
  le_vars : list (chars * val);                      (* the exchange's own variables [VA.17, VA.22] *)
  le_gvars : list (chars * val);                     (* the global repository [VA.20] *)
  le_groups : list (chars * list (chars * val));     (* the group repository, per group name [VA.19] *)
  le_reg : list (chars * regobj);                    (* the registry *)
  le_pp : penv }.                                    (* property placeholders *)
Definition lenv0 (body : val) : lenv := mkLE body [] [] [] [] [] [] (penv0 []).

(** [LV v]: the value. [LErr exc]: the expression fails with an exception of class [exc] (simple name; empty when
    the class is not documented). [LUns why]: UNSPECIFIED. *)
Inductive lres : Type := LV (v : val) | LErr (exc : chars) | LUns (why : string).

(** Lookups. [cilookup]: names compared ignoring case; two entries equal up to case make the environment
    ambiguous. [exlookup]: exact names; when only an entry differing in case exists the result is UNSPECIFIED (the
    docs do not say whether these names are case-sensitive). *)
Inductive look : Type := Found (v : val) | Absent | Amb (why : string).
Definition cilookup (k : chars) (l : list (chars * val)) : look :=
  match filter (fun '(k', _) => ceqs (lower k) (lower k')) l with
  | [] => Absent
  | [(_, v)] => Found v
  | _ => Amb "env: two headers whose names differ only in case"
  end.
Fixpoint exact (k : chars) (l : list (chars * val)) : option val :=
  match l with [] => None | (k', v) :: l' => if ceqs k k' then Some v else exact k l' end.
Definition exlookup (what : string) (k : chars) (l : list (chars * val)) : look :=
  match exact k l with
  | Some v => Found v
  | None => if existsb (fun '(k', _) => ceqs (lower k) (lower k')) l
            then Amb (what ++ ": is the name case-sensitive? (only a name differing in case exists)")
            else Absent
  end.

(*! R L1.lang.trim DOC [CJc.28, CJh.27, CJx.27, CJv.27, CJr.29] *)
(** The expression text, trimmed when [trim] is on (the default). *)
Definition etext (trim_on : bool) (s : chars) : chars := if trim_on then trim s else s.

(** Text forms the language pages do not cover, for the languages whose text is a name. *)
Definition name_guard (lang : string) (s : chars) : option string :=
  if prefix (str "resource:") s then Some "out of scope: resource: loading of the expression text [CJc.29]"
  else if occurs (str "{{") s then Some ("PP: placeholders in a " ++ lang ++ " name ('almost anywhere' [PP.3-4])")%string
  else if occurs (str "${") s then Some ("" ++ lang ++ ": a ${ } in the name")%string
  else match s with [] => Some ("" ++ lang ++ ": an empty name")%string | _ => None end.

(*! R L1.lang.predicate DOC [PR.37-38] *)
(** A value used as a predicate: a Boolean is its own answer [PR.37-38] ("evaluated to a boolean value"). *)
(*! R L1.lang.predicate.value CODE [ObjectHelper.evaluateValuePredicate, camel-util; 025f7cb97232] *)
(** The docs do not say how any other value becomes true or false (was UNSPECIFIED; 1690 differential cases).
    CODE 2026-10-26, from camel-util org.apache.camel.util.ObjectHelper.evaluateValuePredicate (present unchanged
    since the start of the local history, 025f7cb97232; older history is not in this clone): null is false; a String
    is false when blank after trim, true/false ignoring case for those words, true otherwise; a collection is true
    when not empty; any other value is true. *)
Definition str_truth (s : chars) : bool :=
  let t := trim s in
  match t with
  | [] => false
  | _ => if ceqs (lower t) (str "false") then false else true
  end.
Definition as_pred (r : lres) : lres :=
  match r with
  | LV (VBool b) => LV (VBool b)
  | LV VNull => LV (VBool false)
  | LV (VStr s) => LV (VBool (str_truth s))
  | LV (VList l) => LV (VBool (negb (Nat.eqb (length l) 0)))
  | LV _ => LV (VBool true)
  | o => o
  end.

(** ** 2. constant *)

(*! R L1.lang.constant DOC [C.12-18, C.30-78, CJc.19, PP.369-423] *)
(** The text as it is written, a [String] [C.76-78, CJc.19]. Placeholders in it are resolved: the docs' example
    [constant("{{myQuery?nested=false}}")] [PP.380-384]. UNSPECIFIED: whether [trim] applies before or after the
    placeholders, when that changes the result. *)
(*! R L1.lang.constant.resultType DOC [C.80-128, CJc.27] *)
(** [resultType]: the value converted to that type [C.82-83]: UNSPECIFIED pending L0/Convert.v (the doc example
    [resultType="int"] for [90210] [C.105] is therefore not reproduced here). *)
Definition ev_constant (x : lenv) (text : chars) (rtype : option chars) (trim_on : bool) : lres :=
  match rtype with
  | Some _ => LUns "C: resultType needs type conversion (pending L0/Convert.v)"
  | None =>
    let t := etext trim_on text in
    if prefix (str "resource:") t then LUns "out of scope: resource: loading of the expression text [C.131-179]"
    else if occurs (str "{{") text || occurs (str "}}") text || occurs (str "\") text then
      match resolve (le_pp x) t, resolve (le_pp x) text with
      | PV a, PV b => if ceqs a (etext trim_on b) then LV (VStr a)
                      else LUns "C: trim before or after resolving the placeholders"
      | PFail e, PFail _ => LErr e
      | PUns w, _ | _, PUns w => LUns w
      | _, _ => LUns "C: trim before or after resolving the placeholders"
      end
    else LV (VStr t)
  end.

(** ** 3. header, exchangeProperty, variable *)

(*! R L1.lang.header DOC [H.12-13, H.62-63, CJh.19, MJ.31-34, MJ.42, MJ.150] *)
(** The value of the named header as it is, null when there is none [CJh.19, H.12-13]; header names are
    case-insensitive [MJ.31-34, MJ.42, MJ.150]. "A missing header falls back to the exchange property of that name"
    [CJh.19]. UNSPECIFIED: a header that is present with the value null (missing, or there?), and a property name
    that matches only up to case. *)
Definition ev_header (x : lenv) (name : chars) (trim_on : bool) : lres :=
  let k := etext trim_on name in
  match name_guard "header" k with
  | Some w => LUns w
  | None =>
    match cilookup k (le_headers x) with
    | Found VNull => LUns "H: a header present with the value null"
    | Found v => LV v
    | Amb w => LUns w
    | Absent =>
      match exlookup "XP" k (le_xprops x) with
      | Found v => LV v
      | Absent => LV VNull
      | Amb w => LUns w
      end
    end
  end.

(*! R L1.lang.exchangeProperty DOC [XP.12-13, XP.62-63, CJx.19, EXJ.443-457] *)
(** The value of the named exchange property as it is, null when there is none [CJx.19, EXJ.447]. UNSPECIFIED:
    whether the name is case-sensitive, when only a name differing in case exists. *)
Definition ev_prop (x : lenv) (name : chars) (trim_on : bool) : lres :=
  let k := etext trim_on name in
  match name_guard "exchangeProperty" k with
  | Some w => LUns w
  | None => match exlookup "XP" k (le_xprops x) with Found v => LV v | Absent => LV VNull | Amb w => LUns w end
  end.

(*! R L1.lang.variable DOC [V.12-13, V.62-63, CJv.19, VA.13-22, VA.54-66, VA.97-115, EXJ.541-554] *)
(** The value of the named variable as it is, null when there is none [CJv.19]: by default from the exchange's own
    repository [VA.22, VA.54, EXJ.544-545]; [global:name] from the global repository [VA.55-60, CJv.19];
    [group:g:name] from group [g] [VA.97-112]. Out of scope: [route:] (route variables need a route [VA.80-95,
    VA.186-203]). UNSPECIFIED: another [id:] prefix (custom repositories [VA.29-36]), and names matching only up to
    case. *)
Definition ev_var (x : lenv) (name : chars) (trim_on : bool) : lres :=
  let k := etext trim_on name in
  let res := fun (l : look) => match l with Found v => LV v | Absent => LV VNull | Amb w => LUns w end in
  match name_guard "variable" k with
  | Some w => LUns w
  | None =>
    if prefix (str "global:") k then res (exlookup "VA" (skipn 7 k) (le_gvars x))
    else if prefix (str "route:") k then LUns "out of scope: route: variables need a route [VA.80-95]"
    else if prefix (str "group:") k then
      let r := skipn 6 k in
      match split_on ":"%char r with
      | [g; n] => match filter (fun '(g', _) => ceqs g g') (le_groups x) with
                  | [] => LV VNull
                  | (_, l) :: _ => res (exlookup "VA" n l)
                  end
      | _ => LUns "VA: a group: variable name that is not group:g:name"
      end
    else if occurs (str ":") k then LUns "VA: a name with a colon and no documented repository id"
    else res (exlookup "VA" k (le_vars x))
  end.

(** ** 4. ref *)

(*! R L1.lang.ref DOC [R.12-15, R.71-74, CJr.19-20, CJr.28] *)
(** The [Expression] or [Predicate] with this id in the registry [R.12-13, R.71-74]; as an expression it returns
    what the registered expression returns, a Boolean for a predicate [CJr.20]. UNSPECIFIED: a missing id, a bean
    that is neither, an id matching only up to case, and [resultType] (pending L0/Convert.v). *)
Definition ev_ref (x : lenv) (name : chars) (rtype : option chars) (trim_on : bool) (as_predicate : bool) : lres :=
  let k := etext trim_on name in
  match rtype, name_guard "ref" k with
  | Some _, _ => LUns "R: resultType needs type conversion (pending L0/Convert.v)"
  | _, Some w => LUns w
  | None, None =>
    match filter (fun '(k', _) => ceqs k k') (le_reg x) with
    | (_, RgExpr v) :: _ => if as_predicate then as_pred (LV v) else LV v
    | (_, RgPred b) :: _ => LV (VBool b)
    | (_, RgOther _) :: _ => LUns "R: a registry bean that is neither an Expression nor a Predicate"
    | [] => if existsb (fun '(k', _) => ceqs (lower k) (lower k')) (le_reg x)
            then LUns "R: is the registry id case-sensitive?"
            else LUns "R: a ref to an id that is not in the registry"
    end
  end.

(** ** 5. tokenize *)

Record tkopts : Type := mkTK {
  tk_token : chars;            (* token, required [CJt.27] *)
  tk_end : option chars;       (* endToken [CJt.28] *)
  tk_regex : bool;             (* regex, default false [CJt.30] *)
  tk_xml : bool;               (* xml, default false [CJt.31] *)
  tk_incl : bool;              (* includeTokens, default false [CJt.32] *)
  tk_group : option chars;     (* group [CJt.33] *)
  tk_gdelim : option chars;    (* groupDelimiter [CJt.34] *)
  tk_skip : bool;              (* skipFirst, default false [CJt.35] *)
  tk_source : option chars;    (* source [CJt.36] *)
  tk_inherit : option chars }. (* inheritNamespaceTagName [CJt.29] *)
Definition tk (t : string) : tkopts := mkTK (str t) None false false false None None false None None.

(*! R L1.lang.tokenize.newline FIX [TK.37-38, TK.56-59, SE.56, SE.901] *)
(** The token option written as the two characters [\n] is the new-line token: the XML DSL "must use the [token]
    option" with [token="\n"] for a new line [TK.37-38, TK.59] (XML does not turn [\n] into a new line itself).
    UNSPECIFIED: any other backslash in a token; a token with white space at an end other than the new line itself
    (does [trim] apply to the token?); simple ([${ }]) or placeholders ([{{ }}]) in a token; [\n] in start/end
    tokens (the docs show it for the plain token only). FIX 2026-10-26: [\n] was read as a new line in pair mode
    too. *)
Definition nl : ascii := ascii_of_nat 10.
Definition tok_text (what : string) (pairmode : bool) (t : chars) : chars + string :=
  let t' := if pairmode then t else replace_all [bsl; "n"%char] [nl] t in
  if occurs (str "${") t then inr ("TK: simple language in the " ++ what ++ " (dynamic tokens)")%string
  else if occurs (str "{{") t then inr ("PP: placeholders in the " ++ what)%string
  else if occurs [bsl] t' then inr ("TK: a backslash in the " ++ what ++ (if pairmode then " (pair mode)" else " other than \n"))%string
  else match t' with
       | [] => inr ("TK: an empty " ++ what)%string
       | _ => if ceqs t' [nl] then inl t'
              else if negb (ceqs (trim t') t') then inr ("TK: a " ++ what ++ " with white space at an end (trim?)")%string
              else inl t'
       end.

(** A small regular-expression language for the [regex] option: one atom (a literal character or a class [[..]] of
    literal characters), optionally followed by [+]. Other patterns: UNSPECIFIED here (not a gap in the docs: the
    model just does not cover Java regular expressions). *)
Definition is_meta (c : ascii) : bool := existsb (ceq c) (str "\^$.|?*+()[]{}").
Record ratom : Type := mkRA { ra_set : chars; ra_plus : bool }.
Definition parse_re (p : chars) : option ratom :=
  match p with
  | "["%char :: r =>
      match rev r with
      | "+"%char :: "]"%char :: inner => let s := rev inner in
          if negb (existsb is_meta s) && negb (Nat.eqb (length s) 0) then Some (mkRA s true) else None
      | "]"%char :: inner => let s := rev inner in
          if negb (existsb is_meta s) && negb (Nat.eqb (length s) 0) then Some (mkRA s false) else None
      | _ => None
      end
  | [c] => if is_meta c then None else Some (mkRA [c] false)
  | [c; "+"%char] => if is_meta c then None else Some (mkRA [c] true)
  | _ => None
  end.
Fixpoint ra_len (a : ratom) (s : chars) : nat :=
  match s with c :: r => if existsb (ceq c) (ra_set a) then S (if ra_plus a then ra_len a r else 0) else 0 | [] => 0 end.

(** The pieces between the delimiters, left to right (a delimiter match ends a piece). *)
Fixpoint split_by (fuel : nat) (m : chars -> nat) (s cur : chars) : list chars :=
  match fuel with
  | O => [cur ++ s]
  | S f =>
    match s with
    | [] => [cur]
    | c :: r => match m s with
                | O => split_by f m r (cur ++ [c])
                | n => cur :: split_by f m (skipn n s) []
                end
    end
  end.
Definition lit_match (t : chars) (s : chars) : nat := if prefix t s then length t else 0.

(*! R L1.lang.tokenize.pairs FIX [CJt.28, CJt.32, SE.587, SE.596-600] *)
(** With an end token, the parts are the texts between a start token and the next end token ("start/end token
    pairs" [CJt.28, SE.587, SE.600]); text outside the pairs is not a part; [includeTokens] keeps the two tokens
    in each part [CJt.32]. UNSPECIFIED: an end token outside a pair, a start token without an end token after it, a
    start token inside a pair, start and end tokens that overlap, an empty part, no pair at all. FIX 2026-10-26: an
    end token outside a pair was taken as text outside the pairs (the docs do not say). *)
Fixpoint pairs (fuel : nat) (t e s : chars) (incl : bool) : list chars + string :=
  match fuel with
  | O => inr "TK: pairs: fuel"
  | S f =>
    match find t s with
    | None => if occurs e s then inr "TK: an end token outside a pair" else inl []
    | Some i =>
      if occurs e (firstn i s) then inr "TK: an end token outside a pair" else
      let after := skipn (i + length t) s in
      match find e after with
      | None => inr "TK: a start token without an end token"
      | Some j =>
        let content := firstn j after in
        if occurs t content then inr "TK: a start token inside a pair"
        else match pairs f t e (skipn (j + length e) after) incl with
             | inl ps => inl ((if incl then t ++ content ++ e else content) :: ps)
             | inr w => inr w
             end
      end
    end
  end.

Fixpoint chunks (fuel n : nat) (l : list chars) : list (list chars) :=
  match fuel with
  | O => [l]
  | S f => match l with [] => [] | _ => firstn n l :: chunks f n (skipn n l) end
  end.

(*! R L1.lang.tokenize.source DOC [CJt.19, CJt.36] *)
(** The input: the message body, or the [source] [CJt.36]: [variable:], [header:] or [property:] and a name, a bare
    name being a variable; empty means the body. Text is tokenized as it is; another body "is tokenized as its
    toString()" and "fails with endToken or xml" [CJt.19]. UNSPECIFIED: a null input; a list (its toString() depends
    on the List class); a [header:] source missing as a header but present as a property (does the header
    language's fallback apply?). *)
Definition tk_input (x : lenv) (o : tkopts) : val + string :=
  let byvar := fun n => match exlookup "VA" n (le_vars x) with Found v => inl v | Absent => inl VNull | Amb w => inr w end in
  match tk_source o with
  | None | Some [] => inl (le_body x)
  | Some s =>
    if prefix (str "variable:") s then byvar (skipn 9 s)
    else if prefix (str "header:") s then
      let n := skipn 7 s in
      match cilookup n (le_headers x) with
      | Found v => inl v
      | Amb w => inr w
      | Absent => match exlookup "XP" n (le_xprops x) with
                  | Absent => inl VNull
                  | _ => inr "TK: a header: source missing as a header but present as a property"
                  end
      end
    else if prefix (str "property:") s then
      match exlookup "XP" (skipn 9 s) (le_xprops x) with Found v => inl v | Absent => inl VNull | Amb w => inr w end
    else if occurs (str ":") s then inr "TK: a source with a colon and an unknown kind"
    else byvar s
  end.

(*! R L1.lang.tokenize.nullbody MAINTAINER [fac55782529b CAMEL-25043] *)
(** A null body: no tokens. The docs are silent; MAINTAINER 2026-10-26: commit fac55782529b (CAMEL-25043, signed off
    by Claus Ibsen) states "a message without a body has no tokens instead of failing with a NullPointerException".
    Real Camel follows it in plain and regex mode; in pair mode a null body still fails (InvalidPayloadException):
    code-bug candidate, findings/2026-10-26-tokenize-token-always-regex.md (section 3). *)
(*! R L1.lang.tokenize.sametoken CODE [fac55782529b CAMEL-25043] *)
(** The same start and end token: refused (IllegalArgumentException) when the expression is created. The docs are
    silent; CODE 2026-10-26 from fac55782529b (CAMEL-25043, "a pair with the same start and end token is refused when
    the route is created"), TokenPairExpressionIterator. *)
(*! R L1.lang.tokenize DOC [TK.12-21, TK.33-81, CJt.20, CJt.27-36, SE.29-35, SE.475, SE.876-933, SE.955] *)
(** The parts of the text between the tokens, an iterator of texts [CJt.20], here the list it walks: [a,b,c] split
    by [,] [SE.475]. [regex]: the token is a regular expression [CJt.30]. [group N]: each N parts joined into one
    text [CJt.20, CJt.33], with [groupDelimiter], or the token when it is not set [CJt.34, SE.927-928], N a
    positive number [SE.927]; the last group holds what is left (splitting "big files into chunks of 1000 lines"
    [CJt.33, SE.879] loses no line). [skipFirst]: the very first part is dropped [CJt.35]. Out of scope: [xml] and
    [inheritNamespaceTagName] (XML mode [TK.16-21, SE.596-736]). UNSPECIFIED: an empty part (two tokens in a row, a
    token at an end, an empty text); [includeTokens] without an end token [CJt.32] ("must"); [regex] with an end
    token; [group] with pairs, with [skipFirst], with [regex] and no delimiter, or not a positive number; and
    [resultType] (pending L0/Convert.v). *)
Definition ev_tokenize (x : lenv) (o : tkopts) (rtype : option chars) : lres :=
  match rtype with Some _ => LUns "TK: resultType needs type conversion (pending L0/Convert.v)" | None =>
  if tk_xml o then LUns "out of scope: tokenize xml mode"
  else match tk_inherit o with Some _ => LUns "out of scope: tokenize inheritNamespaceTagName (XML)" | None =>
  match tk_input x o with inr w => LUns w | inl v =>
  match v with
  | VNull => if (match tk_source o with None | Some [] => true | _ => false end) && negb (tk_xml o)
             then LV (VList [])
             else LUns "TK: tokenizing a null input"
  | VList _ => LUns "TK: the toString() of a List input"
  | _ =>
  match text_of v with None => LUns "TK: input text" | Some s =>
  if negb (match v with VStr _ => true | _ => false end) && match tk_end o with Some _ => true | None => false end
  then LErr []
  else
  let pairmode := match tk_end o with Some _ => true | None => false end in
  match tok_text "token" pairmode (tk_token o) with inr w => LUns w | inl t =>
  let grp : option nat + string :=
    match tk_group o with
    | None => inl None
    | Some g => if occurs (str "${") g then inr "TK: simple language in group"
                else if all_digits g then (let n := Z.to_nat (digits_val g 0) in
                                           if Nat.ltb 0 n then inl (Some n) else inr "SE: group must be a positive number")
                else inr "SE: group must be a positive number" end in
  match grp with inr w => LUns w | inl grp =>
  let parts : list chars + string :=
    match tk_end o with
    | Some e =>
      if tk_regex o then inr "TK: regex with an end token"
      else match tok_text "endToken" true e with
           | inr w => inr w
           | inl e' =>
             if ceqs t e' then inr "!IllegalArgumentException"
             else if occurs t e' || occurs e' t then inr "TK: start and end tokens that overlap"
             else match grp with
                  | Some _ => inr "TK: group with start/end pairs"
                  | None => match pairs (S (length s)) t e' s (tk_incl o) with
                            | inl [] => inr "TK: no start/end pair in the text"
                            | inl ps => if existsb (fun p => Nat.eqb (length p) 0) ps then inr "TK: an empty part" else inl ps
                            | inr w => inr w
                            end
                  end
           end
    | None =>
      if tk_incl o then inr "TK: includeTokens without an end token (must be configured [CJt.32])"
      else
      let ps := if tk_regex o then match parse_re t with
                                   | Some a => inl (split_by (S (length s)) (ra_len a) s [])
                                   | None => inr "out of scope: a regex pattern outside the model's small regex language"
                                   end
                else inl (split_by (S (length s)) (lit_match t) s []) in
      match ps with
      | inl ps => if existsb (fun p => Nat.eqb (length p) 0) ps then inr "TK: an empty part" else inl ps
      | inr w => inr w
      end
    end in
  match parts with
  | inr "!IllegalArgumentException" => LErr (str "IllegalArgumentException")
  | inr w => LUns w
  | inl ps =>
  match grp with
  | None => LV (VList (if tk_skip o then tl ps else ps))
  | Some n =>
    if tk_skip o then LUns "TK: skipFirst with group (the first part or the first group?)"
    else
    let d : chars + string := match tk_gdelim o with
             | Some d => if occurs [bsl] d || occurs (str "${") d || occurs (str "{{") d
                         then inr "TK: a backslash, ${ } or {{ }} in groupDelimiter" else inl d
             | None => if tk_regex o then inr "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                       else inl t end in
    match d with inr w => LUns w | inl d =>
      LV (VList (map (concat_with d) (chunks (S (length ps)) n ps)))
    end
  end end end end end end end end end.

(** ** 6. Expressions and predicates *)

Inductive lexp : Type :=
| XConstant (text : chars) (rtype : option chars) (trim_on : bool)
| XHeader (name : chars) (trim_on : bool)
| XProp (name : chars) (trim_on : bool)
| XVar (name : chars) (trim_on : bool)
| XRef (name : chars) (rtype : option chars) (trim_on : bool)
| XTokenize (o : tkopts) (rtype : option chars).

Definition eval (x : lenv) (e : lexp) : lres :=
  match e with
  | XConstant t r tr => ev_constant x t r tr
  | XHeader n tr => ev_header x n tr
  | XProp n tr => ev_prop x n tr
  | XVar n tr => ev_var x n tr
  | XRef n r tr => ev_ref x n r tr false
  | XTokenize o r => ev_tokenize x o r
  end.

(*! R L1.lang.predicates DOC [PR.37-38, R.12-13, CJr.20] *)
(** As predicates: ref looks up an expression or a predicate [R.12-13]; header, exchangeProperty, variable and
    constant values are read through [as_pred]. Tokenize as a predicate: UNSPECIFIED (not documented). *)
Definition evalp (x : lenv) (e : lexp) : lres :=
  match e with
  | XRef n r tr => ev_ref x n r tr true
  | XTokenize _ _ => LUns "TK: tokenize as a predicate"
  | _ => as_pred (eval x e)
  end.

(** ** 7. The documented examples (checked by [vm_compute]) *)

Definition Sv (s : string) : val := VStr (str s).
Definition L (l : list string) : val := VList (map str l).
Definition hx (body : val) (hs ps vs : list (string * val)) : lenv :=
  mkLE body (map (fun '(k, v) => (str k, v)) hs) (map (fun '(k, v) => (str k, v)) ps)
       (map (fun '(k, v) => (str k, v)) vs) [] [] [] (penv0 []).
Definition nls (l : list string) : chars := concat_with [nl] (map str l).

(** [C.30-78]: [constant("the value")] is the String [the value]. *)
Example doc_constant : eval (lenv0 VNull) (XConstant (str "the value") None true) = LV (Sv "the value").
Proof. vm_compute. reflexivity. Qed.
(** [C.80-128]: [resultType="int"] is not reproduced: UNSPECIFIED pending L0/Convert.v. *)
Example doc_constant_resulttype_pending :
  exists w, eval (lenv0 VNull) (XConstant (str "90210") (Some (str "int")) true) = LUns w.
Proof. eexists. vm_compute. reflexivity. Qed.
(** [PP.380-423]: [constant("{{myQuery?nested=false}}")] gives the JSON query as it is. *)
Example doc_constant_placeholder :
  let x := mkLE VNull [] [] [] [] [] [] (penv0 [(str "myQuery", str "{""query"":{""match_all"":{}}}")]) in
  eval x (XConstant (str "{{myQuery?nested=false}}") None true) = LV (Sv "{""query"":{""match_all"":{}}}").
Proof. vm_compute. reflexivity. Qed.
(** [H.30-63]: [recipientList(header("myHeader"))]: the recipients are the header's value; the name is
    case-insensitive [MJ.42]. *)
Example doc_header :
  let x := hx VNull [("myHeader", Sv "mock:a,mock:b")] [] [] in
  eval x (XHeader (str "myHeader") true) = LV (Sv "mock:a,mock:b") /\
  eval x (XHeader (str "MYHEADER") true) = LV (Sv "mock:a,mock:b").
Proof. vm_compute. split; reflexivity. Qed.
(** [CJh.19]: a missing header falls back to the exchange property; null when there is neither. *)
Example doc_header_fallback :
  eval (hx VNull [] [("p", Sv "v")] []) (XHeader (str "p") true) = LV (Sv "v") /\
  eval (hx VNull [] [] []) (XHeader (str "p") true) = LV VNull.
Proof. vm_compute. split; reflexivity. Qed.
(** [XP.30-63]: [exchangeProperty("myProperty")]. *)
Example doc_property :
  eval (hx VNull [] [("myProperty", L ["mock:a"; "mock:b"])] []) (XProp (str "myProperty") true) = LV (L ["mock:a"; "mock:b"]).
Proof. vm_compute. reflexivity. Qed.
(** [V.30-63]: [variable("myVar")]; [VA.55-60]: [global:myGlobalKey]; [VA.97-112]: [group:teamA:myKey]. *)
Example doc_variable :
  eval (hx VNull [] [] [("myVar", Sv "mock:a")]) (XVar (str "myVar") true) = LV (Sv "mock:a") /\
  eval (mkLE VNull [] [] [] [(str "myGlobalKey", Sv "g")] [] [] (penv0 [])) (XVar (str "global:myGlobalKey") true) = LV (Sv "g") /\
  eval (mkLE VNull [] [] [] [] [(str "teamA", [(str "myKey", Sv "t")])] [] (penv0 [])) (XVar (str "group:teamA:myKey") true) = LV (Sv "t").
Proof. vm_compute. repeat split. Qed.
(** [R.23-74]: [ref("myExpression")] uses the registered expression. *)
Example doc_ref :
  let x := mkLE VNull [] [] [] [] [] [(str "myExpression", RgExpr (L ["a"; "b"]))] (penv0 []) in
  eval x (XRef (str "myExpression") None true) = LV (L ["a"; "b"]).
Proof. vm_compute. reflexivity. Qed.
(** [TK.33-81, SE.29-35]: [tokenize("\n")] splits into lines; in XML the token is written [\n] [TK.59]. *)
Example doc_tokenize_lines :
  eval (lenv0 (VStr (nls ["a"; "b"; "c"]))) (XTokenize (mkTK [nl] None false false false None None false None None) None)
  = LV (L ["a"; "b"; "c"]) /\
  eval (lenv0 (VStr (nls ["a"; "b"; "c"]))) (XTokenize (tk "\n") None) = LV (L ["a"; "b"; "c"]).
Proof. vm_compute. split; reflexivity. Qed.
(** [SE.475, SE.955]: [tokenize(",")] and [tokenize("@")]. *)
Example doc_tokenize_comma :
  eval (lenv0 (Sv "A,B,C")) (XTokenize (tk ",") None) = LV (L ["A"; "B"; "C"]) /\
  eval (lenv0 (Sv "x@y")) (XTokenize (tk "@") None) = LV (L ["x"; "y"]).
Proof. vm_compute. split; reflexivity. Qed.
(** [SE.876-933]: [tokenize("\n", 1000)]: chunks of up to 1000 lines joined by the token, each a String; here 3
    lines, and group 2 for 3 lines. *)
Example doc_tokenize_group :
  let o := fun g => mkTK [nl] None false false false (Some (str g)) None false None None in
  eval (lenv0 (VStr (nls ["l1"; "l2"; "l3"]))) (XTokenize (o "1000") None) = LV (VList [nls ["l1"; "l2"; "l3"]]) /\
  eval (lenv0 (VStr (nls ["l1"; "l2"; "l3"]))) (XTokenize (o "2") None) = LV (VList [nls ["l1"; "l2"]; str "l3"]).
Proof. vm_compute. split; reflexivity. Qed.
(** [SE.596-600, CJt.28, CJt.32]: start/end pairs, with and without the tokens. *)
Example doc_tokenize_pairs :
  let o := fun i => mkTK (str "<a>") (Some (str "</a>")) false false i None None false None None in
  eval (lenv0 (Sv "<r><a>1</a><a>2</a></r>")) (XTokenize (o false) None) = LV (L ["1"; "2"]) /\
  eval (lenv0 (Sv "<r><a>1</a><a>2</a></r>")) (XTokenize (o true) None) = LV (L ["<a>1</a>"; "<a>2</a>"]).
Proof. vm_compute. split; reflexivity. Qed.
