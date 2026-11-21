open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "scroll_area"

(*$ Demo *)
let tags = List.init 50 ~f:(fun i -> sprintf "v1.2.0-beta.%d" (50 - i))

let demo =
  Scroll_area.root
    ~class_:"h-72 w-48 rounded-md border"
    [ Node.div
        ~attrs:[ Attr.class_ "p-4" ]
        (Node.h4
           ~attrs:[ Attr.class_ "mb-4 text-sm leading-none font-medium" ]
           [ Node.text "Tags" ]
         :: List.concat_map tags ~f:(fun tag ->
           [ Node.div ~attrs:[ Attr.class_ "text-sm" ] [ Node.text tag ]
           ; Separator.view ~attrs:[ Attr.class_ "my-2" ] ()
           ]))
    ]
;;

(*$*)

(*$ Horizontal *)
let works =
  [ ( "Ornella Binni"
    , "https://images.unsplash.com/photo-1465869185982-5a1a7522cbcb?auto=format&fit=crop&w=300&q=80"
    )
  ; ( "Tom Byrom"
    , "https://images.unsplash.com/photo-1548516173-3cabfa4607e9?auto=format&fit=crop&w=300&q=80"
    )
  ; ( "Vladimir Malyavko"
    , "https://images.unsplash.com/photo-1494337480532-3725c85fd2ab?auto=format&fit=crop&w=300&q=80"
    )
  ]
;;

let horizontal =
  Scroll_area.root
    ~class_:"w-96 rounded-md border whitespace-nowrap"
    [ Node.div
        ~attrs:[ Attr.class_ "flex w-max space-x-4 p-4" ]
        (List.map works ~f:(fun (artist, art) ->
           Node.create
             "figure"
             ~attrs:[ Attr.class_ "shrink-0" ]
             [ Node.div
                 ~attrs:[ Attr.class_ "overflow-hidden rounded-md" ]
                 [ Node.img
                     ~attrs:
                       [ Attr.src art
                       ; Attr.alt ("Photo by " ^ artist)
                       ; Attr.class_ "aspect-[3/4] h-fit w-fit object-cover"
                       ; Attr.create "width" "300"
                       ; Attr.create "height" "400"
                       ]
                     ()
                 ]
             ; Node.create
                 "figcaption"
                 ~attrs:[ Attr.class_ "pt-2 text-xs text-muted-foreground" ]
                 [ Node.text "Photo by "
                 ; Node.span
                     ~attrs:[ Attr.class_ "font-semibold text-foreground" ]
                     [ Node.text artist ]
                 ]
             ]))
    ; Scroll_area.scroll_bar ~orientation:Horizontal ()
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Scroll area"
    ~group:Display
    ~description:
      "Augments native scroll functionality for custom, cross-browser styling."
    ~usage:
      {|Scroll_area.root ~class_:"h-[200px] w-[350px] rounded-md border p-4"
  [ Node.text
      "Jokester began sneaking into the castle in the middle of the night and leaving \
       jokes all over the place: under the king's pillow, in his soup, even in the \
       royal toilet."
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "type_"
            , "Scroll_area.Type.t"
            , "When the scrollbars show: [Hover] (default) while the pointer \
               is over the area, [Scroll] while it scrolls, [Auto] when the \
               content overflows, [Always]." )
          ; ( "scroll_hide_delay"
            , "Time_ns.Span.t"
            , "How long a [Hover] or [Scroll] scrollbar stays after the \
               pointer leaves or scrolling stops (600ms)." )
          ; ( "orientation"
            , "Scroll_area.Orientation.t"
            , "[Scroll_area.scroll_bar]: [Vertical] (default; [root] has one) \
               or [Horizontal] (put it among the children)." )
          ]
      ]
    [ Doc.static ~page "Demo" demo; Doc.static ~page "Horizontal" horizontal ]
;;
