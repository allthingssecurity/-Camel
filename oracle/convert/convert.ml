
(** val negb : bool -> bool **)

let negb = function
| true -> false
| false -> true

(** val fst : ('a1 * 'a2) -> 'a1 **)

let fst = function
| (x, _) -> x

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

  (** val iter : ('a1 -> 'a1) -> 'a1 -> Big_int_Z.big_int -> 'a1 **)

  let rec iter f x n0 =
    (fun f2p1 f2p f1 p ->
  if Big_int_Z.le_big_int p Big_int_Z.unit_big_int then f1 () else
  let q = Big_int_Z.shift_right_big_int p 1 in
  if Big_int_Z.eq_big_int (Big_int_Z.and_big_int p Big_int_Z.unit_big_int)
       Big_int_Z.unit_big_int
  then f2p1 q else f2p q)
      (fun n' -> f (iter f (iter f x n') n'))
      (fun n' -> iter f (iter f x n') n')
      (fun _ -> f x)
      n0

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

  (** val pow_pos :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let pow_pos z0 =
    Pos.iter (mul z0) Big_int_Z.unit_big_int

  (** val pow :
      Big_int_Z.big_int -> Big_int_Z.big_int -> Big_int_Z.big_int **)

  let pow x y =
    (fun fO fp fn z -> let s = Big_int_Z.sign_big_int z in
  if s = 0 then fO () else if s > 0 then fp z
  else fn (Big_int_Z.minus_big_int z))
      (fun _ -> Big_int_Z.unit_big_int)
      (fun p -> pow_pos x p)
      (fun _ -> Big_int_Z.zero_big_int)
      y

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

(** val existsb : ('a1 -> bool) -> 'a1 list -> bool **)

let rec existsb f = function
| [] -> false
| a :: l0 -> (||) (f a) (existsb f l0)

(** val forallb : ('a1 -> bool) -> 'a1 list -> bool **)

let rec forallb f = function
| [] -> true
| a :: l0 -> (&&) (f a) (forallb f l0)

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

(** val blank : chars -> bool **)

let blank s =
  forallb is_ws s

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

(** val split_dot : chars -> chars * chars option **)

let rec split_dot = function
| [] -> ([], None)
| c :: l' ->
  if ceq c '.'
  then ([], (Some l'))
  else let (a, b) = split_dot l' in ((c :: a), b)

type dec = Big_int_Z.big_int * int

(** val parse_dec : chars -> dec option **)

let parse_dec l = match l with
| [] ->
  let neg = false in
  let sg = fun z0 -> if neg then Z.opp z0 else z0 in
  let (ip, o) = split_dot l in
  (match o with
   | Some fp ->
     if (&&) (all_digits ip) (all_digits fp)
     then Some ((sg (digits_val (app ip fp) Big_int_Z.zero_big_int)),
            (length fp))
     else None
   | None ->
     if all_digits ip
     then Some ((sg (digits_val ip Big_int_Z.zero_big_int)), 0)
     else None)
| a :: r ->
  (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
    (fun b b0 b1 b2 b3 b4 b5 b6 ->
    if b
    then if b0
         then let neg = false in
              let sg = fun z0 -> if neg then Z.opp z0 else z0 in
              let (ip, o) = split_dot l in
              (match o with
               | Some fp ->
                 if (&&) (all_digits ip) (all_digits fp)
                 then Some
                        ((sg (digits_val (app ip fp) Big_int_Z.zero_big_int)),
                        (length fp))
                 else None
               | None ->
                 if all_digits ip
                 then Some ((sg (digits_val ip Big_int_Z.zero_big_int)), 0)
                 else None)
         else if b1
              then if b2
                   then if b3
                        then let neg = false in
                             let sg = fun z0 -> if neg then Z.opp z0 else z0
                             in
                             let (ip, o) = split_dot l in
                             (match o with
                              | Some fp ->
                                if (&&) (all_digits ip) (all_digits fp)
                                then Some
                                       ((sg
                                          (digits_val (app ip fp)
                                            Big_int_Z.zero_big_int)),
                                       (length fp))
                                else None
                              | None ->
                                if all_digits ip
                                then Some
                                       ((sg
                                          (digits_val ip
                                            Big_int_Z.zero_big_int)),
                                       0)
                                else None)
                        else if b4
                             then if b5
                                  then let neg = false in
                                       let sg = fun z0 ->
                                         if neg then Z.opp z0 else z0
                                       in
                                       let (ip, o) = split_dot l in
                                       (match o with
                                        | Some fp ->
                                          if (&&) (all_digits ip)
                                               (all_digits fp)
                                          then Some
                                                 ((sg
                                                    (digits_val (app ip fp)
                                                      Big_int_Z.zero_big_int)),
                                                 (length fp))
                                          else None
                                        | None ->
                                          if all_digits ip
                                          then Some
                                                 ((sg
                                                    (digits_val ip
                                                      Big_int_Z.zero_big_int)),
                                                 0)
                                          else None)
                                  else if b6
                                       then let neg = false in
                                            let sg = fun z0 ->
                                              if neg then Z.opp z0 else z0
                                            in
                                            let (ip, o) = split_dot l in
                                            (match o with
                                             | Some fp ->
                                               if (&&) (all_digits ip)
                                                    (all_digits fp)
                                               then Some
                                                      ((sg
                                                         (digits_val
                                                           (app ip fp)
                                                           Big_int_Z.zero_big_int)),
                                                      (length fp))
                                               else None
                                             | None ->
                                               if all_digits ip
                                               then Some
                                                      ((sg
                                                         (digits_val ip
                                                           Big_int_Z.zero_big_int)),
                                                      0)
                                               else None)
                                       else let neg = true in
                                            let sg = fun z0 ->
                                              if neg then Z.opp z0 else z0
                                            in
                                            let (ip, o) = split_dot r in
                                            (match o with
                                             | Some fp ->
                                               if (&&) (all_digits ip)
                                                    (all_digits fp)
                                               then Some
                                                      ((sg
                                                         (digits_val
                                                           (app ip fp)
                                                           Big_int_Z.zero_big_int)),
                                                      (length fp))
                                               else None
                                             | None ->
                                               if all_digits ip
                                               then Some
                                                      ((sg
                                                         (digits_val ip
                                                           Big_int_Z.zero_big_int)),
                                                      0)
                                               else None)
                             else let neg = false in
                                  let sg = fun z0 ->
                                    if neg then Z.opp z0 else z0
                                  in
                                  let (ip, o) = split_dot l in
                                  (match o with
                                   | Some fp ->
                                     if (&&) (all_digits ip) (all_digits fp)
                                     then Some
                                            ((sg
                                               (digits_val (app ip fp)
                                                 Big_int_Z.zero_big_int)),
                                            (length fp))
                                     else None
                                   | None ->
                                     if all_digits ip
                                     then Some
                                            ((sg
                                               (digits_val ip
                                                 Big_int_Z.zero_big_int)),
                                            0)
                                     else None)
                   else let neg = false in
                        let sg = fun z0 -> if neg then Z.opp z0 else z0 in
                        let (ip, o) = split_dot l in
                        (match o with
                         | Some fp ->
                           if (&&) (all_digits ip) (all_digits fp)
                           then Some
                                  ((sg
                                     (digits_val (app ip fp)
                                       Big_int_Z.zero_big_int)),
                                  (length fp))
                           else None
                         | None ->
                           if all_digits ip
                           then Some
                                  ((sg (digits_val ip Big_int_Z.zero_big_int)),
                                  0)
                           else None)
              else let neg = false in
                   let sg = fun z0 -> if neg then Z.opp z0 else z0 in
                   let (ip, o) = split_dot l in
                   (match o with
                    | Some fp ->
                      if (&&) (all_digits ip) (all_digits fp)
                      then Some
                             ((sg
                                (digits_val (app ip fp)
                                  Big_int_Z.zero_big_int)),
                             (length fp))
                      else None
                    | None ->
                      if all_digits ip
                      then Some ((sg (digits_val ip Big_int_Z.zero_big_int)),
                             0)
                      else None)
    else let neg = false in
         let sg = fun z0 -> if neg then Z.opp z0 else z0 in
         let (ip, o) = split_dot l in
         (match o with
          | Some fp ->
            if (&&) (all_digits ip) (all_digits fp)
            then Some ((sg (digits_val (app ip fp) Big_int_Z.zero_big_int)),
                   (length fp))
            else None
          | None ->
            if all_digits ip
            then Some ((sg (digits_val ip Big_int_Z.zero_big_int)), 0)
            else None))
    a

type val0 =
| VNull
| VStr of chars
| VInt of Big_int_Z.big_int
| VLong of Big_int_Z.big_int
| VDbl of Big_int_Z.big_int
| VBool of bool
| VList of chars list

(** val btext : bool -> chars **)

let btext = function
| true -> str "true"
| false -> str "false"

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

(** val all_jtypes : jtype list **)

let all_jtypes =
  TString :: (TInteger :: (TLong :: (TDouble :: (TBoolean :: (TPInt :: (TPLong :: (TPDouble :: (TPBoolean :: (TNumber :: (TBigDecimal :: (TList :: (TObject :: []))))))))))))

(** val jname : jtype -> string **)

let jname = function
| TString -> "java.lang.String"
| TInteger -> "java.lang.Integer"
| TLong -> "java.lang.Long"
| TDouble -> "java.lang.Double"
| TBoolean -> "java.lang.Boolean"
| TPInt -> "int"
| TPLong -> "long"
| TPDouble -> "double"
| TPBoolean -> "boolean"
| TNumber -> "java.lang.Number"
| TBigDecimal -> "java.math.BigDecimal"
| TList -> "java.util.List"
| TObject -> "java.lang.Object"

(** val is_prim : jtype -> bool **)

let is_prim = function
| TPInt -> true
| TPLong -> true
| TPDouble -> true
| TPBoolean -> true
| _ -> false

type api =
| AConvert
| AMandatory
| ATry
| AGetBody
| AMandatoryBody
| AGetHeader
| AGetProperty

(** val all_apis : api list **)

let all_apis =
  AConvert :: (AMandatory :: (ATry :: (AGetBody :: (AMandatoryBody :: (AGetHeader :: (AGetProperty :: []))))))

(** val aname : api -> string **)

let aname = function
| AConvert -> "convertTo"
| AMandatory -> "mandatoryConvertTo"
| ATry -> "tryConvertTo"
| AGetBody -> "getBody"
| AMandatoryBody -> "getMandatoryBody"
| AGetHeader -> "getHeader"
| AGetProperty -> "getProperty"

(** val tCE : string **)

let tCE =
  "org.apache.camel.TypeConversionException"

(** val nTCAE : string **)

let nTCAE =
  "org.apache.camel.NoTypeConversionAvailableException"

(** val iPE : string **)

let iPE =
  "org.apache.camel.InvalidPayloadException"

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

(** val in_int : Big_int_Z.big_int -> bool **)

let in_int z0 =
  (&&)
    (Z.leb (Big_int_Z.minus_big_int
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      Big_int_Z.unit_big_int)))))))))))))))))))))))))))))))) z0)
    (Z.leb z0
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      Big_int_Z.unit_big_int)))))))))))))))))))))))))))))))

