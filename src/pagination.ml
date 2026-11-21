open! Import

module Entry = struct
  type t =
    | Page of int
    | Ellipsis
  [@@deriving sexp_of, compare, equal]
end

let range a b = List.range a b ~stop:`inclusive |> List.map ~f:(fun p -> Entry.Page p)

let entries ?(siblings = 1) ~page ~pages () : Entry.t list =
  let page = Int.clamp_exn page ~min:1 ~max:(Int.max 1 pages) in
  (* first, last, current, the siblings and two ellipses *)
  let slots = (2 * siblings) + 5 in
  if pages <= slots
  then range 1 pages
  else (
    let left = Int.max (page - siblings) 1 in
    let right = Int.min (page + siblings) pages in
    let show_left = left > 3 in
    let show_right = right < pages - 2 in
    match show_left, show_right with
    | false, true -> range 1 (3 + (2 * siblings)) @ [ Entry.Ellipsis; Page pages ]
    | true, false -> (Entry.Page 1 :: [ Entry.Ellipsis ]) @ range (pages - (2 + (2 * siblings))) pages
    | _ -> (Entry.Page 1 :: Ellipsis :: range left right) @ [ Ellipsis; Page pages ])
;;

let view ?attrs:extra ?siblings ?(compact = false) ~page ~pages ~on_change () =
  let pages = Int.max 1 pages in
  let page = Int.clamp_exn page ~min:1 ~max:pages in
  let go p ev = Effect.Many [ Dom_util.prevent_default ev; on_change p ] in
  let step ~label ~icon ~target ~text ~disabled =
    Node.li
      [ Node.button
          ~attrs:
            ([ Attr.classes [ "loon-pagination-link"; "loon-pagination-step" ]
             ; Attr.type_ "button"
             ; aria "label" label
             ]
             @ if disabled then [ Attr.disabled ] else [ Attr.on_click (go target) ])
          (match icon with
           | `Before i ->
             [ Icon.view i; Node.span ~attrs:[ Attr.class_ "loon-pagination-step-text" ] [ Node.text text ] ]
           | `After i ->
             [ Node.span ~attrs:[ Attr.class_ "loon-pagination-step-text" ] [ Node.text text ]; Icon.view i ])
      ]
  in
  let numbers =
    if compact
    then
      [ Node.li
          ~attrs:[ Attr.class_ "loon-pagination-compact"; aria "live" "polite" ]
          [ Node.textf "Page %d of %d" page pages ]
      ]
    else
      List.map (entries ?siblings ~page ~pages ()) ~f:(function
        | Ellipsis ->
          Node.li
            [ Node.span
                ~attrs:[ Attr.class_ "loon-pagination-ellipsis"; aria "hidden" "true" ]
                [ Icon.view Ellipsis ]
            ]
        | Page p ->
          let current = p = page in
          Node.li
            [ Node.button
                ~attrs:
                  ([ Attr.class_ "loon-pagination-link"
                   ; Attr.type_ "button"
                   ; aria "label" (sprintf "Page %d" p)
                   ; Attr.on_click (go p)
                   ]
                   @ if current then [ aria "current" "page"; data "state" "active" ] else [])
                [ Node.text (Int.to_string p) ]
            ])
  in
  Node.nav
    ~attrs:(attrs ?attrs:extra [ "loon-pagination" ] @ [ aria "label" "Pagination" ])
    [ Node.ul
        ~attrs:[ Attr.class_ "loon-pagination-list" ]
        ((step
            ~label:"Previous page"
            ~icon:(`Before Icon.Chevron_left)
            ~text:"Previous"
            ~target:(page - 1)
            ~disabled:(page <= 1)
          :: numbers)
         @ [ step
               ~label:"Next page"
               ~icon:(`After Icon.Chevron_right)
               ~text:"Next"
               ~target:(page + 1)
               ~disabled:(page >= pages)
           ])
    ]
;;

type t =
  { page : int
  ; view : Node.t
  }

let component ?attrs ?siblings ?compact ?(default = 1) ~pages (local_ graph) =
  let page, set_page = Bonsai.state default graph in
  let open Bonsai.Let_syntax in
  let%arr page and set_page and pages in
  let page = Int.clamp_exn page ~min:1 ~max:(Int.max 1 pages) in
  { page; view = view ?attrs ?siblings ?compact ~page ~pages ~on_change:set_page () }
;;
