(** The class strings of shadcn's base-nova style ([styles/base-nova/ui]),
    which ui.shadcn.com's customisers are built from, where they differ
    from loon's (new-york-v4) components. *)

(** [Card] with [size="sm"]: give it [data-size="sm"]. *)
val card : string

val card_header : string
val card_content : string
val card_footer : string
val field_group : string

(** [FieldSeparator]'s wrapper; its line is a {!Loon.Separator} with
    [absolute inset-0 top-1/2]. *)
val field_separator : string

module Button : sig
  type variant =
    | Outline
    | Ghost
    | Link

  type size =
    | Default
    | Sm

  val classes : ?class_:string -> variant -> size -> string
end
