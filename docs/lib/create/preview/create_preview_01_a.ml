open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
open Create_preview_util
module Node = Vdom.Node
module Attr = Vdom.Attr

module Info = struct
  type t =
    { style : string
    ; font : string
    ; font_heading : string
    }

  let default = { style = "New York"; font = "Geist"; font_heading = "Geist" }
end

let style_overview (info : Info.t Bonsai.t) (local_ _graph) =
  let%arr info in
  let swatch variant =
    div
      ~class_:"flex flex-col flex-wrap items-center gap-2"
      [ div
          ~class_:
            "relative aspect-square w-full rounded-lg bg-(--color) after:absolute \
             after:inset-0 after:rounded-lg after:border after:border-border \
             after:mix-blend-darken dark:after:mix-blend-lighten style-sera:rounded-none \
             style-sera:after:rounded-none"
          ~attrs:[ Attr.create "style" (sprintf "--color: var(%s)" variant) ]
          []
      ; div
          ~class_:
            "hidden max-w-14 truncate font-mono text-[0.60rem] md:block \
             style-lyra:max-w-10 style-mira:max-w-10"
          [ text variant ]
      ]
  in
  Card.root
    [ Card.content
        ~class_:"flex flex-col gap-6 style-lyra:gap-4 style-mira:gap-4"
        [ div
            ~class_:"flex flex-col gap-1"
            [ div
                ~class_:
                  "cn-font-heading text-2xl font-medium style-lyra:text-lg \
                   style-mira:text-lg style-sera:text-lg style-sera:font-semibold \
                   style-sera:tracking-wide style-sera:uppercase"
                [ text
                    (sprintf
                       "%s - %s"
                       info.style
                       (if String.equal info.font_heading info.font
                        then info.font
                        else info.font_heading))
                ]
            ; div
                ~class_:
                  "line-clamp-2 text-base text-muted-foreground style-lyra:text-sm \
                   style-mira:text-sm style-sera:text-sm style-sera:leading-relaxed"
                [ text
                    "Designers love packing quirky glyphs into test phrases. This is a \
                     preview of the typography styles."
                ]
            ]
        ; div
            ~class_:"grid grid-cols-6 gap-3"
            (List.map
               ~f:swatch
               [ "--background"
               ; "--foreground"
               ; "--primary"
               ; "--secondary"
               ; "--muted"
               ; "--accent"
               ; "--border"
               ; "--chart-1"
               ; "--chart-2"
               ; "--chart-3"
               ; "--chart-4"
               ; "--chart-5"
               ])
        ]
    ]
;;

