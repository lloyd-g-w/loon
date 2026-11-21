(** Syntax highlighting for the docs' code blocks: a small tokenizer, not a
    parser, so it never fails on partial or unusual code. *)

open! Core
open Bonsai_web

module Lang : sig
  type t =
    | Ocaml
    | Dune
    | Shell
    | Css
    | Plain
  [@@deriving sexp_of, compare, equal]
end

module Kind : sig
  type t =
    | Plain
    | Keyword
    | String
    | Comment
    | Module
    | Constructor
    | Number
    | Ppx (** [let%arr], [[%expect]], [[@@deriving]] *)
    | Label (** [~name], [?name] *)
    | Operator
    | Punctuation
  [@@deriving sexp_of, compare, equal]

  val class_ : t -> string
end

(** Consecutive tokens of the same kind are merged; concatenating the
    texts gives back the input. *)
val tokenize : Lang.t -> string -> (Kind.t * string) list

val lang_name : Lang.t -> string

(** A [<code>] as shiki's: a [<span data-line>] per line, of spans with the
    kinds' classes ([hl-keyword], ...); [line_numbers] numbers the lines
    ([data-line-numbers]). *)
val view : ?lang:Lang.t -> ?line_numbers:bool -> string -> Vdom.Node.t

(** The highlighted spans alone, for inline code. *)
val tokens : ?lang:Lang.t -> string -> Vdom.Node.t
