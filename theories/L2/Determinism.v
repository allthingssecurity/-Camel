(** * Determinism of the route rules.

    For every program [P], mode [real] and clause list [C]: an exchange sent through a list of steps has at most one
    outcome (global state, exchange, trace) under the L2/L3 rules. The rules are the documentation's statements; a
    pair of rules that could both apply with different results would be two documented answers to one question, which
    the oracle would then pick between silently. This theorem says there is no such pair (sequential routes; the
    parallel and timing-dependent EIPs are not in the rules).

    Proof: one mutual induction over the 11 relations; in each case the second derivation is inverted, the
    functional premises (an expression's value, the selected clause, the next item, ...) are equated, and the
    induction hypotheses give equal intermediate results. *)
From Stdlib Require Import ZArith String Ascii List Bool.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L2 Require Import Route.
Import ListNotations.
Open Scope list_scope.

Section Det.
Variable P : list route.
Variable real : bool.
Variable C : list clause.
Variable EHc : ehconf.

Scheme bss_m := Induction for bss Sort Prop
with bs1_m := Induction for bs1 Sort Prop
with bmc_m := Induction for bmc Sort Prop
with bsp_m := Induction for bsp Sort Prop
with bdr_m := Induction for bdr Sort Prop
with bfo_m := Induction for bfo Sort Prop
with blp_m := Induction for blp Sort Prop
with blw_m := Induction for blw Sort Prop
with baft_m := Induction for baft Sort Prop
with bfin_m := Induction for bfin Sort Prop
with bch_m := Induction for bch Sort Prop.

(** Equal outcomes. *)
Definition same3 (g : gstate) (x : exchange) (t : list event) (g' : gstate) (x' : exchange) (t' : list event) : Prop :=
  g = g' /\ x = x' /\ t = t'.

(** Use an induction hypothesis on a second derivation with the same inputs. *)
Ltac use_ih :=
  match goal with
  | IH : forall _ _ _, _ -> same3 _ _ _ _ _ _, H : _ |- _ =>
      let E := fresh "E" in pose proof (IH _ _ _ H) as E; destruct E as (? & ? & ?); subst; clear H
  end.
(** Two values of one function at one argument are equal. *)
Ltac fun_eq :=
  match goal with
  | H1 : ?a = ?b, H2 : ?a = ?c |- _ =>
      lazymatch b with c => clear H2 | _ =>
        rewrite H1 in H2; first [ discriminate H2 | inversion H2; subst; clear H2 | clear H2 ] end
  end.
Ltac step :=
  first [ match goal with H : ?a = ?a |- _ => clear H end
        | match goal with H : dlc_fail _ _ ?x ?e = Some _ |- _ =>
            lazymatch goal with _ : (x_eh x && clause_matches _ _ (set_exn x (Some e))) = true |- _ => fail | _ =>
              pose proof (dlc_fail_matches _ _ _ _ _ H) end end
        | use_ih
        | fun_eq
        | match goal with H : _ \/ _ |- _ => destruct H as [H | H] end
        | match goal with H : _ /\ _ |- _ => destruct H as [? ?] end
        | match goal with H : EHDlc _ _ _ = EHDlc _ _ _ |- _ => inversion H; subst; clear H end
        | match goal with H : ?a = ?c, H' : context [?a] |- _ =>
            lazymatch a with ?f _ => idtac end;
            lazymatch type of H' with a = c => fail | _ => rewrite H in H'; simpl in H' end end ].
Ltac det := repeat step; unfold same3; try discriminate; try congruence; try (split; [reflexivity | split; reflexivity]).

Combined Scheme rules_mut from bss_m, bs1_m, bmc_m, bsp_m, bdr_m, bfo_m, blp_m, blw_m, baft_m, bfin_m, bch_m.

Theorem rules_deterministic :
  (forall g x ss g1 x1 t1, bss P real C EHc g x ss g1 x1 t1 ->
     forall g2 x2 t2, bss P real C EHc g x ss g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x s g1 x1 t1, bs1 P real C EHc g x s g1 x1 t1 ->
     forall g2 x2 t2, bs1 P real C EHc g x s g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x st bs acc g1 x1 t1, bmc P real C EHc g x st bs acc g1 x1 t1 ->
     forall g2 x2 t2, bmc P real C EHc g x st bs acc g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x o body l n acc g1 x1 t1, bsp P real C EHc g x o body l n acc g1 x1 t1 ->
     forall g2 x2 t2, bsp P real C EHc g x o body l n acc g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x e d g1 x1 t1, bdr P real C EHc g x e d g1 x1 t1 ->
     forall g2 x2 t2, bdr P real C EHc g x e d g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x exs k bs g1 x1 t1, bfo P real C EHc g x exs k bs g1 x1 t1 ->
     forall g2 x2 t2, bfo P real C EHc g x exs k bs g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x cp body n orig g1 x1 t1, blp P real C EHc g x cp body n orig g1 x1 t1 ->
     forall g2 x2 t2, blp P real C EHc g x cp body n orig g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x e body g1 x1 t1, blw P real C EHc g x e body g1 x1 t1 ->
     forall g2 x2 t2, blw P real C EHc g x e body g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x cs fin g1 x1 t1, baft P real C EHc g x cs fin g1 x1 t1 ->
     forall g2 x2 t2, baft P real C EHc g x cs fin g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x p fin g1 x1 t1, bfin P real C EHc g x p fin g1 x1 t1 ->
     forall g2 x2 t2, bfin P real C EHc g x p fin g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2) /\
  (forall g x ws o g1 x1 t1, bch P real C EHc g x ws o g1 x1 t1 ->
     forall g2 x2 t2, bch P real C EHc g x ws o g2 x2 t2 -> same3 g1 x1 t1 g2 x2 t2).
Proof.
  apply rules_mut; intros;
    lazymatch goal with H : _ |- _ => inversion H; subst; clear H end; det.
Qed.

(** The form used most: a list of steps (a route body) has one outcome. *)
Corollary steps_deterministic : forall g x ss g1 x1 t1 g2 x2 t2,
  bss P real C EHc g x ss g1 x1 t1 -> bss P real C EHc g x ss g2 x2 t2 -> g1 = g2 /\ x1 = x2 /\ t1 = t2.
Proof. intros. exact (proj1 rules_deterministic _ _ _ _ _ _ H _ _ _ H0). Qed.
End Det.
