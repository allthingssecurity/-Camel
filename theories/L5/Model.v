(** * L5 model: the shape of a component's documented option table.

    Every component page includes the generated option tables of its JSON descriptor ([CEO.13-67]: "The {doctitle}
    endpoint is configured using URI syntax: {syntax} With the following path and query parameters", one row per
    option with Name, Description, Default and Type). This file only declares the record that holds one row; the rows
    themselves are generated from the JSON files by tools/gen_l5.py into [GenCatalog.v] (data, no rules). Legend:
      [CEO] docs/docs/components/modules/ROOT/partials/component-endpoint-options.adoc
      [CJ:x] docs/component-json/catalog-components.tar.xz, member ./x.json (the catalog copy of the component JSON;
             the uncompressed copies of the ones used most are in docs/component-json/)

    What is kept of a row: the name, whether it is a path or a query option ([CEO.37-67], JSON [kind]), the JSON
    [type] and [javaType] (the table's Type column, [CEO.9]), [required], [defaultValue] (the Default column,
    [CEO.8]), the [enum] list, [multiValue] with its [prefix], [optionalPrefix], and [secret]. Descriptions, groups and
    labels are left out (no rule uses them yet). *)
From Stdlib Require Import String List.
Import ListNotations.
Open Scope string_scope.

Inductive okind : Type := KPath | KParam.

(** The JSON [type] of an option. *)
Inductive oty : Type := TyString | TyBoolean | TyInteger | TyNumber | TyDuration | TyEnum | TyObject | TyArray.

(** The JSON [javaType], as far as the rules distinguish it: the String / Integer / Long / Boolean / Double wrappers and
    primitives, [java.time.Duration], a Java enum class named by an option of type [enum] ([JEnum]), and any other class
    ([JOther]: objects, maps, lists, Date, Float, Byte, interfaces such as [org.apache.camel.spi.Language]). *)
Inductive ojt : Type :=
| JString | JPInt | JInt | JPLong | JLong | JPBool | JBool | JPDouble | JDouble | JDuration | JEnum | JOther.

Record opt : Type := mkOpt {
  o_name : string;
  o_kind : okind;
  o_ty : oty;
  o_jt : ojt;
  o_req : bool;
  o_def : option string;          (* the JSON defaultValue, as text *)
  o_enum : list string;
  o_multienum : bool;
  o_prefix : option string;       (* the JSON prefix of a multiValue option *)
  o_multi : bool;
  o_oprefix : option string;      (* the JSON optionalPrefix *)
  o_secret : bool
}.

Record comp : Type := mkComp {
  c_file : string;                (* the JSON file name in the catalog *)
  c_scheme : string;
  c_syntax : string;
  c_lenient : bool;               (* the JSON lenientProperties *)
  c_api : bool;                   (* the JSON api: an API-based component (apiName/methodName, [CEO.69-150]) *)
  c_reqc : list string;           (* the required component options (componentProperties) without a default *)
  c_opts : list opt
}.

(** Short constructor used by the generated tables. *)
Definition mkO (n : string) (k : okind) (t : oty) (j : ojt) (r : bool) (d : option string) (e : list string)
  (me : bool) (p : option string) (m : bool) (op : option string) (s : bool) : opt :=
  mkOpt n k t j r d e me p m op s.
