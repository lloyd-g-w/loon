open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
open Create_preview_util
module Node = Vdom.Node
module Attr = Vdom.Attr

let target ~label ~amount ~value ~achieved ~reached =
  Item.view
    ~variant:Muted
    ~class_:"flex-col items-stretch"
    [ Item.content
        ~class_:"gap-3"
        [ Item.description
            ~class_:
              "cn-font-heading text-xs font-medium tracking-wider text-muted-foreground \
               uppercase"
            [ text label ]
        ; tspan "text-3xl font-semibold tabular-nums" amount
        ; Progress.view ~value ()
        ]
    ; Item.footer
        [ tspan "text-sm text-muted-foreground" achieved
        ; tspan "text-sm font-medium tabular-nums" reached
        ]
    ]
;;

let stat label value =
  div
    ~class_:"flex items-center justify-between"
    [ tspan "text-sm text-muted-foreground" label
    ; tspan "text-sm font-semibold tabular-nums" value
    ]
;;

let savings_targets (local_ graph) =
  let order_type =
    Native_select.component
      ~id:"invest-type"
      ~default_value:"market"
      [ Native_select.option ~value:"market" [ text "Market Order" ]
      ; Native_select.option ~value:"limit" [ text "Limit Order" ]
      ; Native_select.option ~value:"stop" [ text "Stop Order" ]
      ]
      graph
  in
  let%arr order_type in
  div
    ~class_:"grid grid-cols-2 gap-(--gap)"
    [ Card.root
        [ Card.header
            [ Card.title [ text "Savings Targets" ]
            ; Card.description [ text "Active milestones for 2024" ]
            ; Card.action [ Button.view ~variant:Outline ~size:Sm [ text "New Goal" ] ]
            ]
        ; Card.content
            [ Item.group
                ~class_:"gap-3"
                [ target
                    ~label:"Retirement"
                    ~amount:"$420,000"
                    ~value:65.
                    ~achieved:"65% achieved"
                    ~reached:"$273,000"
                ; target
                    ~label:"Real Estate"
                    ~amount:"$85,000"
                    ~value:32.
                    ~achieved:"32% achieved"
                    ~reached:"$27,200"
                ]
            ]
        ; Card.footer
            [ Card.description
                ~class_:"text-center"
                [ text "You have not met your targets for this year." ]
            ]
        ]
    ; Card.root
        [ Card.header [ Card.title [ text "Buy Investment" ] ]
        ; Card.content
            ~class_:"flex flex-1 flex-col gap-3"
            [ Field.group
                ~class_:"flex-1"
                [ Field.root
                    [ Field.label ~for_:"invest-amount" [ text "Amount to Invest" ]
                    ; Input_group.root
                        [ Input_group.addon [ Input_group.text [ text "$" ] ]
                        ; Input_group.input
                            ~id:"invest-amount"
                            ~attrs:[ default_value "1,000.00" ]
                            ()
                        ]
                    ]
                ; Field.root
                    [ Field.label ~for_:"invest-type" [ text "Order Type" ]
                    ; order_type.view
                    ; Field.description
                        [ text "Market orders execute at the current price." ]
                    ]
                ; div
                    ~class_:"flex flex-col gap-2"
                    [ stat "Estimated Shares" "1.95"; stat "Buying Power" "$12,450.00" ]
                ]
            ]
        ; Card.footer
            ~class_:"flex-col gap-3"
            [ Button.view ~class_:"w-full" [ text "Review Order" ]
            ; Card.description
                ~class_:"text-center"
                [ text "Trades are typically executed within minutes during market hours."
                ]
            ]
        ]
    ]
;;

let transactions =
  [ Icon.Coffee, "Blue Bottle Coffee", "Food & Drink", "Today, 10:24 AM", "-$6.50", false
  ; Shopping_cart, "Whole Foods Market", "Groceries", "Yesterday", "-$142.30", false
  ; Wallet, "Stripe Payout", "Income", "Oct 12", "+$4,200.00", true
  ; Car, "Uber Technologies", "Transport", "Oct 11", "-$24.10", false
  ; Tv, "Netflix Subscription", "Entertainment", "Oct 10", "-$19.99", false
  ]
;;

