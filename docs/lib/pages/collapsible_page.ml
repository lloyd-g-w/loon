open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "collapsible"

(*$ Demo *)
let demo (local_ graph) =
  let is_open, set_open = Bonsai.state false graph in
  let%arr is_open
  and set_open in
  let repository name =
    Node.div
      ~attrs:[ Attr.class_ "rounded-md border px-4 py-2 font-mono text-sm" ]
      [ Node.text name ]
  in
  Collapsible.view
    ~open_:is_open
    ~on_change:set_open
    ~class_:"flex w-[350px] flex-col gap-2"
    (fun c ->
       [ Node.div
           ~attrs:[ Attr.class_ "flex items-center justify-between gap-4 px-4" ]
           [ Node.h4
               ~attrs:[ Attr.class_ "text-sm font-semibold" ]
               [ Node.text "@peduarte starred 3 repositories" ]
           ; Button.view
               ~attrs:(Collapsible.trigger_attrs c)
               ~variant:Ghost
               ~size:Icon
               ~class_:"size-8"
               [ Icon.view Chevrons_up_down
               ; Node.span
                   ~attrs:[ Attr.class_ "sr-only" ]
                   [ Node.text "Toggle" ]
               ]
           ]
       ; repository "@radix-ui/primitives"
       ; Collapsible.content
           c
           ~class_:"flex flex-col gap-2"
           [ repository "@radix-ui/colors"; repository "@stitches/react" ]
       ])
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Collapsible"
    ~description:"An interactive component which expands/collapses a panel."
    ~usage:
      {|Collapsible.component
  (return (fun c ->
     [ Collapsible.trigger c [ Node.text "Can I use this in my project?" ]
     ; Collapsible.content c
         [ Node.text "Yes. Free to use for personal and commercial projects." ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "default_open"
            , "bool"
            , "[Collapsible.component]: open at first. [Collapsible.view] \
               takes [~open_] and [~on_change] instead." )
          ; "disabled", "bool", "The trigger does nothing."
          ; ( "trigger_attrs"
            , "Collapsible.t -> Attr.t list"
            , "Makes any element the trigger (shadcn's [asChild]), e.g. a \
               [Button.view]." )
          ]
      ]
    [ Doc.example ~page "Demo" demo ]
;;
