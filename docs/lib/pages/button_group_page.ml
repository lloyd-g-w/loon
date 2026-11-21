open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "button_group"

(*$ Demo
   Groups nest: a group of groups spaces them apart. *)
let demo =
  Button_group.root
    [ Button_group.root
        ~class_:"hidden sm:flex"
        [ Button.view
            ~variant:Outline
            ~size:Icon
            ~attrs:[ Attr.create "aria-label" "Go Back" ]
            [ Icon.view Arrow_left ]
        ]
    ; Button_group.root
        [ Button.view ~variant:Outline [ Node.text "Archive" ]
        ; Button.view ~variant:Outline [ Node.text "Report" ]
        ]
    ; Button_group.root
        [ Button.view ~variant:Outline [ Node.text "Snooze" ]
        ; Button.view
            ~variant:Outline
            ~size:Icon
            ~attrs:[ Attr.create "aria-label" "More Options" ]
            [ Icon.view Ellipsis ]
        ]
    ]
(*$*)

(*$ Orientation *)
let orientation =
  Button_group.root
    ~orientation:Vertical
    ~attrs:[ Attr.create "aria-label" "Media controls" ]
    ~class_:"h-fit"
    [ Button.view ~variant:Outline ~size:Icon [ Icon.view Plus ]
    ; Button.view ~variant:Outline ~size:Icon [ Icon.view Minus ]
    ]
(*$*)

(*$ Size
   Give every button the same [size]. *)
let size =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-start gap-8" ]
    [ Button_group.root
        [ Button.view ~variant:Outline ~size:Sm [ Node.text "Small" ]
        ; Button.view ~variant:Outline ~size:Sm [ Node.text "Button" ]
        ; Button.view ~variant:Outline ~size:Sm [ Node.text "Group" ]
        ; Button.view ~variant:Outline ~size:Icon_sm [ Icon.view Plus ]
        ]
    ; Button_group.root
        [ Button.view ~variant:Outline [ Node.text "Default" ]
        ; Button.view ~variant:Outline [ Node.text "Button" ]
        ; Button.view ~variant:Outline [ Node.text "Group" ]
        ; Button.view ~variant:Outline ~size:Icon [ Icon.view Plus ]
        ]
    ; Button_group.root
        [ Button.view ~variant:Outline ~size:Lg [ Node.text "Large" ]
        ; Button.view ~variant:Outline ~size:Lg [ Node.text "Button" ]
        ; Button.view ~variant:Outline ~size:Lg [ Node.text "Group" ]
        ; Button.view ~variant:Outline ~size:Icon_lg [ Icon.view Plus ]
        ]
    ]
(*$*)

(*$ Nested *)
let nested =
  Button_group.root
    [ Button_group.root
        (List.map [ "1"; "2"; "3"; "4"; "5" ] ~f:(fun n ->
           Button.view ~variant:Outline ~size:Sm [ Node.text n ]))
    ; Button_group.root
        [ Button.view
            ~variant:Outline
            ~size:Icon_sm
            ~attrs:[ Attr.create "aria-label" "Previous" ]
            [ Icon.view Arrow_left ]
        ; Button.view
            ~variant:Outline
            ~size:Icon_sm
            ~attrs:[ Attr.create "aria-label" "Next" ]
            [ Icon.view Arrow_right ]
        ]
    ]
(*$*)

(*$ Separator
   Buttons without a border ([Secondary]) need a separator between them. *)
let separator =
  Button_group.root
    [ Button.view ~variant:Secondary ~size:Sm [ Node.text "Copy" ]
    ; Button_group.separator ()
    ; Button.view ~variant:Secondary ~size:Sm [ Node.text "Paste" ]
    ]
(*$*)

(*$ Split *)
let split =
  Button_group.root
    [ Button.view ~variant:Secondary [ Node.text "Button" ]
    ; Button_group.separator ()
    ; Button.view ~size:Icon ~variant:Secondary [ Icon.view Plus ]
    ]
(*$*)

(*$ Input *)
let input =
  Button_group.root
    [ Input.view ~placeholder:"Search..." ()
    ; Button.view
        ~variant:Outline
        ~attrs:[ Attr.create "aria-label" "Search" ]
        [ Icon.view Search ]
    ]
(*$*)

(*$ Input Group *)
let input_group (local_ graph) =
  let voice_enabled, set_voice_enabled = Bonsai.state false graph in
  let%arr voice_enabled and set_voice_enabled in
  Button_group.root
    ~class_:"[--radius:9999rem]"
    [ Button_group.root [ Button.view ~variant:Outline ~size:Icon [ Icon.view Plus ] ]
    ; Button_group.root
        [ Input_group.root
            [ Input_group.input
                ~placeholder:
                  (if voice_enabled
                   then "Record and send audio..."
                   else "Send a message...")
                ~disabled:voice_enabled
                ()
            ; Input_group.addon
                ~align:Inline_end
                [ Input_group.button
                    ~on_click:(set_voice_enabled (not voice_enabled))
                    ~size:Icon_xs
                    ~attrs:
                      [ Attr.create "data-active" (Bool.to_string voice_enabled)
                      ; Attr.create "aria-pressed" (Bool.to_string voice_enabled)
                      ; Attr.title "Voice Mode"
                      ]
                    ~class_:
                      "data-[active=true]:bg-orange-100 \
                       data-[active=true]:text-orange-700 \
                       dark:data-[active=true]:bg-orange-800 \
                       dark:data-[active=true]:text-orange-100"
                    [ Icon.view Audio_lines ]
                ]
            ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Button Group"
    ~description:
      "A container that groups related buttons together with consistent styling."
    ~usage:
      {|Button_group.root
  [ Button.view ~variant:Outline [ Node.text "Archive" ]
  ; Button.view ~variant:Outline [ Node.text "Report" ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "orientation"
            , "Button_group.Orientation.t"
            , "[Horizontal] (by default) or [Vertical]." )
          ; "class_", "string", "More Tailwind classes, merged last."
          ; ( "attrs"
            , "Vdom.Attr.t list"
            , "Extra attributes (an aria-label says what the group is for)." )
          ]
      ; Doc.p
          "[Button_group.separator ()] draws a line between buttons; \
           [Button_group.text] is text boxed like a button; [Button_group.classes] \
           gives the group's classes for another element."
      ; Doc.note
          ~title:"Button Group or Toggle Group?"
          [ Doc.text
              "Use Button Group for buttons that do something; Toggle Group for buttons \
               that turn a state on and off."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Orientation" orientation
    ; Doc.static ~page "Size" size
    ; Doc.static ~page "Nested" nested
    ; Doc.static ~page "Separator" separator
    ; Doc.static ~page "Split" split
    ; Doc.static ~page "Input" input
    ; Doc.example ~page "Input Group" input_group
    ]
;;
