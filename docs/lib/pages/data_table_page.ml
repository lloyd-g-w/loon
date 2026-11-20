open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "data_table"

module Payment = struct
  type t =
    { id : string
    ; email : string
    ; status : string
    ; amount : float
    }

  let all =
    [ { id = "m5gr84i9"; email = "ken99@example.com"; status = "Success"; amount = 316. }
    ; { id = "3u1reuv4"; email = "abe45@example.com"; status = "Success"; amount = 242. }
    ; { id = "derv1ws0"; email = "monserrat44@example.com"; status = "Processing"; amount = 837. }
    ; { id = "5kma53ae"; email = "silas22@example.com"; status = "Success"; amount = 874. }
    ; { id = "bhqecj4p"; email = "carmella@example.com"; status = "Failed"; amount = 721. }
    ; { id = "p0r8sd2k"; email = "ada@example.com"; status = "Success"; amount = 120.5 }
    ; { id = "x9q2lm7c"; email = "grace@example.com"; status = "Processing"; amount = 64. }
    ; { id = "t7hz1n3b"; email = "alan@example.com"; status = "Failed"; amount = 990. }
    ]
  ;;

  let badge t =
    let variant : Badge.Variant.t =
      match t.status with
      | "Success" -> Success
      | "Processing" -> Accent
      | _ -> Danger
    in
    Badge.view ~variant [ Node.text t.status ]
  ;;
end

(*$ Payments
   Press a header to sort by it; type to filter; tick rows to select them.
   Status is a secondary column, hidden when the table is narrow. *)
let payments (local_ graph) =
  let table =
    Data_table.component
      ~selectable:true
      ~page_size:5
      ~filter_placeholder:"Filter emails…"
      ~columns:
        (Bonsai.return
           Data_table.Column.
             [ create
                 ~secondary:true
                 ~sort:(fun (a : Payment.t) b -> String.compare a.status b.status)
                 ~id:"status"
                 "Status"
                 Payment.badge
             ; text ~id:"email" "Email" (fun (p : Payment.t) -> p.email)
             ; create
                 ~align:Right
                 ~sort:(fun (a : Payment.t) b -> Float.compare a.amount b.amount)
                 ~id:"amount"
                 "Amount"
                 (fun p -> Node.textf "$%.2f" p.amount)
             ])
      ~key:(fun (p : Payment.t) -> p.id)
      (Bonsai.return Payment.all)
      graph
  in
  let%arr { Data_table.view; selected } = table in
  Node.div
    ~attrs:[ Attr.class_ "docs-stack"; Attr.create "style" "width: 100%" ]
    [ view
    ; (if Set.is_empty selected
       then Node.none
       else
         Alert.view
           ~variant:Info
           [ Node.textf "Selected: %s" (String.concat ~sep:", " (Set.to_list selected)) ])
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Data table"
    ~group:Display
    ~description:"A table the user can sort, filter, page through and select from."
    ~usage:
      {|Data_table.component ~selectable:true ~columns ~key:(fun p -> p.id) payments graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "columns", "'row Data_table.Column.t list Bonsai.t", "Each with an optional sort (a comparison) and search (the text the filter matches); secondary ones are hidden when the table is narrower than 28rem."
          ; "key", "'row -> string", "Names a row, for selection."
          ; "selectable", "bool", "A checkbox column, and one to select every visible row."
          ; "page_size", "int", "Paginate."
          ; "empty", "Vdom.Node.t", "Shown when nothing matches."
          ; "toolbar", "Vdom.Node.t list", "Extra controls beside the filter."
          ]
      ; Doc.p
          "The component returns its view and the keys of the selected rows. Data_table.visible_rows is the filtering and sorting on its own."
      ]
    [ Doc.example ~page "Payments" payments ]
;;
