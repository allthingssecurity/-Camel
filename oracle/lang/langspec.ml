
(** val negb : bool -> bool **)

let negb = function
| true -> false
| false -> true

type ('a, 'b) sum =
| Inl of 'a
| Inr of 'b

(** val length : 'a1 list -> int **)

let rec length = function
| [] -> 0
| _ :: l' -> Stdlib.Int.succ (length l')

(** val app : 'a1 list -> 'a1 list -> 'a1 list **)

let rec app l m =
  match l with
  | [] -> m
  | a :: l1 -> a :: (app l1 m)

type comparison =
| Eq
| Lt
| Gt

module Coq__1 = struct
 (** val add : int -> int -> int **)

 let rec add = (+)
end
include Coq__1

(** val sub : int -> int -> int **)

let rec sub = fun n m -> Stdlib.max 0 (n-m)

module Nat =
 struct
  (** val ltb : int -> int -> bool **)

  let ltb n0 m =
    (<=) (Stdlib.Int.succ n0) m
 end

module Pos =
 struct
  (** val succ : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec succ x =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p -> (fun p -> Big_int_Z.shift_left_big_int p 1) (succ p))
      (fun p ->
      (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      p)
      (fun _ -> (fun p -> Big_int_Z.shift_left_big_int p 1)
      Big_int_Z.unit_big_int)
      x

  (** val add :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec add x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add_carry p q))
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add p q))
        (fun _ -> (fun p -> Big_int_Z.shift_left_big_int p 1) (succ p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add p q))
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add p q))
        (fun _ ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        p)
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (succ q))
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        q)
        (fun _ -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        Big_int_Z.unit_big_int)
        y)
      x

  (** val add_carry :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  and add_carry x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add_carry p q))
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add_carry p q))
        (fun _ ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (succ p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add_carry p q))
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add p q))
        (fun _ -> (fun p -> Big_int_Z.shift_left_big_int p 1) (succ p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (succ q))
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (succ q))
        (fun _ ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        Big_int_Z.unit_big_int)
        y)
      x

  (** val pred_double : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec pred_double x =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.shift_left_big_int p 1) p))
      (fun p ->
      (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      (pred_double p))
      (fun _ -> Big_int_Z.unit_big_int)
      x

  (** val mul :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec mul x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      add y ((fun p -> Big_int_Z.shift_left_big_int p 1) (mul p y)))
      (fun p -> (fun p -> Big_int_Z.shift_left_big_int p 1)
      (mul p y))
      (fun _ -> y)
      x

  (** val compare_cont :
      comparison -> Big_int_Z.big_int -> Big_int_Z.big_int -> comparison **)

  let rec compare_cont r x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> compare_cont r p q)
        (fun q -> compare_cont Gt p q)
        (fun _ -> Gt)
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> compare_cont Lt p q)
        (fun q -> compare_cont r p q)
        (fun _ -> Gt)
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun _ -> Lt)
        (fun _ -> Lt)
        (fun _ -> r)
        y)
      x

  (** val compare : Big_int_Z.big_int -> Big_int_Z.big_int -> comparison **)

  let compare =
    compare_cont Eq

  (** val eqb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool **)

  let rec eqb p q =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p0 ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q0 -> eqb p0 q0)
        (fun _ -> false)
        (fun _ -> false)
        q)
      (fun p0 ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun _ -> false)
        (fun q0 -> eqb p0 q0)
        (fun _ -> false)
        q)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun _ -> false)
        (fun _ -> false)
        (fun _ -> true)
        q)
      p

  (** val iter_op : ('a1 -> 'a1 -> 'a1) -> Big_int_Z.big_int -> 'a1 -> 'a1 **)

  let rec iter_op op p a =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p0 -> op a (iter_op op p0 (op a a)))
      (fun p0 -> iter_op op p0 (op a a))
      (fun _ -> a)
      p

  (** val to_nat : Big_int_Z.big_int -> int **)

  let to_nat x =
    iter_op Coq__1.add x (Stdlib.Int.succ 0)

  (** val of_succ_nat : int -> Big_int_Z.big_int **)

  let rec of_succ_nat n0 =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> Big_int_Z.unit_big_int)
      (fun x -> succ (of_succ_nat x))
      n0
 end

module Coq_Pos =
 struct
  (** val succ : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec succ = Big_int_Z.succ_big_int

  (** val add :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec add = Big_int_Z.add_big_int

  (** val add_carry :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  and add_carry x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add_carry p q))
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add_carry p q))
        (fun _ ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (succ p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (add_carry p q))
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (add p q))
        (fun _ -> (fun p -> Big_int_Z.shift_left_big_int p 1) (succ p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        (succ q))
        (fun q -> (fun p -> Big_int_Z.shift_left_big_int p 1)
        (succ q))
        (fun _ ->
        (fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
        Big_int_Z.unit_big_int)
        y)
      x

  (** val mul :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec mul = Big_int_Z.mult_big_int
 end

module N =
 struct
  (** val add :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let add = Big_int_Z.add_big_int

  (** val mul :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let mul = Big_int_Z.mult_big_int

  (** val to_nat : Big_int_Z.big_int -> int **)

  let to_nat a =
    (fun fO fp n -> if Big_int_Z.sign_big_int n <= 0 then fO () else fp n)
      (fun _ -> 0)
      (fun p -> Pos.to_nat p)
      a

  (** val of_nat : int -> Big_int_Z.big_int **)

  let of_nat n0 =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> Big_int_Z.zero_big_int)
      (fun n' -> (Pos.of_succ_nat n'))
      n0
 end

module Z =
 struct
  (** val double : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let double x =
    (fun fO fp fn z -> let s = Big_int_Z.sign_big_int z in
  if s = 0 then fO () else if s > 0 then fp z
  else fn (Big_int_Z.minus_big_int z))
      (fun _ -> Big_int_Z.zero_big_int)
      (fun p -> ((fun p -> Big_int_Z.shift_left_big_int p 1) p))
      (fun p -> Big_int_Z.minus_big_int
      ((fun p -> Big_int_Z.shift_left_big_int p 1) p))
      x

  (** val succ_double : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let succ_double x =
    (fun fO fp fn z -> let s = Big_int_Z.sign_big_int z in
  if s = 0 then fO () else if s > 0 then fp z
  else fn (Big_int_Z.minus_big_int z))
      (fun _ -> Big_int_Z.unit_big_int)
      (fun p ->
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      p))
      (fun p -> Big_int_Z.minus_big_int (Pos.pred_double p))
      x

  (** val pred_double : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let pred_double x =
    (fun fO fp fn z -> let s = Big_int_Z.sign_big_int z in
  if s = 0 then fO () else if s > 0 then fp z
  else fn (Big_int_Z.minus_big_int z))
      (fun _ -> Big_int_Z.minus_big_int Big_int_Z.unit_big_int)
      (fun p -> (Pos.pred_double p))
      (fun p -> Big_int_Z.minus_big_int
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      p))
      x

  (** val pos_sub :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let rec pos_sub x y =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> double (pos_sub p q))
        (fun q -> succ_double (pos_sub p q))
        (fun _ -> ((fun p -> Big_int_Z.shift_left_big_int p 1) p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> pred_double (pos_sub p q))
        (fun q -> double (pos_sub p q))
        (fun _ -> (Pos.pred_double p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun q -> Big_int_Z.minus_big_int
        ((fun p -> Big_int_Z.shift_left_big_int p 1) q))
        (fun q -> Big_int_Z.minus_big_int (Pos.pred_double q))
        (fun _ -> Big_int_Z.zero_big_int)
        y)
      x

  (** val add :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let add = Big_int_Z.add_big_int

  (** val opp : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let opp = Big_int_Z.minus_big_int

  (** val sub :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let sub = Big_int_Z.sub_big_int

  (** val mul :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let mul = Big_int_Z.mult_big_int

  (** val compare : Big_int_Z.big_int -> Big_int_Z.big_int -> comparison **)

  let compare = (fun x y -> let s = Big_int_Z.compare_big_int x y in
  if s = 0 then Eq else if s < 0 then Lt else Gt)

  (** val leb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool **)

  let leb x y =
    match compare x y with
    | Gt -> false
    | _ -> true

  (** val ltb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool **)

  let ltb x y =
    match compare x y with
    | Lt -> true
    | _ -> false

  (** val eqb : Big_int_Z.big_int -> Big_int_Z.big_int -> bool **)

  let eqb = Big_int_Z.eq_big_int

  (** val to_nat : Big_int_Z.big_int -> int **)

  let to_nat z0 =
    (fun fO fp fn z -> let s = Big_int_Z.sign_big_int z in
  if s = 0 then fO () else if s > 0 then fp z
  else fn (Big_int_Z.minus_big_int z))
      (fun _ -> 0)
      (fun p -> Pos.to_nat p)
      (fun _ -> 0)
      z0

  (** val of_nat : int -> Big_int_Z.big_int **)

  let of_nat n0 =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> Big_int_Z.zero_big_int)
      (fun n1 -> (Pos.of_succ_nat n1))
      n0

  (** val pos_div_eucl :
      Big_int_Z.big_int -> Big_int_Z.big_int ->
      Big_int_Z.big_int * Big_int_Z.big_int **)

  let rec pos_div_eucl a b =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun a' ->
      let (q, r) = pos_div_eucl a' b in
      let r' =
        add
          (mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
            Big_int_Z.unit_big_int) r)
          Big_int_Z.unit_big_int
      in
      if ltb r' b
      then ((mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
              Big_int_Z.unit_big_int) q),
             r')
      else ((add
              (mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
                Big_int_Z.unit_big_int) q)
              Big_int_Z.unit_big_int),
             (sub r' b)))
      (fun a' ->
      let (q, r) = pos_div_eucl a' b in
      let r' =
        mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
          Big_int_Z.unit_big_int) r
      in
      if ltb r' b
      then ((mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
              Big_int_Z.unit_big_int) q),
             r')
      else ((add
              (mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
                Big_int_Z.unit_big_int) q)
              Big_int_Z.unit_big_int),
             (sub r' b)))
      (fun _ ->
      if leb ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int) b
      then (Big_int_Z.zero_big_int, Big_int_Z.unit_big_int)
      else (Big_int_Z.unit_big_int, Big_int_Z.zero_big_int))
      a

  (** val div_eucl :
      Big_int_Z.big_int -> Big_int_Z.big_int ->
      Big_int_Z.big_int * Big_int_Z.big_int **)

  let div_eucl = Big_int_Z.(fun x y ->
  match sign_big_int y with
  | 0 -> (zero_big_int, x)
  | 1 -> quomod_big_int x y
  | _ -> let (q, r) = quomod_big_int (add_int_big_int (-1) x) y in
          (add_int_big_int (-1) q, add_big_int (add_int_big_int 1 y) r))

  (** val div :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let div = Big_int_Z.(fun x y ->
  match sign_big_int y with
  | 0 -> zero_big_int
  | 1 -> div_big_int x y
  | _ -> add_int_big_int (-1) (div_big_int (add_int_big_int (-1) x) y))

  (** val modulo :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let modulo = Big_int_Z.(fun x y ->
  match sign_big_int y with
  | 0 -> x
  | 1 -> mod_big_int x y
  | _ -> add_big_int y (add_int_big_int 1 (mod_big_int (add_int_big_int (-1) x) y)))

  (** val abs : Big_int_Z.big_int -> Big_int_Z.big_int **)

  let abs = Big_int_Z.abs_big_int
 end

(** val map : ('a1 -> 'a2) -> 'a1 list -> 'a2 list **)

let rec map f = function
| [] -> []
| a :: l0 -> (f a) :: (map f l0)

(** val firstn : int -> 'a1 list -> 'a1 list **)

let rec firstn n0 l =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> [])
    (fun n1 -> match l with
               | [] -> []
               | a :: l0 -> a :: (firstn n1 l0))
    n0

(** val skipn : int -> 'a1 list -> 'a1 list **)

let rec skipn n0 l =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> l)
    (fun n1 -> match l with
               | [] -> []
               | _ :: l0 -> skipn n1 l0)
    n0

(** val tl : 'a1 list -> 'a1 list **)

let tl = function
| [] -> []
| _ :: l' -> l'

(** val rev : 'a1 list -> 'a1 list **)

let rec rev = function
| [] -> []
| x :: l' -> app (rev l') (x :: [])

(** val fold_right : ('a2 -> 'a1 -> 'a1) -> 'a1 -> 'a2 list -> 'a1 **)

let rec fold_right f a0 = function
| [] -> a0
| b :: l0 -> f b (fold_right f a0 l0)

(** val existsb : ('a1 -> bool) -> 'a1 list -> bool **)

let rec existsb f = function
| [] -> false
| a :: l0 -> (||) (f a) (existsb f l0)

(** val forallb : ('a1 -> bool) -> 'a1 list -> bool **)

let rec forallb f = function
| [] -> true
| a :: l0 -> (&&) (f a) (forallb f l0)

(** val filter : ('a1 -> bool) -> 'a1 list -> 'a1 list **)

let rec filter f = function
| [] -> []
| x :: l0 -> if f x then x :: (filter f l0) else filter f l0

(** val zero : char **)

let zero = '\000'

(** val one : char **)

let one = '\001'

(** val shift : bool -> char -> char **)

let shift = fun b c -> Char.chr (((Char.code c) lsl 1) land 255 + if b then 1 else 0)

(** val ascii_of_pos : Big_int_Z.big_int -> char **)

let ascii_of_pos =
  let rec loop n0 p =
    (fun fO fS n -> if n=0 then fO () else fS (n-1))
      (fun _ -> zero)
      (fun n' ->
      (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
        (fun p' -> shift true (loop n' p'))
        (fun p' -> shift false (loop n' p'))
        (fun _ -> one)
        p)
      n0
  in loop (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
       (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
       0))))))))

(** val ascii_of_N : Big_int_Z.big_int -> char **)

let ascii_of_N n0 =
  (fun fO fp n -> if Big_int_Z.sign_big_int n <= 0 then fO () else fp n)
    (fun _ -> zero)
    (fun p -> ascii_of_pos p)
    n0

(** val ascii_of_nat : int -> char **)

let ascii_of_nat a =
  ascii_of_N (N.of_nat a)

(** val n_of_digits : bool list -> Big_int_Z.big_int **)

let rec n_of_digits = function
| [] -> Big_int_Z.zero_big_int
| b :: l' ->
  N.add (if b then Big_int_Z.unit_big_int else Big_int_Z.zero_big_int)
    (N.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
      Big_int_Z.unit_big_int) (n_of_digits l'))

(** val n_of_ascii : char -> Big_int_Z.big_int **)

let n_of_ascii a =
  (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
    (fun a0 a1 a2 a3 a4 a5 a6 a7 ->
    n_of_digits
      (a0 :: (a1 :: (a2 :: (a3 :: (a4 :: (a5 :: (a6 :: (a7 :: [])))))))))
    a

(** val nat_of_ascii : char -> int **)

let nat_of_ascii a =
  N.to_nat (n_of_ascii a)

type chars = char list

(** val str : string -> chars **)

let str =
  (fun s -> List.init (String.length s) (fun i -> s.[i]))

(** val ceq : char -> char -> bool **)

let ceq =
  (=)

(** val ceqs : chars -> chars -> bool **)

let rec ceqs a b =
  match a with
  | [] -> (match b with
           | [] -> true
           | _ :: _ -> false)
  | x :: a' ->
    (match b with
     | [] -> false
     | y :: b' -> (&&) (ceq x y) (ceqs a' b'))

(** val prefix : chars -> chars -> bool **)

let rec prefix p s =
  match p with
  | [] -> true
  | x :: p' ->
    (match s with
     | [] -> false
     | y :: s' -> (&&) (ceq x y) (prefix p' s'))

(** val suffix : chars -> chars -> bool **)

let suffix p s =
  prefix (rev p) (rev s)

(** val find_from : chars -> chars -> int -> int option **)

let rec find_from p s i =
  if prefix p s
  then Some i
  else (match s with
        | [] -> None
        | _ :: s' -> find_from p s' (Stdlib.Int.succ i))

(** val find : chars -> chars -> int option **)

let find p s =
  find_from p s 0

(** val occurs : chars -> chars -> bool **)

let occurs p s =
  match find p s with
  | Some _ -> true
  | None -> false

(** val repl : int -> chars -> chars -> chars -> chars **)

let rec repl fuel from to0 s =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> s)
    (fun f ->
    match s with
    | [] -> []
    | c :: s' ->
      if prefix from s
      then app to0 (repl f from to0 (skipn (length from) s))
      else c :: (repl f from to0 s'))
    fuel

(** val replace_all : chars -> chars -> chars -> chars **)

let replace_all from to0 s =
  repl (Stdlib.Int.succ (length s)) from to0 s

(** val code : char -> int **)

let code =
  nat_of_ascii

(** val is_upper : char -> bool **)

let is_upper c =
  (&&)
    ((<=) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ
      0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
      (code c))
    ((<=) (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

(** val is_lower : char -> bool **)

let is_lower c =
  (&&)
    ((<=) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ
      0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
      (code c))
    ((<=) (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      0)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

(** val is_digit : char -> bool **)

let is_digit c =
  (&&)
    ((<=) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      0)))))))))))))))))))))))))))))))))))))))))))))))) (code c))
    ((<=) (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ
      0))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

