(** Extraction of the L5 rules (Uri.v, proved sound by [run_ep_sound] / [cat_validate_sound]) and the generated
    catalog, for the differential oracle in oracle/l5. Mappings: strings/ascii to OCaml string/char, Z to zarith, nat
    to OCaml int (all lengths here are small). Part of the harness trust base (TRUST.md). Not in _RocqProject (it
    writes files); built by oracle/l5/build.sh. *)
From Stdlib Require Import ZArith String Ascii List.
From Stdlib Require Extraction ExtrOcamlBasic ExtrOcamlNativeString ExtrOcamlZBigInt ExtrOcamlNatInt.
From CamelSpec.Common Require Import Text.
From CamelSpec.L5 Require Import Model GenCatalog Uri Catalog.
Extraction Language OCaml.
Extraction "oracle/l5/l5spec.ml" run_ep run_pin run_real cat_validate_real cat_validate cat_props cat_asuri cat_name catalog avail_pin str find_comp.
