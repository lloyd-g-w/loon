open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "native_select"

(*$ Demo *)
let demo =
  Native_select.view
    [ Native_select.option ~value:"" [ Node.text "Select status" ]
    ; Native_select.option ~value:"todo" [ Node.text "Todo" ]
    ; Native_select.option ~value:"in-progress" [ Node.text "In Progress" ]
    ; Native_select.option ~value:"done" [ Node.text "Done" ]
    ; Native_select.option ~value:"cancelled" [ Node.text "Cancelled" ]
    ]
(*$*)

(*$ Groups
   [opt_group] puts options under a heading. *)
let groups =
  Native_select.view
    [ Native_select.option ~value:"" [ Node.text "Select department" ]
    ; Native_select.opt_group
        ~label:"Engineering"
        [ Native_select.option ~value:"frontend" [ Node.text "Frontend" ]
        ; Native_select.option ~value:"backend" [ Node.text "Backend" ]
        ; Native_select.option ~value:"devops" [ Node.text "DevOps" ]
        ]
    ; Native_select.opt_group
        ~label:"Sales"
        [ Native_select.option ~value:"sales-rep" [ Node.text "Sales Rep" ]
        ; Native_select.option ~value:"account-manager" [ Node.text "Account Manager" ]
        ; Native_select.option ~value:"sales-director" [ Node.text "Sales Director" ]
        ]
    ; Native_select.opt_group
        ~label:"Operations"
        [ Native_select.option ~value:"support" [ Node.text "Customer Support" ]
        ; Native_select.option ~value:"product-manager" [ Node.text "Product Manager" ]
        ; Native_select.option ~value:"ops-manager" [ Node.text "Operations Manager" ]
        ]
    ]
(*$*)

(*$ Disabled *)
let disabled =
  Native_select.view
    ~disabled:true
    [ Native_select.option ~value:"" [ Node.text "Select priority" ]
    ; Native_select.option ~value:"low" [ Node.text "Low" ]
    ; Native_select.option ~value:"medium" [ Node.text "Medium" ]
    ; Native_select.option ~value:"high" [ Node.text "High" ]
    ; Native_select.option ~value:"critical" [ Node.text "Critical" ]
    ]
(*$*)

(*$ Invalid
   [invalid] sets [aria-invalid], which shadcn's classes colour. *)
let invalid =
  Native_select.view
    ~invalid:true
    [ Native_select.option ~value:"" [ Node.text "Select role" ]
    ; Native_select.option ~value:"admin" [ Node.text "Admin" ]
    ; Native_select.option ~value:"editor" [ Node.text "Editor" ]
    ; Native_select.option ~value:"viewer" [ Node.text "Viewer" ]
    ; Native_select.option ~value:"guest" [ Node.text "Guest" ]
    ]
(*$*)

(*$ Controlled
   [component] keeps the choice in Bonsai state; [value] is the chosen
   option's value. *)
let controlled (local_ graph) =
  let%arr status =
    Native_select.component
      ~default_value:"in-progress"
      [ Native_select.option ~value:"todo" [ Node.text "Todo" ]
      ; Native_select.option ~value:"in-progress" [ Node.text "In Progress" ]
      ; Native_select.option ~value:"done" [ Node.text "Done" ]
      ]
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-start gap-3" ]
    [ status.view
    ; Node.p
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.textf "Status: %s" status.value ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Native Select"
    ~description:
      "A styled native HTML select element with consistent design system integration."
    ~usage:
      {|Native_select.view ~value ~on_change:set_status
  [ Native_select.option ~value:"" [ Node.text "Select status" ]
  ; Native_select.option ~value:"todo" [ Node.text "Todo" ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value"
            , "string"
            , "The chosen option's value (controlled); without it the browser keeps the \
               choice." )
          ; "on_change", "string -> unit Effect.t", "Gets the newly chosen value."
          ; "size", "Native_select.Size.t", "[Default] or [Sm]."
          ; "invalid", "bool", "Sets aria-invalid, which colours it as an error."
          ; "disabled", "bool", "Greys it out."
          ; "id, name, required", "", "As on a <select>."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes for the <select>."
          ]
      ; Doc.p
          "[Native_select.option] and [Native_select.opt_group] are the <option> and \
           <optgroup>; [Native_select.component ~default_value] keeps the value in \
           Bonsai."
      ; Doc.note
          ~title:"Native Select or Select?"
          [ Doc.text
              "Native Select is the browser's own control: best on phones and inside \
               forms. Select draws its own listbox, for custom content and styling."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Groups" groups
    ; Doc.static ~page "Disabled" disabled
    ; Doc.static ~page "Invalid" invalid
    ; Doc.example ~page "Controlled" controlled
    ]
;;
