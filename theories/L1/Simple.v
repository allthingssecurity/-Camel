(** * L1 Simple: a readable semantics of Camel's Simple language, written from the documentation only.

    "Ship your interpreters", step 1 (ossfuzz-track/SHIP-SIMPLE-BRIEF.md). The rules below are written from the
    Simple documentation of apache/camel aa63c0a4cb94, not from the code:
      [L] core/camel-core-languages/src/main/docs/modules/languages/pages/simple-language.adoc
      [F] .../simple-functions.adoc       [O] .../simple-operators.adoc
      [A] .../simple-advanced.adoc        [G] .../simple-ognl.adoc
    Every rule names the lines it comes from as [X.n] (line n of page X). Where the documentation is silent, or
    contradicts itself, the rule answers [RUns "why"] (UNSPECIFIED): we do not guess. The differential harness
    (ossfuzz-track/ship-simple) runs the extracted [run] on generated programs and compares with Camel; a program the
    rules call UNSPECIFIED is counted, never compared.

    Scope: templates (text and functions), the core value functions, a set of string/condition functions, the
    comparison operators of [O.47-78] on every pair of value kinds, [&&]/[||], [!], predicates inside and outside
    [${ }], the ternary, elvis and chain operators, the unary [++]/[--], typed prefixes, quoting and the escapes of
    [F.1206-1219]. Not in scope: OGNL method calls (they need camel-bean [G.27-30]), dates, beans, JSON/XML, files.

    Ported from rocq-jvm-threads/theories/Ship/SimpleSpec.v (sha256 ef2550af5018); the pin is the same commit, so the
    citations [X.n] are lines of docs/core/camel-core-languages/src/main/docs/modules/languages/pages/ here. Sections
    1-3 moved to Common/Text.v and L0/Value.v. Changes after the port are listed in CHANGELOG.md. *)
From Stdlib Require Import ZArith String Ascii List Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value.
From CamelSpec.L0 Require Exchange.

Record exch : Type := mkEx {
  ex_body : val;
  ex_headers : list (chars * val);
  ex_props : list (chars * val);
  ex_vars : list (chars * val) }.
Fixpoint lookup (k : chars) (l : list (chars * val)) : val :=
  match l with [] => VNull | (k', v) :: l' => if ceqs k k' then v else lookup k l' end.
Definition with_body (x : exch) (v : val) : exch := mkEx v (ex_headers x) (ex_props x) (ex_vars x).

(** Results. [RLoose s]: only the text of the result is documented, not its Java type (for example a number
    written as a ternary value [O.174]). [RErr]: the documentation says the program is refused or fails. *)
Inductive res : Type :=
| RV (v : val)
| RLoose (s : chars)
| RErr
| RUns (why : string).
Definition bind (r : res) (k : val -> res) : res :=
  match r with RV v => k v | RLoose _ => RUns "loose value used" | RErr => RErr | RUns w => RUns w end.
(** A value used as text (string functions convert their input to a String [F.514]). *)
Definition bind_text (r : res) (k : chars -> res) : res :=
  match r with
  | RV v => match text_of v with Some s => k s | None => RUns "text of null or list" end
  | RLoose s => k s
  | RErr => RErr
  | RUns w => RUns w
  end.

(** ** 4. Programs (the abstract syntax the generator builds) and their concrete text *)

(** Literals. [LQ s]: a single-quoted literal whose source text is [s] [O.18-19]; [LBare s]: a bare word (function
    arguments such as [contains(world)] [F.346], [val(abc)] [F.142]; ranges [O.427]). *)
Inductive lit : Type :=
| LQ (s : chars)
| LNum (z : Z)
| LNull
| LTrue
| LFalse
| LBare (s : chars).

(** The comparison operators of [O.47-78], spelled as there. *)
Inductive binop : Type :=
| OEq | ONe | OEqIc | ONeIc | OGt | OGe | OLt | OLe | OCIc | ONCIc | OContains | ONContains
| OEnds | ONEnds | OEquals | ONEquals | OIn | ONIn | OIs | ONIs | ORange | ONRange | ORegex | ONRegex
| OStarts | ONStarts.
Definition opstr (o : binop) : chars := str
  match o with
  | OEq => "==" | ONe => "!=" | OEqIc => "=~" | ONeIc => "!=~" | OGt => ">" | OGe => ">=" | OLt => "<"
  | OLe => "<=" | OCIc => "~~" | ONCIc => "!~~" | OContains => "contains" | ONContains => "!contains"
  | OEnds => "endsWith" | ONEnds => "!endsWith" | OEquals => "equals" | ONEquals => "!equals" | OIn => "in"
  | ONIn => "!in" | OIs => "is" | ONIs => "!is" | ORange => "range" | ONRange => "!range" | ORegex => "regex"
  | ONRegex => "!regex" | OStarts => "startsWith" | ONStarts => "!startsWith"
  end.

Inductive lop : Type := LAnd | LOr.

Inductive fn : Type :=
| FBody                               (* body [F.51, F.113] *)
| FHeader (sty : nat) (k : chars)     (* 0 header.k [F.68], 1 header[k] [F.70], 2 headers.k [F.73],
                                         3 headers:k [F.75], 4 headers[k] [F.76] *)
| FProp (sty : nat) (k : chars)       (* 0 exchangeProperty.k, 1 exchangeProperty:k, 2 exchangeProperty[k] [F.132-133] *)
| FVar (k : chars)                    (* variable.k [F.102] *)
| FNull                               (* null [F.463, F.484] *)
| FHeadersSize                        (* headers.size [F.74, F.213] *)
| FTyped (t : nat) (f : fn)           (* 0 int: 1 integer: 2 long: 3 boolean: 4 string: [F.20-30] *)
| FCall (name : chars) (sp : bool) (a : args)  (* name(arg,arg) or name(arg, arg) [F.10] *)
| FPred (p : pseq)                    (* a predicate inside the braces [O.29-40] *)
| FTern (c : pseq) (t : tval) (e : tval)  (* c ? t : e [O.140-186] *)
with args : Type := ANil | ACons (a : arg) (r : args)
with arg : Type := AFn (f : fn) | ALit (l : lit) | APred (p : pseq)
with tval : Type := TVLit (l : lit) | TVFn (f : fn)
with atom : Type :=
| ACmp (l : lhs) (op : binop) (r : rhs)
| ANot (f : fn)                       (* !${f}, inside the braces !f [O.255-294] *)
| AFun (f : fn)                       (* a function alone, as a predicate [O.275-276] *)
| ANot2 (f : fn)                      (* !!${f}, inside the braces !!f [O.293-294] *)
with lhs : Type := LFn (f : fn) | LInc (f : fn) | LDecr (f : fn) | LNotFn (f : fn)  (* !${f} OP r [O.289] *)
with rhs : Type := RLit (l : lit) | RFn (f : fn) | RNot (f : fn)                    (* OP !${f} [O.292] *)
with pseq : Type := PS (a : atom) (rest : prest)
with prest : Type := PNil | PCons (o : lop) (a : atom) (r : prest).

Inductive part : Type :=
| TText (s : chars)                   (* template text: source text, copied as-is [O.156-165] *)
| TFn (alt : bool) (f : fn)           (* ${f}, or $simple{f} when alt [L.29-31] *)
| TPost (f : fn) (inc : bool).        (* ${f}++ / ${f}-- [O.92-122] *)

Inductive prog : Type :=
| PExpr (t : list part)               (* evaluated as an expression *)
| PPred (p : pseq)                    (* evaluated as a predicate, operators between the functions [O.29-37] *)
| PElvis (f : fn) (d : lit)           (* ${f} ?: d [O.133, O.189-197] *)
| PChain (nullsafe : bool) (f : fn) (fs : list fn).  (* ${f} ~> ${g} ... [O.134-135, O.199-224] *)

(** Concrete text. *)
Definition dq : chars := str "${".
Definition rlit (l : lit) : chars :=
  match l with
  | LQ s => "'"%char :: s ++ ["'"%char]
  | LNum z => ztext z
  | LNull => str "null" | LTrue => str "true" | LFalse => str "false"
  | LBare s => s
  end.
Definition typed_prefix (t : nat) : chars :=
  str match t with 0 => "int:" | 1 => "integer:" | 2 => "long:" | 3 => "boolean:" | _ => "string:" end.

Fixpoint rfn (f : fn) : chars :=
  match f with
  | FBody => str "body"
  | FHeader sty k =>
      match sty with
      | 0 => str "header." ++ k | 1 => str "header[" ++ k ++ str "]" | 2 => str "headers." ++ k
      | 3 => str "headers:" ++ k | _ => str "headers[" ++ k ++ str "]"
      end
  | FProp sty k =>
      match sty with
      | 0 => str "exchangeProperty." ++ k | 1 => str "exchangeProperty:" ++ k
      | _ => str "exchangeProperty[" ++ k ++ str "]"
      end
  | FVar k => str "variable." ++ k
  | FNull => str "null"
  | FHeadersSize => str "headers.size"
  | FTyped t g => typed_prefix t ++ rfn g
  | FCall n sp a => n ++ "("%char :: rargs sp a ++ [")"%char]
  | FPred p => rps true p
  | FTern c t e => rps true c ++ str " ? " ++ rtv t ++ str " : " ++ rtv e
  end
with rargs (sp : bool) (a : args) : chars :=
  match a with
  | ANil => []
  | ACons x ANil => rarg x
  | ACons x r => rarg x ++ (if sp then str ", " else str ",") ++ rargs sp r
  end
with rarg (a : arg) : chars :=
  match a with AFn f => dq ++ rfn f ++ str "}" | ALit l => rlit l | APred p => rps false p end
with rtv (t : tval) : chars := match t with TVLit l => rlit l | TVFn f => dq ++ rfn f ++ str "}" end
with ratom (inb : bool) (a : atom) : chars :=
  match a with
  | ACmp l o r => rlhs inb l ++ " "%char :: opstr o ++ " "%char :: rrhs r
  | ANot f => if inb then "!"%char :: rfn f else str "!${" ++ rfn f ++ str "}"
  | AFun f => if inb then rfn f else dq ++ rfn f ++ str "}"
  | ANot2 f => if inb then str "!!" ++ rfn f else str "!!${" ++ rfn f ++ str "}"
  end
with rlhs (inb : bool) (l : lhs) : chars :=
  match l with
  | LFn f => if inb then rfn f else dq ++ rfn f ++ str "}"
  | LInc f => (if inb then rfn f else dq ++ rfn f ++ str "}") ++ str "++"
  | LDecr f => (if inb then rfn f else dq ++ rfn f ++ str "}") ++ str "--"
  | LNotFn f => if inb then "!"%char :: rfn f else str "!${" ++ rfn f ++ str "}"
  end
with rrhs (r : rhs) : chars :=
  match r with RLit l => rlit l | RFn f => dq ++ rfn f ++ str "}" | RNot f => str "!${" ++ rfn f ++ str "}" end
with rps (inb : bool) (p : pseq) : chars := match p with PS a r => ratom inb a ++ rprest inb r end
with rprest (inb : bool) (r : prest) : chars :=
  match r with
  | PNil => []
  | PCons o a r' => (match o with LAnd => str " && " | LOr => str " || " end) ++ ratom inb a ++ rprest inb r'
  end.

Definition rpart (p : part) : chars :=
  match p with
  | TText s => s
  | TFn alt f => (if alt then str "$simple{" else dq) ++ rfn f ++ str "}"
  | TPost f inc => dq ++ rfn f ++ str "}" ++ (if inc then str "++" else str "--")
  end.
Definition render (p : prog) : chars :=
  match p with
  | PExpr t => concat (map rpart t)
  | PPred q => rps false q
  | PElvis f d => dq ++ rfn f ++ str "} ?: " ++ rlit d
  | PChain ns f fs =>
      dq ++ rfn f ++ str "}" ++ concat (map (fun g => (if ns then str " ?~> " else str " ~> ") ++ dq ++ rfn g ++ str "}") fs)
  end.
Definition is_predicate (p : prog) : bool := match p with PPred _ => true | _ => false end.

(** ** 5. Source text: the escapes and what a literal may contain *)

(** Built-in symbols [F.1206-1219], also in template text [A.126-136]: [\n], [\t], [\r] and [\}] stand for LF,
    TAB, CR and [}]. Another backslash pair is kept as written: the regex example [O.380-385] writes [\d] in the
    text and means the regex [\d]. A backslash at the very end is UNSPECIFIED. [infn]: inside [${ }], where a
    raw [}] or [{] is UNSPECIFIED ([\}] "may be needed" [F.1216]); in template text both are text, as in the data
    mapping examples [F.723-728] and [A.75-78]. A [$] is UNSPECIFIED anywhere outside the generated functions
    ([$name] is the init-block variable shorthand [A.64-65]). *)
