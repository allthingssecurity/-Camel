(** Extraction of the placeholder rules (L1/Placeholder.v) and the core-language rules (L1/Lang.v) for the
    differential oracle in oracle/lang. The oracle is this extracted code plus a generator and a printer
    (oracle/lang/driver.ml); the rules themselves are only in Placeholder.v and Lang.v. Mappings: strings/ascii to
    OCaml string/char, Z to zarith, nat to OCaml int (all lengths here are small). Part of the harness trust base. *)
From Stdlib Require Import ZArith String Ascii List.
From Stdlib Require Extraction ExtrOcamlBasic ExtrOcamlNativeString ExtrOcamlZBigInt ExtrOcamlNatInt.
From CamelSpec.Common Require Text.
From CamelSpec.L1 Require Placeholder Lang.
Extraction Language OCaml.
Extraction "oracle/lang/langspec.ml" Placeholder.resolve Lang.eval Lang.evalp Text.str.