(** val is_letter : char -> bool **)

let is_letter c =
  (||) (is_upper c) (is_lower c)

(** val lowc : char -> char **)

let lowc c =
  if is_upper c
  then ascii_of_nat
         (add (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ 0)))))))))))))))))))))))))))))))))
  else c

(** val upc : char -> char **)

let upc c =
  if is_lower c
  then ascii_of_nat
         (sub (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
           (Stdlib.Int.succ 0)))))))))))))))))))))))))))))))))
  else c

(** val lower : chars -> chars **)

let lower s =
  map lowc s

(** val is_ws : char -> bool **)

let is_ws c =
  let n0 = code c in
  (||)
    ((||)
      ((||)
        ((=) n0 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ 0)))))))))))))))))))))))))))))))))
        ((=) n0 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ 0)))))))))))
      ((=) n0 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
        (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
        (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ 0))))))))))))
    ((=) n0 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
      (Stdlib.Int.succ (Stdlib.Int.succ 0))))))))))))))

(** val drop_ws : chars -> chars **)

let rec drop_ws s = match s with
| [] -> []
| c :: s' -> if is_ws c then drop_ws s' else s

(** val trim : chars -> chars **)

let trim s =
  rev (drop_ws (rev (drop_ws s)))

(** val split_on : char -> chars -> chars list **)

let rec split_on sep = function
| [] -> [] :: []
| c :: s' ->
  if ceq c sep
  then [] :: (split_on sep s')
  else (match split_on sep s' with
        | [] -> (c :: []) :: []
        | w :: ws -> (c :: w) :: ws)

(** val concat_with : chars -> chars list -> chars **)

let rec concat_with sep = function
| [] -> []
| w :: l' ->
  (match l' with
   | [] -> w
   | _ :: _ -> app w (app sep (concat_with sep l')))

(** val repeat_c : char -> int -> chars **)

let rec repeat_c c n0 =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> [])
    (fun n' -> c :: (repeat_c c n'))
    n0

(** val pos_digits : int -> Big_int_Z.big_int -> chars -> chars **)

let rec pos_digits fuel n0 acc =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> acc)
    (fun f ->
    let c =
      ascii_of_nat
        (add (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
          (Stdlib.Int.succ 0))))))))))))))))))))))))))))))))))))))))))))))))
          (Z.to_nat
            (Z.modulo n0 ((fun p -> Big_int_Z.shift_left_big_int p 1)
              ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
              ((fun p -> Big_int_Z.shift_left_big_int p 1)
              Big_int_Z.unit_big_int))))))
    in
    if Z.eqb
         (Z.div n0 ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int))))
         Big_int_Z.zero_big_int
    then c :: acc
    else pos_digits f
           (Z.div n0 ((fun p -> Big_int_Z.shift_left_big_int p 1)
             ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
             ((fun p -> Big_int_Z.shift_left_big_int p 1)
             Big_int_Z.unit_big_int))))
           (c :: acc))
    fuel

(** val ztext : Big_int_Z.big_int -> chars **)

let ztext z0 =
  if Z.ltb z0 Big_int_Z.zero_big_int
  then '-' :: (pos_digits (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ 0))))))))))))))))))))))))))))))))))))))))
                (Z.opp z0) [])
  else pos_digits (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
         (Stdlib.Int.succ 0)))))))))))))))))))))))))))))))))))))))) z0 []

(** val digits_val : chars -> Big_int_Z.big_int -> Big_int_Z.big_int **)

let rec digits_val l acc =
  match l with
  | [] -> acc
  | c :: l' ->
    digits_val l'
      (Z.add
        (Z.mul acc ((fun p -> Big_int_Z.shift_left_big_int p 1)
          ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
          ((fun p -> Big_int_Z.shift_left_big_int p 1)
          Big_int_Z.unit_big_int))))
        (Z.of_nat
          (sub (code c) (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
            0)))))))))))))))))))))))))))))))))))))))))))))))))))

(** val all_digits : chars -> bool **)

let all_digits l = match l with
| [] -> false
| _ :: _ -> forallb is_digit l

type kv = (chars * chars) list

(** val klookup : chars -> kv -> chars option **)

let rec klookup k = function
| [] -> None
| p :: l' -> let (k', v) = p in if ceqs k k' then Some v else klookup k l'

type penv = { pe_override : kv; pe_env : kv; pe_sys : kv; pe_initial : 
              kv; pe_nested : bool; pe_fallback : bool }

type pres =
| PV of chars
| PFail of chars
| PUns of string

(** val iae : pres **)

let iae =
  PFail (str "IllegalArgumentException")

(** val pbind : pres -> (chars -> pres) -> pres **)

let pbind r k =
  match r with
  | PV s -> k s
  | _ -> r

(** val bsl : char **)

let bsl =
  '\\'

(** val lbr : char **)

let lbr =
  '{'

(** val rbr : char **)

let rbr =
  '}'

(** val oPEN : chars **)

let oPEN =
  lbr :: (lbr :: [])

(** val cLOSE : chars **)

let cLOSE =
  rbr :: (rbr :: [])

type tok =
| TC of char
| TOpen
| TClose
| TLit of chars
| TBad of string

(** val bs_run : chars -> int * chars **)

let rec bs_run s = match s with
| [] -> (0, [])
| c :: r ->
  if ceq c bsl
  then let (n0, t) = bs_run r in ((Stdlib.Int.succ n0), t)
  else (0, s)

(** val lex : int -> chars -> tok list **)

let rec lex fuel s =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> [])
    (fun f ->
    match s with
    | [] -> []
    | c :: r ->
      if ceq c bsl
      then let (n0, rest) = bs_run s in
           if (||) (prefix oPEN rest) (prefix cLOSE rest)
           then if (||) (prefix (lbr :: (lbr :: (lbr :: []))) rest)
                     (prefix (rbr :: (rbr :: (rbr :: []))) rest)
                then (TBad "PP: an escape before three braces") :: []
                else ((fun fO fS n -> if n=0 then fO () else fS (n-1))
                        (fun _ -> (TBad
                        "PP: three or more backslashes before {{ or }}") :: [])
                        (fun n1 ->
                        (fun fO fS n -> if n=0 then fO () else fS (n-1))
                          (fun _ -> (TLit
                          (firstn (Stdlib.Int.succ (Stdlib.Int.succ 0)) rest)) :: 
                          (lex f
                            (skipn (Stdlib.Int.succ (Stdlib.Int.succ 0)) rest)))
                          (fun n2 ->
                          (fun fO fS n -> if n=0 then fO () else fS (n-1))
                            (fun _ -> (TC
                            bsl) :: ((if prefix oPEN rest
                                      then TOpen
                                      else TClose) :: (lex f
                                                        (skipn
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ 0))
                                                          rest))))
                            (fun _ -> (TBad
                            "PP: three or more backslashes before {{ or }}") :: [])
                            n2)
                          n1)
                        n0)
           else app (map (fun x -> TC x) (repeat_c bsl n0)) (lex f rest)
      else if (||) (prefix (lbr :: (lbr :: (lbr :: []))) s)
                (prefix (rbr :: (rbr :: (rbr :: []))) s)
           then (TBad "PP: three or more braces in a row") :: []
           else if prefix oPEN s
                then TOpen :: (lex f
                                (skipn (Stdlib.Int.succ (Stdlib.Int.succ 0))
                                  s))
                else if prefix cLOSE s
                     then TClose :: (lex f
                                      (skipn (Stdlib.Int.succ (Stdlib.Int.succ
                                        0)) s))
                     else (TC c) :: (lex f r))
    fuel

type seg =
| SText of chars
| SPh of chars
| SBad of string

(** val ph_body :
    tok list -> chars -> ((chars * tok list) option, string) sum **)

let rec ph_body ts acc =
  match ts with
  | [] -> Inr "PP: {{ without }}"
  | t :: r ->
    (match t with
     | TC c -> ph_body r (app acc (c :: []))
     | TOpen -> Inr "PP: a placeholder inside a placeholder key"
     | TClose -> Inl (Some (acc, r))
     | TLit _ -> Inr "PP: an escape inside a placeholder"
     | TBad w -> Inr w)

(** val segs : int -> tok list -> seg list **)

let rec segs fuel ts =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> [])
    (fun f ->
    match ts with
    | [] -> []
    | t :: r ->
      (match t with
       | TC c -> (SText (c :: [])) :: (segs f r)
       | TOpen ->
         (match ph_body r [] with
          | Inl o ->
            (match o with
             | Some p -> let (c, r') = p in (SPh c) :: (segs f r')
             | None -> (SBad "PP: {{ without }}") :: [])
          | Inr w -> (SBad w) :: [])
       | TClose -> (SBad "PP: }} without {{") :: []
       | TLit s -> (SText s) :: (segs f r)
       | TBad w -> (SBad w) :: []))
    fuel

(** val parse : chars -> seg list **)

let parse s =
  segs (Stdlib.Int.succ (length s)) (lex (Stdlib.Int.succ (length s)) s)

(** val has_brackets : chars -> bool **)

let has_brackets s =
  (||) (occurs oPEN s) (occurs cLOSE s)

(** val has_escape : chars -> bool **)

let has_escape s =
  (||) (occurs (bsl :: (lbr :: (lbr :: []))) s)
    (occurs (bsl :: (rbr :: (rbr :: []))) s)

(** val is_keyc : char -> bool **)

let is_keyc c =
  (||) ((||) ((||) ((||) (is_letter c) (is_digit c)) (ceq c '.')) (ceq c '-'))
    (ceq c '_')

(** val good_key : chars -> bool **)

let good_key k = match k with
| [] -> false
| _ :: _ -> forallb is_keyc k

(** val env_spelling : chars -> chars **)

let env_spelling k =
  map (fun c -> if (||) (ceq c '.') (ceq c '-') then '_' else upc c) k

type lk =
| LFound of chars * bool
| LMissing
| LUns of string

(** val lookup_key : penv -> chars -> lk **)

let lookup_key pe k =
  let inenv = klookup k pe.pe_env in
  let insys = klookup k pe.pe_sys in
  (match klookup k pe.pe_override with
   | Some _ ->
     (match inenv with
      | Some _ ->
        LUns
          "PC/PCJ contradict: override properties (highest priority) vs OS environment / system properties (override mode)"
      | None ->
        (match insys with
         | Some _ ->
           LUns
             "PC/PCJ contradict: override properties (highest priority) vs OS environment / system properties (override mode)"
         | None ->
           if (&&) (negb (ceqs (env_spelling k) k))
                ((||) (match inenv with
                       | Some _ -> true
                       | None -> false)
                  (match klookup (env_spelling k) pe.pe_env with
                   | Some _ -> true
                   | None -> false))
           then LUns
                  "PC: a key not written as an OS variable, and an OS variable of that name or spelling: is it mapped?"
           else (match inenv with
                 | Some v -> LFound (v, true)
                 | None ->
                   (match insys with
                    | Some v -> LFound (v, true)
                    | None ->
                      (match klookup k pe.pe_override with
                       | Some v -> LFound (v, false)
                       | None ->
                         (match klookup k pe.pe_initial with
                          | Some v -> LFound (v, false)
                          | None -> LMissing))))))
   | None ->
     if (&&) (negb (ceqs (env_spelling k) k))
          ((||) (match inenv with
                 | Some _ -> true
                 | None -> false)
            (match klookup (env_spelling k) pe.pe_env with
             | Some _ -> true
             | None -> false))
     then LUns
            "PC: a key not written as an OS variable, and an OS variable of that name or spelling: is it mapped?"
     else (match inenv with
           | Some v -> LFound (v, true)
           | None ->
             (match insys with
              | Some v -> LFound (v, true)
              | None ->
                (match klookup k pe.pe_override with
                 | Some v -> LFound (v, false)
                 | None ->
                   (match klookup k pe.pe_initial with
                    | Some v -> LFound (v, false)
                    | None -> LMissing)))))

(** val split_colon : chars -> chars * chars option **)

let rec split_colon = function
| [] -> ([], None)
| c :: r ->
  if ceq c ':'
  then ([], (Some r))
  else let (a, b) = split_colon r in ((c :: a), b)

(** val use_value :
    (chars list -> chars -> pres) -> penv -> chars list -> chars -> bool ->
    chars -> bool -> pres **)

let use_value rec0 pe seen k nested v fromos =
  if (&&) nested pe.pe_nested
  then if existsb (ceqs k) seen
       then PUns "PP: a cycle of nested placeholders"
       else if (&&) fromos (has_brackets v)
            then PUns
                   "PP: placeholders inside an OS variable or system property value"
            else rec0 (k :: seen) v
  else if has_escape v
       then PUns "PP: escapes in a value that is not resolved (nested=false)"
       else PV v

(** val missing : chars option -> pres **)

let missing = function
| Some d -> PV d
| None -> iae

(** val f_env : penv -> chars -> chars option -> pres **)

let f_env pe name def =
  if negb (good_key name)
  then PUns "PF: env: variable name characters"
  else if negb
            (ceqs (replace_all (str "-") (str "_") (env_spelling name))
              (replace_all (str "-") (str "_") name))
       then PUns
              "PF: env: a name not written as an OS variable (upper case, _): is it mapped?"
       else let found = fun v ->
              if has_brackets v
              then PUns "PF: placeholders inside an OS variable value"
              else PV v
            in
            (match klookup name pe.pe_env with
             | Some v -> found v
             | None ->
               (match if occurs (str "-") name
                      then klookup (replace_all (str "-") (str "_") name)
                             pe.pe_env
                      else None with
                | Some v -> found v
                | None -> missing def))

(** val f_sys : penv -> chars -> chars option -> pres **)

let f_sys pe name def =
  if negb (good_key name)
  then PUns "PF: sys: property name characters"
  else (match klookup name pe.pe_sys with
        | Some v ->
          if has_brackets v
          then PUns "PF: placeholders inside a system property value"
          else PV v
        | None -> missing def)

(** val is_envc : char -> bool **)

let is_envc c =
  (||) ((||) (is_upper c) (is_digit c)) (ceq c '_')

(** val f_service : penv -> int -> chars -> chars option -> pres **)

let f_service pe part name def =
  if negb (match name with
           | [] -> false
           | _ :: _ -> forallb is_envc name)
  then PUns "PF: service: a name that is not upper case"
  else let h = klookup (app name (str "_SERVICE_HOST")) pe.pe_env in
       let p = klookup (app name (str "_SERVICE_PORT")) pe.pe_env in
       ((fun fO fS n -> if n=0 then fO () else fS (n-1))
          (fun _ ->
          match h with
          | Some hv ->
            (match p with
             | Some pv -> PV (app hv (':' :: pv))
             | None ->
               PUns
                 "PF: service: only one of _SERVICE_HOST and _SERVICE_PORT is set")
          | None ->
            (match p with
             | Some _ ->
               PUns
                 "PF: service: only one of _SERVICE_HOST and _SERVICE_PORT is set"
             | None -> missing def))
          (fun n0 ->
          (fun fO fS n -> if n=0 then fO () else fS (n-1))
            (fun _ ->
            match h with
            | Some hv -> PV hv
            | None -> missing def)
            (fun _ -> match p with
                      | Some pv -> PV pv
                      | None -> missing def)
            n0)
          part)

(** val ph :
    (chars list -> chars -> pres) -> penv -> chars list -> chars -> pres **)