Fixpoint unesc (infn : bool) (s : chars) : option chars :=
  match s with
  | [] => Some []
  | c :: s' =>
      if ceq c "\"%char then
        match s' with
        | [] => None
        | d :: s'' =>
            let k := match code d with
                     | 110 => Some [ascii_of_nat 10] | 116 => Some [ascii_of_nat 9] | 114 => Some [ascii_of_nat 13]
                     | 125 => Some ["}"%char]
                     | 92 => None   (* REFINED: a doubled backslash is not documented (Camel: a backslash, then the next escape) *)
                     | 36 => None   (* a [$] after a backslash: as any [$], UNSPECIFIED *)
                     | _ => Some [c; d] end in
            match k, unesc infn s'' with Some a, Some b => Some (a ++ b) | _, _ => None end
        end
      else if ceq c "$"%char then None
      else if infn && (ceq c "}"%char || ceq c "{"%char) then None
      else match unesc infn s' with Some b => Some (c :: b) | None => None end
  end.

(** What a quoted literal may hold. Inside a function's argument list a comma, a parenthesis or a quote of either
    kind inside the quotes is UNSPECIFIED (the docs only say arguments are separated by comma [F.10]; the replace
    section [A.37-40] says quotes inside quotes are to be avoided). On the right of an operator a literal is "a
    string literal enclosed in ' '" [O.18-19]: anything but the single quote. *)
Definition arg_lit_ok (s : chars) : bool :=
  negb (existsb (fun c => ceq c ","%char || ceq c "("%char || ceq c ")"%char || ceq c "'"%char
                           || ceq c (ascii_of_nat 34)) s).
Definition q_value (infn : bool) (s : chars) : res :=
  if existsb (fun c => ceq c "'"%char) s then RUns "quote inside a quoted literal"
  (* REFINED (MINOR-1): outside [${ }], Camel does not process the escapes of [F.1206-1219] in a quoted operand
     (a backslash pair is compared as written), while inside the braces and in template text it does *)
  else if negb infn && occurs ["\"%char] s then RUns "MINOR: escape in a quoted operand outside ${ } is not processed"
  else match unesc infn s with Some v => RV (VStr v) | None => RUns "escape, $ or brace in a literal" end.

(** ** 6. Functions *)

(** The three XML escapes of the replace function [F.530-531, A.37-99]. *)
Definition xml_ents (s : chars) : chars :=
  replace_all (str "&empty;") [] (replace_all (str "&apos;") ["'"%char] (replace_all (str "&quot;") [ascii_of_nat 34] s)).

(** [capitalize]: "upper case every words", "upper-casing the first letter in every words" [F.519-520, F.553-554].
    Defined for words of lower-case letters separated by single spaces. *)
Definition capitalize (s : chars) : res :=
  let ws := split_on " "%char s in
  if existsb (fun w => match w with [] => true | _ => negb (forallb is_lower w) end) ws then RUns "capitalize: not lower-case words"
  else RV (VStr (concat_with [" "%char] (map (fun w => match w with c :: r => upc c :: r | [] => [] end) ws))).

(** [normalizeWhitespace]: exactly one white space between words, trimmed [F.527-528, F.591-593]. Defined when
    the white space is spaces only. *)
Definition normalize_ws (s : chars) : res :=
  if existsb (fun c => is_ws c && negb (ceq c " "%char)) s then RUns "normalizeWhitespace: tab or line break"
  else RV (VStr (concat_with [" "%char] (filter (fun w => match w with [] => false | _ => true end) (split_on " "%char s)))).

(** [quote]: "as a double-quoted string"; "If the value is currently in single quote, then this will be converted
    to double quotes"; no escaping [F.547-548, F.640-647]. A value that already has a double quote at an end is
    UNSPECIFIED. *)
Definition dquote : ascii := ascii_of_nat 34.
Definition quote_f (s : chars) : res :=
  match s with
  | c :: r => if ceq c "'"%char && suffix ["'"%char] r then RV (VStr (dquote :: removelast r ++ [dquote]))
              else if ceq c dquote || suffix [dquote] s then RUns "quote: already double quoted"
              else RV (VStr (dquote :: s ++ [dquote]))
  | [] => RV (VStr [dquote; dquote])
  end.
(** [unquote]: "removes any surrounding single or double quotes" [F.545-546, F.648-649]. *)
Definition unquote_f (s : chars) : res :=
  match s with
  | c :: (_ :: _) as r =>
      if (ceq c "'"%char && suffix ["'"%char] r) || (ceq c dquote && suffix [dquote] r) then RV (VStr (removelast r))
      else if ceq c "'"%char || ceq c dquote || suffix ["'"%char] s || suffix [dquote] s then RUns "unquote: one-sided"
      else RV (VStr s)
  | [c] => if ceq c "'"%char || ceq c dquote then RUns "unquote: lone quote" else RV (VStr s)
  | [] => RV (VStr [])
  end.

(** [substring]: numbers are how many characters to clip [F.534-536, F.606-610]; "If the number is higher than
    the length ... an empty string is returned" [A.23]. A negative clip longer than the text, a negative first
    number of the two-number form, and clips that together exceed the text are UNSPECIFIED. *)
Definition substring1 (n : Z) (s : chars) : res :=
  let len := Z.of_nat (length s) in
  if Z.leb 0 n then (if Z.leb len n then RV (VStr []) else RV (VStr (skipn (Z.to_nat n) s)))
  else if Z.leb (Z.opp n) len then RV (VStr (firstn (Z.to_nat (len + n)) s))
  else RUns "substring: negative clip longer than the text".
Definition substring2 (n1 n2 : Z) (s : chars) : res :=
  let len := Z.of_nat (length s) in
  if Z.ltb n1 0 then RUns "substring: negative first number"
  else if Z.ltb len (n1 + Z.abs n2) then RUns "substring: clips exceed the text"
  else RV (VStr (firstn (Z.to_nat (len - n1 - Z.abs n2)) (skipn (Z.to_nat n1) s))).

(** [substringBefore]/[After]/[Between] [F.537-542, F.621-629]: "Returns null if nothing comes before / after /
    between". Defined when the marker occurs exactly once (which occurrence is meant is not said) and is not
    empty; a marker that does not occur is UNSPECIFIED. *)
Definition sub_before (b s : chars) : res :=
  match b with [] => RUns "empty marker" | _ =>
  if negb (Nat.eqb (count_occ b s) 1) then RUns "marker not exactly once"
  else match find b s with Some 0 => RUns "DOC: nothing before: empty text, not null" | Some i => RV (VStr (firstn i s)) | None => RUns "not found" end end.
Definition sub_after (a s : chars) : res :=
  match a with [] => RUns "empty marker" | _ =>
  if negb (Nat.eqb (count_occ a s) 1) then RUns "marker not exactly once"
  else match find a s with
       | Some i => match skipn (i + length a) s with [] => RUns "DOC: nothing after: empty text, not null" | r => RV (VStr r) end
       | None => RUns "not found" end end.
Definition sub_between (a b s : chars) : res :=
  match a, b with [], _ | _, [] => RUns "empty marker" | _, _ =>
  if negb (Nat.eqb (count_occ a s) 1) then RUns "marker not exactly once"
  else match find a s with
       | Some i => let r := skipn (i + length a) s in
                   if negb (Nat.eqb (count_occ b r) 1) then RUns "second marker not exactly once after the first"
                   else match find b r with Some 0 => RUns "DOC: nothing between: empty text, not null" | Some j => RV (VStr (firstn j r)) | None => RUns "not found" end
       | None => RUns "not found" end end.

(** [pad(exp,width,separator)] [F.529, F.595-598]: total at least |width| characters; positive pads after, negative
    before; one padding character (several are UNSPECIFIED: how a partial repeat ends is not said). *)
Definition pad_f (s : chars) (w : Z) (sep : chars) : res :=
  match sep with
  | [c] => let need := Z.to_nat (Z.abs w) - length s in
           if Z.leb 0 w then RV (VStr (s ++ repeat_c c need)) else RV (VStr (repeat_c c need ++ s))
  | _ => RUns "pad: separator of several characters"
  end.

(** [escape(kind,exp)] [F.522-523, F.567-582]. xml: the five predefined entities; sql: single quotes doubled;
    html: [&], [<], [>] and the double quote as entities ([F.573] example), the entity of ['] is not given (UNSPECIFIED); json: quotes and
    backslashes backslash-escaped (control characters UNSPECIFIED); url: RFC 3986 percent-encoding, a space becomes
    [%20]: the unreserved characters [A-Za-z0-9-._~] are kept (RFC 3986 2.3), characters outside the unreserved
    and reserved sets are encoded (upper-case hex, RFC 3986 2.1); a reserved character is UNSPECIFIED (whether
    it is encoded depends on where the value goes). The kind is case-insensitive, and [javascript] = [js]
    ([F.582]); js is UNSPECIFIED beyond json (the escaped forms of ['] and [</] are not given). *)
Definition hexd (n : nat) : ascii := if Nat.ltb n 10 then ascii_of_nat (48 + n) else ascii_of_nat (55 + n).
Definition is_unreserved (c : ascii) : bool :=
  is_letter c || is_digit c || ceq c "-"%char || ceq c "."%char || ceq c "_"%char || ceq c "~"%char.
Definition is_reserved (c : ascii) : bool :=
  existsb (fun d => ceq c d) (str ":/?#[]@!$&'()*+,;=").
Fixpoint esc_map (f : ascii -> option chars) (s : chars) : option chars :=
  match s with
  | [] => Some []
  | c :: s' => match f c, esc_map f s' with Some a, Some b => Some (a ++ b) | _, _ => None end
  end.
Definition esc_xml (c : ascii) : option chars :=
  Some (match code c with 38 => str "&amp;" | 60 => str "&lt;" | 62 => str "&gt;" | 34 => str "&quot;"
                     | 39 => str "&apos;" | _ => [c] end).
Definition esc_html (c : ascii) : option chars :=
  match code c with 38 => Some (str "&amp;") | 60 => Some (str "&lt;") | 62 => Some (str "&gt;")
                  | 34 => Some (str "&quot;") | 39 => None | _ => Some [c] end.
Definition esc_sql (c : ascii) : option chars := if ceq c "'"%char then Some (str "''") else Some [c].
Definition esc_json (c : ascii) : option chars :=
  if Nat.ltb (code c) 32 then None
  else if ceq c dquote then Some [ "\"%char; dquote ] else if ceq c "\"%char then Some (str "\\") else Some [c].
Definition esc_url (c : ascii) : option chars :=
  if is_unreserved c then Some [c] else if ceq c " "%char then Some (str "%20")
  else if is_reserved c then None
  else Some ["%"%char; hexd (code c / 16); hexd (code c mod 16)].
Definition escape_f (kind s : chars) : res :=
  let k := lower kind in
  let go f := match esc_map f s with Some r => RV (VStr r) | None => RUns "escape: form not documented" end in
  if ceqs k (str "xml") then go esc_xml else if ceqs k (str "html") then go esc_html
  else if ceqs k (str "sql") then go esc_sql else if ceqs k (str "json") then go esc_json
  else if ceqs k (str "url") then go esc_url else RUns "escape: other kind".

(** [isNumeric]/[isAlpha]/[isAlphaNumeric] [F.334-339, F.356-359]: every character a digit / letter / letter or
    digit ([Character.isDigit] etc.; the generator uses ASCII). The empty text is UNSPECIFIED. *)
Definition all_of (p : ascii -> bool) (s : chars) : res :=
  match s with [] => RUns "is*: empty text" | _ => RV (VBool (forallb p s)) end.

(** ** 7. Truth of a value *)

(** As a predicate [O.275-276]: "a value that is not null and not false is true, and null is false". The Strings
    "true"/"false" are UNSPECIFIED (is the text "false" the value false?). *)
Inductive bres : Type := BV (b : bool) | BErr | BUns (why : string).
Definition truth (v : val) : bres :=
  match v with
  | VNull => BV false
  | VBool b => BV b
  | VStr s => if ceqs (lower s) (str "true") || ceqs (lower s) (str "false") then BUns "truth of the text true/false"
              (* REFINED (DOC-1): Camel's rule (ObjectHelper.evaluateValuePredicate) also makes an empty or blank
                 text false; [O.275-276] does not say so *)
              else if blank s then BUns "DOC: truth of an empty or blank text"
              else BV true
  | VList [] => BUns "DOC: truth of an empty list"
  | _ => BV true
  end.
(** For elvis [O.133]: "an effective Boolean value of false (such as null, false, 0, empty/blank string)"; other
    values with no such list are UNSPECIFIED (the list is "such as"). *)
Definition elvis_truth (v : val) : bres :=
  match v with
  | VNull => BV false
  | VBool b => BV b
  | VInt z | VLong z => BV (negb (Z.eqb z 0))
  | VDbl q => BV (negb (Z.eqb q 0))
  | VStr s => if blank s then BV false
              else if ceqs s (str "0") || ceqs s (str "false") || ceqs s (str "true") then BUns "elvis truth of 0/true/false text"
              else BV true
  | VList _ => BUns "elvis truth of a list"
  end.

(** ** 8. Comparison of two values

    [O.23-25]: "Camel will automatically type convert the rightValue type to the leftValue type".
    [O.334-338]: "Camel will use the type from the left-hand side as first priority. And fallback to the right-hand
    side type if both values couldn't be compared based on that type."
    [O.80-83]: "When both sides of == are strings made up only of digits, they are compared as numbers"; [equals]
    always compares as text [O.66-67, O.83-90].
    [O.389-392] (in): "When the left-hand side is a number, each element is compared by its numeric value".
    [O.336-352]: a String on the left and a number on the right is compared as a String (the docs say so, and
    tell you to flip the sides to get the number type). *)

(** Converting a value to Boolean: the texts "true"/"false" only; other texts UNSPECIFIED. *)
Definition to_bool (v : val) : option (option bool) :=
  match v with
  | VBool b => Some (Some b)
  | VStr s => if ceqs s (str "true") then Some (Some true) else if ceqs s (str "false") then Some (Some false) else None
  | _ => Some None
  end.

(** [==]: None = UNSPECIFIED. *)
Definition eqv (l r : val) : option bool :=
  match l, r with
  | VNull, VNull => Some true
  | VNull, _ | _, VNull => Some false
  | VList _, _ | _, VList _ => None
  | VBool b, _ => match to_bool r with Some (Some c) => Some (Bool.eqb b c) | _ => None end
  | _, VBool c => match l with VStr s => Some (ceqs s (btext c)) | _ => None end
  | VStr s, VStr t => if all_digits s && all_digits t then Some (Z.eqb (digits_val s 0) (digits_val t 0)) else Some (ceqs s t)
  | VStr s, _ =>   (* number on the right: converted to a String (left type) *)
      match text_of r with
      | Some t => if all_digits s && all_digits t then Some (Z.eqb (digits_val s 0) (digits_val t 0)) else Some (ceqs s t)
      | None => None end
  | _, _ =>        (* number on the left *)
      match num_of l, num_of r with
      | Some a, Some b => Some (match qcmp a b with Eq => true | _ => false end)
      | Some _, None => Some false        (* the right is not a number: compared as text (fallback); never equal *)
      | _, _ => None end
  end.

(** Ordering ([< <= > >=]): None = UNSPECIFIED. *)
Definition ordv (l r : val) : option comparison :=
  match l, r with
  | VNull, _ | _, VNull | VList _, _ | _, VList _ | VBool _, _ | _, VBool _ => None
  | VStr s, _ => match text_of r with Some t => Some (scmp s t) | None => None end
  | _, _ => match num_of l, num_of r with
            | Some a, Some b => Some (qcmp a b)
            | Some _, None => match text_of l, text_of r with Some s, Some t => Some (scmp s t) | _, _ => None end
            | _, _ => None end
  end.

(** [in] [O.68-69, O.387-404]: a set of values separated by comma, "no space around"; an empty value needs a
    double comma. A single empty value (a leading, trailing or lone comma) and a value with a space at an end are
    UNSPECIFIED. *)
Fixpoint has_double_comma (s : chars) : bool :=
  match s with c :: ((d :: _) as s') => (ceq c ","%char && ceq d ","%char) || has_double_comma s' | _ => false end.
Definition set_items (s : chars) : option (list chars) :=
  let items := split_on ","%char s in
  let empties := filter (fun w => match w with [] => true | _ => false end) items in
  if existsb (fun w => match w with c :: _ => is_ws c || (match rev w with d :: _ => is_ws d | [] => false end) | [] => false end) items
  then None
  else match empties with
       | [] => Some items
       | _ => if has_double_comma s then Some items else None
       end.
Definition in_set (l : val) (s : chars) : option bool :=
  match set_items s with
  | None => None
  | Some items =>
      match l with
      | VNull | VList _ => None
      | VBool b => let conv := map (fun w => to_bool (VStr w)) items in
                   if existsb (fun o => match o with Some (Some _) => false | _ => true end) conv then None
                   else Some (existsb (fun o => match o with Some (Some c) => Bool.eqb b c | _ => false end) conv)
      | VStr t => if existsb (fun w => all_digits w) items && all_digits t then None  (* digits: == or text? *)
                  else Some (existsb (fun w => ceqs t w) items)
      | _ => let ns := map parse_dec items in
             match num_of l with
             | Some a => if existsb (fun o => match o with None => true | _ => false end) ns then None
                         else Some (existsb (fun o => match o with Some b => match qcmp a b with Eq => true | _ => false end | None => false end) ns)
             | None => None end
      end
  end.

(** [is] [O.70-71, O.406-419]: an instance of the named type; the [java.lang] types may be named without the
    package. A null left side and other type names are UNSPECIFIED. *)
Definition is_type (l : val) (tn : chars) : option bool :=
  let n := if prefix (str "java.lang.") tn then skipn 10 tn else tn in
  let isn := fun s => ceqs n (str s) in
  match l with
  | VNull => None
  | _ =>
    if isn "String" || isn "CharSequence" then Some (match l with VStr _ => true | _ => false end)
    else if isn "Integer" then Some (match l with VInt _ => true | _ => false end)
    else if isn "Long" then Some (match l with VLong _ => true | _ => false end)
    else if isn "Double" then Some (match l with VDbl _ => true | _ => false end)
    else if isn "Boolean" then Some (match l with VBool _ => true | _ => false end)
    else if isn "Number" then Some (is_num l)
    else if isn "Object" then Some true
    else if ceqs tn (str "java.util.List") || ceqs tn (str "java.util.Collection") then
      Some (match l with VList _ => true | _ => false end)
    else None
  end.

(** [range] [O.72-73, O.421-436]: "from..to", numbers, both inclusive, bare or quoted. The left side must be a
    number; negative or decimal bounds and from > to are UNSPECIFIED (and a known backlog item for negatives). *)
Definition in_range (l : val) (s : chars) : option bool :=
  match find (str "..") s with
  | Some i => let a := firstn i s in let b := skipn (i + 2) s in
              if all_digits a && all_digits b then
                let lo := digits_val a 0 in let hi := digits_val b 0 in
                if Z.ltb hi lo then None
                else match l with
                     | VInt z | VLong z => Some (Z.leb lo z && Z.leb z hi)
                     | VDbl q => Some (Z.leb (lo * 4)%Z q && Z.leb q (hi * 4)%Z)
                     | _ => None end
              else None
  | None => None
  end.

(** [regex] [O.74-75, O.380-385]: the left side matches the pattern; "testing if the number header is a 4-digit
    value" with [\d{4}] means the whole value matches. The patterns: literal letters/digits, [.], [\d], [[x-y]],
    each optionally followed by [*], [+] or [{n}] (one digit). Other syntax: UNSPECIFIED. *)
Inductive reatom : Type := RAny | RDigit | RCh (c : ascii) | RCls (lo hi : ascii).
Inductive rquant : Type := QOne | QStar | QPlus | QRep (n : nat).
Definition rmatch1 (a : reatom) (c : ascii) : bool :=
  match a with
  | RAny => negb (Nat.eqb (code c) 10) && negb (Nat.eqb (code c) 13)
  | RDigit => is_digit c
  | RCh d => ceq c d
  | RCls lo hi => Nat.leb (code lo) (code c) && Nat.leb (code c) (code hi)
  end.
Fixpoint rparse (fuel : nat) (s : chars) : option (list (reatom * rquant)) :=
  match fuel with O => None | S f =>
  match s with
  | [] => Some []
  | _ =>
    let at_ := match s with
               | c :: r => if ceq c "."%char then Some (RAny, r)
                           else if ceq c "\"%char then match r with d :: r' => if ceq d "d"%char then Some (RDigit, r') else None | [] => None end
                           else if ceq c "["%char then match r with lo :: m :: hi :: e :: r' =>
                                    if ceq m "-"%char && ceq e "]"%char then Some (RCls lo hi, r') else None | _ => None end
                           else if is_letter c || is_digit c then Some (RCh c, r) else None
               | [] => None end in
    match at_ with
    | None => None
    | Some (a, r) =>
      let q := match r with
               | c :: r' => if ceq c "*"%char then Some (QStar, r') else if ceq c "+"%char then Some (QPlus, r')
                            else if ceq c "{"%char then match r' with d :: e :: r'' =>
                                    if is_digit d && ceq e "}"%char then Some (QRep (code d - 48), r'') else None | _ => None end
                            else Some (QOne, r)
               | [] => Some (QOne, []) end in
      match q with
      | None => None
      | Some (qq, r') => match rparse f r' with Some rest => Some ((a, qq) :: rest) | None => None end
      end
    end
  end end.
Fixpoint take_while_n (p : ascii -> bool) (n : nat) (s : chars) : bool :=
  match n with O => true | S n' => match s with c :: s' => p c && take_while_n p n' s' | [] => false end end.
Fixpoint rmatch (fuel : nat) (re : list (reatom * rquant)) (s : chars) : bool :=
  match fuel with O => false | S f =>
  match re with
  | [] => match s with [] => true | _ => false end
  | (a, QOne) :: re' => match s with c :: s' => rmatch1 a c && rmatch f re' s' | [] => false end
  | (a, QRep n) :: re' => take_while_n (rmatch1 a) n s && rmatch f re' (skipn n s)
  | (a, QStar) :: re' =>
      rmatch f re' s || match s with c :: s' => rmatch1 a c && rmatch f re s' | [] => false end
  | (a, QPlus) :: re' => match s with c :: s' => rmatch1 a c && rmatch f ((a, QStar) :: re') s' | [] => false end
  end end.
Definition regex_f (l : val) (pat : chars) : option bool :=
  match text_of l, rparse (S (length pat)) pat with
  | Some s, Some re => match l with VList _ | VNull => None | _ => Some (rmatch (S (length s) * S (length re) * 2) re s) end
  | _, _ => None
  end.

(** One binary operator. [rv]: the right value; [bare]: the right side was a bare word (only [range] allows one:
    the docs write [range 100..199] [O.427]; other bare words are UNSPECIFIED: the right side is "a string literal
    enclosed in ' ', null, a constant value or another expression enclosed in ${ }" [O.18-19]). *)
Definition string_op (f : chars -> chars -> bool) (l r : val) : bres :=
  match l with
  | VList _ | VNull => BUns "string operator on null/list"
  | _ => match text_of l, text_of r with Some a, Some b => BV (f a b) | _, _ => BUns "string operator on null right side" end
  end.
Definition of_opt (why : string) (o : option bool) : bres := match o with Some b => BV b | None => BUns why end.
Definition neg (b : bres) : bres := match b with BV x => BV (negb x) | o => o end.
(** REFINED (DOC-2): Camel compares two numeric values by value (CAMEL-25013), also when the left one is a
    numeric text; [O.336-352] still describes a text comparison for a String on the left. Where text and value
    disagree the rule is UNSPECIFIED (counted as DOC-2). (KNOWN-1, backlog phase 3 (1)): a number [==] a numeric
    text written differently ([2 == '2.0']) is false in Camel; by the docs ([O.23-25], [O.389-392]) it is a value
    comparison. *)
Definition num_of_trim (v : val) : option dec :=
  match v with VStr s => match trim s with "+"%char :: r => parse_dec r | t => parse_dec t end | _ => num_of v end.
Definition text_value_split (o : binop) (l r : val) : option string :=
  match l, num_of_trim l, num_of_trim r with
  | VStr s, Some a, Some b =>
      match text_of r with
      | Some t =>
          let txt_eq := if all_digits s && all_digits t then Z.eqb (digits_val s 0) (digits_val t 0) else ceqs s t in
          let val_eq := match qcmp a b with Eq => true | _ => false end in
          match o with
          | OEq | ONe => if Bool.eqb txt_eq val_eq then None else Some "DOC: == of numeric values, text vs value"
          | OGt | OGe | OLt | OLe =>
              match scmp s t, qcmp a b with
              | Eq, Eq | Lt, Lt | Gt, Gt => None
              | _, _ => Some "DOC: ordering of numeric values, text vs value" end
          | _ => None end
      | None => None end
  | _, Some a, Some b =>
      match r, o with
      | VStr t, (OEq | ONe) => match text_of l with
                               | Some s => if ceqs s t then None else Some "KNOWN: number == numeric text written differently"
                               | None => None end
      | _, _ => None end
  | _, _, _ => None
  end.
Definition binop_eval (o : binop) (l r : val) (bare : bool) : bres :=
  if bare && negb (match o with ORange | ONRange => true | _ => false end) then BUns "bare word on the right" else
  (* REFINED (DOC-3): [range 100..199] without quotes [O.427] is refused by Camel (also 4.22.1) *)
  if bare then BUns "DOC: bare range" else
  match text_value_split o l r with Some w => BUns w | None =>
  (* REFINED (GAP-1): contains/~~ on a left side that is not a String is element equality in Camel
     (ObjectHelper.contains); "string-based value" [O.60-63] does not settle it *)
  if (match o with OContains | ONContains | OCIc | ONCIc => true | _ => false end)
     && negb (match l with VStr _ => true | _ => false end) then BUns "GAP: contains on a non-String left side" else
  (* REFINED (DOC-4): the [is] shorthand covers the wrapper types (String, Integer, ...), not "all java.lang
     types" [O.414]: [is 'Number'] and [is 'Object'] are refused *)
  if (match o, r with
      | (OIs | ONIs), VStr t => ceqs t (str "Number") || ceqs t (str "Object") || ceqs t (str "CharSequence")
      | _, _ => false end) then BUns "DOC: is shorthand" else
  match o with
  | OEq => of_opt "== on these kinds" (eqv l r)
  | ONe => neg (of_opt "!= on these kinds" (eqv l r))
  | OEqIc | ONeIc =>
      (* REFINED (GAP-2): two digit texts are compared as numbers by =~ too (not documented) *)
      let b := match l, r with
               | VStr a, VStr c => if all_digits a && all_digits c then BUns "GAP: =~ on digit texts" else BV (ceqs (lower a) (lower c))
               | _, _ => BUns "=~ on a non-String" end in
      match o with OEqIc => b | _ => neg b end
  | OGt | OGe | OLt | OLe =>
      match ordv l r with
      | Some c => BV (match o, c with
                      | OGt, Gt => true | OGe, Gt => true | OGe, Eq => true | OLt, Lt => true | OLe, Lt => true
                      | OLe, Eq => true | _, _ => false end)
      | None => BUns "ordering on these kinds"
      end
  | OContains => string_op (fun a b => occurs b a) l r
  | ONContains => neg (string_op (fun a b => occurs b a) l r)
  | OCIc => string_op (fun a b => occurs (lower b) (lower a)) l r
  | ONCIc => neg (string_op (fun a b => occurs (lower b) (lower a)) l r)
  | OStarts => string_op (fun a b => prefix b a) l r
  | ONStarts => neg (string_op (fun a b => prefix b a) l r)
  | OEnds => string_op (fun a b => suffix b a) l r
  | ONEnds => neg (string_op (fun a b => suffix b a) l r)
  | OEquals => string_op ceqs l r
  | ONEquals => neg (string_op ceqs l r)
  | OIn | ONIn => let b := match r with VStr s => of_opt "in: set or kinds" (in_set l s) | _ => BUns "in: right not a text" end in
                  match o with OIn => b | _ => neg b end
  | OIs | ONIs => let b := match r with VStr s => of_opt "is: type or null" (is_type l s) | _ => BUns "is: right not a text" end in
                  match o with OIs => b | _ => neg b end
  | ORange | ONRange => let b := match r with VStr s => of_opt "range: bounds or kinds" (in_range l s) | _ => BUns "range: right not a text" end in
                        match o with ORange => b | _ => neg b end
  | ORegex | ONRegex => let b := match r with VStr s => of_opt "regex: pattern or kinds" (regex_f l s) | _ => BUns "regex: right not a text" end in
                        match o with ORegex => b | _ => neg b end
  end end.

(** [&&]/[||] [O.246-254, O.296-308, O.456-472]. The docs give no precedence and no grouping syntax: a sequence that
    mixes both is defined only when "&& first" and "left to right" agree. Whether the right side is evaluated
    when the left decides is not said: an error next to a deciding value is UNSPECIFIED. *)
Definition all_same (ops : list lop) : option lop :=
  match ops with
  | [] => None
  | o :: os => if forallb (fun o' => match o, o' with LAnd, LAnd | LOr, LOr => true | _, _ => false end) os then Some o else None
  end.
Fixpoint ltr (b : bool) (rest : list (lop * bool)) : bool :=
  match rest with [] => b | (LAnd, c) :: r => ltr (b && c) r | (LOr, c) :: r => ltr (b || c) r end.
Fixpoint prec_terms (cur : bool) (rest : list (lop * bool)) : list bool :=
  match rest with [] => [cur] | (LAnd, c) :: r => prec_terms (cur && c) r | (LOr, c) :: r => cur :: prec_terms c r end.
Fixpoint find_uns (l : list bres) : option string :=
  match l with [] => None | BUns w :: _ => Some w | _ :: l' => find_uns l' end.
Definition combine_seq (first : bres) (rest : list (lop * bres)) : bres :=
  let all := first :: map snd rest in
  if existsb (fun b => match b with BUns _ => true | _ => false end) all then
    match find_uns all with Some w => BUns w | None => BUns "?" end
  else if existsb (fun b => match b with BErr => true | _ => false end) all then
    match all_same (map fst rest) with
    | Some LAnd => if existsb (fun b => match b with BV false => true | _ => false end) all then BUns "error next to a deciding false" else BErr
    | Some LOr => if existsb (fun b => match b with BV true => true | _ => false end) all then BUns "error next to a deciding true" else BErr
    | None => BUns "error in a mixed &&/|| sequence"
    end
  else
    let v := fun b => match b with BV x => x | _ => false end in
    let f := v first in let r := map (fun '(o, b) => (o, v b)) rest in
    let a := ltr f r in let p := existsb (fun x => x) (prec_terms f r) in
    if Bool.eqb a p then BV a else BUns "&&/|| precedence".

(** ** 9. Evaluation *)

Definition is_afun (a : atom) : bool := match a with AFun _ => true | _ => false end.
Definition has_rest (r : prest) : bool := match r with PNil => false | _ => true end.
Fixpoint rest_has_afun (r : prest) : bool := match r with PNil => false | PCons _ a r' => is_afun a || rest_has_afun r' end.
Definition in_int (z : Z) : bool := Z.leb (-2147483648) z && Z.leb z 2147483647.
(** Inlined result types [F.12-30]: [int:]/[integer:] Integer, [long:] Long, [boolean:] Boolean, [string:] String.
    How a value that does not convert is treated is not said (UNSPECIFIED). *)
Definition typed (t : nat) (v : val) : res :=
  let as_int := fun (mk : Z -> val) (lim : Z -> bool) =>
    match v with
    | VInt z | VLong z => if lim z then RV (mk z) else RUns "typed: out of range"
    | VStr s => match parse_dec s with Some (z, O) => if lim z then RV (mk z) else RUns "typed: out of range"
                                     | _ => RUns "typed: text is not an integer" end
    | _ => RUns "typed: from this kind" end in
  match t with
  | 0 | 1 => as_int VInt in_int
  | 2 => as_int VLong (fun z => Z.leb (-9223372036854775808) z && Z.leb z 9223372036854775807)
  | 3 => match to_bool v with Some (Some b) => RV (VBool b) | _ => RUns "boolean: from this value" end
  | _ => match text_of v with Some s => RV (VStr s) | None => RUns "string: of null or a list" end
  end.

(** Arguments, evaluated: [AV r k] with k = 0 nested function, 1 quoted, 2 bare word, 3 number; [AP b] a predicate. *)
Inductive argv : Type := AV (r : res) (k : nat) | AP (b : bres).

(** A literal as a function argument [F.10]: a quoted literal is its text without the quotes ([F.588]:
    [lowercase('Hello World')] returns [hello world]); a bare word is itself ([F.142], [F.346]); a number is its
    text. A bare [null], [true] or [false] is UNSPECIFIED. *)
Definition lit_arg (l : lit) : argv :=
  match l with
  | LQ s => AV (if arg_lit_ok s then q_value true s else RUns "comma, parenthesis or quote inside a quoted argument") 1
  | LBare s => AV (RV (VStr s)) 2
  | LNum z => AV (RV (VStr (ztext z))) 3
  | LNull => AV (RUns "bare null argument") 2
  | LTrue | LFalse => AV (RUns "bare boolean argument") 2
  end.

(** A literal on the right of an operator [O.18-19]; the bool says it was a bare word. *)
Definition lit_rhs (inb : bool) (l : lit) : res * bool :=
  match l with
  | LQ s => (q_value inb s, false)
  | LNum z => (if in_int z then RV (VInt z) else RUns "large constant", false)
  | LNull => (RV VNull, false)
  | LTrue => (RV (VBool true), false)
  | LFalse => (RV (VBool false), false)
  | LBare s => (RV (VStr s), true)
  end.

(** A ternary value [O.174]: "a quoted literal, a number, true, false, null, or a nested function". The Java type
    of a number/true/false value is not said: only its text is compared. *)
Definition tern_lit (l : lit) : res :=
  match l with
  | LQ s => q_value true s
  | LNum z => RLoose (ztext z)
  | LTrue => RLoose (str "true")
  | LFalse => RLoose (str "false")
  | LNull => RV VNull
  | LBare _ => RUns "bare word as a ternary value"
  end.

Definition incdec (inc : bool) (r : res) : res :=
  match r with
  | RV (VInt z) => let z' := (if inc then z + 1 else z - 1)%Z in if in_int z' then RV (VInt z') else RUns "++/-- overflow"
  | RV (VLong z) => RV (VLong (if inc then z + 1 else z - 1)%Z)
  | RV _ => RUns "++/-- of a value that is not an Integer or Long"
  | RLoose _ => RUns "++/-- of a loose value"
  | o => o
  end.

Definition nm (n : chars) (s : string) : bool := ceqs n (str s).
Definition arity : res := RUns "function arity outside the docs".
Definition body_text (x : exch) (k : chars -> res) : res := bind_text (RV (ex_body x)) k.
(** The input of a function: its argument, or the message body by default ("message body as default"). *)
Definition one_text (x : exch) (a : list argv) (k : chars -> res) : res :=
  match a with [] => body_text x k | [AV r _] => bind_text r k | _ => arity end.
Definition one_val (x : exch) (a : list argv) (k : val -> res) : res :=
  match a with [] => k (ex_body x) | [AV r _] => bind r k | _ => arity end.
Definition with_int (r : res) (k : Z -> res) : res :=
  bind_text r (fun s => match parse_dec s with Some (z, O) => k z | _ => RUns "number argument is not an integer" end).
Definition pv (b : bres) : res := match b with BV v => RV (VBool v) | BErr => RErr | BUns w => RUns w end.

Definition call (x : exch) (n : chars) (a : list argv) : res :=
  (* string functions [F.512-551] *)
  if nm n "trim" then one_text x a (fun s => RV (VStr (trim s)))                         (* [F.543-544, F.627-632] *)
  else if nm n "uppercase" then one_text x a (fun s => RV (VStr (upper s)))               (* [F.549-550, F.587-589] *)
  else if nm n "lowercase" then one_text x a (fun s => RV (VStr (lower s)))               (* [F.525-526, F.587-589] *)
  else if nm n "capitalize" then one_text x a capitalize
  else if nm n "normalizeWhitespace" then one_text x a normalize_ws
  else if nm n "quote" then one_text x a quote_f
  else if nm n "unquote" then one_text x a unquote_f
  else if nm n "length" then one_text x a (fun s => RV (VInt (Z.of_nat (length s))))      (* bytes [F.80-81, F.185-188, F.634-635] *)
  else if nm n "size" then                                                               (* [F.246-247, F.292-296] *)
    one_val x a (fun v => RV (VInt (match v with VNull => 0 | VList l => Z.of_nat (length l) | _ => 1 end)))
  else if nm n "isEmpty" then                                                            (* [F.332-333, F.354] *)
    (* REFINED (DOC-5): Camel's isEmpty is true for a blank text; [F.354] says only null and empty are *)
    one_val x a (fun v => match v with VStr (_ :: _ as t) => if blank t then RUns "DOC: isEmpty of a blank text" else RV (VBool false)
                         | _ => RV (VBool (match v with VNull | VStr [] | VList [] => true | _ => false end)) end)
  else if nm n "isNumeric" then one_text x a (all_of is_digit)
  else if nm n "isAlpha" then one_text x a (all_of is_letter)
  else if nm n "isAlphaNumeric" then one_text x a (all_of (fun c => is_letter c || is_digit c))
  else if nm n "contains" then                                                           (* ignore case [F.329-330, F.345-346] *)
    (* REFINED (GAP-3): an empty text, or a body that is not a String, is not settled by the docs *)
    let k := fun s t => match t, s with [], _ | _, [] => RUns "GAP: contains() with an empty text"
                        | _, _ => RV (VBool (occurs (lower t) (lower s))) end in
    match a with
    | [AV t _] => match ex_body x with VStr _ => body_text x (fun s => bind_text t (k s)) | _ => RUns "GAP: contains() of a value that is not a String" end
    | [AV e _; AV t _] => match e with RV (VStr _) => bind_text e (fun s => bind_text t (k s)) | RV _ => RUns "GAP: contains() of a value that is not a String" | _ => bind_text e (fun s => bind_text t (k s)) end
    | _ => arity end
  else if nm n "substring" then
    match a with
    | [AV k _] => with_int k (fun n1 => body_text x (substring1 n1))
    | [AV k1 _; AV k2 _] => with_int k1 (fun n1 => with_int k2 (fun n2 => body_text x (substring2 n1 n2)))
    | [AV k1 _; AV k2 _; AV e _] => with_int k1 (fun n1 => with_int k2 (fun n2 => bind_text e (substring2 n1 n2)))
    | _ => arity end
  else if nm n "substringBefore" then
    match a with
    | [AV b _] => bind_text b (fun m => body_text x (sub_before m))
    | [AV e _; AV b _] => bind_text b (fun m => bind_text e (sub_before m))
    | _ => arity end
  else if nm n "substringAfter" then
    match a with
    | [AV b _] => bind_text b (fun m => body_text x (sub_after m))
    | [AV e _; AV b _] => bind_text b (fun m => bind_text e (sub_after m))
    | _ => arity end
  else if nm n "substringBetween" then
    match a with
    | [AV p _; AV q _] => bind_text p (fun m1 => bind_text q (fun m2 => body_text x (sub_between m1 m2)))
    | [AV e _; AV p _; AV q _] => bind_text p (fun m1 => bind_text q (fun m2 => bind_text e (sub_between m1 m2)))
    | _ => arity end
  else if nm n "replace" then                                                            (* [F.530-531, F.600-602, A.37-99] *)
    let k := fun f t s => match xml_ents f with [] => RUns "replace: empty from" | f' => RV (VStr (replace_all f' (xml_ents t) s)) end in
    match a with
    (* REFINED (GAP-4): from/to as nested functions are taken as text by Camel; the docs only show literals *)
    | (AV _ 0 :: _) | (_ :: AV _ 0 :: _) => RUns "GAP: replace from/to as a function"
    | [AV f _; AV t _] => bind_text f (fun f' => bind_text t (fun t' => body_text x (k f' t')))
    | [AV f _; AV t _; AV e _] => bind_text f (fun f' => bind_text t (fun t' => bind_text e (k f' t')))
    | _ => arity end
  else if nm n "concat" then                                                             (* [F.521, F.556-560] *)
    match a with
    | [AV p _; AV q _] => bind_text p (fun s => bind_text q (fun t => RV (VStr (s ++ t))))
    | [_; _; AV _ 0] => RUns "GAP: concat separator as a function"   (* REFINED (GAP-4) *)
    | [AV p _; AV q _; AV z _] => bind_text p (fun s => bind_text q (fun t => bind_text z (fun u => RV (VStr (s ++ u ++ t)))))
    | _ => arity end
  else if nm n "pad" then
    match a with
    | [AV e _; AV w _] => bind_text e (fun s => with_int w (fun n' => pad_f s n' [" "%char]))
    | [_; _; AV _ 0] => RUns "GAP: pad separator as a function"   (* REFINED (GAP-4) *)
    | [AV e _; AV w _; AV z _] => bind_text e (fun s => with_int w (fun n' => bind_text z (pad_f s n')))
    | _ => arity end
  else if nm n "escape" then
    match a with
    (* REFINED (MINOR-2): a quoted kind ([escape('url')]) is refused by Camel *)
    | (AV _ 1 :: _) => RUns "MINOR: escape with a quoted kind"
    | [AV k _] => bind_text k (fun kd => body_text x (escape_f kd))
    | [AV k _; AV e _] => bind_text k (fun kd => bind_text e (escape_f kd))
    | _ => arity end
  (* condition functions [F.321-369] *)
  else if nm n "not" then
    match a with
    | [] => match ex_body x with                                                         (* [F.363-364] *)
            | VStr [] => RV (VBool true)
            | VStr s => if ceqs (lower s) (str "true") || ceqs (lower s) (str "false") then RUns "not() of a true/false text"
                        (* REFINED (DOC-6): not() of a blank body is true in Camel; [F.363-364] calls only the empty body empty *)
                        else if blank s then RUns "DOC: not() of a blank text" else RV (VBool false)
            | _ => RUns "not() of a body that is not a String" end
    | [AP b] => pv (neg b)                                                               (* [F.340, F.365] *)
    | _ => RUns "not: argument is not a predicate" end
  else if nm n "iif" then                                                                (* [F.331, F.348-350] *)
    match a with
    | [AP b; AV t kt; AV e ke] =>
        match b with
        | BV c => let '(r, k) := if c then (t, kt) else (e, ke) in
                  match k with 0 => r | 1 => RUns "iif/val quoted literal: S1, known" | _ => RUns "iif: bare value" end
        | BErr => RErr
        | BUns w => RUns w end
    | _ => arity end
  else if nm n "val" then                                                                (* [F.101, F.142-143] *)
    match a with
    | [AV r 0] => r
    | [AV _ 1] => RUns "iif/val quoted literal: S1, known"
    | [AV r 2] => r
    | [AV r 3] => match r with RV (VStr s) => RLoose s | o => o end
    | _ => arity end
  else RUns "function outside the spec".

Fixpoint ev (x : exch) (f : fn) {struct f} : res :=
  match f with
  | FBody => RV (ex_body x)                                                              (* [F.51, F.113] *)
  (*! R L1.simple.header-ci FIX [F.68-76] L0.headers.ci *)
  | FHeader _ k => RV (Exchange.hget k (ex_headers x))  (* [F.68-76]; missing: null [O.282]; names ignore case (L0) *)
  | FProp _ k => RV (lookup k (ex_props x))                                   (* [F.63, F.132-133] *)
  | FVar k => RV (lookup k (ex_vars x))                                                 (* [F.102] *)
  | FNull => RV VNull                                                                    (* [F.463] *)
  | FHeadersSize => RV (VInt (Z.of_nat (length (ex_headers x))))                         (* [F.74] *)
  | FTyped t g => bind (ev x g) (typed t)
  | FCall n _ a => call x n (evargs x a)
  | FPred (PS (AFun g) PNil) => ev x g      (* ${f} written as a predicate of one function is the function [F.113] *)
  | FPred p => pv (evps true x p)                                                        (* [O.39-40] *)
  | FTern (PS (AFun _) PNil) _ _ => RUns "GAP: a lone function as the ternary condition (refused by Camel)"
  | FTern c t e => match evps true x c with                                              (* [O.132, O.140-186] *)
                   | BV true => evtv x t | BV false => evtv x e | BErr => RErr | BUns w => RUns w end
  end
with evargs (x : exch) (a : args) {struct a} : list argv :=
  match a with ANil => [] | ACons y r => evarg x y :: evargs x r end
with evarg (x : exch) (a : arg) {struct a} : argv :=
  match a with AFn f => AV (ev x f) 0 | ALit l => lit_arg l | APred p => AP (evps false x p) end
with evtv (x : exch) (t : tval) {struct t} : res :=
  match t with TVLit l => tern_lit l | TVFn f => ev x f end
with evatom (inb : bool) (x : exch) (a : atom) {struct a} : bres :=
  match a with
  | ACmp l o r =>
      match evlhs inb x l, evrhs inb x r with
      | RErr, _ | _, (RErr, _) => BErr
      | RUns w, _ | _, (RUns w, _) => BUns w
      | RV u, (RV v, bare) => binop_eval o u v bare
      | _, _ => BUns "loose operand"
      end
  | ANot f => match ev x f with RV v => neg (truth v) | RErr => BErr | RUns w => BUns w | RLoose _ => BUns "loose" end
  | AFun f => match ev x f with RV v => truth v | RErr => BErr | RUns w => BUns w | RLoose _ => BUns "loose" end
  | ANot2 f => if inb then match ev x f with RV v => truth v | RErr => BErr | RUns w => BUns w | RLoose _ => BUns "loose" end
               else BErr                                                                 (* [O.293-294] *)
  end
with evlhs (inb : bool) (x : exch) (l : lhs) {struct l} : res :=
  match l with
  | LFn FNull => if inb then RUns "GAP: null as the left side inside the braces" else RV VNull
  | LFn f => ev x f
  | LInc f => if inb then RUns "++ inside the braces" else incdec true (ev x f)          (* [O.99-121] *)
  | LDecr f => if inb then RUns "-- inside the braces" else incdec false (ev x f)
  | LNotFn _ => if inb then RUns "!f OP r inside the braces" else RErr                   (* refused [O.289-291] *)
  end
with evrhs (inb : bool) (x : exch) (r : rhs) {struct r} : res * bool :=
  match r with
  | RLit l => lit_rhs inb l
  | RFn f => if inb then (RUns "function on the right inside the braces", false) else (ev x f, false)  (* [O.19, O.363-371] *)
  | RNot _ => (if inb then RUns "!f on the right inside the braces" else RErr, false)    (* refused [O.292] *)
  end
with evps (inb : bool) (x : exch) (p : pseq) {struct p} : bres :=
  match p with
  | PS a r =>
      (* REFINED (GAP-6): inside the braces Camel refuses a function alone as an operand of && / ||
         ([${header.a == 'x' && header.f}]); the docs only show comparisons and negated functions there *)
      if inb && has_rest r && (is_afun a || rest_has_afun r) then BUns "GAP: a lone function as an operand inside the braces"
      else combine_seq (evatom inb x a) (evrest inb x r)
  end
with evrest (inb : bool) (x : exch) (r : prest) {struct r} : list (lop * bres) :=
  match r with PNil => [] | PCons o a r' => (o, evatom inb x a) :: evrest inb x r' end.

(** Template text [O.156-165]: "only the two functions are evaluated and the rest is copied as-is"; a [!] is
    ordinary text in an expression [O.273]; a function that returns null leaves nothing ([O.164]: the text
    [1 == 0 ?  : ...]). Text with [?:] or [~>] (the elvis and chain operators [O.133-134]) is UNSPECIFIED. *)
Definition vtext (r : res) : option chars + string :=
  match r with
  | RV VNull => inl (Some [])
  | RV v => match text_of v with Some s => inl (Some s) | None => inr "list in a template" end
  | RLoose s => inl (Some s)
  | RErr => inl None
  | RUns w => inr w
  end.
Fixpoint template (x : exch) (t : list part) : res :=
  match t with
  | [] => RV (VStr [])
  | p :: t' =>
      let here := match p with
                  | TText s => if occurs (str "?:") s || occurs (str "~>") s then inr "elvis/chain operator in text"
                               else match unesc false s with Some v => inl (Some v) | None => inr "escape or $ in text" end
                  | TFn _ f => vtext (ev x f)
                  | TPost f inc => vtext (incdec inc (ev x f))
                  end in
      match here with
      | inr w => RUns w
      | inl None => RErr
      | inl (Some a) => match template x t' with RV (VStr b) => RV (VStr (a ++ b)) | o => o end
      end
  end.

(** Elvis [O.133, O.189-197]; the default is a quoted literal ([Guest]), null, or a number (text only). *)
Definition elvis_default (d : lit) : res :=
  (* REFINED (GAP-5): a [null] default gives the text "null" in Camel; the docs only show a quoted default *)
  match d with LQ s => q_value false s | LNull => RUns "GAP: elvis default null" | LNum z => RLoose (ztext z) | _ => RUns "elvis default kind" end.

(** Chain [O.134-135, O.199-224]: "The value on the left-hand-side is evaluated, and set as the new message body
    before evaluating the right-hand-side function"; the null-safe chain "will not continue when a function
    returned null" (the answer is then that null). *)
Fixpoint chain (ns : bool) (x : exch) (r : res) (fs : list fn) : res :=
  match fs with
  | [] => r
  | g :: fs' => match r with
                | RV VNull => if ns then RV VNull else chain ns x (ev (with_body x VNull) g) fs'
                | RV v => chain ns x (ev (with_body x v) g) fs'
                | RLoose _ => RUns "chain of a loose value"
                | o => o
                end
  end.

(** The documented function forms (name and number of arguments, [F.42-551]); a predicate argument only as the
    first argument of [not] and [iif]. A program outside them is UNSPECIFIED as a whole: Camel checks the forms
    when it parses, also in a branch that is never evaluated. *)
Fixpoint nargs (a : args) : nat := match a with ANil => 0 | ACons _ r => S (nargs r) end.
Definition arity_ok (n : chars) (k : nat) (first_pred : bool) : bool :=
  let one := existsb (fun m => nm n m) ["trim"; "uppercase"; "lowercase"; "capitalize"; "normalizeWhitespace"; "quote";
               "unquote"; "length"; "size"; "isEmpty"; "isNumeric"; "isAlpha"; "isAlphaNumeric"] in
  if one then Nat.leb k 1 && negb first_pred
  else if nm n "contains" || nm n "substringBefore" || nm n "substringAfter" || nm n "escape" then
    (Nat.eqb k 1 || Nat.eqb k 2) && negb first_pred
  else if nm n "substring" then (Nat.leb 1 k && Nat.leb k 3) && negb first_pred
  else if nm n "substringBetween" || nm n "replace" || nm n "concat" || nm n "pad" then
    (Nat.eqb k 2 || Nat.eqb k 3) && negb first_pred
  else if nm n "not" then Nat.eqb k 0 || (Nat.eqb k 1 && first_pred)
  else if nm n "iif" then Nat.eqb k 3 && first_pred
  else if nm n "val" then Nat.eqb k 1 && negb first_pred
  else false.
Definition first_is_pred (a : args) : bool := match a with ACons (APred _) _ => true | _ => false end.
Definition orelse (a b : option string) : option string := match a with Some _ => a | None => b end.
(** A literal in its context ([infn]: inside [${ }]; [isarg]: a function argument): the conditions of [q_value]
    and [arg_lit_ok], checked for every literal of the program (Camel checks them when it parses). *)
Definition chk_lit (infn isarg : bool) (l : lit) : option string :=
  match l with
  | LQ s => if existsb (fun c => ceq c "'"%char) s then Some "quote inside a quoted literal"
            else if isarg && negb (arg_lit_ok s) then Some "comma, parenthesis or quote inside a quoted argument"
            else match unesc infn s with Some _ => None | None => Some "escape, $ or brace in a literal" end
  | _ => None
  end.
Definition is_typed (f : fn) : bool := match f with FTyped _ _ => true | _ => false end.
Definition is_pred_fn (f : fn) : bool := match f with FPred _ | FTern _ _ _ => true | FTyped _ (FPred _) | FTyped _ (FTern _ _ _) => true | _ => false end.
Definition is_lone (a : atom) : bool := match a with AFun _ | ANot _ | ANot2 _ => true | _ => false end.
(** REFINED (MINOR-5): [${length(${body}) > 3 ? 'a' : 'b'}] is refused by Camel, while [${length(${body}) > 3}] works. *)
Fixpoint args_have_fn (a : args) : bool := match a with ANil => false | ACons (AFn _) _ => true | ACons _ r => args_have_fn r end.
Definition atom_nested_call (a : atom) : bool :=
  match a with ACmp (LFn (FCall _ _ g)) _ _ | ANot (FCall _ _ g) | AFun (FCall _ _ g) | ANot2 (FCall _ _ g) => args_have_fn g | _ => false end.
Fixpoint rest_nested_call (r : prest) : bool := match r with PNil => false | PCons _ a r' => atom_nested_call a || rest_nested_call r' end.
Definition ps_nested_call (p : pseq) : bool := match p with PS a r => atom_nested_call a || rest_nested_call r end.
Definition splits_args (n : chars) : bool :=
  existsb (fun m => nm n m) ["contains"; "substring"; "substringBefore"; "substringAfter"; "substringBetween"; "replace";
                            "concat"; "pad"; "escape"; "iif"].
Fixpoint args_nested_comma (a : args) : bool :=
  match a with ANil => false | ACons (AFn f) r => occurs [","%char] (rfn f) || args_nested_comma r | ACons _ r => args_nested_comma r end.
Fixpoint args_nested_quoted_pred (a : args) : bool :=
  match a with
  | ANil => false
  | ACons (AFn ((FPred _ | FTern _ _ _) as f)) r => occurs ["'"%char] (rfn f) || args_nested_quoted_pred r
  | ACons _ r => args_nested_quoted_pred r end.
Fixpoint args_have_brace_escape (a : args) : bool :=
  match a with ANil => false | ACons y r => occurs [ascii_of_nat 92; "}"%char] (rarg y) || args_have_brace_escape r end.
(** The right side forms each operator accepts, checked when Camel parses: a bare word only for range, no number
    for is and range. *)
Definition chkop (o : binop) (r : rhs) : option string :=
  match o, r with
  | (ORange | ONRange), RLit (LBare _) => None
  | _, RLit (LBare _) => Some "bare word on the right"
  | (OIs | ONIs | ORange | ONRange), RLit (LNum _) => Some "number on the right of is/range"
  | _, _ => None
  end.
Fixpoint chkf (f : fn) : option string :=
  match f with
  | FTyped _ g => chkf g
  | FCall n _ a =>
      if negb (arity_ok n (nargs a) (first_is_pred a)) then Some "function form outside the docs"
      (* REFINED (MINOR-7): a nested function whose own text has a comma ([${concat(a,${replace(o,0)})}]) is refused
         inside a function of several arguments (the arguments are split at every comma; also 4.22.1) *)
      else if splits_args n && args_nested_comma a then Some "MINOR: nested function with a comma inside a function of several arguments"
      (* REFINED (MINOR-6): a nested predicate with a quoted literal inside a function argument loses its quotes *)
      else if args_nested_quoted_pred a then Some "MINOR: nested predicate with a quoted literal in a function argument"
      else if args_have_brace_escape a then Some "GAP: \} inside a function argument"
      (* the escape kind is checked when Camel parses (REFINED MINOR-2: a quoted kind is refused) *)
      else if nm n "escape" && negb (match a with
             | ACons (ALit (LBare k)) _ => existsb (fun m => ceqs (lower k) (str m)) ["html"; "xml"; "json"; "js"; "javascript"; "sql"; "url"]
             | _ => false end)
      then (match a with ACons (ALit (LQ _)) _ => Some "MINOR: escape with a quoted kind" | _ => Some "escape kind outside the docs" end)
      else chkargs (first_is_pred a) a
  | FPred p => orelse (match p with
                       (* REFINED (GAP-8): [${int:header.a > 3}] reads as int:(the predicate) in Camel (null) *)
                       | PS (ACmp (LFn g) _ _) _ => if is_typed g then Some "GAP: typed prefix on the left inside the braces" else None
                       | _ => None end) (chkps true p)
  | FTern c t e =>
      (* REFINED (GAP-9): a negated or lone function as the whole ternary condition is refused by Camel *)
      orelse (match c with PS a PNil => if is_lone a then Some "GAP: a lone or negated function as the ternary condition" else None
                         | _ => None end)
             (orelse (if ps_nested_call c then Some "MINOR: ternary condition with a function that has a nested ${ } argument" else None)
             (orelse (chkps true c) (orelse (chktv t) (chktv e))))
  | _ => None
  end
with chkargs (first : bool) (a : args) : option string :=
  match a with
  | ANil => None
  | ACons (APred p) r => if first then orelse (chkps_infn p) (chkargs false r) else Some "function form outside the docs"
  | ACons y r => orelse (chka y) (chkargs false r)
  end
(* a predicate argument ([not(${a} == 'x')]) is written outside-style but sits inside [${ }]: a raw brace in its
   literals is UNSPECIFIED as anywhere inside the braces *)
with chkps_infn (p : pseq) : option string :=
  match p with PS a r => orelse (chkatom_infn true a) (chkrest_infn r) end
with chkrest_infn (r : prest) : option string :=
  match r with PNil => None | PCons _ a r' => orelse (chkatom_infn false a) (chkrest_infn r') end
with chkatom_infn (first : bool) (a : atom) : option string :=
  match a with
  | ACmp l o r => orelse (chkop o r)
                   (orelse (match l with LInc _ | LDecr _ => Some "GAP: ++/-- in a predicate argument (refused by Camel)" | _ => None end)
                   (orelse (chkl false first l) (match r with RLit li => chk_lit true false li | RFn f | RNot f => chkf f end)))
  | ANot f | ANot2 f | AFun f => chkf f
  end
with chka (a : arg) : option string := match a with AFn f => chkf f | ALit l => chk_lit true true l | APred p => chkps false p end
with chktv (t : tval) : option string := match t with TVLit l => chk_lit true false l | TVFn f => chkf f end
with chkatom (inb first : bool) (a : atom) : option string :=
  if inb && (match a with ACmp (LFn f) _ _ | ANot f | AFun f | ANot2 f => is_pred_fn f | _ => false end)
  then Some "a predicate nested inside the braces without its own ${ } (ambiguous text)" else
  match a with
  | ACmp l o r => orelse (chkop o r) (orelse (match l with LFn FNull => if inb then Some "GAP: null as the left side inside the braces" else None | _ => None end)
                                   (orelse (chkl inb first l) (chkr inb r)))
  | ANot f | ANot2 f =>
      (* REFINED (MINOR-3): [${!int:header.a}] is refused ("Unknown function: int:header.a") *)
      if inb && is_typed f then Some "MINOR: negated typed function inside the braces"
      else if inb && (match f with FCall _ _ g => args_have_fn g | _ => false end) then Some "GAP: negated call with a nested argument inside the braces"
      else chkf f
  | AFun f => chkf f
  end
with chkl (inb first : bool) (l : lhs) : option string :=
  match l with
  | LFn f | LNotFn f => chkf f
  | LInc f | LDecr f =>
      if inb then Some "GAP: ++/-- inside the braces"
      (* REFINED (MINOR-4): ++/-- is refused after && / || ([${a} == 'x' && ${n}++ > 5]), but works first *)
      else if negb first then Some "MINOR: ++/-- after && / ||" else chkf f
  end
with chkr (inb : bool) (r : rhs) : option string :=
  match r with RLit l => chk_lit inb false l | RFn f | RNot f => chkf f end
with chkps (inb : bool) (p : pseq) : option string :=
  match p with
  | PS a r =>
      (* REFINED (GAP-6), static: Camel refuses it when it parses *)
      if inb && has_rest r && (is_afun a || rest_has_afun r) then Some "GAP: a lone function as an operand inside the braces"
      else orelse (chkatom inb true a) (chkrest inb r)
  end
with chkrest (inb : bool) (r : prest) : option string :=
  match r with PNil => None | PCons _ a r' => orelse (chkatom inb false a) (chkrest inb r') end.
Definition chkpart (p : part) : option string := match p with TText _ => None | TFn _ f | TPost f _ => chkf f end.
Fixpoint chkparts (t : list part) : option string := match t with [] => None | p :: r => orelse (chkpart p) (chkparts r) end.
Fixpoint chkfs (fs : list fn) : option string := match fs with [] => None | f :: r => orelse (chkf f) (chkfs r) end.
Definition chkprog (p : prog) : option string :=
  match p with
  | PExpr t => chkparts t
  | PPred q => chkps false q
  | PElvis f d => orelse (chkf f) (chk_lit false false d)
  | PChain _ f fs => chkfs (f :: fs)
  end.
(** Template parts: an empty text is nothing, adjacent texts are one text. *)
Fixpoint norm_parts (t : list part) : list part :=
  match t with
  | TText [] :: r => norm_parts r
  | TText a :: r => match norm_parts r with TText b :: r' => TText (a ++ b) :: r' | r' => TText a :: r' end
  | p :: r => p :: norm_parts r
  | [] => []
  end.
(** REFINED (GAP-7): [${f}++] directly followed by text or by another function is left as text by Camel ([${f}++;]
    gives [5++;]); the docs only show the operator at the end or before a space ([O.103-121]). *)
Fixpoint post_glued (t : list part) : bool :=
  match t with
  | TPost _ _ :: ((TText (c :: _) :: _) as r) => negb (ceq c " "%char) || post_glued r
  | TPost _ _ :: ((TFn _ _ :: _) as r) | TPost _ _ :: ((TPost _ _ :: _) as r) => true
  | TFn _ _ :: ((TText ("+"%char :: "+"%char :: _) :: _) as r) | TFn _ _ :: ((TText ("-"%char :: "-"%char :: _) :: _) as r) => true
  | _ :: r => post_glued r
  | [] => false
  end.
Definition run (x : exch) (p : prog) : res :=
  let txt := render p in
  if (match txt with c :: _ => is_ws c | [] => true end) || (match rev txt with c :: _ => is_ws c | [] => true end)
  then RUns "leading or trailing white space (the trim option [A.138-150])"
  else match chkprog p with Some w => RUns w | None =>
  let p := match p with PExpr t => PExpr (norm_parts t) | _ => p end in
  if (match p with PExpr t => post_glued t | _ => false end) then RUns "GAP: ++/-- followed directly by text or a function"
  else match p with
       | PExpr [TFn _ f] => ev x f                         (* a single function: its value as-is [F.113] *)
       | PExpr [TPost f inc] => incdec inc (ev x f)        (* [O.328-329] *)
       | PExpr t => template x t
       | PPred q => pv (evps false x q)                    (* [O.29-37, O.296-308] *)
       | PElvis f d => match ev x f with
                       | RV v => match elvis_truth v with BV true => RV v | BV false => elvis_default d
                                 | BErr => RErr | BUns w => RUns w end
                       | RLoose _ => RUns "elvis of a loose value"
                       | o => o end
       | PChain ns f fs => chain ns x (ev x f) fs
       end end.

(** ** 10. The documented examples, reproduced by the rules (checked by [vm_compute]) *)

Definition hx (body : val) (hs : list (string * val)) : exch :=
  mkEx body (map (fun '(k, v) => (str k, v)) hs) [] [].
Definition S (s : string) : val := VStr (str s).
Definition q (s : string) : lit := LQ (str s).
Definition bw (s : string) : lit := LBare (str s).
Definition hdr (k : string) : fn := FHeader 0 (str k).
Definition c1 (n : string) (a : list arg) : fn :=
  FCall (str n) false (fold_right (fun x r => ACons x r) ANil a).
Definition one (a : atom) : pseq := PS a PNil.
Definition ex1 (f : fn) : prog := PExpr [TFn false f].

(** [O.167-171]: [${header.foo > 0 ? 'positive' : 'negative'}]. *)
Example doc_ternary :
  run (hx VNull [("foo", VInt 5)]) (ex1 (FTern (one (ACmp (LFn (hdr "foo")) OGt (RLit (LNum 0)))) (TVLit (q "positive")) (TVLit (q "negative"))))
  = RV (S "positive").
Proof. vm_compute. reflexivity. Qed.
(** [O.153]: a compound condition. *)
Example doc_ternary_and :
  run (hx VNull [("age", VInt 20); ("country", S "DK")])
      (ex1 (FTern (PS (ACmp (LFn (hdr "age")) OGt (RLit (LNum 18))) (PCons LAnd (ACmp (LFn (hdr "country")) OEq (RLit (q "DK"))) PNil))
                  (TVLit (q "yes")) (TVLit (q "no"))))
  = RV (S "yes").
Proof. vm_compute. reflexivity. Qed.
(** [O.161-165]: outside the braces a [?] and a [:] are text: [1 == 0 ?  : x]. *)
Example doc_ternary_outside_is_text :
  run (hx VNull [("n", VInt 1)]) (PExpr [TFn false (hdr "n"); TText (str " == 0 ? "); TFn false FNull; TText (str " : x")])
  = RV (S "1 == 0 ?  : x").
Proof. vm_compute. reflexivity. Qed.
(** [O.39-40]: [Over three: ${header.n > 3}]. *)
Example doc_predicate_in_template :
  run (hx VNull [("n", VInt 5)]) (PExpr [TText (str "Over three: "); TFn false (FPred (one (ACmp (LFn (hdr "n")) OGt (RLit (LNum 3)))))])
  = RV (S "Over three: true").
Proof. vm_compute. reflexivity. Qed.
(** [O.80-90]: [0001 == 001] is true, [equals] compares text. *)
Example doc_digits_equal :
  run (hx VNull [("a1", S "0001"); ("a2", S "001")]) (PPred (one (ACmp (LFn (hdr "a1")) OEq (RFn (hdr "a2")))))
  = RV (VBool true) /\
  run (hx VNull [("a1", S "0001"); ("a2", S "001")]) (PPred (one (ACmp (LFn (hdr "a1")) OEquals (RFn (hdr "a2")))))
  = RV (VBool false).
Proof. vm_compute. split; reflexivity. Qed.
(** [O.389-392]: an Integer 2 is not in '2.5,3.5' and is in '2.0,3.0'. *)
Example doc_in_numeric :
  run (hx VNull [("n", VInt 2)]) (PPred (one (ACmp (LFn (hdr "n")) OIn (RLit (q "2.5,3.5"))))) = RV (VBool false) /\
  run (hx VNull [("n", VInt 2)]) (PPred (one (ACmp (LFn (hdr "n")) OIn (RLit (q "2.0,3.0"))))) = RV (VBool true).
Proof. vm_compute. split; reflexivity. Qed.
(** [O.278-284]: [!${header.missing}] is true, [!${body}] is false for a body that is set. *)
Example doc_not :
  run (hx (S "x") []) (PPred (one (ANot (hdr "missing")))) = RV (VBool true) /\
  run (hx (S "x") []) (PPred (one (ANot FBody))) = RV (VBool false).
Proof. vm_compute. split; reflexivity. Qed.
(** [O.191-196]: [${header.username} ?: 'Guest']. *)
Example doc_elvis :
  run (hx VNull []) (PElvis (hdr "username") (q "Guest")) = RV (S "Guest") /\
  run (hx VNull [("username", S "")]) (PElvis (hdr "username") (q "Guest")) = RV (S "Guest") /\
  run (hx VNull [("username", S "Bob")]) (PElvis (hdr "username") (q "Guest")) = RV (S "Bob").
Proof. vm_compute. repeat split. Qed.
(** [O.215-219]: [${substringAfter('Hello')} ~> ${trim()} ~> ${uppercase()}] gives [WORLD]. *)
Example doc_chain :
  run (hx (S "Hello World") []) (PChain false (c1 "substringAfter" [ALit (q "Hello")]) [c1 "trim" []; c1 "uppercase" []])
  = RV (S "WORLD").
Proof. vm_compute. reflexivity. Qed.
(** [F.606-610]: substring clips characters. *)
Example doc_substring :
  let x := hx (S "ABCDEFGHIJK") [] in
  run x (ex1 (c1 "substring" [ALit (LNum 3)])) = RV (S "DEFGHIJK") /\
  run x (ex1 (c1 "substring" [ALit (LNum (-3))])) = RV (S "ABCDEFGH") /\
  run x (ex1 (c1 "substring" [ALit (LNum 1); ALit (LNum (-1))])) = RV (S "BCDEFGHIJ") /\
  run x (ex1 (c1 "substring" [ALit (LNum 3); ALit (LNum (-2))])) = RV (S "DEFGHI") /\
  run x (ex1 (c1 "substring" [ALit (LNum 1); ALit (LNum 0)])) = RV (S "BCDEFGHIJK").
Proof. vm_compute. repeat split. Qed.
(** [F.621-629]: before, after, between. *)
Example doc_substring_markers :
  let x := hx (S "Hello great big World how are you") [] in
  run x (ex1 (c1 "substringBefore" [ALit (q "World")])) = RV (S "Hello great big ") /\
  run x (ex1 (c1 "substringAfter" [ALit (q "World")])) = RV (S " how are you") /\
  run x (ex1 (c1 "substringBetween" [ALit (q "great"); ALit (q "how")])) = RV (S " big World ").
Proof. vm_compute. repeat split. Qed.
(** [A.37-99]: the replace examples, with the space around the comma as written there. *)
Example doc_replace_quotes :
  run (hx (S "say ""hi""") []) (ex1 (FCall (str "replace") true (ACons (ALit (bw "&quot;")) (ACons (ALit (bw "&apos;")) ANil))))
  = RV (S "say 'hi'").
Proof. vm_compute. reflexivity. Qed.
(** [F.553-598]: capitalize, pad, escape, contains (ignore case). *)
Example doc_string_functions :
  run (hx VNull []) (ex1 (c1 "capitalize" [ALit (q "hello world")])) = RV (S "Hello World") /\
  run (hx (S "foo") []) (ex1 (c1 "pad" [AFn FBody; ALit (LNum 5)])) = RV (S "foo  ") /\
  run (hx (S "foo") []) (ex1 (c1 "pad" [AFn FBody; ALit (LNum (-5)); ALit (q "@")])) = RV (S "@@foo") /\
  run (hx VNull []) (ex1 (FCall (str "escape") true (ACons (ALit (bw "html")) (ACons (ALit (q "Tom & Jerry")) ANil))))
    = RV (S "Tom &amp; Jerry") /\
  run (hx VNull []) (ex1 (FCall (str "escape") true (ACons (ALit (bw "url")) (ACons (ALit (q "Camel in Action")) ANil))))
    = RV (S "Camel%20in%20Action") /\
  run (hx (S "Hello big World") []) (ex1 (c1 "contains" [ALit (bw "world")])) = RV (VBool true).
Proof. vm_compute. repeat split. Qed.
(** [F.292-296, F.354]: size and isEmpty. *)
Example doc_size_isempty :
  run (hx VNull []) (ex1 (c1 "size" [ALit (q "Hello World")])) = RV (VInt 1) /\
  run (hx VNull []) (ex1 (c1 "size" [])) = RV (VInt 0) /\
  run (hx (VList [str "a"; str "b"; str "c"]) []) (ex1 (c1 "size" [])) = RV (VInt 3) /\
  run (hx (S "") []) (ex1 (c1 "isEmpty" [])) = RV (VBool true).
Proof. vm_compute. repeat split. Qed.
(** [O.328-329]: [${header.bar}++] gives 101 for 100. *)
Example doc_increment :
  run (hx VNull [("bar", VInt 100)]) (PExpr [TPost (hdr "bar") true]) = RV (VInt 101).
Proof. vm_compute. reflexivity. Qed.
