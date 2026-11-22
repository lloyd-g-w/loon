open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
open Create_preview_util
module Node = Vdom.Node
module Attr = Vdom.Attr
module Info = Create_preview_01_a.Info

let bar_data ~x ~y rows = List.map rows ~f:(fun (k, v) -> [ x, `Text k; y, `Num v ])

let upcoming_item ~label ~value ~detail =
  Item.view
    ~variant:Muted
    ~class_:"flex-col items-stretch"
    [ Item.content
        ~class_:"gap-1"
        [ Item.description
            ~class_:"text-xs font-medium tracking-wider text-muted-foreground uppercase"
            [ text label ]
        ; tspan "cn-font-heading text-lg font-semibold" value
        ; tspan "text-sm text-muted-foreground" detail
        ]
    ]
;;

let contribution_history (info : Info.t Bonsai.t) (local_ graph) =
  let chart = chart graph in
  let%arr chart and info in
  let config =
    [ "amount", Chart.Config.item ~label:"Contribution" ~color:"var(--chart-2)" () ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Contribution History" ]
        ; Card.description [ text "Last 6 months of activity" ]
        ]
    ; Card.content
        [ Chart.container
            ~config
            ~class_:"h-[200px] w-full"
            chart
            (Chart.bar_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:8. ~bottom:0. ())
               ~data:
                 (bar_data
                    ~x:"month"
                    ~y:"amount"
                    [ "Dec", 800.
                    ; "Jan", 1100.
                    ; "Feb", 900.
                    ; "Mar", 1300.
                    ; "Apr", 750.
                    ; "May", 1400.
                    ])
               [ Chart.x_axis
                   ~data_key:"month"
                   ~tick_line:false
                   ~tick_margin:8.
                   ~axis_line:false
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ~class_:"min-w-40" ())
                   ()
               ; Chart.bar
                   ~data_key:"amount"
                   ~fill:"var(--color-amount)"
                   ~radius:(Info.bar_radius info 6.)
                   ~max_bar_size:40.
                   ()
               ])
        ]
    ; Card.content
        [ div
            ~class_:"grid w-full grid-cols-1 gap-3 @min-[48rem]/preview:grid-cols-2"
            [ upcoming_item
                ~label:"Upcoming"
                ~value:"May 25, 2024"
                ~detail:"$1,000 scheduled"
            ; upcoming_item
                ~label:"Auto-Save Plan"
                ~value:"Accelerated"
                ~detail:"Recurring weekly"
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "View Full Report" ] ]
    ]
;;

let empty_distribute_track =
  static
    (Card.root
       [ Card.content
           [ empty_card
               ~media:(icon Plus)
               ~title:"Distribute Track"
               ~description:
                 "Upload your first master to start reaching listeners on Spotify, \
                  Apple Music, and more."
               ~button:(Button.view [ text "Create Release" ])
               ()
           ]
       ])
;;

(* react-qr-code's SVG for "https://ledger.app/connect/jd-4829" at level M
   (29 modules). *)
