(** * A small Camel core, first step.

    The idea (as for Python in "The Full Monty", OOPSLA 2013): most EIPs are combinations of a few basic operations,
    so translate them into a small core language and give rules only for the core. This file starts with four core
    operations and translates three EIPs into them:
<<
      filter(p, steps)                    =  if p then steps else skip
      choice(when p1 a; when p2 b; else c) =  if p1 then a else (if p2 then b else c)
      pipeline(steps)                     =  steps
>>
    Every other step stays a "leaf" of the core, run by the existing L2/L3 rules. The theorem [translation_sound]:
    for every route and every message, whatever the CamelSpec rules say the route does, the translated core program
    does the same (same final exchange, same state, same events). Next: the other direction, and more EIPs
    (recipientList, routingSlip, dynamicRouter, split) as translations instead of rules. *)
From Stdlib Require Import String List.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L2 Require Import Route Determinism.
Import ListNotations.
Open Scope list_scope.

(** The core: skip, a leaf step, sequence, condition. *)
Inductive core : Type :=
| KSkip
| KLeaf (s : step)
| KThen (k1 k2 : core)
| KIf (p : expr) (k1 k2 : core).

(** The translation. *)
Fixpoint tr_s (s : step) : core :=
  let fix tr_l (ss : list step) : core := match ss with [] => KSkip | s1 :: r => KThen (tr_s s1) (tr_l r) end in
  let fix tr_ws (ws : list (expr * list step)) (d : core) : core :=
    match ws with [] => d | (p, ss) :: r => KIf p (tr_l ss) (tr_ws r d) end in
  match s with
  | SFilter p body => KIf p (tr_l body) KSkip
  | SPipeline body => tr_l body
  | SChoice ws o => tr_ws ws (match o with Some ss => tr_l ss | None => KSkip end)
  | _ => KLeaf s
  end.
Fixpoint tr_l (ss : list step) : core := match ss with [] => KSkip | s1 :: r => KThen (tr_s s1) (tr_l r) end.
Fixpoint tr_ws (ws : list (expr * list step)) (d : core) : core :=
  match ws with [] => d | (p, ss) :: r => KIf p (tr_l ss) (tr_ws r d) end.
Definition tr_ch (ws : list (expr * list step)) (o : option (list step)) : core :=
  tr_ws ws (match o with Some ss => tr_l ss | None => KSkip end).
Lemma tr_filter : forall p body, tr_s (SFilter p body) = KIf p (tr_l body) KSkip.
Proof. reflexivity. Qed.
Lemma tr_pipeline : forall body, tr_s (SPipeline body) = tr_l body.
Proof. reflexivity. Qed.
Lemma tr_choice : forall ws o, tr_s (SChoice ws o) = tr_ch ws o.
Proof. intros ws o. unfold tr_ch. induction ws as [|[p ss] r IH]; [reflexivity|]. simpl. f_equal; try exact IH. Qed.
Lemma tr_ch_cons : forall p ss ws o, tr_ch ((p, ss) :: ws) o = KIf p (tr_l ss) (tr_ch ws o).
Proof. reflexivity. Qed.
Lemma tr_ch_some : forall ss, tr_ch [] (Some ss) = tr_l ss.
Proof. reflexivity. Qed.
Lemma tr_ch_none : tr_ch [] None = KSkip.
Proof. reflexivity. Qed.

Section CoreRules.
Variable P : list route.
Variable real : bool.
Variable C : list clause.
Variable EHc : ehconf.

(** The core's rules. A leaf is run by the CamelSpec rules; between two steps the exchange is handed on as in
    L2.pipeline.seq ([surface]), and a halted exchange (failed, stopped, completed) runs nothing more. *)
Inductive crun : gstate -> exchange -> core -> gstate -> exchange -> list event -> Prop :=
| CSkip : forall g x, crun g x KSkip g x []
| CLeaf : forall g x s g' x' t, bs1 P real C EHc g x s g' x' t -> crun g x (KLeaf s) g' x' t
| CThenHalt : forall g x k1 k2, halted x = true -> crun g x (KThen k1 k2) g x []
| CThen : forall g x k1 k2 g1 x1 t1 g2 x2 t2, halted x = false -> crun g x k1 g1 x1 t1 ->
    crun g1 (surface x1) k2 g2 x2 t2 -> crun g x (KThen k1 k2) g2 x2 (t1 ++ t2)
| CIfT : forall g x p k1 k2 g' x' t, eval_pred x p = PB true -> crun g x k1 g' x' t -> crun g x (KIf p k1 k2) g' x' t
| CIfF : forall g x p k1 k2 g' x' t, eval_pred x p = PB false -> crun g x k2 g' x' t -> crun g x (KIf p k1 k2) g' x' t.

(** The translation keeps the meaning: every outcome the CamelSpec rules give a route, its core program gives too. *)
Theorem translation_sound :
  (forall g x ss g1 x1 t1, bss P real C EHc g x ss g1 x1 t1 -> crun g x (tr_l ss) g1 x1 t1) /\
  (forall g x s g1 x1 t1, bs1 P real C EHc g x s g1 x1 t1 -> crun g x (tr_s s) g1 x1 t1) /\
  (forall g x st bs acc g1 x1 t1, bmc P real C EHc g x st bs acc g1 x1 t1 -> True) /\
  (forall g x o body l n acc g1 x1 t1, bsp P real C EHc g x o body l n acc g1 x1 t1 -> True) /\
  (forall g x e d g1 x1 t1, bdr P real C EHc g x e d g1 x1 t1 -> True) /\
  (forall g x exs k bs g1 x1 t1, bfo P real C EHc g x exs k bs g1 x1 t1 -> True) /\
  (forall g x cp body n orig g1 x1 t1, blp P real C EHc g x cp body n orig g1 x1 t1 -> True) /\
  (forall g x e body g1 x1 t1, blw P real C EHc g x e body g1 x1 t1 -> True) /\
  (forall g x cs fin g1 x1 t1, baft P real C EHc g x cs fin g1 x1 t1 -> True) /\
  (forall g x p fin g1 x1 t1, bfin P real C EHc g x p fin g1 x1 t1 -> True) /\
  (forall g x ws o g1 x1 t1, bch P real C EHc g x ws o g1 x1 t1 -> crun g x (tr_ch ws o) g1 x1 t1).
Proof.
  apply rules_mut; intros; try exact I;
    rewrite ?tr_filter, ?tr_pipeline, ?tr_choice, ?tr_ch_cons, ?tr_ch_some, ?tr_ch_none; simpl tr_l.
  (* sequences *)
  all: try (constructor; assumption).
  all: try (eapply CThen; eauto; fail).
  (* the translated EIPs *)
  all: try (eapply CIfT; eauto; fail).
  all: try (eapply CIfF; eauto using CSkip; fail).
  all: try assumption.
  (* every other step is a leaf, run by the CamelSpec rules *)
  all: try (apply CLeaf; econstructor; eauto; fail).
Qed.
End CoreRules.
