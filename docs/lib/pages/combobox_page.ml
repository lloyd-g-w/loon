open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node

let page = "combobox"

(*$ Framework *)
let framework (local_ graph) =
  let combobox =
    Combobox.component
      ~placeholder:"Select a framework…"
      ~search_placeholder:"Search frameworks…"
      ~empty:"No framework found."
      (Bonsai.return
         [ Select.Group.create
             ~label:"OCaml"
             (List.map [ "Bonsai"; "Incr_dom"; "Ocsigen"; "Brr"; "Dream" ] ~f:(fun f ->
                Select.Option_.create f))
         ; Select.Group.create
             ~label:"Other"
             (List.map [ "React"; "Svelte"; "SolidJS"; "Elm"; "Phoenix LiveView" ] ~f:(fun f ->
                Select.Option_.create f))
         ])
      graph
  in
  let%arr _, view = combobox in
  view
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Combobox"
    ~group:Forms
    ~description:"A select with a search box, for choosing one of many options."
    ~usage:
      {|let%sub value, view =
  Combobox.component ~placeholder:"Country" (Bonsai.return groups) graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "placeholder", "string", "Shown until something is chosen."
          ; "search_placeholder", "string", "In the search box."
          ; "empty", "string", "Shown when nothing matches."
          ; "groups", "Select.Group.t list Bonsai.t", "The options, as for a select."
          ]
      ]
    [ Doc.example ~page "Framework" framework ]
;;