let ph rec0 pe seen c =
  let k = trim c in
  let plain = fun key nested def ->
    if negb (good_key key)
    then PUns "PP: key characters (only letters, digits, . - _ are covered)"
    else (match lookup_key pe key with
          | LFound (v, os) -> use_value rec0 pe seen key nested v os
          | LMissing -> missing def
          | LUns w -> PUns w)
  in
  (match k with
   | [] -> PUns "PP: an empty placeholder"
   | a :: k' ->
     (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
       (fun b b0 b1 b2 b3 b4 b5 b6 ->
       if b
       then if b0
            then if b1
                 then if b2
                      then if b3
                           then if b4
                                then if b5
                                     then if suffix (str "?nested=false") k
                                          then let key =
                                                 firstn
                                                   (sub (length k)
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     0))))))))))))))
                                                   k
                                               in
                                               if negb (good_key key)
                                               then PUns
                                                      "PP: ?nested=false combined with another form"
                                               else plain key false None
                                          else if occurs (str "?") k
                                               then PUns
                                                      "PP: a question mark inside a placeholder"
                                               else if negb pe.pe_fallback
                                                    then if occurs (str ":") k
                                                         then PUns
                                                                "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                         else plain k true
                                                                None
                                                    else let (name, rest) =
                                                           split_colon k
                                                         in
                                                         if ceqs name
                                                              (str "env")
                                                         then (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_env pe n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: env without a name")
                                                         else if ceqs name
                                                                   (str "sys")
                                                              then (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_sys pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: sys without a name")
                                                              else if 
                                                                    (||)
                                                                    ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                                   then 
                                                                    let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                    in
                                                                    (
                                                                    match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                                   else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                                     else if b6
                                          then if suffix (str "?nested=false")
                                                    k
                                               then let key =
                                                      firstn
                                                        (sub (length k)
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          0))))))))))))))
                                                        k
                                                    in
                                                    if negb (good_key key)
                                                    then PUns
                                                           "PP: ?nested=false combined with another form"
                                                    else plain key false None
                                               else if occurs (str "?") k
                                                    then PUns
                                                           "PP: a question mark inside a placeholder"
                                                    else if negb
                                                              pe.pe_fallback
                                                         then if occurs
                                                                   (str ":") k
                                                              then PUns
                                                                    "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                              else plain k
                                                                    true None
                                                         else let (name, rest) =
                                                                split_colon k
                                                              in
                                                              if ceqs name
                                                                   (str "env")
                                                              then (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_env pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: env without a name")
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "sys")
                                                                   then 
                                                                    (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_sys pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: sys without a name")
                                                                   else 
                                                                    if 
                                                                    (||)
                                                                    ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                                    then 
                                                                    let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                    in
                                                                    (
                                                                    match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                                          else if negb (good_key k')
                                               then PUns
                                                      "PP: an optional placeholder combined with another form"
                                               else (match lookup_key pe k' with
                                                     | LFound (v, os) ->
                                                       use_value rec0 pe seen
                                                         k' true v os
                                                     | LMissing ->
                                                       PUns
                                                         "PP: a missing optional placeholder in a text (only endpoint URIs are documented)"
                                                     | LUns w -> PUns w)
                                else if suffix (str "?nested=false") k
                                     then let key =
                                            firstn
                                              (sub (length k) (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                0))))))))))))))
                                              k
                                          in
                                          if negb (good_key key)
                                          then PUns
                                                 "PP: ?nested=false combined with another form"
                                          else plain key false None
                                     else if occurs (str "?") k
                                          then PUns
                                                 "PP: a question mark inside a placeholder"
                                          else if negb pe.pe_fallback
                                               then if occurs (str ":") k
                                                    then PUns
                                                           "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                    else plain k true None
                                               else let (name, rest) =
                                                      split_colon k
                                                    in
                                                    if ceqs name (str "env")
                                                    then (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_env pe n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: env without a name")
                                                    else if ceqs name
                                                              (str "sys")
                                                         then (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_sys pe n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: sys without a name")
                                                         else if (||)
                                                                   ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                   (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                              then let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                   in
                                                                   (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                   then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                   else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                           else if suffix (str "?nested=false") k
                                then let key =
                                       firstn
                                         (sub (length k) (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           0))))))))))))))
                                         k
                                     in
                                     if negb (good_key key)
                                     then PUns
                                            "PP: ?nested=false combined with another form"
                                     else plain key false None
                                else if occurs (str "?") k
                                     then PUns
                                            "PP: a question mark inside a placeholder"
                                     else if negb pe.pe_fallback
                                          then if occurs (str ":") k
                                               then PUns
                                                      "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                               else plain k true None
                                          else let (name, rest) =
                                                 split_colon k
                                               in
                                               if ceqs name (str "env")
                                               then (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_env pe n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: env without a name")
                                               else if ceqs name (str "sys")
                                                    then (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_sys pe n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: sys without a name")
                                                    else if (||)
                                                              ((||)
                                                                (ceqs name
                                                                  (str
                                                                    "service"))
                                                                (ceqs name
                                                                  (str
                                                                    "service.host")))
                                                              (ceqs name
                                                                (str
                                                                  "service.port"))
                                                         then let part =
                                                                if ceqs name
                                                                    (str
                                                                    "service")
                                                                then 0
                                                                else 
                                                                  if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                  then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                  else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                              in
                                                              (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_service pe
                                                                   part n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: service without a name")
                                                         else if ceqs name
                                                                   (str
                                                                    "bean")
                                                              then PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                   then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                   else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                      else if suffix (str "?nested=false") k
                           then let key =
                                  firstn
                                    (sub (length k) (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      0))))))))))))))
                                    k
                                in
                                if negb (good_key key)
                                then PUns
                                       "PP: ?nested=false combined with another form"
                                else plain key false None
                           else if occurs (str "?") k
                                then PUns
                                       "PP: a question mark inside a placeholder"
                                else if negb pe.pe_fallback
                                     then if occurs (str ":") k
                                          then PUns
                                                 "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                          else plain k true None
                                     else let (name, rest) = split_colon k in
                                          if ceqs name (str "env")
                                          then (match rest with
                                                | Some r ->
                                                  let (n0, d) = split_colon r
                                                  in
                                                  f_env pe n0 d
                                                | None ->
                                                  PUns
                                                    "PF: env without a name")
                                          else if ceqs name (str "sys")
                                               then (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_sys pe n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: sys without a name")
                                               else if (||)
                                                         ((||)
                                                           (ceqs name
                                                             (str "service"))
                                                           (ceqs name
                                                             (str
                                                               "service.host")))
                                                         (ceqs name
                                                           (str
                                                             "service.port"))
                                                    then let part =
                                                           if ceqs name
                                                                (str
                                                                  "service")
                                                           then 0
                                                           else if ceqs name
                                                                    (str
                                                                    "service.host")
                                                                then 
                                                                  Stdlib.Int.succ
                                                                    0
                                                                else 
                                                                  Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                         in
                                                         (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_service pe part
                                                              n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: service without a name")
                                                    else if ceqs name
                                                              (str "bean")
                                                         then PUns
                                                                "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                         else if ceqs name
                                                                   (str
                                                                    "boolean")
                                                              then PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                              else if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                   then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                   else 
                                                                    plain name
                                                                    true rest
                 else if suffix (str "?nested=false") k
                      then let key =
                             firstn
                               (sub (length k) (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 0))))))))))))))
                               k
                           in
                           if negb (good_key key)
                           then PUns
                                  "PP: ?nested=false combined with another form"
                           else plain key false None
                      else if occurs (str "?") k
                           then PUns
                                  "PP: a question mark inside a placeholder"
                           else if negb pe.pe_fallback
                                then if occurs (str ":") k
                                     then PUns
                                            "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                     else plain k true None
                                else let (name, rest) = split_colon k in
                                     if ceqs name (str "env")
                                     then (match rest with
                                           | Some r ->
                                             let (n0, d) = split_colon r in
                                             f_env pe n0 d
                                           | None ->
                                             PUns "PF: env without a name")
                                     else if ceqs name (str "sys")
                                          then (match rest with
                                                | Some r ->
                                                  let (n0, d) = split_colon r
                                                  in
                                                  f_sys pe n0 d
                                                | None ->
                                                  PUns
                                                    "PF: sys without a name")
                                          else if (||)
                                                    ((||)
                                                      (ceqs name
                                                        (str "service"))
                                                      (ceqs name
                                                        (str "service.host")))
                                                    (ceqs name
                                                      (str "service.port"))
                                               then let part =
                                                      if ceqs name
                                                           (str "service")
                                                      then 0
                                                      else if ceqs name
                                                                (str
                                                                  "service.host")
                                                           then Stdlib.Int.succ
                                                                  0
                                                           else Stdlib.Int.succ
                                                                  (Stdlib.Int.succ
                                                                  0)
                                                    in
                                                    (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_service pe part n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: service without a name")
                                               else if ceqs name (str "bean")
                                                    then PUns
                                                           "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                    else if ceqs name
                                                              (str "boolean")
                                                         then PUns
                                                                "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                         else if negb
                                                                   (good_key
                                                                    name)
                                                              then PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                              else plain name
                                                                    true rest
            else if b1
                 then if suffix (str "?nested=false") k
                      then let key =
                             firstn
                               (sub (length k) (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 (Stdlib.Int.succ (Stdlib.Int.succ
                                 0))))))))))))))
                               k
                           in
                           if negb (good_key key)
                           then PUns
                                  "PP: ?nested=false combined with another form"
                           else plain key false None
                      else if occurs (str "?") k
                           then PUns
                                  "PP: a question mark inside a placeholder"
                           else if negb pe.pe_fallback
                                then if occurs (str ":") k
                                     then PUns
                                            "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                     else plain k true None
                                else let (name, rest) = split_colon k in
                                     if ceqs name (str "env")
                                     then (match rest with
                                           | Some r ->
                                             let (n0, d) = split_colon r in
                                             f_env pe n0 d
                                           | None ->
                                             PUns "PF: env without a name")
                                     else if ceqs name (str "sys")
                                          then (match rest with
                                                | Some r ->
                                                  let (n0, d) = split_colon r
                                                  in
                                                  f_sys pe n0 d
                                                | None ->
                                                  PUns
                                                    "PF: sys without a name")
                                          else if (||)
                                                    ((||)
                                                      (ceqs name
                                                        (str "service"))
                                                      (ceqs name
                                                        (str "service.host")))
                                                    (ceqs name
                                                      (str "service.port"))
                                               then let part =
                                                      if ceqs name
                                                           (str "service")
                                                      then 0
                                                      else if ceqs name
                                                                (str
                                                                  "service.host")
                                                           then Stdlib.Int.succ
                                                                  0
                                                           else Stdlib.Int.succ
                                                                  (Stdlib.Int.succ
                                                                  0)
                                                    in
                                                    (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_service pe part n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: service without a name")
                                               else if ceqs name (str "bean")
                                                    then PUns
                                                           "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                    else if ceqs name
                                                              (str "boolean")
                                                         then PUns
                                                                "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                         else if negb
                                                                   (good_key
                                                                    name)
                                                              then PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                              else plain name
                                                                    true rest
                 else if b2
                      then if suffix (str "?nested=false") k
                           then let key =
                                  firstn
                                    (sub (length k) (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      (Stdlib.Int.succ (Stdlib.Int.succ
                                      0))))))))))))))
                                    k
                                in
                                if negb (good_key key)
                                then PUns
                                       "PP: ?nested=false combined with another form"
                                else plain key false None
                           else if occurs (str "?") k
                                then PUns
                                       "PP: a question mark inside a placeholder"
                                else if negb pe.pe_fallback
                                     then if occurs (str ":") k
                                          then PUns
                                                 "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                          else plain k true None
                                     else let (name, rest) = split_colon k in
                                          if ceqs name (str "env")
                                          then (match rest with
                                                | Some r ->
                                                  let (n0, d) = split_colon r
                                                  in
                                                  f_env pe n0 d
                                                | None ->
                                                  PUns
                                                    "PF: env without a name")
                                          else if ceqs name (str "sys")
                                               then (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_sys pe n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: sys without a name")
                                               else if (||)
                                                         ((||)
                                                           (ceqs name
                                                             (str "service"))
                                                           (ceqs name
                                                             (str
                                                               "service.host")))
                                                         (ceqs name
                                                           (str
                                                             "service.port"))
                                                    then let part =
                                                           if ceqs name
                                                                (str
                                                                  "service")
                                                           then 0
                                                           else if ceqs name
                                                                    (str
                                                                    "service.host")
                                                                then 
                                                                  Stdlib.Int.succ
                                                                    0
                                                                else 
                                                                  Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                         in
                                                         (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_service pe part
                                                              n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: service without a name")
                                                    else if ceqs name
                                                              (str "bean")
                                                         then PUns
                                                                "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                         else if ceqs name
                                                                   (str
                                                                    "boolean")
                                                              then PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                              else if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                   then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                   else 
                                                                    plain name
                                                                    true rest
                      else if b3
                           then if suffix (str "?nested=false") k
                                then let key =
                                       firstn
                                         (sub (length k) (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           (Stdlib.Int.succ (Stdlib.Int.succ
                                           0))))))))))))))
                                         k
                                     in
                                     if negb (good_key key)
                                     then PUns
                                            "PP: ?nested=false combined with another form"
                                     else plain key false None
                                else if occurs (str "?") k
                                     then PUns
                                            "PP: a question mark inside a placeholder"
                                     else if negb pe.pe_fallback
                                          then if occurs (str ":") k
                                               then PUns
                                                      "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                               else plain k true None
                                          else let (name, rest) =
                                                 split_colon k
                                               in
                                               if ceqs name (str "env")
                                               then (match rest with
                                                     | Some r ->
                                                       let (n0, d) =
                                                         split_colon r
                                                       in
                                                       f_env pe n0 d
                                                     | None ->
                                                       PUns
                                                         "PF: env without a name")
                                               else if ceqs name (str "sys")
                                                    then (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_sys pe n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: sys without a name")
                                                    else if (||)
                                                              ((||)
                                                                (ceqs name
                                                                  (str
                                                                    "service"))
                                                                (ceqs name
                                                                  (str
                                                                    "service.host")))
                                                              (ceqs name
                                                                (str
                                                                  "service.port"))
                                                         then let part =
                                                                if ceqs name
                                                                    (str
                                                                    "service")
                                                                then 0
                                                                else 
                                                                  if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                  then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                  else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                              in
                                                              (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_service pe
                                                                   part n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: service without a name")
                                                         else if ceqs name
                                                                   (str
                                                                    "bean")
                                                              then PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                   then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                   else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                           else if b4
                                then if b5
                                     then if suffix (str "?nested=false") k
                                          then let key =
                                                 firstn
                                                   (sub (length k)
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     (Stdlib.Int.succ
                                                     0))))))))))))))
                                                   k
                                               in
                                               if negb (good_key key)
                                               then PUns
                                                      "PP: ?nested=false combined with another form"
                                               else plain key false None
                                          else if occurs (str "?") k
                                               then PUns
                                                      "PP: a question mark inside a placeholder"
                                               else if negb pe.pe_fallback
                                                    then if occurs (str ":") k
                                                         then PUns
                                                                "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                         else plain k true
                                                                None
                                                    else let (name, rest) =
                                                           split_colon k
                                                         in
                                                         if ceqs name
                                                              (str "env")
                                                         then (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_env pe n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: env without a name")
                                                         else if ceqs name
                                                                   (str "sys")
                                                              then (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_sys pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: sys without a name")
                                                              else if 
                                                                    (||)
                                                                    ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                                   then 
                                                                    let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                    in
                                                                    (
                                                                    match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                                   else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                                     else if b6
                                          then if suffix (str "?nested=false")
                                                    k
                                               then let key =
                                                      firstn
                                                        (sub (length k)
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          (Stdlib.Int.succ
                                                          0))))))))))))))
                                                        k
                                                    in
                                                    if negb (good_key key)
                                                    then PUns
                                                           "PP: ?nested=false combined with another form"
                                                    else plain key false None
                                               else if occurs (str "?") k
                                                    then PUns
                                                           "PP: a question mark inside a placeholder"
                                                    else if negb
                                                              pe.pe_fallback
                                                         then if occurs
                                                                   (str ":") k
                                                              then PUns
                                                                    "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                              else plain k
                                                                    true None
                                                         else let (name, rest) =
                                                                split_colon k
                                                              in
                                                              if ceqs name
                                                                   (str "env")
                                                              then (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_env pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: env without a name")
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "sys")
                                                                   then 
                                                                    (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_sys pe
                                                                    n0 d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: sys without a name")
                                                                   else 
                                                                    if 
                                                                    (||)
                                                                    ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                                    then 
                                                                    let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                    in
                                                                    (
                                                                    match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
                                          else if negb (good_key k')
                                               then PUns
                                                      "PP: a negated placeholder combined with another form"
                                               else (match lookup_key pe k' with
                                                     | LFound (v, os) ->
                                                       pbind
                                                         (use_value rec0 pe
                                                           seen k' true v os)
                                                         (fun s ->
                                                         if ceqs s
                                                              (str "true")
                                                         then PV (str "false")
                                                         else if ceqs s
                                                                   (str
                                                                    "false")
                                                              then PV
                                                                    (str
                                                                    "true")
                                                              else PUns
                                                                    "PP: negating a value that is not true or false")
                                                     | LMissing ->
                                                       PUns
                                                         "PP: a missing negated placeholder"
                                                     | LUns w -> PUns w)
                                else if suffix (str "?nested=false") k
                                     then let key =
                                            firstn
                                              (sub (length k) (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                (Stdlib.Int.succ
                                                0))))))))))))))
                                              k
                                          in
                                          if negb (good_key key)
                                          then PUns
                                                 "PP: ?nested=false combined with another form"
                                          else plain key false None
                                     else if occurs (str "?") k
                                          then PUns
                                                 "PP: a question mark inside a placeholder"
                                          else if negb pe.pe_fallback
                                               then if occurs (str ":") k
                                                    then PUns
                                                           "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                                                    else plain k true None
                                               else let (name, rest) =
                                                      split_colon k
                                                    in
                                                    if ceqs name (str "env")
                                                    then (match rest with
                                                          | Some r ->
                                                            let (n0, d) =
                                                              split_colon r
                                                            in
                                                            f_env pe n0 d
                                                          | None ->
                                                            PUns
                                                              "PF: env without a name")
                                                    else if ceqs name
                                                              (str "sys")
                                                         then (match rest with
                                                               | Some r ->
                                                                 let (
                                                                   n0, d) =
                                                                   split_colon
                                                                    r
                                                                 in
                                                                 f_sys pe n0 d
                                                               | None ->
                                                                 PUns
                                                                   "PF: sys without a name")
                                                         else if (||)
                                                                   ((||)
                                                                    (ceqs name
                                                                    (str
                                                                    "service"))
                                                                    (ceqs name
                                                                    (str
                                                                    "service.host")))
                                                                   (ceqs name
                                                                    (str
                                                                    "service.port"))
                                                              then let part =
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service")
                                                                    then 0
                                                                    else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "service.host")
                                                                    then 
                                                                    Stdlib.Int.succ
                                                                    0
                                                                    else 
                                                                    Stdlib.Int.succ
                                                                    (Stdlib.Int.succ
                                                                    0)
                                                                   in
                                                                   (match rest with
                                                                    | Some r ->
                                                                    let (
                                                                    n0, d) =
                                                                    split_colon
                                                                    r
                                                                    in
                                                                    f_service
                                                                    pe part n0
                                                                    d
                                                                    | None ->
                                                                    PUns
                                                                    "PF: service without a name")
                                                              else if 
                                                                    ceqs name
                                                                    (str
                                                                    "bean")
                                                                   then 
                                                                    PUns
                                                                    "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                                                   else 
                                                                    if 
                                                                    ceqs name
                                                                    (str
                                                                    "boolean")
                                                                    then 
                                                                    PUns
                                                                    "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                                                    else 
                                                                    if 
                                                                    negb
                                                                    (good_key
                                                                    name)
                                                                    then 
                                                                    PUns
                                                                    "PP: key characters (only letters, digits, . - _ are covered)"
                                                                    else 
                                                                    plain name
                                                                    true rest
       else if suffix (str "?nested=false") k
            then let key =
                   firstn
                     (sub (length k) (Stdlib.Int.succ (Stdlib.Int.succ
                       (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                       (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                       (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                       (Stdlib.Int.succ (Stdlib.Int.succ 0))))))))))))))
                     k
                 in
                 if negb (good_key key)
                 then PUns "PP: ?nested=false combined with another form"
                 else plain key false None
            else if occurs (str "?") k
                 then PUns "PP: a question mark inside a placeholder"
                 else if negb pe.pe_fallback
                      then if occurs (str ":") k
                           then PUns
                                  "PC: default-fallback-enabled=false with a colon: the key characters are not covered"
                           else plain k true None
                      else let (name, rest) = split_colon k in
                           if ceqs name (str "env")
                           then (match rest with
                                 | Some r ->
                                   let (n0, d) = split_colon r in
                                   f_env pe n0 d
                                 | None -> PUns "PF: env without a name")
                           else if ceqs name (str "sys")
                                then (match rest with
                                      | Some r ->
                                        let (n0, d) = split_colon r in
                                        f_sys pe n0 d
                                      | None -> PUns "PF: sys without a name")
                                else if (||)
                                          ((||) (ceqs name (str "service"))
                                            (ceqs name (str "service.host")))
                                          (ceqs name (str "service.port"))
                                     then let part =
                                            if ceqs name (str "service")
                                            then 0
                                            else if ceqs name
                                                      (str "service.host")
                                                 then Stdlib.Int.succ 0
                                                 else Stdlib.Int.succ
                                                        (Stdlib.Int.succ 0)
                                          in
                                          (match rest with
                                           | Some r ->
                                             let (n0, d) = split_colon r in
                                             f_service pe part n0 d
                                           | None ->
                                             PUns "PF: service without a name")
                                     else if ceqs name (str "bean")
                                          then PUns
                                                 "out of scope: the bean: function (needs a registry and camel-bean) [PF.262-300]"
                                          else if ceqs name (str "boolean")
                                               then PUns
                                                      "out of scope: the boolean: function (Simple over properties) [PF.95-174]"
                                               else if negb (good_key name)
                                                    then PUns
                                                           "PP: key characters (only letters, digits, . - _ are covered)"
                                                    else plain name true rest)
       a)

