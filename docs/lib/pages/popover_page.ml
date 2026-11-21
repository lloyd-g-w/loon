open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "popover"

(*$ Demo *)
let demo (local_ graph) =
  let field id label value =
    Node.div
      ~attrs:[ Attr.class_ "grid grid-cols-3 items-center gap-4" ]
      [ Node.label
          ~attrs:
            [ Attr.for_ id
            ; Attr.class_ "flex items-center gap-2 text-sm leading-none font-medium select-none"
            ]
          [ Node.text label ]
      ; Node.input
          ~attrs:
            [ Attr.id id
            ; Attr.value value
            ; Attr.class_
                "col-span-2 h-8 w-full min-w-0 rounded-md border border-input \
                 bg-transparent px-3 py-1 text-base shadow-xs outline-none \
                 focus-visible:border-ring focus-visible:ring-[3px] \
                 focus-visible:ring-ring/50 md:text-sm dark:bg-input/30"
            ]
          ()
      ]
  in
  Popover.component
    (Bonsai.return (fun popover ->
       [ Popover.trigger popover (Button.view ~variant:Outline [ Node.text "Open popover" ])
       ; Popover.content
           popover
           ~class_:"w-80"
           [ Node.div
               ~attrs:[ Attr.class_ "grid gap-4" ]
               [ Node.div
                   ~attrs:[ Attr.class_ "space-y-2" ]
                   [ Node.h4
                       ~attrs:[ Attr.class_ "leading-none font-medium" ]
                       [ Node.text "Dimensions" ]
                   ; Node.p
                       ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
                       [ Node.text "Set the dimensions for the layer." ]
                   ]
               ; Node.div
                   ~attrs:[ Attr.class_ "grid gap-2" ]
                   [ field "width" "Width" "100%"
                   ; field "maxWidth" "Max. width" "300px"
                   ; field "height" "Height" "25px"
                   ; field "maxHeight" "Max. height" "none"
                   ]
               ]
           ]
       ]))
    graph
(*$*)

(*$ Header and side
   [Popover.header], [title] and [description]; [~side] and [~align] place
   the content. *)
let header (local_ graph) =
  Popover.component
    (Bonsai.return (fun popover ->
       [ Popover.trigger popover (Button.view ~variant:Outline [ Node.text "Open on the right" ])
       ; Popover.content
           popover
           ~side:Right
           ~align:Start
           [ Popover.header
               [ Popover.title [ Node.text "Title" ]
               ; Popover.description [ Node.text "Description text here." ]
               ]
           ]
       ]))
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Popover"
    ~description:"Displays rich content in a portal, triggered by a button."
    ~usage:
      {|Popover.component
  (return (fun popover ->
     [ Popover.trigger popover (Button.view ~variant:Outline [ Node.text "Open" ])
     ; Popover.content popover [ Node.text "Place content for the popover here." ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Popover.view]: controlled. [Popover.component] keeps it \
               ([?default_open])." )
          ; ( "modal"
            , "bool"
            , "Default [false]. While open, the page ignores the pointer and focus \
               stays inside the content." )
          ; ( "side, side_offset, align, align_offset"
            , "Popper.Side.t, float, Popper.Align.t, float"
            , "[content]: where it opens ([Bottom], 4px, [Center] by default); it flips \
               and shifts to stay in view ([?avoid_collisions])." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Enter / Space"; Doc.text "On the trigger: open or close it." ]
          ; [ Doc.text "Tab"; Doc.text "Moves through the content (leaving it closes it)." ]
          ; [ Doc.text "Esc"; Doc.text "Close, returning focus to the trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Header and side" header ]
;;
