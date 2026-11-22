open! Import

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

let div slot classes ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs)
    children
;;

let root ?(attrs = []) ?class_ ?(size = Size.Default) children =
  div
    "card"
    "cn-card group/card flex flex-col"
    ~attrs:(data "size" (Size.name size) :: attrs)
    ?class_
    children
;;

let header =
  div
    "card-header"
    "cn-card-header group/card-header @container/card-header grid auto-rows-min \
     items-start has-data-[slot=card-action]:grid-cols-[1fr_auto] \
     has-data-[slot=card-description]:grid-rows-[auto_auto]"
;;

let title = div "card-title" "cn-card-title cn-font-heading"
let description = div "card-description" "cn-card-description"

let action =
  div
    "card-action"
    "cn-card-action col-start-2 row-span-2 row-start-1 self-start justify-self-end"
;;

let content = div "card-content" "cn-card-content"
let footer = div "card-footer" "cn-card-footer flex items-center"