(** val res_text : int -> penv -> chars list -> chars -> pres **)

let rec res_text fuel pe seen s =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> PUns "PP: nesting deeper than the model's bound")
    (fun f ->
    fold_right (fun sg acc ->
      match sg with
      | SText t -> pbind acc (fun r -> PV (app t r))
      | SPh c ->
        (match ph (res_text f pe) pe seen c with
         | PV v -> pbind acc (fun r -> PV (app v r))
         | x -> (match acc with
                 | PUns w -> PUns w
                 | _ -> x))
      | SBad w -> PUns w) (PV []) (parse s))
    fuel

(** val resolve : penv -> chars -> pres **)

let resolve pe s =
  res_text (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    0)))))))))))))))) pe [] s

type val0 =
| VNull
| VStr of chars
| VInt of Big_int_Z.big_int
| VLong of Big_int_Z.big_int
| VDbl of Big_int_Z.big_int
| VBool of bool
| VList of chars list

(** val dbltext : Big_int_Z.big_int -> chars **)

let dbltext q =
  let a = Z.abs q in
  app (if Z.ltb q Big_int_Z.zero_big_int then str "-" else [])
    (app
      (ztext
        (Z.div a ((fun p -> Big_int_Z.shift_left_big_int p 1)
          ((fun p -> Big_int_Z.shift_left_big_int p 1)
          Big_int_Z.unit_big_int))))
      ('.' :: ((fun fO fS n -> if n=0 then fO () else fS (n-1))
                 (fun _ -> str "0")
                 (fun n0 ->
                 (fun fO fS n -> if n=0 then fO () else fS (n-1))
                   (fun _ -> str "25")
                   (fun n1 ->
                   (fun fO fS n -> if n=0 then fO () else fS (n-1))
                     (fun _ -> str "5")
                     (fun _ -> str "75")
                     n1)
                   n0)
                 (Z.to_nat
                   (Z.modulo a ((fun p -> Big_int_Z.shift_left_big_int p 1)
                     ((fun p -> Big_int_Z.shift_left_big_int p 1)
                     Big_int_Z.unit_big_int)))))))

(** val btext : bool -> chars **)

let btext = function
| true -> str "true"
| false -> str "false"

(** val text_of : val0 -> chars option **)

let text_of = function
| VStr s -> Some s
| VInt z0 -> Some (ztext z0)
| VLong z0 -> Some (ztext z0)
| VDbl q -> Some (dbltext q)
| VBool b -> Some (btext b)
| _ -> None

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

(** val cilookup : chars -> (chars * val0) list -> look **)

let cilookup k l =
  match filter (fun pat -> let (k', _) = pat in ceqs (lower k) (lower k')) l with
  | [] -> Absent
  | p :: l0 ->
    let (_, v) = p in
    (match l0 with
     | [] -> Found v
     | _ :: _ -> Amb "env: two headers whose names differ only in case")

(** val exact : chars -> (chars * val0) list -> val0 option **)

let rec exact k = function
| [] -> None
| p :: l' -> let (k', v) = p in if ceqs k k' then Some v else exact k l'

(** val exlookup : string -> chars -> (chars * val0) list -> look **)

let exlookup what k l =
  match exact k l with
  | Some v -> Found v
  | None ->
    if existsb (fun pat -> let (k', _) = pat in ceqs (lower k) (lower k')) l
    then Amb
           ((^) what
             ": is the name case-sensitive? (only a name differing in case exists)")
    else Absent

(** val etext : bool -> chars -> chars **)

let etext trim_on s =
  if trim_on then trim s else s

(** val name_guard : string -> chars -> string option **)

let name_guard lang s =
  if prefix (str "resource:") s
  then Some "out of scope: resource: loading of the expression text [CJc.29]"
  else if occurs (str "{{") s
       then Some
              ((^) "PP: placeholders in a "
                ((^) lang " name ('almost anywhere' [PP.3-4])"))
       else if occurs (str "${") s
            then Some ((^) "" ((^) lang ": a ${ } in the name"))
            else (match s with
                  | [] -> Some ((^) "" ((^) lang ": an empty name"))
                  | _ :: _ -> None)

(** val str_truth : chars -> bool **)

let str_truth s =
  let t = trim s in
  (match t with
   | [] -> false
   | _ :: _ -> if ceqs (lower t) (str "false") then false else true)

(** val as_pred : lres -> lres **)

let as_pred r = match r with
| LV v ->
  (match v with
   | VNull -> LV (VBool false)
   | VStr s -> LV (VBool (str_truth s))
   | VBool b -> LV (VBool b)
   | VList l -> LV (VBool (negb ((=) (length l) 0)))
   | _ -> LV (VBool true))
| _ -> r

(** val ev_constant : lenv -> chars -> chars option -> bool -> lres **)

let ev_constant x text rtype trim_on =
  match rtype with
  | Some _ ->
    LUns0 "C: resultType needs type conversion (pending L0/Convert.v)"
  | None ->
    let t = etext trim_on text in
    if prefix (str "resource:") t
    then LUns0
           "out of scope: resource: loading of the expression text [C.131-179]"
    else if (||) ((||) (occurs (str "{{") text) (occurs (str "}}") text))
              (occurs (str "\\") text)
         then (match resolve x.le_pp t with
               | PV a ->
                 (match resolve x.le_pp text with
                  | PV b ->
                    if ceqs a (etext trim_on b)
                    then LV (VStr a)
                    else LUns0
                           "C: trim before or after resolving the placeholders"
                  | PFail _ ->
                    LUns0 "C: trim before or after resolving the placeholders"
                  | PUns w -> LUns0 w)
               | PFail e ->
                 (match resolve x.le_pp text with
                  | PV _ ->
                    LUns0 "C: trim before or after resolving the placeholders"
                  | PFail _ -> LErr e
                  | PUns w -> LUns0 w)
               | PUns w -> LUns0 w)
         else LV (VStr t)

(** val ev_header : lenv -> chars -> bool -> lres **)

let ev_header x name trim_on =
  let k = etext trim_on name in
  (match name_guard "header" k with
   | Some w -> LUns0 w
   | None ->
     (match cilookup k x.le_headers with
      | Found v ->
        (match v with
         | VNull -> LUns0 "H: a header present with the value null"
         | _ -> LV v)
      | Absent ->
        (match exlookup "XP" k x.le_xprops with
         | Found v -> LV v
         | Absent -> LV VNull
         | Amb w -> LUns0 w)
      | Amb w -> LUns0 w))

(** val ev_prop : lenv -> chars -> bool -> lres **)

let ev_prop x name trim_on =
  let k = etext trim_on name in
  (match name_guard "exchangeProperty" k with
   | Some w -> LUns0 w
   | None ->
     (match exlookup "XP" k x.le_xprops with
      | Found v -> LV v
      | Absent -> LV VNull
      | Amb w -> LUns0 w))

(** val ev_var : lenv -> chars -> bool -> lres **)

let ev_var x name trim_on =
  let k = etext trim_on name in
  let res = fun l ->
    match l with
    | Found v -> LV v
    | Absent -> LV VNull
    | Amb w -> LUns0 w
  in
  (match name_guard "variable" k with
   | Some w -> LUns0 w
   | None ->
     if prefix (str "global:") k
     then res
            (exlookup "VA"
              (skipn (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                (Stdlib.Int.succ 0))))))) k)
              x.le_gvars)
     else if prefix (str "route:") k
          then LUns0 "out of scope: route: variables need a route [VA.80-95]"
          else if prefix (str "group:") k
               then let r =
                      skipn (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                        (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                        0)))))) k
                    in
                    (match split_on ':' r with
                     | [] ->
                       LUns0
                         "VA: a group: variable name that is not group:g:name"
                     | g :: l ->
                       (match l with
                        | [] ->
                          LUns0
                            "VA: a group: variable name that is not group:g:name"
                        | n0 :: l0 ->
                          (match l0 with
                           | [] ->
                             (match filter (fun pat ->
                                      let (g', _) = pat in ceqs g g')
                                      x.le_groups with
                              | [] -> LV VNull
                              | p :: _ ->
                                let (_, l1) = p in res (exlookup "VA" n0 l1))
                           | _ :: _ ->
                             LUns0
                               "VA: a group: variable name that is not group:g:name")))
               else if occurs (str ":") k
                    then LUns0
                           "VA: a name with a colon and no documented repository id"
                    else res (exlookup "VA" k x.le_vars))

(** val ev_ref : lenv -> chars -> chars option -> bool -> bool -> lres **)

let ev_ref x name rtype trim_on as_predicate =
  let k = etext trim_on name in
  (match rtype with
   | Some _ ->
     LUns0 "R: resultType needs type conversion (pending L0/Convert.v)"
   | None ->
     (match name_guard "ref" k with
      | Some w -> LUns0 w
      | None ->
        (match filter (fun pat -> let (k', _) = pat in ceqs k k') x.le_reg with
         | [] ->
           if existsb (fun pat ->
                let (k', _) = pat in ceqs (lower k) (lower k')) x.le_reg
           then LUns0 "R: is the registry id case-sensitive?"
           else LUns0 "R: a ref to an id that is not in the registry"
         | p :: _ ->
           let (_, r) = p in
           (match r with
            | RgExpr v -> if as_predicate then as_pred (LV v) else LV v
            | RgPred b -> LV (VBool b)
            | RgOther _ ->
              LUns0
                "R: a registry bean that is neither an Expression nor a Predicate"))))

type tkopts = { tk_token : chars; tk_end : chars option; tk_regex : bool;
                tk_xml : bool; tk_incl : bool; tk_group : chars option;
                tk_gdelim : chars option; tk_skip : bool;
                tk_source : chars option; tk_inherit : chars option }

(** val nl : char **)

let nl =
  ascii_of_nat (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
    (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ 0))))))))))

(** val tok_text : string -> bool -> chars -> (chars, string) sum **)

