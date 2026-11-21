open! Import

type t = Modal.t

let view ?id ~open_ ~on_open_change f = Modal.view ?id ~open_ ~on_open_change f
let component = Modal.component
let trigger ?attrs t node = Modal.trigger ~slot:"dialog-trigger" ?attrs t node
let close ?attrs t node = Modal.close ~slot:"dialog-close" ?attrs t node

let overlay_class =
  "fixed inset-0 z-50 bg-black/50 data-[state=closed]:animate-out \
   data-[state=closed]:fade-out-0 data-[state=open]:animate-in \
   data-[state=open]:fade-in-0"
;;

let content_class =
  "fixed top-[50%] left-[50%] z-50 grid w-full max-w-[calc(100%-2rem)] \
   translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg border bg-background p-6 \
   shadow-lg duration-200 outline-none data-[state=closed]:animate-out \
   data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 \
   data-[state=open]:animate-in data-[state=open]:fade-in-0 \
   data-[state=open]:zoom-in-95 sm:max-w-lg"
;;

let close_class =
  "absolute top-4 right-4 rounded-xs opacity-70 ring-offset-background \
   transition-opacity hover:opacity-100 focus:ring-2 focus:ring-ring \
   focus:ring-offset-2 focus:outline-hidden disabled:pointer-events-none \
   data-[state=open]:bg-accent data-[state=open]:text-muted-foreground \
   [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
;;

let content ?(attrs = []) ?class_ ?(show_close_button = true) ?initial_focus t children =
  Modal.content
    ?initial_focus
    ~overlay:(Modal.overlay ~slot:"dialog-overlay" ~class_:overlay_class t)
    ~content_attrs:([ data "slot" "dialog-content"; Cn.with_class ?class_ [ content_class ] ] @ attrs)
    t
    (children
     @
     if show_close_button
     then
       [ Node.button
           ~attrs:
             [ Attr.type_ "button"
             ; data "slot" "dialog-close"
             ; Attr.class_ close_class
             ; Attr.on_click (fun _ -> t.on_open_change false)
             ]
           [ Icon.view X; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Close" ] ]
       ]
     else [])
;;

let header ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "dialog-header"
       ; Cn.with_class ?class_ [ "flex flex-col gap-2 text-center sm:text-left" ]
       ]
       @ attrs)
    children
;;

let footer ?(attrs = []) ?class_ ?show_close_button children =
  Node.div
    ~attrs:
      ([ data "slot" "dialog-footer"
       ; Cn.with_class ?class_ [ "flex flex-col-reverse gap-2 sm:flex-row sm:justify-end" ]
       ]
       @ attrs)
    (children
     @
     match show_close_button with
     | None -> []
     | Some t -> [ close t (Button.view ~variant:Outline [ Node.text "Close" ]) ])
;;

let title ?attrs ?class_ t children =
  Modal.title
    ~slot:"dialog-title"
    ~class_:(Cn.cn [ "text-lg leading-none font-semibold"; Option.value class_ ~default:"" ])
    ?attrs
    t
    children
;;

let description ?attrs ?class_ t children =
  Modal.description
    ~slot:"dialog-description"
    ~class_:(Cn.cn [ "text-sm text-muted-foreground"; Option.value class_ ~default:"" ])
    ?attrs
    t
    children
;;
