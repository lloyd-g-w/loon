open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "command_palette"

let groups ~(run : string -> unit Effect.t) =
  Command_palette.
    [ Group.create
        ~heading:"Suggestions"
        [ Item.create ~icon:Calendar ~on_select:(run "Calendar") "Calendar"
        ; Item.create ~icon:Search ~keywords:[ "find" ] ~on_select:(run "Search") "Search files"
        ; Item.create ~icon:Inbox ~disabled:true ~on_select:(run "Inbox") "Inbox"
        ]
    ; Group.create
        ~heading:"Settings"
        [ Item.create ~icon:User ~shortcut:"⌘P" ~on_select:(run "Profile") "Profile"
        ; Item.create ~icon:Mail ~shortcut:"⌘B" ~on_select:(run "Mail") "Mail"
        ; Item.create
            ~icon:Settings
            ~keywords:[ "preferences" ]
            ~shortcut:"⌘S"
            ~on_select:(run "Settings")
            "Settings"
        ]
    ]
;;

(*$ Inline *)
let inline (local_ graph) =
  let last, set_last = Bonsai.state "nothing yet" graph in
  let command =
    Command_palette.component
      (let%arr set_last in
       groups ~run:set_last)
      graph
  in
  let%arr command and last in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "flex flex-col gap-3" ]
    [ Node.div
        ~attrs:
          [ Vdom.Attr.style
              (Css_gen.concat
                 [ Css_gen.create ~field:"max-width" ~value:"28rem"
                 ; Css_gen.create ~field:"border" ~value:"1px solid var(--loon-border)"
                 ; Css_gen.create ~field:"border-radius" ~value:"var(--loon-radius-lg)"
                 ; Css_gen.create ~field:"box-shadow" ~value:"var(--loon-shadow)"
                 ])
          ]
        [ command ]
    ; Node.span
        ~attrs:[ Vdom.Attr.class_ "loon-field-description" ]
        [ Node.text ("Ran: " ^ last) ]
    ]
(*$*)

(*$ Palette
   Press Ctrl+K (or ⌘K) anywhere on the page. *)
let palette (local_ graph) =
  let last, set_last = Bonsai.state "nothing yet" graph in
  let palette =
    Command_palette.dialog
      (let%arr set_last in
       groups ~run:set_last)
      graph
  in
  let%arr palette_view, open_palette = palette
  and last in
  Node.div
    ~attrs:
      [ Vdom.Attr.class_ "flex flex-col gap-3"
      ; Vdom.Attr.style (Css_gen.create ~field:"align-items" ~value:"flex-start")
      ]
    [ Button.view
        ~variant:Outline
        ~on_click:open_palette
        [ Icon.view Search
        ; Node.text "Search…"
        ; Node.kbd ~attrs:[ Vdom.Attr.class_ "loon-menu-shortcut" ] [ Node.text "Ctrl K" ]
        ]
    ; Node.span
        ~attrs:[ Vdom.Attr.class_ "loon-field-description" ]
        [ Node.text ("Ran: " ^ last) ]
    ; palette_view
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Command palette"
    ~description:"A search box over a grouped list of commands, fuzzy-filtered as you type."
    ~usage:
      {|let%sub view, open_palette =
  Command_palette.dialog
    (Bonsai.return
       Command_palette.
         [ Group.create ~heading:"Files"
             [ Item.create ~icon:File ~on_select:open_file "Open file" ] ])
    graph|}
    ~body:
      [ Doc.h2 "Items"
      ; Doc.props
          [ "label", "string", "What is shown and searched."
          ; "keywords", "string list", "Other words that find it."
          ; "icon, shortcut", "Icon.t, string", "Shown before and after the label."
          ; "on_select", "unit Effect.t", "What choosing it does."
          ]
      ; Doc.p
          "Typing filters the items fuzzily (the letters in order, preferring word starts \
           and runs), best first within each group. Up and Down move, Enter runs the \
           highlighted item. Command_palette.filter is exposed for using the matching \
           elsewhere."
      ]
    [ Doc.example ~page "Inline" inline; Doc.example ~page "Palette" palette ]
;;