let tok_text what pairmode t =
  let t' =
    if pairmode then t else replace_all (bsl :: ('n' :: [])) (nl :: []) t
  in
  if occurs (str "${") t
  then Inr ((^) "TK: simple language in the " ((^) what " (dynamic tokens)"))
  else if occurs (str "{{") t
       then Inr ((^) "PP: placeholders in the " what)
       else if occurs (bsl :: []) t'
            then Inr
                   ((^) "TK: a backslash in the "
                     ((^) what
                       (if pairmode then " (pair mode)" else " other than \\n")))
            else (match t' with
                  | [] -> Inr ((^) "TK: an empty " what)
                  | _ :: _ ->
                    if ceqs t' (nl :: [])
                    then Inl t'
                    else if negb (ceqs (trim t') t')
                         then Inr
                                ((^) "TK: a "
                                  ((^) what
                                    " with white space at an end (trim?)"))
                         else Inl t')

(** val is_meta : char -> bool **)

let is_meta c =
  existsb (ceq c) (str "\\^$.|?*+()[]{}")

type ratom = { ra_set : chars; ra_plus : bool }

(** val parse_re : chars -> ratom option **)

let parse_re = function
| [] -> None
| c :: r ->
  (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
    (fun b b0 b1 b2 b3 b4 b5 b6 ->
    if b
    then if b0
         then if b1
              then (match r with
                    | [] ->
                      if is_meta c
                      then None
                      else Some { ra_set = (c :: []); ra_plus = false }
                    | a :: l ->
                      (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                        (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                        if b7
                        then if b8
                             then if b9
                                  then None
                                  else if b10
                                       then if b11
                                            then None
                                            else if b12
                                                 then if b13
                                                      then None
                                                      else if b14
                                                           then None
                                                           else (match l with
                                                                 | [] ->
                                                                   if 
                                                                    is_meta c
                                                                   then None
                                                                   else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                 | _ :: _ ->
                                                                   None)
                                                 else None
                                       else None
                             else None
                        else None)
                        a)
              else if b2
                   then if b3
                        then if b4
                             then (match r with
                                   | [] ->
                                     if is_meta c
                                     then None
                                     else Some { ra_set = (c :: []); ra_plus =
                                            false }
                                   | a :: l ->
                                     (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                       (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                       if b7
                                       then if b8
                                            then if b9
                                                 then None
                                                 else if b10
                                                      then if b11
                                                           then None
                                                           else if b12
                                                                then 
                                                                  if b13
                                                                  then None
                                                                  else 
                                                                    if b14
                                                                    then None
                                                                    else 
                                                                    (match l with
                                                                    | [] ->
                                                                    if 
                                                                    is_meta c
                                                                    then None
                                                                    else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                    | _ :: _ ->
                                                                    None)
                                                                else None
                                                      else None
                                            else None
                                       else None)
                                       a)
                             else if b5
                                  then if b6
                                       then (match r with
                                             | [] ->
                                               if is_meta c
                                               then None
                                               else Some { ra_set = (c :: []);
                                                      ra_plus = false }
                                             | a :: l ->
                                               (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                 (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                 if b7
                                                 then if b8
                                                      then if b9
                                                           then None
                                                           else if b10
                                                                then 
                                                                  if b11
                                                                  then None
                                                                  else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then None
                                                                    else 
                                                                    if b14
                                                                    then None
                                                                    else 
                                                                    (match l with
                                                                    | [] ->
                                                                    if 
                                                                    is_meta c
                                                                    then None
                                                                    else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                    | _ :: _ ->
                                                                    None)
                                                                    else None
                                                                else None
                                                      else None
                                                 else None)
                                                 a)
                                       else (match rev r with
                                             | [] -> None
                                             | a :: inner ->
                                               (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                 (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                 if b7
                                                 then if b8
                                                      then if b9
                                                           then None
                                                           else if b10
                                                                then 
                                                                  if b11
                                                                  then None
                                                                  else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then None
                                                                    else 
                                                                    if b14
                                                                    then None
                                                                    else 
                                                                    (match inner with
                                                                    | [] ->
                                                                    None
                                                                    | a0 :: inner0 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    if b16
                                                                    then None
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    if b20
                                                                    then None
                                                                    else 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then None
                                                                    else 
                                                                    let s =
                                                                    rev inner0
                                                                    in
                                                                    if 
                                                                    (&&)
                                                                    (negb
                                                                    (existsb
                                                                    is_meta s))
                                                                    (negb
                                                                    ((=)
                                                                    (length s)
                                                                    0))
                                                                    then 
                                                                    Some
                                                                    { ra_set =
                                                                    s;
                                                                    ra_plus =
                                                                    true }
                                                                    else None
                                                                    else None
                                                                    else None
                                                                    else None
                                                                    else None
                                                                    else None)
                                                                    a0)
                                                                    else None
                                                                else None
                                                      else if b9
                                                           then if b10
                                                                then 
                                                                  if b11
                                                                  then 
                                                                    if b12
                                                                    then None
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then None
                                                                    else 
                                                                    let s =
                                                                    rev inner
                                                                    in
                                                                    if 
                                                                    (&&)
                                                                    (negb
                                                                    (existsb
                                                                    is_meta s))
                                                                    (negb
                                                                    ((=)
                                                                    (length s)
                                                                    0))
                                                                    then 
                                                                    Some
                                                                    { ra_set =
                                                                    s;
                                                                    ra_plus =
                                                                    false }
                                                                    else None
                                                                    else None
                                                                  else None
                                                                else None
                                                           else None
                                                 else None)
                                                 a)
                                  else (match r with
                                        | [] ->
                                          if is_meta c
                                          then None
                                          else Some { ra_set = (c :: []);
                                                 ra_plus = false }
                                        | a :: l ->
                                          (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                            (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                            if b7
                                            then if b8
                                                 then if b9
                                                      then None
                                                      else if b10
                                                           then if b11
                                                                then None
                                                                else 
                                                                  if b12
                                                                  then 
                                                                    if b13
                                                                    then None
                                                                    else 
                                                                    if b14
                                                                    then None
                                                                    else 
                                                                    (match l with
                                                                    | [] ->
                                                                    if 
                                                                    is_meta c
                                                                    then None
                                                                    else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                    | _ :: _ ->
                                                                    None)
                                                                  else None
                                                           else None
                                                 else None
                                            else None)
                                            a)
                        else (match r with
                              | [] ->
                                if is_meta c
                                then None
                                else Some { ra_set = (c :: []); ra_plus =
                                       false }
                              | a :: l ->
                                (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                  (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                  if b7
                                  then if b8
                                       then if b9
                                            then None
                                            else if b10
                                                 then if b11
                                                      then None
                                                      else if b12
                                                           then if b13
                                                                then None
                                                                else 
                                                                  if b14
                                                                  then None
                                                                  else 
                                                                    (match l with
                                                                    | [] ->
                                                                    if 
                                                                    is_meta c
                                                                    then None
                                                                    else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                    | _ :: _ ->
                                                                    None)
                                                           else None
                                                 else None
                                       else None
                                  else None)
                                  a)
                   else (match r with
                         | [] ->
                           if is_meta c
                           then None
                           else Some { ra_set = (c :: []); ra_plus = false }
                         | a :: l ->
                           (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                             (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                             if b7
                             then if b8
                                  then if b9
                                       then None
                                       else if b10
                                            then if b11
                                                 then None
                                                 else if b12
                                                      then if b13
                                                           then None
                                                           else if b14
                                                                then None
                                                                else 
                                                                  (match l with
                                                                   | [] ->
                                                                    if 
                                                                    is_meta c
                                                                    then None
                                                                    else 
                                                                    Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                                   | _ :: _ ->
                                                                    None)
                                                      else None
                                            else None
                                  else None
                             else None)
                             a)
         else (match r with
               | [] ->
                 if is_meta c
                 then None
                 else Some { ra_set = (c :: []); ra_plus = false }
               | a :: l ->
                 (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                   (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                   if b7
                   then if b8
                        then if b9
                             then None
                             else if b10
                                  then if b11
                                       then None
                                       else if b12
                                            then if b13
                                                 then None
                                                 else if b14
                                                      then None
                                                      else (match l with
                                                            | [] ->
                                                              if is_meta c
                                                              then None
                                                              else Some
                                                                    { ra_set =
                                                                    (c :: []);
                                                                    ra_plus =
                                                                    true }
                                                            | _ :: _ -> None)
                                            else None
                                  else None
                        else None
                   else None)
                   a)
    else (match r with
          | [] ->
            if is_meta c
            then None
            else Some { ra_set = (c :: []); ra_plus = false }
          | a :: l ->
            (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
              (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
              if b7
              then if b8
                   then if b9
                        then None
                        else if b10
                             then if b11
                                  then None
                                  else if b12
                                       then if b13
                                            then None
                                            else if b14
                                                 then None
                                                 else (match l with
                                                       | [] ->
                                                         if is_meta c
                                                         then None
                                                         else Some { ra_set =
                                                                (c :: []);
                                                                ra_plus =
                                                                true }
                                                       | _ :: _ -> None)
                                       else None
                             else None
                   else None
              else None)
              a))
    c

(** val ra_len : ratom -> chars -> int **)

let rec ra_len a = function
| [] -> 0
| c :: r ->
  if existsb (ceq c) a.ra_set
  then Stdlib.Int.succ (if a.ra_plus then ra_len a r else 0)
  else 0

(** val split_by : int -> (chars -> int) -> chars -> chars -> chars list **)

let rec split_by fuel m s cur =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> (app cur s) :: [])
    (fun f ->
    match s with
    | [] -> cur :: []
    | c :: r ->
      ((fun fO fS n -> if n=0 then fO () else fS (n-1))
         (fun _ -> split_by f m r (app cur (c :: [])))
         (fun n0 ->
         cur :: (split_by f m (skipn (Stdlib.Int.succ n0) s) []))
         (m s)))
    fuel

(** val lit_match : chars -> chars -> int **)

let lit_match t s =
  if prefix t s then length t else 0

(** val pairs :
    int -> chars -> chars -> chars -> bool -> (chars list, string) sum **)

let rec pairs fuel t e s incl =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> Inr "TK: pairs: fuel")
    (fun f ->
    match find t s with
    | Some i ->
      if occurs e (firstn i s)
      then Inr "TK: an end token outside a pair"
      else let after = skipn (add i (length t)) s in
           (match find e after with
            | Some j ->
              let content = firstn j after in
              if occurs t content
              then Inr "TK: a start token inside a pair"
              else (match pairs f t e (skipn (add j (length e)) after) incl with
                    | Inl ps ->
                      Inl
                        ((if incl then app t (app content e) else content) :: ps)
                    | Inr w -> Inr w)
            | None -> Inr "TK: a start token without an end token")
    | None ->
      if occurs e s then Inr "TK: an end token outside a pair" else Inl [])
    fuel

(** val chunks : int -> int -> chars list -> chars list list **)

let rec chunks fuel n0 l =
  (fun fO fS n -> if n=0 then fO () else fS (n-1))
    (fun _ -> l :: [])
    (fun f ->
    match l with
    | [] -> []
    | _ :: _ -> (firstn n0 l) :: (chunks f n0 (skipn n0 l)))
    fuel

(** val tk_input : lenv -> tkopts -> (val0, string) sum **)

let tk_input x o =
  let byvar = fun n0 ->
    match exlookup "VA" n0 x.le_vars with
    | Found v -> Inl v
    | Absent -> Inl VNull
    | Amb w -> Inr w
  in
  (match o.tk_source with
   | Some s ->
     (match s with
      | [] -> Inl x.le_body
      | _ :: _ ->
        if prefix (str "variable:") s
        then byvar
               (skipn (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                 (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ 0)))))))))
                 s)
        else if prefix (str "header:") s
             then let n0 =
                    skipn (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                      (Stdlib.Int.succ (Stdlib.Int.succ (Stdlib.Int.succ
                      (Stdlib.Int.succ 0))))))) s
                  in
                  (match cilookup n0 x.le_headers with
                   | Found v -> Inl v
                   | Absent ->
                     (match exlookup "XP" n0 x.le_xprops with
                      | Absent -> Inl VNull
                      | _ ->
                        Inr
                          "TK: a header: source missing as a header but present as a property")
                   | Amb w -> Inr w)
             else if prefix (str "property:") s
                  then (match exlookup "XP"
                                (skipn (Stdlib.Int.succ (Stdlib.Int.succ
                                  (Stdlib.Int.succ (Stdlib.Int.succ
                                  (Stdlib.Int.succ (Stdlib.Int.succ
                                  (Stdlib.Int.succ (Stdlib.Int.succ
                                  (Stdlib.Int.succ 0))))))))) s)
                                x.le_xprops with
                        | Found v -> Inl v
                        | Absent -> Inl VNull
                        | Amb w -> Inr w)
                  else if occurs (str ":") s
                       then Inr
                              "TK: a source with a colon and an unknown kind"
                       else byvar s)
   | None -> Inl x.le_body)

(** val ev_tokenize : lenv -> tkopts -> chars option -> lres **)

let ev_tokenize x o = function
| Some _ ->
  LUns0 "TK: resultType needs type conversion (pending L0/Convert.v)"