(** val in_long : Big_int_Z.big_int -> bool **)

let in_long z0 =
  (&&)
    (Z.leb (Big_int_Z.minus_big_int
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.shift_left_big_int p 1)
      Big_int_Z.unit_big_int))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
      z0)
    (Z.leb z0
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      Big_int_Z.unit_big_int)))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

(** val in_dbl_exact : Big_int_Z.big_int -> bool **)

let in_dbl_exact z0 =
  Z.leb (Z.abs z0) ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    ((fun p -> Big_int_Z.shift_left_big_int p 1)
    Big_int_Z.unit_big_int)))))))))))))))))))))))))))))))))))))))))))))))))))))

(** val canon_int : chars -> Big_int_Z.big_int option **)

let canon_int s =
  match parse_dec s with
  | Some d ->
    let (z0, n0) = d in
    ((fun fO fS n -> if n=0 then fO () else fS (n-1))
       (fun _ -> if ceqs (ztext z0) s then Some z0 else None)
       (fun _ -> None)
       n0)
  | None -> None

(** val plain_dec : chars -> dec option **)

let plain_dec s =
  let b =
    match s with
    | [] -> s
    | a :: r ->
      (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
        (fun b b0 b1 b2 b3 b4 b5 b6 ->
        if b
        then if b0
             then s
             else if b1
                  then if b2
                       then if b3
                            then s
                            else if b4
                                 then if b5 then s else if b6 then s else r
                                 else s
                       else s
                  else s
        else s)
        a
  in
  let neg =
    match s with
    | [] -> false
    | a :: _ ->
      (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
        (fun b0 b1 b2 b3 b4 b5 b6 b7 ->
        if b0
        then if b1
             then false
             else if b2
                  then if b3
                       then if b4
                            then false
                            else if b5
                                 then if b6
                                      then false
                                      else if b7 then false else true
                                 else false
                       else false
                  else false
        else false)
        a
  in
  let ip = fst (split_dot b) in
  let ip_ok =
    match ip with
    | [] -> true
    | a :: l ->
      (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
        (fun b0 b1 b2 b3 b4 b5 b6 b7 ->
        if b0
        then true
        else if b1
             then true
             else if b2
                  then true
                  else if b3
                       then true
                       else if b4
                            then if b5
                                 then if b6
                                      then true
                                      else if b7
                                           then true
                                           else (match l with
                                                 | [] -> true
                                                 | _ :: _ -> false)
                                 else true
                            else true)
        a
  in
  (match parse_dec s with
   | Some d ->
     let (m, k) = d in
     if (&&) ip_ok (negb ((&&) neg (Z.eqb m Big_int_Z.zero_big_int)))
     then Some (m, k)
     else None
   | None -> None)

(** val dec_quarters : dec -> Big_int_Z.big_int option **)

let dec_quarters = function
| (m, k) ->
  let p =
    Z.pow ((fun p -> Big_int_Z.shift_left_big_int p 1)
      ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
      ((fun p -> Big_int_Z.shift_left_big_int p 1) Big_int_Z.unit_big_int)))
      (Z.of_nat k)
  in
  if Z.eqb
       (Z.modulo
         (Z.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int)) m)
         p)
       Big_int_Z.zero_big_int
  then Some
         (Z.div
           (Z.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
             ((fun p -> Big_int_Z.shift_left_big_int p 1)
             Big_int_Z.unit_big_int)) m)
           p)
  else None

