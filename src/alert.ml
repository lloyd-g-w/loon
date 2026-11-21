open! Import

module Variant = struct
  type t =
    | Default
    | Destructive
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Default -> "default"
    | Destructive -> "destructive"
  ;;

  let classes = function
    | Default -> "bg-card text-card-foreground"
    | Destructive ->
      "bg-card text-destructive *:data-[slot=alert-description]:text-destructive/90 \
       [&>svg]:text-current"
  ;;
end

let base =
  "relative grid w-full grid-cols-[0_1fr] items-start gap-y-0.5 rounded-lg border px-4 py-3 \
   text-sm has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] has-[>svg]:gap-x-3 \
   [&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
;;

let class_list ?(variant = Variant.Default) ?class_ () =
  [ base; Variant.classes variant ] @ Option.to_list class_
;;

let classes ?variant ?class_ () = Cn.cn (class_list ?variant ?class_ ())

let root ?(attrs = []) ?class_ ?variant children =
  Node.div
    ~attrs:
      ([ data "slot" "alert"; Attr.role "alert"; Cn.attr (class_list ?variant ?class_ ()) ]
       @ attrs)
    children
;;

let div slot classes ?(attrs = []) ?class_ children =
  Node.div ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs) children
;;

let title =
  div "alert-title" "col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight"
;;

let description =
  div
    "alert-description"
    "col-start-2 grid justify-items-start gap-1 text-sm text-muted-foreground \
     [&_p]:leading-relaxed"
;;
