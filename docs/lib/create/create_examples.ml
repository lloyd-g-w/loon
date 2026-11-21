open! Core
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr

let pages =
  List.filter Pages.all ~f:(fun (p : Doc.Page.t) ->
    Doc.Section.equal p.section Components && not (List.is_empty p.examples))
  |> List.sort ~compare:(fun (a : Doc.Page.t) (b : Doc.Page.t) ->
    String.compare a.title b.title)
;;

let name (p : Doc.Page.t) = p.slug ^ "-example"
let items = List.map pages ~f:(fun p -> name p, p.title)
let mem item = List.exists pages ~f:(fun p -> String.equal (name p) item)

module Item = struct
  type t = string [@@deriving compare, equal, sexp]

  let all = List.map pages ~f:name
end

(* components/example.tsx *)
let example (e : Doc.Example.t) content =
  Node.div
    ~attrs:
      [ Attr.create "data-slot" "example"
      ; Attr.class_
          "mx-auto flex w-full max-w-lg min-w-0 flex-col gap-1 self-stretch lg:max-w-none"
      ]
    [ Node.div
        ~attrs:[ Attr.class_ "px-1.5 py-2 text-xs font-medium text-muted-foreground" ]
        [ Node.text e.title ]
    ; Node.div
        ~attrs:
          [ Attr.create "data-slot" "example-content"
          ; Attr.class_
              "flex min-w-0 flex-1 flex-col items-start gap-6 rounded-xl bg-card p-12 \
               text-foreground *:[div:not([class*='w-'])]:w-full"
          ]
        [ content ]
    ]
;;

let wrapper children =
  Node.div
    ~attrs:[ Attr.class_ "min-h-full w-full bg-muted dark:bg-background" ]
    [ Node.div
        ~attrs:
          [ Attr.create "data-slot" "example-wrapper"
          ; Attr.class_
              "mx-auto grid min-h-full w-full max-w-5xl min-w-0 content-center \
               items-start gap-8 p-4 pt-2 sm:gap-12 sm:p-6 md:grid-cols-2 md:gap-8 \
               lg:p-12 2xl:max-w-6xl"
          ]
        children
    ]
;;

let component item (local_ graph) =
  Bonsai.enum
    (module Item)
    ~match_:item
    ~with_:(fun item (local_ graph) ->
      let page = List.find_exn pages ~f:(fun p -> String.equal (name p) item) in
      let views =
        List.map page.examples ~f:(fun (e : Doc.Example.t) ->
          Bonsai.map (e.view graph) ~f:(example e))
      in
      Bonsai.map (Bonsai.all views) ~f:wrapper)
    graph
;;
