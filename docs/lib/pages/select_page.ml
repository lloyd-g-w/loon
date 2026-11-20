open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "select"

(*$ Fruit *)
let fruit (local_ graph) =
  let select =
    Select.component
      ~placeholder:"Select a fruit"
      (Bonsai.return
         [ Select.Group.create
             (List.map [ "Apple"; "Banana"; "Blueberry"; "Grapes"; "Pineapple" ] ~f:(fun f ->
                Select.Option_.create f))
         ])
      graph
  in
  let%arr value, view = select in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    [ view
    ; Node.span
        [ Node.text
            (match value with
             | None -> "Nothing chosen"
             | Some v -> "Chose " ^ v)
        ]
    ]
(*$*)

(*$ Groups, icons and disabled options
   Starts on a default value; open it to see the options under their
   headings. *)
let utc_offsets =
  [ "aest", "+10:00"
  ; "acst", "+9:30"
  ; "awst", "+8:00"
  ; "nzst", "+12:00"
  ; "gmt", "+0:00"
  ]
;;

let timezone (local_ graph) =
  let select =
    Select.component
      ~default:"aest"
      (Bonsai.return
         [ Select.Group.create
             ~label:"Australia"
             [ Select.Option_.create ~label:"Sydney (AEST)" "aest"
             ; Select.Option_.create ~label:"Adelaide (ACST)" "acst"
             ; Select.Option_.create ~label:"Perth (AWST)" "awst"
             ]
         ; Select.Group.create
             ~label:"Elsewhere"
             [ Select.Option_.create ~icon:Home ~label:"Auckland (NZST)" "nzst"
             ; Select.Option_.create ~label:"London (GMT)" "gmt"
             ; Select.Option_.create ~disabled:true ~label:"Mars (MTC)" "mtc"
             ]
         ])
      graph
  in
  let%arr zone, view = select in
  Node.div
    ~attrs:[ Vdom.Attr.class_ "docs-row" ]
    [ view
    ; Node.span
        ~attrs:[ Vdom.Attr.class_ "loon-field-description" ]
        [ Node.text
            (match
               Option.bind zone ~f:(List.Assoc.find utc_offsets ~equal:String.equal)
             with
             | None -> "No time zone"
             | Some offset -> "UTC" ^ offset)
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Select"
    ~group:Forms
    ~description:"Choose one value from a list that opens beside its trigger."
    ~usage:
      {|let%sub value, view =
  Select.component
    ~placeholder:"Theme"
    (Bonsai.return
       [ Select.Group.create
           [ Select.Option_.create "Light"; Select.Option_.create "Dark" ] ])
    graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "placeholder", "string", "Shown until something is chosen."
          ; "default", "string", "The value chosen at first."
          ; "disabled", "bool", "Greys it out."
          ; ( "groups"
            , "Select.Group.t list Bonsai.t"
            , "Options (value, label, optional icon, disabled), under optional headings." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.p
          "Arrows, Enter or Space open it on the current value; arrows, Home, End and \
           letters move; Enter, Space or a click chooses; Esc closes. A letter typed on the \
           closed select changes the value, as a native one does."
      ]
    [ Doc.example ~page "Fruit" fruit
    ; Doc.example ~page "Groups, icons and disabled options" timezone
    ]
;;
