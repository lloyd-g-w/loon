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
      "cn-button-group-orientation-horizontal [&>*:not(:first-child)]:rounded-l-none \
       [&>*:not(:first-child)]:border-l-0 [&>*:not(:last-child)]:rounded-r-none"
    | Vertical ->
      "cn-button-group-orientation-vertical flex-col \
       [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 \
       [&>*:not(:last-child)]:rounded-b-none"
  ;;
end

let class_list ?(orientation = Orientation.Horizontal) ?class_ () =
  [ "cn-button-group group/button-group flex w-fit items-stretch *:focus-visible:relative \
     *:focus-visible:z-10 [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit \
     [&>input]:flex-1"
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
         [ "cn-button-group-text flex items-center [&_svg]:pointer-events-none"
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
           ; "cn-button-group-separator relative self-stretch data-horizontal:mx-px \
              data-horizontal:w-auto data-vertical:my-px data-vertical:h-auto"
           ]
       ]
       @ attrs)
    []
;;
