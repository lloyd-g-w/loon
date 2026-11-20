(** What the registry needs to know about a component's sources. *)

open! Core

(** The capitalised module names an OCaml source refers to as modules: before
    a [.] ([Button.view], [Icon.t]) or after [open], [open!] or [include].
    Comments and string literals are skipped. *)
val module_refs : string -> String.Set.t

(** The [loon-...] class names in an OCaml source's string literals. A
    literal ending in [-] (["loon-button-" ^ size]) stands for every class it
    starts. *)
val class_literals : string -> String.Set.t

(** The [.loon-...] classes a stylesheet's selectors name. *)
val css_classes : string -> String.Set.t

(** Whether [literal] (from {!class_literals}) names [class_]. *)
val literal_matches : literal:string -> class_:string -> bool

(** The first sentence of a source's leading doc comment ([(** ... *)] before
    any code), on one line, with the [\[...\]] code markup removed. *)
val description : string -> string option
