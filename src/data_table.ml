open! Import

module Direction = struct
  type t =
    | Ascending
    | Descending
  [@@deriving sexp_of, compare, equal]
end

module Column = struct
  type 'row t =
    { id : string
    ; header : string
    ; align : Table.Align.t
    ; cell : 'row -> Node.t
    ; sort : ('row -> 'row -> int) option
    ; search : ('row -> string) option
    ; secondary : bool
    }

  let create ?(align = Table.Align.Left) ?(secondary = false) ?sort ?search ~id header cell
    =
    { id; header; align; cell; sort; search; secondary }
  ;;

  let text ?align ?secondary ~id header f =
    create
      ?align
      ?secondary
      ~sort:(fun a b -> String.compare (f a) (f b))
      ~search:f
      ~id
      header
      (fun r -> Node.text (f r))
  ;;
end

let visible_rows ~(columns : _ Column.t list) ~filter ~sort rows =
  let needle = String.lowercase (String.strip filter) in
  let searches = List.filter_map columns ~f:(fun c -> c.search) in
  let rows =
    if String.is_empty needle || List.is_empty searches
    then rows
    else
      List.filter rows ~f:(fun r ->
        List.exists searches ~f:(fun s ->
          String.is_substring (String.lowercase (s r)) ~substring:needle))
  in
  match sort with
  | None -> rows
  | Some (id, direction) ->
    (match
       List.find_map columns ~f:(fun c -> if String.equal c.id id then c.sort else None)
     with
     | None -> rows
     | Some compare ->
       let compare =
         match (direction : Direction.t) with
         | Ascending -> compare
         | Descending -> fun a b -> compare b a
       in
       List.stable_sort rows ~compare)
;;

type t =
  { view : Node.t
  ; selected : String.Set.t
  }

let next_sort current id =
  match current with
  | Some (c, Direction.Ascending) when String.equal c id -> Some (id, Direction.Descending)
  | Some (c, Descending) when String.equal c id -> None
  | _ -> Some (id, Ascending)
;;

let checkbox ~label ~checked ?(indeterminate = false) on_click =
  Node.input
    ~attrs:
      [ Attr.class_ "loon-data-table-check"
      ; Attr.type_ "checkbox"
      ; aria "label" label
      ; Attr.bool_property "checked" checked
      ; Attr.bool_property "indeterminate" indeterminate
      ; Attr.on_click (fun _ -> on_click)
      ]
    ()
;;

let secondary (column : _ Column.t) =
  if column.secondary then [ Attr.class_ "loon-data-table-secondary" ] else []
;;

let sort_header (column : _ Column.t) ~sort ~set_sort =
  let direction =
    match sort with
    | Some (id, d) when String.equal id column.id -> Some d
    | _ -> None
  in
  let aria_sort =
    match direction with
    | None -> "none"
    | Some Direction.Ascending -> "ascending"
    | Some Descending -> "descending"
  in
  match column.sort with
  | None ->
    Table.head ~attrs:(secondary column) ~align:column.align [ Node.text column.header ]
  | Some _ ->
    Table.head
      ~attrs:(aria "sort" aria_sort :: secondary column)
      ~align:column.align
      [ Node.button
          ~attrs:
            [ Attr.class_ "loon-data-table-sort"
            ; Attr.type_ "button"
            ; data "sort" aria_sort
            ; Attr.on_click (fun _ -> set_sort (next_sort sort column.id))
            ]
          [ Node.text column.header
          ; Icon.view
              ~attrs:[ Attr.class_ "loon-data-table-sort-icon" ]
              (match direction with
               | None -> Chevrons_up_down
               | Some Ascending -> Chevron_up
               | Some Descending -> Chevron_down)
          ]
      ]
;;

let component
  ?attrs
  ?striped
  ?dense
  ?caption
  ?(filter_placeholder = "Filter…")
  ?(selectable = false)
  ?page_size
  ?empty
  ?(toolbar = [])
  ~columns
  ~key
  rows
  (local_ graph)
  =
  let filter, set_filter = Bonsai.state "" graph in
  let sort, set_sort = Bonsai.state None graph in
  let selected, update_selected = Bonsai.state' String.Set.empty graph in
  let page, set_page = Bonsai.state 1 graph in
  let open Bonsai.Let_syntax in
  let%arr filter
  and set_filter
  and sort
  and set_sort
  and selected
  and update_selected
  and page
  and set_page
  and columns
  and rows in
  (* Rows that have gone stop being selected. *)
  let keys = String.Set.of_list (List.map rows ~f:key) in
  let selected = Set.inter selected keys in
  let visible = visible_rows ~columns ~filter ~sort rows in
  let n = List.length visible in
  let pages, page, shown =
    match page_size with
    | None -> 1, 1, visible
    | Some size ->
      let size = Int.max 1 size in
      let pages = Int.max 1 ((n + size - 1) / size) in
      let page = Int.clamp_exn page ~min:1 ~max:pages in
      pages, page, List.take (List.drop visible ((page - 1) * size)) size
  in
  let visible_keys = List.map visible ~f:key in
  let all_selected =
    (not (List.is_empty visible_keys)) && List.for_all visible_keys ~f:(Set.mem selected)
  in
  let some_selected = List.exists visible_keys ~f:(Set.mem selected) in
  let toggle k =
    update_selected (fun selected ->
      if Set.mem selected k then Set.remove selected k else Set.add selected k)
  in
  let toggle_all =
    update_selected (fun selected ->
      if all_selected
       then List.fold visible_keys ~init:selected ~f:Set.remove
       else List.fold visible_keys ~init:selected ~f:Set.add)
  in
  let searchable = List.exists columns ~f:(fun c -> Option.is_some c.search) in
  let header_row =
    Table.row
      ((if selectable
        then
          [ Table.head
              ~attrs:[ Attr.class_ "loon-data-table-select" ]
              [ checkbox
                  ~label:"Select all"
                  ~checked:all_selected
                  ~indeterminate:(some_selected && not all_selected)
                  toggle_all
              ]
          ]
        else [])
       @ List.map columns ~f:(fun c ->
         sort_header c ~sort ~set_sort:(fun s -> Effect.Many [ set_sort s; set_page 1 ])))
  in
  let width = List.length columns + if selectable then 1 else 0 in
  let body_rows =
    match shown with
    | [] ->
      [ Table.row
          [ Table.cell
              ~attrs:[ Attr.class_ "loon-data-table-empty" ]
              ~align:Center
              ~colspan:width
              [ Option.value empty ~default:(Node.text "No results.") ]
          ]
      ]
    | shown ->
      List.map shown ~f:(fun r ->
        let k = key r in
        let is_selected = Set.mem selected k in
        Table.row
          ~key:k
          ~selected:is_selected
          ((if selectable
            then
              [ Table.cell
                  ~attrs:[ Attr.class_ "loon-data-table-select" ]
                  [ checkbox ~label:"Select row" ~checked:is_selected (toggle k) ]
              ]
            else [])
           @ List.map columns ~f:(fun c ->
             Table.cell ~attrs:(secondary c) ~align:c.align [ c.cell r ])))
  in
  let status =
    if selectable
    then sprintf "%d of %d row%s selected" (Set.length selected) (List.length rows)
           (if List.length rows = 1 then "" else "s")
    else sprintf "%d row%s" n (if n = 1 then "" else "s")
  in
  let view =
    Node.div
      ~attrs:(Import.attrs ?attrs [ "loon-data-table" ])
      [ (if searchable || not (List.is_empty toolbar)
         then
           Node.div
             ~attrs:[ Attr.class_ "loon-data-table-toolbar" ]
             ((if searchable
               then
                 [ Node.div
                     ~attrs:[ Attr.class_ "loon-data-table-filter" ]
                     [ Icon.view Search
                     ; Node.input
                         ~attrs:
                           [ Attr.type_ "search"
                           ; Attr.placeholder filter_placeholder
                           ; aria "label" "Filter rows"
                           ; Attr.string_property "value" filter
                           ; Attr.on_input (fun _ text ->
                               Effect.Many [ set_filter text; set_page 1 ])
                           ]
                         ()
                     ]
                 ]
               else [])
              @ toolbar)
         else Node.none)
      ; Node.div
          ~attrs:[ Attr.class_ "loon-data-table-frame" ]
          [ Table.table
              ?striped
              ?dense
              ?caption
              [ Table.header [ header_row ]; Table.body body_rows ]
          ]
      ; Node.div
          ~attrs:[ Attr.class_ "loon-data-table-footer" ]
          [ Node.div
              ~attrs:[ Attr.class_ "loon-data-table-status"; aria "live" "polite" ]
              [ Node.text status ]
          ; (if pages > 1
             then
               (* shadcn's data table: Previous and Next buttons. *)
               Node.div
                 ~attrs:[ Attr.class_ "flex items-center gap-2" ]
                 [ Button.view
                     ~variant:Outline
                     ~size:Sm
                     ~disabled:(page <= 1)
                     ~on_click:(set_page (page - 1))
                     [ Node.text "Previous" ]
                 ; Button.view
                     ~variant:Outline
                     ~size:Sm
                     ~disabled:(page >= pages)
                     ~on_click:(set_page (page + 1))
                     [ Node.text "Next" ]
                 ]
             else Node.none)
          ]
      ]
  in
  { view; selected }
;;
