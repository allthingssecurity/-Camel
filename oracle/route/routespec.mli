
val negb : bool -> bool

val option_map : ('a1 -> 'a2) -> 'a1 option -> 'a2 option

type ('a, 'b) sum =
| Inl of 'a
| Inr of 'b

val fst : ('a1 * 'a2) -> 'a1

val snd : ('a1 * 'a2) -> 'a2

val length : 'a1 list -> int

val app : 'a1 list -> 'a1 list -> 'a1 list

type comparison =
| Eq
| Lt
| Gt

val add : int -> int -> int

val mul : int -> int -> int

val sub : int -> int -> int

val eqb : bool -> bool -> bool

module Nat :
 sig
  val sub : int -> int -> int

  val ltb : int -> int -> bool

  val compare : int -> int -> comparison

  val min : int -> int -> int

  val divmod : int -> int -> int -> int -> int * int

  val div : int -> int -> int

  val modulo : int -> int -> int
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

val tl : 'a1 list -> 'a1 list

val nth_error : 'a1 list -> int -> 'a1 option

val removelast : 'a1 list -> 'a1 list

val rev : 'a1 list -> 'a1 list

val concat : 'a1 list list -> 'a1 list

val fold_left : ('a1 -> 'a2 -> 'a1) -> 'a2 list -> 'a1 -> 'a1

val fold_right : ('a2 -> 'a1 -> 'a1) -> 'a1 -> 'a2 list -> 'a1

val existsb : ('a1 -> bool) -> 'a1 list -> bool

val forallb : ('a1 -> bool) -> 'a1 list -> bool

val filter : ('a1 -> bool) -> 'a1 list -> 'a1 list

val find : ('a1 -> bool) -> 'a1 list -> 'a1 option

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

val find0 : chars -> chars -> int option

val occurs : chars -> chars -> bool

val count_occ : chars -> chars -> int

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

val upper : chars -> chars

val is_ws : char -> bool

val drop_ws : chars -> chars

val trim : chars -> chars

val blank : chars -> bool

val scmp : chars -> chars -> comparison

val split_on : char -> chars -> chars list

val concat_with : chars -> chars list -> chars

val repeat_c : char -> int -> chars

val pos_digits : int -> Big_int_Z.big_int -> chars -> chars

val ztext : Big_int_Z.big_int -> chars

val digits_val : chars -> Big_int_Z.big_int -> Big_int_Z.big_int

val all_digits : chars -> bool

val split_dot : chars -> chars * chars option

type dec = Big_int_Z.big_int * int

val parse_dec : chars -> dec option

val qcmp : dec -> dec -> comparison

type val0 =
| VNull
| VStr of chars
| VInt of Big_int_Z.big_int
| VLong of Big_int_Z.big_int
| VDbl of Big_int_Z.big_int
| VBool of bool
| VList of chars list

val dbltext : Big_int_Z.big_int -> chars

val num_of : val0 -> dec option

val is_num : val0 -> bool

val btext : bool -> chars

val text_of : val0 -> chars option

val ascii_name : chars -> bool

val ieq : chars -> chars -> bool

type 'a r0 =
| Ok0 of 'a
| Uns0 of string

val hget : chars -> (chars * val0) list -> val0

val hset : chars -> val0 -> (chars * val0) list -> (chars * val0) list

val hremove : chars -> (chars * val0) list -> (chars * val0) list

val is_meta : char -> bool

val pmatch : chars -> chars -> bool r0

val any_match : chars list -> chars -> bool r0

val hremove_pat :
  chars -> chars list -> (chars * val0) list -> (chars * val0) list r0

val pset : chars -> val0 -> (chars * val0) list -> (chars * val0) list

val premove : chars -> (chars * val0) list -> (chars * val0) list

val pput : chars -> val0 -> (chars * val0) list -> (chars * val0) list

type vscope =
| VExchange
| VGlobal
| VRoute of chars
| VGroup of chars

val strip : chars -> chars -> chars option

val split_colon : chars -> (chars * chars) option

val vname : chars -> (vscope * chars) r0

val ceqsl : chars list -> chars list -> bool

val veqb : val0 -> val0 -> bool

val kveqb : (chars * val0) list -> (chars * val0) list -> bool

type exn =
| MkExnS of chars * chars * exn option * exn list

val mkExn : chars -> chars -> exn option -> exn

val exn_class : exn -> chars

val exn_msg : exn -> chars

val add_suppressed : exn -> exn -> exn

val exn_chain : exn -> exn list

val jdk_super : chars -> chars option option

val instance_of_f : int -> chars -> chars -> bool r0

val instance_of : chars -> chars -> bool r0

type mep =
| InOnly
| InOut

type message = { m_body : val0; m_headers : (chars * val0) list }

type exchange = { x_msg : message; x_props : (chars * val0) list;
                  x_vars : (chars * val0) list; x_mep : mep;
                  x_exn : exn option; x_stop : bool; x_eh : bool;
                  x_seen : bool; x_done : bool; x_uow : (chars * chars) list;
                  x_orig : message option; x_route : chars; x_cont : 
                  bool }

type agroup = { ag_x : exchange; ag_n : int; ag_in : exchange list }

type gstate = { g_global : (chars * val0) list;
                g_route : (chars * (chars * val0) list) list;
                g_group : (chars * (chars * val0) list) list;
                g_agg : (chars * (chars * agroup) list) list;
                g_closed : (chars * chars list) list;
                g_cnt : (chars * int) list }

val g0 : gstate

val new_exchange : mep -> val0 -> (chars * val0) list -> exchange

val set_route : exchange -> chars -> exchange

val set_cont : exchange -> bool -> exchange

val with_msg : exchange -> message -> exchange

val set_body : exchange -> val0 -> exchange

val map_headers :
  ((chars * val0) list -> (chars * val0) list) -> exchange -> exchange

val map_props :
  ((chars * val0) list -> (chars * val0) list) -> exchange -> exchange

val map_vars :
  ((chars * val0) list -> (chars * val0) list) -> exchange -> exchange

val set_exn : exchange -> exn option -> exchange

val set_stop : exchange -> bool -> exchange

val set_eh : exchange -> bool -> exchange

val set_seen : exchange -> bool -> exchange

val set_done : exchange -> bool -> exchange

val aget : chars -> (chars * (chars * val0) list) list -> (chars * val0) list

val aset :
  chars -> (chars * val0) list -> (chars * (chars * val0) list) list ->
  (chars * (chars * val0) list) list

val var_set : exchange -> gstate -> chars -> val0 -> (exchange * gstate) r0

val var_remove : exchange -> gstate -> chars -> (exchange * gstate) r0

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

val jname : jtype -> string

val is_prim : jtype -> bool

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

type exch = { ex_body : val0; ex_headers : (chars * val0) list;
              ex_props : (chars * val0) list; ex_vars : (chars * val0) list }

val lookup : chars -> (chars * val0) list -> val0

val with_body : exch -> val0 -> exch

type res =
| RV of val0
| RLoose of chars
| RErr
| RUns of string

val bind : res -> (val0 -> res) -> res

val bind_text : res -> (chars -> res) -> res

type lit =
| LQ of chars
| LNum of Big_int_Z.big_int
| LNull
| LTrue
| LFalse
| LBare of chars

type binop =
| OEq
| ONe
| OEqIc
| ONeIc
| OGt
| OGe
| OLt
| OLe
| OCIc
| ONCIc
| OContains
| ONContains
| OEnds
| ONEnds
| OEquals
| ONEquals
| OIn
| ONIn
| OIs
| ONIs
| ORange
| ONRange
| ORegex
| ONRegex
| OStarts
| ONStarts

val opstr : binop -> chars

type lop =
| LAnd
| LOr

type fn =
| FBody
| FHeader of int * chars
| FProp of int * chars
| FVar of chars
| FNull
| FHeadersSize
| FTyped of int * fn
| FCall of chars * bool * args
| FPred of pseq
| FTern of pseq * tval * tval
and args =
| ANil
| ACons of arg * args
and arg =
| AFn of fn
| ALit of lit
| APred of pseq
and tval =
| TVLit of lit
| TVFn of fn
and atom =
| ACmp of lhs * binop * rhs
| ANot of fn
| AFun of fn
| ANot2 of fn
and lhs =
| LFn of fn
| LInc of fn
| LDecr of fn
| LNotFn of fn
and rhs =
| RLit of lit
| RFn of fn
| RNot of fn
and pseq =
| PS of atom * prest
and prest =
| PNil
| PCons of lop * atom * prest

type part =
| TText of chars
| TFn of bool * fn
| TPost of fn * bool

type prog =
| PExpr of part list
| PPred of pseq
| PElvis of fn * lit
| PChain of bool * fn * fn list

val dq : chars

val rlit : lit -> chars

val typed_prefix : int -> chars

val rfn : fn -> chars

val rargs : bool -> args -> chars

val rarg : arg -> chars

val rtv : tval -> chars

val ratom : bool -> atom -> chars

val rlhs : bool -> lhs -> chars

val rrhs : rhs -> chars

val rps : bool -> pseq -> chars

val rprest : bool -> prest -> chars

val rpart : part -> chars

val render : prog -> chars

val is_predicate : prog -> bool

val unesc : bool -> chars -> chars option

val arg_lit_ok : chars -> bool

val q_value : bool -> chars -> res

val xml_ents : chars -> chars

val capitalize : chars -> res

val normalize_ws : chars -> res

val dquote : char

val quote_f : chars -> res

val unquote_f : chars -> res

val substring1 : Big_int_Z.big_int -> chars -> res

val substring2 : Big_int_Z.big_int -> Big_int_Z.big_int -> chars -> res

val sub_before : chars -> chars -> res

val sub_after : chars -> chars -> res

val sub_between : chars -> chars -> chars -> res

val pad_f : chars -> Big_int_Z.big_int -> chars -> res

val hexd : int -> char

val is_unreserved : char -> bool

val is_reserved : char -> bool

val esc_map : (char -> chars option) -> chars -> chars option

val esc_xml : char -> chars option

val esc_html : char -> chars option

val esc_sql : char -> chars option

val esc_json : char -> chars option

val esc_url : char -> chars option

val escape_f : chars -> chars -> res

val all_of : (char -> bool) -> chars -> res

type bres =
| BV of bool
| BErr
| BUns of string

val truth : val0 -> bres

val elvis_truth : val0 -> bres

val to_bool : val0 -> bool option option

val eqv : val0 -> val0 -> bool option

val ordv : val0 -> val0 -> comparison option

val has_double_comma : chars -> bool

val set_items : chars -> chars list option

val in_set : val0 -> chars -> bool option

val is_type : val0 -> chars -> bool option

val in_range : val0 -> chars -> bool option

type reatom =
| RAny
| RDigit
| RCh of char
| RCls of char * char

type rquant =
| QOne
| QStar
| QPlus
| QRep of int

val rmatch1 : reatom -> char -> bool

val rparse : int -> chars -> (reatom * rquant) list option

val take_while_n : (char -> bool) -> int -> chars -> bool

val rmatch : int -> (reatom * rquant) list -> chars -> bool

val regex_f : val0 -> chars -> bool option

val string_op : (chars -> chars -> bool) -> val0 -> val0 -> bres

val of_opt : string -> bool option -> bres

val neg : bres -> bres

val num_of_trim : val0 -> dec option

val text_value_split : binop -> val0 -> val0 -> string option

val binop_eval : binop -> val0 -> val0 -> bool -> bres

val all_same : lop list -> lop option

val ltr : bool -> (lop * bool) list -> bool

val prec_terms : bool -> (lop * bool) list -> bool list

val find_uns : bres list -> string option

val combine_seq : bres -> (lop * bres) list -> bres

val is_afun : atom -> bool

val has_rest : prest -> bool

val rest_has_afun : prest -> bool

val in_int0 : Big_int_Z.big_int -> bool

val typed : int -> val0 -> res

type argv =
| AV of res * int
| AP of bres

val lit_arg : lit -> argv

val lit_rhs : bool -> lit -> res * bool

val tern_lit : lit -> res

val incdec : bool -> res -> res

val nm : chars -> string -> bool

val arity : res

val body_text : exch -> (chars -> res) -> res

val one_text : exch -> argv list -> (chars -> res) -> res

val one_val : exch -> argv list -> (val0 -> res) -> res

val with_int : res -> (Big_int_Z.big_int -> res) -> res

val pv : bres -> res

val call : exch -> chars -> argv list -> res

val ev : exch -> fn -> res

val evargs : exch -> args -> argv list

val evarg : exch -> arg -> argv

val evtv : exch -> tval -> res

val evatom : bool -> exch -> atom -> bres

val evlhs : bool -> exch -> lhs -> res

val evrhs : bool -> exch -> rhs -> res * bool

val evps : bool -> exch -> pseq -> bres

val evrest : bool -> exch -> prest -> (lop * bres) list

val vtext : res -> (chars option, string) sum

val template : exch -> part list -> res

val elvis_default : lit -> res

val chain : bool -> exch -> res -> fn list -> res

val nargs : args -> int

val arity_ok : chars -> int -> bool -> bool

val first_is_pred : args -> bool

val orelse : string option -> string option -> string option

val chk_lit : bool -> bool -> lit -> string option

val is_typed : fn -> bool

val is_pred_fn : fn -> bool

val is_lone : atom -> bool

val args_have_fn : args -> bool

val atom_nested_call : atom -> bool

val rest_nested_call : prest -> bool

val ps_nested_call : pseq -> bool

val splits_args : chars -> bool

val args_nested_comma : args -> bool

val args_nested_quoted_pred : args -> bool

val args_have_brace_escape : args -> bool

val chkop : binop -> rhs -> string option

val chkf : fn -> string option

val chkargs : bool -> args -> string option

val chkps_infn : pseq -> string option

val chkrest_infn : prest -> string option

val chkatom_infn : bool -> atom -> string option

val chka : arg -> string option

val chktv : tval -> string option

val chkatom : bool -> bool -> atom -> string option

val chkl : bool -> bool -> lhs -> string option

val chkr : bool -> rhs -> string option

val chkps : bool -> pseq -> string option

val chkrest : bool -> prest -> string option

val chkpart : part -> string option

val chkparts : part list -> string option

val chkfs : fn list -> string option

val chkprog : prog -> string option

val norm_parts : part list -> part list

val post_glued : part list -> bool

val run : exch -> prog -> res

type kv = (chars * chars) list

val klookup : chars -> kv -> chars option

type penv = { pe_override : kv; pe_env : kv; pe_sys : kv; pe_initial : 
              kv; pe_nested : bool; pe_fallback : bool }

val penv0 : kv -> penv

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

val split_colon0 : chars -> chars * chars option

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

val is_meta0 : char -> bool

type ratom0 = { ra_set : chars; ra_plus : bool }

val parse_re : chars -> ratom0 option

val ra_len : ratom0 -> chars -> int

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

type expr =
| XSimple of prog
| XLang of lexp

type eres =
| EV of val0
| EUns of string

val sview : exchange -> exch

val lenv_of : exchange -> lenv

val lang_scoped : lexp -> bool

val eval_expr : exchange -> expr -> eres

type pres0 =
| PB of bool
| PUns0 of string

val eval_pred : exchange -> expr -> pres0

type strat =
| StNone
| StLatest
| StOriginal
| StGroupedBody

type split_opts = { sp_stop : bool; sp_group : int option; sp_delim : 
                    chars; sp_maxfail : int option; sp_strat : strat }

type agg_opts = { ago_id : chars; ago_corr : expr; ago_strat : strat;
                  ago_size : int option; ago_pred : expr option;
                  ago_eager : bool; ago_close : bool; ago_timeout : bool;
                  ago_discard : bool; ago_force : bool }

type lbkind =
| LBRoundRobin
| LBFailover of chars list * Big_int_Z.big_int

type endpoint =
| EDirect of chars
| EMock of chars

type step =
| SSetBody of expr
| STransform of expr
| SSetHeader of chars * expr
| SSetProperty of chars * expr
| SSetVariable of chars * expr
| SRemoveHeader of chars
| SRemoveHeaders of chars * chars list
| SRemoveProperty of chars
| SRemoveVariable of chars
| SFilter of expr * step list
| SChoice of (expr * step list) list * step list option
| SPipeline of step list
| STo of endpoint
| SStop
| SThrow of chars * chars
| SDoTry of step list * ((chars list * expr option) * step list) list
   * step list option
| SSplit of expr * split_opts * step list
| SMulticast of strat * step list
| SRecipientList of strat * expr * chars
| SAggregate of agg_opts * step list
| SLoop of expr * bool * bool * step list
| SIdem of chars * expr * bool * bool * step list
| SLB of chars * lbkind * step list
| SRoutingSlip of expr * chars
| SDynamicRouter of expr * chars
| SConvertBody of jtype * bool

type route = { r_id : chars; r_from : chars; r_steps : step list }

type clause = { c_ex : chars list; c_when : expr option;
                c_handled : bool option; c_continued : bool;
                c_redeliveries : int; c_steps : step list;
                c_retry : expr option; c_onredel : bool;
                c_scope : chars option }

type uomode =
| UONone
| UOMessage
| UOBody

type ehconf =
| EHDefault
| EHDlc of chars * int * uomode

type octrig =
| OcAlways
| OcComplete
| OcFailure

type oncomp = { oc_trig : octrig; oc_when : expr option; oc_before : 
                bool; oc_orig : bool; oc_steps : step list }

type event =
| EvMock of chars * exchange * bool

val unknown_exn : event list -> event list

val any_instance : chars -> chars list -> bool r0

val chain_instance : exn list -> chars list -> bool r0

val select_catch :
  exchange -> exn -> ((chars list * expr option) * step list) list -> step
  list option r0

val split_items : split_opts -> val0 -> val0 list r0

val chunk_f : int -> int -> chars list -> chars list list

val texts : val0 list -> chars list option

val group_items : split_opts -> val0 list -> val0 list r0

val sub_of : exchange -> val0 -> exchange

val cee : exn -> exn

val has_maxfail : split_opts -> bool

val copy_of : exchange -> exchange

val kvin : chars -> val0 -> (chars * val0) list -> bool

val kvset_eqb : (chars * val0) list -> (chars * val0) list -> bool

val last_of : exchange list -> exchange option

val strat_result :
  bool -> strat -> exchange -> exchange list -> exchange option

val agget : chars -> (chars * agroup) list -> agroup option

val agput : chars -> agroup -> (chars * agroup) list -> (chars * agroup) list

val agdel : chars -> (chars * agroup) list -> (chars * agroup) list

val aglget :
  chars -> (chars * (chars * agroup) list) list -> (chars * agroup) list

val aglset :
  chars -> (chars * agroup) list -> (chars * (chars * agroup) list) list ->
  (chars * (chars * agroup) list) list

val clget : chars -> (chars * chars list) list -> chars list

val clset :
  chars -> chars list -> (chars * chars list) list -> (chars * chars list)
  list

val with_groups :
  gstate -> chars -> ((chars * agroup) list -> (chars * agroup) list) ->
  gstate

val close_key : gstate -> chars -> chars -> gstate

val is_closed : gstate -> chars -> chars -> bool

val fresh : exchange -> exchange

val sdt : step -> bool

val lsdt : step list -> bool

val find_agg_s : chars -> step -> (agg_opts * step list) option

val find_some :
  (step -> (agg_opts * step list) option) -> step list -> (agg_opts * step
  list) option

val find_agg : route list -> chars -> (agg_opts * step list) option

type agres =
| AgCont of gstate
| AgEmit of gstate * exchange
| AgFail of exn
| AgUns of string

val same_as_first : exchange list -> bool

val agg_step : exchange -> gstate -> agg_opts -> agres

type lcount =
| LcN of int
| LcFail
| LcUns of string

val loop_count : val0 -> lcount

val loop_copy : exchange -> exchange -> exchange

val rce : exn

val add_key : gstate -> chars -> chars -> gstate

val add_uow : exchange -> chars -> chars -> exchange

val remove_key : gstate -> (chars * chars) -> gstate

val complete_uow : bool -> gstate -> exchange -> gstate

val cntget : chars -> (chars * int) list -> int

val cntset : chars -> int -> (chars * int) list -> (chars * int) list

val bump : gstate -> chars -> gstate

val same_state : exchange -> exchange -> bool

val fo_attempts : int -> Big_int_Z.big_int -> int

val fo_monitored : bool -> chars list -> exn -> bool r0

val uri_of : chars -> endpoint option

val uris_of : chars list -> endpoint list r0

val recipients : chars -> val0 -> endpoint list r0

val slip_of : chars -> val0 -> endpoint list r0

val any_exn : exn

type cbres =
| CbBody of val0
| CbFail
| CbUns of string

val convert_body : jtype -> bool -> val0 -> cbres

val keep_pending : exn -> exchange -> exchange

val keep : exn option -> exchange -> exchange

val halted : exchange -> bool

val merge_props :
  (chars * val0) list -> (chars * val0) list -> (chars * val0) list

val is_dlc : ehconf -> bool

val dist_f : int -> chars -> chars -> int option r0

val lt2 : (int * int) -> (int * int) -> bool

val eq2 : (int * int) -> (int * int) -> bool

val best : (int * int) option -> (int * int) option -> (int * int) option

val score_cls : chars -> int -> chars list -> (int * int) option r0

val score_chain : exn list -> int -> chars list -> (int * int) option r0

val candidates :
  exchange -> exn -> clause list -> (((int * int) * bool) * clause) list r0

val min_score : (((int * int) * bool) * clause) list -> (int * int) option

val in_scope : exchange -> clause -> bool

val is_route_scoped : clause -> bool

val has_clauses : clause list -> chars -> bool

val pick_tied :
  (((int * int) * bool) * clause) list -> (int * int) -> clause option r0

val select_clause : clause list -> exchange -> exn -> clause option r0

val clause_matches : clause list -> ehconf -> exchange -> bool

val redelivery_headers : int -> exchange -> exchange

val drop_redelivery_headers : exchange -> exchange

val not_redelivered_headers : int -> exchange -> exchange

val eh_outcome_n :
  clause -> int -> exchange -> exn -> exchange -> exchange option

val retry_n : int -> int -> expr -> exchange -> int r0

val eh_max : ehconf -> int

val redeliveries : ehconf -> clause -> exchange -> int r0

val onr_apply : exchange -> exchange

val after_redelivery : clause -> int -> exchange -> exchange

val redelivery_headers_rw : bool -> int -> exchange -> exchange

val block_input_n : clause -> int -> exchange -> exchange

val surface : exchange -> exchange

val default_failed : clause list -> exchange -> exn -> exchange

val dlc_msg : uomode -> exchange -> message option

val dlc_out : uomode -> exchange -> exchange option

val dlc_fail :
  clause list -> ehconf -> exchange -> exn -> (exchange * event list) option

val dlc_takes : ehconf -> clause -> bool

val seen_if_failed : exchange -> exchange

val abort_result : bool -> exchange -> exchange -> exn -> exchange

val find_route : route list -> chars -> route option

val oc_failed : exchange -> bool

val oc_trig_ok : octrig -> exchange -> bool

val oc_fires : oncomp -> exchange -> pres0

val oc_input : oncomp -> exchange -> exchange option

type out =
| ODone of gstate * exchange * event list * string list
| OUns of string

val seqo :
  out -> (gstate -> exchange -> event list -> string list -> out) -> out

val tag : string -> out -> out

val done1 : string -> gstate -> exchange -> out

val run0 :
  route list -> bool -> clause list -> ehconf -> int -> gstate -> exchange ->
  step list -> out

val runoc :
  route list -> bool -> clause list -> ehconf -> int -> oncomp option ->
  gstate -> exchange -> out

type send = { s_to : chars; s_mep : mep; s_body : val0;
              s_headers : (chars * val0) list }

type sres =
| SDone of event list * exchange * string list
| SUns of string

val clause_unconfigured : clause -> bool

val complete_groups :
  route list -> bool -> clause list -> ehconf -> int -> bool ->
  (chars * (chars * agroup)) list -> gstate -> out

val pending_groups : gstate -> (chars * (chars * agroup)) list

val run_case_ :
  bool -> clause list -> ehconf -> oncomp option -> int -> route list ->
  gstate -> send list -> sres list * gstate

val run_case :
  bool -> clause list -> ehconf -> oncomp option -> int -> route list ->
  gstate -> send list -> sres list * gstate

val s : string -> chars

val xesc : chars -> chars

val attr : string -> chars -> chars

val elem : string -> chars -> chars -> chars

val empty : string -> chars -> chars

val btxt : bool -> chars

val ntxt : int -> chars

val xexpr : expr -> chars

val strat_attr : strat -> chars

val uri : endpoint -> chars

val joinc : chars list -> chars

val xstep : step -> chars

val xsteps : step list -> chars

val xclause : clause -> chars

val xeh : ehconf -> chars

val xoc : oncomp -> chars

val clause_of_route : chars -> clause -> bool

val clause_global : clause -> bool

val xroute : clause list -> ehconf -> oncomp option -> route -> chars

val xml_program :
  clause list -> ehconf -> oncomp option -> route list -> chars

val s0 : string -> chars

val dq0 : char

val bsl0 : char

val hex1 : int -> char

val jesc : chars -> chars

val jstr : chars -> chars

val kv0 : string -> chars -> chars

val commas : chars list -> chars

val obj : chars list -> chars

val arr : chars list -> chars

val btxt0 : bool -> chars

val ntxt0 : int -> chars

val yexpr : expr -> chars

val exprf : expr -> chars

val strat_f : strat -> chars list

val uri0 : endpoint -> chars

val joinc0 : chars list -> chars

val step1 : string -> chars list -> chars

val ystep : step -> chars

val ysteps : step list -> chars

val yclause : clause -> chars

val yeh : ehconf -> chars list

val yoc : oncomp -> chars

val yclause_global : clause -> bool

val yroute : clause list -> ehconf -> bool -> route -> chars

val yaml_program :
  clause list -> ehconf -> oncomp option -> route list -> chars
