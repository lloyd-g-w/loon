open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "input_group"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Input_group.root
        [ Input_group.input ~placeholder:"Search..." ()
        ; Input_group.addon [ Icon.view Search ]
        ; Input_group.addon ~align:Inline_end [ Node.text "12 results" ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"example.com" ~class_:"pl-1!" ()
        ; Input_group.addon [ Input_group.text [ Node.text "https://" ] ]
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.button
                ~class_:"rounded-full"
                ~size:Icon_xs
                ~attrs:[ Attr.title "This is content in a tooltip." ]
                [ Icon.view Info ]
            ]
        ]
    ; Input_group.root
        [ Input_group.textarea ~placeholder:"Ask, Search or Chat..." ()
        ; Input_group.addon
            ~align:Block_end
            [ Input_group.button
                ~variant:Outline
                ~class_:"rounded-full"
                ~size:Icon_xs
                [ Icon.view Plus ]
            ; Input_group.button ~variant:Ghost [ Node.text "Auto" ]
            ; Input_group.text ~class_:"ml-auto" [ Node.text "52% used" ]
            ; Node.div
                ~attrs:
                  [ Attr.role "none"
                  ; Attr.create "data-orientation" "vertical"
                  ; Attr.class_ "h-4 w-px shrink-0 bg-border"
                  ]
                []
            ; Input_group.button
                ~variant:Default
                ~class_:"rounded-full"
                ~size:Icon_xs
                ~disabled:true
                [ Icon.view Arrow_up
                ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Send" ]
                ]
            ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"@shadcn" ()
        ; Input_group.addon
            ~align:Inline_end
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "flex size-4 items-center justify-center rounded-full bg-primary \
                       text-primary-foreground"
                  ]
                [ Icon.view ~class_:"size-3" Check ]
            ]
        ]
    ]
(*$*)

(*$ Icon *)
let icon =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Input_group.root
        [ Input_group.input ~placeholder:"Search..." ()
        ; Input_group.addon [ Icon.view Search ]
        ]
    ; Input_group.root
        [ Input_group.input ~type_:Email ~placeholder:"Enter your email" ()
        ; Input_group.addon [ Icon.view Mail ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"Card number" ()
        ; Input_group.addon [ Icon.view Credit_card ]
        ; Input_group.addon ~align:Inline_end [ Icon.view Check ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"Card number" ()
        ; Input_group.addon ~align:Inline_end [ Icon.view Star; Icon.view Info ]
        ]
    ]
(*$*)

(*$ Text *)
let text =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Input_group.root
        [ Input_group.addon [ Input_group.text [ Node.text "$" ] ]
        ; Input_group.input ~placeholder:"0.00" ()
        ; Input_group.addon ~align:Inline_end [ Input_group.text [ Node.text "USD" ] ]
        ]
    ; Input_group.root
        [ Input_group.addon [ Input_group.text [ Node.text "https://" ] ]
        ; Input_group.input ~placeholder:"example.com" ~class_:"pl-0.5!" ()
        ; Input_group.addon ~align:Inline_end [ Input_group.text [ Node.text ".com" ] ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"Enter your username" ()
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.text [ Node.text "@company.com" ] ]
        ]
    ; Input_group.root
        [ Input_group.textarea ~placeholder:"Enter your message" ()
        ; Input_group.addon
            ~align:Block_end
            [ Input_group.text
                ~class_:"text-xs text-muted-foreground"
                [ Node.text "120 characters left" ]
            ]
        ]
    ]
(*$*)

(*$ Button
   [Input_group.button] is a small [Button] for an addon. *)
let button (local_ graph) =
  let copied, set_copied = Bonsai.state false graph in
  let favorite, set_favorite = Bonsai.state false graph in
  let%arr copied and set_copied and favorite and set_favorite in
  let copy text =
    Effect.Many
      [ Effect.of_thunk (fun () ->
          let open Js_of_ocaml in
          ignore
            (Js.Unsafe.global##.navigator##.clipboard##writeText (Js.string text)
             : Js.Unsafe.any))
      ; set_copied true
      ]
  in
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Input_group.root
        [ Input_group.input
            ~placeholder:"https://x.com/shadcn"
            ~attrs:[ Attr.create "readonly" "" ]
            ()
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.button
                ~attrs:[ Attr.create "aria-label" "Copy"; Attr.title "Copy" ]
                ~size:Icon_xs
                ~on_click:(copy "https://x.com/shadcn")
                [ Icon.view (if copied then Check else Copy) ]
            ]
        ]
    ; Input_group.root
        ~class_:"[--radius:9999px]"
        [ Input_group.addon
            [ Input_group.button ~variant:Secondary ~size:Icon_xs [ Icon.view Info ] ]
        ; Input_group.addon
            ~class_:"pl-1.5 text-muted-foreground"
            [ Node.text "https://" ]
        ; Input_group.input ~id:"input-secure-19" ()
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.button
                ~on_click:(set_favorite (not favorite))
                ~size:Icon_xs
                [ Icon.view
                    ~attrs:[ Attr.create "data-favorite" (Bool.to_string favorite) ]
                    ~class_:
                      "data-[favorite=true]:fill-blue-600 \
                       data-[favorite=true]:stroke-blue-600"
                    Star
                ]
            ]
        ]
    ; Input_group.root
        [ Input_group.input ~placeholder:"Type to search..." ()
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.button ~variant:Secondary [ Node.text "Search" ] ]
        ]
    ]
(*$*)

