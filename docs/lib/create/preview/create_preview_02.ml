open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Create_preview_util
open Create_preview_layout
module A = Create_preview_02_a
module B = Create_preview_02_b
module C = Create_preview_02_c

let all cards (local_ graph) = Bonsai.all (List.map cards ~f:(fun card -> card graph))

let component (local_ graph) =
  let col1 =
    all
      [ A.contribution_history
      ; A.empty_distribute_track
      ; A.qr_connect
      ; A.dividend_income
      ; A.index_investing
      ; A.syncing_state
      ]
      graph
  in
  let col2 =
    all
      [ A.payout_threshold
      ; A.claimable_balance
      ; A.preferences
      ; A.savings_progress
      ; A.kitchen_island
      ]
      graph
  in
  let col3 =
    all
      [ B.savings_targets
      ; B.recent_transactions
      ; B.sidebar_nav
      ; B.faq
      ; B.payments
      ; B.front_door
      ; B.release_catalog
      ]
      graph
  in
  let col4 =
    all
      [ C.account_access; C.card_overview; C.transfer_funds; C.cover_art; C.loading_card ]
      graph
  in
  let col5 =
    all
      [ C.receiving_method
      ; C.power_usage
      ; C.empty_connect_bank
      ; C.upcoming_payments
      ; C.roller_shades
      ]
      graph
  in
  let col6 =
    all
      [ C.stock_performance
      ; C.empty_explore_catalog
      ; C.new_milestone
      ; C.social_links
      ; C.notification_settings
      ]
      graph
  in
  let%arr col1 and col2 and col3 and col4 and col5 and col6 in
  let col3 =
    match col3 with
    | [ savings; recent; sidebar; faq; payments; front_door; release ] ->
      [ savings
      ; recent
      ; div
          ~class_:"grid grid-cols-2 items-start gap-(--gap)"
          [ div ~class_:"flex flex-col gap-(--gap)" [ sidebar; faq ]
          ; div ~class_:"flex flex-col gap-(--gap)" [ payments; front_door ]
          ]
      ; release
      ]
    | _ -> col3
  in
  frame
    [ column col1
    ; column col2
    ; column ~wide:true col3
    ; column col4
    ; column col5
    ; column col6
    ]
;;