let qr_path =
  "M0 0h7v1h-7zM9 0h2v1h-2zM12 0h4v1h-4zM17 0h4v1h-4zM22 0h7v1h-7zM0 1h1v1h-1zM6 \
   1h1v1h-1zM9 1h3v1h-3zM13 1h5v1h-5zM22 1h1v1h-1zM28 1h1v1h-1zM0 2h1v1h-1zM2 \
   2h3v1h-3zM6 2h1v1h-1zM8 2h3v1h-3zM13 2h1v1h-1zM15 2h1v1h-1zM18 2h3v1h-3zM22 \
   2h1v1h-1zM24 2h3v1h-3zM28 2h1v1h-1zM0 3h1v1h-1zM2 3h3v1h-3zM6 3h1v1h-1zM8 \
   3h2v1h-2zM11 3h2v1h-2zM14 3h2v1h-2zM17 3h1v1h-1zM19 3h1v1h-1zM22 3h1v1h-1zM24 \
   3h3v1h-3zM28 3h1v1h-1zM0 4h1v1h-1zM2 4h3v1h-3zM6 4h1v1h-1zM8 4h1v1h-1zM11 \
   4h2v1h-2zM15 4h2v1h-2zM18 4h3v1h-3zM22 4h1v1h-1zM24 4h3v1h-3zM28 4h1v1h-1zM0 \
   5h1v1h-1zM6 5h1v1h-1zM8 5h1v1h-1zM10 5h3v1h-3zM20 5h1v1h-1zM22 5h1v1h-1zM28 \
   5h1v1h-1zM0 6h7v1h-7zM8 6h1v1h-1zM10 6h1v1h-1zM12 6h1v1h-1zM14 6h1v1h-1zM16 \
   6h1v1h-1zM18 6h1v1h-1zM20 6h1v1h-1zM22 6h7v1h-7zM8 7h3v1h-3zM14 7h1v1h-1zM16 \
   7h1v1h-1zM19 7h2v1h-2zM0 8h1v1h-1zM2 8h5v1h-5zM10 8h1v1h-1zM17 8h1v1h-1zM19 \
   8h1v1h-1zM22 8h5v1h-5zM3 9h3v1h-3zM7 9h4v1h-4zM13 9h3v1h-3zM18 9h7v1h-7zM28 \
   9h1v1h-1zM0 10h1v1h-1zM4 10h1v1h-1zM6 10h1v1h-1zM8 10h1v1h-1zM10 10h1v1h-1zM13 \
   10h6v1h-6zM20 10h1v1h-1zM23 10h1v1h-1zM1 11h1v1h-1zM3 11h2v1h-2zM7 11h4v1h-4zM13 \
   11h1v1h-1zM15 11h1v1h-1zM19 11h1v1h-1zM23 11h3v1h-3zM27 11h1v1h-1zM1 12h1v1h-1zM6 \
   12h2v1h-2zM10 12h1v1h-1zM12 12h1v1h-1zM14 12h1v1h-1zM16 12h2v1h-2zM25 12h2v1h-2zM0 \
   13h1v1h-1zM2 13h1v1h-1zM9 13h1v1h-1zM19 13h2v1h-2zM22 13h3v1h-3zM28 13h1v1h-1zM0 \
   14h1v1h-1zM5 14h2v1h-2zM8 14h4v1h-4zM15 14h1v1h-1zM20 14h2v1h-2zM24 14h3v1h-3zM1 \
   15h3v1h-3zM5 15h1v1h-1zM7 15h1v1h-1zM12 15h1v1h-1zM14 15h1v1h-1zM18 15h7v1h-7zM27 \
   15h1v1h-1zM3 16h8v1h-8zM15 16h5v1h-5zM21 16h1v1h-1zM25 16h2v1h-2zM0 17h3v1h-3zM7 \
   17h2v1h-2zM11 17h4v1h-4zM17 17h3v1h-3zM21 17h4v1h-4zM26 17h1v1h-1zM28 17h1v1h-1zM0 \
   18h1v1h-1zM2 18h1v1h-1zM6 18h5v1h-5zM13 18h3v1h-3zM17 18h1v1h-1zM22 18h3v1h-3zM26 \
   18h1v1h-1zM0 19h1v1h-1zM5 19h1v1h-1zM9 19h1v1h-1zM11 19h1v1h-1zM13 19h1v1h-1zM15 \
   19h1v1h-1zM21 19h4v1h-4zM27 19h1v1h-1zM0 20h1v1h-1zM2 20h3v1h-3zM6 20h2v1h-2zM9 \
   20h2v1h-2zM14 20h1v1h-1zM16 20h2v1h-2zM20 20h5v1h-5zM26 20h3v1h-3zM8 21h3v1h-3zM12 \
   21h1v1h-1zM17 21h4v1h-4zM24 21h5v1h-5zM0 22h7v1h-7zM9 22h1v1h-1zM15 22h1v1h-1zM17 \
   22h4v1h-4zM22 22h1v1h-1zM24 22h3v1h-3zM0 23h1v1h-1zM6 23h1v1h-1zM8 23h2v1h-2zM11 \
   23h2v1h-2zM14 23h3v1h-3zM18 23h3v1h-3zM24 23h1v1h-1zM27 23h2v1h-2zM0 24h1v1h-1zM2 \
   24h3v1h-3zM6 24h1v1h-1zM8 24h3v1h-3zM15 24h3v1h-3zM20 24h5v1h-5zM26 24h2v1h-2zM0 \
   25h1v1h-1zM2 25h3v1h-3zM6 25h1v1h-1zM8 25h2v1h-2zM11 25h1v1h-1zM14 25h1v1h-1zM18 \
   25h1v1h-1zM25 25h4v1h-4zM0 26h1v1h-1zM2 26h3v1h-3zM6 26h1v1h-1zM8 26h1v1h-1zM10 \
   26h3v1h-3zM15 26h2v1h-2zM21 26h7v1h-7zM0 27h1v1h-1zM6 27h1v1h-1zM10 27h1v1h-1zM12 \
   27h2v1h-2zM15 27h2v1h-2zM18 27h4v1h-4zM24 27h2v1h-2zM27 27h1v1h-1zM0 28h7v1h-7zM8 \
   28h2v1h-2zM12 28h1v1h-1zM14 28h1v1h-1zM17 28h3v1h-3zM23 28h1v1h-1zM26 28h1v1h-1z"
