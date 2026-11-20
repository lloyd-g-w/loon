(** Line icons drawn on a 24x24 grid, sized to the text (1em) and coloured
    with it. *)

open! Import

type t =
  | Check
  | X
  | Chevron_down
  | Chevron_up
  | Chevron_left
  | Chevron_right
  | Chevrons_up_down
  | Plus
  | Minus
  | Search
  | Info
  | Alert_triangle
  | Alert_circle
  | Check_circle
  | Sun
  | Moon
  | Copy
  | Menu
  | More_horizontal
  | Settings
  | User
  | Mail
  | Bell
  | Trash
  | Pencil
  | Arrow_right
  | Arrow_left
  | External_link
  | Github
  | Loader
  | Dot
  | Calendar
  | Home
  | Inbox
  | File
  | Folder
  | Command
[@@deriving enumerate, sexp_of, compare, equal]

val name : t -> string
val view : ?attrs:Attr.t list -> t -> Node.t