let typography_specimen (info : Info.t Bonsai.t) (local_ graph) =
  let category =
    select
      ~id:"feedback-category"
      ~class_:"w-full"
      ~default_value:"general"
      [ "general", "General"
      ; "bug", "Bug Report"
      ; "feature", "Feature Request"
      ; "improvement", "Improvement"
      ]
      graph
  in
  let dialog =
    Dialog.component
      (let%arr category in
       fun d ->
         [ Dialog.trigger
             d
             (Button.view ~variant:Outline ~class_:"w-full" [ text "Share Feedback" ])
         ; Dialog.content
             d
             [ Dialog.header
                 [ Dialog.title d [ text "Share Feedback" ]
                 ; Dialog.description
                     d
                     [ text "Let us know how we can improve your experience." ]
                 ]
             ; Field.group
                 [ div
                     ~class_:"grid grid-cols-2 gap-3"
                     [ Field.root
                         [ Field.label ~for_:"feedback-name" [ text "Name" ]
                         ; Input.view ~id:"feedback-name" ~placeholder:"Your name" ()
                         ]
                     ; Field.root
                         [ Field.label ~for_:"feedback-email" [ text "Email" ]
                         ; Input.view
                             ~id:"feedback-email"
                             ~type_:Email
                             ~placeholder:"you@example.com"
                             ()
                         ]
                     ]
                 ; Field.root
                     [ Field.label
                         ~for_:(select_trigger_id "feedback-category")
                         [ text "Category" ]
                     ; category
                     ]
                 ; Field.root
                     [ Field.label ~for_:"feedback-message" [ text "Message" ]
                     ; Textarea.view
                         ~id:"feedback-message"
                         ~placeholder:"Tell us what's on your mind..."
                         ~class_:"min-h-24 resize-none"
                         ()
                     ]
                 ]
             ; Dialog.footer
                 [ Dialog.close d (Button.view ~variant:Outline [ text "Cancel" ])
                 ; Button.view [ text "Submit" ]
                 ]
             ]
         ])
      graph
  in
  let%arr info
  and dialog in
  let heading_label =
    if String.equal info.font_heading info.font then "Inherit" else info.font_heading
  in
  Card.root
    [ Card.content
        ~class_:"flex flex-col gap-2"
        [ div
            ~class_:"text-xs font-medium text-muted-foreground uppercase"
            [ text (sprintf "%s - %s" heading_label info.font) ]
        ; el
            "p"
            ~class_:
              "cn-font-heading text-2xl font-medium style-sera:text-lg \
               style-sera:font-semibold style-sera:tracking-wider style-sera:uppercase"
            [ text "Designing with rhythm and hierarchy." ]
        ; el
            "p"
            ~class_:"text-sm leading-relaxed text-muted-foreground"
            [ text
                "A strong body style keeps long-form content readable and balances the \
                 visual weight of headings."
            ]
        ; el
            "p"
            ~class_:"text-sm leading-relaxed text-muted-foreground"
            [ text
                "Thoughtful spacing and cadence help paragraphs scan quickly without \
                 feeling dense."
            ]
        ]
    ; Card.footer [ dialog ]
    ]
;;