;;

let qr_code () =
  let svg = Node.create_svg in
  svg
    "svg"
    ~attrs:
      [ Attr.create "height" "160"
      ; Attr.create "width" "160"
      ; Attr.create "viewBox" "0 0 29 29"
      ]
    [ svg
        "path"
        ~attrs:[ Attr.create "fill" "#FFFFFF"; Attr.create "d" "M0,0 h29v29H0z" ]
        []
    ; svg "path" ~attrs:[ Attr.create "fill" "#000000"; Attr.create "d" qr_path ] []
    ]
;;

let qr_connect =
  static
    (Card.root
       [ Card.content
           ~class_:"flex justify-center pt-6"
           [ div ~class_:"rounded-xl border bg-white p-4" [ qr_code () ] ]
       ; Card.header
           ~class_:"text-center"
           [ Card.title [ text "Scan to connect your mobile device" ]
           ; Card.description
               [ text "Open the Ledger mobile app and scan this code to link your device."
               ]
           ]
       ; Card.footer [ Button.view ~variant:Secondary ~class_:"w-full" [ text "Got it" ] ]
       ])
;;

let holdings =
  [ "Vanguard VIG", "450 Shares", "$1,842.10", [ 380.; 420.; 390.; 652. ]
  ; "S&P 500 VOO", "112 Shares", "$928.40", [ 180.; 210.; 320.; 218. ]
  ; "Apple AAPL", "85 Shares", "$340.00", [ 60.; 70.; 120.; 90. ]
  ; "Realty Income", "320 Shares", "$1,139.50", [ 240.; 260.; 280.; 360. ]
  ]
;;

let dividend_income (info : Info.t Bonsai.t) (local_ graph) =
  let charts = List.map holdings ~f:(fun _ -> chart graph) |> Bonsai.all in
  let%arr charts and info in
  let config =
    [ "value", Chart.Config.item ~label:"Dividend" ~color:"var(--chart-2)" () ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Q2 Dividend Income" ]
        ; Card.description
            [ text "Quarterly dividend payouts across your portfolio holdings." ]
        ; Card.action [ close_button () ]
        ]
    ; Card.content
        [ Item.group
            (List.map2_exn holdings charts ~f:(fun (name, shares, amount, data) chart ->
               Item.view
                 ~variant:Muted
                 [ Item.content
                     [ Item.title [ text name ]; Item.description [ text shares ] ]
                 ; Chart.container
                     ~config
                     ~class_:"hidden h-8 w-24 @min-[48rem]/preview:block"
                     chart
                     (Chart.bar_chart
                        ~margin:(Chart.margin ~top:0. ~right:0. ~bottom:0. ~left:0. ())
                        ~data:
                          (bar_data
                             ~x:"q"
                             ~y:"value"
                             (List.zip_exn [ "Q1"; "Q2"; "Q3"; "Q4" ] data))
                        [ Chart.tooltip
                            ~cursor:false
                            ~content:(Chart.tooltip_content ~hide_label:true ())
                            ()
                        ; Chart.bar
                            ~data_key:"value"
                            ~fill:"var(--color-value)"
                            ~radius:(Info.bar_radius info 3.)
                            ()
                        ])
                 ; tspan "hidden text-sm font-semibold tabular-nums @min-[48rem]/preview:block" amount
                 ]))
        ]
    ]