(*$ Spinner *)
let spinner =
  let spinner =
    Icon.view
      ~attrs:[ Attr.role "status"; Attr.create "aria-label" "Loading" ]
      ~class_:"size-4 animate-spin"
      Loader_circle
  in
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-4" ]
    [ Input_group.root
        ~disabled:true
        [ Input_group.input ~placeholder:"Searching..." ~disabled:true ()
        ; Input_group.addon ~align:Inline_end [ spinner ]
        ]
    ; Input_group.root
        ~disabled:true
        [ Input_group.input ~placeholder:"Processing..." ~disabled:true ()
        ; Input_group.addon [ spinner ]
        ]
    ; Input_group.root
        ~disabled:true
        [ Input_group.input ~placeholder:"Saving changes..." ~disabled:true ()
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.text [ Node.text "Saving..." ]; spinner ]
        ]
    ; Input_group.root
        ~disabled:true
        [ Input_group.input ~placeholder:"Refreshing data..." ~disabled:true ()
        ; Input_group.addon [ Icon.view ~class_:"animate-spin" Loader ]
        ; Input_group.addon
            ~align:Inline_end
            [ Input_group.text
                ~class_:"text-muted-foreground"
                [ Node.text "Please wait..." ]
            ]
        ]
    ]
(*$*)

(*$ Textarea
   Addons above and below a textarea span its width. *)
let textarea =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-md gap-4" ]
    [ Input_group.root
        [ Input_group.textarea
            ~id:"textarea-code-32"
            ~placeholder:"console.log('Hello, world!');"
            ~class_:"min-h-[200px]"
            ()
        ; Input_group.addon
            ~align:Block_end
            ~class_:"border-t"
            [ Input_group.text [ Node.text "Line 1, Column 1" ]
            ; Input_group.button
                ~size:Sm
                ~class_:"ml-auto"
                ~variant:Default
                [ Node.text "Run"; Icon.view Corner_down_left ]
            ]
        ; Input_group.addon
            ~align:Block_start
            ~class_:"border-b"
            [ Input_group.text
                ~class_:"font-mono font-medium"
                [ Icon.view File_code; Node.text "script.js" ]
            ; Input_group.button ~class_:"ml-auto" ~size:Icon_xs [ Icon.view Refresh_cw ]
            ; Input_group.button ~variant:Ghost ~size:Icon_xs [ Icon.view Copy ]
            ]
        ]
    ]
(*$*)

(*$ Label *)
let label =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-4" ]
    [ Input_group.root
        [ Input_group.input ~id:"email" ~placeholder:"shadcn" ()
        ; Input_group.addon [ Label.view ~for_:"email" [ Node.text "@" ] ]
        ]
    ; Input_group.root
        [ Input_group.input ~id:"email-2" ~placeholder:"shadcn@vercel.com" ()
        ; Input_group.addon
            ~align:Block_start
            [ Label.view ~for_:"email-2" ~class_:"text-foreground" [ Node.text "Email" ]
            ; Input_group.button
                ~variant:Ghost
                ~attrs:
                  [ Attr.create "aria-label" "Help"
                  ; Attr.title "We'll use this to send you notifications"
                  ]
                ~class_:"ml-auto rounded-full"
                ~size:Icon_xs
                [ Icon.view Info ]
            ]
        ]
    ]
(*$*)

(*$ Button Group
   An input group sits in a [Button_group] like a button. *)
let button_group =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Button_group.root
        [ Button_group.text [ Label.view ~for_:"url" [ Node.text "https://" ] ]
        ; Input_group.root
            [ Input_group.input ~id:"url" ()
            ; Input_group.addon ~align:Inline_end [ Icon.view Link_2 ]
            ]
        ; Button_group.text [ Node.text ".com" ]
        ]
    ]
(*$*)

(*$ Custom Input
   Any control with [data-slot="input-group-control"] takes the group's
   focus ring; here a textarea that grows with its text. *)
let custom =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full max-w-sm gap-6" ]
    [ Input_group.root
        [ Node.textarea
            ~attrs:
              [ Attr.create "data-slot" "input-group-control"
              ; Attr.class_
                  "flex field-sizing-content min-h-16 w-full resize-none rounded-md \
                   bg-transparent px-3 py-2.5 text-base transition-[color,box-shadow] \
                   outline-none md:text-sm"
              ; Attr.placeholder "Autoresize textarea..."
              ]
            []
        ; Input_group.addon
            ~align:Block_end
            [ Input_group.button
                ~class_:"ml-auto"
                ~size:Sm
                ~variant:Default
                [ Node.text "Submit" ]
            ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Input Group"
    ~description:"Display additional information or actions to an input or textarea."
    ~usage:
      {|Input_group.root
  [ Input_group.input ~placeholder:"Search..." ()
  ; Input_group.addon [ Icon.view Search ]
  ; Input_group.addon ~align:Inline_end [ Node.text "12 results" ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "align"
            , "Input_group.Align.t"
            , "Where an addon goes: [Inline_start] (by default) or [Inline_end] in the \
               row, [Block_start] or [Block_end] above or below." )
          ; ( "size"
            , "Input_group.Button_size.t"
            , "A button's size: [Xs] (by default), [Sm], [Icon_xs] or [Icon_sm]." )
          ; "variant", "Button.Variant.t", "A button's variant; [Ghost] by default."
          ; "disabled", "bool", "On [root]: fades the addons (disable the input too)."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Input_group.input] and [Input_group.textarea] take the arguments of [Input] \
           and [Textarea]. Put addons after the control in the list: their [align] \
           orders them, so the focus order follows the source."
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Icon" icon
    ; Doc.static ~page "Text" text
    ; Doc.example ~page "Button" button
    ; Doc.static ~page "Spinner" spinner
    ; Doc.static ~page "Textarea" textarea
    ; Doc.static ~page "Label" label
    ; Doc.static ~page "Button Group" button_group
    ; Doc.static ~page "Custom Input" custom
    ]
;;
