open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "dialog"

(*$ Edit profile
   [content ~close] gives the body and the footer's buttons. *)
let edit_profile (local_ graph) =
  Dialog.component
    ~title:"Edit profile"
    ~description:"Make changes to your profile here. Click save when you're done."
    ~trigger:(fun attrs -> Button.view ~attrs ~variant:Outline [ Node.text "Edit profile" ])
    (Bonsai.return (fun ~close ->
       let field label value =
         Node.label
           ~attrs:[ Attr.create "style" "display: grid; gap: 0.375rem; font-weight: 500" ]
           [ Node.text label
           ; Node.input
               ~attrs:
                 [ Attr.value value
                 ; Attr.create
                     "style"
                     "height: 2.25rem; padding: 0 0.75rem; font: inherit; color: inherit; \
                      background: var(--loon-surface); border: 1px solid var(--loon-input); \
                      border-radius: var(--loon-radius)"
                 ]
               ()
           ]
       in
       ( [ Node.div
             ~attrs:[ Attr.class_ "docs-stack" ]
             [ field "Name" "Lloyd"; field "Username" "@lloyd" ]
         ]
       , [ Button.view ~variant:Outline ~on_click:close [ Node.text "Cancel" ]
         ; Button.view ~on_click:close [ Node.text "Save changes" ]
         ] )))
    graph
(*$*)

(*$ Sizes *)
let sizes (local_ graph) =
  let dialog size name (local_ graph) =
    Dialog.component
      ~size
      ~title:(name ^ " dialog")
      ~description:"Dialogs come in four widths, and never overflow a phone's screen."
      ~trigger:(fun attrs -> Button.view ~attrs ~variant:Outline [ Node.text name ])
      (Bonsai.return (fun ~close ->
         [], [ Button.view ~on_click:close [ Node.text "Got it" ] ]))
      graph
  in
  let views =
    Bonsai.all
      [ dialog Sm "Small" graph
      ; dialog Md "Medium" graph
      ; dialog Lg "Large" graph
      ; dialog Xl "Extra large" graph
      ]
  in
  let%arr views in
  Node.div ~attrs:[ Attr.class_ "docs-row" ] views
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Dialog"
    ~group:Overlays
    ~description:
      "A window over the page that must be dealt with before going back to it."
    ~usage:
      {|Dialog.component
  ~title:"Rename file"
  ~trigger:(fun attrs -> Button.view ~attrs [ Node.text "Rename" ])
  (Bonsai.return (fun ~close ->
     ( [ body ]
     , [ Button.view ~on_click:close [ Node.text "Done" ] ] )))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "title", "string", "Names the dialog (it labels it for screen readers)."
          ; "description", "string", "A sentence under the title."
          ; "size", "Dialog.Size.t", "Sm, Md (default), Lg or Xl."
          ; "close_button", "bool", "The × in the corner (default true)."
          ; ( "trigger"
            , "Attr.t list -> Node.t"
            , "The element that opens it, given the attributes that make it a trigger." )
          ]
      ; Doc.h2 "Behaviour"
      ; Doc.p
          "While it is open, the page behind does not scroll, Tab and Shift+Tab cycle \
           through the dialog only, and Esc, the close button or a click on the scrim \
           closes it, giving focus back to the trigger. Dialog.view is the controlled form."
      ]
    [ Doc.example ~page "Edit profile" edit_profile; Doc.example ~page "Sizes" sizes ]
;;