;;

let index_investing =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Dollar-Cost Averaging" ]
           ; Card.description [ text "A strategy for building wealth over time." ]
           ]
       ; Card.content
           [ Card.description
               ~class_:"mt-3 text-sm leading-relaxed style-sera:mt-0"
               [ Node.a
                   ~attrs:
                     [ Attr.href "#"
                     ; Attr.class_ "underline underline-offset-4 hover:text-primary"
                     ]
                   [ text "Over time" ]
               ; text
                   ", this smooths out the average cost of your investments. When \
                    prices                     drop, your fixed amount buys more shares. \
                    When prices rise, you buy                     fewer. The result is a \
                    lower average cost per share compared to                     \
                    lump-sum investing during volatile periods."
               ]
           ]
       ])
;;

let syncing_state =
  static
    (Card.root
       [ Card.content
           ~class_:"p-0"
           [ empty_card
               ~media_in_header:true
               ~media:(Spinner.view ())
               ~title:"Syncing your accounts"
               ~description:
                 "We're pulling in your latest transactions. This usually takes a \
                  few                   seconds."
               ~button:(Button.view ~variant:Outline [ text "Cancel" ])
               ()
           ]
       ])
;;

let currencies =
  [ "usd", "USD — United States Dollar"
  ; "eur", "EUR — Euro"
  ; "gbp", "GBP — British Pound"
  ; "jpy", "JPY — Japanese Yen"
  ]
;;