let more_button ?sr () =
  Button.view
    ~variant:Ghost
    ~size:Icon_sm
    (icon Ellipsis
     ::
     (match sr with
      | None -> []
      | Some s -> [ tspan "sr-only" s ]))
;;

let recent_transactions (local_ graph) =
  let menus =
    List.map transactions ~f:(fun _ ->
      dropdown
        ~trigger:(more_button ())
        [ Some "View details"; Some "Add note"; Some "Categorize"; None; Some "Dispute" ]
        graph)
    |> Bonsai.all
  in
  let%arr menus in
  Card.root
    [ Card.header
        [ Card.title [ text "Recent Transactions" ]
        ; Card.description [ text "Your latest account activity." ]
        ; Card.action [ Button.view ~variant:Outline ~size:Sm [ text "View All" ] ]
        ]
    ; Card.content
        [ Table.root
            [ Table.body
                (List.map2_exn
                   transactions
                   menus
                   ~f:(fun (i, name, category, date, amount, income) menu ->
                     Table.row
                       [ Table.cell
                           ~class_:"w-10"
                           [ div
                               ~class_:
                                 "flex size-10 items-center justify-center rounded-lg \
                                  bg-muted"
                               [ icon ~class_:"size-4 shrink-0" i ]
                           ]
                       ; Table.cell
                           [ div
                               ~class_:"flex flex-col"
                               [ tspan "font-medium" name
                               ; tspan "text-sm text-muted-foreground" category
                               ]
                           ]
                       ; Table.cell ~class_:"text-sm text-muted-foreground" [ text date ]
                       ; Table.cell
                           ~class_:"text-right"
                           [ (if income
                              then
                                tspan
                                  "text-sm font-semibold text-emerald-500 tabular-nums"
                                  amount
                              else tspan "text-sm font-semibold tabular-nums" amount)
                           ]
                       ; Table.cell ~class_:"w-8" [ menu ]
                       ]))
            ]
        ]
    ]
;;

let sidebar_state =
  Sidebar.create
    ~persist:false
    ~open_:true
    ~on_open_change:(fun _ -> Effect.Ignore)
    ~open_mobile:false
    ~on_open_mobile_change:(fun _ -> Effect.Ignore)
    ~is_mobile:false
    ()
;;

let nav_card groups =
  let group (class_, label, items) =
    Sidebar.group
      ~class_
      [ Sidebar.group_label [ text label ]
      ; Sidebar.group_content
          [ Sidebar.menu
              (List.map items ~f:(fun (i, label, is_active) ->
                 Sidebar.menu_item
                   [ Sidebar.menu_button ~is_active [ icon i; text label ] ]))
          ]
      ]
  in
  let top, bottom = groups in
  Card.root
    ~class_:"overflow-hidden py-0"
    [ Sidebar.provider
        ~keyboard_shortcut:false
        ~class_:"min-h-0"
        sidebar_state
        [ Sidebar.root
            ~collapsible:None
            ~class_:"w-full bg-transparent"
            sidebar_state
            [ Sidebar.content
                ~class_:"gap-0"
                [ group ("pb-1", fst top, snd top)
                ; Sidebar.separator ~class_:"w-auto!" ()
                ; group ("pt-1", fst bottom, snd bottom)
                ]
            ]
        ]
    ]
;;

let sidebar_nav =
  static
    (div
       ~class_:"grid grid-cols-2 items-start gap-6"
       [ nav_card
           ( ( "Overview"
             , [ Icon.Layout_dashboard, "Dashboard", true
               ; Arrow_left_right, "Transactions", false
               ; Trending_up, "Investments", false
               ; Building_2, "Accounts", false
               ; Chart_pie, "Spending", false
               ] )
           , ( "Planning"
             , [ Icon.Target, "Goals", false
               ; Wallet, "Budget", false
               ; File_chart_column_increasing, "Reports", false
               ; File_text, "Documents", false
               ] ) )
       ; nav_card
           ( ( "Account"
             , [ Icon.User, "Profile", false
               ; Credit_card, "Billing", true
               ; Bell, "Notifications", false
               ; Shield, "Security", false
               ; Paintbrush, "Appearance", false
               ] )
           , ( "Support"
             , [ Icon.Circle_help, "Help Center", false
               ; Message_square, "Contact Us", false
               ; Book_open, "Documentation", false
               ; Activity, "Status", false
               ] ) )
       ])