(** val exp_int : chars -> Big_int_Z.big_int option **)

let exp_int s =
  match find ('e' :: []) s with
  | Some i ->
    let mant = firstn i s in
    let ex = skipn (Stdlib.Int.succ i) s in
    (match canon_int mant with
     | Some m ->
       (match canon_int ex with
        | Some e ->
          if (&&)
               ((&&) (Z.leb Big_int_Z.zero_big_int m)
                 (Z.leb Big_int_Z.zero_big_int e))
               (Z.leb e ((fun p -> Big_int_Z.shift_left_big_int p 1)
                 ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
                 ((fun p -> Big_int_Z.shift_left_big_int p 1)
                 ((fun p -> Big_int_Z.shift_left_big_int p 1)
                 Big_int_Z.unit_big_int)))))
          then Some
                 (Z.mul m
                   (Z.pow ((fun p -> Big_int_Z.shift_left_big_int p 1)
                     ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
                     ((fun p -> Big_int_Z.shift_left_big_int p 1)
                     Big_int_Z.unit_big_int))) e))
          else None
        | None -> None)
     | None -> None)
  | None -> None

(** val wordy : chars -> bool **)

let wordy s = match s with
| [] -> false
| _ :: _ ->
  (&&) (forallb is_letter s)
    (negb
      ((||) (ceqs (lower s) (str "nan")) (ceqs (lower s) (str "infinity"))))

