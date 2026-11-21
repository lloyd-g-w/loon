open! Core
open Bonsai_web
open Loon
open Bonsai.Let_syntax
open Create_preview_util
module Node = Vdom.Node
module Attr = Vdom.Attr

let pie_centre total (vb : Chart.Polar_view_box.t) =
  let svg = Node.create_svg in
  svg
    "text"
    ~attrs:
      [ Attr.create "x" (num vb.cx)
      ; Attr.create "y" (num vb.cy)
      ; Attr.create "text-anchor" "middle"
      ; Attr.create "dominant-baseline" "middle"
      ; Attr.create "fill" "red"
      ]
    [ svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (num vb.cx)
          ; Attr.create "y" (num (vb.cy -. 16.))
          ; Attr.class_ "fill-foreground text-2xl font-bold"
          ]
        [ text total ]
    ; svg
        "tspan"
        ~attrs:
          [ Attr.create "x" (num vb.cx)
          ; Attr.create "y" (num (vb.cy +. 4.))
          ; Attr.class_ "fill-muted-foreground text-xs"
          ]
        [ text "Visitors" ]
    ]
;;

let pie_chart_card (local_ graph) =
  let chart = chart graph in
  let data = [ "chrome", 275.; "safari", 200.; "firefox", 287.; "edge", 173. ] in
  let total = List.sum (module Float) data ~f:snd in
  let top_browser, top_visitors =
    List.reduce_exn data ~f:(fun a b -> if Float.( > ) (snd b) (snd a) then b else a)
  in
  let share = Float.iround_nearest_exn (top_visitors /. total *. 100.) in
  let config =
    [ "visitors", Chart.Config.item ~label:"Visitors" ()
    ; "chrome", Chart.Config.item ~label:"Chrome" ~color:"var(--chart-1)" ()
    ; "safari", Chart.Config.item ~label:"Safari" ~color:"var(--chart-2)" ()
    ; "firefox", Chart.Config.item ~label:"Firefox" ~color:"var(--chart-3)" ()
    ; "edge", Chart.Config.item ~label:"Edge" ~color:"var(--chart-4)" ()
    ]
  in
  let top_label =
    List.Assoc.find config ~equal:String.equal top_browser
    |> Option.bind ~f:(fun (c : Chart.Config.item) -> c.label)
    |> Option.value ~default:"Top"
  in
  let%arr chart in
  Card.root
    [ Card.header
        ~class_:"pb-0"
        [ Card.title [ text "Browser Share" ]
        ; Card.description [ text "January - June 2026" ]
        ; Card.action [ Badge.view ~variant:Outline [ text top_label ] ]
        ]
    ; Card.content
        ~class_:"pt-0"
        [ Chart.container
            ~config
            ~class_:"mx-auto aspect-square max-h-[190px]"
            chart
            (Chart.pie_chart
               [ Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~hide_label:true ())
                   ()
               ; Chart.pie
                   ~data:
                     (List.map data ~f:(fun (b, v) ->
                        [ "browser", `Text b
                        ; "visitors", `Num v
                        ; "fill", `Text (sprintf "var(--color-%s)" b)
                        ]))
                   ~data_key:"visitors"
                   ~name_key:"browser"
                   ~inner_radius:50.
                   ~stroke_width:5.
                   ~children:
                     [ Chart.label
                         ~content:
                           (pie_centre
                              (Int.to_string_hum
                                 ~delimiter:','
                                 (Float.iround_nearest_exn total)))
                         ()
                     ]
                   ()
               ; Chart.legend
                   ~content:(Chart.legend_content ~name_key:"browser" ())
                   ~class_:"translate-y-2"
                   ()
               ])
        ]
    ; Card.footer
        ~class_:"flex-col items-stretch gap-2"
        [ div
            ~class_:"flex items-center text-xs"
            [ tspan "font-medium" top_label
            ; tspan "ml-auto text-muted-foreground tabular-nums" (sprintf "%d%%" share)
            ]
        ; Progress.view
            ~value:(Float.of_int share)
            ~class_:"**:data-[slot=progress-indicator]:bg-chart-3"
            ()
        ]
    ]
;;

(* The base loads GitHub avatars; the docs load nothing remote, so the
   avatars show their fallbacks. *)
let avatar ?size ?class_ initials =
  Avatar.view
    ?size
    ?class_
    ~status:Error
    ~on_status_change:(fun _ -> Effect.Ignore)
    (fun a -> [ Avatar.fallback a [ text initials ] ])
;;

let no_team_members =
  static
    (Card.root
       [ Card.content
           [ Empty.root
               ~class_:"h-56 border"
               [ Empty.header
                   [ Empty.media
                       [ Avatar.group
                           ~class_:"grayscale"
                           [ avatar ~size:Lg "CN"
                           ; avatar ~size:Lg "LR"
                           ; avatar ~size:Lg "ER"
                           ]
                       ]
                   ; Empty.title [ text "No Team Members" ]
                   ; Empty.description
                       [ text "Invite your team to collaborate on this project." ]
                   ]
               ; Empty.content [ Button.view ~size:Sm [ text "Invite Members" ] ]
               ]
           ]
       ])
;;

let report_bug (local_ graph) =
  let severity =
    select
      ~id:"bug-severity"
      ~class_:"w-full"
      ~default_value:"medium"
      [ "critical", "Critical"; "high", "High"; "medium", "Medium"; "low", "Low" ]
      graph
  in
  let component =
    select
      ~id:"bug-component"
      ~class_:"w-full"
      ~default_value:"dashboard"
      [ "dashboard", "Dashboard"; "auth", "Auth"; "api", "API"; "billing", "Billing" ]
      graph
  in
  let%arr severity
  and component in
  Card.root
    [ Card.header
        [ Card.title [ text "Report Bug" ]
        ; Card.description [ text "Help us fix issues faster." ]
        ]
    ; Card.content
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"bug-title" [ text "Title" ]
                ; Input.view
                    ~id:"bug-title"
                    ~placeholder:"Brief description of the issue"
                    ()
                ]
            ; div
                ~class_:"grid grid-cols-2 gap-3"
                [ Field.root
                    [ Field.label
                        ~for_:(select_trigger_id "bug-severity")
                        [ text "Severity" ]
                    ; severity
                    ]
                ; Field.root
                    [ Field.label
                        ~for_:(select_trigger_id "bug-component")
                        [ text "Component" ]
                    ; component
                    ]
                ]
            ; Field.root
                [ Field.label ~for_:"bug-steps" [ text "Steps to reproduce" ]
                ; Textarea.view
                    ~id:"bug-steps"
                    ~placeholder:"1. Go to\n2. Click on\n3. Observe..."
                    ~class_:"min-h-24 resize-none"
                    ()
                ]
            ]
        ]
    ; Card.footer
        [ Field.root
            ~orientation:Horizontal
            ~class_:"justify-end style-sera:justify-center"
            [ Button.view
                ~variant:Outline
                ~class_:"style-sera:flex-1"
                [ text "Attach File" ]
            ; Button.view ~class_:"style-sera:flex-1" [ text "Submit Bug" ]
            ]
        ]
    ]
;;

let contributors =
  let usernames =
    [ "shadcn"
    ; "vercel"
    ; "nextjs"
    ; "tailwindlabs"
    ; "typescript-lang"
    ; "eslint"
    ; "prettier"
    ; "babel"
    ; "webpack"
    ; "rollup"
    ; "parcel"
    ; "vite"
    ; "react"
    ; "vue"
    ; "angular"
    ; "solid"
    ]
  in
  static
    (Card.root
       ~class_:"max-w-sm"
       [ Card.header
           [ Card.title
               [ text "Contributors "; Badge.view ~variant:Secondary [ text "312" ] ]
           ]
       ; Card.content
           [ div
               ~class_:"flex flex-wrap gap-2"
               (List.map usernames ~f:(fun u ->
                  avatar ~class_:"grayscale" (String.prefix u 1)))
           ]
       ; Card.footer
           [ Node.a
               ~attrs:
                 [ Attr.href "#"; Attr.class_ "text-sm underline underline-offset-4" ]
               [ text "+ 810 contributors" ]
           ]
       ])
;;

let feedback_form =
  let options =
    [ "", "Select a topic"
    ; "ai", "AI"
    ; "accounts-and-access-controls", "Accounts and Access Controls"
    ; "billing", "Billing"
    ; "cdn", "CDN (Firewall, Caching)"
    ; "ci-cd", "CI/CD (Builds, Deployments, Environment Variables)"
    ; "dashboard-interface", "Dashboard Interface (Navigation, UI Issues)"
    ; "domains", "Domains"
    ; "frameworks", "Frameworks"
    ; "marketplace-and-integrations", "Marketplace and Integrations"
    ; "observability", "Observability (Observability, Logs, Monitoring)"
    ; "storage", "Storage"
    ]
  in
  static
    (Card.root
       [ Card.content
           [ Node.create
               "form"
               ~attrs:[ Attr.id "feedback-form"; Attr.on_submit Dom_util.prevent_default ]
               [ Field.group
                   [ Field.root
                       [ Field.label ~for_:"topic" [ text "Topic" ]
                       ; Native_select.view
                           ~id:"topic"
                           (List.map options ~f:(fun (value, label) ->
                              Native_select.option ~value [ text label ]))
                       ]
                   ; Field.root
                       [ Field.label ~for_:"feedback" [ text "Feedback" ]
                       ; Textarea.view
                           ~id:"feedback"
                           ~placeholder:"Your feedback helps us improve..."
                           ()
                       ]
                   ]
               ]
           ]
       ; Card.footer
           [ Button.view
               ~type_:`Submit
               ~attrs:[ Attr.create "form" "feedback-form" ]
               ~class_:"style-sera:w-full"
               [ text "Submit" ]
           ]
       ])
;;

let book_appointment (local_ graph) =
  let slots =
    Toggle_group.multiple_component
      ~spacing:2
      ~default_value:[ "slot-0" ]
      (Bonsai.return (fun g ->
         List.mapi [ "9:00 AM"; "10:30 AM"; "11:00 AM"; "1:30 PM" ] ~f:(fun i time ->
           Toggle_group.item g ~value:(sprintf "slot-%d" i) [ text time ])))
      graph
  in
  let%arr slots in
  Card.root
    [ Card.header
        [ Card.title [ text "Book Appointment" ]
        ; Card.description [ text "Dr. Sarah Chen · Cardiology" ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-4"
        [ Field.group
            [ Field.root
                [ Field.label [ text "Available on March 18, 2026" ]; slots.view ]
            ]
        ; Alert.root
            [ Alert.title [ text "New patient?" ]
            ; Alert.description [ text "Please arrive 15 minutes early." ]
            ]
        ]
    ; Card.footer [ Button.view ~class_:"w-full" [ text "Book Appointment" ] ]
    ]
;;

let sleep_report (local_ graph) =
  let chart = chart graph in
  let%arr chart in
  let config =
    [ "deep", Chart.Config.item ~label:"Deep" ~color:"var(--chart-1)" ()
    ; "light", Chart.Config.item ~label:"Light" ~color:"var(--chart-2)" ()
    ; "rem", Chart.Config.item ~label:"REM" ~color:"var(--chart-3)" ()
    ]
  in
  let data =
    List.map
      [ "10pm", 0., 30., 0.
      ; "11pm", 20., 10., 0.
      ; "12am", 40., 0., 10.
      ; "1am", 30., 5., 15.
      ; "2am", 10., 20., 30.
      ; "3am", 25., 10., 20.
      ; "4am", 15., 25., 10.
      ; "5am", 5., 35., 15.
      ; "6am", 0., 20., 25.
      ]
      ~f:(fun (h, d, l, r) ->
        [ "hour", `Text h; "deep", `Num d; "light", `Num l; "rem", `Num r ])
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Sleep Report" ]
        ; Card.description [ text "Last night · 7h 24m" ]
        ]
    ; Card.content
        ~class_:"flex flex-col gap-3"
        [ Chart.container
            ~config
            ~class_:"h-32 w-full"
            chart
            (Chart.bar_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:0. ~bottom:0. ())
               ~data
               [ Chart.bar
                   ~data_key:"deep"
                   ~stack_id:"a"
                   ~bar_size:16.
                   ~fill:"var(--color-deep)"
                   ()
               ; Chart.bar
                   ~data_key:"light"
                   ~stack_id:"a"
                   ~bar_size:16.
                   ~fill:"var(--color-light)"
                   ()
               ; Chart.bar
                   ~data_key:"rem"
                   ~stack_id:"a"
                   ~bar_size:16.
                   ~fill:"var(--color-rem)"
                   ~radius:(`Corners (2., 2., 0., 0.))
                   ()
               ])
        ; div
            ~class_:"grid grid-cols-4 gap-2"
            (List.map
               [ "Deep", "2h 10m"; "Light", "3h 48m"; "REM", "1h 26m"; "Score", "84" ]
               ~f:(fun (label, value) ->
                 div
                   ~class_:"text-center"
                   [ div ~class_:"text-sm font-medium tabular-nums" [ text value ]
                   ; div ~class_:"text-xs text-muted-foreground" [ text label ]
                   ]))
        ]
    ; Card.footer
        [ Badge.view ~variant:Outline [ text "Good" ]
        ; Button.view ~variant:Outline ~size:Sm ~class_:"ml-auto" [ text "Details" ]
        ]
    ]
;;

let github_profile =
  static
    (Card.root
       ~class_:"mx-auto w-full max-w-md"
       [ Card.header
           [ Card.title [ text "Profile" ]
           ; Card.description [ text "Manage your profile information." ]
           ]
       ; Card.content
           [ Node.create
               "form"
               ~attrs:[ Attr.id "profile"; Attr.on_submit Dom_util.prevent_default ]
               [ Field.group
                   [ Field.root
                       [ Field.label ~for_:"name" [ text "Name" ]
                       ; Input.view ~id:"name" ~placeholder:"shadcn" ()
                       ; Field.description
                           [ text
                               "Your name may appear around GitHub where you contribute \
                                or are mentioned. You can remove it at any time."
                           ]
                       ]
                   ; Field.root
                       [ Field.label ~for_:"email" [ text "Public Email" ]
                       ; Native_select.view
                           ~id:"email"
                           [ Native_select.option
                               ~value:"m@shadcn.com"
                               [ text "m@shadcn.com" ]
                           ; Native_select.option
                               ~value:"m@gmail.com"
                               [ text "m@gmail.com" ]
                           ]
                       ; Field.description
                           [ text "You can manage verified email addresses in your "
                           ; Node.a
                               ~attrs:[ Attr.href "#email-settings" ]
                               [ text "email settings" ]
                           ; text "."
                           ]
                       ]
                   ; Field.root
                       [ Field.label ~for_:"bio" [ text "Bio" ]
                       ; Textarea.view
                           ~id:"bio"
                           ~placeholder:"Tell us a little bit about yourself"
                           ()
                       ; Field.description
                           [ text "You can "
                           ; span [ text "@mention" ]
                           ; text " other users and organizations to link to them."
                           ]
                       ]
                   ]
               ]
           ]
       ; Card.footer
           [ Button.view
               ~attrs:[ Attr.create "form" "profile" ]
               ~class_:"style-sera:w-full"
               [ text "Save Profile" ]
           ]
       ])
;;

let weekly_fitness_summary =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "Weekly Fitness Summary" ]
           ; Card.description [ text "Calories and workout load by day" ]
           ]
       ; Card.content
           ~class_:"flex flex-col gap-4"
           [ div
               ~class_:"grid grid-cols-7 gap-1.5"
               (List.map
                  [ "M", 84; "T", 52; "W", 73; "T", 66; "F", 91; "S", 48; "S", 61 ]
                  ~f:(fun (day, load) ->
                    div
                      ~class_:"rounded-md p-1.5 text-center ring ring-border"
                      [ div ~class_:"text-sm text-muted-foreground" [ text day ]
                      ; div
                          ~class_:"relative mt-1 h-16 overflow-hidden rounded-sm bg-muted"
                          [ div
                              ~class_:"absolute inset-x-0 bottom-0 rounded-sm bg-chart-3"
                              ~attrs:
                                [ Attr.style
                                    (Css_gen.height
                                       (`Percent
                                           (Percent.of_mult (Float.of_int load /. 100.))))
                                ]
                              []
                          ]
                      ]))
           ]
       ; Card.footer [ Button.view ~class_:"w-full" [ text "View details" ] ]
       ])
