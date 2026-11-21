open! Import

let div slot classes ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:([ data "slot" slot; Cn.with_class ?class_ [ classes ] ] @ attrs)
    children
;;

let root =
  div
    "card"
    "flex flex-col gap-6 rounded-xl border bg-card py-6 text-card-foreground shadow-sm"
;;

let header =
  div
    "card-header"
    "@container/card-header grid auto-rows-min grid-rows-[auto_auto] items-start gap-2 px-6 \
     has-data-[slot=card-action]:grid-cols-[1fr_auto] [.border-b]:pb-6"
;;

let title = div "card-title" "leading-none font-semibold"
let description = div "card-description" "text-sm text-muted-foreground"

let action =
  div "card-action" "col-start-2 row-span-2 row-start-1 self-start justify-self-end"
;;

let content = div "card-content" "px-6"
let footer = div "card-footer" "flex items-center px-6 [.border-t]:pt-6"
