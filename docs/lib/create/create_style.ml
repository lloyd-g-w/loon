open! Core

type t =
  { name : string
  ; title : string
  ; description : string
  ; icon : string
  }
[@@deriving sexp_of]
