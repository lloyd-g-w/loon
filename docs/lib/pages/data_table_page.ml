open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "data_table"

(*$ Demo
   Filter by email, sort by pressing Email, hide columns from Columns, and tick rows
   to select them. *)
module Payment = struct
  type t =
    { id : string
    ; amount : float
    ; status : string
    ; email : string
    }

  let data =
    [ { id = "m5gr84i9"
      ; amount = 316.
      ; status = "success"
      ; email = "ken99@example.com"
      }
    ; { id = "3u1reuv4"
      ; amount = 242.
      ; status = "success"
      ; email = "Abe45@example.com"
      }
    ; { id = "derv1ws0"
      ; amount = 837.
      ; status = "processing"
      ; email = "Monserrat44@example.com"
      }
    ; { id = "5kma53ae"
      ; amount = 874.
      ; status = "success"
      ; email = "Silas22@example.com"
      }
    ; { id = "bhqecj4p"
      ; amount = 721.
      ; status = "failed"
      ; email = "carmella@example.com"
      }
    ]
  ;;
end

let copy_to_clipboard text =
  Effect.of_thunk (fun () ->
    try
      Js_of_ocaml.Js.Unsafe.global##.navigator##.clipboard##writeText
        (Js_of_ocaml.Js.string text)
      |> ignore
    with
    | _ -> ())
;;

