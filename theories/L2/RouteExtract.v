(** Extraction of the route rules' interpreter (L2/Route.v, proved sound against the rules by [run_sound]) and the
    Simple renderer, for the differential oracle in oracle/route. Mappings: strings/ascii to OCaml string/char, Z to
    zarith, nat to OCaml int. Part of the harness trust base (TRUST.md). *)
From Stdlib Require Import ZArith String Ascii List.
From Stdlib Require Extraction ExtrOcamlBasic ExtrOcamlNativeString ExtrOcamlZBigInt ExtrOcamlNatInt.
From CamelSpec.Common Require Text.
From CamelSpec.L0 Require Exchange Convert.
From CamelSpec.L1 Require Simple.
From CamelSpec.L2 Require Import Route.
From CamelSpec.L6 Require Xml Yaml.
Extraction Language OCaml.
Extraction "oracle/route/routespec.ml" run_case Simple.render Text.str Exchange.g0 Text.lower Exchange.exn_class Exchange.exn_msg Convert.jname Xml.xml_program Yaml.yaml_program.
