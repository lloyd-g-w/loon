open! Import

module Orientation = struct
  type t =
    | Horizontal
    | Vertical
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Horizontal -> "horizontal"
    | Vertical -> "vertical"
  ;;

  let classes = function
    | Horizontal ->
      "[&>*:not(:first-child)]:rounded-l-none [&>*:not(:first-child)]:border-l-0 \
       [&>*:not(:last-child)]:rounded-r-none"
    | Vertical ->
      "flex-col [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 \
       [&>*:not(:last-child)]:rounded-b-none"
  ;;
end

let class_list ?(orientation = Orientation.Horizontal) ?class_ () =
  [ "flex w-fit items-stretch has-[>[data-slot=button-group]]:gap-2 \
     [&>*]:focus-visible:relative [&>*]:focus-visible:z-10 \
     has-[select[aria-hidden=true]:last-child]:[&>[data-slot=select-trigger]:last-of-type]:rounded-r-md \
     [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1"
  ; Orientation.classes orientation
  ]
  @ Option.to_list class_
;;

let classes ?orientation ?class_ () = Cn.cn (class_list ?orientation ?class_ ())

let root ?(attrs = []) ?class_ ?orientation children =
  Node.div
    ~attrs:
      ([ Attr.role "group"; data "slot" "button-group" ]
       @ Option.value_map orientation ~default:[] ~f:(fun o ->
         [ data "orientation" (Orientation.name o) ])
       @ [ Cn.attr (class_list ?orientation ?class_ ()) ]
       @ attrs)
    children
;;

let text ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      (Cn.with_class
         ?class_
         [ "flex items-center gap-2 rounded-md border bg-muted px-4 text-sm font-medium \
            shadow-xs [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4"
         ]
       :: attrs)
    children
;;

(* shadcn's Separator (decorative) with the group's classes. *)
let separator ?(attrs = []) ?class_ ?(orientation = Orientation.Vertical) () =
  Node.div
    ~attrs:
      ([ data "slot" "button-group-separator"
       ; Attr.role "none"
       ; data "orientation" (Orientation.name orientation)
       ; Cn.with_class
           ?class_
           [ "shrink-0 bg-border data-[orientation=horizontal]:h-px \
              data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full \
              data-[orientation=vertical]:w-px"
           ; "relative m-0! self-stretch bg-input data-[orientation=vertical]:h-auto"
           ]
       ]
       @ attrs)
    []
;;
