open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "menubar"

(*$ Demo *)
let demo (local_ graph) =
  let bookmarks_bar, set_bookmarks_bar = Bonsai.state false graph in
  let full_urls, set_full_urls = Bonsai.state true graph in
  let profile, set_profile = Bonsai.state "benoit" graph in
  Menubar.component
    ~class_:"w-72"
    (let%arr bookmarks_bar and set_bookmarks_bar and full_urls and set_full_urls
     and profile and set_profile in
     let item ?disabled ?inset ?shortcut text =
       Menubar.item
         ?disabled
         ?inset
         (Node.text text
          :: Option.to_list
               (Option.map shortcut ~f:(fun s -> Menubar.shortcut [ Node.text s ])))
     in
     let group = Menubar.group in
     [ Menubar.menu
         (Menubar.trigger [ Node.text "File" ])
         (Menubar.content
            [ group
                [ item "New Tab" ~shortcut:"⌘T"
                ; item "New Window" ~shortcut:"⌘N"
                ; item ~disabled:true "New Incognito Window"
                ]
            ; Menubar.separator ()
            ; group
                [ Menubar.sub
                    (Menubar.sub_trigger [ Node.text "Share" ])
                    (Menubar.sub_content
                       [ group [ item "Email link"; item "Messages"; item "Notes" ] ])
                ]
            ; Menubar.separator ()
            ; group [ item "Print..." ~shortcut:"⌘P" ]
            ])
     ; Menubar.menu
         (Menubar.trigger [ Node.text "Edit" ])
         (Menubar.content
            [ group [ item "Undo" ~shortcut:"⌘Z"; item "Redo" ~shortcut:"⇧⌘Z" ]
            ; Menubar.separator ()
            ; group
                [ Menubar.sub
                    (Menubar.sub_trigger [ Node.text "Find" ])
                    (Menubar.sub_content
                       [ group [ item "Search the web" ]
                       ; Menubar.separator ()
                       ; group [ item "Find..."; item "Find Next"; item "Find Previous" ]
                       ])
                ]
            ; Menubar.separator ()
            ; group [ item "Cut"; item "Copy"; item "Paste" ]
            ])
     ; Menubar.menu
         (Menubar.trigger [ Node.text "View" ])
         (Menubar.content
            ~class_:"w-44"
            [ group
                [ Menubar.checkbox_item
                    ~checked:bookmarks_bar
                    ~on_checked_change:set_bookmarks_bar
                    [ Node.text "Bookmarks Bar" ]
                ; Menubar.checkbox_item
                    ~checked:full_urls
                    ~on_checked_change:set_full_urls
                    [ Node.text "Full URLs" ]
                ]
            ; Menubar.separator ()
            ; group
                [ item ~inset:true "Reload" ~shortcut:"⌘R"
                ; item ~disabled:true ~inset:true "Force Reload" ~shortcut:"⇧⌘R"
                ]
            ; Menubar.separator ()
            ; group [ item ~inset:true "Toggle Fullscreen" ]
            ; Menubar.separator ()
            ; group [ item ~inset:true "Hide Sidebar" ]
            ])
     ; Menubar.menu
         (Menubar.trigger [ Node.text "Profiles" ])
         (Menubar.content
            [ Menubar.radio_group
                ~value:profile
                ~on_value_change:set_profile
                [ Menubar.radio_item ~value:"andy" [ Node.text "Andy" ]
                ; Menubar.radio_item ~value:"benoit" [ Node.text "Benoit" ]
                ; Menubar.radio_item ~value:"Luis" [ Node.text "Luis" ]
                ]
            ; Menubar.separator ()
            ; group [ item ~inset:true "Edit..." ]
            ; Menubar.separator ()
            ; group [ item ~inset:true "Add Profile..." ]
            ])
     ])
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Menubar"
    ~description:
      "A visually persistent menu common in desktop applications that provides quick \
       access to a consistent set of commands."
    ~usage:
      {|Menubar.component
  (return
     [ Menubar.menu
         (Menubar.trigger [ Node.text "File" ])
         (Menubar.content
            [ Menubar.item ~on_select:new_tab
                [ Node.text "New Tab"; Menubar.shortcut [ Node.text "⌘T" ] ]
            ; Menubar.item ~on_select:new_window [ Node.text "New Window" ]
            ; Menubar.separator ()
            ; Menubar.item ~on_select:share [ Node.text "Share" ]
            ])
     ])
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "state"
            , "Menubar.State.t"
            , "[Menubar.view]: the open menu's value, the trigger with the tab stop and \
               the open menu's highlight, and [~on_change]. [Menubar.component] keeps \
               it." )
          ; ( "value"
            , "string"
            , "[menu]: names the menu in the state (by default its index)." )
          ; ( "side, side_offset, align, align_offset"
            , "Popper.Side.t, float, Popper.Align.t, float"
            , "[content]: where it opens ([Bottom], 8px, [Start], -4px by default)." )
          ; "variant", "Menu.Variant.t", "[item]: [Default] or [Destructive]."
          ; ( "inset"
            , "bool"
            , "[item], [label], [sub_trigger]: indented to line up with checkbox items." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "ArrowLeft / ArrowRight"
            ; Doc.text
                "Move between the triggers; in an open menu, open the previous or next \
                 menu."
            ]
          ; [ Doc.text "Enter / Space / ArrowDown"
            ; Doc.text "On a trigger: open its menu, highlighting the first item."
            ]
          ; [ Doc.text "ArrowUp / ArrowDown"; Doc.text "Highlight the previous or next item." ]
          ; [ Doc.text "Enter / Space"; Doc.text "Choose the highlighted item." ]
          ; [ Doc.text "Esc"; Doc.text "Close the menu, returning focus to its trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