| None ->
  if o.tk_xml
  then LUns0 "out of scope: tokenize xml mode"
  else (match o.tk_inherit with
        | Some _ ->
          LUns0 "out of scope: tokenize inheritNamespaceTagName (XML)"
        | None ->
          (match tk_input x o with
           | Inl v ->
             (match v with
              | VNull ->
                if (&&)
                     (match o.tk_source with
                      | Some c -> (match c with
                                   | [] -> true
                                   | _ :: _ -> false)
                      | None -> true)
                     (negb o.tk_xml)
                then LV (VList [])
                else LUns0 "TK: tokenizing a null input"
              | VStr _ ->
                (match text_of v with
                 | Some s ->
                   if (&&) (negb (match v with
                                  | VStr _ -> true
                                  | _ -> false))
                        (match o.tk_end with
                         | Some _ -> true
                         | None -> false)
                   then LErr []
                   else let pairmode =
                          match o.tk_end with
                          | Some _ -> true
                          | None -> false
                        in
                        (match tok_text "token" pairmode o.tk_token with
                         | Inl t ->
                           let grp =
                             match o.tk_group with
                             | Some g ->
                               if occurs (str "${") g
                               then Inr "TK: simple language in group"
                               else if all_digits g
                                    then let n0 =
                                           Z.to_nat
                                             (digits_val g
                                               Big_int_Z.zero_big_int)
                                         in
                                         if Nat.ltb 0 n0
                                         then Inl (Some n0)
                                         else Inr
                                                "SE: group must be a positive number"
                                    else Inr
                                           "SE: group must be a positive number"
                             | None -> Inl None
                           in
                           (match grp with
                            | Inl grp0 ->
                              let parts =
                                match o.tk_end with
                                | Some e ->
                                  if o.tk_regex
                                  then Inr "TK: regex with an end token"
                                  else (match tok_text "endToken" true e with
                                        | Inl e' ->
                                          if ceqs t e'
                                          then Inr "!IllegalArgumentException"
                                          else if (||) (occurs t e')
                                                    (occurs e' t)
                                               then Inr
                                                      "TK: start and end tokens that overlap"
                                               else (match grp0 with
                                                     | Some _ ->
                                                       Inr
                                                         "TK: group with start/end pairs"
                                                     | None ->
                                                       (match pairs
                                                                (Stdlib.Int.succ
                                                                (length s)) t
                                                                e' s o.tk_incl with
                                                        | Inl ps ->
                                                          (match ps with
                                                           | [] ->
                                                             Inr
                                                               "TK: no start/end pair in the text"
                                                           | _ :: _ ->
                                                             if existsb
                                                                  (fun p ->
                                                                  (=)
                                                                    (length p)
                                                                    0)
                                                                  ps
                                                             then Inr
                                                                    "TK: an empty part"
                                                             else Inl ps)
                                                        | Inr w -> Inr w))
                                        | Inr w -> Inr w)
                                | None ->
                                  if o.tk_incl
                                  then Inr
                                         "TK: includeTokens without an end token (must be configured [CJt.32])"
                                  else let ps =
                                         if o.tk_regex
                                         then (match parse_re t with
                                               | Some a ->
                                                 Inl
                                                   (split_by (Stdlib.Int.succ
                                                     (length s)) (ra_len a) s
                                                     [])
                                               | None ->
                                                 Inr
                                                   "out of scope: a regex pattern outside the model's small regex language")
                                         else Inl
                                                (split_by (Stdlib.Int.succ
                                                  (length s)) (lit_match t) s
                                                  [])
                                       in
                                       (match ps with
                                        | Inl ps0 ->
                                          if existsb (fun p ->
                                               (=) (length p) 0) ps0
                                          then Inr "TK: an empty part"
                                          else Inl ps0
                                        | Inr w -> Inr w)
                              in
                              (match parts with
                               | Inl ps ->
                                 (match grp0 with
                                  | Some n0 ->
                                    if o.tk_skip
                                    then LUns0
                                           "TK: skipFirst with group (the first part or the first group?)"
                                    else let d =
                                           match o.tk_gdelim with
                                           | Some d ->
                                             if (||)
                                                  ((||) (occurs (bsl :: []) d)
                                                    (occurs (str "${") d))
                                                  (occurs (str "{{") d)
                                             then Inr
                                                    "TK: a backslash, ${ } or {{ }} in groupDelimiter"
                                             else Inl d
                                           | None ->
                                             if o.tk_regex
                                             then Inr
                                                    "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                                             else Inl t
                                         in
                                         (match d with
                                          | Inl d0 ->
                                            LV (VList
                                              (map (concat_with d0)
                                                (chunks (Stdlib.Int.succ
                                                  (length ps)) n0 ps)))
                                          | Inr w -> LUns0 w)
                                  | None ->
                                    LV (VList
                                      (if o.tk_skip then tl ps else ps)))
                               | Inr w ->
                                 ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                    (fun _ -> LUns0 w)
                                    (fun a s0 ->
                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                      (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                      if b
                                      then if b0
                                           then LUns0 w
                                           else if b1
                                                then LUns0 w
                                                else if b2
                                                     then LUns0 w
                                                     else if b3
                                                          then LUns0 w
                                                          else if b4
                                                               then if b5
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b6
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a0 s1 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a1 s2 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a2 s3 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b23 b24 b25 b26 b27 b28 b29 b30 ->
                                                                    if b23
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b24
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then 
                                                                    if b27
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a3 s4 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b31 b32 b33 b34 b35 b36 b37 b38 ->
                                                                    if b31
                                                                    then 
                                                                    if b32
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b33
                                                                    then 
                                                                    if b34
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a4 s5 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b39 b40 b41 b42 b43 b44 b45 b46 ->
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then 
                                                                    if b41
                                                                    then 
                                                                    if b42
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b43
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a5 s6 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b47 b48 b49 b50 b51 b52 b53 b54 ->
                                                                    if b47
                                                                    then 
                                                                    if b48
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b50
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b51
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a6 s7 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b55 b56 b57 b58 b59 b60 b61 b62 ->
                                                                    if b55
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b56
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b57
                                                                    then 
                                                                    if b58
                                                                    then 
                                                                    if b59
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then 
                                                                    if b62
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a7 s8 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b63 b64 b65 b66 b67 b68 b69 b70 ->
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b66
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b67
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b68
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a8 s9 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b71 b72 b73 b74 b75 b76 b77 b78 ->
                                                                    if b71
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b74
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b75
                                                                    then 
                                                                    if b76
                                                                    then 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a9 s10 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b79 b80 b81 b82 b83 b84 b85 b86 ->
                                                                    if b79
                                                                    then 
                                                                    if b80
                                                                    then 
                                                                    if b81
                                                                    then 
                                                                    if b82
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b84
                                                                    then 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a10 s11 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b87 b88 b89 b90 b91 b92 b93 b94 ->
                                                                    if b87
                                                                    then 
                                                                    if b88
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b89
                                                                    then 
                                                                    if b90
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b91
                                                                    then 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then 
                                                                    if b94
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a11 s12 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b95 b96 b97 b98 b99 b100 b101 b102 ->
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b97
                                                                    then 
                                                                    if b98
                                                                    then 
                                                                    if b99
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a12 s13 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b103 b104 b105 b106 b107 b108 b109 b110 ->
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b107
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a13 s14 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b111 b112 b113 b114 b115 b116 b117 b118 ->
                                                                    if b111
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then 
                                                                    if b114
                                                                    then 
                                                                    if b115
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a14 s15 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b119 b120 b121 b122 b123 b124 b125 b126 ->
                                                                    if b119
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a15 s16 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b127 b128 b129 b130 b131 b132 b133 b134 ->
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b131
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a16 s17 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b135 b136 b137 b138 b139 b140 b141 b142 ->
                                                                    if b135
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b137
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b138
                                                                    then 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a17 s18 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b143 b144 b145 b146 b147 b148 b149 b150 ->
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b146
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a18 s19 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b151 b152 b153 b154 b155 b156 b157 b158 ->
                                                                    if b151
                                                                    then 
                                                                    if b152
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b153
                                                                    then 
                                                                    if b154
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b155
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then 
                                                                    if b158
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a19 s20 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b159 b160 b161 b162 b163 b164 b165 b166 ->
                                                                    if b159
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b160
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b162
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b163
                                                                    then 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a20 s21 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b167 b168 b169 b170 b171 b172 b173 b174 ->
                                                                    if b167
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b168
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b169
                                                                    then 
                                                                    if b170
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a21 s22 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b175 b176 b177 b178 b179 b180 b181 b182 ->
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b177
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a22 s23 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b183 b184 b185 b186 b187 b188 b189 b190 ->
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then 
                                                                    if b186
                                                                    then 
                                                                    if b187
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a23 s24 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b191 b192 b193 b194 b195 b196 b197 b198 ->
                                                                    if b191
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b192
                                                                    then 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then 
                                                                    if b195
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LErr
                                                                    (str
                                                                    "IllegalArgumentException"))
                                                                    (fun _ _ ->
                                                                    LUns0
                                                                    w)
                                                                    s24)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a23)
                                                                    s23)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a22)
                                                                    s22)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a21)
                                                                    s21)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a20)
                                                                    s20)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a19)
                                                                    s19)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a18)
                                                                    s18)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a17)
                                                                    s17)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a16)
                                                                    s16)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a15)
                                                                    s15)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a14)
                                                                    s14)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a13)
                                                                    s13)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a12)
                                                                    s12)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a11)
                                                                    s11)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a10)
                                                                    s10)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a9)
                                                                    s9)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a8)
                                                                    s8)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a7)
                                                                    s7)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a6)
                                                                    s6)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a5)
                                                                    s5)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a4)
                                                                    s4)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a3)
                                                                    s3)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a2)
                                                                    s2)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a1)
                                                                    s1)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a0)
                                                                    s0)
                                                               else LUns0 w
                                      else LUns0 w)
                                      a)
                                    w))
                            | Inr w -> LUns0 w)
                         | Inr w -> LUns0 w)
                 | None -> LUns0 "TK: input text")
              | VInt _ ->
                (match text_of v with
                 | Some s ->
                   if (&&) (negb (match v with
                                  | VStr _ -> true
                                  | _ -> false))
                        (match o.tk_end with
                         | Some _ -> true
                         | None -> false)
                   then LErr []
                   else let pairmode =
                          match o.tk_end with
                          | Some _ -> true
                          | None -> false
                        in
                        (match tok_text "token" pairmode o.tk_token with
                         | Inl t ->
                           let grp =
                             match o.tk_group with
                             | Some g ->
                               if occurs (str "${") g
                               then Inr "TK: simple language in group"
                               else if all_digits g
                                    then let n0 =
                                           Z.to_nat
                                             (digits_val g
                                               Big_int_Z.zero_big_int)
                                         in
                                         if Nat.ltb 0 n0
                                         then Inl (Some n0)
                                         else Inr
                                                "SE: group must be a positive number"
                                    else Inr
                                           "SE: group must be a positive number"
                             | None -> Inl None
                           in
                           (match grp with
                            | Inl grp0 ->
                              let parts =
                                match o.tk_end with
                                | Some e ->
                                  if o.tk_regex
                                  then Inr "TK: regex with an end token"
                                  else (match tok_text "endToken" true e with
                                        | Inl e' ->
                                          if ceqs t e'
                                          then Inr "!IllegalArgumentException"
                                          else if (||) (occurs t e')
                                                    (occurs e' t)
                                               then Inr
                                                      "TK: start and end tokens that overlap"
                                               else (match grp0 with
                                                     | Some _ ->
                                                       Inr
                                                         "TK: group with start/end pairs"
                                                     | None ->
                                                       (match pairs
                                                                (Stdlib.Int.succ
                                                                (length s)) t
                                                                e' s o.tk_incl with
                                                        | Inl ps ->
                                                          (match ps with
                                                           | [] ->
                                                             Inr
                                                               "TK: no start/end pair in the text"
                                                           | _ :: _ ->
                                                             if existsb
                                                                  (fun p ->
                                                                  (=)
                                                                    (length p)
                                                                    0)
                                                                  ps
                                                             then Inr
                                                                    "TK: an empty part"
                                                             else Inl ps)
                                                        | Inr w -> Inr w))
                                        | Inr w -> Inr w)
                                | None ->
                                  if o.tk_incl
                                  then Inr
                                         "TK: includeTokens without an end token (must be configured [CJt.32])"
                                  else let ps =
                                         if o.tk_regex
                                         then (match parse_re t with
                                               | Some a ->
                                                 Inl
                                                   (split_by (Stdlib.Int.succ
                                                     (length s)) (ra_len a) s
                                                     [])
                                               | None ->
                                                 Inr
                                                   "out of scope: a regex pattern outside the model's small regex language")
                                         else Inl
                                                (split_by (Stdlib.Int.succ
                                                  (length s)) (lit_match t) s
                                                  [])
                                       in
                                       (match ps with
                                        | Inl ps0 ->
                                          if existsb (fun p ->
                                               (=) (length p) 0) ps0
                                          then Inr "TK: an empty part"
                                          else Inl ps0
                                        | Inr w -> Inr w)
                              in
                              (match parts with
                               | Inl ps ->
                                 (match grp0 with
                                  | Some n0 ->
                                    if o.tk_skip
                                    then LUns0
                                           "TK: skipFirst with group (the first part or the first group?)"
                                    else let d =
                                           match o.tk_gdelim with
                                           | Some d ->
                                             if (||)
                                                  ((||) (occurs (bsl :: []) d)
                                                    (occurs (str "${") d))
                                                  (occurs (str "{{") d)
                                             then Inr
                                                    "TK: a backslash, ${ } or {{ }} in groupDelimiter"
                                             else Inl d
                                           | None ->
                                             if o.tk_regex
                                             then Inr
                                                    "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                                             else Inl t
                                         in
                                         (match d with
                                          | Inl d0 ->
                                            LV (VList
                                              (map (concat_with d0)
                                                (chunks (Stdlib.Int.succ
                                                  (length ps)) n0 ps)))
                                          | Inr w -> LUns0 w)
                                  | None ->
                                    LV (VList
                                      (if o.tk_skip then tl ps else ps)))
                               | Inr w ->
                                 ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                    (fun _ -> LUns0 w)
                                    (fun a s0 ->
                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                      (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                      if b
                                      then if b0
                                           then LUns0 w
                                           else if b1
                                                then LUns0 w
                                                else if b2
                                                     then LUns0 w
                                                     else if b3
                                                          then LUns0 w
                                                          else if b4
                                                               then if b5
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b6
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a0 s1 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a1 s2 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a2 s3 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b23 b24 b25 b26 b27 b28 b29 b30 ->
                                                                    if b23
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b24
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then 
                                                                    if b27
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a3 s4 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b31 b32 b33 b34 b35 b36 b37 b38 ->
                                                                    if b31
                                                                    then 
                                                                    if b32
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b33
                                                                    then 
                                                                    if b34
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a4 s5 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b39 b40 b41 b42 b43 b44 b45 b46 ->
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then 
                                                                    if b41
                                                                    then 
                                                                    if b42
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b43
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a5 s6 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b47 b48 b49 b50 b51 b52 b53 b54 ->
                                                                    if b47
                                                                    then 
                                                                    if b48
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b50
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b51
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a6 s7 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b55 b56 b57 b58 b59 b60 b61 b62 ->
                                                                    if b55
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b56
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b57
                                                                    then 
                                                                    if b58
                                                                    then 
                                                                    if b59
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then 
                                                                    if b62
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a7 s8 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b63 b64 b65 b66 b67 b68 b69 b70 ->
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b66
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b67
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b68
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a8 s9 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b71 b72 b73 b74 b75 b76 b77 b78 ->
                                                                    if b71
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b74
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b75
                                                                    then 
                                                                    if b76
                                                                    then 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a9 s10 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b79 b80 b81 b82 b83 b84 b85 b86 ->
                                                                    if b79
                                                                    then 
                                                                    if b80
                                                                    then 
                                                                    if b81
                                                                    then 
                                                                    if b82
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b84
                                                                    then 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a10 s11 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b87 b88 b89 b90 b91 b92 b93 b94 ->
                                                                    if b87
                                                                    then 
                                                                    if b88
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b89
                                                                    then 
                                                                    if b90
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b91
                                                                    then 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then 
                                                                    if b94
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a11 s12 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b95 b96 b97 b98 b99 b100 b101 b102 ->
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b97
                                                                    then 
                                                                    if b98
                                                                    then 
                                                                    if b99
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a12 s13 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b103 b104 b105 b106 b107 b108 b109 b110 ->
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b107
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a13 s14 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b111 b112 b113 b114 b115 b116 b117 b118 ->
                                                                    if b111
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then 
                                                                    if b114
                                                                    then 
                                                                    if b115
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a14 s15 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b119 b120 b121 b122 b123 b124 b125 b126 ->
                                                                    if b119
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a15 s16 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b127 b128 b129 b130 b131 b132 b133 b134 ->
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b131
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a16 s17 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b135 b136 b137 b138 b139 b140 b141 b142 ->
                                                                    if b135
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b137
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b138
                                                                    then 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a17 s18 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b143 b144 b145 b146 b147 b148 b149 b150 ->
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b146
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a18 s19 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b151 b152 b153 b154 b155 b156 b157 b158 ->
                                                                    if b151
                                                                    then 
                                                                    if b152
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b153
                                                                    then 
                                                                    if b154
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b155
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then 
                                                                    if b158
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a19 s20 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b159 b160 b161 b162 b163 b164 b165 b166 ->
                                                                    if b159
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b160
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b162
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b163
                                                                    then 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a20 s21 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b167 b168 b169 b170 b171 b172 b173 b174 ->
                                                                    if b167
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b168
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b169
                                                                    then 
                                                                    if b170
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a21 s22 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b175 b176 b177 b178 b179 b180 b181 b182 ->
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b177
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a22 s23 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b183 b184 b185 b186 b187 b188 b189 b190 ->
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then 
                                                                    if b186
                                                                    then 
                                                                    if b187
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a23 s24 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b191 b192 b193 b194 b195 b196 b197 b198 ->
                                                                    if b191
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b192
                                                                    then 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then 
                                                                    if b195
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LErr
                                                                    (str
                                                                    "IllegalArgumentException"))
                                                                    (fun _ _ ->
                                                                    LUns0
                                                                    w)
                                                                    s24)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a23)
                                                                    s23)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a22)
                                                                    s22)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a21)
                                                                    s21)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a20)
                                                                    s20)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a19)
                                                                    s19)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a18)
                                                                    s18)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a17)
                                                                    s17)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a16)
                                                                    s16)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a15)
                                                                    s15)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a14)
                                                                    s14)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a13)
                                                                    s13)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a12)
                                                                    s12)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a11)
                                                                    s11)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a10)
                                                                    s10)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a9)
                                                                    s9)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a8)
                                                                    s8)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a7)
                                                                    s7)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a6)
                                                                    s6)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a5)
                                                                    s5)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a4)
                                                                    s4)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a3)
                                                                    s3)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a2)
                                                                    s2)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a1)
                                                                    s1)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a0)
                                                                    s0)
                                                               else LUns0 w
                                      else LUns0 w)
                                      a)
                                    w))
                            | Inr w -> LUns0 w)
                         | Inr w -> LUns0 w)
                 | None -> LUns0 "TK: input text")
              | VLong _ ->
                (match text_of v with
                 | Some s ->
                   if (&&) (negb (match v with
                                  | VStr _ -> true
                                  | _ -> false))
                        (match o.tk_end with
                         | Some _ -> true
                         | None -> false)
                   then LErr []
                   else let pairmode =
                          match o.tk_end with
                          | Some _ -> true
                          | None -> false
                        in
                        (match tok_text "token" pairmode o.tk_token with
                         | Inl t ->
                           let grp =
                             match o.tk_group with
                             | Some g ->
                               if occurs (str "${") g
                               then Inr "TK: simple language in group"
                               else if all_digits g
                                    then let n0 =
                                           Z.to_nat
                                             (digits_val g
                                               Big_int_Z.zero_big_int)
                                         in
                                         if Nat.ltb 0 n0
                                         then Inl (Some n0)
                                         else Inr
                                                "SE: group must be a positive number"
                                    else Inr
                                           "SE: group must be a positive number"
                             | None -> Inl None
                           in
                           (match grp with
                            | Inl grp0 ->
                              let parts =
                                match o.tk_end with
                                | Some e ->
                                  if o.tk_regex
                                  then Inr "TK: regex with an end token"
                                  else (match tok_text "endToken" true e with
                                        | Inl e' ->
                                          if ceqs t e'
                                          then Inr "!IllegalArgumentException"
                                          else if (||) (occurs t e')
                                                    (occurs e' t)
                                               then Inr
                                                      "TK: start and end tokens that overlap"
                                               else (match grp0 with
                                                     | Some _ ->
                                                       Inr
                                                         "TK: group with start/end pairs"
                                                     | None ->
                                                       (match pairs
                                                                (Stdlib.Int.succ
                                                                (length s)) t
                                                                e' s o.tk_incl with
                                                        | Inl ps ->
                                                          (match ps with
                                                           | [] ->
                                                             Inr
                                                               "TK: no start/end pair in the text"
                                                           | _ :: _ ->
                                                             if existsb
                                                                  (fun p ->
                                                                  (=)
                                                                    (length p)
                                                                    0)
                                                                  ps
                                                             then Inr
                                                                    "TK: an empty part"
                                                             else Inl ps)
                                                        | Inr w -> Inr w))
                                        | Inr w -> Inr w)
                                | None ->
                                  if o.tk_incl
                                  then Inr
                                         "TK: includeTokens without an end token (must be configured [CJt.32])"
                                  else let ps =
                                         if o.tk_regex
                                         then (match parse_re t with
                                               | Some a ->
                                                 Inl
                                                   (split_by (Stdlib.Int.succ
                                                     (length s)) (ra_len a) s
                                                     [])
                                               | None ->
                                                 Inr
                                                   "out of scope: a regex pattern outside the model's small regex language")
                                         else Inl
                                                (split_by (Stdlib.Int.succ
                                                  (length s)) (lit_match t) s
                                                  [])
                                       in
                                       (match ps with
                                        | Inl ps0 ->
                                          if existsb (fun p ->
                                               (=) (length p) 0) ps0
                                          then Inr "TK: an empty part"
                                          else Inl ps0
                                        | Inr w -> Inr w)
                              in
                              (match parts with
                               | Inl ps ->
                                 (match grp0 with
                                  | Some n0 ->
                                    if o.tk_skip
                                    then LUns0
                                           "TK: skipFirst with group (the first part or the first group?)"
                                    else let d =
                                           match o.tk_gdelim with
                                           | Some d ->
                                             if (||)
                                                  ((||) (occurs (bsl :: []) d)
                                                    (occurs (str "${") d))
                                                  (occurs (str "{{") d)
                                             then Inr
                                                    "TK: a backslash, ${ } or {{ }} in groupDelimiter"
                                             else Inl d
                                           | None ->
                                             if o.tk_regex
                                             then Inr
                                                    "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                                             else Inl t
                                         in
                                         (match d with
                                          | Inl d0 ->
                                            LV (VList
                                              (map (concat_with d0)
                                                (chunks (Stdlib.Int.succ
                                                  (length ps)) n0 ps)))
                                          | Inr w -> LUns0 w)
                                  | None ->
                                    LV (VList
                                      (if o.tk_skip then tl ps else ps)))
                               | Inr w ->
                                 ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                    (fun _ -> LUns0 w)
                                    (fun a s0 ->
                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                      (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                      if b
                                      then if b0
                                           then LUns0 w
                                           else if b1
                                                then LUns0 w
                                                else if b2
                                                     then LUns0 w
                                                     else if b3
                                                          then LUns0 w
                                                          else if b4
                                                               then if b5
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b6
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a0 s1 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a1 s2 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a2 s3 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b23 b24 b25 b26 b27 b28 b29 b30 ->
                                                                    if b23
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b24
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then 
                                                                    if b27
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a3 s4 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b31 b32 b33 b34 b35 b36 b37 b38 ->
                                                                    if b31
                                                                    then 
                                                                    if b32
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b33
                                                                    then 
                                                                    if b34
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a4 s5 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b39 b40 b41 b42 b43 b44 b45 b46 ->
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then 
                                                                    if b41
                                                                    then 
                                                                    if b42
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b43
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a5 s6 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b47 b48 b49 b50 b51 b52 b53 b54 ->
                                                                    if b47
                                                                    then 
                                                                    if b48
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b50
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b51
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a6 s7 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b55 b56 b57 b58 b59 b60 b61 b62 ->
                                                                    if b55
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b56
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b57
                                                                    then 
                                                                    if b58
                                                                    then 
                                                                    if b59
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then 
                                                                    if b62
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a7 s8 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b63 b64 b65 b66 b67 b68 b69 b70 ->
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b66
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b67
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b68
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a8 s9 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b71 b72 b73 b74 b75 b76 b77 b78 ->
                                                                    if b71
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b74
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b75
                                                                    then 
                                                                    if b76
                                                                    then 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a9 s10 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b79 b80 b81 b82 b83 b84 b85 b86 ->
                                                                    if b79
                                                                    then 
                                                                    if b80
                                                                    then 
                                                                    if b81
                                                                    then 
                                                                    if b82
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b84
                                                                    then 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a10 s11 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b87 b88 b89 b90 b91 b92 b93 b94 ->
                                                                    if b87
                                                                    then 
                                                                    if b88
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b89
                                                                    then 
                                                                    if b90
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b91
                                                                    then 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then 
                                                                    if b94
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a11 s12 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b95 b96 b97 b98 b99 b100 b101 b102 ->
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b97
                                                                    then 
                                                                    if b98
                                                                    then 
                                                                    if b99
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a12 s13 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b103 b104 b105 b106 b107 b108 b109 b110 ->
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b107
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a13 s14 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b111 b112 b113 b114 b115 b116 b117 b118 ->
                                                                    if b111
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then 
                                                                    if b114
                                                                    then 
                                                                    if b115
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a14 s15 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b119 b120 b121 b122 b123 b124 b125 b126 ->
                                                                    if b119
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a15 s16 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b127 b128 b129 b130 b131 b132 b133 b134 ->
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b131
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a16 s17 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b135 b136 b137 b138 b139 b140 b141 b142 ->
                                                                    if b135
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b137
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b138
                                                                    then 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a17 s18 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b143 b144 b145 b146 b147 b148 b149 b150 ->
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b146
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a18 s19 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b151 b152 b153 b154 b155 b156 b157 b158 ->
                                                                    if b151
                                                                    then 
                                                                    if b152
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b153
                                                                    then 
                                                                    if b154
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b155
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then 
                                                                    if b158
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a19 s20 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b159 b160 b161 b162 b163 b164 b165 b166 ->
                                                                    if b159
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b160
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b162
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b163
                                                                    then 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a20 s21 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b167 b168 b169 b170 b171 b172 b173 b174 ->
                                                                    if b167
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b168
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b169
                                                                    then 
                                                                    if b170
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a21 s22 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b175 b176 b177 b178 b179 b180 b181 b182 ->
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b177
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a22 s23 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b183 b184 b185 b186 b187 b188 b189 b190 ->
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then 
                                                                    if b186
                                                                    then 
                                                                    if b187
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a23 s24 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b191 b192 b193 b194 b195 b196 b197 b198 ->
                                                                    if b191
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b192
                                                                    then 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then 
                                                                    if b195
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LErr
                                                                    (str
                                                                    "IllegalArgumentException"))
                                                                    (fun _ _ ->
                                                                    LUns0
                                                                    w)
                                                                    s24)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a23)
                                                                    s23)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a22)
                                                                    s22)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a21)
                                                                    s21)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a20)
                                                                    s20)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a19)
                                                                    s19)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a18)
                                                                    s18)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a17)
                                                                    s17)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a16)
                                                                    s16)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a15)
                                                                    s15)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a14)
                                                                    s14)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a13)
                                                                    s13)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a12)
                                                                    s12)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a11)
                                                                    s11)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a10)
                                                                    s10)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a9)
                                                                    s9)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a8)
                                                                    s8)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a7)
                                                                    s7)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a6)
                                                                    s6)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a5)
                                                                    s5)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a4)
                                                                    s4)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a3)
                                                                    s3)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a2)
                                                                    s2)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a1)
                                                                    s1)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a0)
                                                                    s0)
                                                               else LUns0 w
                                      else LUns0 w)
                                      a)
                                    w))
                            | Inr w -> LUns0 w)
                         | Inr w -> LUns0 w)
                 | None -> LUns0 "TK: input text")
              | VDbl _ ->
                (match text_of v with
                 | Some s ->
                   if (&&) (negb (match v with
                                  | VStr _ -> true
                                  | _ -> false))
                        (match o.tk_end with
                         | Some _ -> true
                         | None -> false)
                   then LErr []
                   else let pairmode =
                          match o.tk_end with
                          | Some _ -> true
                          | None -> false
                        in
                        (match tok_text "token" pairmode o.tk_token with
                         | Inl t ->
                           let grp =
                             match o.tk_group with
                             | Some g ->
                               if occurs (str "${") g
                               then Inr "TK: simple language in group"
                               else if all_digits g
                                    then let n0 =
                                           Z.to_nat
                                             (digits_val g
                                               Big_int_Z.zero_big_int)
                                         in
                                         if Nat.ltb 0 n0
                                         then Inl (Some n0)
                                         else Inr
                                                "SE: group must be a positive number"
                                    else Inr
                                           "SE: group must be a positive number"
                             | None -> Inl None
                           in
                           (match grp with
                            | Inl grp0 ->
                              let parts =
                                match o.tk_end with
                                | Some e ->
                                  if o.tk_regex
                                  then Inr "TK: regex with an end token"
                                  else (match tok_text "endToken" true e with
                                        | Inl e' ->
                                          if ceqs t e'
                                          then Inr "!IllegalArgumentException"
                                          else if (||) (occurs t e')
                                                    (occurs e' t)
                                               then Inr
                                                      "TK: start and end tokens that overlap"
                                               else (match grp0 with
                                                     | Some _ ->
                                                       Inr
                                                         "TK: group with start/end pairs"
                                                     | None ->
                                                       (match pairs
                                                                (Stdlib.Int.succ
                                                                (length s)) t
                                                                e' s o.tk_incl with
                                                        | Inl ps ->
                                                          (match ps with
                                                           | [] ->
                                                             Inr
                                                               "TK: no start/end pair in the text"
                                                           | _ :: _ ->
                                                             if existsb
                                                                  (fun p ->
                                                                  (=)
                                                                    (length p)
                                                                    0)
                                                                  ps
                                                             then Inr
                                                                    "TK: an empty part"
                                                             else Inl ps)
                                                        | Inr w -> Inr w))
                                        | Inr w -> Inr w)
                                | None ->
                                  if o.tk_incl
                                  then Inr
                                         "TK: includeTokens without an end token (must be configured [CJt.32])"
                                  else let ps =
                                         if o.tk_regex
                                         then (match parse_re t with
                                               | Some a ->
                                                 Inl
                                                   (split_by (Stdlib.Int.succ
                                                     (length s)) (ra_len a) s
                                                     [])
                                               | None ->
                                                 Inr
                                                   "out of scope: a regex pattern outside the model's small regex language")
                                         else Inl
                                                (split_by (Stdlib.Int.succ
                                                  (length s)) (lit_match t) s
                                                  [])
                                       in
                                       (match ps with
                                        | Inl ps0 ->
                                          if existsb (fun p ->
                                               (=) (length p) 0) ps0
                                          then Inr "TK: an empty part"
                                          else Inl ps0
                                        | Inr w -> Inr w)
                              in
                              (match parts with
                               | Inl ps ->
                                 (match grp0 with
                                  | Some n0 ->
                                    if o.tk_skip
                                    then LUns0
                                           "TK: skipFirst with group (the first part or the first group?)"
                                    else let d =
                                           match o.tk_gdelim with
                                           | Some d ->
                                             if (||)
                                                  ((||) (occurs (bsl :: []) d)
                                                    (occurs (str "${") d))
                                                  (occurs (str "{{") d)
                                             then Inr
                                                    "TK: a backslash, ${ } or {{ }} in groupDelimiter"
                                             else Inl d
                                           | None ->
                                             if o.tk_regex
                                             then Inr
                                                    "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                                             else Inl t
                                         in
                                         (match d with
                                          | Inl d0 ->
                                            LV (VList
                                              (map (concat_with d0)
                                                (chunks (Stdlib.Int.succ
                                                  (length ps)) n0 ps)))
                                          | Inr w -> LUns0 w)
                                  | None ->
                                    LV (VList
                                      (if o.tk_skip then tl ps else ps)))
                               | Inr w ->
                                 ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                    (fun _ -> LUns0 w)
                                    (fun a s0 ->
                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                      (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                      if b
                                      then if b0
                                           then LUns0 w
                                           else if b1
                                                then LUns0 w
                                                else if b2
                                                     then LUns0 w
                                                     else if b3
                                                          then LUns0 w
                                                          else if b4
                                                               then if b5
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b6
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a0 s1 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a1 s2 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a2 s3 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b23 b24 b25 b26 b27 b28 b29 b30 ->
                                                                    if b23
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b24
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then 
                                                                    if b27
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a3 s4 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b31 b32 b33 b34 b35 b36 b37 b38 ->
                                                                    if b31
                                                                    then 
                                                                    if b32
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b33
                                                                    then 
                                                                    if b34
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a4 s5 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b39 b40 b41 b42 b43 b44 b45 b46 ->
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then 
                                                                    if b41
                                                                    then 
                                                                    if b42
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b43
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a5 s6 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b47 b48 b49 b50 b51 b52 b53 b54 ->
                                                                    if b47
                                                                    then 
                                                                    if b48
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b50
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b51
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a6 s7 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b55 b56 b57 b58 b59 b60 b61 b62 ->
                                                                    if b55
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b56
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b57
                                                                    then 
                                                                    if b58
                                                                    then 
                                                                    if b59
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then 
                                                                    if b62
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a7 s8 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b63 b64 b65 b66 b67 b68 b69 b70 ->
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b66
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b67
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b68
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a8 s9 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b71 b72 b73 b74 b75 b76 b77 b78 ->
                                                                    if b71
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b74
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b75
                                                                    then 
                                                                    if b76
                                                                    then 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a9 s10 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b79 b80 b81 b82 b83 b84 b85 b86 ->
                                                                    if b79
                                                                    then 
                                                                    if b80
                                                                    then 
                                                                    if b81
                                                                    then 
                                                                    if b82
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b84
                                                                    then 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a10 s11 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b87 b88 b89 b90 b91 b92 b93 b94 ->
                                                                    if b87
                                                                    then 
                                                                    if b88
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b89
                                                                    then 
                                                                    if b90
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b91
                                                                    then 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then 
                                                                    if b94
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a11 s12 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b95 b96 b97 b98 b99 b100 b101 b102 ->
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b97
                                                                    then 
                                                                    if b98
                                                                    then 
                                                                    if b99
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a12 s13 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b103 b104 b105 b106 b107 b108 b109 b110 ->
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b107
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a13 s14 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b111 b112 b113 b114 b115 b116 b117 b118 ->
                                                                    if b111
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then 
                                                                    if b114
                                                                    then 
                                                                    if b115
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a14 s15 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b119 b120 b121 b122 b123 b124 b125 b126 ->
                                                                    if b119
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a15 s16 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b127 b128 b129 b130 b131 b132 b133 b134 ->
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b131
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a16 s17 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b135 b136 b137 b138 b139 b140 b141 b142 ->
                                                                    if b135
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b137
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b138
                                                                    then 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a17 s18 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b143 b144 b145 b146 b147 b148 b149 b150 ->
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b146
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a18 s19 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b151 b152 b153 b154 b155 b156 b157 b158 ->
                                                                    if b151
                                                                    then 
                                                                    if b152
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b153
                                                                    then 
                                                                    if b154
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b155
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then 
                                                                    if b158
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a19 s20 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b159 b160 b161 b162 b163 b164 b165 b166 ->
                                                                    if b159
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b160
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b162
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b163
                                                                    then 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a20 s21 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b167 b168 b169 b170 b171 b172 b173 b174 ->
                                                                    if b167
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b168
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b169
                                                                    then 
                                                                    if b170
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a21 s22 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b175 b176 b177 b178 b179 b180 b181 b182 ->
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b177
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a22 s23 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b183 b184 b185 b186 b187 b188 b189 b190 ->
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then 
                                                                    if b186
                                                                    then 
                                                                    if b187
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a23 s24 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b191 b192 b193 b194 b195 b196 b197 b198 ->
                                                                    if b191
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b192
                                                                    then 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then 
                                                                    if b195
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LErr
                                                                    (str
                                                                    "IllegalArgumentException"))
                                                                    (fun _ _ ->
                                                                    LUns0
                                                                    w)
                                                                    s24)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a23)
                                                                    s23)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a22)
                                                                    s22)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a21)
                                                                    s21)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a20)
                                                                    s20)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a19)
                                                                    s19)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a18)
                                                                    s18)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a17)
                                                                    s17)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a16)
                                                                    s16)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a15)
                                                                    s15)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a14)
                                                                    s14)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a13)
                                                                    s13)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a12)
                                                                    s12)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a11)
                                                                    s11)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a10)
                                                                    s10)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a9)
                                                                    s9)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a8)
                                                                    s8)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a7)
                                                                    s7)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a6)
                                                                    s6)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a5)
                                                                    s5)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a4)
                                                                    s4)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a3)
                                                                    s3)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a2)
                                                                    s2)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a1)
                                                                    s1)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a0)
                                                                    s0)
                                                               else LUns0 w
                                      else LUns0 w)
                                      a)
                                    w))
                            | Inr w -> LUns0 w)
                         | Inr w -> LUns0 w)
                 | None -> LUns0 "TK: input text")
              | VBool _ ->
                (match text_of v with
                 | Some s ->
                   if (&&) (negb (match v with
                                  | VStr _ -> true
                                  | _ -> false))
                        (match o.tk_end with
                         | Some _ -> true
                         | None -> false)
                   then LErr []
                   else let pairmode =
                          match o.tk_end with
                          | Some _ -> true
                          | None -> false
                        in
                        (match tok_text "token" pairmode o.tk_token with
                         | Inl t ->
                           let grp =
                             match o.tk_group with
                             | Some g ->
                               if occurs (str "${") g
                               then Inr "TK: simple language in group"
                               else if all_digits g
                                    then let n0 =
                                           Z.to_nat
                                             (digits_val g
                                               Big_int_Z.zero_big_int)
                                         in
                                         if Nat.ltb 0 n0
                                         then Inl (Some n0)
                                         else Inr
                                                "SE: group must be a positive number"
                                    else Inr
                                           "SE: group must be a positive number"
                             | None -> Inl None
                           in
                           (match grp with
                            | Inl grp0 ->
                              let parts =
                                match o.tk_end with
                                | Some e ->
                                  if o.tk_regex
                                  then Inr "TK: regex with an end token"
                                  else (match tok_text "endToken" true e with
                                        | Inl e' ->
                                          if ceqs t e'
                                          then Inr "!IllegalArgumentException"
                                          else if (||) (occurs t e')
                                                    (occurs e' t)
                                               then Inr
                                                      "TK: start and end tokens that overlap"
                                               else (match grp0 with
                                                     | Some _ ->
                                                       Inr
                                                         "TK: group with start/end pairs"
                                                     | None ->
                                                       (match pairs
                                                                (Stdlib.Int.succ
                                                                (length s)) t
                                                                e' s o.tk_incl with
                                                        | Inl ps ->
                                                          (match ps with
                                                           | [] ->
                                                             Inr
                                                               "TK: no start/end pair in the text"
                                                           | _ :: _ ->
                                                             if existsb
                                                                  (fun p ->
                                                                  (=)
                                                                    (length p)
                                                                    0)
                                                                  ps
                                                             then Inr
                                                                    "TK: an empty part"
                                                             else Inl ps)
                                                        | Inr w -> Inr w))
                                        | Inr w -> Inr w)
                                | None ->
                                  if o.tk_incl
                                  then Inr
                                         "TK: includeTokens without an end token (must be configured [CJt.32])"
                                  else let ps =
                                         if o.tk_regex
                                         then (match parse_re t with
                                               | Some a ->
                                                 Inl
                                                   (split_by (Stdlib.Int.succ
                                                     (length s)) (ra_len a) s
                                                     [])
                                               | None ->
                                                 Inr
                                                   "out of scope: a regex pattern outside the model's small regex language")
                                         else Inl
                                                (split_by (Stdlib.Int.succ
                                                  (length s)) (lit_match t) s
                                                  [])
                                       in
                                       (match ps with
                                        | Inl ps0 ->
                                          if existsb (fun p ->
                                               (=) (length p) 0) ps0
                                          then Inr "TK: an empty part"
                                          else Inl ps0
                                        | Inr w -> Inr w)
                              in
                              (match parts with
                               | Inl ps ->
                                 (match grp0 with
                                  | Some n0 ->
                                    if o.tk_skip
                                    then LUns0
                                           "TK: skipFirst with group (the first part or the first group?)"
                                    else let d =
                                           match o.tk_gdelim with
                                           | Some d ->
                                             if (||)
                                                  ((||) (occurs (bsl :: []) d)
                                                    (occurs (str "${") d))
                                                  (occurs (str "{{") d)
                                             then Inr
                                                    "TK: a backslash, ${ } or {{ }} in groupDelimiter"
                                             else Inl d
                                           | None ->
                                             if o.tk_regex
                                             then Inr
                                                    "TK: group with regex and no groupDelimiter (the pattern as delimiter?)"
                                             else Inl t
                                         in
                                         (match d with
                                          | Inl d0 ->
                                            LV (VList
                                              (map (concat_with d0)
                                                (chunks (Stdlib.Int.succ
                                                  (length ps)) n0 ps)))
                                          | Inr w -> LUns0 w)
                                  | None ->
                                    LV (VList
                                      (if o.tk_skip then tl ps else ps)))
                               | Inr w ->
                                 ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                    (fun _ -> LUns0 w)
                                    (fun a s0 ->
                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                      (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                      if b
                                      then if b0
                                           then LUns0 w
                                           else if b1
                                                then LUns0 w
                                                else if b2
                                                     then LUns0 w
                                                     else if b3
                                                          then LUns0 w
                                                          else if b4
                                                               then if b5
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b6
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a0 s1 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b13
                                                                    then 
                                                                    if b14
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a1 s2 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b15 b16 b17 b18 b19 b20 b21 b22 ->
                                                                    if b15
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b16
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b17
                                                                    then 
                                                                    if b18
                                                                    then 
                                                                    if b19
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b20
                                                                    then 
                                                                    if b21
                                                                    then 
                                                                    if b22
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a2 s3 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b23 b24 b25 b26 b27 b28 b29 b30 ->
                                                                    if b23
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b24
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b25
                                                                    then 
                                                                    if b26
                                                                    then 
                                                                    if b27
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b28
                                                                    then 
                                                                    if b29
                                                                    then 
                                                                    if b30
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a3 s4 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b31 b32 b33 b34 b35 b36 b37 b38 ->
                                                                    if b31
                                                                    then 
                                                                    if b32
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b33
                                                                    then 
                                                                    if b34
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b35
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b36
                                                                    then 
                                                                    if b37
                                                                    then 
                                                                    if b38
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a4 s5 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b39 b40 b41 b42 b43 b44 b45 b46 ->
                                                                    if b39
                                                                    then 
                                                                    if b40
                                                                    then 
                                                                    if b41
                                                                    then 
                                                                    if b42
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b43
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b44
                                                                    then 
                                                                    if b45
                                                                    then 
                                                                    if b46
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a5 s6 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b47 b48 b49 b50 b51 b52 b53 b54 ->
                                                                    if b47
                                                                    then 
                                                                    if b48
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b49
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b50
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b51
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b52
                                                                    then 
                                                                    if b53
                                                                    then 
                                                                    if b54
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a6 s7 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b55 b56 b57 b58 b59 b60 b61 b62 ->
                                                                    if b55
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b56
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b57
                                                                    then 
                                                                    if b58
                                                                    then 
                                                                    if b59
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b60
                                                                    then 
                                                                    if b61
                                                                    then 
                                                                    if b62
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a7 s8 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b63 b64 b65 b66 b67 b68 b69 b70 ->
                                                                    if b63
                                                                    then 
                                                                    if b64
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b65
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b66
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b67
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b68
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b69
                                                                    then 
                                                                    if b70
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a8 s9 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b71 b72 b73 b74 b75 b76 b77 b78 ->
                                                                    if b71
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b72
                                                                    then 
                                                                    if b73
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b74
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b75
                                                                    then 
                                                                    if b76
                                                                    then 
                                                                    if b77
                                                                    then 
                                                                    if b78
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a9 s10 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b79 b80 b81 b82 b83 b84 b85 b86 ->
                                                                    if b79
                                                                    then 
                                                                    if b80
                                                                    then 
                                                                    if b81
                                                                    then 
                                                                    if b82
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b83
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b84
                                                                    then 
                                                                    if b85
                                                                    then 
                                                                    if b86
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a10 s11 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b87 b88 b89 b90 b91 b92 b93 b94 ->
                                                                    if b87
                                                                    then 
                                                                    if b88
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b89
                                                                    then 
                                                                    if b90
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b91
                                                                    then 
                                                                    if b92
                                                                    then 
                                                                    if b93
                                                                    then 
                                                                    if b94
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a11 s12 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b95 b96 b97 b98 b99 b100 b101 b102 ->
                                                                    if b95
                                                                    then 
                                                                    if b96
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b97
                                                                    then 
                                                                    if b98
                                                                    then 
                                                                    if b99
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b100
                                                                    then 
                                                                    if b101
                                                                    then 
                                                                    if b102
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a12 s13 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b103 b104 b105 b106 b107 b108 b109 b110 ->
                                                                    if b103
                                                                    then 
                                                                    if b104
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b105
                                                                    then 
                                                                    if b106
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b107
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b108
                                                                    then 
                                                                    if b109
                                                                    then 
                                                                    if b110
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a13 s14 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b111 b112 b113 b114 b115 b116 b117 b118 ->
                                                                    if b111
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b112
                                                                    then 
                                                                    if b113
                                                                    then 
                                                                    if b114
                                                                    then 
                                                                    if b115
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b116
                                                                    then 
                                                                    if b117
                                                                    then 
                                                                    if b118
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a14 s15 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b119 b120 b121 b122 b123 b124 b125 b126 ->
                                                                    if b119
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b120
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b121
                                                                    then 
                                                                    if b122
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b123
                                                                    then 
                                                                    if b124
                                                                    then 
                                                                    if b125
                                                                    then 
                                                                    if b126
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a15 s16 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b127 b128 b129 b130 b131 b132 b133 b134 ->
                                                                    if b127
                                                                    then 
                                                                    if b128
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b129
                                                                    then 
                                                                    if b130
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b131
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b132
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b133
                                                                    then 
                                                                    if b134
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a16 s17 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b135 b136 b137 b138 b139 b140 b141 b142 ->
                                                                    if b135
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b136
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b137
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b138
                                                                    then 
                                                                    if b139
                                                                    then 
                                                                    if b140
                                                                    then 
                                                                    if b141
                                                                    then 
                                                                    if b142
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a17 s18 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b143 b144 b145 b146 b147 b148 b149 b150 ->
                                                                    if b143
                                                                    then 
                                                                    if b144
                                                                    then 
                                                                    if b145
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b146
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b147
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b148
                                                                    then 
                                                                    if b149
                                                                    then 
                                                                    if b150
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a18 s19 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b151 b152 b153 b154 b155 b156 b157 b158 ->
                                                                    if b151
                                                                    then 
                                                                    if b152
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b153
                                                                    then 
                                                                    if b154
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b155
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b156
                                                                    then 
                                                                    if b157
                                                                    then 
                                                                    if b158
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a19 s20 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b159 b160 b161 b162 b163 b164 b165 b166 ->
                                                                    if b159
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b160
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b161
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b162
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b163
                                                                    then 
                                                                    if b164
                                                                    then 
                                                                    if b165
                                                                    then 
                                                                    if b166
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a20 s21 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b167 b168 b169 b170 b171 b172 b173 b174 ->
                                                                    if b167
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b168
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b169
                                                                    then 
                                                                    if b170
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b171
                                                                    then 
                                                                    if b172
                                                                    then 
                                                                    if b173
                                                                    then 
                                                                    if b174
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a21 s22 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b175 b176 b177 b178 b179 b180 b181 b182 ->
                                                                    if b175
                                                                    then 
                                                                    if b176
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b177
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b178
                                                                    then 
                                                                    if b179
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b180
                                                                    then 
                                                                    if b181
                                                                    then 
                                                                    if b182
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a22 s23 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b183 b184 b185 b186 b187 b188 b189 b190 ->
                                                                    if b183
                                                                    then 
                                                                    if b184
                                                                    then 
                                                                    if b185
                                                                    then 
                                                                    if b186
                                                                    then 
                                                                    if b187
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b188
                                                                    then 
                                                                    if b189
                                                                    then 
                                                                    if b190
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LUns0
                                                                    w)
                                                                    (fun a23 s24 ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b191 b192 b193 b194 b195 b196 b197 b198 ->
                                                                    if b191
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b192
                                                                    then 
                                                                    if b193
                                                                    then 
                                                                    if b194
                                                                    then 
                                                                    if b195
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    if b196
                                                                    then 
                                                                    if b197
                                                                    then 
                                                                    if b198
                                                                    then 
                                                                    LUns0 w
                                                                    else 
                                                                    ((* If this appears, you're using String internals. Please don't *)
 (fun f0 f1 s ->
    let l = String.length s in
    if l = 0 then f0 () else f1 (String.get s 0) (String.sub s 1 (l-1)))

                                                                    (fun _ ->
                                                                    LErr
                                                                    (str
                                                                    "IllegalArgumentException"))
                                                                    (fun _ _ ->
                                                                    LUns0
                                                                    w)
                                                                    s24)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a23)
                                                                    s23)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a22)
                                                                    s22)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a21)
                                                                    s21)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a20)
                                                                    s20)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a19)
                                                                    s19)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a18)
                                                                    s18)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a17)
                                                                    s17)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a16)
                                                                    s16)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a15)
                                                                    s15)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a14)
                                                                    s14)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a13)
                                                                    s13)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a12)
                                                                    s12)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a11)
                                                                    s11)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a10)
                                                                    s10)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a9)
                                                                    s9)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a8)
                                                                    s8)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a7)
                                                                    s7)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a6)
                                                                    s6)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a5)
                                                                    s5)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a4)
                                                                    s4)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a3)
                                                                    s3)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a2)
                                                                    s2)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a1)
                                                                    s1)
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w
                                                                    else 
                                                                    LUns0 w)
                                                                    a0)
                                                                    s0)
                                                               else LUns0 w
                                      else LUns0 w)
                                      a)
                                    w))
                            | Inr w -> LUns0 w)
                         | Inr w -> LUns0 w)
                 | None -> LUns0 "TK: input text")
              | VList _ -> LUns0 "TK: the toString() of a List input")
           | Inr w -> LUns0 w))

type lexp =
| XConstant of chars * chars option * bool
| XHeader of chars * bool
| XProp of chars * bool
| XVar of chars * bool
| XRef of chars * chars option * bool
| XTokenize of tkopts * chars option

(** val eval : lenv -> lexp -> lres **)

let eval x = function
| XConstant (t, r, tr) -> ev_constant x t r tr
| XHeader (n0, tr) -> ev_header x n0 tr
| XProp (n0, tr) -> ev_prop x n0 tr
| XVar (n0, tr) -> ev_var x n0 tr
| XRef (n0, r, tr) -> ev_ref x n0 r tr false
| XTokenize (o, r) -> ev_tokenize x o r

(** val evalp : lenv -> lexp -> lres **)

let evalp x e = match e with
| XRef (n0, r, tr) -> ev_ref x n0 r tr true
| XTokenize (_, _) -> LUns0 "TK: tokenize as a predicate"
| _ -> as_pred (eval x e)