let payout_threshold (local_ graph) =
  let currency =
    select ~id:"preferred-currency" ~class_:"w-full" ~default_value:"usd" currencies graph
  in
  let amount = slider_state 2500. graph in
  let notes =
    Textarea.component
      ~id:"payout-notes"
      ~placeholder:"Add any notes for this payout configuration..."
      ~class_:"min-h-[100px]"
      graph
  in
  let%arr currency
  and amount, set_amount = amount
  and notes in
  Card.root
    [ Card.header
        [ Card.title [ text "Payout Threshold" ]
        ; Card.description
            [ text "Set the minimum balance required before a payout is triggered." ]
        ; Card.action [ close_button () ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label
                    ~for_:(select_trigger_id "preferred-currency")
                    [ text "Preferred Currency" ]
                ; currency
                ]
            ; Field.root
                [ div
                    ~class_:"flex items-baseline justify-between"
                    [ Field.label ~for_:"min-payout" [ text "Minimum Payout Amount" ]
                    ; tspan "text-2xl font-semibold tabular-nums" (sprintf "$%.2f" amount)
                    ]
                ; Slider.view
                    ~attrs:[ Attr.id "min-payout" ]
                    ~value:[ amount ]
                    ~on_change:(fun v -> set_amount (List.hd_exn v))
                    ~min:50.
                    ~max:10000.
                    ~step:50.
                    ()
                ; div
                    ~class_:"flex items-center justify-between"
                    [ Field.description [ text "$50 (MIN)" ]
                    ; Field.description [ text "$10,000 (MAX)" ]
                    ]
                ]
            ; Field.root [ Field.label ~for_:"payout-notes" [ text "Notes" ]; notes.view ]
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Save Threshold" ] ]
    ]
;;

let row ?(value_class = "text-sm font-medium tabular-nums") label value =
  div
    ~class_:"flex items-center justify-between"
    [ tspan "text-sm text-muted-foreground" label; tspan value_class value ]
;;

let claimable_balance =
  static
    (Card.root
       [ Card.header
           [ Card.description [ text "Claimable Balance" ]
           ; Card.title ~class_:"text-5xl tabular-nums" [ text "$0.00" ]
           ; Badge.view
               ~variant:Outline
               [ span ~class_:"size-2 rounded-full bg-yellow-500" []
               ; text "Pending Setup"
               ]
           ]
       ; Card.content
           ~class_:"flex flex-1 flex-col justify-end"
           [ Item.view
               ~variant:Muted
               ~class_:"flex-col items-stretch"
               [ Item.content
                   ~class_:"gap-3"
                   [ row "Net Royalties" "$0.00"
                   ; row "Processing Fee" "-$0.00"
                   ; Separator.view ()
                   ; row
                       ~value_class:"text-sm font-semibold tabular-nums"
                       "Total Ready to Claim"
                       "$0.00 USD"
                   ]
               ]
           ]
       ; Card.footer
           [ Card.description
               [ text
                   "Once your bank is connected, balances over $10.00 are \
                    automatically                     eligible for monthly distribution \
                    on the 15th of each month."
               ]
           ]
       ])
;;

let switch_field ~id ~label ~description switch =
  Field.root
    ~orientation:Horizontal
    [ Field.content
        [ Field.label ~for_:id [ text label ]; Field.description [ text description ] ]
    ; switch
    ]
;;

let preferences (local_ graph) =
  let currency =
    select ~id:"default-currency" ~class_:"w-full" ~default_value:"usd" currencies graph
  in
  let public_ = Switch.component ~id:"public-statistics" ~default_checked:true graph in
  let email = Switch.component ~id:"email-notifications" ~default_checked:true graph in
  let%arr currency
  and public_
  and email in
  Card.root
    [ Card.header
        [ Card.title [ text "Preferences" ]
        ; Card.description [ text "Manage your account settings and notifications." ]
        ; Card.action [ close_button () ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label
                    ~for_:(select_trigger_id "default-currency")
                    [ text "Default Currency" ]
                ; currency
                ]
            ; Field.separator ~class_:"-my-4 style-sera:hidden" []
            ; switch_field
                ~id:"public-statistics"
                ~label:"Public Statistics"
                ~description:
                  "Allow others to see your total stream count and listening activity"
                public_.view
            ; Field.separator ~class_:"-my-4 style-sera:hidden" []
            ; switch_field
                ~id:"email-notifications"
                ~label:"Email Notifications"
                ~description:"Monthly royalty reports and distribution updates"
                email.view
            ]
        ]
    ; Card.footer
        [ Button.view ~variant:Outline [ text "Reset" ]
        ; Button.view ~class_:"ml-auto" [ text "Save Preferences" ]
        ]
    ]
;;

let savings_centre (vb : Chart.Polar_view_box.t) =
  let svg = Node.create_svg in
  svg
    "text"
    ~attrs:
      [ Attr.create "x" (num vb.cx)
      ; Attr.create "y" (num vb.cy)
      ; Attr.create "text-anchor" "middle"
      ; Attr.create "dominant-baseline" "middle"
      ]
    [ svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (num vb.cx)
          ; Attr.create "y" (num (vb.cy -. 12.))
          ; Attr.class_ "fill-foreground text-2xl font-bold"
          ]
        [ text "$24,000" ]
    ; svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (num vb.cx)
          ; Attr.create "y" (num (vb.cy +. 12.))
          ; Attr.class_ "fill-muted-foreground text-xs"
          ]
        [ text "80% of $30,000" ]
    ]
;;

let footer_row ?(value_class = "text-sm font-semibold") label value =
  div
    ~class_:"flex w-full items-center justify-between py-3"
    [ tspan "text-sm text-muted-foreground" label; tspan value_class value ]
;;

