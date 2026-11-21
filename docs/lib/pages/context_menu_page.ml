open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "context_menu"

(*$ Demo *)
let demo (local_ graph) =
  let bookmarks, set_bookmarks = Bonsai.state true graph in
  let full_urls, set_full_urls = Bonsai.state false graph in
  let person, set_person = Bonsai.state "pedro" graph in
  Context_menu.component
    (let%arr bookmarks and set_bookmarks and full_urls and set_full_urls and person
     and set_person in
     fun menu ->
       let item ?disabled ?shortcut ?variant ?inset text =
         Context_menu.item
           ?disabled
           ?variant
           ?inset
           (Node.text text
            :: Option.to_list
                 (Option.map shortcut ~f:(fun s -> Context_menu.shortcut [ Node.text s ])))
       in
       [ Context_menu.trigger
           menu
           ~class_:
             "flex h-[150px] w-[300px] items-center justify-center rounded-md border \
              border-dashed text-sm"
           [ Node.text "Right click here" ]
       ; Context_menu.content
           menu
           ~class_:"w-52"
           [ item ~inset:true "Back" ~shortcut:"⌘["
           ; item ~inset:true ~disabled:true "Forward" ~shortcut:"⌘]"
           ; item ~inset:true "Reload" ~shortcut:"⌘R"
           ; Context_menu.sub
               (Context_menu.sub_trigger ~inset:true [ Node.text "More Tools" ])
               (Context_menu.sub_content
                  ~class_:"w-44"
                  [ item "Save Page..."
                  ; item "Create Shortcut..."
                  ; item "Name Window..."
                  ; Context_menu.separator ()
                  ; item "Developer Tools"
                  ; Context_menu.separator ()
                  ; item ~variant:Destructive "Delete"
                  ])
           ; Context_menu.separator ()
           ; Context_menu.checkbox_item
               ~checked:bookmarks
               ~on_checked_change:set_bookmarks
               [ Node.text "Show Bookmarks" ]
           ; Context_menu.checkbox_item
               ~checked:full_urls
               ~on_checked_change:set_full_urls
               [ Node.text "Show Full URLs" ]
           ; Context_menu.separator ()
           ; Context_menu.radio_group
               ~value:person
               ~on_value_change:set_person
               [ Context_menu.label ~inset:true [ Node.text "People" ]
               ; Context_menu.radio_item ~value:"pedro" [ Node.text "Pedro Duarte" ]
               ; Context_menu.radio_item ~value:"colm" [ Node.text "Colm Tuite" ]
               ]
           ]
       ])
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Context menu"
    ~group:Overlays
    ~description:
      "Displays a menu to the user — such as a set of actions or functions — triggered \
       by a right click."
    ~usage:
      {|Context_menu.component
  (return (fun menu ->
     [ Context_menu.trigger menu [ Node.text "Right click" ]
     ; Context_menu.content menu
         [ Context_menu.item ~on_select:profile [ Node.text "Profile" ]
         ; Context_menu.item ~on_select:billing [ Node.text "Billing" ]
         ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "state"
            , "Context_menu.State.t"
            , "[Context_menu.view]: [Closed], or [Open] at a point of the viewport (with \
               the highlighted item), and [~on_change]. [Context_menu.component] keeps \
               it." )
          ; ( "modal"
            , "bool"
            , "Default [true]: while open, the page ignores the pointer and does not \
               scroll." )
          ; ( "disabled"
            , "bool"
            , "[trigger]: a right click shows the browser's own menu instead." )
          ; "variant", "Menu.Variant.t", "[item]: [Default] or [Destructive]."
          ; ( "inset"
            , "bool"
            , "[item], [label], [sub_trigger]: indented to line up with checkbox items." )
          ; ( "close_on_select"
            , "bool"
            , "Default [true]: choosing the item closes the menu." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "ArrowUp / ArrowDown"; Doc.text "Highlight the previous or next item." ]
          ; [ Doc.text "Home / End"; Doc.text "Highlight the first or last item." ]
          ; [ Doc.text "A letter"; Doc.text "Highlight the next item starting with it." ]
          ; [ Doc.text "ArrowRight / ArrowLeft"; Doc.text "Open or close a sub-menu." ]
          ; [ Doc.text "Enter / Space"; Doc.text "Choose the highlighted item." ]
          ; [ Doc.text "Esc"; Doc.text "Close the menu." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
