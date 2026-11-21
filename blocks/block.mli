(** shadcn/ui's blocks: whole pages and sections (dashboards, sidebars,
    login and signup forms, calendars) built from loon's components, each
    a module of this library ([Dashboard_01.view]). This module lists them
    with shadcn's registry metadata, for a gallery. *)

open! Core
open Bonsai_web

module Category : sig
  type t =
    | Sidebar
    | Dashboard
    | Authentication
    | Login
    | Signup
    | Calendar
  [@@deriving enumerate, sexp_of, compare, equal]

  val name : t -> string

  (** ["sidebar"], ["login"], ... *)
  val slug : t -> string

  (** Not listed in shadcn's blocks navigation (Dashboard, Authentication). *)
  val hidden : t -> bool
end

type t =
  { name : string (** shadcn's name: ["dashboard-01"] *)
  ; description : string
  ; categories : Category.t list
  ; iframe_height : string (** the preview's height in shadcn's gallery *)
  ; container : string option
    (** classes of the page wrapping the block, when viewed alone *)
  ; view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
  }

(** In shadcn's order: dashboard, sidebars, logins, signups, calendars. *)
val all : t list

val find : string -> t option
val in_category : Category.t -> t list

(** shadcn's featured blocks, for the gallery's first page. *)
val featured : t list

(** The block's module (and file) name: ["dashboard_01"]. *)
val module_name : t -> string
