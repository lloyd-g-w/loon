open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

module User = struct
  type t =
    { name : string
    ; email : string
    ; avatar : string
    }
end

module Mail = struct
  type t =
    { name : string
    ; email : string
    ; subject : string
    ; date : string
    ; teaser : string
    }
end

(* This is sample data *)
let user =
  { User.name = "shadcn"; email = "m@example.com"; avatar = "avatars/shadcn.jpg" }
;;

let nav_main : (string * Icon.t) list =
  [ "Inbox", Inbox
  ; "Drafts", File
  ; "Sent", Send
  ; "Junk", Archive_x
  ; "Trash", Trash
  ]
;;

let mails : Mail.t list =
  [ { name = "William Smith"
    ; email = "williamsmith@example.com"
    ; subject = "Meeting Tomorrow"
    ; date = "09:34 AM"
    ; teaser =
        "Hi team, just a reminder about our meeting tomorrow at 10 AM.\n\
         Please come prepared with your project updates."
    }
  ; { name = "Alice Smith"
    ; email = "alicesmith@example.com"
    ; subject = "Re: Project Update"
    ; date = "Yesterday"
    ; teaser =
        "Thanks for the update. The progress looks great so far.\n\
         Let's schedule a call to discuss the next steps."
    }
  ; { name = "Bob Johnson"
    ; email = "bobjohnson@example.com"
    ; subject = "Weekend Plans"
    ; date = "2 days ago"
    ; teaser =
        "Hey everyone! I'm thinking of organizing a team outing this weekend.\n\
         Would you be interested in a hiking trip or a beach day?"
    }
  ; { name = "Emily Davis"
    ; email = "emilydavis@example.com"
    ; subject = "Re: Question about Budget"
    ; date = "2 days ago"
    ; teaser =
        "I've reviewed the budget numbers you sent over.\n\
         Can we set up a quick call to discuss some potential adjustments?"
    }
  ; { name = "Michael Wilson"
    ; email = "michaelwilson@example.com"
    ; subject = "Important Announcement"
    ; date = "1 week ago"
    ; teaser =
        "Please join us for an all-hands meeting this Friday at 3 PM.\n\
         We have some exciting news to share about the company's future."
    }
  ; { name = "Sarah Brown"
    ; email = "sarahbrown@example.com"
    ; subject = "Re: Feedback on Proposal"
    ; date = "1 week ago"
    ; teaser =
        "Thank you for sending over the proposal. I've reviewed it and have \
         some thoughts.\n\
         Could we schedule a meeting to discuss my feedback in detail?"
    }
  ; { name = "David Lee"
    ; email = "davidlee@example.com"
    ; subject = "New Project Idea"
    ; date = "1 week ago"
    ; teaser =
        "I've been brainstorming and came up with an interesting project \
         concept.\n\
         Do you have time this week to discuss its potential impact and \
         feasibility?"
    }
  ; { name = "Olivia Wilson"
    ; email = "oliviawilson@example.com"
    ; subject = "Vacation Plans"
    ; date = "1 week ago"
    ; teaser =
        "Just a heads up that I'll be taking a two-week vacation next month.\n\
         I'll make sure all my projects are up to date before I leave."
    }
  ; { name = "James Martin"
    ; email = "jamesmartin@example.com"
    ; subject = "Re: Conference Registration"
    ; date = "1 week ago"
    ; teaser =
        "I've completed the registration for the upcoming tech conference.\n\
         Let me know if you need any additional information from my end."
    }
  ; { name = "Sophia White"
    ; email = "sophiawhite@example.com"
    ; subject = "Team Dinner"
    ; date = "1 week ago"
    ; teaser =
        "To celebrate our recent project success, I'd like to organize a team \
         dinner.\n\
         Are you available next Friday evening? Please let me know your \
         preferences."
    }
  ]
;;

let avatar ~(user : User.t) (local_ graph) =
  Avatar.component
    ~class_:"h-8 w-8 rounded-lg"
    (Bonsai.return (fun avatar ->
       [ Avatar.image avatar ~src:user.avatar ~alt:user.name ()
       ; Avatar.fallback ~class_:"rounded-lg" avatar [ Node.text "CN" ]
       ]))
    graph
;;

let user_text (user : User.t) =
  Node.div
    ~attrs:[ Attr.class_ "grid flex-1 text-left text-sm leading-tight" ]
    [ Node.span
        ~attrs:[ Attr.class_ "truncate font-medium" ]
        [ Node.text user.name ]
    ; Node.span
        ~attrs:[ Attr.class_ "truncate text-xs" ]
        [ Node.text user.email ]
    ]