let savings_progress (local_ graph) =
  let chart = chart graph in
  let%arr chart in
  let config =
    [ "saved", Chart.Config.item ~label:"Saved" ~color:"var(--chart-2)" ()
    ; "remaining", Chart.Config.item ~label:"Remaining" ~color:"var(--chart-1)" ()
    ]
  in
  let data =
    List.map
      [ "saved", 24000.; "remaining", 6000. ]
      ~f:(fun (name, value) ->
        [ "name", `Text name
        ; "value", `Num value
        ; "fill", `Text ("var(--color-" ^ name ^ ")")
        ])
  in
  Card.root
    [ Card.content
        [ Chart.container
            ~config
            ~class_:"mx-auto aspect-square max-h-[220px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data
                   ~data_key:"value"
                   ~name_key:"name"
                   ~inner_radius:70.
                   ~outer_radius:95.
                   ~stroke_width:0.
                   ~start_angle:90.
                   ~end_angle:(-270.)
                   ~children:[ Chart.label ~content:savings_centre () ]
                   ()
               ])
        ]
    ; Card.footer
        ~class_:"flex-col gap-0"
        [ footer_row "Projected Finish" "October 2024"
        ; Separator.view ()
        ; footer_row
            ~value_class:"text-sm font-semibold tabular-nums"
            "Monthly Average"
            "$1,250"
        ; Separator.view ()
        ; footer_row "Top Contributor" "Auto-Transfer"
        ]
    ]
;;

module Scene = struct
  type t =
    { brightness : float
    ; color_temp : float
    ; volume : float
    ; fade : float
    }
  [@@deriving equal, sexp_of]

  let of_name = function
    | "dining" -> { brightness = 50.; color_temp = 40.; volume = 20.; fade = 60. }
    | "nightlight" -> { brightness = 15.; color_temp = 20.; volume = 0.; fade = 80. }
    | "focus" -> { brightness = 100.; color_temp = 85.; volume = 0.; fade = 0. }
    | _ -> { brightness = 90.; color_temp = 70.; volume = 30.; fade = 0. }
  ;;
end

let kitchen_island (local_ graph) =
  let enabled, set_enabled = Bonsai.state true graph in
  let scene, set_scene = Bonsai.state "cooking" graph in
  let levels, set_levels = Bonsai.state (Scene.of_name "cooking") graph in
  let%arr enabled
  and set_enabled
  and scene
  and set_scene
  and levels
  and set_levels in
  let slider ?class_ value set =
    Slider.view
      ?class_
      ~value:[ value ]
      ~on_change:(fun v -> set_levels (set (List.hd_exn v)))
      ~max:100.
      ~disabled:(not enabled)
      ()
  in
  let item i title slider =
    Item.view
      ~size:Sm
      ~variant:Outline
      [ Item.media ~variant:Icon [ icon i ]
      ; Item.content
          ~class_:"flex-row items-center gap-3"
          [ Item.title ~class_:"shrink-0" [ text title ] ]
      ; Item.actions ~class_:"flex-1" [ slider ]
      ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Kitchen Island" ]
        ; Card.description [ text "Hue Color Ambient" ]
        ; Card.action [ Switch.view ~checked:enabled ~on_change:set_enabled () ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ div
            ~class_:"flex flex-col gap-2"
            [ tspan "sr-only" "Scenes"
            ; Toggle_group.single
                ~value:(Some scene)
                ~on_change:(function
                  | None -> Effect.Ignore
                  | Some value ->
                    Effect.Many [ set_scene value; set_levels (Scene.of_name value) ])
                ~variant:Outline
                ~spacing:1
                ~class_:"flex-wrap"
                (fun group ->
                   List.map
                     [ "cooking", "Cooking"
                     ; "dining", "Dining"
                     ; "nightlight", "Nightlight"
                     ; "focus", "Focus"
                     ]
                     ~f:(fun (value, label) ->
                       Toggle_group.item
                         group
                         ~value
                         ~disabled:(not enabled)
                         [ text label ]))
            ]
        ; Item.group
            [ item
                Sun
                "Brightness"
                (slider ~class_:"w-full" levels.brightness (fun brightness ->
                   { levels with brightness }))
            ; item
                Thermometer
                "Color Temp"
                (slider levels.color_temp (fun color_temp -> { levels with color_temp }))
            ; item
                Volume_2
                "Volume"
                (slider levels.volume (fun volume -> { levels with volume }))
            ; item Timer "Fade" (slider levels.fade (fun fade -> { levels with fade }))
            ]
        ]
    ]
;;
