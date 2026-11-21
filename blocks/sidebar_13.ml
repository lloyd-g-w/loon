open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let nav : (string * Icon.t) list =
  [ "Notifications", Bell
  ; "Navigation", Menu
  ; "Home", House
  ; "Appearance", Paintbrush
  ; "Messages & media", Message_circle
  ; "Language & region", Globe
  ; "Accessibility", Keyboard
  ; "Mark as read", Check
  ; "Audio & video", Video
  ; "Connected accounts", Link
  ; "Privacy & visibility", Lock
  ; "Advanced", Settings
  ]
;;

let settings_dialog (local_ graph) =
  let sidebar = Sidebar.component ~persist:false graph in
  Dialog.component
    ~default_open:true
    (let%arr sidebar in
     fun dialog ->
       [ Dialog.trigger dialog (Button.view ~size:Sm [ Node.text "Open Dialog" ])
       ; Dialog.content
           dialog
           ~class_:
             "overflow-hidden p-0 md:max-h-[500px] md:max-w-[700px] \
              lg:max-w-[800px]"
           [ Dialog.title ~class_:"sr-only" dialog [ Node.text "Settings" ]
           ; Dialog.description
               ~class_:"sr-only"
               dialog
               [ Node.text "Customize your settings here." ]
           ; Sidebar.provider
               ~class_:"items-start"
               sidebar
               [ Sidebar.root
                   ~collapsible:None
                   ~class_:"hidden md:flex"
                   sidebar
                   [ Sidebar.content
                       [ Sidebar.group
                           [ Sidebar.group_content
                               [ Sidebar.menu
                                   (List.map nav ~f:(fun (name, icon) ->
                                      Sidebar.menu_item
                                        [ Sidebar.menu_button
                                            ~href:"#"
                                            ~is_active:
                                              (String.equal name "Messages & media")
                                            [ Icon.view icon
                                            ; Node.span [ Node.text name ]
                                            ]
                                        ]))
                               ]
                           ]
                       ]
                   ]
               ; Node.main
                   ~attrs:
                     [ Attr.class_
                         "flex h-[480px] flex-1 flex-col overflow-hidden"
                     ]
                   [ Node.header
                       ~attrs:
                         [ Attr.class_
                             "flex h-16 shrink-0 items-center gap-2 \
                              transition-[width,height] ease-linear \
                              group-has-data-[collapsible=icon]/sidebar-wrapper:h-12"
                         ]
                       [ Node.div
                           ~attrs:[ Attr.class_ "flex items-center gap-2 px-4" ]
                           [ Breadcrumb.root
                               [ Breadcrumb.list
                                   [ Breadcrumb.item
                                       ~class_:"hidden md:block"
                                       [ Breadcrumb.link
                                           ~href:"#"
                                           [ Node.text "Settings" ]
                                       ]
                                   ; Breadcrumb.separator
                                       ~class_:"hidden md:block"
                                       ()
                                   ; Breadcrumb.item
                                       [ Breadcrumb.page
                                           [ Node.text "Messages & media" ]
                                       ]
                                   ]
                               ]
                           ]
                       ]
                   ; Node.div
                       ~attrs:
                         [ Attr.class_
                             "flex flex-1 flex-col gap-4 overflow-y-auto p-4 \
                              pt-0"
                         ]
                       (List.init 10 ~f:(fun _ ->
                          Node.div
                            ~attrs:
                              [ Attr.class_
                                  "aspect-video max-w-3xl rounded-xl bg-muted/50"
                              ]
                            []))
                   ]
               ]
           ]
       ])
    graph
;;

let view (local_ graph) =
  let settings_dialog = settings_dialog graph in
  let%arr settings_dialog in
  Node.div
    ~attrs:[ Attr.class_ "flex h-svh items-center justify-center" ]
    [ settings_dialog ]
;;