;;

let file_upload =
  static
    (Card.root
       [ Card.header
           [ Card.title [ text "File Upload" ]
           ; Card.description [ text "Drag and drop or browse" ]
           ]
       ; Card.content
           [ Empty.root
               ~class_:"border"
               [ Empty.header
                   [ Empty.media ~variant:Icon [ icon Cloud_upload ]
                   ; Empty.title [ text "Upload files" ]
                   ; Empty.description [ text "PNG, JPG, PDF up to 10MB" ]
                   ]
               ; Empty.content [ Button.view [ text "Browse Files" ] ]
               ]
           ]
       ])
;;

let months6 = [ "January"; "February"; "March"; "April"; "May"; "June" ]
let visitors6 = [ 186.; 305.; 237.; 73.; 209.; 214. ]

let analytics_card (local_ graph) =
  let chart = chart graph in
  let%arr chart in
  let config =
    [ "visitors", Chart.Config.item ~label:"Visitors" ~color:"var(--chart-1)" () ]
  in
  (* The base's [size="sm"] card; new-york-v4's has no sizes. *)
  Card.root
    ~attrs:[ Attr.create "data-size" "sm" ]
    ~class_:"mx-auto w-full max-w-sm data-[size=sm]:pb-0"
    [ Card.header
        [ Card.title [ text "Analytics" ]
        ; Card.description [ text "418.2K Visitors "; Badge.view [ text "+10%" ] ]
        ; Card.action [ Button.view ~variant:Outline ~size:Sm [ text "View Analytics" ] ]
        ]
    ; Chart.container
        ~config
        ~class_:"aspect-[1/0.35]"
        chart
        (Chart.area_chart
           ~margin:(Chart.margin ~left:0. ~right:0. ())
           ~data:
             (List.map2_exn months6 visitors6 ~f:(fun m v ->
                [ "month", `Text m; "visitors", `Num v ]))
           [ Chart.tooltip
               ~cursor:false
               ~default_index:2
               ~content:(Chart.tooltip_content ~indicator:Line ~hide_label:true ())
               ()
           ; Chart.area
               ~data_key:"visitors"
               ~type_:Linear
               ~fill:"var(--color-visitors)"
               ~fill_opacity:0.4
               ~stroke:"var(--color-visitors)"
               ()
           ])
    ]
