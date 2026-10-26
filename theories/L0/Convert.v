(** * L0 type conversion: the documented contract of Camel's type converter on the value kinds of [val].

    Written from the documentation of apache/camel aa63c0a4cb94 (PIN), not from the code. Legend:
      [TC]    docs/docs/user-manual/modules/ROOT/pages/type-converter.adoc
      [TCJ]   docs/core/camel-api/src/main/java/org/apache/camel/TypeConverter.java (javadoc)
      [MSGJ]  docs/core/camel-api/src/main/java/org/apache/camel/Message.java (javadoc)
      [EXJ]   docs/core/camel-api/src/main/java/org/apache/camel/Exchange.java (javadoc)
      [EXPJ]  docs/core/camel-api/src/main/java/org/apache/camel/Expression.java (javadoc)
      [F]     docs/core/camel-core-languages/src/main/docs/modules/languages/pages/simple-functions.adoc
      [O]     docs/core/camel-core-languages/src/main/docs/modules/languages/pages/simple-operators.adoc
      [VAR]   docs/docs/user-manual/modules/ROOT/pages/variables.adoc
      [UG412] docs/docs/user-manual/modules/ROOT/pages/camel-4x-upgrade-guide-4_12.adoc
      [UG423] docs/docs/user-manual/modules/ROOT/pages/camel-4x-upgrade-guide-4_23.adoc
      [UG424] docs/docs/user-manual/modules/ROOT/pages/camel-4x-upgrade-guide-4_24.adoc

    Two layers. [conv v t] says what the documentation says about converting the value [v] to the Java type [t],
    independent of the API: a value, null, "this value cannot be converted", or UNSPECIFIED. [run a v t] then says
    what each API method returns or throws for it ([TCJ.33-35]: convertTo / mandatoryConvertTo / tryConvertTo; the
    message and exchange accessors that convert [MSGJ], [EXJ]).

    The documentation states very few concrete conversions: [TC] only describes the mechanism, and the concrete
    results come from doc examples ([F.115-130], [O.320], [UG423.2085-2109], [UG424.2458]). Where a documented
    example is generalised (for example "42" -> Integer 42 [F.126-127] to "the canonical decimal text of an
    in-range integer"), the rule says so. Everything else is UNSPECIFIED with a reason; where only the kind of
    outcome is documented (a value of the type, null, or one of the documented exceptions) the rule answers
    [COneOf], which the harness checks as a set of allowed outcomes. *)
From Stdlib Require Import ZArith String Ascii List Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value.

(** ** 1. Target types and API methods *)

(** The requested Java type ([TC.33]: [convertTo(Class<T> type, ...)]): the wrapper types of the value kinds, the
    primitive types [int], [long], [double], [boolean] ([UG423.2085]), [Number] ([UG423.2103]), [BigDecimal]
    ([UG423.2106]), [java.util.List] and [Object] ([EXPJ.49]). *)
Inductive jtype : Type :=
| TString | TInteger | TLong | TDouble | TBoolean
| TPInt | TPLong | TPDouble | TPBoolean
| TNumber | TBigDecimal | TList | TObject.

Definition all_jtypes : list jtype :=
  [TString; TInteger; TLong; TDouble; TBoolean; TPInt; TPLong; TPDouble; TPBoolean; TNumber; TBigDecimal; TList;
   TObject].

(** The Java class name of a type (as the harness loads it; a primitive by its keyword). *)
Definition jname (t : jtype) : string :=
  match t with
  | TString => "java.lang.String" | TInteger => "java.lang.Integer" | TLong => "java.lang.Long"
  | TDouble => "java.lang.Double" | TBoolean => "java.lang.Boolean"
  | TPInt => "int" | TPLong => "long" | TPDouble => "double" | TPBoolean => "boolean"
  | TNumber => "java.lang.Number" | TBigDecimal => "java.math.BigDecimal" | TList => "java.util.List"
  | TObject => "java.lang.Object"
  end.

Definition is_prim (t : jtype) : bool :=
  match t with TPInt | TPLong | TPDouble | TPBoolean => true | _ => false end.

(** The API methods. [AConvert] [TCJ.71], [AMandatory] [TCJ.98], [ATry] [TCJ.126] (the variants with an exchange
    [TCJ.84, 113, 142] have the same documented results); [AGetBody] [MSGJ.307] and [AMandatoryBody] [MSGJ.329] on a
    message whose body is the value; [AGetHeader] [MSGJ.155] and [AGetProperty] [EXJ.467] on a header / exchange
    property set to the value (absent when the value is null). *)
Inductive api : Type := AConvert | AMandatory | ATry | AGetBody | AMandatoryBody | AGetHeader | AGetProperty.

Definition all_apis : list api := [AConvert; AMandatory; ATry; AGetBody; AMandatoryBody; AGetHeader; AGetProperty].

Definition aname (a : api) : string :=
  match a with
  | AConvert => "convertTo" | AMandatory => "mandatoryConvertTo" | ATry => "tryConvertTo"
  | AGetBody => "getBody" | AMandatoryBody => "getMandatoryBody" | AGetHeader => "getHeader"
  | AGetProperty => "getProperty"
  end.

(** The documented exceptions. *)
Definition TCE : string := "org.apache.camel.TypeConversionException".
Definition NTCAE : string := "org.apache.camel.NoTypeConversionAvailableException".
Definition IPE : string := "org.apache.camel.InvalidPayloadException".

(** ** 2. Results

    [CV v]: returns exactly [v] (of the Java class of its kind). [CDec d]: returns a [java.math.BigDecimal]
    numerically equal to [d] (the kind [val] has no BigDecimal; see notes/convert.md). [CNull]: returns null.
    [CFail cls]: throws an exception that is an instance of [cls]. [COneOf os why]: the documentation only fixes the
    set of possible outcomes [os]; [why] says what is not documented. [CUns why]: UNSPECIFIED.

    An outcome [OAnyVal] is "some non-null value of the requested type" (of the wrapper type for a primitive
    [UG423.2085]). *)
Inductive out : Type :=
| OV (v : val)
| ODec (d : dec)
| ONull
| OExc (cls : string)
| OAnyVal.

Inductive cres : Type :=
| CV (v : val)
| CDec (d : dec)
| CNull
| CFail (cls : string)
| COneOf (os : list out) (why : string)
| CUns (why : string).

(** ** 3. Text helpers (no documentation content) *)

Definition in_int (z : Z) : bool := Z.leb (-2147483648) z && Z.leb z 2147483647.
Definition in_long (z : Z) : bool := Z.leb (-9223372036854775808) z && Z.leb z 9223372036854775807.
(** Integers a Double holds exactly. *)
Definition in_dbl_exact (z : Z) : bool := Z.leb (Z.abs z) 9007199254740992.

(** The canonical decimal text of an integer: what [ztext] prints (optional minus, no leading zeros, no "-0"). *)
Definition canon_int (s : chars) : option Z :=
  match parse_dec s with
  | Some (z, O) => if ceqs (ztext z) s then Some z else None
  | _ => None
  end.

(** A plain decimal text: optional minus, an integer part without leading zeros, optionally a dot and digits; not a
    negative zero (which a Double keeps as -0.0 and [val] cannot hold). *)
Definition plain_dec (s : chars) : option dec :=
  let b := match s with "-"%char :: r => r | _ => s end in
  let neg := match s with "-"%char :: _ => true | _ => false end in
  let ip := fst (split_dot b) in
  let ip_ok := match ip with "0"%char :: _ :: _ => false | _ => true end in
  match parse_dec s with
  | Some (m, k) => if ip_ok && negb (neg && Z.eqb m 0) then Some (m, k) else None
  | None => None
  end.

(** The quarters of a decimal, when it is a whole number of quarters. *)
Definition dec_quarters (d : dec) : option Z :=
  let '(m, k) := d in
  let p := Z.pow 10 (Z.of_nat k) in (
  if Z.eqb (Z.modulo (4 * m) p) 0 then Some (Z.div (4 * m) p) else None)%Z.

(** Exponent notation of a whole number, [UG423.2104] "such as [1e5]": a canonical non-negative integer, a lower-case
    [e], and the digits of a non-negative exponent without leading zeros. *)
Definition exp_int (s : chars) : option Z :=
  match find ["e"%char] s with
  | Some i =>
      let mant := firstn i s in let ex := skipn (S i) s in
      match canon_int mant, canon_int ex with
      | Some m, Some e => if Z.leb 0 m && Z.leb 0 e && Z.leb e 18 then Some (m * Z.pow 10 e)%Z else None
      | _, _ => None
      end
  | None => None
  end.

(** A word: letters only, not empty, and not a word that a Java number parser could read as a number (NaN,
    Infinity, in any case). Such a text does not denote a number. *)
Definition wordy (s : chars) : bool :=
  match s with
  | [] => false
  | _ => forallb is_letter s && negb (ceqs (lower s) (str "nan") || ceqs (lower s) (str "infinity"))
  end.

(** A short description of a text that is not a canonical number, used to group UNSPECIFIED reasons. *)
Definition text_kind (s : chars) : string :=
  if blank s then "empty or blank text"
  else if existsb is_ws s then "text with white space"
  else match s with
       | "+"%char :: _ => "text with a plus sign"
       | _ =>
         if existsb (fun c => ceq c "x"%char || ceq c "X"%char) s then "hex-like text"
         else if existsb (fun c => ceq c "e"%char || ceq c "E"%char) s && existsb is_digit s then "exponent text"
         else if existsb (fun c => ceq c "."%char) s && existsb is_digit s then "decimal text"
         else if all_digits (match s with "-"%char :: r => r | _ => s end) then "integer text with leading zeros or -0"
         else "other text"
       end.

(** ** 4. What converting a value to a type gives, independent of the API *)

Inductive conv : Type :=
| KV (v : val)          (* converts to this value *)
| KDec (d : dec)        (* converts to a BigDecimal of this value *)
| KNull                 (* the conversion result is null *)
| KCannot (why : string)(* the value cannot be converted to the type *)
| KUns (why : string).  (* UNSPECIFIED *)

(** The zero of a primitive type: "Camel's type converter returns [0] or [false] for a null value that is converted
    to a primitive type such as [double] or [boolean]" [UG424.2458-2459], in the wrapper type [UG423.2085]. *)
(*! R L0.TC.null_primitive DOC [UG424.2458-2459] [UG423.2085] *)
Definition prim_zero (t : jtype) : val :=
  match t with TPInt => VInt 0 | TPLong => VLong 0 | TPDouble => VDbl 0 | _ => VBool false end.

(** A null value: "null when there is no conversion or the value is null" [TCJ.69]; for a primitive type, its zero
    (rule [null_primitive], the more specific statement; [TCJ.69] does not mention primitives, see notes). *)
(*! R L0.TC.null_value DOC [TCJ.69] [UG424.2458-2459] *)
Definition conv_null (t : jtype) : conv := if is_prim t then KV (prim_zero t) else KNull.

(** To [String]. A String is kept. "if the body is the integer [42], then [${bodyAs(String)}] returns ["42"]"
    [F.115]: an Integer (and, generalised, a Long) converts to its decimal text. A Boolean converts to [true] /
    [false]: "[Over three: ${header.n > 3}] gives [Over three: true]" [O.40]. The text of a Double and of a List is
    not documented. *)
(*! R L0.TC.to_string DOC [F.115] [O.40] *)
Definition conv_string (v : val) : conv :=
  match v with
  | VNull => KNull
  | VStr s => KV (VStr s)
  | VInt z | VLong z => KV (VStr (ztext z))
  | VBool b => KV (VStr (btext b))
  | VDbl _ => KUns "TC: String from a Double (its text is not documented)"
  | VList _ => KUns "TC: String from a List (its text is not documented)"
  end.

(** To an integer type ([Integer]/[int], [Long]/[long]). "if a header [num] contains the string ["42"], then
    [${headerAs(num,Integer)}] returns the integer [42]" [F.126-127], also ["99"] [F.129-130] and ['100'] [O.320]
    ("Camel will type convert ['100'] into the type of [header.bar] and if it is an Integer ['100'] will also be
    converter to an Integer"); "convert a string into a numeric" [O.23-25]. Generalised: the canonical decimal text of
    an integer in the range of the type converts to it. A number converts to the same number when the type holds it
    exactly: [convertTo(int.class, 5L)] gives an Integer [UG423.2085-2087]. A word (letters only) does not denote a
    number and cannot be converted [TCJ.64]. Out-of-range values, fractions, signs, spaces, leading zeros, exponents,
    hex and empty text are not documented. *)
(*! R L0.TC.to_integral DOC [F.126-130] [O.23-25] [O.320] [UG423.2085-2087] [TCJ.64] *)
Definition conv_integral (nm : string) (mk : Z -> val) (lim : Z -> bool) (v : val) : conv :=
  match v with
  | VNull => KNull
  | VInt z | VLong z => if lim z then KV (mk z) else KUns ("TC: " ++ nm ++ " from a number out of its range")
  | VDbl q => if Z.eqb (Z.modulo q 4) 0 && lim (Z.div q 4) then KV (mk (Z.div q 4))
              else KUns ("TC: " ++ nm ++ " from a Double with a fraction or out of range")
  | VStr s => match canon_int s with
              | Some z => if lim z then KV (mk z) else KUns ("TC: " ++ nm ++ " from integer text out of its range")
              | None => if wordy s then KCannot "a word is not a number"
                        else KUns ("TC: " ++ nm ++ " from " ++ text_kind s)
              end
  | VBool _ => KUns ("TC: " ++ nm ++ " from a Boolean")
  | VList _ => KUns ("TC: " ++ nm ++ " from a List")
  end.

(** To [Double]/[double]: as for the integer types ("convert a string into a numeric" [O.23-25], the number rule
    of [UG423.2085-2087]), for a plain decimal text and for an integer that a Double holds exactly. A text whose value
    is not a whole number of quarters is outside what [val] can hold (MODEL). A text whose value a Double does not
    hold exactly (beyond 2^53 quarters) needs rounding, which is not documented (FIX 2026-10-26: the first version
    converted "9223372036854775807" to that exact value, which no Double holds). *)
(*! R L0.TC.to_double DOC [O.23-25] [UG423.2085-2087] [TCJ.64] *)
Definition conv_double (v : val) : conv :=
  match v with
  | VNull => KNull
  | VDbl q => KV (VDbl q)
  | VInt z | VLong z => if in_dbl_exact z then KV (VDbl (4 * z)%Z) else KUns "TC: Double from a long beyond 2^53"
  | VStr s => match plain_dec s with
              | Some d => match dec_quarters d with
                          | Some q => if in_dbl_exact q then KV (VDbl q)
                                      else KUns "TC: Double from a decimal text that a Double does not hold exactly"
                          | None => KUns "MODEL: Double from a decimal text that is not a whole number of quarters"
                          end
              | None => if wordy s then KCannot "a word is not a number" else KUns ("TC: Double from " ++ text_kind s)
              end
  | VBool _ => KUns "TC: Double from a Boolean"
  | VList _ => KUns "TC: Double from a List"
  end.

(** To [Boolean]/[boolean]. A Boolean is kept; the texts [true] and [false] convert to the Boolean ([F.26] the
    [boolean:] result type; "true/false are converted to a boolean" [VAR.298-301]). Every other text, and numbers,
    are not documented ([UG423.2089-2090] says some values "cannot be converted" to [boolean], not which). *)
(*! R L0.TC.to_boolean DOC [F.26] [VAR.298-301] *)
Definition conv_bool (v : val) : conv :=
  match v with
  | VNull => KNull
  | VBool b => KV (VBool b)
  | VStr s => if ceqs s (str "true") then KV (VBool true) else if ceqs s (str "false") then KV (VBool false)
              else KUns "TC: Boolean from text other than true/false"
  | VInt _ | VLong _ | VDbl _ => KUns "TC: Boolean from a number"
  | VList _ => KUns "TC: Boolean from a List"
  end.

(** To [Number]. A number is already a Number (kept, rule [same_type]). "Converting a [String] to a [Number] now
    returns an [Integer] for all values within the [Integer] range (including [Integer.MAX_VALUE] ...), and supports
    exponent notation such as [1e5]" [UG423.2103-2104]. The canonical decimal text of an integer in the Integer range
    gives that Integer (DOC). The rest is read from the code (see the rules below). *)
(*! R L0.TC.to_number DOC [UG423.2103-2104] [TCJ.64] *)
Definition number_int_text (z : Z) : conv := KV (VInt z).

(** Exponent text gives a [Double], not an Integer: [UG423.2104] says the notation is "supported" but not what it
    gives; the first reading here ("all values within the Integer range" give an Integer, so [1e5] -> Integer 100000)
    was not what Camel intends: the commit that wrote [UG423.2103-2104] pins [assertEquals(1e5d,
    ObjectConverter.toNumber("1e5"))] (ObjectConverterTest, 073c6cf7ec20 CAMEL-24976). The doc sentence should say
    so (notes/convert.md). *)
(*! R L0.TC.to_number_exponent DOC-BUG [UG423.2104] ObjectConverter.toNumber(String) 073c6cf7ec20 *)
Definition number_exp_text (z : Z) : conv :=
  if in_dbl_exact z then KV (VDbl (4 * z)%Z) else KUns "UG423: Number from exponent text beyond 2^53".

(** Docs silent: an integer text beyond the Integer range gives a [Long] (in its range), and a decimal text gives a
    [Double]. [ObjectConverter.toNumber(String)]: [Double.parseDouble] when the text has [.], [e] or [E], else
    [Long.parseLong] narrowed to an Integer when in range; pinned by [toNumber("2147483648") = 2147483648L] and
    [toNumber("1.5") = 1.5d] in ObjectConverterTest (073c6cf7ec20 CAMEL-24976). *)
(*! R L0.TC.to_number_long_decimal CODE ObjectConverter.toNumber(String) 073c6cf7ec20 *)
Definition number_other_text (s : chars) : conv :=
  match canon_int s with
  | Some z => if in_long z then KV (VLong z) else KUns "UG423: Number from integer text beyond the Long range"
  | None => match plain_dec s with
            | Some d => match dec_quarters d with
                        | Some q => if in_dbl_exact q then KV (VDbl q)
                                    else KUns "UG423: Number from a decimal text that a Double does not hold exactly"
                        | None => KUns "MODEL: Number from a decimal text that is not a whole number of quarters"
                        end
            | None => KUns ("UG423: Number from " ++ text_kind s)
            end
  end.

Definition conv_number (v : val) : conv :=
  match v with
  | VNull => KNull
  | VInt z => KV (VInt z)
  | VLong z => KV (VLong z)
  | VDbl q => KV (VDbl q)
  | VStr s => match canon_int s with
              | Some z => if in_int z then number_int_text z else number_other_text s
              | None => match exp_int s with
                        | Some z => number_exp_text z
                        | None => if wordy s then KCannot "a word is not a number" else number_other_text s
                        end
              end
  | VBool _ => KUns "TC: Number from a Boolean"
  | VList _ => KUns "TC: Number from a List"
  end.

(** To [BigDecimal]. "A [String] or a [Number] can now be converted to [BigDecimal] ... [${bodyAs(java.math.BigDecimal)}]
    was empty for a body of ["1000.01"] ... A [double] or [float] is converted from its decimal text, so [0.1] becomes
    [0.1]" [UG423.2106-2109]. Read as: a plain decimal text and an integer give that number; a Double gives the number
    its decimal text shows (for [VDbl q], exactly q/4). Other texts are not documented. *)
(*! R L0.TC.to_bigdecimal DOC [UG423.2106-2109] [TCJ.64] *)
Definition conv_bigdec (v : val) : conv :=
  match v with
  | VNull => KNull
  | VInt z | VLong z => KDec (z, O)
  | VDbl q => KDec ((q * 25)%Z, 2%nat)
  | VStr s => match plain_dec s with
              | Some d => KDec d
              | None => if wordy s then KCannot "a word is not a number" else KUns ("UG423: BigDecimal from " ++ text_kind s)
              end
  | VBool _ => KUns "UG423: BigDecimal from a Boolean"
  | VList _ => KUns "UG423: BigDecimal from a List"
  end.

(** A value that already is of the requested type is kept, and [Object] keeps every value ("pass [Object.class] to
    keep it as is" [EXPJ.49]; "Converts the value to the specified type" [TCJ.60]). Converting something else to a
    [List] is not documented. *)
(*! R L0.TC.same_type DOC [EXPJ.49] [TCJ.60-64] *)
Definition conv_list (v : val) : conv :=
  match v with
  | VNull => KNull
  | VList l => KV (VList l)
  | _ => KUns "TC: List from a value that is not a List"
  end.

(** The conversion of a value to a type. *)
(*! R L0.TC.conv DOC [TC.33-38] [TCJ.60-69] *)
Definition conv_of (v : val) (t : jtype) : conv :=
  match v with
  | VNull => conv_null t
  | _ =>
    match t with
    | TString => conv_string v
    | TInteger | TPInt => conv_integral "Integer" VInt in_int v
    | TLong | TPLong => conv_integral "Long" VLong in_long v
    | TDouble | TPDouble => conv_double v
    | TBoolean | TPBoolean => conv_bool v
    | TNumber => conv_number v
    | TBigDecimal => conv_bigdec v
    | TList => conv_list v
    | TObject => KV v
    end
  end.

(** ** 5. The API methods *)

Definition kv_res (k : conv) : option cres :=
  match k with KV v => Some (CV v) | KDec d => Some (CDec d) | _ => None end.

(** [convertTo]: "the converted value, or [null] if not possible to convert"; "[TypeConversionException] is thrown
    if error during type conversion" [TCJ.64-65]; "null when there is no conversion or the value is null" [TCJ.69].
    For a value that cannot be converted the documentation does not say whether that is "not possible" (null) or an
    "error during type conversion" (the exception): both are allowed. When the conversion itself is UNSPECIFIED, the
    documented outcomes still are: a value of the type, null, or [TypeConversionException]. *)
(*! R L0.TC.api_convertTo DOC [TCJ.33] [TCJ.59-71] *)
Definition run_convert (k : conv) : cres :=
  match k with
  | KV v => CV v
  | KDec d => CDec d
  | KNull => CNull
  | KCannot _ => COneOf [ONull; OExc TCE] "TCJ: convertTo of a value that cannot be converted: null or TypeConversionException"
  | KUns w => COneOf [OAnyVal; ONull; OExc TCE] w
  end.

(** [mandatoryConvertTo]: "the converted value, is never [null]"; [TypeConversionException] on an error during
    conversion, [NoTypeConversionAvailableException] "if no type converters exists to convert to the given type"
    [TCJ.92-94, 97]. For a null value (not of a primitive type) the result is not documented beyond "never null".
    [UG412.52-53] (a converter marked [allowNull] may answer null) is about custom converters, outside this model. *)
(*! R L0.TC.api_mandatoryConvertTo DOC [TCJ.34] [TCJ.87-99] *)
Definition run_mandatory (k : conv) : cres :=
  match k with
  | KV v => CV v
  | KDec d => CDec d
  | KNull => COneOf [OAnyVal; OExc TCE; OExc NTCAE] "TCJ: mandatoryConvertTo of null: never null, outcome not documented"
  | KCannot _ => COneOf [OExc TCE; OExc NTCAE] "TCJ: mandatoryConvertTo of a value that cannot be converted: which exception"
  | KUns w => COneOf [OAnyVal; OExc TCE; OExc NTCAE] w
  end.

(** [tryConvertTo]: "returning [null] if not possible to convert"; "will not throw an exception if an exception
    occurred during conversion" [TCJ.117-119, 125]; for [boolean]: "returns [null] instead of throwing an exception
    when the value cannot be converted" [UG423.2089-2090]. *)
(*! R L0.TC.api_tryConvertTo DOC [TCJ.35] [TCJ.116-126] [UG423.2089-2090] *)
Definition run_try (k : conv) : cres :=
  match k with
  | KV v => CV v
  | KDec d => CDec d
  | KNull => CNull
  | KCannot _ => CNull
  | KUns w => COneOf [OAnyVal; ONull] w
  end.

(** [getBody(type)]: "the body of the message as the specified type, or [null] if body does not exist";
    [TypeConversionException] "if error during type conversion" [MSGJ.296-298]; "null when there is no body or no
    conversion" [MSGJ.305]. A null body with a primitive type: [MSGJ.296-297] says null, [UG424.2458] says the
    converter gives the zero; the documentation contradicts itself (UNSPECIFIED). *)
(*! R L0.TC.api_getBody DOC [MSGJ.296-298] [MSGJ.304-305] *)
Definition run_getbody (v : val) (t : jtype) (k : conv) : cres :=
  match v with
  | VNull => if is_prim t then CUns "MSGJ: getBody of a null body as a primitive: null (MSGJ.296) or zero (UG424.2458)"
             else CNull
  | _ => match k with
         | KCannot _ => COneOf [ONull; OExc TCE] "MSGJ: getBody of a body that cannot be converted: null or TypeConversionException"
         | _ => run_convert k
         end
  end.

(** [getMandatoryBody(type)]: "is never [null]"; "[InvalidPayloadException] Is thrown if the body being [null] or
    wrong class type" [MSGJ.321-322]; "throws InvalidPayloadException when the body is null or cannot be converted"
    [MSGJ.327-328]; [mandatoryBodyAs] "will throw an exception if the body is [null]" [F.116]. *)
(*! R L0.TC.api_getMandatoryBody DOC [MSGJ.321-322] [MSGJ.327-328] [F.116] *)
Definition run_mandbody (v : val) (k : conv) : cres :=
  match v with
  | VNull => CFail IPE
  | _ => match k with
         | KV v' => CV v'
         | KDec d => CDec d
         | KNull => CFail IPE
         | KCannot _ => CFail IPE
         | KUns w => COneOf [OAnyVal; OExc IPE] w
         end
  end.

(** [getHeader(name, type)]: "the value of the given header or [null] if there is no header for the given name";
    [TypeConversionException] "if error during type conversion" [MSGJ.144-146]. What it gives for a value with no
    conversion is not documented; null is allowed ([@Nullable], [MSGJ.155]). A null value is modelled as an absent
    header. *)
(*! R L0.TC.api_getHeader DOC [MSGJ.139-155] *)
Definition run_getheader (v : val) (k : conv) : cres :=
  match v with
  | VNull => CNull
  | _ => match k with
         | KV v' => CV v'
         | KDec d => CDec d
         | KNull => CNull
         | KCannot _ => COneOf [ONull; OExc TCE] "MSGJ: getHeader of a value that cannot be converted: null or TypeConversionException"
         | KUns w => COneOf [OAnyVal; ONull; OExc TCE] w
         end
  end.

(** [Exchange.getProperty(name, type)]: "the value of the given property or [null] if there is no property for the
    given name or [null] if it cannot be converted to the given type" [EXJ.464-465]. A null value is modelled as an
    absent property. "Cannot be converted" is read as "there is no conversion" (null); an error inside a converter
    (the [TypeConversionException] of [TCJ.65]) is not mentioned, so a value the rules call [KCannot] gives null or
    that exception (FIX 2026-10-26: the first version answered null for it, reading "cannot be converted" as
    covering converter errors; the javadoc misses the [@throws] that [MSGJ.146] has, see notes). *)
(*! R L0.TC.api_getProperty DOC [EXJ.459-467] *)
Definition run_getprop (v : val) (k : conv) : cres :=
  match v with
  | VNull => CNull
  | _ => match k with
         | KV v' => CV v'
         | KDec d => CDec d
         | KNull => CNull
         | KCannot _ => COneOf [ONull; OExc TCE] "EXJ: getProperty of a value whose converter fails: null or TypeConversionException"
         | KUns w => COneOf [OAnyVal; ONull; OExc TCE] w
         end
  end.

(** An absent header or property read as [boolean] gives [false], not null as [MSGJ.144-145] and [EXJ.464] say.
    Deliberate: [DefaultMessage.getHeader(String, Class)] and [AbstractExchange.evalPropertyValue] return
    [Boolean.FALSE] for [boolean.class] ("let's avoid NullPointerException when converting to boolean for null
    values"); pinned by [assertEquals(Boolean.FALSE, exchange.getProperty("beer", boolean.class))]
    (DefaultExchangeTest) and [assertFalse(in.getHeader("someproperty", boolean.class))] (Issue3Test), both at
    aa63c0a4cb94 (the history before 025f7cb97232, the root of the local clone, is not available). *)
(*! R L0.TC.absent_boolean DOC-BUG [MSGJ.144-145] [EXJ.464] DefaultMessage.getHeader AbstractExchange.evalPropertyValue *)
Definition absent_as (t : jtype) (r : cres) : cres :=
  match t with TPBoolean => CV (VBool false) | _ => r end.

Definition run (a : api) (v : val) (t : jtype) : cres :=
  let k := conv_of v t in
  match a with
  | AConvert => run_convert k
  | AMandatory => run_mandatory k
  | ATry => run_try k
  | AGetBody => run_getbody v t k
  | AMandatoryBody => run_mandbody v k
  | AGetHeader => match v with VNull => absent_as t CNull | _ => run_getheader v k end
  | AGetProperty => match v with VNull => absent_as t CNull | _ => run_getprop v k end
  end.

(** ** 6. Properties of the rules *)

Definition may_throw (r : cres) : bool :=
  match r with
  | CFail _ => true
  | COneOf os _ => existsb (fun o => match o with OExc _ => true | _ => false end) os
  | CUns _ => true
  | _ => false
  end.
Definition may_null (r : cres) : bool :=
  match r with
  | CNull => true
  | COneOf os _ => existsb (fun o => match o with ONull => true | _ => false end) os
  | CUns _ => true
  | _ => false
  end.

(** [tryConvertTo] never throws [TCJ.119]. *)
Lemma try_never_throws : forall v t, may_throw (run ATry v t) = false.
Proof. intros v t. unfold run, run_try. destruct (conv_of v t); reflexivity. Qed.

(** [mandatoryConvertTo] and [getMandatoryBody] never return null [TCJ.92], [MSGJ.321]. *)
Lemma mandatory_never_null : forall v t, may_null (run AMandatory v t) = false.
Proof. intros v t. unfold run, run_mandatory. destruct (conv_of v t); reflexivity. Qed.
Lemma mandatory_body_never_null : forall v t, may_null (run AMandatoryBody v t) = false.
Proof. intros v t. unfold run, run_mandbody. destruct v; try reflexivity; destruct (conv_of _ t); reflexivity. Qed.

(** ** 7. Documented examples *)

Definition vs (s : string) : val := VStr (str s).

(** "if the body is the integer [42], then [${bodyAs(String)}] returns ["42"] as a String" [F.115]. *)
Example doc_bodyAs_string : run AGetBody (VInt 42) TString = CV (vs "42").
Proof. vm_compute. reflexivity. Qed.
(** "[${mandatoryBodyAs(Integer)}] will throw an exception if the body is [null]" [F.116]. *)
Example doc_mandatoryBodyAs_null : run AMandatoryBody VNull TInteger = CFail IPE.
Proof. vm_compute. reflexivity. Qed.
(** "if a header [num] contains the string ["42"], then [${headerAs(num,Integer)}] returns the integer [42]"
    [F.126-127]. *)
Example doc_headerAs_integer : run AGetHeader (vs "42") TInteger = CV (VInt 42).
Proof. vm_compute. reflexivity. Qed.
(** "If a variable [num] contains ["99"], then [${variableAs(num,Integer)}] returns the integer [99]" [F.129-130]
    (variables are not modelled; the conversion is). *)
Example doc_variableAs_integer : conv_of (vs "99") TInteger = KV (VInt 99).
Proof. vm_compute. reflexivity. Qed.
(** "if it is an Integer ['100'] will also be converter to an Integer" [O.320]. *)
Example doc_operator_rhs_integer : conv_of (vs "100") TInteger = KV (VInt 100).
Proof. vm_compute. reflexivity. Qed.
(** "[Over three: ${header.n > 3}] gives [Over three: true]" [O.40]. *)
Example doc_boolean_text : conv_of (VBool true) TString = KV (vs "true").
Proof. vm_compute. reflexivity. Qed.
(** "[convertTo(int.class, 5L)] returned a [Long]" before; now "the matching wrapper type" [UG423.2085-2087]. *)
Example doc_int_of_long : run AConvert (VLong 5) TPInt = CV (VInt 5).
Proof. vm_compute. reflexivity. Qed.
(** "an [Integer] for all values within the [Integer] range (including [Integer.MAX_VALUE] ...)" [UG423.2103-2104]. *)
Example doc_number_max_int : run AConvert (vs "2147483647") TNumber = CV (VInt 2147483647).
Proof. vm_compute. reflexivity. Qed.
(** "supports exponent notation such as [1e5]" [UG423.2104]; the result is a Double (rule [to_number_exponent],
    DOC-BUG: the sentence does not say which type, and the first reading, Integer, was not the intent). *)
Example doc_number_exponent : run AConvert (vs "1e5") TNumber = CV (VDbl 400000).
Proof. vm_compute. reflexivity. Qed.
(** "[${bodyAs(java.math.BigDecimal)}] was empty for a body of ["1000.01"]" (now converts) [UG423.2106-2107]. *)
Example doc_bigdecimal_text : run AGetBody (vs "1000.01") TBigDecimal = CDec (100001%Z, 2%nat).
Proof. vm_compute. reflexivity. Qed.
(** "Camel's type converter returns [0] or [false] for a null value that is converted to a primitive type such as
    [double] or [boolean]" [UG424.2458-2459]. *)
Example doc_null_double : run AConvert VNull TPDouble = CV (VDbl 0).
Proof. vm_compute. reflexivity. Qed.
Example doc_null_boolean : run AConvert VNull TPBoolean = CV (VBool false).
Proof. vm_compute. reflexivity. Qed.
(** "null when there is no conversion or the value is null" [TCJ.69]. *)
Example doc_convert_null : run AConvert VNull TString = CNull.
Proof. vm_compute. reflexivity. Qed.
(** Not reproducible: "[0.1] becomes [0.1]" [UG423.2108-2109] (0.1 is not a whole number of quarters, so [val] cannot
    hold the Double 0.1); the same rule on 0.25: *)
Example doc_bigdecimal_double_quarter : run AConvert (VDbl 1) TBigDecimal = CDec (25%Z, 2%nat).
Proof. vm_compute. reflexivity. Qed.
