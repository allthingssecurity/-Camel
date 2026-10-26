(** * Properties of the route rules (KICKOFF step 4, Track C).

    Theorems about the readable rules of L2/Route.v (the relations bss/bs1/... and the pure parts they use), for every
    program, clause list and exchange. Each states its hypotheses; the ones with hypotheses have a non-vacuity example
    (CONVENTIONS practice 4). By [run_sound] they also hold for every result of the extracted oracle. *)
From Stdlib Require Import ZArith String Ascii List Bool Lia.
From CamelSpec.Common Require Import Text.
From CamelSpec.L0 Require Import Value Exchange.
From CamelSpec.L2 Require Import Route.
Import ListNotations.
Open Scope list_scope.

Section Props.
Variable P : list route.
Variable real : bool.
Variable C : list clause.

(** ** 1. A halted exchange (failed, stopped, or handled) makes no progress *)
Theorem halted_no_progress : forall g x ss g' x' t,
  bss P real C g x ss g' x' t -> halted x = true -> g' = g /\ x' = x /\ t = [].
Proof.
  intros g x ss g' x' t H Hh. inversion H; subst; auto.
  rewrite Hh in H0. discriminate.
Qed.

(** ** 2. The pipeline law: [ss1 ++ ss2] runs [ss1], then [ss2] on its outcome, and the traces add up
    (pipeline-eip.adoc 131-132: "the output from the previous step is input to the next"). *)
Theorem pipeline_app_split : forall ss1 ss2 g x g'' x'' t,
  bss P real C g x (ss1 ++ ss2) g'' x'' t ->
  exists g' x' t1 t2, bss P real C g x ss1 g' x' t1 /\ bss P real C g' x' ss2 g'' x'' t2 /\ t = t1 ++ t2.
Proof.
  induction ss1 as [|s ss1 IH]; intros ss2 g x g'' x'' t H; simpl in H.
  - exists g, x, [], t. split; [constructor|]. split; auto.
  - inversion H; subst.
    + (* halted: nothing runs, and nothing runs after either *)
      exists g'', x'', [], []. split; [apply BHalt; assumption|]. split; [|reflexivity].
      destruct ss2 as [|s2 ss2']; [constructor | apply BHalt; assumption].
    + destruct (IH ss2 _ _ _ _ _ ltac:(eassumption)) as [g' [x' [u1 [u2 [A [B E]]]]]].
      exists g', x', (t1 ++ u1), u2. split; [eapply BCons; eauto|]. split; [exact B|].
      subst. now rewrite app_assoc.
Qed.

Theorem pipeline_app_join : forall ss1 ss2 g x g' x' t1 g'' x'' t2,
  bss P real C g x ss1 g' x' t1 -> bss P real C g' x' ss2 g'' x'' t2 ->
  bss P real C g x (ss1 ++ ss2) g'' x'' (t1 ++ t2).
Proof.
  induction ss1 as [|s ss1 IH]; intros ss2 g x g' x' t1 g'' x'' t2 H1 H2; simpl.
  - inversion H1; subst. exact H2.
  - inversion H1; subst.
    + (* ss1 halted at the start: so does ss2, nothing changes *)
      match goal with Hh : halted _ = true |- _ =>
        destruct (halted_no_progress _ _ _ _ _ _ H2 Hh) as [-> [-> ->]]; simpl; apply BHalt; exact Hh end.
    + rewrite <- app_assoc. eapply BCons; eauto.
Qed.

(** ** 3. A pipeline block is transparent (pipeline-eip.adoc 138) *)
Theorem pipeline_block : forall g x b g' x' t,
  bs1 P real C g x (SPipeline b) g' x' t <-> bss P real C g x b g' x' t.
Proof.
  split; intro H; [inversion H; subst; assumption | now apply BPipeline].
Qed.

(** ** 4. An idempotent duplicate never reaches the block (idempotentConsumer-eip.adoc 62-65) *)
Theorem idempotent_duplicate_skipped : forall g x id e eg body g' x' t v k,
  eval_expr x e = EV v -> text_of v = Some k -> is_closed g id k = true ->
  bs1 P real C g x (SIdem id e true eg body) g' x' t -> g' = g /\ x' = x /\ t = [].
Proof.
  intros g x id e eg body g' x' t v k Ev Tk Cl H. inversion H; subst; auto.
  (* BIdemNew needs the key not closed: the same key, so a contradiction *)
  match goal with E1 : eval_expr x e = EV ?v1, T1 : text_of ?v1 = Some ?k1, C1 : is_closed g id ?k1 = false |- _ =>
    rewrite Ev in E1; inversion E1; subst; rewrite Tk in T1; inversion T1; subst; rewrite Cl in C1; discriminate end.
Qed.

End Props.


