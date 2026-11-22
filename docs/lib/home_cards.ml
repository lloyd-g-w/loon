open! Core
open Bonsai_web
open! Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

(* Ports of shadcn's home-page cards (apps/v4/app/(app)/(root)/cards), with
   its Hugeicons as the nearest Lucide icons. Ids are prefixed [home-]. *)

let text = Node.text
let div class_ children = Node.div ~attrs:[ Attr.class_ class_ ] children
let span class_ s = Node.span ~attrs:[ Attr.class_ class_ ] [ text s ]
let aria_label s = Attr.create "aria-label" s
let role s = Attr.create "role" s

let ui_elements (local_ graph) =
  let radio =
    Radio_group.component
      ~class_:"ml-auto flex w-fit gap-3"
      ~attrs:[ aria_label "Fruit preference" ]
      ~default_value:"apple"
      (Bonsai.return (fun group ->
         [ Radio_group.item ~attrs:[ aria_label "Apple" ] group ~value:"apple"
         ; Radio_group.item ~attrs:[ aria_label "Banana" ] group ~value:"banana"
         ]))
      graph
  in
  let email =
    Checkbox.component
      ~attrs:[ aria_label "Enable email alerts" ]
      ~default_checked:true
      graph
  in
  let push =
    Checkbox.component
      ~class_:"hidden 4xl:flex"
      ~attrs:[ aria_label "Enable push alerts" ]
      graph
  in
  let compact =
    Switch.component
      ~class_:"flex 4xl:hidden"
      ~attrs:[ aria_label "Enable compact notifications" ]
      ~default_checked:true
      graph
  in
  let advanced =
    Switch.component
      ~class_:"hidden 4xl:flex"
      ~attrs:[ aria_label "Enable advanced setting" ]
      ~default_checked:true
      graph
  in
  let alert_dialog =
    Alert_dialog.component
      (Bonsai.return (fun d ->
         [ Alert_dialog.trigger
             d
             (Button.view
                ~variant:Outline
                [ span "hidden md:flex style-sera:md:hidden" "Alert Dialog"
                ; span "flex md:hidden style-sera:md:flex" "Dialog"
                ])
         ; Alert_dialog.content
             ~size:Sm
             d
             [ Alert_dialog.header
                 [ Alert_dialog.title d [ text "Allow accessory to connect?" ]
                 ; Alert_dialog.description
                     d
                     [ text
                         "Do you want to allow the USB accessory to connect to this \
                          device and your data?"
                     ]
                 ]
             ; Alert_dialog.footer
                 [ Alert_dialog.cancel d [ text "Don't allow" ]
                 ; Alert_dialog.action d [ text "Allow" ]
                 ]
             ]
         ]))
      graph
  in
  let menu =
    Dropdown_menu.component
      (Bonsai.return (fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Button.view
                ~attrs:[ aria_label "Open quick actions" ]
                ~variant:Outline
                ~size:Icon
                [ Icon.view Chevron_up ])
         ; Dropdown_menu.content
             ~align:End
             ~side:Top
             ~class_:"w-40"
             menu
             [ Dropdown_menu.group
                 [ Dropdown_menu.label [ text "Quick Actions" ]
                 ; Dropdown_menu.item [ text "Mute Conversation" ]
                 ; Dropdown_menu.item [ text "Mark as Read" ]
                 ; Dropdown_menu.item [ text "Block User" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item ~variant:Destructive [ text "Delete Conversation" ] ]
             ]
         ]))
      graph
  in
  let%arr radio and email and push and compact and advanced and alert_dialog and menu in
  Card.root
    ~class_:"w-full"
    [ Card.content
        ~class_:"flex flex-col gap-6"
        [ div
            "flex gap-2"
            [ Button.view
                [ text "Button "
                ; Icon.view ~attrs:[ Attr.create "data-icon" "inline-end" ] Arrow_right
                ]
            ; Button.view ~variant:Secondary [ text "Secondary" ]
            ; Button.view ~variant:Outline [ text "Outline" ]
            ]
        ; Field.group
            [ Field.root
                [ Input_group.root
                    [ Input_group.input ~placeholder:"Name" ()
                    ; Input_group.addon
                        ~align:Inline_end
                        [ Input_group.text [ Icon.view Search ] ]
                    ]
                ]
            ; Field.root
                ~class_:"flex-1"
                [ Textarea.view ~placeholder:"Message" ~class_:"resize-none" () ]
            ]
        ; div
            "flex items-center gap-2"
            [ div
                "flex gap-2"
                [ Badge.view [ text "Badge" ]
                ; Badge.view ~variant:Secondary [ text "Secondary" ]
                ; Badge.view ~variant:Outline ~class_:"hidden 4xl:flex" [ text "Outline" ]
                ]
            ; radio.view
            ; div "flex gap-3" [ email.view; push.view ]
            ; compact.view
            ]
        ; div
            "flex items-center gap-4"
            [ alert_dialog
            ; Button_group.root
                ~class_:"ml-auto"
                [ Button.view
                    ~variant:Outline
                    [ span "style-sera:hidden" "Button Group"
                    ; span "hidden style-sera:block" "Group"
                    ]
                ; menu
                ]
            ; advanced.view
            ]
        ]
    ]
