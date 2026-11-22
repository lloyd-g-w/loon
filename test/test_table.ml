open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Table.root
       [ Table.caption [ Node.text "Invoices" ]
       ; Table.header [ Table.row [ Table.head [ Node.text "Invoice" ] ] ]
       ; Table.body
           [ Table.row
               ~selected:true
               [ Table.cell ~class_:"font-medium" [ Node.text "INV001" ] ]
           ]
       ; Table.footer
           [ Table.row [ Table.cell ~col_span:3 [ Node.text "Total" ] ] ]
       ]);
  [%expect
    {|
    <div data-slot="table-container" class="cn-table-container">
      <table data-slot="table" class="cn-table">
        <caption data-slot="table-caption" class="cn-table-caption"> Invoices </caption>
        <thead data-slot="table-header" class="cn-table-header">
          <tr data-slot="table-row" class="cn-table-row has-aria-expanded:bg-muted/50">
            <th data-slot="table-head" class="cn-table-head"> Invoice </th>
          </tr>
        </thead>
        <tbody data-slot="table-body" class="cn-table-body">
          <tr data-slot="table-row"
              data-state="selected"
              class="cn-table-row has-aria-expanded:bg-muted/50">
            <td data-slot="table-cell" class="cn-table-cell font-medium"> INV001 </td>
          </tr>
        </tbody>
        <tfoot data-slot="table-footer" class="cn-table-footer">
          <tr data-slot="table-row" class="cn-table-row has-aria-expanded:bg-muted/50">
            <td data-slot="table-cell" colspan="3" class="cn-table-cell"> Total </td>
          </tr>
        </tfoot>
      </table>
    </div>
    |}]
;;