(** val text_kind : chars -> string **)

let text_kind s =
  if blank s
  then "empty or blank text"
  else if existsb is_ws s
       then "text with white space"
       else (match s with
             | [] ->
               if existsb (fun c -> (||) (ceq c 'x') (ceq c 'X')) s
               then "hex-like text"
               else if (&&)
                         (existsb (fun c -> (||) (ceq c 'e') (ceq c 'E')) s)
                         (existsb is_digit s)
                    then "exponent text"
                    else if (&&) (existsb (fun c -> ceq c '.') s)
                              (existsb is_digit s)
                         then "decimal text"
                         else if all_digits
                                   (match s with
                                    | [] -> s
                                    | a :: r ->
                                      (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                        (fun b b0 b1 b2 b3 b4 b5 b6 ->
                                        if b
                                        then if b0
                                             then s
                                             else if b1
                                                  then if b2
                                                       then if b3
                                                            then s
                                                            else if b4
                                                                 then 
                                                                   if b5
                                                                   then s
                                                                   else 
                                                                    if b6
                                                                    then s
                                                                    else r
                                                                 else s
                                                       else s
                                                  else s
                                        else s)
                                        a)
                              then "integer text with leading zeros or -0"
                              else "other text"
             | a :: _ ->
               (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                 (fun b b0 b1 b2 b3 b4 b5 b6 ->
                 if b
                 then if b0
                      then if b1
                           then if existsb (fun c ->
                                     (||) (ceq c 'x') (ceq c 'X')) s
                                then "hex-like text"
                                else if (&&)
                                          (existsb (fun c ->
                                            (||) (ceq c 'e') (ceq c 'E')) s)
                                          (existsb is_digit s)
                                     then "exponent text"
                                     else if (&&)
                                               (existsb (fun c -> ceq c '.')
                                                 s)
                                               (existsb is_digit s)
                                          then "decimal text"
                                          else if all_digits
                                                    (match s with
                                                     | [] -> s
                                                     | a0 :: r ->
                                                       (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                         (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                         if b7
                                                         then if b8
                                                              then s
                                                              else if b9
                                                                   then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                   else s
                                                         else s)
                                                         a0)
                                               then "integer text with leading zeros or -0"
                                               else "other text"
                           else if b2
                                then if b3
                                     then if existsb (fun c ->
                                               (||) (ceq c 'x') (ceq c 'X')) s
                                          then "hex-like text"
                                          else if (&&)
                                                    (existsb (fun c ->
                                                      (||) (ceq c 'e')
                                                        (ceq c 'E'))
                                                      s)
                                                    (existsb is_digit s)
                                               then "exponent text"
                                               else if (&&)
                                                         (existsb (fun c ->
                                                           ceq c '.') s)
                                                         (existsb is_digit s)
                                                    then "decimal text"
                                                    else if all_digits
                                                              (match s with
                                                               | [] -> s
                                                               | a0 :: r ->
                                                                 (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                   (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                   if b7
                                                                   then 
                                                                    if b8
                                                                    then s
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                    else s
                                                                   else s)
                                                                   a0)
                                                         then "integer text with leading zeros or -0"
                                                         else "other text"
                                     else if b4
                                          then if b5
                                               then if existsb (fun c ->
                                                         (||) (ceq c 'x')
                                                           (ceq c 'X'))
                                                         s
                                                    then "hex-like text"
                                                    else if (&&)
                                                              (existsb
                                                                (fun c ->
                                                                (||)
                                                                  (ceq c 'e')
                                                                  (ceq c 'E'))
                                                                s)
                                                              (existsb
                                                                is_digit s)
                                                         then "exponent text"
                                                         else if (&&)
                                                                   (existsb
                                                                    (fun c ->
                                                                    ceq c '.')
                                                                    s)
                                                                   (existsb
                                                                    is_digit
                                                                    s)
                                                              then "decimal text"
                                                              else if 
                                                                    all_digits
                                                                    (match s with
                                                                    | [] -> s
                                                                    | a0 :: r ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then s
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                    else s
                                                                    else s)
                                                                    a0)
                                                                   then 
                                                                    "integer text with leading zeros or -0"
                                                                   else 
                                                                    "other text"
                                               else if b6
                                                    then if existsb (fun c ->
                                                              (||) (ceq c 'x')
                                                                (ceq c 'X'))
                                                              s
                                                         then "hex-like text"
                                                         else if (&&)
                                                                   (existsb
                                                                    (fun c ->
                                                                    (||)
                                                                    (ceq c
                                                                    'e')
                                                                    (ceq c
                                                                    'E')) s)
                                                                   (existsb
                                                                    is_digit
                                                                    s)
                                                              then "exponent text"
                                                              else if 
                                                                    (&&)
                                                                    (existsb
                                                                    (fun c ->
                                                                    ceq c '.')
                                                                    s)
                                                                    (existsb
                                                                    is_digit
                                                                    s)
                                                                   then 
                                                                    "decimal text"
                                                                   else 
                                                                    if 
                                                                    all_digits
                                                                    (match s with
                                                                    | [] -> s
                                                                    | a0 :: r ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then s
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                    else s
                                                                    else s)
                                                                    a0)
                                                                    then 
                                                                    "integer text with leading zeros or -0"
                                                                    else 
                                                                    "other text"
                                                    else "text with a plus sign"
                                          else if existsb (fun c ->
                                                    (||) (ceq c 'x')
                                                      (ceq c 'X'))
                                                    s
                                               then "hex-like text"
                                               else if (&&)
                                                         (existsb (fun c ->
                                                           (||) (ceq c 'e')
                                                             (ceq c 'E'))
                                                           s)
                                                         (existsb is_digit s)
                                                    then "exponent text"
                                                    else if (&&)
                                                              (existsb
                                                                (fun c ->
                                                                ceq c '.') s)
                                                              (existsb
                                                                is_digit s)
                                                         then "decimal text"
                                                         else if all_digits
                                                                   (match s with
                                                                    | [] -> s
                                                                    | a0 :: r ->
                                                                    (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                                    if b7
                                                                    then 
                                                                    if b8
                                                                    then s
                                                                    else 
                                                                    if b9
                                                                    then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                    else s
                                                                    else s)
                                                                    a0)
                                                              then "integer text with leading zeros or -0"
                                                              else "other text"
                                else if existsb (fun c ->
                                          (||) (ceq c 'x') (ceq c 'X')) s
                                     then "hex-like text"
                                     else if (&&)
                                               (existsb (fun c ->
                                                 (||) (ceq c 'e') (ceq c 'E'))
                                                 s)
                                               (existsb is_digit s)
                                          then "exponent text"
                                          else if (&&)
                                                    (existsb (fun c ->
                                                      ceq c '.') s)
                                                    (existsb is_digit s)
                                               then "decimal text"
                                               else if all_digits
                                                         (match s with
                                                          | [] -> s
                                                          | a0 :: r ->
                                                            (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                              (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                              if b7
                                                              then if b8
                                                                   then s
                                                                   else 
                                                                    if b9
                                                                    then 
                                                                    if b10
                                                                    then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                    else s
                                                                    else s
                                                              else s)
                                                              a0)
                                                    then "integer text with leading zeros or -0"
                                                    else "other text"
                      else if existsb (fun c -> (||) (ceq c 'x') (ceq c 'X'))
                                s
                           then "hex-like text"
                           else if (&&)
                                     (existsb (fun c ->
                                       (||) (ceq c 'e') (ceq c 'E')) s)
                                     (existsb is_digit s)
                                then "exponent text"
                                else if (&&) (existsb (fun c -> ceq c '.') s)
                                          (existsb is_digit s)
                                     then "decimal text"
                                     else if all_digits
                                               (match s with
                                                | [] -> s
                                                | a0 :: r ->
                                                  (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                                    (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                                    if b7
                                                    then if b8
                                                         then s
                                                         else if b9
                                                              then if b10
                                                                   then 
                                                                    if b11
                                                                    then s
                                                                    else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                                   else s
                                                              else s
                                                    else s)
                                                    a0)
                                          then "integer text with leading zeros or -0"
                                          else "other text"
                 else if existsb (fun c -> (||) (ceq c 'x') (ceq c 'X')) s
                      then "hex-like text"
                      else if (&&)
                                (existsb (fun c ->
                                  (||) (ceq c 'e') (ceq c 'E')) s)
                                (existsb is_digit s)
                           then "exponent text"
                           else if (&&) (existsb (fun c -> ceq c '.') s)
                                     (existsb is_digit s)
                                then "decimal text"
                                else if all_digits
                                          (match s with
                                           | [] -> s
                                           | a0 :: r ->
                                             (* If this appears, you're using Ascii internals. Please don't *)
 (fun f c ->
  let n = Char.code c in
  let h i = (n land (1 lsl i)) <> 0 in
  f (h 0) (h 1) (h 2) (h 3) (h 4) (h 5) (h 6) (h 7))
                                               (fun b7 b8 b9 b10 b11 b12 b13 b14 ->
                                               if b7
                                               then if b8
                                                    then s
                                                    else if b9
                                                         then if b10
                                                              then if b11
                                                                   then s
                                                                   else 
                                                                    if b12
                                                                    then 
                                                                    if b13
                                                                    then s
                                                                    else 
                                                                    if b14
                                                                    then s
                                                                    else r
                                                                    else s
                                                              else s
                                                         else s
                                               else s)
                                               a0)
                                     then "integer text with leading zeros or -0"
                                     else "other text")
                 a)

type conv =
| KV of val0
| KDec of dec
| KNull
| KCannot of string
| KUns of string

(** val prim_zero : jtype -> val0 **)

let prim_zero = function
| TPInt -> VInt Big_int_Z.zero_big_int
| TPLong -> VLong Big_int_Z.zero_big_int
| TPDouble -> VDbl Big_int_Z.zero_big_int
| _ -> VBool false

(** val conv_null : jtype -> conv **)

let conv_null t =
  if is_prim t then KV (prim_zero t) else KNull

(** val conv_string : val0 -> conv **)

let conv_string = function
| VNull -> KNull
| VStr s -> KV (VStr s)
| VInt z0 -> KV (VStr (ztext z0))
| VLong z0 -> KV (VStr (ztext z0))
| VDbl _ -> KUns "TC: String from a Double (its text is not documented)"
| VBool b -> KV (VStr (btext b))
| VList _ -> KUns "TC: String from a List (its text is not documented)"

(** val conv_integral :
    string -> (Big_int_Z.big_int -> val0) -> (Big_int_Z.big_int -> bool) ->
    val0 -> conv **)

let conv_integral nm mk lim = function
| VNull -> KNull
| VStr s ->
  (match canon_int s with
   | Some z0 ->
     if lim z0
     then KV (mk z0)
     else KUns ((^) "TC: " ((^) nm " from integer text out of its range"))
   | None ->
     if wordy s
     then KCannot "a word is not a number"
     else KUns ((^) "TC: " ((^) nm ((^) " from " (text_kind s)))))
| VInt z0 ->
  if lim z0
  then KV (mk z0)
  else KUns ((^) "TC: " ((^) nm " from a number out of its range"))
| VLong z0 ->
  if lim z0
  then KV (mk z0)
  else KUns ((^) "TC: " ((^) nm " from a number out of its range"))
| VDbl q ->
  if (&&)
       (Z.eqb
         (Z.modulo q ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int)))
         Big_int_Z.zero_big_int)
       (lim
         (Z.div q ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int))))
  then KV
         (mk
           (Z.div q ((fun p -> Big_int_Z.shift_left_big_int p 1)
             ((fun p -> Big_int_Z.shift_left_big_int p 1)
             Big_int_Z.unit_big_int))))
  else KUns
         ((^) "TC: "
           ((^) nm " from a Double with a fraction or out of range"))