let columns ~open_menu ~set_open_menu : Payment.t Data_table.Column.t list =
  [ Data_table.Column.create
      ~id:"select"
      ~hideable:false
      ~header:(fun table ->
        [ Checkbox.view
            ~attrs:[ Attr.create "aria-label" "Select all" ]
            ~checked:
              (if Data_table.is_all_page_rows_selected table
               then Checked
               else if Data_table.is_some_page_rows_selected table
               then Indeterminate
               else Unchecked)
            ~on_change:(Data_table.toggle_all_page_rows_selected table)
            ()
        ])
      ~cell:(fun table row ->
        [ Checkbox.view
            ~attrs:[ Attr.create "aria-label" "Select row" ]
            ~checked:(Checkbox.State.of_bool (Data_table.is_selected table row))
            ~on_change:(Data_table.toggle_selected table row)
            ()
        ])
      ()
  ; Data_table.Column.create
      ~id:"status"
      ~header:(fun _ -> [ Node.text "Status" ])
      ~sort:(Data_table.sort_text (fun (p : Payment.t) -> p.status))
      ~cell:(fun _ (row : Payment.t Data_table.Row.t) ->
        [ Node.div
            ~attrs:[ Attr.class_ "capitalize" ]
            [ Node.text row.original.status ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"email"
      ~header:(fun table ->
        [ Button.view
            ~variant:Ghost
            ~on_click:
              (Data_table.toggle_sorting
                 table
                 "email"
                 ~desc:
                   ([%equal: Data_table.Sort_direction.t option]
                      (Data_table.is_sorted table "email")
                      (Some Asc)))
            [ Node.text "Email"; Icon.view Arrow_up_down ]
        ])
      ~sort:(Data_table.sort_text (fun (p : Payment.t) -> p.email))
      ~filter:(fun (p : Payment.t) -> p.email)
      ~cell:(fun _ (row : Payment.t Data_table.Row.t) ->
        [ Node.div
            ~attrs:[ Attr.class_ "lowercase" ]
            [ Node.text row.original.email ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"amount"
      ~header:(fun _ ->
        [ Node.div ~attrs:[ Attr.class_ "text-right" ] [ Node.text "Amount" ] ])
      ~sort:(fun (a : Payment.t) b -> Float.compare a.amount b.amount)
      ~cell:(fun _ (row : Payment.t Data_table.Row.t) ->
        (* Formats the amount as a dollar amount. *)
        let formatted = sprintf "$%.2f" row.original.amount in
        [ Node.div
            ~attrs:[ Attr.class_ "text-right font-medium" ]
            [ Node.text formatted ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"actions"
      ~hideable:false
      ~header:(fun _ -> [])
      ~cell:(fun _ row ->
        let (payment : Payment.t) = row.original in
        let id = "payment-actions-" ^ payment.id in
        [ Dropdown_menu.view
            ~id
            ~state:
              (match open_menu with
               | Some (open_id, state) when String.equal open_id id -> state
               | _ -> Closed)
            ~on_change:(fun state ->
              set_open_menu
                (match (state : Dropdown_menu.State.t) with
                 | Closed -> None
                 | Open _ -> Some (id, state)))
            (fun menu ->
              [ Dropdown_menu.trigger
                  menu
                  (Button.view
                     ~variant:Ghost
                     ~class_:"h-8 w-8 p-0"
                     [ Node.span ~attrs:[ Attr.class_ "sr-only" ] [ Node.text "Open menu" ]
                     ; Icon.view Ellipsis
                     ])
              ; Dropdown_menu.content
                  menu
                  ~align:End
                  [ Dropdown_menu.label [ Node.text "Actions" ]
                  ; Dropdown_menu.item
                      ~on_select:(copy_to_clipboard payment.id)
                      [ Node.text "Copy payment ID" ]
                  ; Dropdown_menu.separator ()
                  ; Dropdown_menu.item [ Node.text "View customer" ]
                  ; Dropdown_menu.item [ Node.text "View payment details" ]
                  ]
              ])
        ])
      ()
  ]
;;

let demo (local_ graph) =
  let open_menu, set_open_menu = Bonsai.state None graph in
  let columns =
    let%arr open_menu
    and set_open_menu in
    columns ~open_menu ~set_open_menu
  in
  let table =
    Data_table.component
      ~get_row_id:(fun (p : Payment.t) -> p.id)
      ~columns
      (Bonsai.return Payment.data)
      graph
  in
  let column_menu =
    Dropdown_menu.component
      (let%arr table in
       fun menu ->
         [ Dropdown_menu.trigger
             menu
             (Button.view
                ~variant:Outline
                ~class_:"ml-auto"
                [ Node.text "Columns"; Icon.view Chevron_down ])
         ; Dropdown_menu.content
             menu
             ~align:End
             (Data_table.all_columns table
              |> List.filter ~f:Data_table.can_hide
              |> List.map ~f:(fun column ->
                let id = Data_table.Column.id column in
                Dropdown_menu.checkbox_item
                  ~class_:"capitalize"
                  ~checked:(Data_table.is_visible table id)
                  ~on_checked_change:(Data_table.toggle_visibility table id)
                  [ Node.text id ]))
         ])
      graph
  in
  let%arr table
  and column_menu in
  let visible = Data_table.visible_columns table in
  Node.div
    ~attrs:[ Attr.class_ "w-full" ]
    [ Node.div
        ~attrs:[ Attr.class_ "flex items-center py-4" ]
        [ Input.view
            ~class_:"max-w-sm"
            ~placeholder:"Filter emails..."
            ~value:(Data_table.filter_value table "email")
            ~on_input:(Data_table.set_filter_value table "email")
            ()
        ; column_menu
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "overflow-hidden rounded-md border" ]
        [ Table.root
            [ Table.header
                [ Table.row
                    (List.map visible ~f:(fun column ->
                       Table.head (Data_table.header table column)))
                ]
            ; Table.body
                (match Data_table.rows table with
                 | [] ->
                   [ Table.row
                       [ Table.cell
                           ~col_span:
                             (List.length (Data_table.all_columns table))
                           ~class_:"h-24 text-center"
                           [ Node.text "No results." ]
                       ]
                   ]
                 | rows ->
                   List.map rows ~f:(fun row ->
                     Table.row
                       ~selected:(Data_table.is_selected table row)
                       (List.map visible ~f:(fun column ->
                          Table.cell (Data_table.cell table column row)))))
            ]
        ]
    ; Node.div
        ~attrs:[ Attr.class_ "flex items-center justify-end space-x-2 py-4" ]
        [ Node.div
            ~attrs:[ Attr.class_ "flex-1 text-sm text-muted-foreground" ]
            [ Node.textf
                "%d of %d row(s) selected."
                (List.length (Data_table.filtered_selected_rows table))
                (List.length (Data_table.filtered_rows table))
            ]
        ; Node.div
            ~attrs:[ Attr.class_ "space-x-2" ]
            [ Button.view
                ~variant:Outline
                ~size:Sm
                ~on_click:(Data_table.previous_page table)
                ~disabled:(not (Data_table.can_previous_page table))
                [ Node.text "Previous" ]
            ; Button.view
                ~variant:Outline
                ~size:Sm
                ~on_click:(Data_table.next_page table)
                ~disabled:(not (Data_table.can_next_page table))
                [ Node.text "Next" ]
            ]
        ]
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Data table"
    ~description:"Powerful table and datagrids built using TanStack Table."
    ~usage:
      {|let table =
  Data_table.component ~get_row_id:(fun p -> p.id) ~columns data graph
in
let%arr table in
Table.root
  [ Table.header
      [ Table.row
          (List.map (Data_table.visible_columns table) ~f:(fun column ->
             Table.head (Data_table.header table column)))
      ]
  ; Table.body
      (List.map (Data_table.rows table) ~f:(fun row ->
         Table.row
           ~selected:(Data_table.is_selected table row)
           (List.map (Data_table.visible_columns table) ~f:(fun column ->
              Table.cell (Data_table.cell table column row)))))
  ]|}
    ~body:
      [ Doc.p
          "[Data_table] ports the parts of TanStack Table that shadcn's \
           example uses: the table's state (sorting, column filters, column \
           visibility, row selection, pagination) and the rows it gives. You \
           render the table yourself with [Table]'s parts, so every cell and \
           header is yours to shape."
      ; Doc.h2 "Columns"
      ; Doc.props
          [ ( "id"
            , "string"
            , "Names the column (in the state, and its default header)." )
          ; ( "header"
            , "'row Data_table.t -> Node.t list"
            , "Its heading; gets the table, e.g. to toggle sorting or select \
               every row." )
          ; ( "cell"
            , "'row Data_table.t -> 'row Data_table.Row.t -> Node.t list"
            , "A row's cell; [row.original] is the row's data." )
          ; ( "sort"
            , "'row -> 'row -> int"
            , "Makes it sortable. [Data_table.sort_text] compares text \
               case-insensitively." )
          ; ( "filter"
            , "'row -> string"
            , "The text its filter value is looked for in, case-insensitively."
            )
          ; ( "hideable"
            , "bool"
            , "[true] by default; [false] for the selection and actions \
               columns." )
          ]
      ; Doc.h2 "State"
      ; Doc.p
          "[Data_table.component] keeps the state in Bonsai; \
           [Data_table.create ~state ~on_change] is controlled ([on_change] \
           gets an updater, as with [Bonsai.state']). Read and change it with \
           the table's functions: [toggle_sorting], [set_filter_value], \
           [toggle_visibility], [toggle_selected], \
           [toggle_all_page_rows_selected], [previous_page], [next_page], \
           [set_page_size]. Rows are paginated 10 to a page by default."
      ]
    [ Doc.example ~page "Demo" demo ]
;;
