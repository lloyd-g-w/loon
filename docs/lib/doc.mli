(** What a documentation page is made of. *)

open! Core
open Bonsai_web

module Group : sig
  type t =
    | Guide
    | Forms
    | Overlays
    | Display
    | Navigation
    | Feedback
  [@@deriving enumerate, sexp_of, compare, equal]

  val title : t -> string
end

module Example : sig
  type t =
    { title : string
    ; source : string
    ; view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
    }
end

module Page : sig
  type t =
    { slug : string
    ; title : string
    ; group : Group.t
    ; description : string
    ; usage : string option (** a short code snippet shown first *)
    ; body : Vdom.Node.t list (** prose and tables after the examples *)
    ; examples : Example.t list
    }
end

(** An example of the page [page] (its file's name without [_page.ml]): its
    source is the text the docs' generator found under the example's
    marker in that file ("(*$ title" ... "(*$*)"). *)
val example
  :  page:string
  -> string
  -> (local_ Bonsai.graph -> Vdom.Node.t Bonsai.t)
  -> Example.t

(** An example that needs no state. *)
val static : page:string -> string -> Vdom.Node.t -> Example.t

val page
  :  ?usage:string
  -> ?body:Vdom.Node.t list
  -> slug:string
  -> title:string
  -> group:Group.t
  -> description:string
  -> Example.t list
  -> Page.t

(** Prose helpers for [body]. *)

val h2 : string -> Vdom.Node.t
val p : string -> Vdom.Node.t
val code : string -> Vdom.Node.t

(** A table of a component's arguments: name, type, description. *)
val props : (string * string * string) list -> Vdom.Node.t
