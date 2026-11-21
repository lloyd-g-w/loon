open! Core
open Bonsai_web
open Create_preview_util

let frame columns =
  div
    ~class_:
      "overflow-x-auto overflow-y-hidden bg-muted contain-[paint] [--gap:--spacing(4)] \
       3xl:[--gap:--spacing(12)] md:[--gap:--spacing(10)] dark:bg-background \
       style-lyra:md:[--gap:--spacing(6)] style-mira:md:[--gap:--spacing(6)]"
    [ div
        ~class_:"flex w-full min-w-max justify-center"
        [ div
            ~attrs:[ Vdom.Attr.create "data-slot" "capture-target" ]
            ~class_:
              "grid w-[2400px] grid-cols-7 items-start gap-(--gap) bg-muted p-(--gap) \
               md:w-[3000px] dark:bg-background style-lyra:md:w-[2600px] \
               style-mira:md:w-[2600px] *:[div]:gap-(--gap)"
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
