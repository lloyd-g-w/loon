open! Core
open Loon
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr
module Handle = Bonsai_web_test.Handle

type person =
  { name : string
  ; role : string
  ; age : int
  }

let people =
  [ { name = "Ada"; role = "Mathematician"; age = 36 }
  ; { name = "grace"; role = "Admiral"; age = 85 }
  ; { name = "Alan"; role = "Mathematician"; age = 41 }
  ; { name = "Edsger"; role = "Programmer"; age = 72 }
  ]
;;

let columns : person Data_table.Column.t list =
  [ Data_table.Column.create
      ~id:"select"
      ~hideable:false
      ~header:(fun table ->
        [ Node.button
            ~attrs:
              [ Attr.id "all"
              ; Attr.on_click (fun _ ->
                  Data_table.toggle_all_page_rows_selected
                    table
                    (not (Data_table.is_all_page_rows_selected table)))
              ]
            [ Node.textf
                "all:%b some:%b"
                (Data_table.is_all_page_rows_selected table)
                (Data_table.is_some_page_rows_selected table)
            ]
        ])
      ~cell:(fun table row ->
        [ Node.button
            ~attrs:
              [ Attr.id ("select-" ^ row.id)
              ; Attr.on_click (fun _ ->
                  Data_table.toggle_selected
                    table
                    row
                    (not (Data_table.is_selected table row)))
              ]
            [ Node.text "select" ]
        ])
      ()
  ; Data_table.Column.create
      ~id:"name"
      ~header:(fun table ->
        [ Node.button
            ~attrs:
              [ Attr.id "sort-name"
              ; Attr.on_click (fun _ -> Data_table.toggle_sorting table "name")
              ]
            [ Node.textf
                "Name %s"
                (Option.value_map
                   (Data_table.is_sorted table "name")
                   ~default:"-"
                   ~f:Data_table.Sort_direction.name)
            ]
        ])
      ~sort:(Data_table.sort_text (fun p -> p.name))
      ~filter:(fun p -> p.name)
      ~cell:(fun _ row -> [ Node.text row.original.name ])
      ()
  ; Data_table.Column.create
      ~id:"role"
      ~filter:(fun p -> p.role)
      ~cell:(fun _ row -> [ Node.text row.original.role ])
      ()
  ; Data_table.Column.create
      ~id:"age"
      ~sort:(fun a b -> Int.compare a.age b.age)
      ~cell:(fun _ row -> [ Node.text (Int.to_string row.original.age) ])
      ()
  ]
;;

let component (local_ graph) =
  let open Bonsai.Let_syntax in
  let table =
    Data_table.component
      ~get_row_id:(fun p -> p.name)
      ~default_state:{ Data_table.State.default with page_size = 3 }
      ~columns:(Bonsai.return columns)
      (Bonsai.return people)
      graph
  in
  let%arr table in
  Node.div
    [ Node.input
        ~attrs:
          [ Attr.id "filter"
          ; Attr.on_input (fun _ s ->
              Data_table.set_filter_value table "name" s)
          ]
        ()
    ; Node.button
        ~attrs:
          [ Attr.id "hide-role"
          ; Attr.on_click (fun _ ->
              Data_table.toggle_visibility
                table
                "role"
                (not (Data_table.is_visible table "role")))
          ]
        [ Node.text "role" ]
    ; Table.root
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
        ]
    ; Node.p
        [ Node.textf
            "%d of %d row(s) selected; page %d of %d; previous:%b next:%b"
            (List.length (Data_table.filtered_selected_rows table))
            (List.length (Data_table.filtered_rows table))
            ((Data_table.state table).page_index + 1)
            (Data_table.page_count table)
            (Data_table.can_previous_page table)
            (Data_table.can_next_page table)
        ]
    ; Node.button
        ~attrs:
          [ Attr.id "next"
          ; Attr.on_click (fun _ -> Data_table.next_page table)
          ]
        [ Node.text "Next" ]
    ; Node.button
        ~attrs:
          [ Attr.id "previous"
          ; Attr.on_click (fun _ -> Data_table.previous_page table)
          ]
        [ Node.text "Previous" ]
    ]
;;

let click handle id =
  Handle.click_on handle ~get_vdom:Fn.id ~selector:("#" ^ id);
  Handle.recompute_view handle
;;

