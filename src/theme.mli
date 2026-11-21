(** Light and dark mode. shadcn/ui's theme is CSS variables on [:root],
    with dark values under the class [dark] on an ancestor (usually
    [<html>]): [root ~mode:Dark] is a [div] with that class. *)

open! Import

module Mode : sig
  type t =
    | Light
    | Dark
  [@@deriving enumerate, sexp, compare, equal]

  val toggle : t -> t

  (** The browser's preference ([prefers-color-scheme]); [Light] where it
      cannot tell. *)
  val preferred : unit -> t
end

(** The attributes of a themed subtree's root: the class [dark] in [Dark]
    mode. *)
val attrs : ?mode:Mode.t -> unit -> Attr.t list

(** A [div] with [attrs ?mode ()]: the subtree is dark with [Dark], else its
    surroundings' mode (nothing undoes a [dark] ancestor). Every colour comes from the theme's
    variables, so the subtree's text and background follow it:
    [bg-background text-foreground]. *)
val root : ?attrs:Attr.t list -> ?mode:Mode.t -> Node.t list -> Node.t
