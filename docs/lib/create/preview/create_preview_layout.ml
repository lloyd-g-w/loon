open! Core
open Bonsai_web
open Create_preview_util

(* shadcn shows the blocks in an iframe, so their breakpoints are the
   preview's width: here they are container queries on Create's preview
   ([@container/preview]), md: as [@min-[48rem]/preview:] and so on. *)
let frame columns =
  div
    ~class_:
      "overflow-x-auto overflow-y-hidden bg-muted contain-[paint] [--gap:--spacing(4)] \
       @min-[100rem]/preview:[--gap:--spacing(12)] @min-[48rem]/preview:[--gap:--spacing(10)] dark:bg-background \
       style-lyra:@min-[48rem]/preview:[--gap:--spacing(6)] style-mira:@min-[48rem]/preview:[--gap:--spacing(6)]"
    [ div
        ~class_:"flex w-full min-w-max justify-center"
        [ div
            ~attrs:[ Vdom.Attr.create "data-slot" "capture-target" ]
            ~class_:
              "grid w-[2400px] grid-cols-7 items-start gap-(--gap) bg-muted p-(--gap) \
               @min-[48rem]/preview:w-[3000px] dark:bg-background style-lyra:@min-[48rem]/preview:w-[2600px] \
               style-mira:@min-[48rem]/preview:w-[2600px] *:[div]:gap-(--gap)"
            columns
        ]
    ]
;;

let column ?(wide = false) children =
  if wide
  then
    div
      ~class_:
        "col-span-2 flex flex-col p-1 [contain-intrinsic-size:760px_1200px] \
         [content-visibility:auto]"
      children
  else
    div
      ~class_:
        "flex flex-col p-1 [contain-intrinsic-size:380px_1200px] \
         [content-visibility:auto]"
      children
;;