;;

let sidebar_nav =
  let sidebar =
    Sidebar.create
      ~persist:false
      ~open_:true
      ~on_open_change:(fun _ -> Effect.Ignore)
      ~open_mobile:false
      ~on_open_mobile_change:(fun _ -> Effect.Ignore)
      ~is_mobile:false
      ()
  in
  let section ~label ~class_ items =
    Card.root
      ~class_:(Cn.cn [ "w-full overflow-hidden rounded-3xl py-0"; class_ ])
      [ Sidebar.provider
          ~class_:"min-h-0"
          ~keyboard_shortcut:false
          sidebar
          [ Sidebar.root
              ~collapsible:None
              ~class_:"w-full bg-transparent"
              sidebar
              [ Sidebar.content
                  ~class_:"gap-0 overflow-hidden"
                  [ Sidebar.group
                      [ Sidebar.group_label [ text label ]
                      ; Sidebar.group_content
                          [ Sidebar.menu
                              ~class_:"gap-1"
                              (List.map items ~f:(fun (icon, name, is_active) ->
                                 Sidebar.menu_item
                                   [ Sidebar.menu_button
                                       ~is_active
                                       [ Icon.view icon; text name ]
                                   ]))
                          ]
                      ]
                  ]
              ]
          ]
      ]
  in
  div
    "grid w-full grid-cols-2 gap-4 xl:gap-6"
    [ section
        ~label:"Overview"
        ~class_:"xl:col-start-1 xl:row-start-2"
        [ Icon.Chart_area, "Analytics", true
        ; Arrow_up_down, "Transactions", false
        ; Trending_up, "Investments", false
        ; House, "Accounts", false
        ; Chart_pie, "Spending", false
        ]
    ; section
        ~label:"Planning"
        ~class_:"xl:col-start-1 xl:row-start-1"
        [ Icon.File_text, "Documents", false
        ; Calculator, "Budget", false
        ; Chart_column_big, "Reports", false
        ; Radar, "Goals", false
        ; Calendar, "Calendar", false
        ]
    ; section
        ~label:"Support"
        ~class_:"flex xl:col-start-2 xl:row-start-1"
        [ Icon.Circle_help, "Help Center", false
        ; Book_open, "Docs", false
        ; Message_circle, "Contact Us", false
        ; Activity, "Status", false
        ; Globe, "Community", false
        ]
    ; section
        ~label:"Account"
        ~class_:"flex xl:col-start-2 xl:row-start-2"
        [ Icon.User, "Profile", false
        ; Credit_card, "Billing", true
        ; Bell, "Notifications", false
        ; Shield_alert, "Security", false
        ; Paintbrush, "Appearance", false
        ]
    ]
