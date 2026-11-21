open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "textarea"

(*$ Demo *)
let demo = Textarea.view ~placeholder:"Type your message here." ()
(*$*)

(*$ Disabled *)
let disabled = Textarea.view ~placeholder:"Type your message here." ~disabled:true ()
(*$*)

(*$ With Label *)
let with_label =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full gap-3" ]
    [ Label.view ~for_:"message" [ Node.text "Your message" ]
    ; Textarea.view ~placeholder:"Type your message here." ~id:"message" ()
    ]
(*$*)

(*$ With Text *)
let with_text =
  Node.div
    ~attrs:[ Attr.class_ "grid w-full gap-3" ]
    [ Label.view ~for_:"message-2" [ Node.text "Your Message" ]
    ; Textarea.view ~placeholder:"Type your message here." ~id:"message-2" ()
    ; Node.p
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.text "Your message will be copied to the support team." ]
    ]
(*$*)

(*$ With Button
   Controlled: the button sends the text and clears it. *)
let with_button (local_ graph) =
  let message = Textarea.component ~placeholder:"Type your message here." graph in
  let sent, set_sent = Bonsai.state "" graph in
  let%arr message and sent and set_sent in
  Node.div
    ~attrs:[ Attr.class_ "grid w-full gap-2" ]
    ([ message.view
     ; Button.view
         ~on_click:(Effect.Many [ set_sent message.value; message.set "" ])
         [ Node.text "Send message" ]
     ]
     @
     if String.is_empty sent
     then []
     else
       [ Node.p
           ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
           [ Node.text ("Sent: " ^ sent) ]
       ])
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Textarea"
    ~group:Forms
    ~description:"Displays a form textarea or a component that looks like a textarea."
    ~usage:{|Textarea.view ~placeholder:"Type your message here." ~value ~on_input:set ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "value", "string", "Makes it controlled: the text shown. Without it the browser keeps what is typed."
          ; "on_input", "string -> unit Effect.t", "Gets the text after each edit."
          ; "placeholder", "string", "Shown while it is empty."
          ; "rows", "int", "The height in lines (it grows with its content too)."
          ; "id", "string", "For a [Label]'s [for_]."
          ; "name", "string", "The form field's name."
          ; "disabled", "bool", "Greys it out."
          ; "required", "bool", "Must be filled in."
          ; "invalid", "bool", "Sets [aria-invalid], drawing it in the destructive colour."
          ; "class_", "string", "More Tailwind classes, merged last (they win conflicts)."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ; Doc.p
          "[Textarea.component ~default_value graph] keeps the text in Bonsai state and \
           returns a [Control.t]: its value, a [set] effect and its view."
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Disabled" disabled
    ; Doc.static ~page "With Label" with_label
    ; Doc.static ~page "With Text" with_text
    ; Doc.example ~page "With Button" with_button
    ]
;;
