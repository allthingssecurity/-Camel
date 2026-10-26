(** Extraction of the type-conversion rules (Convert.v) to OCaml, for the differential oracle in oracle/convert.
    The oracle is this extracted code plus a value pool and a printer (oracle/convert/driver.ml); the rules are only
    in Convert.v. Mappings: strings/ascii to OCaml string/char, Z to zarith, nat to OCaml int (all lengths here are
    small). Not in _RocqProject (it writes files); built by oracle/convert/build.sh. *)
From Stdlib Require Import ZArith String Ascii List.
From Stdlib Require Extraction ExtrOcamlBasic ExtrOcamlNativeString ExtrOcamlZBigInt ExtrOcamlNatInt.
From CamelSpec.L0 Require Import Value Convert.
From CamelSpec.Common Require Import Text.
Extraction Language OCaml.
Extraction "oracle/convert/convert.ml" run all_jtypes all_apis jname aname str.
