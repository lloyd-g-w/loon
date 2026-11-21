open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Create_preview_util
open Create_preview_layout
module A = Create_preview_01_a
module B = Create_preview_01_b

let all cards (local_ graph) = Bonsai.all (List.map cards ~f:(fun card -> card graph))

let component info (local_ graph) =
  let col1 =
    all
      [ A.style_overview info
      ; A.typography_specimen info
      ; (fun (local_ graph) ->
          let%arr ui_elements = A.ui_elements graph in
          div ~class_:"md:hidden" [ ui_elements ])
      ; A.codespaces_card
      ; A.invoice
      ]
      graph
  in
  let col2 =
    all
      [ A.icon_preview_grid
      ; (fun (local_ graph) ->
          let%arr ui_elements = A.ui_elements graph in
          div ~class_:"hidden w-full md:flex" [ ui_elements ])
      ; A.observability_card
      ; A.shipping_address
      ]
      graph
  in
  let col3 =
    all
      [ A.environment_variables
      ; A.bar_chart_card
      ; A.invite_team
      ; A.activate_agent_dialog
      ]
      graph
  in
  let col4 =
    all
      [ A.skeleton_loading
      ; B.pie_chart_card
      ; B.no_team_members
      ; B.report_bug
      ; B.contributors
      ]
      graph
  in
  let col5 =
    all [ B.feedback_form; B.book_appointment; B.sleep_report; B.github_profile ] graph
  in
  let col6 =
    all
      [ B.weekly_fitness_summary
      ; B.file_upload
      ; B.analytics_card
      ; B.usage_card
      ; B.shortcuts
      ]
      graph
  in
  let col7 =
    all
      [ B.anomaly_alert
      ; B.live_waveform_card
      ; B.visitors
      ; B.contributions_activity
      ; B.not_found
      ]
      graph
  in
  let%arr col1
  and col2
  and col3
  and col4
  and col5
  and col6
  and col7 in
  frame (List.map [ col1; col2; col3; col4; col5; col6; col7 ] ~f:(fun c -> column c))
;;
