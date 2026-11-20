open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "dropdown_menu"

(*$ Account menu *)
let account (local_ graph) =
  Dropdown_menu.component
    ~trigger:(fun attrs ->
      Button.view ~attrs ~variant:Outline [ Icon.view User; Node.text "My account" ])
    (Bonsai.return
       Dropdown_menu.Item.
         [ label "Signed in as lloyd"
         ; action ~icon:User ~shortcut:"⇧⌘P" ~on_select:Effect.Ignore "Profile"
         ; action ~icon:Settings ~shortcut:"⌘," ~on_select:Effect.Ignore "Settings"
         ; action ~icon:Bell ~on_select:Effect.Ignore "Notifications"
         ; separator
         ; action ~icon:Github ~on_select:Effect.Ignore "GitHub"
         ; action ~icon:Mail ~disabled:true ~on_select:Effect.Ignore "Support"
         ; separator
         ; action ~icon:Arrow_right ~danger:true ~shortcut:"⇧⌘Q" ~on_select:Effect.Ignore
             "Log out"
         ])
    graph
(*$*)

(*$ Checkbox and radio items
   Checkbox and radio items keep the menu open, so several can be changed. *)
let view_options (local_ graph) =
  let status_bar, set_status_bar = Bonsai.state true graph in
  let panel, set_panel = Bonsai.state false graph in
  let density, set_density = Bonsai.state "Comfortable" graph in
  let items =
    let%arr status_bar and set_status_bar and panel and set_panel and density
    and set_density in
    Dropdown_menu.Item.(
      [ label "Appearance"
      ; checkbox ~checked:status_bar ~on_change:set_status_bar "Status bar"
      ; checkbox ~checked:panel ~on_change:set_panel "Side panel"
      ; separator
      ; label "Density"
      ]
      @ List.map [ "Compact"; "Comfortable"; "Spacious" ] ~f:(fun d ->
        radio ~selected:(String.equal d density) ~on_select:(set_density d) d))
  in
  Dropdown_menu.component
    ~align:End
    ~trigger:(fun attrs ->
      Button.view ~attrs ~variant:Outline ~size:Icon [ Icon.view More_horizontal ])
    items
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Dropdown menu"
    ~group:Overlays
    ~description:"A menu of actions, toggles and choices opened from a button."
    ~usage:
      {|Dropdown_menu.component
  ~trigger:(fun attrs -> Button.view ~attrs [ Node.text "Open" ])
  (Bonsai.return
     Dropdown_menu.Item.
       [ action ~icon:Pencil ~shortcut:"⌘E" ~on_select:edit "Edit"
       ; separator
       ; action ~danger:true ~on_select:delete "Delete"
       ])
  graph|}
    ~body:
      [ Doc.h2 "Items"
      ; Doc.props
          [ ( "action"
            , "?icon ?shortcut ?disabled ?danger ~on_select label"
            , "Runs on_select and closes the menu." )
          ; "checkbox", "?disabled ~checked ~on_change label", "A toggle with a check mark."
          ; "radio", "?disabled ~selected ~on_select label", "One of a set of choices."
          ; "label", "string", "A heading for the items after it."
          ; "separator", "", "A line between groups of items."
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p
          "On the trigger, Enter, Space or the arrow keys open the menu. In it, the arrows, \
           Home and End move, a letter jumps to the next item starting with it, Enter or \
           Space chooses, and Esc or Tab closes it."
      ]
    [ Doc.example ~page "Account menu" account
    ; Doc.example ~page "Checkbox and radio items" view_options
    ]
;;
