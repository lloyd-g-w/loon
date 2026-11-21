open! Import

type t = Modal.t

module Size = struct
  type t =
    | Default
    | Sm
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Sm -> "sm"
  ;;
end

let view ?id = Modal.view ?id
let component = Modal.component
let trigger ?attrs t node = Modal.trigger ~slot:"alert-dialog-trigger" ?attrs t node

let overlay_class =
  "fixed inset-0 z-50 bg-black/50 data-[state=closed]:animate-out \
   data-[state=closed]:fade-out-0 data-[state=open]:animate-in \
   data-[state=open]:fade-in-0"
;;

let content_class =
  "group/alert-dialog-content fixed top-[50%] left-[50%] z-50 grid w-full \
   max-w-[calc(100%-2rem)] translate-x-[-50%] translate-y-[-50%] gap-4 rounded-lg \
   border bg-background p-6 shadow-lg duration-200 data-[size=sm]:max-w-xs \
   data-[state=closed]:animate-out data-[state=closed]:fade-out-0 \
   data-[state=closed]:zoom-out-95 data-[state=open]:animate-in \
   data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 \
   data-[size=default]:sm:max-w-lg"
;;

let content ?(attrs = []) ?class_ ?(size = Size.Default) (t : t) children =
  Modal.content
    ~dismissible:false
    ~role:"alertdialog"
    ~initial_focus:"[data-slot=alert-dialog-cancel]"
    ~overlay:(Modal.overlay ~slot:"alert-dialog-overlay" ~class_:overlay_class t)
    ~content_attrs:
      ([ data "slot" "alert-dialog-content"
       ; data "size" (Size.name size)
       ; Cn.with_class ?class_ [ content_class ]
       ]
       @ attrs)
    t
    children
;;

let header ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "alert-dialog-header"
       ; Cn.with_class
           ?class_
           [ "grid grid-rows-[auto_1fr] place-items-center gap-1.5 text-center \
              has-data-[slot=alert-dialog-media]:grid-rows-[auto_auto_1fr] \
              has-data-[slot=alert-dialog-media]:gap-x-6 \
              sm:group-data-[size=default]/alert-dialog-content:place-items-start \
              sm:group-data-[size=default]/alert-dialog-content:text-left \
              sm:group-data-[size=default]/alert-dialog-content:has-data-[slot=alert-dialog-media]:grid-rows-[auto_1fr]"
           ]
       ]
       @ attrs)
    children
;;

let footer ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "alert-dialog-footer"
       ; Cn.with_class
           ?class_
           [ "flex flex-col-reverse gap-2 \
              group-data-[size=sm]/alert-dialog-content:grid \
              group-data-[size=sm]/alert-dialog-content:grid-cols-2 sm:flex-row \
              sm:justify-end"
           ]
       ]
       @ attrs)
    children
;;

let title ?attrs ?class_ t children =
  Modal.title
    ~slot:"alert-dialog-title"
    ~class_:
      (Cn.cn
         [ "text-lg font-semibold \
            sm:group-data-[size=default]/alert-dialog-content:group-has-data-[slot=alert-dialog-media]/alert-dialog-content:col-start-2"
         ; Option.value class_ ~default:""
         ])
    ?attrs
    t
    children
;;

let description ?attrs ?class_ t children =
  Modal.description
    ~slot:"alert-dialog-description"
    ~class_:(Cn.cn [ "text-sm text-muted-foreground"; Option.value class_ ~default:"" ])
    ?attrs
    t
    children
;;

let media ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "alert-dialog-media"
       ; Cn.with_class
           ?class_
           [ "mb-2 inline-flex size-16 items-center justify-center rounded-md bg-muted \
              sm:group-data-[size=default]/alert-dialog-content:row-span-2 \
              *:[svg:not([class*='size-'])]:size-8"
           ]
       ]
       @ attrs)
    children
;;

(* shadcn's [<Button asChild><AlertDialogPrimitive.Action>]: the button's
   classes and data attributes, the action's slot. *)
let button ~slot ?(attrs = []) ?class_ ?(variant = Button.Variant.Default) ?(size = Button.Size.Default) ~on_click children =
  Node.button
    ~attrs:
      ([ Attr.type_ "button"
       ; data "slot" slot
       ; data "variant" (Button.Variant.name variant)
       ; data "size" (Button.Size.name size)
       ; Attr.class_ (Button.classes ~variant ~size ?class_ ())
       ; Attr.on_click (fun _ -> on_click)
       ]
       @ attrs)
    children
;;

let action ?attrs ?class_ ?variant ?size ?on_click (t : t) children =
  button
    ~slot:"alert-dialog-action"
    ?attrs
    ?class_
    ?variant
    ?size
    ~on_click:(Effect.Many [ Option.value on_click ~default:Effect.Ignore; t.on_open_change false ])
    children
;;

let cancel ?attrs ?class_ ?(variant = Button.Variant.Outline) ?size (t : t) children =
  button
    ~slot:"alert-dialog-cancel"
    ?attrs
    ?class_
    ~variant
    ?size
    ~on_click:(t.on_open_change false)
    children
;;
