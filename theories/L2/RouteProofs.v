(** * Proofs about one concrete route, for every message.

    The route from filter-eip.adoc 255-262:
<<
      from(...).filter(header("type").isEqualTo("gold")).to("mock:gold").end().to("mock:all")
>>
    The theorem below holds for EVERY message (any body, any headers, any properties), every program the route
    runs in, every set of onException clauses and every error handler, in both Doc and Real mode:
    - every message reaches mock:all, exactly once;
    - a message reaches mock:gold exactly when its type header is "gold" (and then before mock:all);
    - the message itself is not changed, and nothing else happens.
    The only hypotheses: the message has not already failed or stopped, and the condition can be decided (for a
    header that is a List, the docs do not say what == does: no rule). *)
From Stdlib Require Import String List.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L2 Require Import Route.
Import ListNotations.
Open Scope list_scope.

Section GoldRoute.
Variable P : list route.
Variable real : bool.
Variable C : list clause.
Variable EHc : ehconf.

Definition gold : chars := str "gold".
Definition all : chars := str "all".
Definition is_gold : expr := hdr_is "type" "gold".

Theorem gold_route_spec : forall g x g' x' t b,
  halted x = false ->
  eval_pred x is_gold = PB b ->
  bss P real C EHc g x gold_route g' x' t ->
  g' = g /\ x' = x /\ t = (if b then [EvMock gold x false] else []) ++ [EvMock all x false].
Proof.
  intros g x g' x' t b Hh Hp H. unfold gold_route in H. unfold is_gold in Hp.
  (* not halted: no exception, so [surface] leaves the exchange alone *)
  assert (Hn : x_exn x = None) by
    (unfold halted in Hh; destruct (x_exn x); [rewrite Bool.orb_true_r in Hh; discriminate | reflexivity]).
  (* the condition's value decides the case; take the derivation apart, step by step: filter, then to mock:all *)
  destruct b; cbv iota;
  repeat match goal with
    | D : bss _ _ _ _ _ _ (_ :: _) _ _ _ |- _ => inversion D; subst; clear D
    | D : bss _ _ _ _ _ _ [] _ _ _ |- _ => inversion D; subst; clear D
    | D : bs1 _ _ _ _ _ _ (SFilter _ _) _ _ _ |- _ => inversion D; subst; clear D
    | D : bs1 _ _ _ _ _ _ (STo (EMock _)) _ _ _ |- _ => inversion D; subst; clear D
    end;
  unfold surface in *; rewrite ?Hn in *; cbv beta iota in *;
  first [ repeat split; reflexivity | congruence ].
Qed.

(** The two facts people care about, read off the theorem. *)
Corollary gold_route_always_reaches_all : forall g x g' x' t b,
  halted x = false -> eval_pred x is_gold = PB b -> bss P real C EHc g x gold_route g' x' t ->
  In (EvMock all x false) t.
Proof.
  intros g x g' x' t b Hh Hp H. destruct (gold_route_spec g x g' x' t b Hh Hp H) as (_ & _ & ->).
  apply in_or_app. right. left. reflexivity.
Qed.
Corollary gold_route_gold_iff : forall g x g' x' t b,
  halted x = false -> eval_pred x is_gold = PB b -> bss P real C EHc g x gold_route g' x' t ->
  (In (EvMock gold x false) t <-> b = true).
Proof.
  intros g x g' x' t b Hh Hp H. destruct (gold_route_spec g x g' x' t b Hh Hp H) as (_ & _ & ->).
  destruct b; simpl.
  - split; intros; [reflexivity | left; reflexivity].
  - split; intro K; [| discriminate]. destruct K as [K|[]]. inversion K.
Qed.
End GoldRoute.
