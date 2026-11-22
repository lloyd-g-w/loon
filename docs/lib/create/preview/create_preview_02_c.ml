open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
open Create_preview_util
module Node = Vdom.Node
module Attr = Vdom.Attr
module Info = Create_preview_01_a.Info

let input ?type_ ?placeholder ?value ~id () =
  Input.view
    ?type_
    ?placeholder
    ~id
    ~attrs:(Option.to_list (Option.map value ~f:default_value))
    ()
;;

let account_access =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Account Access" ]
           ; Card.description [ text "Update your credentials or re-authenticate." ]
           ]
       ; Card.content
           [ Field.group
               [ Field.root
                   [ Field.label ~for_:"email-address" [ text "Email Address" ]
                   ; input ~id:"email-address" ~type_:Email ~value:"artist@studio.inc" ()
                   ]
               ; Field.root
                   [ div
                       ~class_:"flex items-center justify-between"
                       [ Field.label ~for_:"current-password" [ text "Current Password" ]
                       ; Node.a
                           ~attrs:
                             [ Attr.href "#"
                             ; Attr.class_
                                 "text-xs font-medium tracking-wider \
                                  text-muted-foreground uppercase hover:text-foreground"
                             ]
                           [ text "Forgot?" ]
                       ]
                   ; input ~id:"current-password" ~type_:Password ~value:"password123" ()
                   ]
               ]
           ]
       ; Card.footer
           ~class_:"flex-col gap-4"
           [ Button.view ~class_:"w-full" [ icon Lock_keyhole; text "Update Security" ]
           ; Item.link
               ~variant:Muted
               ~href:"#"
               [ Item.media
                   ~variant:Icon
                   [ icon ~class_:"text-destructive" Circle_alert ]
               ; Item.content
                   [ Item.title [ text "Danger Zone" ]
                   ; Item.description
                       ~class_:"line-clamp-1"
                       [ text "Archive account and remove catalog" ]
                   ]
               ; icon ~class_:"size-4" Arrow_right
               ]
           ]
       ])
;;

