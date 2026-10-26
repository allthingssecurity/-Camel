(** Extraction of the lifecycle rules' interpreter (L4/Lifecycle.v; [run_case] runs [step], proved sound and
    complete against the rules [lstep] by [step_sound] / [step_complete], and [run_sound] for whole traces) for the
    differential oracle in oracle/l4. Mappings: strings/ascii to OCaml string/char, Z to zarith, nat to OCaml int
    (lengths are small). Part of the harness trust base (notes/l4.md, TRUST). *)
From Stdlib Require Import ZArith String Ascii List.
From Stdlib Require Extraction ExtrOcamlBasic ExtrOcamlNativeString ExtrOcamlZBigInt ExtrOcamlNatInt.
From CamelSpec.Common Require Text.
From CamelSpec.L4 Require Import Lifecycle.
Extraction Language OCaml.
Extraction "oracle/l4/lifecyclespec.ml" run_case Text.str.
