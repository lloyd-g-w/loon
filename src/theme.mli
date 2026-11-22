(** Light and dark mode, and the style. shadcn/ui's theme is CSS variables
    on [:root], with dark values under the class [dark] on an ancestor
    (usually [<html>]): [root ~mode:Dark] is a [div] with that class. The
    style (shadcn's Vega, Nova, Maia, ...) is the class [style-<name>] on an
    ancestor, which gives the components' [cn-*] classes their look;
    without one they are Vega. *)

open! Import

(** shadcn/ui's styles ([registry/styles.tsx]). *)
module Style : sig
  type t =
    | Vega (** Clean, neutral, and familiar (the default) *)
    | Nova (** Reduced padding and margins *)
    | Maia (** Rounded, with generous spacing *)
    | Lyra (** Boxy and sharp. For mono fonts *)
    | Mira (** Made for compact interfaces *)
    | Luma (** Fluid, luminous, and soft *)
    | Sera (** Editorial and typographic *)
    | Rhea (** Like Luma but compact *)
  [@@deriving enumerate, sexp, compare, equal]

  (** shadcn's name: ["vega"]. *)
  val name : t -> string

  val of_name : string -> t option

  (** The class that applies it: ["style-vega"]. *)
  val class_ : t -> string
end

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
    mode, and the style's class. *)
val attrs : ?mode:Mode.t -> ?style:Style.t -> unit -> Attr.t list

(** A [div] with [attrs ?mode ?style ()]: the subtree is dark with [Dark],
    else its surroundings' mode (nothing undoes a [dark] ancestor), and in
    [style], else its surroundings' style. Every colour comes from the
    theme's variables, so the subtree's text and background follow it:
    [bg-background text-foreground]. *)
val root
  :  ?attrs:Attr.t list
  -> ?mode:Mode.t
  -> ?style:Style.t
  -> Node.t list
  -> Node.t
