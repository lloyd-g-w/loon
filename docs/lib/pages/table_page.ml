open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node

let page = "table"

(*$ Demo *)
let invoices =
  [ "INV001", "Paid", "$250.00", "Credit Card"
  ; "INV002", "Pending", "$150.00", "PayPal"
  ; "INV003", "Unpaid", "$350.00", "Bank Transfer"
  ; "INV004", "Paid", "$450.00", "Credit Card"
  ; "INV005", "Paid", "$550.00", "PayPal"
  ; "INV006", "Pending", "$200.00", "Bank Transfer"
  ; "INV007", "Unpaid", "$300.00", "Credit Card"
  ]
;;

let demo =
  Table.root
    [ Table.caption [ Node.text "A list of your recent invoices." ]
    ; Table.header
        [ Table.row
            [ Table.head ~class_:"w-[100px]" [ Node.text "Invoice" ]
            ; Table.head [ Node.text "Status" ]
            ; Table.head [ Node.text "Method" ]
            ; Table.head ~class_:"text-right" [ Node.text "Amount" ]
            ]
        ]
    ; Table.body
        (List.map invoices ~f:(fun (invoice, status, amount, method_) ->
           Table.row
             [ Table.cell ~class_:"font-medium" [ Node.text invoice ]
             ; Table.cell [ Node.text status ]
             ; Table.cell [ Node.text method_ ]
             ; Table.cell ~class_:"text-right" [ Node.text amount ]
             ]))
    ; Table.footer
        [ Table.row
            [ Table.cell ~col_span:3 [ Node.text "Total" ]
            ; Table.cell ~class_:"text-right" [ Node.text "$2,500.00" ]
            ]
        ]
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Table"
    ~description:"A responsive table component."
    ~usage:
      {|Table.root
  [ Table.caption [ Node.text "A list of your recent invoices." ]
  ; Table.header
      [ Table.row
          [ Table.head ~class_:"w-[100px]" [ Node.text "Invoice" ]
          ; Table.head [ Node.text "Status" ]
          ; Table.head [ Node.text "Method" ]
          ; Table.head ~class_:"text-right" [ Node.text "Amount" ]
          ]
      ]
  ; Table.body
      [ Table.row
          [ Table.cell ~class_:"font-medium" [ Node.text "INV001" ]
          ; Table.cell [ Node.text "Paid" ]
          ; Table.cell [ Node.text "Credit Card" ]
          ; Table.cell ~class_:"text-right" [ Node.text "$250.00" ]
          ]
      ]
  ]|}
    ~body:
      [ Doc.h2 "Parts"
      ; Doc.table
          [ "Part"; "Renders" ]
          (List.map
             [ ( "Table.root"
               , "<table> in a <div> that scrolls sideways when it is too wide"
               )
             ; "Table.header, body, footer", "<thead>, <tbody>, <tfoot>"
             ; "Table.row", "<tr>; ~selected:true sets data-state=\"selected\""
             ; ( "Table.head, cell"
               , "<th>, <td>; Table.cell ~col_span spans columns" )
             ; "Table.caption", "<caption>, below the table"
             ]
             ~f:(fun (part, renders) -> [ Doc.code part; Doc.text renders ]))
      ; Doc.p
          "For sorting, filtering, selection and pagination, see [Data_table]."
      ]
    [ Doc.static ~page "Demo" demo ]
;;
