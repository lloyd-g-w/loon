(** A registry entry: a component (or helper) and what [loon add] copies for
    it. *)

open! Core

module File : sig
  type t =
    { name : string (** e.g. [button.ml], [button.css] *)
    ; contents : string
    }
  [@@deriving sexp_of]
end

type t =
  { name : string (** the module's file name without [.ml], e.g. [dom_util] *)
  ; description : string
  ; sources : File.t list (** the [.ml] and [.mli] files *)
  ; css : File.t list (** its stylesheets, in order *)
  ; deps : string list (** the entries it uses directly *)
  }
[@@deriving sexp_of]

(** The entry holding the theme's stylesheets (the [src/css] files whose
    names start with a digit) and the [Theme] module if there is one. *)
val theme : string

(** [build files ~generated]: the entries of loon's sources [files] (paths
    such as [src/button.ml], [src/css/button.css]). Modules that are, or use,
    one of the [generated] modules (built by a rule, so not copyable) are
    left out. A module's dependencies are the modules it names and the
    entries owning the [loon-...] classes its strings use (a class belongs
    to the entry whose name, with [-] for [_], is its longest prefix); every
    entry depends on {!theme} except those the theme itself needs. *)
val build : (string * string) list -> generated:String.Set.t -> t list

(** The module names a [dune] file's rules generate ([(target x.ml)],
    [(targets ...)]), capitalised. *)
val generated_modules : string -> String.Set.t