;;

let circular_gauge percentage =
  let p = Float.min (Float.max percentage 0.) 100. in
  let circumference = 2. *. Float.pi *. 42.5 in
  let stroke = p /. 100. *. circumference in
  let svg = Node.create_svg in
  let circle extra dash =
    svg
      "circle"
      ~attrs:
        ([ Attr.create "cx" "50"
         ; Attr.create "cy" "50"
         ; Attr.create "r" "42.5"
         ; Attr.create "stroke-width" "12"
         ; Attr.create "stroke-dashoffset" "0"
         ; Attr.create "stroke-linecap" "round"
         ; Attr.create "stroke-linejoin" "round"
         ; Attr.create "stroke" "currentColor"
         ; Attr.style
             (Css_gen.create
                ~field:"stroke-dasharray"
                ~value:(sprintf "%g %g" dash circumference))
         ]
         @ extra)
      []
  in
  svg
    "svg"
    ~attrs:
      [ Attr.create "aria-hidden" "true"
      ; Attr.create "fill" "none"
      ; Attr.create "height" "16"
      ; Attr.create "width" "16"
      ; Attr.create "stroke-width" "2"
      ; Attr.create "viewBox" "0 0 100 100"
      ; Attr.class_ "-rotate-90"
      ]
    [ circle [ Attr.class_ "opacity-20" ] circumference
    ; circle [ Attr.class_ "transition-all duration-300" ] stroke
    ]