;;

let savings_targets =
  let target ~label ~progress_label ~amount ~value ~achieved ~saved =
    Item.view
      ~attrs:[ role "listitem" ]
      ~variant:Muted
      ~class_:"flex-col items-stretch"
      [ Item.content
          ~class_:"gap-3"
          [ Item.description
              ~class_:
                "cn-font-heading text-xs font-medium tracking-wider \
                 text-muted-foreground uppercase"
              [ text label ]
          ; span "text-3xl font-semibold tabular-nums" amount
          ; Progress.view ~attrs:[ aria_label progress_label ] ~value ()
          ]
      ; Item.footer
          [ span "text-sm text-muted-foreground" achieved
          ; span "text-sm font-medium tabular-nums" saved
          ]
      ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Savings Targets" ]
        ; Card.description
            [ text
                "Active milestones for 2024 across your portfolio. Monitor how close you \
                 are to each savings goal."
            ]
        ]
    ; Card.content
        [ Item.group
            ~class_:"gap-3"
            [ target
                ~label:"Retirement"
                ~progress_label:"Retirement savings progress"
                ~amount:"$420,000"
                ~value:65.
                ~achieved:"65% achieved"
                ~saved:"$273,000"
            ; target
                ~label:"Real Estate"
                ~progress_label:"Real estate savings progress"
                ~amount:"$85,000"
                ~value:32.
                ~achieved:"32% achieved"
                ~saved:"$27,200"
            ]
        ]
    ; Card.footer
        [ Card.description
            ~class_:"text-center"
            [ text "You have not met your targets for this year." ]
        ]
    ]
;;

let height_percent value max =
  Attr.create "style" (sprintf "height: %g%%" (value /. max *. 100.))
;;

let contribution_history =
  let data = [ "Dec", 800.; "Jan", 1100.; "Feb", 900.; "Mar", 1300.; "Apr", 750. ] in
  let max_amount = List.fold data ~init:0. ~f:(fun m (_, a) -> Float.max m a) in
  let plan ~class_ ~label ~value ~detail =
    Item.view
      ~variant:Muted
      ~class_
      [ Item.content
          ~class_:"gap-1"
          [ Item.description
              ~class_:"text-xs font-medium tracking-wider text-muted-foreground uppercase"
              [ text label ]
          ; span "cn-font-heading text-base font-semibold" value
          ; span "text-sm text-muted-foreground" detail
          ]
      ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Contribution History" ]
        ; Card.description [ text "Last 6 months of activity" ]
        ]
    ; Card.content
        [ Node.div
            ~attrs:
              [ Attr.class_ "flex h-[200px] w-full items-end gap-3"
              ; role "img"
              ; aria_label "Last 6 months of contribution activity"
              ]
            (List.mapi data ~f:(fun index (month, amount) ->
               div
                 "flex h-full flex-1 flex-col justify-end gap-2"
                 [ Node.div
                     ~attrs:
                       [ Attr.create "data-index" (Int.to_string index)
                       ; Attr.class_
                           "data-[index=5]:bg-chart-6 min-h-2 rounded-lg \
                            data-[index=0]:bg-chart-1 data-[index=1]:bg-chart-2 \
                            data-[index=2]:bg-chart-3 data-[index=3]:bg-chart-4 \
                            data-[index=4]:bg-chart-5"
                       ; height_percent amount max_amount
                       ]
                     []
                 ; span "text-center text-xs text-muted-foreground" month
                 ]))
        ]
    ; Card.content
        [ div
            "grid w-full grid-cols-1 gap-3 xl:grid-cols-2"
            [ plan
                ~class_:"flex-col items-stretch"
                ~label:"Upcoming"
                ~value:"May 2024"
                ~detail:"Scheduled"
            ; plan
                ~class_:"hidden flex-col items-stretch xl:flex"
                ~label:"Savings Plan"
                ~value:"Accelerated"
                ~detail:"Recurring"
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "View Full Report" ] ]
    ]
