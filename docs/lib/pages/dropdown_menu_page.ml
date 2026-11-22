open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "dropdown_menu"

(*$ Demo *)
let demo (local_ graph) =
  let item ?disabled ?shortcut text =
    Dropdown_menu.item
      ?disabled
      (Node.text text
       :: Option.to_list
            (Option.map shortcut ~f:(fun s -> Dropdown_menu.shortcut [ Node.text s ])))
  in
  Dropdown_menu.component
    (Bonsai.return (fun menu ->
       [ Dropdown_menu.trigger menu (Button.view ~variant:Outline [ Node.text "Open" ])
       ; Dropdown_menu.content
           menu
           ~class_:"w-40"
           ~align:Start
           [ Dropdown_menu.group
               [ Dropdown_menu.label [ Node.text "My Account" ]
               ; item "Profile" ~shortcut:"⇧⌘P"
               ; item "Billing" ~shortcut:"⌘B"
               ; item "Settings" ~shortcut:"⌘S"
               ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.group
               [ item "Team"
               ; Dropdown_menu.sub
                   (Dropdown_menu.sub_trigger [ Node.text "Invite users" ])
                   (Dropdown_menu.sub_content
                      [ item "Email"
                      ; item "Message"
                      ; Dropdown_menu.separator ()
                      ; item "More..."
                      ])
               ; item "New Team" ~shortcut:"⌘+T"
               ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.group
               [ item "GitHub"; item "Support"; item "API" ~disabled:true ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.group [ item "Log out" ~shortcut:"⇧⌘Q" ]
           ]
       ]))
    graph
(*$*)

(*$ Checkboxes *)
let checkboxes (local_ graph) =
  let status_bar, set_status_bar = Bonsai.state true graph in
  let activity_bar, set_activity_bar = Bonsai.state false graph in
  let panel, set_panel = Bonsai.state false graph in
  Dropdown_menu.component
    (let%arr status_bar and set_status_bar and activity_bar and set_activity_bar
     and panel and set_panel in
     fun menu ->
       [ Dropdown_menu.trigger menu (Button.view ~variant:Outline [ Node.text "Open" ])
       ; Dropdown_menu.content
           menu
           ~class_:"w-56"
           [ Dropdown_menu.label [ Node.text "Appearance" ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.checkbox_item
               ~checked:status_bar
               ~on_checked_change:set_status_bar
               [ Node.text "Status Bar" ]
           ; Dropdown_menu.checkbox_item
               ~checked:activity_bar
               ~on_checked_change:set_activity_bar
               ~disabled:true
               [ Node.text "Activity Bar" ]
           ; Dropdown_menu.checkbox_item
               ~checked:panel
               ~on_checked_change:set_panel
               [ Node.text "Panel" ]
           ]
       ])
    graph
(*$*)

(*$ Radio Group *)
let radio_group (local_ graph) =
  let position, set_position = Bonsai.state "bottom" graph in
  Dropdown_menu.component
    (let%arr position and set_position in
     fun menu ->
       [ Dropdown_menu.trigger menu (Button.view ~variant:Outline [ Node.text "Open" ])
       ; Dropdown_menu.content
           menu
           ~class_:"w-56"
           [ Dropdown_menu.label [ Node.text "Panel Position" ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.radio_group
               ~value:position
               ~on_value_change:set_position
               [ Dropdown_menu.radio_item ~value:"top" [ Node.text "Top" ]
               ; Dropdown_menu.radio_item ~value:"bottom" [ Node.text "Bottom" ]
               ; Dropdown_menu.radio_item ~value:"right" [ Node.text "Right" ]
               ]
           ]
       ])
    graph
(*$*)

(*$ Dialog
   An item that opens a dialog: the menu is not modal, and the item sets the
   dialog's state. *)
let dialog (local_ graph) =
  let show_new, set_show_new = Bonsai.state false graph in
  let show_share, set_show_share = Bonsai.state false graph in
  let input_class =
    "h-9 w-full min-w-0 rounded-md border border-input bg-transparent px-3 py-1 \
     text-base shadow-xs transition-[color,box-shadow] outline-none \
     placeholder:text-muted-foreground focus-visible:border-ring \
     focus-visible:ring-[3px] focus-visible:ring-ring/50 md:text-sm dark:bg-input/30"
  in
  let label for_ text =
    Node.label
      ~attrs:
        [ Attr.for_ for_
        ; Attr.class_ "flex items-center gap-2 text-sm leading-none font-medium select-none"
        ]
      [ Node.text text ]
  in
  let field children = Node.div ~attrs:[ Attr.class_ "grid gap-3" ] children in
  let file_dialog ~id ~open_ ~on_open_change ~title ~description ~fields ~submit =
    Dialog.view ~id ~open_ ~on_open_change (fun d ->
      [ Dialog.content
          d
          ~class_:"sm:max-w-[425px]"
          [ Dialog.header
              [ Dialog.title d [ Node.text title ]
              ; Dialog.description d [ Node.text description ]
              ]
          ; Node.div ~attrs:[ Attr.class_ "flex flex-col gap-4 py-3" ] fields
          ; Dialog.footer
              [ Dialog.close d (Button.view ~variant:Outline [ Node.text "Cancel" ])
              ; Button.view ~type_:`Submit [ Node.text submit ]
              ]
          ]
      ])
  in
  Dropdown_menu.component
    ~modal:false
    (let%arr show_new and set_show_new and show_share and set_show_share in
     fun menu ->
       [ Dropdown_menu.trigger
           menu
           (Button.view
              ~variant:Outline
              ~size:Icon_sm
              ~attrs:[ Attr.create "aria-label" "Open menu" ]
              [ Icon.view Ellipsis ])
       ; Dropdown_menu.content
           menu
           ~class_:"w-40"
           ~align:End
           [ Dropdown_menu.label [ Node.text "File Actions" ]
           ; Dropdown_menu.group
               [ Dropdown_menu.item
                   ~on_select:(set_show_new true)
                   [ Node.text "New File..." ]
               ; Dropdown_menu.item
                   ~on_select:(set_show_share true)
                   [ Node.text "Share..." ]
               ; Dropdown_menu.item ~disabled:true [ Node.text "Download" ]
               ]
           ]
       ; file_dialog
           ~id:"new-file-dialog"
           ~open_:show_new
           ~on_open_change:set_show_new
           ~title:"Create New File"
           ~description:
             "Provide a name for your new file. Click create when you're done."
           ~fields:
             [ field
                 [ label "filename" "File Name"
                 ; Node.input
                     ~attrs:
                       [ Attr.id "filename"
                       ; Attr.name "filename"
                       ; Attr.placeholder "document.txt"
                       ; Attr.class_ input_class
                       ]
                     ()
                 ]
             ]
           ~submit:"Create"
       ; file_dialog
           ~id:"share-file-dialog"
           ~open_:show_share
           ~on_open_change:set_show_share
           ~title:"Share File"
           ~description:"Anyone with the link will be able to view this file."
           ~fields:
             [ field
                 [ label "email" "Email Address"
                 ; Node.input
                     ~attrs:
                       [ Attr.id "email"
                       ; Attr.name "email"
                       ; Attr.type_ "email"
                       ; Attr.placeholder "shadcn@vercel.com"
                       ; Attr.create "autocomplete" "off"
                       ; Attr.class_ input_class
                       ]
                     ()
                 ]
             ; field
                 [ label "message" "Message (Optional)"
                 ; Node.textarea
                     ~attrs:
                       [ Attr.id "message"
                       ; Attr.name "message"
                       ; Attr.placeholder "Check out this file"
                       ; Attr.class_
                           "flex field-sizing-content min-h-16 w-full rounded-md border \
                            border-input bg-transparent px-3 py-2 text-base shadow-xs \
                            outline-none placeholder:text-muted-foreground \
                            focus-visible:border-ring focus-visible:ring-[3px] \
                            focus-visible:ring-ring/50 md:text-sm dark:bg-input/30"
                       ]
                     []
                 ]
             ]
           ~submit:"Send Invite"
       ])
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Dropdown menu"
    ~description:
      "Displays a menu to the user — such as a set of actions or functions — triggered \
       by a button."
    ~usage:
      {|Dropdown_menu.component
  (return (fun menu ->
     [ Dropdown_menu.trigger menu (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Dropdown_menu.content menu
         [ Dropdown_menu.label [ Node.text "My Account" ]
         ; Dropdown_menu.separator ()
         ; Dropdown_menu.item ~on_select:profile [ Node.text "Profile" ]
         ; Dropdown_menu.item ~on_select:billing [ Node.text "Billing" ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "state"
            , "Dropdown_menu.State.t"
            , "[Dropdown_menu.view]: [Closed] or [Open] (with the highlighted item), and \
               [~on_change]. [Dropdown_menu.component] keeps it ([?default_open])." )
          ; ( "modal"
            , "bool"
            , "Default [true]: while open, the page ignores the pointer and does not \
               scroll." )
          ; ( "side, side_offset, align, align_offset"
            , "Popper.Side.t, float, Popper.Align.t, float"
            , "[content]: where it opens ([Bottom], 4px, [Center] by default)." )
          ; ( "variant"
            , "Menu.Variant.t"
            , "[item]: [Default] or [Destructive]." )
          ; "inset", "bool", "[item], [label], [sub_trigger]: indented to line up with checkbox items."
          ; ( "close_on_select"
            , "bool"
            , "Default [true]: choosing the item closes the menu." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Enter / Space / ArrowDown"
            ; Doc.text "On the trigger: open, highlighting the first item."
            ]
          ; [ Doc.text "ArrowUp / ArrowDown"; Doc.text "Highlight the previous or next item." ]
          ; [ Doc.text "Home / End"; Doc.text "Highlight the first or last item." ]
          ; [ Doc.text "A letter"; Doc.text "Highlight the next item starting with it." ]
          ; [ Doc.text "ArrowRight / ArrowLeft"; Doc.text "Open or close a sub-menu." ]
          ; [ Doc.text "Enter / Space"; Doc.text "Choose the highlighted item." ]
          ; [ Doc.text "Esc"; Doc.text "Close, returning focus to the trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Checkboxes" checkboxes
    ; Doc.example ~page "Radio Group" radio_group
    ; Doc.example ~page "Dialog" dialog
    ]
;;