;;

let general_questions =
  [ ( "How secure is my financial data with Ledger?"
    , "We use bank-level AES-256 encryption, SOC 2 Type II certified infrastructure, and \
       never store your credentials. All connections use read-only access tokens. We are \
       a SEC registered investment advisor." )
  ; ( "How do I connect my bank or investment accounts?"
    , "Go to Settings > Linked Accounts and search for your institution. We support over \
       12,000 banks and brokerages via Plaid and MX." )
  ; ( "Can I export my data for tax purposes?"
    , "Yes. Navigate to Reports > Tax Export to download a CSV or PDF summary of your \
       transactions, dividends, and capital gains for any tax year." )
  ]
;;

let billing_questions =
  [ ( "What is the difference between Basic and Pro pricing tiers?"
    , "Basic includes budgeting, goal tracking, and up to 3 linked accounts. Pro adds \
       unlimited accounts, dividend tracking, portfolio analysis, and priority support." )
  ; ( "How do I cancel my subscription?"
    , "Go to Settings > Billing > Manage Plan and click Cancel. Your access continues \
       until the end of your current billing period." )
  ; ( "Do you offer a free trial?"
    , "Yes. All new accounts start with a 14-day Pro trial. No credit card required." )
  ]
;;

let goals_questions =
  [ ( "How do I set up a custom financial goal?"
    , "Click New Goal from the Savings Targets card. Choose a category, set a target \
       amount and date, and we'll calculate the monthly contribution needed." )
  ; ( "Can I track multiple goals at once?"
    , "Yes. Pro accounts can track unlimited goals. Basic accounts support up to 3 \
       active goals." )
  ; ( "How are monthly contributions calculated?"
    , "We divide the remaining amount by the number of months until your target date, \
       adjusted for your current savings rate and any auto-transfer schedules." )
  ]
;;

let question_list questions (local_ graph) =
  Accordion.component
    ~type_:Single
    ~collapsible:true
    ~default_value:[ "item-0" ]
    (Bonsai.return (fun acc ->
       List.mapi questions ~f:(fun index (q, a) ->
         Accordion.item
           acc
           ~value:(sprintf "item-%d" index)
           [ Accordion.trigger [ text q ]; Accordion.content [ text a ] ])))
    graph
;;

let faq (local_ graph) =
  let general = question_list general_questions graph in
  let billing = question_list billing_questions graph in
  let goals = question_list goals_questions graph in
  let tabs =
    Tabs.component
      ~default_value:"general"
      (let%arr general
       and billing
       and goals in
       fun tabs ->
         [ Tabs.list
             ~class_:"w-full"
             tabs
             [ Tabs.trigger ~value:"general" ~class_:"flex-1" [ text "General" ]
             ; Tabs.trigger ~value:"billing" ~class_:"flex-1" [ text "Billing" ]
             ; Tabs.trigger ~value:"goals" ~class_:"flex-1" [ text "Goals" ]
             ]
         ; Tabs.content tabs ~value:"general" [ general ]
         ; Tabs.content tabs ~value:"billing" [ billing ]
         ; Tabs.content tabs ~value:"goals" [ goals ]
         ])
      graph
  in
  let%arr tabs in
  (* The style's card clips (Vega's [overflow-hidden]): the footer's two
     [w-full] buttons overflow it. *)
  Card.root
    ~class_:"overflow-hidden"
    [ Card.content [ tabs ]
    ; Card.footer
        [ Button.view ~variant:Outline ~class_:"w-full" [ text "Contact Support" ]
        ; Button.view ~variant:Link ~class_:"w-full" [ text "Learn More" ]
        ]
    ]
;;

let payment_link i title description =
  Item.link
    ~variant:Muted
    ~href:"#"
    [ Item.media ~variant:Icon [ icon i ]
    ; Item.content [ Item.title [ text title ]; Item.description [ text description ] ]
    ; icon ~class_:"size-4 shrink-0 text-muted-foreground" Chevron_right
    ]
;;

