(** A style of shadcn's /create ([registry/styles.tsx]). loon ports
    new-york-v4, which is Vega's markup: the others need other components. *)

type t =
  { name : string (** ["vega"] *)
  ; title : string
  ; description : string
  ; icon : string (** SVG markup, [class="size-4"] *)
  }
[@@deriving sexp_of]
