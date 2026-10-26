
val negb : bool -> bool

val fst : ('a1 * 'a2) -> 'a1

val length : 'a1 list -> int

val app : 'a1 list -> 'a1 list -> 'a1 list

type comparison =
| Eq
| Lt
| Gt

val add : int -> int -> int

val sub : int -> int -> int

module Nat :
 sig
 end

module Pos :
 sig
  val succ : Big_int_Z.big_int -> Big_int_Z.big_int

  val add : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val add_carry : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val pred_double : Big_int_Z.big_int -> Big_int_Z.big_int

  val mul : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val iter : ('a1 -> 'a1) -> 'a1 -> Big_int_Z.big_int -> 'a1

  val compare_cont :
    comparison -> Big_int_Z.big_int -> Big_int_Z.big_int -> comparison

  val compare : Big_int_Z.big_int -> Big_int_Z.big_int -> comparison

  val eqb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool

  val iter_op : ('a1 -> 'a1 -> 'a1) -> Big_int_Z.big_int -> 'a1 -> 'a1

  val to_nat : Big_int_Z.big_int -> int

  val of_succ_nat : int -> Big_int_Z.big_int
 end

module Coq_Pos :
 sig
  val succ : Big_int_Z.big_int -> Big_int_Z.big_int

  val add : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val add_carry : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val mul : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int
 end

module N :
 sig
  val add : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val mul : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val to_nat : Big_int_Z.big_int -> int

  val of_nat : int -> Big_int_Z.big_int
 end

module Z :
 sig
  val double : Big_int_Z.big_int -> Big_int_Z.big_int

  val succ_double : Big_int_Z.big_int -> Big_int_Z.big_int

  val pred_double : Big_int_Z.big_int -> Big_int_Z.big_int

  val pos_sub : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val add : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val opp : Big_int_Z.big_int -> Big_int_Z.big_int

  val sub : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val mul : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val pow_pos : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val pow : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val compare : Big_int_Z.big_int -> Big_int_Z.big_int -> comparison

  val leb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool

  val ltb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool

  val eqb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool

  val to_nat : Big_int_Z.big_int -> int

  val of_nat : int -> Big_int_Z.big_int

  val pos_div_eucl :
    Big_int_Z.big_int -> Big_int_Z.big_int ->
    Big_int_Z.big_int * Big_int_Z.big_int

  val div_eucl :
    Big_int_Z.big_int -> Big_int_Z.big_int ->
    Big_int_Z.big_int * Big_int_Z.big_int

  val div : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val modulo : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val abs : Big_int_Z.big_int -> Big_int_Z.big_int
 end

val map : ('a1 -> 'a2) -> 'a1 list -> 'a2 list

val firstn : int -> 'a1 list -> 'a1 list

val skipn : int -> 'a1 list -> 'a1 list

val existsb : ('a1 -> bool) -> 'a1 list -> bool

val forallb : ('a1 -> bool) -> 'a1 list -> bool

val zero : char

val one : char

val shift : bool -> char -> char

val ascii_of_pos : Big_int_Z.big_int -> char

val ascii_of_N : Big_int_Z.big_int -> char

val ascii_of_nat : int -> char

val n_of_digits : bool list -> Big_int_Z.big_int

val n_of_ascii : char -> Big_int_Z.big_int

val nat_of_ascii : char -> int

type chars = char list

val str : string -> chars

val ceq : char -> char -> bool

val ceqs : chars -> chars -> bool

val prefix : chars -> chars -> bool

val find_from : chars -> chars -> int -> int option

val find : chars -> chars -> int option

val code : char -> int

val is_upper : char -> bool

val is_lower : char -> bool

val is_digit : char -> bool

val is_letter : char -> bool

val lowc : char -> char

val lower : chars -> chars

val is_ws : char -> bool

val blank : chars -> bool

val pos_digits : int -> Big_int_Z.big_int -> chars -> chars

val ztext : Big_int_Z.big_int -> chars

val digits_val : chars -> Big_int_Z.big_int -> Big_int_Z.big_int

val all_digits : chars -> bool

val split_dot : chars -> chars * chars option

type dec = Big_int_Z.big_int * int

val parse_dec : chars -> dec option

type val0 =
| VNull
| VStr of chars
| VInt of Big_int_Z.big_int
| VLong of Big_int_Z.big_int
| VDbl of Big_int_Z.big_int
| VBool of bool
| VList of chars list

val btext : bool -> chars

type jtype =
| TString
| TInteger
| TLong
| TDouble
| TBoolean
| TPInt
| TPLong
| TPDouble
| TPBoolean
| TNumber
| TBigDecimal
| TList
| TObject

val all_jtypes : jtype list

val jname : jtype -> string

val is_prim : jtype -> bool

type api =
| AConvert
| AMandatory
| ATry
| AGetBody
| AMandatoryBody
| AGetHeader
| AGetProperty

val all_apis : api list

val aname : api -> string

val tCE : string

val nTCAE : string

val iPE : string

type out =
| OV of val0
| ODec of dec
| ONull
| OExc of string
| OAnyVal

type cres =
| CV of val0
| CDec of dec
| CNull
| CFail of string
| COneOf of out list * string
| CUns of string

val in_int : Big_int_Z.big_int -> bool

val in_long : Big_int_Z.big_int -> bool

val in_dbl_exact : Big_int_Z.big_int -> bool

val canon_int : chars -> Big_int_Z.big_int option

val plain_dec : chars -> dec option

val dec_quarters : dec -> Big_int_Z.big_int option

val exp_int : chars -> Big_int_Z.big_int option

val wordy : chars -> bool

val text_kind : chars -> string

type conv =
| KV of val0
| KDec of dec
| KNull
| KCannot of string
| KUns of string

val prim_zero : jtype -> val0

val conv_null : jtype -> conv

val conv_string : val0 -> conv

val conv_integral :
  string -> (Big_int_Z.big_int -> val0) -> (Big_int_Z.big_int -> bool) -> val0
  -> conv

val conv_double : val0 -> conv

val conv_bool : val0 -> conv

val number_int_text : Big_int_Z.big_int -> conv

val number_exp_text : Big_int_Z.big_int -> conv

val number_other_text : chars -> conv

val conv_number : val0 -> conv

val conv_bigdec : val0 -> conv

val conv_list : val0 -> conv

val conv_of : val0 -> jtype -> conv

val run_convert : conv -> cres

val run_mandatory : conv -> cres

val run_try : conv -> cres

val run_getbody : val0 -> jtype -> conv -> cres

val run_mandbody : val0 -> conv -> cres

val run_getheader : val0 -> conv -> cres

val run_getprop : val0 -> conv -> cres

val absent_as : jtype -> cres -> cres

val run : api -> val0 -> jtype -> cres
