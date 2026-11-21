(** What Typeset's "Get Code" shows for the chosen params: a port of the
    code generation in shadcn's [(typeset)/components/docs-panel.tsx]. *)

open! Core

module Framework : sig
  (** shadcn's [(create)/lib/templates.ts]. *)
  type t =
    | Next
    | Vite
    | Start
    | Laravel
    | React_router
    | Astro
  [@@deriving enumerate, sexp_of, compare, equal]

  (** ["next"], ..., ["react-router"], ["astro"]. *)
  val name : t -> string

  (** ["Next.js"], ..., ["Astro"]. *)
  val title : t -> string

  val of_name : string -> t option
end

module Package_manager : sig
  type t =
    | Pnpm
    | Npm
    | Yarn
    | Bun
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string

  (** [command] (an [npm install] or [npx] one) for this package manager. *)
  val command : t -> string -> string
end

(** The fonts the params pick (body, heading, mono; without repeats). *)
val picked_fonts : Typeset_params.t -> Customize_fonts.Font.t list

(** ["typeset-docs"]: the preset's class, named after the content. *)
val preset_name : Typeset_params.t -> string

(** The preset's rule ([.typeset-docs { --typeset-font-body: ...; }]). *)
val preset_css : Typeset_params.t -> string

(** The main CSS file: Tailwind's and typeset's imports, then the preset. *)
val preset : Typeset_params.t -> string

(** The container to wrap content in. *)
val usage : Typeset_params.t -> string

val next_font_code : Customize_fonts.Font.t list -> string
val fontsource_command : Customize_fonts.Font.t list -> string
val fontsource_css : Customize_fonts.Font.t list -> string

(** The prompt for a coding agent, with the picks baked in. *)
val prompt : Typeset_params.t -> Framework.t -> string

(** The URLs the prompt names: shadcn's [typeset.css] and its docs. *)
val css_url : string

val docs_url : string
