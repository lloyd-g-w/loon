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
           ~class_:"w-56"
           ~align:Start
           [ Dropdown_menu.label [ Node.text "My Account" ]
           ; Dropdown_menu.group
               [ item "Profile" ~shortcut:"⇧⌘P"
               ; item "Billing" ~shortcut:"⌘B"
               ; item "Settings" ~shortcut:"⌘S"
               ; item "Keyboard shortcuts" ~shortcut:"⌘K"
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
           ; item "GitHub"
           ; item "Support"
           ; item "API" ~disabled:true
           ; Dropdown_menu.separator ()
           ; item "Log out" ~shortcut:"⇧⌘Q"
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

let page =
  Doc.page
    ~slug:page
    ~title:"Dropdown menu"
    ~group:Overlays
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
    ]
;;
