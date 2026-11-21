open! Import

type t = Modal.t

module Side = struct
  type t =
    | Top
    | Right
    | Bottom
    | Left
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Top -> "top"
    | Right -> "right"
    | Bottom -> "bottom"
    | Left -> "left"
  ;;

  let classes = function
    | Right ->
      "inset-y-0 right-0 h-full w-3/4 border-l data-[state=closed]:slide-out-to-right \
       data-[state=open]:slide-in-from-right sm:max-w-sm"
    | Left ->
      "inset-y-0 left-0 h-full w-3/4 border-r data-[state=closed]:slide-out-to-left \
       data-[state=open]:slide-in-from-left sm:max-w-sm"
    | Top ->
      "inset-x-0 top-0 h-auto border-b data-[state=closed]:slide-out-to-top \
       data-[state=open]:slide-in-from-top"
    | Bottom ->
      "inset-x-0 bottom-0 h-auto border-t data-[state=closed]:slide-out-to-bottom \
       data-[state=open]:slide-in-from-bottom"
  ;;
end

let view ?id ~open_ ~on_open_change f = Modal.view ?id ~open_ ~on_open_change f
let component = Modal.component
let trigger ?attrs t node = Modal.trigger ~slot:"sheet-trigger" ?attrs t node
let close ?attrs t node = Modal.close ~slot:"sheet-close" ?attrs t node

let overlay_class =
  "fixed inset-0 z-50 bg-black/50 data-[state=closed]:animate-out \
   data-[state=closed]:fade-out-0 data-[state=open]:animate-in \
   data-[state=open]:fade-in-0"
;;

let content_class =
  "fixed z-50 flex flex-col gap-4 bg-background shadow-lg transition ease-in-out \
   data-[state=closed]:animate-out data-[state=closed]:duration-300 \
   data-[state=open]:animate-in data-[state=open]:duration-500"
;;

let close_class =
  "absolute top-4 right-4 rounded-xs opacity-70 ring-offset-background \
   transition-opacity hover:opacity-100 focus:ring-2 focus:ring-ring \
   focus:ring-offset-2 focus:outline-hidden disabled:pointer-events-none \
   data-[state=open]:bg-secondary"
;;

let content ?(attrs = []) ?class_ ?(side = Side.Right) ?(show_close_button = true) (t : t) children =
  Modal.content
    ~overlay:(Modal.overlay ~slot:"sheet-overlay" ~class_:overlay_class t)
    ~content_attrs:
      ([ data "slot" "sheet-content"
       ; Cn.with_class ?class_ [ content_class; Side.classes side ]
       ]
       @ attrs)
    t
    (children
     @
     if show_close_button
     then
       [ Node.button
           ~attrs:
             [ Attr.type_ "button"
             ; Attr.class_ close_class
             ; Attr.on_click (fun _ -> t.on_open_change false)
             ]
           [ Icon.view ~class_:"size-4" X
           ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Close" ]
           ]
       ]
     else [])
;;

let header ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "sheet-header"; Cn.with_class ?class_ [ "flex flex-col gap-1.5 p-4" ] ]
       @ attrs)
    children
;;

let footer ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "sheet-footer"; Cn.with_class ?class_ [ "mt-auto flex flex-col gap-2 p-4" ] ]
       @ attrs)
    children
;;

let title ?attrs ?class_ t children =
  Modal.title
    ~slot:"sheet-title"
    ~class_:(Cn.cn [ "font-semibold text-foreground"; Option.value class_ ~default:"" ])
    ?attrs
    t
    children
;;

let description ?attrs ?class_ t children =
  Modal.description
    ~slot:"sheet-description"
    ~class_:(Cn.cn [ "text-sm text-muted-foreground"; Option.value class_ ~default:"" ])
    ?attrs
    t
    children
;;
