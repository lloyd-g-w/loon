open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let label ?(class_ = "") ~for_ text =
  Node.label
    ~attrs:
      [ Attr.for_ for_
      ; Attr.class_
          (Cn.cn
             [ "flex items-center gap-2 text-sm leading-none font-medium \
                select-none group-data-[disabled=true]:pointer-events-none \
                group-data-[disabled=true]:opacity-50 \
                peer-disabled:cursor-not-allowed peer-disabled:opacity-50"
             ; class_
             ])
      ]
    [ Node.text text ]
;;

let input ?(attrs = []) ~id value =
  Node.input
    ~attrs:
      ([ Attr.id id
       ; Attr.create "value" value
       ; Attr.class_
           "h-9 w-full min-w-0 rounded-md border border-input bg-transparent \
            px-3 py-1 text-base shadow-xs transition-[color,box-shadow] \
            outline-none selection:bg-primary \
            selection:text-primary-foreground \
            placeholder:text-muted-foreground md:text-sm dark:bg-input/30 \
            focus-visible:border-ring focus-visible:ring-[3px] \
            focus-visible:ring-ring/50"
       ]
       @ attrs)
    ()
;;