| VBool _ -> KUns ((^) "TC: " ((^) nm " from a Boolean"))
| VList _ -> KUns ((^) "TC: " ((^) nm " from a List"))

(** val conv_double : val0 -> conv **)

let conv_double = function
| VNull -> KNull
| VStr s ->
  (match plain_dec s with
   | Some d ->
     (match dec_quarters d with
      | Some q ->
        if in_dbl_exact q
        then KV (VDbl q)
        else KUns
               "TC: Double from a decimal text that a Double does not hold exactly"
      | None ->
        KUns
          "MODEL: Double from a decimal text that is not a whole number of quarters")
   | None ->
     if wordy s
     then KCannot "a word is not a number"
     else KUns ((^) "TC: Double from " (text_kind s)))
| VInt z0 ->
  if in_dbl_exact z0
  then KV (VDbl
         (Z.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int)) z0))
  else KUns "TC: Double from a long beyond 2^53"
| VLong z0 ->
  if in_dbl_exact z0
  then KV (VDbl
         (Z.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int)) z0))
  else KUns "TC: Double from a long beyond 2^53"
| VDbl q -> KV (VDbl q)
| VBool _ -> KUns "TC: Double from a Boolean"
| VList _ -> KUns "TC: Double from a List"

(** val conv_bool : val0 -> conv **)