;;

let usage_card =
  let items =
    [ "Edge Requests", "$1.83K", 67.34
    ; "Fast Data Transfer", "$952.51", 52.18
    ; "Monitoring data points", "$901.20", 89.42
    ; "Web Analytics Events", "$603.71", 45.67
    ; "ISR Writes", "524.52K / 2M", 26.23
    ; "Function Duration", "5.11 GB Hrs / 1K GB Hrs", 5.11
    ]
  in
  static
    (Card.root
       ~class_:"w-full max-w-sm gap-4"
       [ Card.header
           [ Card.title ~class_:"px-1 text-sm" [ text "5 days remaining in cycle" ] ]
       ; Card.content
           [ Item.group
               ~class_:"gap-0"
               (List.map items ~f:(fun (name, value, percentage) ->
                  Item.link
                    ~size:Sm
                    ~href:"#"
                    ~class_:"px-0 group-hover/item-group:bg-transparent"
                    [ Item.media
                        ~variant:Icon
                        ~class_:"text-primary"
                        [ circular_gauge percentage ]
                    ; Item.content
                        ~class_:"inline-block truncate"
                        [ Item.title ~class_:"inline" [ text name ] ]
                    ; Item.actions
                        [ tspan
                            "font-mono text-xs font-medium text-muted-foreground \
                             tabular-nums"
                            value
                        ]
                    ]))
           ]
       ])