;;

let nav_user ~sidebar ~(user : User.t) (local_ graph) =
  let trigger_avatar = avatar ~user graph in
  let label_avatar = avatar ~user graph in
  let menu =
    Dropdown_menu.component
      (let%arr sidebar and trigger_avatar and label_avatar in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Sidebar.menu_button
                ~size:Lg
                ~class_:
                  "data-[state=open]:bg-sidebar-accent \
                   data-[state=open]:text-sidebar-accent-foreground md:h-8 \
                   md:p-0"
                [ trigger_avatar
                ; user_text user
                ; Icon.view ~class_:"ml-auto size-4" Chevrons_up_down
                ])
         ; Dropdown_menu.content
             menu
             ~class_:
               "w-(--radix-dropdown-menu-trigger-width) min-w-56 rounded-lg"
             ~side:(if Sidebar.is_mobile sidebar then Bottom else Right)
             ~align:End
             ~side_offset:4.
             [ Dropdown_menu.label
                 ~class_:"p-0 font-normal"
                 [ Node.div
                     ~attrs:
                       [ Attr.class_
                           "flex items-center gap-2 px-1 py-1.5 text-left \
                            text-sm"
                       ]
                     [ label_avatar; user_text user ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item
                     [ Icon.view Sparkles; Node.text "Upgrade to Pro" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.group
                 [ Dropdown_menu.item
                     [ Icon.view Badge_check; Node.text "Account" ]
                 ; Dropdown_menu.item
                     [ Icon.view Credit_card; Node.text "Billing" ]
                 ; Dropdown_menu.item
                     [ Icon.view Bell; Node.text "Notifications" ]
                 ]
             ; Dropdown_menu.separator ()
             ; Dropdown_menu.item [ Icon.view Log_out; Node.text "Log out" ]
             ]
         ])
      graph
  in
  let%arr menu in
  Sidebar.menu [ Sidebar.menu_item [ menu ] ]
;;

(* shadcn shuffles the mails at random on each click; this shuffles them
   by the number of clicks, so that the page is the same each time. *)
let shuffle clicks =
  let random_state = Random.State.make [| clicks |] in
  let mails = List.permute ~random_state mails in
  List.take mails (Int.max 5 (Random.State.int random_state 10 + 1))
;;

let app_sidebar ~sidebar (local_ graph) =
  (* Note: I'm using state to show active item.
     IRL you should use the url/router. *)
  let active_item, set_active_item = Bonsai.state "Inbox" graph in
  let clicks, set_clicks = Bonsai.state 0 graph in
  let search, set_search = Bonsai.state "" graph in
  let unreads, set_unreads = Bonsai.state false graph in
  let nav_user = nav_user ~sidebar ~user graph in
  let%arr sidebar
  and active_item
  and set_active_item
  and clicks
  and set_clicks
  and search
  and set_search
  and unreads
  and set_unreads
  and nav_user in
  let mails = if clicks = 0 then mails else shuffle clicks in
  Sidebar.root
    ~collapsible:Icon
    ~class_:"overflow-hidden *:data-[sidebar=sidebar]:flex-row"
    sidebar
    [ (* This is the first sidebar. We disable collapsible and adjust width
         to icon. This will make the sidebar appear as icons. *)
      Sidebar.root
        ~collapsible:None
        ~class_:"w-[calc(var(--sidebar-width-icon)+1px)]! border-r"
        sidebar
        [ Sidebar.header
            [ Sidebar.menu
                [ Sidebar.menu_item
                    [ Sidebar.menu_button
                        ~size:Lg
                        ~href:"#"
                        ~class_:"md:h-8 md:p-0"
                        [ Node.div
                            ~attrs:
                              [ Attr.class_
                                  "flex aspect-square size-8 items-center \
                                   justify-center rounded-lg \
                                   bg-sidebar-primary \
                                   text-sidebar-primary-foreground"
                              ]
                            [ Icon.view ~class_:"size-4" Command ]
                        ; Node.div
                            ~attrs:
                              [ Attr.class_
                                  "grid flex-1 text-left text-sm leading-tight"
                              ]
                            [ Node.span
                                ~attrs:[ Attr.class_ "truncate font-medium" ]
                                [ Node.text "Acme Inc" ]
                            ; Node.span
                                ~attrs:[ Attr.class_ "truncate text-xs" ]
                                [ Node.text "Enterprise" ]
                            ]
                        ]
                    ]
                ]
            ]
        ; Sidebar.content
            [ Sidebar.group
                [ Sidebar.group_content
                    ~class_:"px-1.5 md:px-0"
                    [ Sidebar.menu
                        (List.map nav_main ~f:(fun (title, icon) ->
                           Sidebar.menu_item
                             [ Sidebar.menu_button
                                 ~tooltip:
                                   (Sidebar.menu_tooltip
                                      ~hidden:false
                                      sidebar
                                      title)
                                 ~on_click:
                                   (Effect.Many
                                      [ set_active_item title
                                      ; set_clicks (clicks + 1)
                                      ; Sidebar.set_open sidebar true
                                      ])
                                 ~is_active:(String.equal active_item title)
                                 ~class_:"px-2.5 md:px-2"
                                 [ Icon.view icon; Node.span [ Node.text title ] ]
                             ]))
                    ]
                ]
            ]
        ; Sidebar.footer [ nav_user ]
        ]
    ; (* This is the second sidebar. We disable collapsible and let it fill
         remaining space. *)
      Sidebar.root
        ~collapsible:None
        ~class_:"hidden flex-1 md:flex"
        sidebar
        [ Sidebar.header
            ~class_:"gap-3.5 border-b p-4"
            [ Node.div
                ~attrs:
                  [ Attr.class_ "flex w-full items-center justify-between" ]
                [ Node.div
                    ~attrs:
                      [ Attr.class_ "text-base font-medium text-foreground" ]
                    [ Node.text active_item ]
                ; Label.view
                    ~class_:"flex items-center gap-2 text-sm"
                    [ Node.span [ Node.text "Unreads" ]
                    ; Switch.view
                        ~class_:"shadow-none"
                        ~checked:unreads
                        ~on_change:set_unreads
                        ()
                    ]
                ]
            ; Sidebar.input
                ~placeholder:"Type to search..."
                ~value:search
                ~on_input:set_search
                ()
            ]
        ; Sidebar.content
            [ Sidebar.group
                ~class_:"px-0"
                [ Sidebar.group_content
                    (List.map mails ~f:(fun (mail : Mail.t) ->
                       Node.a
                         ~key:mail.email
                         ~attrs:
                           [ Attr.href "#"
                           ; Attr.class_
                               "flex flex-col items-start gap-2 border-b p-4 \
                                text-sm leading-tight whitespace-nowrap \
                                last:border-b-0 hover:bg-sidebar-accent \
                                hover:text-sidebar-accent-foreground"
                           ]
                         [ Node.div
                             ~attrs:
                               [ Attr.class_ "flex w-full items-center gap-2" ]
                             [ Node.span [ Node.text mail.name ]
                             ; Node.text " "
                             ; Node.span
                                 ~attrs:[ Attr.class_ "ml-auto text-xs" ]
                                 [ Node.text mail.date ]
                             ]
                         ; Node.span
                             ~attrs:[ Attr.class_ "font-medium" ]
                             [ Node.text mail.subject ]
                         ; Node.span
                             ~attrs:
                               [ Attr.class_
                                   "line-clamp-2 w-[260px] text-xs \
                                    whitespace-break-spaces"
                               ]
                             [ Node.text mail.teaser ]
                         ]))
                ]
            ]
        ]
    ]
;;

let view (local_ graph) =
  let sidebar = Sidebar.component graph in
  let app_sidebar = app_sidebar ~sidebar graph in
  let%arr sidebar and app_sidebar in
  Sidebar.provider
    ~attrs:[ Attr.__css_vars_no_kebabs [ "--sidebar-width", "350px" ] ]
    sidebar
    [ app_sidebar
    ; Sidebar.inset
        [ Node.header
            ~attrs:
              [ Attr.class_
                  "sticky top-0 flex shrink-0 items-center gap-2 border-b \
                   bg-background p-4"
              ]
            [ Sidebar.trigger ~class_:"-ml-1" sidebar
            ; Separator.view
                ~orientation:Vertical
                ~class_:"mr-2 data-[orientation=vertical]:h-4"
                ()
            ; Breadcrumb.root
                [ Breadcrumb.list
                    [ Breadcrumb.item
                        ~class_:"hidden md:block"
                        [ Breadcrumb.link ~href:"#" [ Node.text "All Inboxes" ] ]
                    ; Breadcrumb.separator ~class_:"hidden md:block" ()
                    ; Breadcrumb.item [ Breadcrumb.page [ Node.text "Inbox" ] ]
                    ]
                ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex flex-1 flex-col gap-4 p-4" ]
            (List.init 24 ~f:(fun _ ->
               Node.div
                 ~attrs:
                   [ Attr.class_
                       "aspect-video h-12 w-full rounded-lg bg-muted/50"
                   ]
                 []))
        ]
    ]
;;