;;

let claimable_balance =
  let row ~value_class label value =
    div
      "flex items-center justify-between"
      [ span "text-sm text-muted-foreground" label; span value_class value ]
  in
  let medium = "text-sm font-medium tabular-nums" in
  Card.root
    [ Card.header
        [ Card.description [ text "Claimable Balance" ]
        ; Card.title ~class_:"text-4xl tabular-nums" [ text "$1,211.29" ]
        ; Badge.view
            ~variant:Outline
            [ Node.span ~attrs:[ Attr.class_ "size-2 rounded-full bg-yellow-500" ] []
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
                [ row ~value_class:medium "Net Royalties" "$1,248.75"
                ; row ~value_class:medium "Processing Fee" "-$37.46"
                ; Separator.view ()
                ; row
                    ~value_class:"text-sm font-semibold tabular-nums"
                    "Total Ready to Claim"
                    "$1,211.29 USD"
                ]
            ]
        ]
    ; Card.footer
        [ Card.description
            [ text
                "Once your bank is connected, balances over $10.00 are automatically \
                 eligible for monthly distribution on the 15th of each month."
            ]
        ]
    ]
;;

let dismiss label =
  Card.action
    [ Button.view
        ~attrs:[ aria_label label ]
        ~variant:Ghost
        ~size:Icon_sm
        ~class_:"bg-muted"
        [ Icon.view X ]
    ]
;;

let dividend_income =
  let holdings =
    [ "Vanguard", "450 Shares", [ 380.; 420.; 390.; 652. ]
    ; "S&P 500 VOO", "112 Shares", [ 180.; 210.; 320.; 218. ]
    ; "Apple AAPL", "85 Shares", [ 60.; 70.; 120.; 90. ]
    ; "Realty Income", "320 Shares", [ 240.; 260.; 280.; 360. ]
    ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Q2 Dividend Income" ]
        ; Card.description
            [ text "Quarterly dividend payouts across your portfolio holdings." ]
        ; dismiss "Dismiss dividend income"
        ]
    ; Card.content
        [ Item.group
            (List.map holdings ~f:(fun (name, shares, data) ->
               let max = List.fold data ~init:0. ~f:Float.max in
               Item.view
                 ~attrs:[ role "listitem" ]
                 ~variant:Muted
                 [ Item.content
                     [ Item.title [ text name ]; Item.description [ text shares ] ]
                 ; Node.div
                     ~attrs:
                       [ Attr.class_ "hidden h-8 w-24 items-end gap-1 md:flex"
                       ; role "img"
                       ; aria_label (name ^ " quarterly dividends")
                       ]
                     (List.map data ~f:(fun value ->
                        Node.div
                          ~attrs:
                            [ Attr.class_ "min-h-1 flex-1 rounded-t-sm bg-chart-2"
                            ; height_percent value max
                            ]
                          []))
                 ]))
        ]
    ]
;;

let new_milestone =
  Card.root
    [ Card.header
        [ Card.title [ text "Set a new milestone" ]
        ; Card.description
            [ text "Define your financial target and we'll help you pace your savings." ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"home-goal-name" [ text "Goal Name" ]
                ; Input.view
                    ~id:"home-goal-name"
                    ~placeholder:"e.g. New Car, Home Downpayment"
                    ()
                ]
            ; div
                "grid grid-cols-2 gap-3"
                [ Field.root
                    [ Field.label ~for_:"home-target-amount" [ text "Target Amount" ]
                    ; Input.view
                        ~attrs:[ Attr.create "value" "$15,000" ]
                        ~id:"home-target-amount"
                        ()
                    ]
                ; Field.root
                    [ Field.label ~for_:"home-target-date" [ text "Target Date" ]
                    ; Input.view
                        ~attrs:[ Attr.create "value" "Dec 2025" ]
                        ~id:"home-target-date"
                        ()
                    ]
                ]
            ]
        ]
    ; Card.footer
        ~class_:"flex-col gap-2"
        [ Button.view ~class_:"w-full" [ text "Create Goal" ]
        ; Button.view ~variant:Outline ~class_:"w-full" [ text "Cancel" ]
        ]
    ]
