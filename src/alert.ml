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
    | Default -> "cn-alert-variant-default"
    | Destructive -> "cn-alert-variant-destructive"
  ;;
end

let base =
  "cn-alert group/alert relative w-full"
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
  div
    "alert-title"
    "cn-alert-title [&_a]:underline [&_a]:underline-offset-3 [&_a]:hover:text-foreground"
;;

let description =
  div
    "alert-description"
    "cn-alert-description [&_a]:underline [&_a]:underline-offset-3 \
     [&_a]:hover:text-foreground"
;;

let action = div "alert-action" "cn-alert-action"