;;

let shortcuts =
  let shortcuts =
    [ "Search", [ "⌘"; "K" ]
    ; "Quick Actions", [ "⌘"; "J" ]
    ; "New File", [ "⌘"; "N" ]
    ; "Save", [ "⌘"; "S" ]
    ; "Toggle Sidebar", [ "⌘"; "B" ]
    ]
  in
  static
    (Card.root
       [ Card.content
           [ div
               ~class_:"flex flex-col gap-3"
               [ div ~class_:"text-sm font-medium" [ text "Shortcuts" ]
               ; Item.group
                   ~class_:"gap-2 text-muted-foreground"
                   ~attrs:[ Attr.create "data-size" "xs" ]
                   (List.concat_mapi shortcuts ~f:(fun i (label, keys) ->
                      (if i > 0 then [ Item.separator () ] else [])
                      @ [ Item.view
                            ~variant:Default
                            ~size:Sm
                            ~class_:"border-0 px-0 py-0"
                            [ Item.header
                                [ Item.title ~class_:"font-normal" [ text label ]
                                ; Item.actions
                                    [ div
                                        ~class_:"flex gap-1"
                                        (List.map keys ~f:(fun k -> Kbd.view [ text k ]))
                                    ]
                                ]
                            ]
                        ]))
               ]
           ]
       ])
