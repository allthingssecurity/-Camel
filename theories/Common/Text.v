(** * Text: characters, strings and decimal numbers (helpers; no documentation content).
    Moved unchanged from rocq-jvm-threads/theories/Ship/SimpleSpec.v (sha256 ef2550af5018), sections 1-2. *)
From Stdlib Require Import ZArith String Ascii List Bool.
Import ListNotations.
Open Scope string_scope.
Open Scope list_scope.

(** ** 1. Characters and strings (helpers, no documentation content) *)

Definition chars := list ascii.
Definition str (s : string) : chars := list_ascii_of_string s.
Definition ceq (a b : ascii) : bool := Ascii.eqb a b.
Fixpoint ceqs (a b : chars) : bool :=
  match a, b with
  | [], [] => true
  | x :: a', y :: b' => ceq x y && ceqs a' b'
  | _, _ => false
  end.
Fixpoint prefix (p s : chars) : bool :=
  match p with
  | [] => true
  | x :: p' => match s with [] => false | y :: s' => ceq x y && prefix p' s' end
  end.
Definition suffix (p s : chars) : bool := prefix (rev p) (rev s).
(** Index of the first occurrence of [p] in [s] (at or after position [i] of the original). *)
Fixpoint find_from (p s : chars) (i : nat) : option nat :=
  if prefix p s then Some i else match s with [] => None | _ :: s' => find_from p s' (S i) end.
Definition find (p s : chars) : option nat := find_from p s 0.
Definition occurs (p s : chars) : bool := match find p s with Some _ => true | None => false end.
(** Number of (possibly overlapping) occurrences; used to say "exactly once". *)
Fixpoint count_occ (p s : chars) : nat :=
  match s with [] => 0 | _ :: s' => (if prefix p s then 1 else 0) + count_occ p s' end.
Fixpoint repl (fuel : nat) (from to s : chars) : chars :=
  match fuel with
  | O => s
  | S f => match s with
           | [] => []
           | c :: s' => if prefix from s then to ++ repl f from to (skipn (length from) s)
                        else c :: repl f from to s'
           end
  end.
Definition replace_all (from to s : chars) : chars := repl (S (length s)) from to s.
Definition code (c : ascii) : nat := nat_of_ascii c.
Definition is_upper (c : ascii) : bool := Nat.leb 65 (code c) && Nat.leb (code c) 90.
Definition is_lower (c : ascii) : bool := Nat.leb 97 (code c) && Nat.leb (code c) 122.
Definition is_digit (c : ascii) : bool := Nat.leb 48 (code c) && Nat.leb (code c) 57.
Definition is_letter (c : ascii) : bool := is_upper c || is_lower c.
Definition lowc (c : ascii) : ascii := if is_upper c then ascii_of_nat (code c + 32) else c.
Definition upc (c : ascii) : ascii := if is_lower c then ascii_of_nat (code c - 32) else c.
Definition lower (s : chars) : chars := map lowc s.
Definition upper (s : chars) : chars := map upc s.
(** White space as the generator uses it: space, tab, LF, CR. *)
Definition is_ws (c : ascii) : bool := let n := code c in Nat.eqb n 32 || Nat.eqb n 9 || Nat.eqb n 10 || Nat.eqb n 13.
Fixpoint drop_ws (s : chars) : chars := match s with c :: s' => if is_ws c then drop_ws s' else s | [] => [] end.
Definition trim (s : chars) : chars := rev (drop_ws (rev (drop_ws s))).
Definition blank (s : chars) : bool := forallb is_ws s.
(** Java's [String.compareTo] on ASCII text: by character code, a proper prefix first. *)
Fixpoint scmp (a b : chars) : comparison :=
  match a, b with
  | [], [] => Eq | [], _ => Lt | _, [] => Gt
  | x :: a', y :: b' => match Nat.compare (code x) (code y) with Eq => scmp a' b' | c => c end
  end.
Fixpoint split_on (sep : ascii) (s : chars) : list chars :=
  match s with
  | [] => [[]]
  | c :: s' => if ceq c sep then [] :: split_on sep s'
               else match split_on sep s' with w :: ws => (c :: w) :: ws | [] => [[c]] end
  end.
Fixpoint concat_with (sep : chars) (l : list chars) : chars :=
  match l with [] => [] | [w] => w | w :: l' => w ++ sep ++ concat_with sep l' end.
Fixpoint repeat_c (c : ascii) (n : nat) : chars := match n with O => [] | S n' => c :: repeat_c c n' end.

(** ** 2. Numbers: decimal text, and the numeric reading of a text *)

Fixpoint pos_digits (fuel : nat) (n : Z) (acc : chars) : chars :=
  match fuel with
  | O => acc
  | S f => let c := ascii_of_nat (48 + Z.to_nat (Z.modulo n 10)) in
           if Z.eqb (Z.div n 10) 0 then c :: acc else pos_digits f (Z.div n 10) (c :: acc)
  end.
Definition ztext (z : Z) : chars :=
  if Z.ltb z 0 then "-"%char :: pos_digits 40 (Z.opp z) [] else pos_digits 40 z [].
Fixpoint digits_val (l : chars) (acc : Z) : Z :=
  match l with [] => acc | c :: l' => digits_val l' (acc * 10 + Z.of_nat (code c - 48)) end.
Definition all_digits (l : chars) : bool := match l with [] => false | _ => forallb is_digit l end.
Fixpoint split_dot (l : chars) : chars * option chars :=
  match l with
  | [] => ([], None)
  | c :: l' => if ceq c "."%char then ([], Some l') else let (a, b) := split_dot l' in (c :: a, b)
  end.
(** A rational m * 10^-k. The documented numeric text: optional minus, digits, optional dot and digits. A plus
    sign, an exponent, or spaces make a text non-numeric here (the docs do not say how they convert). *)
Definition dec := (Z * nat)%type.
Definition parse_dec (l : chars) : option dec :=
  let '(neg, b) := match l with "-"%char :: r => (true, r) | _ => (false, l) end in
  let sg := fun z => if neg then Z.opp z else z in
  match split_dot b with
  | (ip, None) => if all_digits ip then Some (sg (digits_val ip 0), O) else None
  | (ip, Some fp) => if all_digits ip && all_digits fp then Some (sg (digits_val (ip ++ fp) 0), length fp) else None
  end.
Definition qcmp (a b : dec) : comparison :=
  let '(m1, s1) := a in let '(m2, s2) := b in
  Z.compare (m1 * Z.pow 10 (Z.of_nat s2)) (m2 * Z.pow 10 (Z.of_nat s1)).

