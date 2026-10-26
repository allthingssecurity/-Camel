(** * L0 values: the Java value kinds the rules talk about.
    Moved unchanged from rocq-jvm-threads/theories/Ship/SimpleSpec.v (sha256 ef2550af5018), section 3. Extended here as
    later layers need more kinds; every kind must have a canonical text form shared with the Java harness. *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** 3. Values

    The value kinds of an exchange that the rules talk about: null, String, Integer, Long, Double, Boolean and a
    List of Strings ([F.42-108] "Response Type"). A Double is held in quarters ([VDbl q] = q/4), so its value is
    exact and its Java text is known ("2.5", "2.0"). *)
Inductive val : Type :=
| VNull
| VStr (s : chars)
| VInt (z : Z)
| VLong (z : Z)
| VDbl (q : Z)
| VBool (b : bool)
| VList (l : list chars).

Definition dbltext (q : Z) : chars :=
  let a := Z.abs q in
  (if Z.ltb q 0 then str "-" else []) ++ ztext (Z.div a 4) ++ "."%char ::
  (match Z.to_nat (Z.modulo a 4) with 0 => str "0" | 1 => str "25" | 2 => str "5" | _ => str "75" end).
Definition num_of (v : val) : option dec :=
  match v with
  | VInt z | VLong z => Some (z, O)
  | VDbl q => Some ((q * 25)%Z, 2%nat)
  | VStr s => parse_dec s
  | _ => None
  end.
Definition is_num (v : val) : bool := match v with VInt _ | VLong _ | VDbl _ => true | _ => false end.
Definition btext (b : bool) : chars := if b then str "true" else str "false".
(** The "string-based value" of a value [O.60-67]: the text of a String, number or boolean; null and lists have
    none (UNSPECIFIED where it is needed). *)
Definition text_of (v : val) : option chars :=
  match v with
  | VStr s => Some s
  | VInt z | VLong z => Some (ztext z)
  | VDbl q => Some (dbltext q)
  | VBool b => Some (btext b)
  | _ => None
  end.