;;

let payout_threshold (local_ graph) =
  let currency =
    Native_select.component
      ~id:"home-preferred-currency"
      ~class_:"w-full"
      ~default_value:"usd"
      (List.map
         [ "USD — United States Dollar", "usd"
         ; "EUR — Euro", "eur"
         ; "GBP — British Pound", "gbp"
         ; "JPY — Japanese Yen", "jpy"
         ]
         ~f:(fun (label, value) -> Native_select.option ~value [ text label ]))
      graph
  in
  let%arr currency in
  Card.root
    [ Card.header
        [ Card.title [ text "Payout Threshold" ]
        ; Card.description
            [ text "Set the minimum balance required before a payout is triggered." ]
        ; dismiss "Dismiss payout threshold"
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"home-preferred-currency" [ text "Preferred Currency" ]
                ; currency.view
                ]
            ; Field.root
                [ div
                    "flex items-baseline justify-between"
                    [ Field.label
                        ~attrs:[ Attr.id "home-min-payout-label" ]
                        [ text "Minimum Payout Amount" ]
                    ; span "text-2xl font-semibold tabular-nums" "$2500.00"
                    ]
                ; Progress.view
                    ~attrs:
                      [ Attr.create "aria-labelledby" "home-min-payout-label" ]
                    ~value:25.
                    ()
                ; div
                    "flex items-center justify-between"
                    [ Field.description [ text "$50 (MIN)" ]
                    ; Field.description [ text "$10,000 (MAX)" ]
                    ]
                ]
            ; Field.root
                [ Field.label ~for_:"home-payout-notes" [ text "Notes" ]
                ; Textarea.view
                    ~id:"home-payout-notes"
                    ~placeholder:"Add any notes for this payout configuration..."
                    ~class_:"min-h-[100px]"
                    ()
                ]
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Save Threshold" ] ]
    ]
;;

let account_access =
  Card.root
    [ Card.header
        [ Card.title [ text "Account Access" ]
        ; Card.description [ text "Update your credentials or re-authenticate." ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"home-email-address" [ text "Email Address" ]
                ; Input.view
                    ~id:"home-email-address"
                    ~type_:Email
                    ~placeholder:"artist@studio.inc"
                    ()
                ]
            ; Field.root
                [ div
                    "flex items-center justify-between"
                    [ Field.label ~for_:"home-current-password" [ text "Current Password" ]
                    ; Node.a
                        ~attrs:
                          [ Attr.href "#/"
                          ; Attr.class_
                              "text-xs font-medium tracking-wider text-muted-foreground \
                               uppercase hover:text-foreground"
                          ]
                        [ text "Forgot?" ]
                    ]
                ; Input.view
                    ~id:"home-current-password"
                    ~type_:Password
                    ~placeholder:"••••••••••••••••••••••••"
                    ()
                ]
            ]
        ]
    ; Card.footer
        ~class_:"flex-col gap-4"
        [ Button.view ~class_:"w-full" [ Icon.view Lock; text "Update Security" ]
        ; Item.link
            ~variant:Muted
            ~href:"#/"
            [ Item.media
                ~variant:Icon
                [ Icon.view ~class_:"text-destructive" Circle_alert ]
            ; Item.content
                [ Item.title [ text "Danger Zone" ]
                ; Item.description
                    ~class_:"line-clamp-1"
                    [ text "Archive account and remove catalog" ]
                ]
            ; Icon.view ~class_:"size-4" Chevron_right
            ]
        ]
    ]
