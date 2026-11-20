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
    ; description : string option
        (** the rest of the example's marker comment, after the title *)
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
    ; order : int (** within its group (then by title); 100 by default *)
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
  :  ?order:int
  -> ?usage:string
  -> ?body:Vdom.Node.t list
  -> slug:string
  -> title:string
  -> group:Group.t
  -> description:string
  -> Example.t list
  -> Page.t

(** Prose helpers for [body]. *)

(** A section heading, listed in the page's "On this page" outline. *)
val h2 : string -> Vdom.Node.t

val h3 : string -> Vdom.Node.t

(** Text with code in brackets, as in odoc: ["Use [Table.view]."]. Pages'
    descriptions, examples' descriptions, [p] and [props]' descriptions are
    written this way. *)
val inline : string -> Vdom.Node.t list

val p : string -> Vdom.Node.t

(** A paragraph of mixed text, [code] and [link]s. *)
val p' : Vdom.Node.t list -> Vdom.Node.t

val text : string -> Vdom.Node.t

(** Inline code. *)
val code : string -> Vdom.Node.t

val link : href:string -> string -> Vdom.Node.t
val ul : Vdom.Node.t list list -> Vdom.Node.t

(** A highlighted code block with a copy button. *)
val pre : ?lang:Highlight.Lang.t -> string -> Vdom.Node.t

(** A highlighted aside: [tone] is ["info"] (default), ["warning"] or
    ["tip"]. *)
val note : ?tone:string -> ?title:string -> Vdom.Node.t list -> Vdom.Node.t

(** A plain table: column headings and rows of cells. *)
val table : string list -> Vdom.Node.t list list -> Vdom.Node.t

(** The id a heading with this text gets: lowercase words joined by ["-"]. *)
val anchor : string -> string

(** A table of a component's arguments: name, type, description. *)
val props : (string * string * string) list -> Vdom.Node.t