let%expect_test "sorting, filtering, visibility, selection and pagination" =
  let handle = Render.handle ~classes:false component in
  Handle.show handle;
  [%expect
    {|
    <div>
      <input id="filter" @on_input/>
      <button id="hide-role" @on_click> role </button>
      <div data-slot="table-container">
        <table data-slot="table">
          <thead data-slot="table-header">
            <tr data-slot="table-row">
              <th data-slot="table-head">
                <button id="all" @on_click> all:false some:false </button>
              </th>
              <th data-slot="table-head">
                <button id="sort-name" @on_click> Name - </button>
              </th>
              <th data-slot="table-head"> role </th>
              <th data-slot="table-head"> age </th>
            </tr>
          </thead>
          <tbody data-slot="table-body">
            <tr data-slot="table-row">
              <td data-slot="table-cell">
                <button id="select-Ada" @on_click> select </button>
              </td>
              <td data-slot="table-cell"> Ada </td>
              <td data-slot="table-cell"> Mathematician </td>
              <td data-slot="table-cell"> 36 </td>
            </tr>
            <tr data-slot="table-row">
              <td data-slot="table-cell">
                <button id="select-grace" @on_click> select </button>
              </td>
              <td data-slot="table-cell"> grace </td>
              <td data-slot="table-cell"> Admiral </td>
              <td data-slot="table-cell"> 85 </td>
            </tr>
            <tr data-slot="table-row">
              <td data-slot="table-cell">
                <button id="select-Alan" @on_click> select </button>
              </td>
              <td data-slot="table-cell"> Alan </td>
              <td data-slot="table-cell"> Mathematician </td>
              <td data-slot="table-cell"> 41 </td>
            </tr>
          </tbody>
        </table>
      </div>
      <p> 0 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
      <button id="next" @on_click> Next </button>
      <button id="previous" @on_click> Previous </button>
    </div>
    |}];
  (* Sorting by name: ascending, case-insensitively, then descending, then not. *)
  click handle "sort-name";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
                  <button id="all" @on_click> all:false some:false </button>
                </th>
                <th data-slot="table-head">
    -|            <button id="sort-name" @on_click> Name - </button>
    +|            <button id="sort-name" @on_click> Name asc </button>
                </th>
                <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
              <tr data-slot="table-row">
                <td data-slot="table-cell">
                  <button id="select-Ada" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Ada </td>
                <td data-slot="table-cell"> Mathematician </td>
                <td data-slot="table-cell"> 36 </td>
              </tr>
    -|        <tr data-slot="table-row">
    -|          <td data-slot="table-cell">
    -|            <button id="select-grace" @on_click> select </button>
    -|          </td>
    -|          <td data-slot="table-cell"> grace </td>
    -|          <td data-slot="table-cell"> Admiral </td>
    -|          <td data-slot="table-cell"> 85 </td>
    -|        </tr>
              <tr data-slot="table-row">
                <td data-slot="table-cell">
                  <button id="select-Alan" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Alan </td>
                <td data-slot="table-cell"> Mathematician </td>
                <td data-slot="table-cell"> 41 </td>
              </tr>
    +|        <tr data-slot="table-row">
    +|          <td data-slot="table-cell">
    +|            <button id="select-Edsger" @on_click> select </button>
    +|          </td>
    +|          <td data-slot="table-cell"> Edsger </td>
    +|          <td data-slot="table-cell"> Programmer </td>
    +|          <td data-slot="table-cell"> 72 </td>
    +|        </tr>
            </tbody>
          </table>
        </div>
        <p> 0 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}];
  click handle "sort-name";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
                  <button id="all" @on_click> all:false some:false </button>
                </th>
                <th data-slot="table-head">
    -|            <button id="sort-name" @on_click> Name asc </button>
    +|            <button id="sort-name" @on_click> Name desc </button>
                </th>
                <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
              <tr data-slot="table-row">
                <td data-slot="table-cell">
    -|            <button id="select-Ada" @on_click> select </button>
    +|            <button id="select-grace" @on_click> select </button>
                </td>
    -|          <td data-slot="table-cell"> Ada </td>
    +|          <td data-slot="table-cell"> grace </td>
    -|          <td data-slot="table-cell"> Mathematician </td>
    +|          <td data-slot="table-cell"> Admiral </td>
    -|          <td data-slot="table-cell"> 36 </td>
    -|        </tr>
    -|        <tr data-slot="table-row">
    -|          <td data-slot="table-cell">
    -|            <button id="select-Alan" @on_click> select </button>
    -|          </td>
    -|          <td data-slot="table-cell"> Alan </td>
    -|          <td data-slot="table-cell"> Mathematician </td>
    -|          <td data-slot="table-cell"> 41 </td>
    +|          <td data-slot="table-cell"> 85 </td>
              </tr>
              <tr data-slot="table-row">
                <td data-slot="table-cell">
                  <button id="select-Edsger" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Edsger </td>
                <td data-slot="table-cell"> Programmer </td>
                <td data-slot="table-cell"> 72 </td>
              </tr>
    +|        <tr data-slot="table-row">
    +|          <td data-slot="table-cell">
    +|            <button id="select-Alan" @on_click> select </button>
    +|          </td>
    +|          <td data-slot="table-cell"> Alan </td>
    +|          <td data-slot="table-cell"> Mathematician </td>
    +|          <td data-slot="table-cell"> 41 </td>
    +|        </tr>
            </tbody>
          </table>
        </div>
        <p> 0 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}];
  click handle "sort-name";
  (* Selecting rows; the header knows when some or all of the page are. *)
  click handle "select-Ada";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
    -|            <button id="all" @on_click> all:false some:false </button>
    +|            <button id="all" @on_click> all:false some:true </button>
                </th>
                <th data-slot="table-head">
    -|            <button id="sort-name" @on_click> Name desc </button>
    +|            <button id="sort-name" @on_click> Name - </button>
                </th>
                <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
    +|        <tr data-slot="table-row" data-state="selected">
    +|          <td data-slot="table-cell">
    +|            <button id="select-Ada" @on_click> select </button>
    +|          </td>
    +|          <td data-slot="table-cell"> Ada </td>
    +|          <td data-slot="table-cell"> Mathematician </td>
    +|          <td data-slot="table-cell"> 36 </td>
    +|        </tr>
              <tr data-slot="table-row">
                <td data-slot="table-cell">
                  <button id="select-grace" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> grace </td>
                <td data-slot="table-cell"> Admiral </td>
                <td data-slot="table-cell"> 85 </td>
              </tr>
    -|        <tr data-slot="table-row">
    -|          <td data-slot="table-cell">
    -|            <button id="select-Edsger" @on_click> select </button>
    -|          </td>
    -|          <td data-slot="table-cell"> Edsger </td>
    -|          <td data-slot="table-cell"> Programmer </td>
    -|          <td data-slot="table-cell"> 72 </td>
    -|        </tr>
              <tr data-slot="table-row">
                <td data-slot="table-cell">
                  <button id="select-Alan" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Alan </td>
                <td data-slot="table-cell"> Mathematician </td>
                <td data-slot="table-cell"> 41 </td>
              </tr>
            </tbody>
          </table>
        </div>
    -|  <p> 0 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
    +|  <p> 1 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}];
  click handle "all";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
    -|            <button id="all" @on_click> all:false some:true </button>
    +|            <button id="all" @on_click> all:true some:false </button>
                </th>
                <th data-slot="table-head">
                  <button id="sort-name" @on_click> Name - </button>
                </th>
                <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
              <tr data-slot="table-row" data-state="selected">
                <td data-slot="table-cell">
                  <button id="select-Ada" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Ada </td>
                <td data-slot="table-cell"> Mathematician </td>
                <td data-slot="table-cell"> 36 </td>
              </tr>
    -|        <tr data-slot="table-row">
    +|        <tr data-slot="table-row" data-state="selected">
                <td data-slot="table-cell">
                  <button id="select-grace" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> grace </td>
                <td data-slot="table-cell"> Admiral </td>
                <td data-slot="table-cell"> 85 </td>
              </tr>
    -|        <tr data-slot="table-row">
    +|        <tr data-slot="table-row" data-state="selected">
                <td data-slot="table-cell">
                  <button id="select-Alan" @on_click> select </button>
                </td>
                <td data-slot="table-cell"> Alan </td>
                <td data-slot="table-cell"> Mathematician </td>
                <td data-slot="table-cell"> 41 </td>
              </tr>
            </tbody>
          </table>
        </div>
    -|  <p> 1 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
    +|  <p> 3 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}];
  click handle "next";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
    -|            <button id="all" @on_click> all:true some:false </button>
    +|            <button id="all" @on_click> all:false some:false </button>
                </th>
                <th data-slot="table-head">
                  <button id="sort-name" @on_click> Name - </button>
                </th>
                <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
    -|        <tr data-slot="table-row" data-state="selected">
    +|        <tr data-slot="table-row">
                <td data-slot="table-cell">
    -|            <button id="select-Ada" @on_click> select </button>
    +|            <button id="select-Edsger" @on_click> select </button>
                </td>
    -|          <td data-slot="table-cell"> Ada </td>
    +|          <td data-slot="table-cell"> Edsger </td>
    -|          <td data-slot="table-cell"> Mathematician </td>
    +|          <td data-slot="table-cell"> Programmer </td>
    -|          <td data-slot="table-cell"> 36 </td>
    -|        </tr>
    -|        <tr data-slot="table-row" data-state="selected">
    -|          <td data-slot="table-cell">
    -|            <button id="select-grace" @on_click> select </button>
    -|          </td>
    -|          <td data-slot="table-cell"> grace </td>
    -|          <td data-slot="table-cell"> Admiral </td>
    -|          <td data-slot="table-cell"> 85 </td>
    -|        </tr>
    -|        <tr data-slot="table-row" data-state="selected">
    -|          <td data-slot="table-cell">
    -|            <button id="select-Alan" @on_click> select </button>
    -|          </td>
    -|          <td data-slot="table-cell"> Alan </td>
    -|          <td data-slot="table-cell"> Mathematician </td>
    -|          <td data-slot="table-cell"> 41 </td>
    +|          <td data-slot="table-cell"> 72 </td>
              </tr>
            </tbody>
          </table>
        </div>
    -|  <p> 3 of 4 row(s) selected; page 1 of 2; previous:false next:true </p>
    +|  <p> 3 of 4 row(s) selected; page 2 of 2; previous:true next:false </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}];
  click handle "previous";
  click handle "hide-role";
  Handle.input_text handle ~get_vdom:Fn.id ~selector:"#filter" ~text:"A";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <input id="filter" @on_input/>
        <button id="hide-role" @on_click> role </button>
        <div data-slot="table-container">
          <table data-slot="table">
            <thead data-slot="table-header">
              <tr data-slot="table-row">
                <th data-slot="table-head">
    -|            <button id="all" @on_click> all:false some:false </button>
    +|            <button id="all" @on_click> all:true some:false </button>
                </th>
                <th data-slot="table-head">
                  <button id="sort-name" @on_click> Name - </button>
                </th>
    -|          <th data-slot="table-head"> role </th>
                <th data-slot="table-head"> age </th>
              </tr>
            </thead>
            <tbody data-slot="table-body">
    -|        <tr data-slot="table-row">
    +|        <tr data-slot="table-row" data-state="selected">
                <td data-slot="table-cell">
    -|            <button id="select-Edsger" @on_click> select </button>
    +|            <button id="select-Ada" @on_click> select </button>
                </td>
    -|          <td data-slot="table-cell"> Edsger </td>
    +|          <td data-slot="table-cell"> Ada </td>
    -|          <td data-slot="table-cell"> Programmer </td>
    +|          <td data-slot="table-cell"> 36 </td>
    +|        </tr>
    +|        <tr data-slot="table-row" data-state="selected">
    +|          <td data-slot="table-cell">
    +|            <button id="select-grace" @on_click> select </button>
    +|          </td>
    +|          <td data-slot="table-cell"> grace </td>
    +|          <td data-slot="table-cell"> 85 </td>
    +|        </tr>
    +|        <tr data-slot="table-row" data-state="selected">
    +|          <td data-slot="table-cell">
    +|            <button id="select-Alan" @on_click> select </button>
    +|          </td>
    +|          <td data-slot="table-cell"> Alan </td>
    -|          <td data-slot="table-cell"> 72 </td>
    +|          <td data-slot="table-cell"> 41 </td>
              </tr>
            </tbody>
          </table>
        </div>
    -|  <p> 3 of 4 row(s) selected; page 2 of 2; previous:true next:false </p>
    +|  <p> 3 of 3 row(s) selected; page 1 of 1; previous:false next:false </p>
        <button id="next" @on_click> Next </button>
        <button id="previous" @on_click> Previous </button>
      </div>
    |}]
;;
