(** A theme of shadcn's /create ([registry/themes.ts]): a base colour (every
    variable) or an accent (the variables it changes), as CSS variable names
    (without the [--]) and values, for light and dark mode. *)

type t =
  { name : string (** ["neutral"], ["blue"] *)
  ; title : string (** ["Neutral"] *)
  ; light : (string * string) list
  ; dark : (string * string) list
  }
[@@deriving sexp_of]