let payments (local_ graph) =
  let menu =
    dropdown
      ~align:Start
      ~group:true
      ~trigger:(more_button ~sr:"Account options" ())
      [ Some "Profile"; Some "Statements"; Some "Documents" ]
      graph
  in
  let%arr menu in
  Card.root
    [ Card.header
        ~class_:"flex flex-col gap-3"
        [ Breadcrumb.root
            [ Breadcrumb.list
                [ Breadcrumb.item [ Breadcrumb.link ~href:"#" [ text "Home" ] ]
                ; Breadcrumb.separator ()
                ; Breadcrumb.item [ menu ]
                ; Breadcrumb.separator ()
                ; Breadcrumb.item [ Breadcrumb.page [ text "Payments" ] ]
                ]
            ]
        ]
    ; Card.content
        [ Item.group
            [ payment_link
                Gauge
                "Change transfer limit"
                "Adjust how much you can send from your balance."
            ; payment_link
                Calendar
                "Scheduled transfers"
                "Set up a transfer to send at a later date."
            ; payment_link Repeat "Direct Debits" "Set up and manage regular payments."
            ; payment_link
                Refresh_cw
                "Recurring card payments"
                "Manage your repeated card transactions."
            ]
        ]
    ]
;;

let front_door =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Front Door" ]
           ; Card.description [ text "Smart Lock Pro" ]
           ; Card.action
               [ div
                   ~class_:"flex items-center gap-1.5 text-sm text-muted-foreground"
                   [ text "Locked"; icon ~class_:"size-4" Lock ]
               ]
           ]
       ; Card.content
           [ div
               ~class_:
                 "relative flex aspect-video items-center justify-center overflow-hidden \
                  rounded-lg bg-muted \
                  bg-[repeating-linear-gradient(45deg,transparent,transparent_10px,var(--border)_10px,var(--border)_11px)]"
               [ Badge.view
                   ~variant:Destructive
                   ~class_:"absolute top-2 right-2"
                   [ text "Live" ]
               ]
           ]
       ])
;;

let release_holdings =
  [ "VOO", "Vanguard S&P 500 ETF", "ETF", "Jan 2021", "112", "$48,230.40"
  ; "VIG", "Vanguard Dividend Appreciation", "ETF", "Mar 2022", "450", "$26,033.79"
  ; "AAPL", "Apple Inc.", "Stock", "Nov 2020", "85", "$18,488.90"
  ; "O", "Realty Income Corp", "REIT", "Jun 2023", "320", "$15,136.59"
  ]
;;

let release_catalog (local_ graph) =
  let toggle =
    Toggle_group.single_component
      ~default_value:"etfs"
      ~variant:Outline
      ~spacing:1
      (Bonsai.return (fun group ->
         [ Toggle_group.item group ~value:"stocks" [ text "Stocks" ]
         ; Toggle_group.item group ~value:"etfs" [ text "ETFs" ]
         ; Toggle_group.item group ~value:"reits" [ text "REITs" ]
         ]))
      graph
  in
  let%arr toggle in
  Card.root
    [ Card.header
        [ div
            ~class_:"flex items-center justify-between gap-3"
            [ Input_group.root
                ~class_:"max-w-sm"
                [ Input_group.addon [ icon Search ]
                ; Input_group.input ~placeholder:"Search holdings or tickers..." ()
                ]
            ; toggle.view
            ]
        ]
    ; Card.content
        [ Item.group
            (List.map
               release_holdings
               ~f:(fun (ticker, name, type_, added, shares, value) ->
                 Item.view
                   ~variant:Muted
                   [ Item.media
                       [ div
                           ~class_:
                             "flex size-12 items-center justify-center rounded-lg border \
                              text-sm font-semibold"
                           [ text ticker ]
                       ]
                   ; Item.content
                       [ Item.title [ text name ]
                       ; Item.description
                           ~class_:"text-xs tracking-wider uppercase"
                           [ text (sprintf "%s Shares · %s" shares added) ]
                       ]
                   ; div
                       ~class_:"flex shrink-0 items-center gap-6"
                       [ Badge.view ~variant:Outline [ text type_ ]
                       ; div
                           ~class_:"flex flex-col items-end gap-0.5"
                           [ tspan
                               "text-xs tracking-wider text-muted-foreground uppercase"
                               "Value"
                           ; tspan "font-medium tabular-nums" value
                           ]
                       ]
                   ]))
        ]
    ]
;;
