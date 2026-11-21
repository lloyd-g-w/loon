(** The fonts Typeset offers: shadcn's [(typeset)/lib/fonts.ts], the
    customisers' fonts without the display faces that read poorly as body
    text (Instrument Serif, EB Garamond, Playfair Display). *)

open! Core

type t = Customize_fonts.Font.t

val all : t list
val find : string -> t option

(** The value to render it with: its preview variable, then its family. *)
val value : t -> string