let conv_bool = function
| VNull -> KNull
| VStr s ->
  if ceqs s (str "true")
  then KV (VBool true)
  else if ceqs s (str "false")
       then KV (VBool false)
       else KUns "TC: Boolean from text other than true/false"
| VBool b -> KV (VBool b)
| VList _ -> KUns "TC: Boolean from a List"
| _ -> KUns "TC: Boolean from a number"

(** val number_int_text : Big_int_Z.big_int -> conv **)

let number_int_text z0 =
  KV (VInt z0)

(** val number_exp_text : Big_int_Z.big_int -> conv **)

let number_exp_text z0 =
  if in_dbl_exact z0
  then KV (VDbl
         (Z.mul ((fun p -> Big_int_Z.shift_left_big_int p 1)
           ((fun p -> Big_int_Z.shift_left_big_int p 1)
           Big_int_Z.unit_big_int)) z0))
  else KUns "UG423: Number from exponent text beyond 2^53"

(** val number_other_text : chars -> conv **)

let number_other_text s =
  match canon_int s with
  | Some z0 ->
    if in_long z0
    then KV (VLong z0)
    else KUns "UG423: Number from integer text beyond the Long range"
  | None ->
    (match plain_dec s with
     | Some d ->
       (match dec_quarters d with
        | Some q ->
          if in_dbl_exact q
          then KV (VDbl q)
          else KUns
                 "UG423: Number from a decimal text that a Double does not hold exactly"
        | None ->
          KUns
            "MODEL: Number from a decimal text that is not a whole number of quarters")
     | None -> KUns ((^) "UG423: Number from " (text_kind s)))

