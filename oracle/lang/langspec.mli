
val negb : bool -> bool

type ('a, 'b) sum =
| Inl of 'a
| Inr of 'b

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
  val ltb : int -> int -> bool
 end

module Pos :
 sig
  val succ : Big_int_Z.big_int -> Big_int_Z.big_int

  val add : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val add_carry : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

  val pred_double : Big_int_Z.big_int -> Big_int_Z.big_int

  val mul : Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int

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

val tl : 'a1 list -> 'a1 list

val rev : 'a1 list -> 'a1 list

val fold_right : ('a2 -> 'a1 -> 'a1) -> 'a1 -> 'a2 list -> 'a1

val existsb : ('a1 -> bool) -> 'a1 list -> bool

val forallb : ('a1 -> bool) -> 'a1 list -> bool

val filter : ('a1 -> bool) -> 'a1 list -> 'a1 list

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

val suffix : chars -> chars -> bool

val find_from : chars -> chars -> int -> int option

val find : chars -> chars -> int option

val occurs : chars -> chars -> bool

val repl : int -> chars -> chars -> chars -> chars

val replace_all : chars -> chars -> chars -> chars

val code : char -> int

val is_upper : char -> bool

val is_lower : char -> bool

val is_digit : char -> bool

val is_letter : char -> bool

val lowc : char -> char

val upc : char -> char

val lower : chars -> chars

val is_ws : char -> bool

val drop_ws : chars -> chars

val trim : chars -> chars

val split_on : char -> chars -> chars list

val concat_with : chars -> chars list -> chars

val repeat_c : char -> int -> chars

val pos_digits : int -> Big_int_Z.big_int -> chars -> chars

val ztext : Big_int_Z.big_int -> chars

val digits_val : chars -> Big_int_Z.big_int -> Big_int_Z.big_int

val all_digits : chars -> bool

type kv = (chars * chars) list

val klookup : chars -> kv -> chars option

type penv = { pe_override : kv; pe_env : kv; pe_sys : kv; pe_initial : 
              kv; pe_nested : bool; pe_fallback : bool }

type pres =
| PV of chars
| PFail of chars
| PUns of string

val iae : pres

val pbind : pres -> (chars -> pres) -> pres

val bsl : char

val lbr : char

val rbr : char

val oPEN : chars

val cLOSE : chars

type tok =
| TC of char
| TOpen
| TClose
| TLit of chars
| TBad of string

val bs_run : chars -> int * chars

val lex : int -> chars -> tok list

type seg =
| SText of chars
| SPh of chars
| SBad of string

val ph_body : tok list -> chars -> ((chars * tok list) option, string) sum

val segs : int -> tok list -> seg list

val parse : chars -> seg list

val has_brackets : chars -> bool

val has_escape : chars -> bool

val is_keyc : char -> bool

val good_key : chars -> bool

val env_spelling : chars -> chars

type lk =
| LFound of chars * bool
| LMissing
| LUns of string

val lookup_key : penv -> chars -> lk

val split_colon : chars -> chars * chars option

val use_value :
  (chars list -> chars -> pres) -> penv -> chars list -> chars -> bool ->
  chars -> bool -> pres

val missing : chars option -> pres

val f_env : penv -> chars -> chars option -> pres

val f_sys : penv -> chars -> chars option -> pres

val is_envc : char -> bool

val f_service : penv -> int -> chars -> chars option -> pres

val ph : (chars list -> chars -> pres) -> penv -> chars list -> chars -> pres

val res_text : int -> penv -> chars list -> chars -> pres

val resolve : penv -> chars -> pres

type val0 =
| VNull
| VStr of chars
| VInt of Big_int_Z.big_int
| VLong of Big_int_Z.big_int
| VDbl of Big_int_Z.big_int
| VBool of bool
| VList of chars list

val dbltext : Big_int_Z.big_int -> chars

val btext : bool -> chars

val text_of : val0 -> chars option

type regobj =
| RgExpr of val0
| RgPred of bool
| RgOther of val0

type lenv = { le_body : val0; le_headers : (chars * val0) list;
              le_xprops : (chars * val0) list; le_vars : (chars * val0) list;
              le_gvars : (chars * val0) list;
              le_groups : (chars * (chars * val0) list) list;
              le_reg : (chars * regobj) list; le_pp : penv }

type lres =
| LV of val0
| LErr of chars
| LUns0 of string

type look =
| Found of val0
| Absent
| Amb of string

val cilookup : chars -> (chars * val0) list -> look

val exact : chars -> (chars * val0) list -> val0 option

val exlookup : string -> chars -> (chars * val0) list -> look

val etext : bool -> chars -> chars

val name_guard : string -> chars -> string option

val str_truth : chars -> bool

val as_pred : lres -> lres

val ev_constant : lenv -> chars -> chars option -> bool -> lres

val ev_header : lenv -> chars -> bool -> lres

val ev_prop : lenv -> chars -> bool -> lres

val ev_var : lenv -> chars -> bool -> lres

val ev_ref : lenv -> chars -> chars option -> bool -> bool -> lres

type tkopts = { tk_token : chars; tk_end : chars option; tk_regex : bool;
                tk_xml : bool; tk_incl : bool; tk_group : chars option;
                tk_gdelim : chars option; tk_skip : bool;
                tk_source : chars option; tk_inherit : chars option }

val nl : char

val tok_text : string -> bool -> chars -> (chars, string) sum

val is_meta : char -> bool

type ratom = { ra_set : chars; ra_plus : bool }

val parse_re : chars -> ratom option

val ra_len : ratom -> chars -> int

val split_by : int -> (chars -> int) -> chars -> chars -> chars list

val lit_match : chars -> chars -> int

val pairs : int -> chars -> chars -> chars -> bool -> (chars list, string) sum

val chunks : int -> int -> chars list -> chars list list

val tk_input : lenv -> tkopts -> (val0, string) sum

val ev_tokenize : lenv -> tkopts -> chars option -> lres

type lexp =
| XConstant of chars * chars option * bool
| XHeader of chars * bool
| XProp of chars * bool
| XVar of chars * bool
| XRef of chars * chars option * bool
| XTokenize of tkopts * chars option

val eval : lenv -> lexp -> lres

val evalp : lenv -> lexp -> lres