;;

let qr_cells =
  [ "111111100101101111111"
  ; "100000101001001000001"
  ; "101110101111101011101"
  ; "101110100100001011101"
  ; "101110101010101011101"
  ; "100000100111001000001"
  ; "111111101010101111111"
  ; "000000001101000000000"
  ; "101011111001111010110"
  ; "010100001110010101001"
  ; "111010111011101111010"
  ; "001101000101000010101"
  ; "110111101111010111011"
  ; "000000001001010001010"
  ; "111111101101111101001"
  ; "100000100010001001111"
  ; "101110101011101110100"
  ; "101110100110100010011"
  ; "101110101000111101110"
  ; "100000101101000011001"
  ; "111111101011101101111"
  ]
;;

let qr_connect =
  let rect attrs = Node.create_svg "rect" ~attrs [] in
  let cells =
    List.concat_mapi qr_cells ~f:(fun y row ->
      List.filter_mapi (String.to_list row) ~f:(fun x cell ->
        if Char.equal cell '1'
        then
          Some
            (rect
               [ Attr.create "x" (Int.to_string x)
               ; Attr.create "y" (Int.to_string y)
               ; Attr.create "width" "1"
               ; Attr.create "height" "1"
               ])
        else None))
  in
  Card.root
    [ Card.content
        ~class_:"flex justify-center pt-6"
        [ div
            "rounded-xl border bg-white p-4"
            [ Node.create_svg
                "svg"
                ~attrs:
                  [ Attr.create "viewBox" "0 0 21 21"
                  ; Attr.class_ "size-40 text-black"
                  ; role "img"
                  ; aria_label "Connect device QR code"
                  ; Attr.create "shape-rendering" "crispEdges"
                  ]
                (rect
                   [ Attr.create "width" "21"
                   ; Attr.create "height" "21"
                   ; Attr.create "fill" "white"
                   ]
                 :: cells)
            ]
        ]
    ; Card.header
        ~class_:"text-center"
        [ Card.title [ text "Scan to connect your mobile device" ]
        ; Card.description
            ~class_:"text-balance"
            [ text "Open the Ledger mobile app and scan this code to link your device." ]
        ]
    ]
;;

let payments (local_ graph) =
  let menu =
    Dropdown_menu.component
      (Bonsai.return (fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Button.view
                ~attrs:[ aria_label "Account options" ]
                ~size:Icon_sm
                ~variant:Ghost
                [ Icon.view Ellipsis; span "sr-only" "Account options" ])
         ; Dropdown_menu.content
             ~align:Start
             menu
             [ Dropdown_menu.group
                 [ Dropdown_menu.item [ text "Profile" ]
                 ; Dropdown_menu.item [ text "Statements" ]
                 ; Dropdown_menu.item [ text "Documents" ]
                 ]
             ]
         ]))
      graph
  in
  let payment icon title description =
    Node.div
      ~attrs:[ role "listitem"; Attr.class_ "w-full" ]
      [ Item.link
          ~variant:Muted
          ~href:"#/"
          [ Item.media ~variant:Icon [ Icon.view icon ]
          ; Item.content
              [ Item.title [ text title ]; Item.description [ text description ] ]
          ; Icon.view ~class_:"size-4 shrink-0 text-muted-foreground" Chevron_right
          ]
      ]
  in
  let%arr menu in
  Card.root
    [ Card.header
        ~class_:"flex flex-col gap-3"
        [ Breadcrumb.root
            [ Breadcrumb.list
                [ Breadcrumb.item [ Breadcrumb.link ~href:"#/" [ text "Home" ] ]
                ; Breadcrumb.separator ()
                ; Breadcrumb.item [ menu ]
                ; Breadcrumb.separator ()
                ; Breadcrumb.item [ Breadcrumb.page [ text "Payments" ] ]
                ]
            ]
        ]
    ; Card.content
        [ Item.group
            [ payment
                Settings
                "Change transfer limit"
                "Adjust how much you can send from your balance."
            ; payment
                Calendar
                "Scheduled transfers"
                "Set up a transfer to send at a later date."
            ; payment
                Refresh_cw
                "Recurring card payments"
                "Manage your repeated card transactions."
            ]
        ]
    ]
