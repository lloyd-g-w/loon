(** The fonts the customisers offer: shadcn's [FONT_DEFINITIONS]
    ([apps/v4/lib/font-definitions.ts]), in its order. Those under the SIL
    Open Font License are bundled (docs/bin/fonts/, by
    [tools/fetch-fonts.sh]); the others are [available = false] and shown
    disabled. *)

open! Core

module Kind : sig
  type t =
    | Sans
    | Mono
    | Serif
  [@@deriving sexp_of, compare, equal]

  (** ["sans"], ["mono"], ["serif"]. *)
  val name : t -> string
end

module Font : sig
  type t =
    { name : string (** shadcn's id: ["inter"], ["jetbrains-mono"] *)
    ; title : string (** ["Inter"] *)
    ; kind : Kind.t
    ; family : string (** the CSS value: ["'Inter Variable', sans-serif"] *)
    ; registry_variable : string (** ["--font-sans"], ["--font-mono"] or ["--font-serif"] *)
    ; preview_variable : string
        (** ["--font-inter"]: set (by {!style}) on {!root_class} *)
    ; import : string (** next/font's name: ["Inter"], ["Noto_Sans"] *)
    ; dependency : string (** the fontsource package: ["@fontsource-variable/inter"] *)
    ; weight : string list (** for a font with no variable weight: ["400"] *)
    ; available : bool (** bundled: its licence is the OFL *)
    }
  [@@deriving sexp_of]
end

val all : Font.t list
val find : string -> Font.t option

(** The class giving a subtree the fonts' preview variables. *)
val root_class : string

(** A [<style>] element: an [@font-face] for each available font (its
    [family]'s first name, loaded from [fonts/<name>.woff2] when used) and
    the preview variables under [.]{!root_class}. Put it in the page once. *)
val style : Virtual_dom.Vdom.Node.t

(** The CSS of {!style}. *)
val css : string
