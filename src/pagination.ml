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

let root ?(attrs = []) ?class_ children =
  Node.create
    "nav"
    ~attrs:
      ([ Attr.role "navigation"
       ; aria "label" "pagination"
       ; data "slot" "pagination"
       ; Cn.with_class ?class_ [ "mx-auto flex w-full justify-center" ]
       ]
       @ attrs)
    children
;;

let content ?(attrs = []) ?class_ children =
  Node.ul
    ~attrs:
      ([ data "slot" "pagination-content"
       ; Cn.with_class ?class_ [ "flex flex-row items-center gap-1" ]
       ]
       @ attrs)
    children
;;

let item ?(attrs = []) ?class_ children =
  Node.li
    ~attrs:
      ([ data "slot" "pagination-item" ]
       @ Option.value_map class_ ~default:[] ~f:(fun c -> [ Cn.attr [ c ] ])
       @ attrs)
    children
;;

let link ?(attrs = []) ?class_ ?(is_active = false) ?(size = Button.Size.Icon) ?href
  ?on_click children
  =
  Node.a
    ~attrs:
      ((if is_active then [ aria "current" "page" ] else [])
       @ [ data "slot" "pagination-link" ]
       @ (if is_active then [ data "active" "true" ] else [])
       @ [ Attr.class_
             (Button.classes
                ~variant:(if is_active then Outline else Ghost)
                ~size
                ?class_
                ())
         ]
       @ Option.value_map href ~default:[] ~f:(fun h -> [ Attr.href h ])
       @ Option.value_map on_click ~default:[] ~f:(fun effect ->
         [ Attr.on_click (fun ev -> Effect.Many [ Dom_util.prevent_default ev; effect ]) ])
       @ attrs)
    children
;;

let previous ?(attrs = []) ?class_ ?href ?on_click () =
  link
    ~attrs:([ aria "label" "Go to previous page" ] @ attrs)
    ~size:Default
    ~class_:(Cn.cn ([ "gap-1 px-2.5 sm:pl-2.5" ] @ Option.to_list class_))
    ?href
    ?on_click
    [ Icon.view Chevron_left
    ; Node.span ~attrs:[ Attr.class_ "hidden sm:block" ] [ Node.text "Previous" ]
    ]
;;

let next ?(attrs = []) ?class_ ?href ?on_click () =
  link
    ~attrs:([ aria "label" "Go to next page" ] @ attrs)
    ~size:Default
    ~class_:(Cn.cn ([ "gap-1 px-2.5 sm:pr-2.5" ] @ Option.to_list class_))
    ?href
    ?on_click
    [ Node.span ~attrs:[ Attr.class_ "hidden sm:block" ] [ Node.text "Next" ]
    ; Icon.view Chevron_right
    ]
;;

let ellipsis ?(attrs = []) ?class_ () =
  Node.span
    ~attrs:
      ([ aria "hidden" "true"
       ; data "slot" "pagination-ellipsis"
       ; Cn.with_class ?class_ [ "flex size-9 items-center justify-center" ]
       ]
       @ attrs)
    [ Icon.view ~class_:"size-4" Ellipsis
    ; Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "More pages" ]
    ]
;;