(** ** 5. The aggregator, completion by size only: each stored group holds fewer than [size] exchanges, and a group is
    emitted exactly when its [size]-th exchange arrives, then removed (aggregate-eip.adoc 256-257: "after X aggregated
    exchanges its complete"). Hence every emitted group holds exactly [size] exchanges, and is emitted once. *)

Lemma ceqs_refl : forall a, ceqs a a = true.
Proof. induction a as [|c a IH]; simpl; [reflexivity|]. unfold ceq. now rewrite Ascii.eqb_refl, IH. Qed.
Lemma ceqs_eq : forall a b, ceqs a b = true -> a = b.
Proof.
  induction a as [|c a IH]; destruct b as [|d b]; simpl; try discriminate; auto.
  intro H. apply andb_true_iff in H as [H1 H2]. unfold ceq in H1. apply Ascii.eqb_eq in H1. subst. f_equal. auto.
Qed.

Lemma aglget_aglset : forall id v l, aglget id (aglset id v l) = v.
Proof.
  intros id v l. induction l as [|[k' v'] r IH]; simpl.
  - now rewrite ceqs_refl.
  - destruct (ceqs id k') eqn:E; simpl; [now rewrite E | now rewrite E].
Qed.
Lemma agget_agput : forall k a l, agget k (agput k a l) = Some a.
Proof.
  intros k a l. induction l as [|[k' a'] r IH]; simpl; [now rewrite ceqs_refl|].
  destruct (ceqs k k') eqn:E; simpl; rewrite E; [reflexivity | exact IH].
Qed.
Lemma agget_agput_other : forall k k' a l, ceqs k' k = false -> agget k' (agput k a l) = agget k' l.
Proof.
  intros k k' a l Hne. induction l as [|[k2 a2] r IH]; simpl.
  - now rewrite Hne.
  - destruct (ceqs k k2) eqn:E; simpl.
    + apply ceqs_eq in E. subst k2. now rewrite Hne.
    + destruct (ceqs k' k2); [reflexivity | exact IH].
Qed.
Lemma agget_agdel : forall k l, agget k (agdel k l) = None.
Proof.
  intros k l. induction l as [|[k' a'] r IH]; simpl; [reflexivity|].
  destruct (ceqs k k') eqn:E; [exact IH|]. simpl. now rewrite E.
Qed.
Lemma agget_agdel_other : forall k k' l, ceqs k' k = false -> agget k' (agdel k l) = agget k' l.
Proof.
  intros k k' l Hne. induction l as [|[k2 a2] r IH]; simpl; [reflexivity|].
  destruct (ceqs k k2) eqn:E.
  - apply ceqs_eq in E. subst k2. rewrite Hne. exact IH.
  - simpl. destruct (ceqs k' k2); [reflexivity | exact IH].
Qed.

Definition groups_below (g : gstate) (id : chars) (size : nat) : Prop :=
  forall k a, agget k (aglget id (g_agg g)) = Some a -> ag_n a < size.

Lemma groups_of_with : forall g id f, aglget id (g_agg (with_groups g id f)) = f (aglget id (g_agg g)).
Proof. intros. unfold with_groups. simpl. apply aglget_aglset. Qed.
Lemma groups_of_close : forall g id k, g_agg (close_key g id k) = g_agg g.
Proof. reflexivity. Qed.

Theorem aggregate_size_invariant : forall x g o g',
  ago_pred o = None -> agg_step x g o = AgCont g' ->
  forall sz, ago_size o = Some sz -> groups_below g (ago_id o) sz -> groups_below g' (ago_id o) sz.
Proof.
  intros x g o g' Hp H sz Hs Hb k a Ha.
  unfold agg_step in H. rewrite Hp, Hs in H.
  destruct (ago_strat o); try discriminate;
  destruct (eval_expr x (ago_corr o)) as [v|w]; try discriminate;
  destruct v; try discriminate; simpl in H;
  repeat match goal with
         | H : context [if ?b then _ else _] |- _ => destruct b eqn:?; try discriminate
         | H : context [match ?m with _ => _ end] |- _ => destruct m eqn:?; try discriminate
         end;
  inversion H; subst; clear H;
  rewrite groups_of_with in Ha;
  match goal with
  | Ha : agget k (agput ?k0 ?a0 ?l) = Some a |- _ =>
      destruct (ceqs k k0) eqn:Ek;
      [ apply ceqs_eq in Ek; subst k; rewrite agget_agput in Ha; inversion Ha; subst a; simpl;
        match goal with Hl : context [Nat.leb sz ?n] |- _ =>
          rewrite ?Bool.orb_false_r in Hl; apply Nat.leb_gt in Hl; lia end
      | rewrite agget_agput_other in Ha by exact Ek; exact (Hb _ _ Ha) ]
  end.
Qed.

(** The number of exchanges a group holds once the incoming one is aggregated. *)
Definition count_after (g : gstate) (id k : chars) : nat :=
  match agget k (aglget id (g_agg g)) with Some a => S (ag_n a) | None => 1 end.

Theorem aggregate_emits_at_size : forall x g o g' agx sz,
  ago_pred o = None -> ago_size o = Some sz -> 0 < sz -> groups_below g (ago_id o) sz ->
  agg_step x g o = AgEmit g' agx ->
  exists k, count_after g (ago_id o) k = sz /\ agget k (aglget (ago_id o) (g_agg g')) = None.
Proof.
  intros x g o g' agx sz Hp Hs Hpos Hb H.
  unfold agg_step in H. rewrite Hp, Hs in H.
  destruct (ago_strat o); try discriminate;
  destruct (eval_expr x (ago_corr o)) as [v|w]; try discriminate;
  destruct v; try discriminate; simpl in H;
  repeat match goal with
         | H : context [if ?b then _ else _] |- _ => destruct b eqn:?; try discriminate
         | H : context [match ?m with _ => _ end] |- _ => destruct m eqn:?; try discriminate
         end;
  inversion H; subst; clear H;
  match goal with
  | Hc : agget ?k0 (aglget (ago_id o) (g_agg g)) = _ |- _ =>
      exists k0; unfold count_after; rewrite Hc; split;
      [ match goal with Hl : context [Nat.leb sz ?n] |- _ =>
          rewrite ?Bool.orb_false_r in Hl; apply Nat.leb_le in Hl end;
        try (specialize (Hb _ _ Hc)); lia
      | rewrite ?groups_of_close, groups_of_with; apply agget_agdel ]
  end.
Qed.

(** Non-vacuity: the hypotheses can be met (completionSize 3, no predicate, an empty repository). *)
Example aggregate_hyps_satisfiable :
  exists o, ago_pred o = None /\ ago_size o = Some 3 /\ 0 < 3 /\ groups_below g0 (ago_id o) 3.
Proof.
  exists (mkAgg (str "a1") hid StGroupedBody (Some 3) None false false).
  repeat split; [lia|]. intros k a H. simpl in H. discriminate.
Qed.

(** ** 6. Redelivery: the counter the onException block sees is 0 without redelivery and maximumRedeliveries after
    them, never more (dead-letter-channel.adoc 575-584; with handled/continued the block sees no counter at all) *)
Lemma lower_ceqs_ieq : forall a b c, ieq a b = true -> ieq c a = ieq c b.
Proof.
  intros a b c H. unfold ieq in *. apply ceqs_eq in H. now rewrite H.
Qed.
Lemma ieq_refl : forall a, ieq a a = true.
Proof. intro a. unfold ieq. apply ceqs_refl. Qed.
Lemma hget_hset : forall k v hs, hget k (hset k v hs) = v.
Proof.
  intros k v hs. induction hs as [|[k' v'] r IH]; simpl.
  - now rewrite ieq_refl.
  - destruct (ieq k k') eqn:E; simpl; rewrite E; [reflexivity | exact IH].
Qed.
Lemma hget_hset_other : forall k k' v hs, ieq k k' = false -> hget k (hset k' v hs) = hget k hs.
Proof.
  intros k k' v hs Hne. induction hs as [|[k2 v2] r IH]; simpl.
  - now rewrite Hne.
  - destruct (ieq k' k2) eqn:E; simpl.
    + rewrite <- (lower_ceqs_ieq _ _ k E), Hne. reflexivity.
    + destruct (ieq k k2); [reflexivity | exact IH].
Qed.

Definition counter_seen (k : clause) (x : exchange) : val :=
  hget (str "CamelRedeliveryCounter") (m_headers (x_msg (block_input k x))).
Theorem redelivery_counter_exact : forall k x,
  c_continued k = false -> c_handled k <> Some true ->
  counter_seen k x = VInt (Z.of_nat (c_redeliveries k)).
Proof.
  intros k x Hc Hh. unfold counter_seen, block_input. rewrite Hc. simpl.
  destruct (c_handled k) as [[|]|]; [congruence| |];
  (destruct (c_redeliveries k) as [|n] eqn:E;
   [ unfold not_redelivered_headers, map_headers, with_msg; simpl; apply hget_hset
   | unfold redelivery_headers, map_headers, with_msg; simpl;
     rewrite hget_hset_other by (vm_compute; reflexivity); apply hget_hset ]).
Qed.
Corollary redelivery_counter_bounded : forall k x z,
  c_continued k = false -> c_handled k <> Some true -> counter_seen k x = VInt z ->
  (Z.to_nat z <= c_redeliveries k)%nat.
Proof.
  intros k x z Hc Hh H. rewrite redelivery_counter_exact in H by assumption. inversion H. lia.
Qed.
