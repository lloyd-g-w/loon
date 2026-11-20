(** loon's stylesheet (the theme's variables, the base styles and every
    component's), for pages that do not link [loon.css]. *)

open! Import

val css : string

(** Adds the stylesheet to the document's head (once; later calls do
    nothing). Call it before [Bonsai_web.Start.start]. *)
val install : unit -> unit
