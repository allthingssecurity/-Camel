(* Conversion oracle driver: enumerates a pool of values x target types x API methods, asks the extracted rules
   (convert.ml, from theories/L0/Convert.v) for the documented result, and prints one case per line:
     id TAB api TAB type TAB value TAB expected
   value: the canonical text of CONVENTIONS.md (N, S<pct>, I<int>, L<long>, D<quarters>, B1/B0, A<pct>,...).
   expected: V<value> | Z<unscaled>:<scale> (a BigDecimal equal to it) | NULL | X<exception class>
             | P<pct why>|alt|alt... (one of the alternatives; alt = V.. Z.. NULL X<cls> ANYV) | U<pct why>.
   The pool and this printer are harness code; the semantics is only in Convert.v.  usage: driver *)
open Convert

let cl (s : string) : char list = List.init (String.length s) (String.get s)
let sc (l : char list) : string = String.init (List.length l) (List.nth l)
let z = Big_int_Z.big_int_of_string
let zs = Big_int_Z.string_of_big_int

(* percent-encode everything but [A-Za-z0-9] *)
let pct (s : string) : string =
  let b = Buffer.create (String.length s * 2) in
  String.iter (fun c ->
    match c with
    | 'A'..'Z' | 'a'..'z' | '0'..'9' -> Buffer.add_char b c
    | _ -> Buffer.add_string b (Printf.sprintf "%%%02X" (Char.code c))) s;
  Buffer.contents b

let enc_val = function
  | VNull -> "N"
  | VStr s -> "S" ^ pct (sc s)
  | VInt i -> "I" ^ zs i
  | VLong i -> "L" ^ zs i
  | VDbl q -> "D" ^ zs q
  | VBool b -> if b then "B1" else "B0"
  | VList l -> "A" ^ string_of_int (List.length l) ^ "." ^ String.concat "," (List.map (fun s -> pct (sc s)) l)

let enc_out = function
  | OV v -> "V" ^ enc_val v
  | ODec (m, k) -> "Z" ^ zs m ^ ":" ^ string_of_int k
  | ONull -> "NULL"
  | OExc c -> "X" ^ c
  | OAnyVal -> "ANYV"

let enc_res = function
  | CV v -> "V" ^ enc_val v
  | CDec (m, k) -> "Z" ^ zs m ^ ":" ^ string_of_int k
  | CNull -> "NULL"
  | CFail c -> "X" ^ c
  | COneOf (os, why) -> "P" ^ pct why ^ "|" ^ String.concat "|" (List.map enc_out os)
  | CUns why -> "U" ^ pct why

let s x = VStr (cl x)
let pool : val0 list =
  [ VNull;
    s ""; s " "; s "42"; s "-7"; s "0"; s "-0"; s "007"; s "+1"; s " 7 "; s "7 "; s "1.0"; s "1.5"; s "2.5";
    s "-1.25"; s "0.1"; s "1000.01"; s "1e3"; s "1e5"; s "1E5"; s "1e10"; s "0x10"; s "#10";
    s "2147483647"; s "2147483648"; s "-2147483648"; s "-2147483649";
    s "9223372036854775807"; s "9223372036854775808"; s "-9223372036854775808";
    s "true"; s "false"; s "TRUE"; s "True"; s "yes"; s "no"; s "on"; s "1"; s "abc"; s "a,b"; s "NaN";
    s "Infinity"; s "null";
    VInt (z "0"); VInt (z "1"); VInt (z "42"); VInt (z "-1"); VInt (z "2147483647"); VInt (z "-2147483648");
    VLong (z "0"); VLong (z "5"); VLong (z "2147483648"); VLong (z "-2147483649");
    VLong (z "9223372036854775807"); VLong (z "-9223372036854775808"); VLong (z "9007199254740993");
    VDbl (z "0"); VDbl (z "1"); VDbl (z "8"); VDbl (z "10"); VDbl (z "-6"); VDbl (z "17179869184");
    VBool true; VBool false;
    VList []; VList [cl "a"]; VList [cl "a"; cl "b"]; VList [cl "1"]; VList [cl "true"] ]

let () =
  let id = ref 0 in
  List.iter (fun a ->
    List.iter (fun t ->
      List.iter (fun v ->
        incr id;
        Printf.printf "%d\t%s\t%s\t%s\t%s\n" !id (aname a) (jname t) (enc_val v) (enc_res (run a v t)))
        pool) all_jtypes) all_apis
