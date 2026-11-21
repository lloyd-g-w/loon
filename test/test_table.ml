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
    <div data-slot="table-container" class="overflow-x-auto relative w-full">
      <table data-slot="table" class="caption-bottom text-sm w-full">
        <caption data-slot="table-caption" class="mt-4 text-muted-foreground text-sm"> Invoices </caption>
        <thead data-slot="table-header" class="[&_tr]:border-b">
          <tr data-slot="table-row"
              class="border-b data-[state=selected]:bg-muted has-aria-expanded:bg-muted/50 hover:bg-muted/50 transition-colors">
            <th data-slot="table-head"
                class="[&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px] align-middle font-medium h-10 px-2 text-foreground text-left whitespace-nowrap"> Invoice </th>
          </tr>
        </thead>
        <tbody data-slot="table-body" class="[&_tr:last-child]:border-0">
          <tr data-slot="table-row"
              data-state="selected"
              class="border-b data-[state=selected]:bg-muted has-aria-expanded:bg-muted/50 hover:bg-muted/50 transition-colors">
            <td data-slot="table-cell"
                class="[&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px] align-middle font-medium p-2 whitespace-nowrap"> INV001 </td>
          </tr>
        </tbody>
        <tfoot data-slot="table-footer"
               class="[&>tr]:last:border-b-0 bg-muted/50 border-t font-medium">
          <tr data-slot="table-row"
              class="border-b data-[state=selected]:bg-muted has-aria-expanded:bg-muted/50 hover:bg-muted/50 transition-colors">
            <td data-slot="table-cell"
                colspan="3"
                class="[&:has([role=checkbox])]:pr-0 [&>[role=checkbox]]:translate-y-[2px] align-middle p-2 whitespace-nowrap"> Total </td>
          </tr>
        </tfoot>
      </table>
    </div>
    |}]
;;
