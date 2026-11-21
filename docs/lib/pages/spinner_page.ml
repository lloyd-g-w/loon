open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "spinner"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-xs flex-col gap-4 [--radius:1rem]" ]
    [ Item.view
        ~variant:Muted
        [ Item.media [ Spinner.view () ]
        ; Item.content
            [ Item.title ~class_:"line-clamp-1" [ Node.text "Processing payment..." ] ]
        ; Item.content
            ~class_:"flex-none justify-end"
            [ Node.span ~attrs:[ Attr.class_ "text-sm tabular-nums" ] [ Node.text "$100.00" ]
            ]
        ]
    ]
(*$*)

(*$ Basic *)
let basic =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-center justify-center gap-8" ]
    [ Spinner.view () ]
(*$*)

(*$ Size
   Size it with a [size-*] class. *)
let size =
  Node.div
    ~attrs:[ Attr.class_ "flex items-center gap-6" ]
    [ Spinner.view ~class_:"size-3" ()
    ; Spinner.view ~class_:"size-4" ()
    ; Spinner.view ~class_:"size-6" ()
    ; Spinner.view ~class_:"size-8" ()
    ]
(*$*)

(*$ Color
   Colour it with a [text-*] class. *)
let color =
  Node.div
    ~attrs:[ Attr.class_ "flex items-center gap-6" ]
    [ Spinner.view ~class_:"size-6 text-red-500" ()
    ; Spinner.view ~class_:"size-6 text-green-500" ()
    ; Spinner.view ~class_:"size-6 text-blue-500" ()
    ; Spinner.view ~class_:"size-6 text-yellow-500" ()
    ; Spinner.view ~class_:"size-6 text-purple-500" ()
    ]
(*$*)

(*$ Custom
   Another icon, spinning: a spinner of your own. *)
let custom =
  let spinner ?class_ () =
    Icon.view
      ~attrs:[ Attr.role "status"; Attr.create "aria-label" "Loading" ]
      ~class_:(Cn.cn ([ "size-4 animate-spin" ] @ Option.to_list class_))
      Loader
  in
  Node.div ~attrs:[ Attr.class_ "flex items-center gap-4" ] [ spinner () ]
(*$*)

(*$ Button *)
let button =
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col items-center gap-4" ]
    [ Button.view ~disabled:true ~size:Sm [ Spinner.view (); Node.text "Loading..." ]
    ; Button.view
        ~variant:Outline
        ~disabled:true
        ~size:Sm
        [ Spinner.view (); Node.text "Please wait" ]
    ; Button.view
        ~variant:Secondary
        ~disabled:true
        ~size:Sm
        [ Spinner.view (); Node.text "Processing" ]
    ]
(*$*)

(*$ Badge *)
let badge =
  Node.div
    ~attrs:[ Attr.class_ "flex items-center gap-4 [--radius:1.2rem]" ]
    [ Badge.view [ Spinner.view (); Node.text "Syncing" ]
    ; Badge.view ~variant:Secondary [ Spinner.view (); Node.text "Updating" ]
    ; Badge.view ~variant:Outline [ Spinner.view (); Node.text "Processing" ]
    ]
(*$*)

(*$ Empty *)
let empty =
  Empty.root
    ~class_:"w-full"
    [ Empty.header
        [ Empty.media ~variant:Icon [ Spinner.view () ]
        ; Empty.title [ Node.text "Processing your request" ]
        ; Empty.description
            [ Node.text
                "Please wait while we process your request. Do not refresh the page."
            ]
        ]
    ; Empty.content [ Button.view ~variant:Outline ~size:Sm [ Node.text "Cancel" ] ]
    ]
(*$*)

(*$ Item *)
let item =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-4 [--radius:1rem]" ]
    [ Item.view
        ~variant:Outline
        [ Item.media ~variant:Icon [ Spinner.view () ]
        ; Item.content
            [ Item.title [ Node.text "Downloading..." ]
            ; Item.description [ Node.text "129 MB / 1000 MB" ]
            ]
        ; Item.actions
            ~class_:"hidden sm:flex"
            [ Button.view ~variant:Outline ~size:Sm [ Node.text "Cancel" ] ]
        ; Item.footer [ Progress.view ~value:75. () ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Spinner"
    ~description:"An indicator that can be used to show a loading state."
    ~usage:{|Spinner.view ()|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "class_"
            , "string"
            , "Its size ([size-6]) and colour ([text-blue-500]), merged last." )
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Basic" basic
    ; Doc.static ~page "Size" size
    ; Doc.static ~page "Color" color
    ; Doc.static ~page "Custom" custom
    ; Doc.static ~page "Button" button
    ; Doc.static ~page "Badge" badge
    ; Doc.static ~page "Empty" empty
    ; Doc.static ~page "Item" item
    ]
;;
