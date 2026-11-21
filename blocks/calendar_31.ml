open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let june_12 = Date.create_exn ~y:2025 ~m:Jun ~d:12
let at h m : Little_date.moment = june_12, (h * 60) + m

let events =
  [ "Team Sync Meeting", at 9 0, at 10 0
  ; "Design Review", at 11 30, at 12 30
  ; "Client Presentation", at 14 0, at 15 0
  ]
;;

let view (local_ graph) =
  let calendar =
    Calendar.component
      ~class_:"bg-transparent p-0"
      ~required:true
      ~default_month:june_12
      ~default:(Single (Some june_12))
      graph
  in
  let%arr calendar in
  let date =
    match calendar.selected with
    | Single date -> date
    | Multiple _ | Range _ -> None
  in
  Card.root
    ~class_:"w-fit py-4"
    [ Card.content ~class_:"px-4" [ calendar.view ]
    ; Card.footer
        ~class_:"flex flex-col items-start gap-3 border-t px-4 !pt-4"
        [ Node.div
            ~attrs:
              [ Attr.class_ "flex w-full items-center justify-between px-1" ]
            [ Node.div
                ~attrs:[ Attr.class_ "text-sm font-medium" ]
                [ Node.text
                    (Option.value_map
                       date
                       ~default:""
                       ~f:(Calendar.format "MMMM d, yyyy"))
                ]
            ; Button.view
                ~variant:Ghost
                ~size:Icon
                ~class_:"size-6"
                ~attrs:[ Attr.title "Add Event" ]
                [ Icon.view Plus
                ; Node.span
                    ~attrs:[ Attr.class_ "sr-only" ]
                    [ Node.text "Add Event" ]
                ]
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "flex w-full flex-col gap-2" ]
            (List.map events ~f:(fun (title, from, to_) ->
               Node.div
                 ~key:title
                 ~attrs:
                   [ Attr.class_
                       "bg-muted after:bg-primary/70 relative rounded-md p-2 \
                        pl-6 text-sm after:absolute after:inset-y-2 \
                        after:left-2 after:w-1 after:rounded-full"
                   ]
                 [ Node.div
                     ~attrs:[ Attr.class_ "font-medium" ]
                     [ Node.text title ]
                 ; Node.div
                     ~attrs:[ Attr.class_ "text-muted-foreground text-xs" ]
                     [ Node.text (Little_date.format_date_range from to_) ]
                 ]))
        ]
    ]
;;