(** val conv_number : val0 -> conv **)

let conv_number = function
| VNull -> KNull
| VStr s ->
  (match canon_int s with
   | Some z0 -> if in_int z0 then number_int_text z0 else number_other_text s
   | None ->
     (match exp_int s with
      | Some z0 -> number_exp_text z0
      | None ->
        if wordy s
        then KCannot "a word is not a number"
        else number_other_text s))
| VBool _ -> KUns "TC: Number from a Boolean"
| VList _ -> KUns "TC: Number from a List"
| x -> KV x

(** val conv_bigdec : val0 -> conv **)

let conv_bigdec = function
| VNull -> KNull
| VStr s ->
  (match plain_dec s with
   | Some d -> KDec d
   | None ->
     if wordy s
     then KCannot "a word is not a number"
     else KUns ((^) "UG423: BigDecimal from " (text_kind s)))
| VInt z0 -> KDec (z0, 0)
| VLong z0 -> KDec (z0, 0)
| VDbl q ->
  KDec
    ((Z.mul q
       ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
       ((fun p -> Big_int_Z.shift_left_big_int p 1)
       ((fun p -> Big_int_Z.shift_left_big_int p 1)
       ((fun p -> Big_int_Z.succ_big_int (Big_int_Z.shift_left_big_int p 1))
       Big_int_Z.unit_big_int))))),
    (Stdlib.Int.succ (Stdlib.Int.succ 0)))
| VBool _ -> KUns "UG423: BigDecimal from a Boolean"
| VList _ -> KUns "UG423: BigDecimal from a List"

(** val conv_list : val0 -> conv **)

let conv_list = function
| VNull -> KNull
| VList l -> KV (VList l)
| _ -> KUns "TC: List from a value that is not a List"

(** val conv_of : val0 -> jtype -> conv **)