let ui_elements (local_ graph) =
  let slider =
    Slider.component
      ~max:1000.
      ~min:0.
      ~step:10.
      ~class_:"flex-1"
      ~attrs:[ Attr.create "aria-label" "Slider" ]
      ~default_value:[ 500. ]
      graph
  in
  let radio =
    Radio_group.component
      ~default_value:"apple"
      ~class_:"ml-auto flex w-fit gap-3"
      (Bonsai.return (fun g ->
         [ Radio_group.item g ~value:"apple"; Radio_group.item g ~value:"banana" ]))
      graph
  in
  let check1 = Checkbox.component ~default_checked:true graph in
  let check2 = Checkbox.component graph in
  let switch = Switch.component ~default_checked:true ~class_:"ml-auto" graph in
  let alert =
    Alert_dialog.component
      (Bonsai.return (fun d ->
         [ Alert_dialog.trigger
             d
             (Button.view
                ~variant:Outline
                [ span
                    ~class_:"hidden md:flex style-sera:md:hidden"
                    [ text "Alert Dialog" ]
                ; span ~class_:"flex md:hidden style-sera:md:flex" [ text "Dialog" ]
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
      (Bonsai.return (fun m ->
         let item s = Dropdown_menu.item [ text s ] in
         [ Dropdown_menu.trigger
             m
             (Button.view ~variant:Outline ~size:Icon [ icon Chevron_up ])
         ; Dropdown_menu.content
             m
             ~align:End
             ~side:Top
             ~class_:"w-fit"
             [ Dropdown_menu.group
                 [ Dropdown_menu.label [ text "Quick Actions" ]
                 ; item "Mute Conversation"
                 ; item "Mark as Read"
                 ; item "Block User"
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.label [ text "Conversation" ]
                 ; item "Share Conversation"
                 ; item "Copy Conversation"
                 ; item "Report Conversation"
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item ~variant:Destructive [ text "Delete Conversation" ]
                 ]
             ]
         ]))
      graph
  in
  let%arr slider
  and radio
  and check1
  and check2
  and switch
  and alert
  and menu in
  Card.root
    ~class_:"w-full"
    [ Card.content
        ~class_:"flex flex-col gap-6"
        [ div
            ~class_:"flex flex-col gap-4"
            [ div
                ~class_:"flex flex-wrap gap-2"
                [ Button.view [ text "Button" ]
                ; Button.view ~variant:Secondary [ text "Secondary" ]
                ; Button.view ~variant:Outline [ text "Outline" ]
                ; Button.view ~variant:Ghost [ text "Ghost" ]
                ]
            ; Item.view
                ~variant:Outline
                [ Item.content
                    [ Item.title [ text "Two-factor authentication" ]
                    ; Item.description
                        ~class_:"text-pretty xl:hidden 2xl:block"
                        [ text "Verify via email or phone number." ]
                    ]
                ; Item.actions
                    ~class_:"hidden md:flex"
                    [ Button.view ~size:Sm ~variant:Secondary [ text "Enable" ] ]
                ]
            ]
        ; slider.view
        ; Field.group
            [ Field.root
                [ Input_group.root
                    [ Input_group.input ~placeholder:"Name" ()
                    ; Input_group.addon
                        ~align:Inline_end
                        [ Input_group.text [ icon Search ] ]
                    ]
                ]
            ; Field.root
                ~class_:"flex-1"
                [ Textarea.view ~placeholder:"Message" ~class_:"resize-none" () ]
            ]
        ; div
            ~class_:"flex items-center gap-2"
            [ div
                ~class_:"flex gap-2"
                [ Badge.view [ text "Badge" ]
                ; Badge.view ~variant:Secondary [ text "Secondary" ]
                ; Badge.view ~variant:Outline [ text "Outline" ]
                ]
            ; radio.view
            ; div ~class_:"flex gap-3" [ check1.view; check2.view ]
            ]
        ; div
            ~class_:"flex items-center gap-4"
            [ alert
            ; Button_group.root
                [ Button.view
                    ~variant:Outline
                    [ span ~class_:"style-sera:hidden" [ text "Button Group" ]
                    ; span ~class_:"hidden style-sera:block" [ text "Group" ]
                    ]
                ; menu
                ]
            ; switch.view
            ]
        ]
    ]
;;

let icon_preview_grid =
  static
    (Card.root
       [ Card.content
           [ div
               ~class_:"grid grid-cols-8 place-items-center gap-4"
               (List.map
                  [ Icon.Copy
                  ; Circle_exclamation_point
                  ; Trash
                  ; Share
                  ; Shopping_bag
                  ; Ellipsis
                  ; Loader_circle
                  ; Plus
                  ; Minus
                  ; Arrow_left
                  ; Arrow_right
                  ; Check
                  ; Chevron_down
                  ; Chevron_right
                  ; Search
                  ; Settings
                  ]
                  ~f:(fun i ->
                    div
                      ~class_:
                        "flex size-8 items-center justify-center rounded-md ring \
                         ring-border style-sera:rounded-none *:[svg]:size-4"
                      [ icon i ]))
           ]
       ])
;;

let copy_url ~id ~label ~url ~description =
  Field.root
    ~class_:"gap-2"
    [ Field.label ~for_:id ~class_:"sr-only" [ text label ]
    ; Input_group.root
        [ Input_group.addon
            ~align:Inline_end
            [ Input_group.button ~variant:Ghost ~size:Icon_xs [ icon Copy ] ]
        ; Input_group.input ~id ~attrs:[ default_value url; Attr.create "readonly" "" ] ()
        ]
    ; Field.description description
    ]
;;

let codespaces_card (local_ graph) =
  let creating, set_creating = Bonsai.state false graph in
  let add_tooltip =
    Tooltip.component
      (Bonsai.return (fun t ->
         [ Tooltip.trigger t (Button.view ~variant:Ghost ~size:Icon_sm [ icon Plus ])
         ; Tooltip.content ~side:Bottom t [ text "Create a codespace on main" ]
         ]))
      graph
  in
  let menu =
    Dropdown_menu.component
      (Bonsai.return (fun m ->
         let item i s = Dropdown_menu.item [ icon i; text s ] in
         [ Dropdown_menu.trigger
             m
             (Button.view ~variant:Ghost ~size:Icon_sm [ icon Ellipsis ])
         ; Dropdown_menu.content
             m
             ~align:End
             ~class_:"w-56"
             [ Dropdown_menu.group
                 [ item Plus "New with options..."
                 ; item Container "Configure container"
                 ; item Zap "Set up prebuilds"
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ item Server "Manage codespaces"
                 ; item Share "Share deep link"
                 ; item Info "What are codespaces?"
                 ]
             ]
         ]))
      graph
  in
  let info_tooltip =
    Tooltip.component
      (Bonsai.return (fun t ->
         [ Tooltip.trigger t (Button.view ~variant:Ghost ~size:Icon [ icon Info ])
         ; Tooltip.content ~side:Left t [ text "Which remote URL should I use?" ]
         ]))
      graph
  in
  let clone_tabs =
    Tabs.component
      ~default_value:"https"
      (Bonsai.return (fun t ->
         [ Tabs.list
             ~variant:Line
             ~class_:"w-full justify-start border-b *:[button]:flex-0"
             t
             [ Tabs.trigger ~value:"https" [ text "HTTPS" ]
             ; Tabs.trigger ~value:"ssh" [ text "SSH" ]
             ; Tabs.trigger ~value:"cli" [ text "GitHub CLI" ]
             ]
         ; div
             ~class_:"rounded-md border bg-muted/30 p-2"
             [ Tabs.content
                 t
                 ~value:"https"
                 [ copy_url
                     ~id:"https-url"
                     ~label:"HTTPS URL"
                     ~url:"https://github.com/shadcn-ui/ui.git"
                     ~description:[ text "Clone using the web URL." ]
                 ]
             ; Tabs.content
                 t
                 ~value:"ssh"
                 [ copy_url
                     ~id:"ssh-url"
                     ~label:"SSH URL"
                     ~url:"git@github.com:shadcn-ui/ui.git"
                     ~description:[ text "Use a password-protected SSH key." ]
                 ]
             ; Tabs.content
                 t
                 ~value:"cli"
                 [ copy_url
                     ~id:"cli-command"
                     ~label:"CLI Command"
                     ~url:"gh repo clone shadcn-ui/ui"
                     ~description:
                       [ text "Work fast with our official CLI. "
                       ; Node.a ~attrs:[ Attr.href "#learn-more" ] [ text "Learn more" ]
                       ]
                 ]
             ]
         ]))
      graph
  in
  let tabs =
    let%arr creating
    and set_creating
    and add_tooltip
    and menu
    and info_tooltip
    and clone_tabs in
    let separator () = Separator.view ~class_:"-mx-2 my-2 w-auto!" () in
    fun t ->
      [ Tabs.list
          ~class_:"w-full"
          t
          [ Tabs.trigger ~value:"codespaces" [ text "Codespaces" ]
          ; Tabs.trigger ~value:"local" [ text "Local" ]
          ]
      ; Tabs.content
          t
          ~value:"codespaces"
          [ Item.view
              ~size:Sm
              ~class_:"px-1 pt-2"
              [ Item.content
                  [ Item.title [ text "Codespaces" ]
                  ; Item.description [ text "Your workspaces in the cloud" ]
                  ]
              ; Item.actions [ add_tooltip; menu ]
              ]
          ; separator ()
          ; Empty.root
              ~class_:"p-4"
              [ Empty.header
                  [ Empty.media ~variant:Icon [ icon Server ]
                  ; Empty.title [ text "No codespaces" ]
                  ; Empty.description
                      [ text
                          "You don't have any codespaces with this repository checked out"
                      ]
                  ]
              ; Empty.content
                  [ Button.view
                      ~size:Sm
                      ~disabled:creating
                      ~on_click:
                        (* shadcn resets it after 2s; here a second click does. *)
                        (set_creating true)
                      ((if creating
                        then
                          [ Spinner.view
                              ~attrs:[ Attr.create "data-icon" "inline-start" ]
                              ()
                          ]
                        else [])
                       @ [ text "Create Codespace" ])
                  ; Node.a
                      ~attrs:
                        [ Attr.href "#learn-more"
                        ; Attr.class_
                            "text-xs text-muted-foreground underline underline-offset-4"
                        ]
                      [ text "Learn more about codespaces" ]
                  ]
              ]
          ; separator ()
          ; div
              ~class_:"p-1.5 text-xs text-muted-foreground"
              [ text "Codespace usage for this repository is paid for by "
              ; tspan "font-medium" "shadcn"
              ; text "."
              ]
          ]
      ; Tabs.content
          t
          ~value:"local"
          [ Item.view
              ~size:Sm
              ~class_:"hidden p-0"
              [ Item.content
                  [ Item.title
                      ~class_:"gap-2"
                      [ icon ~class_:"size-4" Terminal; text "Clone" ]
                  ]
              ; Item.actions [ info_tooltip ]
              ]
          ; clone_tabs
          ; separator ()
          ; div
              ~class_:"flex flex-col"
              [ Button.view
                  ~variant:Ghost
                  ~size:Sm
                  ~class_:"justify-start gap-1.5"
                  [ Icon.view ~attrs:[ Attr.create "data-icon" "inline-start" ] Monitor
                  ; text "Open with GitHub Desktop"
                  ]
              ; Button.view
                  ~variant:Ghost
                  ~size:Sm
                  ~class_:"justify-start gap-1.5"
                  [ Icon.view ~attrs:[ Attr.create "data-icon" "inline-start" ] Download
                  ; text "Download ZIP"
                  ]
              ]
          ]
      ]
  in
  let tabs = Tabs.component ~default_value:"codespaces" tabs graph in
  let%arr tabs in
  Card.root [ Card.content [ tabs ] ]
;;

let invoice =
  let items =
    [ "Design System License", 1, 499
    ; "Priority Support", 12, 99
    ; "Custom Components", 3, 250
    ]
  in
  let currency v = "$" ^ Int.to_string_hum ~delimiter:',' v ^ ".00" in
  let subtotal = List.sum (module Int) items ~f:(fun (_, q, p) -> q * p) in
  let total_row label value =
    Table.row
      [ Table.cell ~col_span:3 ~class_:"text-right" [ text label ]
      ; Table.cell ~class_:"text-right tabular-nums" [ text value ]
      ]
  in
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Invoice #INV-2847" ]
           ; Card.description [ text "Due March 30, 2026" ]
           ; Card.action [ Badge.view ~variant:Secondary [ text "Pending" ] ]
           ]
       ; Card.content
           [ Table.root
               [ Table.header
                   [ Table.row
                       [ Table.head [ text "Item" ]
                       ; Table.head ~class_:"text-right" [ text "Qty" ]
                       ; Table.head ~class_:"text-right" [ text "Rate" ]
                       ; Table.head ~class_:"text-right" [ text "Amount" ]
                       ]
                   ]
               ; Table.body
                   (List.map items ~f:(fun (item, qty, price) ->
                      Table.row
                        [ Table.cell [ text item ]
                        ; Table.cell
                            ~class_:"text-right tabular-nums"
                            [ text (Int.to_string qty) ]
                        ; Table.cell
                            ~class_:"text-right tabular-nums"
                            [ text (currency price) ]
                        ; Table.cell
                            ~class_:"text-right tabular-nums"
                            [ text (currency (qty * price)) ]
                        ])
                    @ [ total_row "Subtotal" (currency subtotal)
                      ; total_row "Tax" "$0.00"
                      ; total_row "Total Due" (currency subtotal)
                      ])
               ]
           ]
       ; Card.footer
           [ Button.view ~variant:Outline ~size:Sm [ text "Download PDF" ]
           ; Button.view ~size:Sm ~class_:"ml-auto" [ text "Pay Now" ]
           ]
       ])
;;

(* shadcn shows an Unsplash photo; the docs load nothing remote, so a muted
   block of the same size stands in. *)
let observability_card =
  static
    (Card.root
       ~class_:"relative w-full max-w-md overflow-hidden pt-0"
       [ div
           ~class_:
             "absolute inset-0 z-30 aspect-video bg-primary opacity-50 mix-blend-color"
           []
       ; div
           ~class_:
             "relative z-20 aspect-video w-full bg-linear-to-br from-muted-foreground \
              to-foreground brightness-60 grayscale"
           ~attrs:[ Attr.title "Photo by mymind on Unsplash" ]
           []
       ; Card.header
           [ Card.title [ text "Observability Plus is replacing Monitoring" ]
           ; Card.description
               [ text
                   "Switch to the improved way to explore your data, with natural \
                    language. Monitoring will no longer be available on the Pro plan in \
                    November, 2025"
               ]
           ]
       ; Card.footer
           [ Button.view
               [ text "Create Query "
               ; Icon.view ~attrs:[ Attr.create "data-icon" "inline-end" ] Plus
               ]
           ; Badge.view ~variant:Secondary ~class_:"ml-auto" [ text "Warning" ]
           ]
       ])
;;

let shipping_address (local_ graph) =
  let state =
    select
      ~id:"shipping-state"
      ~class_:"w-full"
      ~default_value:"CA"
      [ "CA", "California"; "NY", "New York"; "TX", "Texas" ]
      graph
  in
  let country =
    select
      ~id:"shipping-country"
      ~class_:"w-full"
      ~default_value:"US"
      [ "US", "United States"; "CA", "Canada"; "UK", "United Kingdom" ]
      graph
  in
  let save = Checkbox.component ~id:"shipping-save" ~default_checked:true graph in
  let%arr state
  and country
  and save in
  let input ~id ~label ~placeholder =
    Field.root [ Field.label ~for_:id [ text label ]; Input.view ~id ~placeholder () ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Shipping Address" ]
        ; Card.description [ text "Where should we deliver?" ]
        ]
    ; Card.content
        [ Field.group
            [ input
                ~id:"shipping-street"
                ~label:"Street address"
                ~placeholder:"123 Main Street"
            ; input ~id:"shipping-apt" ~label:"Apt / Suite" ~placeholder:"Apt 4B"
            ; Field.group
                ~class_:"grid grid-cols-2"
                [ input ~id:"shipping-city" ~label:"City" ~placeholder:"San Francisco"
                ; Field.root
                    [ Field.label
                        ~for_:(select_trigger_id "shipping-state")
                        [ text "State" ]
                    ; state
                    ]
                ]
            ; Field.group
                ~class_:"grid grid-cols-2"
                [ input ~id:"shipping-zip" ~label:"ZIP Code" ~placeholder:"94102"
                ; Field.root
                    [ Field.label
                        ~for_:(select_trigger_id "shipping-country")
                        [ text "Country" ]
                    ; country
                    ]
                ]
            ; Field.root
                ~orientation:Horizontal
                [ save.view
                ; Field.label
                    ~for_:"shipping-save"
                    ~class_:"font-normal"
                    [ text "Save as default address" ]
                ]
            ]
        ]
    ; Card.footer
        [ Button.view ~variant:Outline ~size:Sm [ text "Cancel" ]
        ; Button.view ~size:Sm ~class_:"ml-auto" [ text "Save Address" ]
        ]
    ]
;;

let environment_variables =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Environment Variables" ]
           ; Card.description [ text "Production · 8 variables" ]
           ]
       ; Card.content
           ~class_:"flex flex-col gap-2"
           (List.map
              [ "DATABASE_URL", true; "NEXT_PUBLIC_API", false; "STRIPE_SECRET", true ]
              ~f:(fun (key, masked) ->
                div
                  ~class_:
                    "flex items-center gap-2 rounded-md px-2.5 py-2 font-mono text-xs \
                     ring ring-border"
                  [ tspan "font-medium" key
                  ; tspan
                      "ml-auto text-muted-foreground"
                      (if masked then "••••••••" else "https://api.example.com")
                  ]))
       ; Card.footer
           [ Button.view ~variant:Outline [ text "Edit" ]
           ; Button.view ~class_:"ml-auto" [ text "Deploy" ]
           ]
       ])
