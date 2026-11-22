(** A style of shadcn's /create ([registry/styles.tsx]): the class
    [style-<name>] (Theme.Style) over the components. *)

type t =
  { name : string (** ["vega"] *)
  ; title : string
  ; description : string
  ; icon : string (** SVG markup, [class="size-4"] *)
  }
[@@deriving sexp_of]