let conv_of v t =
  match v with
  | VNull -> conv_null t
  | _ ->
    (match t with
     | TString -> conv_string v
     | TInteger -> conv_integral "Integer" (fun x -> VInt x) in_int v
     | TLong -> conv_integral "Long" (fun x -> VLong x) in_long v
     | TDouble -> conv_double v
     | TPInt -> conv_integral "Integer" (fun x -> VInt x) in_int v
     | TPLong -> conv_integral "Long" (fun x -> VLong x) in_long v
     | TPDouble -> conv_double v
     | TNumber -> conv_number v
     | TBigDecimal -> conv_bigdec v
     | TList -> conv_list v
     | TObject -> KV v
     | _ -> conv_bool v)

(** val run_convert : conv -> cres **)

let run_convert = function
| KV v -> CV v
| KDec d -> CDec d
| KNull -> CNull
| KCannot _ ->
  COneOf ((ONull :: ((OExc tCE) :: [])),
    "TCJ: convertTo of a value that cannot be converted: null or TypeConversionException")
| KUns w -> COneOf ((OAnyVal :: (ONull :: ((OExc tCE) :: []))), w)

(** val run_mandatory : conv -> cres **)

let run_mandatory = function
| KV v -> CV v
| KDec d -> CDec d
| KNull ->
  COneOf ((OAnyVal :: ((OExc tCE) :: ((OExc nTCAE) :: []))),
    "TCJ: mandatoryConvertTo of null: never null, outcome not documented")
| KCannot _ ->
  COneOf (((OExc tCE) :: ((OExc nTCAE) :: [])),
    "TCJ: mandatoryConvertTo of a value that cannot be converted: which exception")
| KUns w -> COneOf ((OAnyVal :: ((OExc tCE) :: ((OExc nTCAE) :: []))), w)

(** val run_try : conv -> cres **)

let run_try = function
| KV v -> CV v
| KDec d -> CDec d
| KUns w -> COneOf ((OAnyVal :: (ONull :: [])), w)
| _ -> CNull

(** val run_getbody : val0 -> jtype -> conv -> cres **)

let run_getbody v t k =
  match v with
  | VNull ->
    if is_prim t
    then CUns
           "MSGJ: getBody of a null body as a primitive: null (MSGJ.296) or zero (UG424.2458)"
    else CNull
  | _ ->
    (match k with
     | KCannot _ ->
       COneOf ((ONull :: ((OExc tCE) :: [])),
         "MSGJ: getBody of a body that cannot be converted: null or TypeConversionException")
     | _ -> run_convert k)

(** val run_mandbody : val0 -> conv -> cres **)

let run_mandbody v k =
  match v with
  | VNull -> CFail iPE
  | _ ->
    (match k with
     | KV v' -> CV v'
     | KDec d -> CDec d
     | KUns w -> COneOf ((OAnyVal :: ((OExc iPE) :: [])), w)
     | _ -> CFail iPE)

(** val run_getheader : val0 -> conv -> cres **)

let run_getheader v k =
  match v with
  | VNull -> CNull
  | _ ->
    (match k with
     | KV v' -> CV v'
     | KDec d -> CDec d
     | KNull -> CNull
     | KCannot _ ->
       COneOf ((ONull :: ((OExc tCE) :: [])),
         "MSGJ: getHeader of a value that cannot be converted: null or TypeConversionException")
     | KUns w -> COneOf ((OAnyVal :: (ONull :: ((OExc tCE) :: []))), w))

(** val run_getprop : val0 -> conv -> cres **)

let run_getprop v k =
  match v with
  | VNull -> CNull
  | _ ->
    (match k with
     | KV v' -> CV v'
     | KDec d -> CDec d
     | KNull -> CNull
     | KCannot _ ->
       COneOf ((ONull :: ((OExc tCE) :: [])),
         "EXJ: getProperty of a value whose converter fails: null or TypeConversionException")
     | KUns w -> COneOf ((OAnyVal :: (ONull :: ((OExc tCE) :: []))), w))

(** val absent_as : jtype -> cres -> cres **)

let absent_as t r =
  match t with
  | TPBoolean -> CV (VBool false)
  | _ -> r

(** val run : api -> val0 -> jtype -> cres **)

let run a v t =
  let k = conv_of v t in
  (match a with
   | AConvert -> run_convert k
   | AMandatory -> run_mandatory k
   | ATry -> run_try k
   | AGetBody -> run_getbody v t k
   | AMandatoryBody -> run_mandbody v k
   | AGetHeader ->
     (match v with
      | VNull -> absent_as t CNull
      | _ -> run_getheader v k)
   | AGetProperty ->
     (match v with
      | VNull -> absent_as t CNull
      | _ -> run_getprop v k))