;;

let bar_chart_card (local_ graph) =
  let chart = chart graph in
  let data =
    [ "January", 186., 80.
    ; "February", 305., 200.
    ; "March", 237., 120.
    ; "April", 73., 190.
    ; "May", 209., 130.
    ; "June", 214., 140.
    ]
  in
  let desktop = List.sum (module Float) data ~f:(fun (_, d, _) -> d) in
  let mobile = List.sum (module Float) data ~f:(fun (_, _, m) -> m) in
  let delta = Float.iround_nearest_exn ((desktop -. mobile) /. mobile *. 100.) in
  let%arr chart in
  let config =
    [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
    ; "mobile", Chart.Config.item ~label:"Mobile" ~color:"var(--chart-2)" ()
    ]
  in
  let stat label value =
    div
      ~class_:"px-2 text-center"
      [ div ~class_:"text-[0.65rem] text-muted-foreground uppercase" [ text label ]
      ; div ~class_:"text-sm font-medium tabular-nums" [ text value ]
      ]
  in
  let hum f = Int.to_string_hum ~delimiter:',' (Float.iround_nearest_exn f) in
  Card.root
    [ Card.header
        [ Card.title ~class_:"text-lg" [ text "Traffic channels" ]
        ; Card.description
            ~class_:"line-clamp-2 text-sm leading-snug"
            [ text
                "Monthly desktop and mobile traffic for the last six months—compare \
                 volume and mix across platforms and devices at a glance."
            ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4 pt-0"
        [ Chart.container
            ~config
            ~class_:"max-h-[180px] w-full"
            chart
            (Chart.bar_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:8. ~bottom:0. ())
               ~data:
                 (List.map data ~f:(fun (m, d, mo) ->
                    [ "month", `Text m; "desktop", `Num d; "mobile", `Num mo ]))
               [ Chart.cartesian_grid ~vertical:false ~stroke_dasharray:"3 3" ()
               ; Chart.x_axis
                   ~data_key:"month"
                   ~tick_line:false
                   ~tick_margin:8.
                   ~axis_line:false
                   ~tick_formatter:(fun v -> String.prefix v 3)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Dashed ())
                   ()
               ; Chart.legend ~content:(Chart.legend_content ()) ()
               ; Chart.bar
                   ~data_key:"desktop"
                   ~fill:"var(--color-desktop)"
                   ~radius:(`Corners (6., 6., 0., 0.))
                   ()
               ; Chart.bar
                   ~data_key:"mobile"
                   ~fill:"var(--color-mobile)"
                   ~radius:(`Corners (6., 6., 0., 0.))
                   ()
               ])
        ; div
            ~class_:"grid w-full grid-cols-3 divide-x divide-border/60"
            [ stat "Desktop" (hum desktop)
            ; stat "Mobile" (hum mobile)
            ; stat "Mix Delta" (sprintf "%s%d%%" (if delta > 0 then "+" else "") delta)
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "View report" ] ]
    ]
;;

let invite_team (local_ graph) =
  let role ~email ~default (local_ graph) =
    let value, set_value = Bonsai.state default graph in
    let state, set_state = Bonsai.state Select.State.closed graph in
    let%arr value
    and set_value
    and state
    and set_state in
    div
      ~class_:"flex items-center gap-2"
      [ Input.view ~attrs:[ default_value email ] ~class_:"flex-1" ()
      ; Select.view
          ~id:("invite-role-" ^ email)
          ~value:(Some value)
          ~on_value_change:set_value
          ~state
          ~on_state_change:set_state
          (Select.trigger ~class_:"w-24" ())
          (Select.content
             ~position:Popper
             ~align:End
             [ Select.group
                 [ Select.item ~value:"admin" [ text "Admin" ]
                 ; Select.item ~value:"editor" [ text "Editor" ]
                 ; Select.item ~value:"viewer" [ text "Viewer" ]
                 ]
             ])
      ]
  in
  let alex = role ~email:"alex@example.com" ~default:"editor" graph in
  let sam = role ~email:"sam@example.com" ~default:"viewer" graph in
  let%arr alex
  and sam in
  Card.root
    [ Card.header
        [ Card.title [ text "Invite Team" ]
        ; Card.description [ text "Add members to your workspace" ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ div ~class_:"flex flex-col gap-3" [ alex; sam ]
        ; Button.view
            ~variant:Outline
            [ Icon.view ~attrs:[ Attr.create "data-icon" "inline-start" ] Plus
            ; text "Add another"
            ]
        ; Separator.view ()
        ; Field.root
            [ Field.label ~for_:"invite-link" [ text "Or share invite link" ]
            ; Input_group.root
                [ Input_group.input
                    ~id:"invite-link"
                    ~attrs:
                      [ default_value "https://app.co/invite/x8f2k"
                      ; Attr.create "readonly" ""
                      ]
                    ()
                ; Input_group.addon
                    ~align:Inline_end
                    [ Input_group.button
                        ~size:Icon_xs
                        ~attrs:[ Attr.create "aria-label" "Copy link" ]
                        [ icon Copy ]
                    ]
                ]
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Send Invites" ] ]
    ]
;;

let activate_agent_dialog =
  let strong s = el "strong" [ text s ] in
  let features =
    [ [ strong "Code reviews"
      ; text " with full codebase context to catch "
      ; strong "hard-to-find"
      ; text " bugs."
      ]
    ; [ strong "Code suggestions"; text " validated in sandboxes before you merge." ]
    ; [ strong "Root-cause analysis"
      ; text " for production issues with deployment context. "
      ; Badge.view
          ~variant:Secondary
          ~class_:"bg-chart-1 text-chart-5"
          [ text "Requires Observability Plus" ]
      ]
    ]
  in
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Ship faster & safer with Vercel Agent" ]
           ; Card.description
               [ text "Your use is subject to Vercel's "
               ; Node.a ~attrs:[ Attr.href "#" ] [ text "Public Beta Agreement" ]
               ; text " and "
               ; Node.a ~attrs:[ Attr.href "#" ] [ text "AI Product Terms" ]
               ; text "."
               ]
           ]
       ; Card.content
           ~class_:"flex flex-col gap-4"
           [ Item.group
               ~class_:"gap-0"
               (List.map features ~f:(fun content ->
                  (* The base's [size="xs"]; loon's Item has [sm] at the least. *)
                  Item.view
                    ~size:Sm
                    ~class_:"px-0"
                    [ Item.media
                        ~variant:Icon
                        ~class_:"self-start"
                        [ icon
                            ~class_:"size-5 fill-primary text-primary-foreground"
                            Circle_check_big
                        ]
                    ; Item.content
                        [ Item.title
                            ~class_:
                              "inline leading-relaxed font-normal text-muted-foreground \
                               *:[strong]:font-medium *:[strong]:text-foreground"
                            content
                        ]
                    ]))
           ; Alert.root
               [ Alert.description
                   [ text
                       "Pro teams get $100 in Vercel Agent trial credit for 2 weeks \
                        after activation."
                   ]
               ]
           ]
       ; Card.footer
           ~class_:"justify-end gap-2"
           [ Button.view ~variant:Outline ~class_:"style-sera:hidden" [ text "Cancel" ]
           ; Button.view ~class_:"style-sera:w-full" [ text "Enable with $100 credits" ]
           ]
       ])
;;

let skeleton_loading =
  let sk c = Skeleton.view ~class_:c [] in
  static
    (Card.root
       [ Card.content
           ~class_:"flex flex-col gap-4"
           [ div
               ~class_:"flex items-center gap-3"
               [ sk "size-10 rounded-full"
               ; div
                   ~class_:"flex flex-1 flex-col gap-2"
                   [ sk "h-4 w-3/4"; sk "h-3 w-1/2" ]
               ]
           ; div
               ~class_:"flex flex-col gap-2"
               [ sk "h-3 w-full"; sk "h-3 w-full"; sk "h-3 w-4/5" ]
           ; div ~class_:"flex gap-2" [ sk "h-8 w-20"; sk "h-8 w-20" ]
           ]
       ])
;;
