(** Code as shadcn's docs show it: rehype-pretty-code's figure, with a copy
    button. *)

open! Core
open Bonsai_web

(** Copies [text] to the clipboard and marks the element the event came
    from [data-copied="true"] for two seconds. *)
val copy : text:string -> Js_of_ocaml.Dom_html.mouseEvent Js_of_ocaml.Js.t -> unit Effect.t

(** shadcn's CopyButton ([class_] after its own). *)
val copy_button : ?class_:string -> string -> Vdom.Node.t

(** A highlighted block (a fenced block in shadcn's mdx). *)
val view
  :  ?lang:Highlight.Lang.t
  -> ?line_numbers:bool
  -> ?class_:string
  -> string
  -> Vdom.Node.t

(** shadcn's CodeBlockCommand: [commands] are (tab, command line) pairs,
    [value] the tab shown. *)
val command
  :  id:string
  -> value:string
  -> on_change:(string -> unit Effect.t)
  -> (string * string) list
  -> Vdom.Node.t