;;

let anomaly_alert =
  static
    (Card.root
       [ Card.content
           [ Empty.root
               ~class_:"h-48"
               [ Empty.header
                   [ Empty.title [ text "Get alerted for anomalies" ]
                   ; Empty.description
                       [ text
                           "Automatically monitor your projects for anomalies and get \
                            notified."
                       ]
                   ]
               ; Empty.content [ Button.view [ text "Upgrade to Observability Plus" ] ]
               ]
           ]
       ])
;;

(* shadcn's card draws the microphone's live waveform on a canvas; here the
   buttons keep their states and the waveform is a still one. *)
let live_waveform_card (local_ graph) =
  let active, set_active = Bonsai.state false graph in
  let processing, set_processing = Bonsai.state true graph in
  let scrolling, set_scrolling = Bonsai.state false graph in
  let%arr active
  and set_active
  and processing
  and set_processing
  and scrolling
  and set_scrolling in
  let bars =
    List.init 60 ~f:(fun i ->
      let x = Float.of_int i in
      let h =
        if processing || active
        then 0.15 +. (0.6 *. Float.abs (Float.sin (x /. 4.) *. Float.cos (x /. 9.)))
        else 0.05
      in
      div
        ~class_:"rounded-full bg-muted-foreground/60"
        ~attrs:
          [ Attr.style
              (Css_gen.concat
                 [ Css_gen.width (`Px 3); Css_gen.height (`Percent (Percent.of_mult h)) ])
          ]
        [])
  in
  let button on label value set =
    Button.view
      ~size:Sm
      ~variant:(if on then Default else Outline)
      ~on_click:(set (not value))
      [ text label ]
  in
  Card.root
    [ Card.header
        [ Card.title [ text "Live Audio Waveform" ]
        ; Card.description
            [ text "Real-time microphone input visualization with audio reactivity" ]
        ]
    ; Card.content
        [ div
            ~class_:
              "flex h-20 items-center justify-center gap-[2px] \
               [mask-image:linear-gradient(to_right,transparent,black_20%,black_80%,transparent)]"
            bars
        ]
    ; Card.footer
        ~class_:"gap-2"
        [ Button.view
            ~size:Sm
            ~variant:(if active then Default else Outline)
            ~on_click:
              (Effect.Many
                 [ set_active (not active)
                 ; (if not active then set_processing false else Effect.Ignore)
                 ])
            [ text ((if active then "Stop" else "Start") ^ " Listening") ]
        ; Button.view
            ~size:Sm
            ~variant:(if processing then Default else Outline)
            ~on_click:
              (Effect.Many
                 [ set_processing (not processing)
                 ; (if not processing then set_active false else Effect.Ignore)
                 ])
            [ text ((if processing then "Stop" else "Start") ^ " Processing") ]
        ; button
            false
            (if scrolling then "Scrolling" else "Static")
            scrolling
            set_scrolling
        ]
    ]