let card_overview (local_ graph) =
  let chart = chart graph in
  let%arr chart in
  let config =
    [ "amount", Chart.Config.item ~label:"Activity" ~color:"var(--chart-2)" () ]
  in
  let data =
    List.map
      [ "Jan", 40.
      ; "Feb", 55.
      ; "Mar", 35.
      ; "Apr", 60.
      ; "May", 45.
      ; "Jun", 50.
      ; "Jul", 65.
      ; "Aug", 40.
      ; "Sep", 55.
      ; "Oct", 70.
      ; "Nov", 45.
      ; "Dec", 80.
      ]
      ~f:(fun (m, v) -> [ "month", `Text m; "amount", `Num v ])
  in
  div
    ~class_:"grid grid-cols-2 gap-3"
    [ Card.root
        [ Card.content
            [ Card.description [ text "Card Balance" ]
            ; Card.title ~class_:"text-2xl tabular-nums" [ text "US$12.94" ]
            ; Card.description ~class_:"tabular-nums" [ text "US$11,337.06 Available" ]
            ]
        ]
    ; Card.root
        ~class_:"flex flex-col justify-between"
        [ Card.content
            ~class_:"flex flex-1 flex-col justify-between"
            [ div
                ~class_:"flex flex-col gap-1"
                [ Card.description [ text "Payment Due" ]
                ; Card.title ~class_:"text-2xl" [ text "1 Apr" ]
                ]
            ; Button.view
                ~variant:Outline
                ~size:Sm
                ~class_:"mt-3 w-full"
                [ text "Pay Early" ]
            ]
        ]
    ; Card.root
        ~class_:"col-span-2"
        [ Card.content
            ~class_:"flex flex-col gap-2"
            [ div
                ~class_:"flex items-center justify-between"
                [ Card.description [ text "Yearly Activity" ]
                ; Badge.view ~variant:Secondary [ text "+US$0.25 Daily Cash" ]
                ]
            ; Chart.container
                ~config
                ~class_:"h-20 w-full [&_.recharts-cartesian-axis-tick_text]:text-[10px]"
                chart
                (Chart.bar_chart
                   ~margin:(Chart.margin ~top:4. ~right:0. ~bottom:0. ~left:0. ())
                   ~data
                   [ Chart.x_axis
                       ~data_key:"month"
                       ~tick_line:false
                       ~tick_margin:4.
                       ~axis_line:false
                       ~tick_formatter:(fun v -> String.prefix v 1)
                       ()
                   ; Chart.tooltip
                       ~cursor:false
                       ~content:(Chart.tooltip_content ~hide_label:true ())
                       ()
                   ; Chart.bar
                       ~data_key:"amount"
                       ~fill:"var(--color-amount)"
                       ~radius:(`Corners (3., 3., 0., 0.))
                       ()
                   ])
            ]
        ]
    ]
;;

let summary_row ?(label_class = "text-sm text-muted-foreground") ~value_class label value =
  div
    ~class_:"flex items-center justify-between"
    [ tspan label_class label; tspan value_class value ]
;;

let transfer_funds (local_ graph) =
  let from_ =
    select
      ~id:"from-account"
      ~class_:"w-full"
      ~default_value:"checking"
      [ "checking", "Main Checking (··8402) — $12,450.00"
      ; "business", "Business (··7731) — $8,920.00"
      ]
      graph
  in
  let to_ =
    select
      ~id:"to-account"
      ~class_:"w-full"
      ~default_value:"savings"
      [ "savings", "High Yield Savings (··1192) — $42,100.00"
      ; "investment", "Investment (··3349) — $18,200.00"
      ]
      graph
  in
  let%arr from_
  and to_ in
  Card.root
    [ Card.header
        [ Card.title [ text "Transfer Funds" ]
        ; Card.description [ text "Move money between your connected accounts." ]
        ; Card.action [ close_button () ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"transfer-amount" [ text "Amount to Transfer" ]
                ; Input_group.root
                    [ Input_group.addon [ Input_group.text [ text "$" ] ]
                    ; Input_group.input
                        ~id:"transfer-amount"
                        ~attrs:[ default_value "1,200.00" ]
                        ()
                    ]
                ]
            ; Field.root
                [ Field.label
                    ~for_:(select_trigger_id "from-account")
                    [ text "From Account" ]
                ; from_
                ]
            ; Field.root
                [ Field.label ~for_:(select_trigger_id "to-account") [ text "To Account" ]
                ; to_
                ]
            ; Item.view
                ~variant:Muted
                ~class_:"flex-col items-stretch"
                [ Item.content
                    ~class_:"gap-3"
                    [ summary_row
                        ~value_class:"text-sm font-medium"
                        "Estimated arrival"
                        "Today, Apr 14"
                    ; Separator.view ()
                    ; summary_row
                        ~value_class:"text-sm font-medium tabular-nums"
                        "Transaction fee"
                        "$0.00"
                    ; Separator.view ()
                    ; summary_row
                        ~label_class:"text-sm font-medium"
                        ~value_class:"text-sm font-semibold tabular-nums"
                        "Total amount"
                        "$1,200.00"
                    ]
                ]
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Confirm Transfer" ] ]
    ]
;;

let cover_art =
  static
    (Card.root
       [ Card.content
           ~class_:"flex flex-col gap-3"
           [ Label.view
               ~for_:"cover-art"
               ~class_:
                 "text-center text-xs font-normal tracking-wider text-muted-foreground \
                  uppercase"
               [ text "Cover Art" ]
           ; Item.view
               ~class_:"aspect-square"
               ~variant:Outline
               [ Node.label
                   ~attrs:
                     [ Attr.for_ "cover-art"
                     ; Attr.class_
                         "flex size-full cursor-pointer items-center justify-center"
                     ]
                   [ icon ~class_:"size-10 text-muted-foreground/50" Image ]
               ]
           ; Node.input
               ~attrs:
                 [ Attr.id "cover-art"
                 ; Attr.type_ "file"
                 ; Attr.create "accept" "image/jpeg,image/png"
                 ; Attr.class_ "sr-only"
                 ]
               ()
           ]
       ; Card.footer
           ~class_:"flex-col gap-2"
           [ Node.label
               ~attrs:
                 [ Attr.for_ "cover-art"
                 ; Attr.class_
                     (Button.classes
                        ~variant:Secondary
                        ~class_:"w-full cursor-pointer"
                        ())
                 ; Attr.create "data-slot" "button"
                 ; Attr.create "data-variant" "secondary"
                 ; Attr.create "data-size" "default"
                 ]
               [ text "Upload Artwork" ]
           ; Card.description
               ~class_:"text-center text-xs"
               [ text "Minimum 3000 × 3000px"; Node.br (); text "JPEG or PNG only" ]
           ]
       ])
;;

let loading_card =
  static
    (Card.root
       [ Card.header
           [ Skeleton.view ~class_:"h-5 w-32" []; Skeleton.view ~class_:"h-4 w-48" [] ]
       ; Card.content
           ~class_:"flex flex-col gap-4"
           [ Skeleton.view ~class_:"h-32 w-full rounded-lg" []
           ; div
               ~class_:"flex flex-col gap-2"
               [ Skeleton.view ~class_:"h-4 w-full" []
               ; Skeleton.view ~class_:"h-4 w-3/4" []
               ; Skeleton.view ~class_:"h-4 w-1/2" []
               ]
           ; div
               ~class_:"flex gap-2"
               [ Skeleton.view ~class_:"h-9 flex-1 rounded-md" []
               ; Skeleton.view ~class_:"h-9 flex-1 rounded-md" []
               ]
           ]
       ])
;;

let receiving_method (local_ graph) =
  let method_ =
    Radio_group.component
      ~default_value:"bank"
      ~class_:"grid grid-cols-1 items-start gap-3 @min-[48rem]/preview:grid-cols-2 style-sera:grid-cols-1"
      (Bonsai.return (fun group ->
         let option ~value ~id ~title ?description_class description =
           Field.label
             ~for_:id
             [ Field.root
                 ~orientation:Horizontal
                 ~class_:"pb-2.5"
                 [ Radio_group.item group ~value ~id
                 ; Field.content
                     [ Field.title [ text title ]
                     ; Field.description ?class_:description_class [ text description ]
                     ]
                 ]
             ]
         in
         [ option ~value:"bank" ~id:"method-bank" ~title:"Bank Transfer" "SWIFT / IBAN"
         ; option
             ~value:"paypal"
             ~id:"method-paypal"
             ~title:"PayPal"
             ~description_class:"line-clamp-1"
             "Instant Payout"
         ]))
      graph
  in
  let%arr method_ in
  Card.root
    [ Card.header
        [ Card.description [ text "Payout Preferences" ]
        ; Card.title [ text "Receiving Method" ]
        ; Card.action [ close_button () ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"account-holder" [ text "Account Holder Name" ]
                ; input ~id:"account-holder" ~value:"Synthetic Horizons Music LLC" ()
                ]
            ; Field.set
                [ Field.legend ~variant:Label [ text "Receiving Method" ]; method_.view ]
            ; Field.root
                [ Field.label ~for_:"iban" [ text "IBAN / Account Number" ]
                ; input ~id:"iban" ~placeholder:"DE89 3704 0044 ...." ()
                ]
            ]
        ]
    ; Card.footer
        [ Button.view ~class_:"w-full" ~disabled:true [ text "Save Payout Settings" ] ]
    ]
;;

let power_usage (info : Info.t Bonsai.t) (local_ graph) =
  let chart = chart graph in
  let%arr chart and info in
  let config =
    [ "usage", Chart.Config.item ~label:"Usage (kW)" ~color:"var(--chart-2)" () ]
  in
  let data =
    List.map
      [ "6a", 1.2
      ; "8a", 2.8
      ; "10a", 3.1
      ; "12p", 2.4
      ; "2p", 3.4
      ; "4p", 2.9
      ; "6p", 3.8
      ; "8p", 3.2
      ]
      ~f:(fun (h, v) -> [ "hour", `Text h; "usage", `Num v ])
  in
  let stat ?(value_class = "text-lg font-semibold tabular-nums") label value =
    div
      ~class_:"flex flex-col gap-0.5"
      [ tspan "text-sm text-muted-foreground" label; tspan value_class value ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Power Usage" ]; Card.description [ text "Whole Home" ] ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ Chart.container
            ~config
            ~class_:"h-[140px] w-full [&_.recharts-cartesian-axis-tick_text]:text-xs"
            chart
            (Chart.bar_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:4. ~bottom:0. ())
               ~data
               [ Chart.x_axis
                   ~data_key:"hour"
                   ~tick_line:false
                   ~tick_margin:6.
                   ~axis_line:false
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.bar
                   ~data_key:"usage"
                   ~fill:"var(--color-usage)"
                   ~radius:(Info.bar_radius info 4.)
                   ()
               ])
        ; Separator.view ()
        ; div
            ~class_:"grid grid-cols-2 gap-4"
            [ stat "Currently Using" "3.4 kW"
            ; stat
                ~value_class:"text-lg font-semibold text-chart-1 tabular-nums"
                "Solar Gen"
                "+1.2 kW"
            ]
        ]
    ; Card.footer
        ~class_:"flex-col items-start gap-1"
        [ tspan "text-sm text-muted-foreground" "Battery Level"
        ; div
            ~class_:"flex w-full items-center gap-2"
            [ Progress.view ~value:85. ~class_:"flex-1" ()
            ; tspan "text-sm font-medium tabular-nums" "85%"
            ]
        ]
    ]
;;

let empty_connect_bank =
  static
    (Card.root
       [ Card.content
           [ empty_card
               ~media:(icon Credit_card)
               ~title:"Connect Bank"
               ~description:
                 "Link your payout method to receive monthly royalty distributions \
                  automatically."
               ~button:(Button.view [ text "Set Up Payouts" ])
               ()
           ]
       ])
;;

let upcoming_payments (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:
        "w-full [--cell-size:--spacing(8)] @min-[48rem]/preview:[--cell-size:--spacing(10)] \
         style-sera:@min-[48rem]/preview:[--cell-size:--spacing(9)]"
      ~default:(Single (Some (Calendar.today ())))
      graph
  in
  let%arr calendar in
  let payment title date amount =
    Item.view
      ~variant:Muted
      [ Item.content [ Item.title [ text title ]; Item.description [ text date ] ]
      ; Badge.view ~variant:Secondary [ text amount ]
      ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Upcoming Payments" ]
        ; Card.description [ text "Select a date to view scheduled payments." ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ Item.view ~variant:Outline ~class_:"justify-center" [ calendar.view ]
        ; Item.group
            ~class_:"w-full"
            [ payment "Netflix Subscription" "Apr 15, 2024" "$19.99"
            ; payment "Rent Payment" "Apr 1, 2024" "$2,400.00"
            ; payment "Auto Insurance" "Apr 22, 2024" "$186.00"
            ]
        ]
    ]
;;

let roller_shades (local_ graph) =
  let position, set_position = Bonsai.state 50. graph in
  let%arr position
  and set_position in
  let preset =
    if Float.(position <= 10.)
    then "open"
    else if Float.(position >= 90.)
    then "closed"
    else "half"
  in
  let label s =
    tspan "text-xs font-medium tracking-wider text-muted-foreground uppercase" s
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Living Room" ]; Card.description [ text "Roller Shades" ] ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ div
            ~class_:"flex h-32 flex-col overflow-hidden rounded-lg border bg-muted"
            [ div
                ~class_:"bg-muted-foreground transition-all duration-300"
                ~attrs:
                  [ Attr.style
                      (Css_gen.create ~field:"height" ~value:(num position ^ "%"))
                  ]
                []
            ]
        ; div
            ~class_:"flex items-center gap-3"
            [ label "Open"
            ; Slider.view
                ~value:[ position ]
                ~on_change:(fun v -> set_position (List.hd_exn v))
                ~max:100.
                ~class_:"flex-1"
                ()
            ; label "Close"
            ]
        ]
    ; Card.footer
        [ Toggle_group.single
            ~value:(Some preset)
            ~on_change:(function
              | Some "open" -> set_position 0.
              | Some "half" -> set_position 50.
              | Some "closed" -> set_position 100.
              | _ -> Effect.Ignore)
            ~variant:Outline
            ~spacing:1
            ~class_:"w-full"
            (fun group ->
               [ Toggle_group.item group ~value:"open" ~class_:"flex-1" [ text "Open" ]
               ; Toggle_group.item group ~value:"half" ~class_:"flex-1" [ text "Half" ]
               ; Toggle_group.item
                   group
                   ~value:"closed"
                   ~class_:"flex-1"
                   [ text "Closed" ]
               ])
        ]
    ]
;;

let tickers = [ "VOO"; "VIG"; "AAPL"; "MSFT"; "GOOGL"; "AMZN"; "TSLA" ]

let price_data = function
  | "VOO" -> [ 412.; 438.; 395.; 450.; 420.; 462. ]
  | "AAPL" -> [ 185.; 210.; 172.; 198.; 178.; 215. ]
  | _ -> [ 100.; 118.; 95.; 125.; 108.; 130. ]
;;

let stock_performance (local_ graph) =
  let ticker =
    Combobox.component
      ~class_:"w-full justify-between"
      ~placeholder:"Search ticker..."
      ~search_placeholder:"Search ticker..."
      ~empty:"No tickers found."
      ~default_value:"VOO"
      (Bonsai.return
         (List.map tickers ~f:(fun t -> { Combobox.Option_.value = t; label = t })))
      graph
  in
  let chart = chart graph in
  let%arr value, combobox = ticker
  and chart in
  let config = [ "price", Chart.Config.item ~label:"Price" ~color:"var(--chart-1)" () ] in
  let data =
    List.map2_exn
      [ "Jan"; "Feb"; "Mar"; "Apr"; "May"; "Jun" ]
      (price_data (Option.value value ~default:"VOO"))
      ~f:(fun m p -> [ "month", `Text m; "price", `Num p ])
  in
  let svg = Node.create_svg in
  let stop offset opacity =
    svg
      "stop"
      ~attrs:
        [ Attr.create "offset" offset
        ; Attr.create "stop-color" "var(--color-price)"
        ; Attr.create "stop-opacity" opacity
        ]
      []
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Stock Performance" ]
        ; Card.description [ text "6-month price history." ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ Field.group
            [ Field.root [ Field.label ~for_:"ticker-select" [ text "Ticker" ]; combobox ]
            ]
        ; Separator.view ~class_:"style-sera:hidden" ()
        ; Chart.container
            ~config
            ~class_:"h-[200px] w-full"
            chart
            (Chart.area_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:8. ~bottom:0. ())
               ~data
               [ Chart.defs
                   [ svg
                       "linearGradient"
                       ~attrs:
                         [ Attr.id "fillPrice"
                         ; Attr.create "x1" "0"
                         ; Attr.create "y1" "0"
                         ; Attr.create "x2" "0"
                         ; Attr.create "y2" "1"
                         ]
                       [ stop "0%" "0.3"; stop "100%" "0.05" ]
                   ]
               ; Chart.cartesian_grid ~vertical:false ~stroke_dasharray:"3 3" ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.area
                   ~type_:Monotone
                   ~data_key:"price"
                   ~stroke:"var(--color-price)"
                   ~stroke_width:2.
                   ~fill:"url(#fillPrice)"
                   ()
               ])
        ]
    ]
;;

let empty_explore_catalog =
  static
    (Card.root
       [ Card.content
           [ empty_card
               ~media:(icon Audio_lines)
               ~title:"Explore Catalog"
               ~description:
                 "Check your ISRC codes, metadata, and visual assets before going live."
               ~button:(Button.view [ text "View Catalog" ])
               ()
           ]
       ])
;;

let new_milestone =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Set a new milestone" ]
           ; Card.description
               [ text "Define your financial target and we'll help you pace your savings."
               ]
           ]
       ; Card.content
           [ Field.group
               [ Field.root
                   [ Field.label ~for_:"goal-name" [ text "Goal Name" ]
                   ; input
                       ~id:"goal-name"
                       ~placeholder:"e.g. New Car, Home Downpayment"
                       ()
                   ]
               ; div
                   ~class_:"grid grid-cols-2 gap-3"
                   [ Field.root
                       [ Field.label ~for_:"target-amount" [ text "Target Amount" ]
                       ; input ~id:"target-amount" ~value:"$15,000" ()
                       ]
                   ; Field.root
                       [ Field.label ~for_:"target-date" [ text "Target Date" ]
                       ; input ~id:"target-date" ~value:"Dec 2025" ()
                       ]
                   ]
               ]
           ]
       ; Card.footer
           ~class_:"flex-col gap-2"
           [ Button.view ~class_:"w-full" [ text "Create Goal" ]
           ; Button.view ~variant:Outline ~class_:"w-full" [ text "Cancel" ]
           ]
       ])
;;

let social_links =
  let field ~id ~label i ?value ?placeholder () =
    Field.root
      [ Field.label ~for_:id [ text label ]
      ; Input_group.root
          [ Input_group.addon [ icon i ]
          ; Input_group.input
              ~id
              ?placeholder
              ~attrs:(Option.to_list (Option.map value ~f:default_value))
              ()
          ]
      ]
  in
  static
    (Card.root
       [ Card.header [ Card.title [ text "Social Links" ] ]
       ; Card.content
           [ Field.group
               [ field
                   ~id:"spotify-url"
                   ~label:"Spotify Artist URL"
                   Circle_plus
                   ~value:"spotify.com/artist/3j...2k"
                   ()
               ; field
                   ~id:"instagram-handle"
                   ~label:"Instagram Handle"
                   Camera
                   ~value:"@julianduryea_music"
                   ()
               ; field
                   ~id:"soundcloud-url"
                   ~label:"SoundCloud URL"
                   Cloud
                   ~placeholder:"soundcloud.com/username"
                   ()
               ; field
                   ~id:"website-url"
                   ~label:"Website"
                   Globe
                   ~placeholder:"https://yoursite.com"
                   ()
               ]
           ]
       ; Card.footer
           ~class_:"justify-end gap-2 style-sera:justify-center"
           [ Button.view ~variant:Secondary ~class_:"style-sera:flex-1" [ text "Discard" ]
           ; Button.view ~class_:"style-sera:flex-1" [ text "Save Changes" ]
           ]
       ])
;;

let notifications =
  [ "transactions", "Transaction alerts", "Deposits, withdrawals, and transfers.", true
  ; "security", "Security alerts", "Login attempts and account changes.", true
  ; "goals", "Goal milestones", "Updates at 25%, 50%, 75%, and 100%.", false
  ; "market", "Market updates", "Daily portfolio summary and price alerts.", false
  ]
;;

let notification_settings (local_ graph) =
  let checked, set_checked =
    Bonsai.state
      (String.Map.of_alist_exn (List.map notifications ~f:(fun (id, _, _, d) -> id, d)))
      graph
  in
  let%arr checked
  and set_checked in
  let all = Map.for_all checked ~f:Fn.id in
  let some = Map.exists checked ~f:Fn.id && not all in
  let state : Checkbox.State.t =
    if some then Indeterminate else Checkbox.State.of_bool all
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Notifications" ]
        ; Card.description [ text "Choose what you want to be notified about." ]
        ]
    ; Card.content
        [ Field.group
            (Field.root
               ~orientation:Horizontal
               [ Checkbox.view
                   ~id:"notify-all"
                   ~checked:state
                   ~on_change:(fun v -> set_checked (Map.map checked ~f:(fun _ -> v)))
                   ()
               ; Field.content [ Field.label ~for_:"notify-all" [ text "Select all" ] ]
               ]
             :: List.map notifications ~f:(fun (id, label, description, _) ->
               let html_id = "notify-" ^ id in
               Field.root
                 ~orientation:Horizontal
                 [ Checkbox.view
                     ~id:html_id
                     ~checked:(Checkbox.State.of_bool (Map.find_exn checked id))
                     ~on_change:(fun v -> set_checked (Map.set checked ~key:id ~data:v))
                     ()
                 ; Field.content
                     [ Field.label ~for_:html_id [ text label ]
                     ; Field.description [ text description ]
                     ]
                 ]))
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Save Preferences" ] ]
    ]
;;
