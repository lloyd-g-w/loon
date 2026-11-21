open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "carousel"

(*$ Demo *)
let demo (local_ graph) =
  let carousel = Carousel.component graph in
  let%arr carousel in
  Carousel.root
    carousel
    ~class_:"w-full max-w-xs"
    [ Carousel.content
        carousel
        (List.init 5 ~f:(fun index ->
           Carousel.item
             carousel
             [ Node.div
                 ~attrs:[ Attr.class_ "p-1" ]
                 [ Card.root
                     [ Card.content
                         ~class_:"flex aspect-square items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-4xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]
             ]))
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

(*$*)

(*$ Sizes
   A [basis-*] class on the items sets their size: here a half or a third
   of the viewport. *)
let size (local_ graph) =
  let carousel = Carousel.component ~align:Start graph in
  let%arr carousel in
  Carousel.root
    carousel
    ~class_:"w-full max-w-sm"
    [ Carousel.content
        carousel
        (List.init 5 ~f:(fun index ->
           Carousel.item
             carousel
             ~class_:"md:basis-1/2 lg:basis-1/3"
             [ Node.div
                 ~attrs:[ Attr.class_ "p-1" ]
                 [ Card.root
                     [ Card.content
                         ~class_:"flex aspect-square items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-3xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]
             ]))
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

(*$*)

(*$ Spacing
   [pl-*] on the items and a negative [-ml-*] on the content set the space
   between them. *)
let spacing (local_ graph) =
  let carousel = Carousel.component graph in
  let%arr carousel in
  Carousel.root
    carousel
    ~class_:"w-full max-w-sm"
    [ Carousel.content
        carousel
        ~class_:"-ml-1"
        (List.init 5 ~f:(fun index ->
           Carousel.item
             carousel
             ~class_:"pl-1 md:basis-1/2 lg:basis-1/3"
             [ Node.div
                 ~attrs:[ Attr.class_ "p-1" ]
                 [ Card.root
                     [ Card.content
                         ~class_:"flex aspect-square items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-2xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]
             ]))
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

(*$*)

(*$ Orientation *)
let orientation (local_ graph) =
  let carousel = Carousel.component ~align:Start ~orientation:Vertical graph in
  let%arr carousel in
  Carousel.root
    carousel
    ~class_:"w-full max-w-xs"
    [ Carousel.content
        carousel
        ~class_:"-mt-1 h-[200px]"
        (List.init 5 ~f:(fun index ->
           Carousel.item
             carousel
             ~class_:"pt-1 md:basis-1/2"
             [ Node.div
                 ~attrs:[ Attr.class_ "p-1" ]
                 [ Card.root
                     [ Card.content
                         ~class_:"flex items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-3xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]
             ]))
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

(*$*)

(*$ API
   [Carousel.selected] and [Carousel.count] read the carousel's state:
   Embla's [selectedScrollSnap] and [scrollSnapList]. *)
let api (local_ graph) =
  let carousel = Carousel.component graph in
  let%arr carousel in
  Node.div
    ~attrs:[ Attr.class_ "mx-auto max-w-xs" ]
    [ Carousel.root
        carousel
        ~class_:"w-full max-w-xs"
        [ Carousel.content
            carousel
            (List.init 5 ~f:(fun index ->
               Carousel.item
                 carousel
                 [ Card.root
                     [ Card.content
                         ~class_:"flex aspect-square items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-4xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]))
        ; Carousel.previous carousel
        ; Carousel.next carousel
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "py-2 text-center text-sm text-muted-foreground" ]
        [ Node.textf
            "Slide %d of %d"
            (if Carousel.count carousel = 0 then 0 else Carousel.selected carousel + 1)
            (Carousel.count carousel)
        ]
    ]
;;

(*$*)

(*$ Autoplay
   [~autoplay] (milliseconds) moves on by itself, as Embla's Autoplay
   plugin: it pauses while the pointer is over the carousel and stops once
   the slides are dragged. *)
let autoplay (local_ graph) =
  let carousel = Carousel.component ~autoplay:2000 graph in
  let%arr carousel in
  Carousel.root
    carousel
    ~class_:"w-full max-w-xs"
    [ Carousel.content
        carousel
        (List.init 5 ~f:(fun index ->
           Carousel.item
             carousel
             [ Node.div
                 ~attrs:[ Attr.class_ "p-1" ]
                 [ Card.root
                     [ Card.content
                         ~class_:"flex aspect-square items-center justify-center p-6"
                         [ Node.span
                             ~attrs:[ Attr.class_ "text-4xl font-semibold" ]
                             [ Node.text (Int.to_string (index + 1)) ]
                         ]
                     ]
                 ]
             ]))
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Carousel"
    ~group:Display
    ~description:"A carousel with motion and swipe built using Embla."
    ~usage:
      {|let%sub carousel = Carousel.component graph in
let%arr carousel in
Carousel.root carousel
  [ Carousel.content carousel
      [ Carousel.item carousel [ Node.text "..." ]
      ; Carousel.item carousel [ Node.text "..." ]
      ; Carousel.item carousel [ Node.text "..." ]
      ]
  ; Carousel.previous carousel
  ; Carousel.next carousel
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "orientation"
            , "Carousel.Orientation.t"
            , "[Horizontal] (default) or [Vertical]." )
          ; ( "align"
            , "Carousel.Align.t"
            , "Where the selected slide sits: [Start], [Center] (default) or [End]." )
          ; "loop", "bool", "Go round from the last slide to the first and back."
          ; ( "autoplay"
            , "int"
            , "Move on every so many milliseconds, until the slides are dragged." )
          ]
      ; Doc.p
          "[Carousel.component] keeps the state; [Carousel.create] takes it with \
           [~state] and [~on_change]. [Carousel.selected], [count], \
           [can_scroll_prev]/[next], [scroll_prev]/[next] and [scroll_to] are its API."
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Arrow Left / Right"; Doc.text "The previous or next slide." ] ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Sizes" size
    ; Doc.example ~page "Spacing" spacing
    ; Doc.example ~page "Orientation" orientation
    ; Doc.example ~page "API" api
    ; Doc.example ~page "Autoplay" autoplay
    ]
;;
