(** The first columns' cards of shadcn's [preview] block. *)

open! Core
open Bonsai_web
open Create_preview_util

(** What the overview cards name: the style and fonts. *)
module Info : sig
  type t =
    { style : string
    ; font : string
    ; font_heading : string
    }

  (** New York, Geist. *)
  val default : t
end

val style_overview : Info.t Bonsai.t -> card
val typography_specimen : Info.t Bonsai.t -> card
val ui_elements : card
val icon_preview_grid : card
val codespaces_card : card
val invoice : card
val observability_card : card
val shipping_address : card
val environment_variables : card
val bar_chart_card : card
val invite_team : card
val activate_agent_dialog : card
val skeleton_loading : card