;;

let visitors (local_ graph) =
  let chart = chart graph in
  let latest = List.last_exn visitors6 in
  let previous = List.nth_exn visitors6 (List.length visitors6 - 2) in
  let trend =
    if Float.equal previous 0.
    then 0
    else Float.iround_nearest_exn ((latest -. previous) /. previous *. 100.)
  in
  let%arr chart in
  let config =
    [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" () ]
  in
  Card.root
    ~class_:"pb-0"
    [ Card.header
        [ Card.title [ text "Visitors" ]
        ; Card.description [ text "Last 6 months " ]
        ; Card.action
            [ Badge.view
                ~variant:(if trend >= 0 then Secondary else Destructive)
                [ text
                    (sprintf "%s%d%% vs last month" (if trend > 0 then "+" else "") trend)
                ]
            ]
        ]
    ; Card.content
        ~class_:"px-0"
        [ Chart.container
            ~config
            ~class_:"h-48 w-full"
            chart
            (Chart.area_chart
               ~margin:(Chart.margin ~left:0. ~right:0. ~top:6. ~bottom:0. ())
               ~data:
                 (List.map2_exn months6 visitors6 ~f:(fun m v ->
                    [ "month", `Text m; "desktop", `Num v ]))
               [ Chart.x_axis
                   ~data_key:"month"
                   ~tick_line:false
                   ~hide:true
                   ~axis_line:false
                   ~tick_margin:6.
                   ~tick_formatter:(fun v -> String.prefix v 3)
                   ()
               ; Chart.tooltip
                   ~cursor:false
                   ~content:(Chart.tooltip_content ~indicator:Line ())
                   ()
               ; Chart.area
                   ~data_key:"desktop"
                   ~type_:Natural
                   ~fill:"var(--color-desktop)"
                   ~fill_opacity:0.15
                   ~stroke:"var(--color-desktop)"
                   ~stroke_width:2.
                   ()
               ])
        ]
    ]
;;

let contributions_activity (local_ graph) =
  let private_ = Checkbox.component ~id:"activity-private-profile" graph in
  let%arr private_ in
  Card.root
    [ Card.header
        [ Card.title [ text "Contributions & Activity" ]
        ; Card.description [ text "Manage your contributions and activity visibility." ]
        ]
    ; Card.content
        [ Node.create
            "form"
            ~attrs:
              [ Attr.id "contributions-activity"
              ; Attr.on_submit Dom_util.prevent_default
              ]
            [ Field.group
                [ Field.set
                    [ Field.legend ~class_:"sr-only" [ text "Contributions & activity" ]
                    ; Field.group
                        [ Field.root
                            ~orientation:Horizontal
                            [ private_.view
                            ; Field.content
                                [ Field.label
                                    ~for_:"activity-private-profile"
                                    [ text "Make profile private and hide activity" ]
                                ; Field.description
                                    [ text
                                        "Enabling this will hide your contributions and \
                                         activity from your GitHub profile and from \
                                         social features like followers, stars, feeds, \
                                         leaderboards and releases."
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    ; Card.footer
        [ Button.view
            ~attrs:[ Attr.create "form" "contributions-activity" ]
            ~class_:"style-sera:w-full"
            [ text "Save Changes" ]
        ]
    ]
;;

let not_found =
  static
    (Card.root
       [ Card.content
           [ Empty.root
               ~class_:"h-72"
               [ Empty.header
                   [ Empty.title [ text "404 - Not Found" ]
                   ; Empty.description
                       [ text
                           "The page you're looking for doesn't exist. Try searching for \
                            what you need below."
                       ]
                   ]
               ; Empty.content
                   [ Input_group.root
                       ~class_:"w-3/4"
                       [ Input_group.input ~placeholder:"Try searching for pages..." ()
                       ; Input_group.addon [ icon Search ]
                       ; Input_group.addon ~align:Inline_end [ Kbd.view [ text "/" ] ]
                       ]
                   ; Button.view ~variant:Link [ text "Go to homepage" ]
                   ]
               ]
           ]
       ])
;;