;;

let empty_distribute_track =
  Card.root
    [ Card.content
        [ Empty.root
            ~class_:"p-4"
            [ Empty.media ~variant:Icon [ Icon.view Plus ]
            ; Empty.header
                [ Empty.title [ text "Distribute Track" ]
                ; Empty.description
                    [ text
                        "Upload your first master to start reaching listeners on \
                         Spotify, Apple Music, and more."
                    ]
                ]
            ; Empty.content [ Button.view [ text "Create Release" ] ]
            ]
        ]
    ]
;;

(* shadcn's card is [size="sm"] here, whose [data-[size=sm]:pb-0] drops the
   bottom padding under the chart; loon's Card has no sizes, hence [pb-0]. *)
let analytics_card =
  let path attrs = Node.create_svg "path" ~attrs [] in
  Card.root
    ~class_:"mx-auto w-full max-w-sm pb-0"
    [ Card.header
        [ Card.title [ text "Analytics" ]
        ; Card.description [ text "418.2K Visitors "; Badge.view [ text "+10%" ] ]
        ; Card.action [ Button.view ~variant:Outline ~size:Sm [ text "View Analytics" ] ]
        ]
    ; Node.create_svg
        "svg"
        ~attrs:
          [ Attr.create "viewBox" "0 0 100 86"
          ; Attr.create "preserveAspectRatio" "none"
          ; Attr.class_ "aspect-[1/0.35] w-full text-chart-1"
          ; role "img"
          ; aria_label "Visitor trend"
          ]
        [ path
            [ Attr.create "d" "M0 52L18 40L36 46L54 70L72 50L100 49V86H0Z"
            ; Attr.create "fill" "currentColor"
            ; Attr.create "opacity" "0.28"
            ]
        ; path
            [ Attr.create "d" "M0 52L18 40L36 46L54 70L72 50L100 49"
            ; Attr.create "fill" "none"
            ; Attr.create "stroke" "currentColor"
            ; Attr.create "stroke-width" "1.5"
            ; Attr.create "vector-effect" "non-scaling-stroke"
            ]
        ]
    ]
;;

let notification (local_ graph) ~id ~label ~description ~default_checked =
  let id = "home-notify-" ^ id in
  let checkbox = Checkbox.component ~id ~default_checked graph in
  let%arr checkbox in
  Field.root
    ~orientation:Horizontal
    [ checkbox.view
    ; Field.content
        [ Field.label ~for_:id [ text label ]; Field.description [ text description ] ]
    ]
;;

let notification_settings (local_ graph) =
  let transactions =
    notification
      graph
      ~id:"transactions"
      ~label:"Transaction alerts"
      ~description:"Deposits, withdrawals, and transfers."
      ~default_checked:true
  in
  let security =
    notification
      graph
      ~id:"security"
      ~label:"Security alerts"
      ~description:"Login attempts and account changes."
      ~default_checked:true
  in
  let goals =
    notification
      graph
      ~id:"goals"
      ~label:"Goal milestones"
      ~description:"Updates at 25%, 50%, 75%, and 100%."
      ~default_checked:false
  in
  let market =
    notification
      graph
      ~id:"market"
      ~label:"Market updates"
      ~description:"Daily portfolio summary and price alerts."
      ~default_checked:false
  in
  let%arr transactions and security and goals and market in
  Card.root
    [ Card.header
        [ Card.title [ text "Notifications" ]
        ; Card.description
            [ text "Choose which email and push alerts you want to receive." ]
        ]
    ; Card.content [ Field.group [ transactions; security; goals; market ] ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Save Preferences" ] ]
    ]
;;

let power_usage =
  let data =
    [ "6a", 1.2; "8a", 2.8; "10a", 3.1; "12p", 2.4; "2p", 3.4; "4p", 2.9; "6p", 3.8; "8p", 3.2 ]
  in
  let max_usage = List.fold data ~init:0. ~f:(fun m (_, u) -> Float.max m u) in
  let stat label value =
    div
      "flex flex-col gap-0.5"
      [ span "text-sm text-muted-foreground" label
      ; span "text-lg font-semibold tabular-nums" value
      ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Power Usage" ]; Card.description [ text "Whole Home" ] ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ Node.div
            ~attrs:
              [ Attr.class_ "flex h-[140px] w-full items-end gap-2"
              ; role "img"
              ; aria_label "Power usage by hour"
              ]
            (List.map data ~f:(fun (hour, usage) ->
               div
                 "flex h-full flex-1 flex-col justify-end gap-1.5"
                 [ Node.div
                     ~attrs:
                       [ Attr.class_ "min-h-2 rounded-t bg-chart-2"
                       ; height_percent usage max_usage
                       ]
                     []
                 ; span "text-center text-xs text-muted-foreground" hour
                 ]))
        ; Separator.view ()
        ; div
            "grid grid-cols-2 gap-4"
            [ stat "Currently Using" "3.4 kW"; stat "Solar Gen" "+1.2 kW" ]
        ]
    ]
;;

(* shadcn's CardsDemo: columns of example cards on a muted ground, fading
   out at the bottom. *)
let view (local_ graph) =
  let ui_elements = ui_elements graph in
  let payout_threshold = payout_threshold graph in
  let payments = payments graph in
  let notification_settings = notification_settings graph in
  let%arr ui_elements and payout_threshold and payments and notification_settings in
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "demo"
      ; Attr.class_
          "theme-neutral relative flex w-full max-w-none flex-col gap-(--gap) \
           overflow-hidden bg-muted p-12 pb-0! [--gap:--spacing(8)] \
           3xl:[--gap:--spacing(8)] min-[1900px]:p-12 \
           min-[1900px]:[--gap:--spacing(10)]! lg:p-6 lg:[--gap:--spacing(6)] \
           dark:bg-background"
      ]
    [ div
        "relative z-10 mx-auto grid gap-(--gap) **:data-[slot=card]:w-full \
         min-[1400px]:grid-cols-4! min-[1900px]:grid-cols-5! md:max-w-3xl \
         md:grid-cols-2 lg:max-w-none lg:grid-cols-3 xl:max-w-[1600px] \
         2xl:max-w-[1900px]"
        [ div
            "flex flex-col items-start gap-(--gap)"
            [ ui_elements; sidebar_nav; savings_targets ]
        ; div
            "hidden flex-col gap-(--gap) lg:flex"
            [ contribution_history; claimable_balance; dividend_income ]
        ; div
            "hidden flex-col gap-(--gap) min-[1400px]:flex"
            [ new_milestone; payout_threshold; account_access ]
        ; div "hidden flex-col gap-(--gap) md:flex" [ qr_connect; payments ]
        ; div
            "hidden flex-col gap-(--gap) min-[1900px]:flex"
            [ empty_distribute_track; analytics_card; notification_settings; power_usage ]
        ]
    ; div
        "absolute inset-x-0 top-0 z-1 h-120 bg-linear-to-b from-background via-muted \
         to-transparent dark:hidden"
        []
    ; div
        "absolute inset-x-0 bottom-0 z-20 h-48 bg-linear-to-t from-background \
         via-muted/80 to-transparent lg:h-80 xl:h-64 dark:via-background/80"
        []
    ]
;;
