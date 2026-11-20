open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "table"

module Invoice = struct
  type t =
    { id : string
    ; status : string
    ; method_ : string
    ; amount : float
    }

  let all =
    [ { id = "INV001"; status = "Paid"; method_ = "Credit card"; amount = 250. }
    ; { id = "INV002"; status = "Pending"; method_ = "PayPal"; amount = 150. }
    ; { id = "INV003"; status = "Unpaid"; method_ = "Bank transfer"; amount = 350. }
    ; { id = "INV004"; status = "Paid"; method_ = "Credit card"; amount = 450. }
    ; { id = "INV005"; status = "Paid"; method_ = "PayPal"; amount = 550. }
    ]
  ;;

  let status_badge t =
    let variant : Badge.Variant.t =
      match t.status with
      | "Paid" -> Success
      | "Pending" -> Warning
      | _ -> Neutral
    in
    Badge.view ~dot:true ~variant [ Node.text t.status ]
  ;;
end

(*$ Invoices *)
let invoices =
  let total = List.sum (module Float) Invoice.all ~f:(fun i -> i.amount) in
  Table.view
    ~caption:"Your recent invoices."
    ~columns:
      Table.Column.
        [ text "Invoice" (fun (i : Invoice.t) -> i.id)
        ; create "Status" Invoice.status_badge
        ; text "Method" (fun (i : Invoice.t) -> i.method_)
        ; text ~align:Right "Amount" (fun (i : Invoice.t) -> sprintf "$%.2f" i.amount)
        ]
    ~footer:
      [ Table.cell ~colspan:3 [ Node.text "Total" ]
      ; Table.cell ~align:Right [ Node.textf "$%.2f" total ]
      ]
    Invoice.all
(*$*)

(*$ Striped and dense, from the parts *)
let parts =
  Table.table
    ~striped:true
    ~dense:true
    [ Table.header
        [ Table.row
            [ Table.head [ Node.text "Key" ]
            ; Table.head [ Node.text "Action" ]
            ]
        ]
    ; Table.body
        (List.map
           [ [ "Cmd"; "K" ], "Open the command palette"
           ; [ "Cmd"; "Shift"; "P" ], "Run a command"
           ; [ "Esc" ], "Close a dialog"
           ; [ "?" ], "Show every shortcut"
           ]
           ~f:(fun (keys, action) ->
             Table.row [ Table.cell [ Kbd.combo keys ]; Table.cell [ Node.text action ] ]))
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Table"
    ~group:Display
    ~description:"Rows and columns of data, styled."
    ~usage:
      {|Table.view ~columns:Table.Column.[ text "Name" name; text ~align:Right "Age" age ] people|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "columns", "'row Table.Column.t list", "A header and how to show each row's cell."
          ; "caption", "string", "Under the table."
          ; "footer", "Vdom.Node.t list", "Cells of a footer row."
          ; "striped", "bool", "Shade every other row."
          ; "hover", "bool", "Highlight the row under the pointer (default true)."
          ; "dense", "bool", "Less padding."
          ]
      ; Doc.p
          "Table.table, header, body, footer, row, head and cell build tables of any shape. Wide tables scroll sideways in their own box. For sorting, filtering and selecting, see Data table."
      ]
    [ Doc.static ~page "Invoices" invoices
    ; Doc.static ~page "Striped and dense, from the parts" parts
    ]
;;
