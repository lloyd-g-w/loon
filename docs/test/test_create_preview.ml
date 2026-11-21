open! Core
open Bonsai_web
module Handle = Bonsai_web_test.Handle
module N = Virtual_dom_test_helpers.Node_helpers
module Create_preview = Loon_docs.Create_preview

let handle ?info item =
  Handle.create
    (Bonsai_web_test.Result_spec.vdom Fn.id)
    (Create_preview.component ?info (Bonsai.return item))
;;

let root h = N.unsafe_convert_exn (Handle.last_result h)
let count h selector = List.length (N.select (root h) ~selector)
let texts h selector = List.map (N.select (root h) ~selector) ~f:N.inner_text

let attr h selector name =
  match N.select_first_exn (root h) ~selector with
  | Element e -> List.Assoc.find e.attributes name ~equal:String.equal
  | Text _ | Widget -> None
;;

let summary h =
  print_s
    [%message
      ""
        ~columns:(count h "[data-slot=capture-target] > div" : int)
        ~cards:(count h "[data-slot=card]" : int)
        ~charts:(count h "[data-slot=chart]" : int)
        ~titles:(texts h "[data-slot=card-title]" : string list)]
;;

let%expect_test "items" =
  print_s [%sexp (Create_preview.items : (string * string) list)];
  [%expect {| ((preview-02 01) (preview 02)) |}]
;;

let%expect_test "preview-02" =
  let h = handle "preview-02" in
  summary h;
  [%expect {|
    ((columns 6) (cards 37) (charts 9)
     (titles
      ("Contribution History" "Scan to connect your mobile device"
       "Q2 Dividend Income" "Dollar-Cost Averaging" "Payout Threshold" $0.00
       Preferences "Kitchen Island" "Savings Targets" "Buy Investment"
       "Recent Transactions" "Front Door" "Account Access" US$12.94 "1 Apr"
       "Transfer Funds" "Receiving Method" "Power Usage" "Upcoming Payments"
       "Living Room" "Stock Performance" "Set a new milestone" "Social Links"
       Notifications)))
    |}]
;;

let%expect_test "preview, named by its info" =
  let h =
    handle
      ~info:
        (Bonsai.return
           { Create_preview.Info.style = "Vega"; font = "Inter"; font_heading = "Lora" })
      "preview"
  in
  summary h;
  print_s
    [%sexp (texts h "[data-slot=card-content] > div > div.cn-font-heading" : string list)];
  [%expect {|
    ((columns 7) (cards 32) (charts 5)
     (titles
      ("Invoice #INV-2847" "Observability Plus is replacing Monitoring"
       "Shipping Address" "Environment Variables" "Traffic channels"
       "Invite Team" "Ship faster & safer with Vercel Agent" "Browser Share"
       "Report Bug" "Contributors 312" "Book Appointment" "Sleep Report" Profile
       "Weekly Fitness Summary" "File Upload" Analytics
       "5 days remaining in cycle" "Live Audio Waveform" Visitors
       "Contributions & Activity")))
    ("Vega - Lora")
    |}]
;;

let%expect_test "an unknown item is the first" =
  let h = handle "nope" in
  print_s
    [%sexp
      (count h "[data-slot=card]" = count (handle "preview-02") "[data-slot=card]" : bool)];
  [%expect {| true |}]
;;

let%expect_test "stateful cards" =
  let h = handle "preview" in
  (* the codespaces card's tabs *)
  let local = "[data-slot=tabs-trigger][aria-controls$=content-local]" in
  print_s [%sexp (attr h local "aria-selected" : string option)];
  Handle.click_on h ~get_vdom:Fn.id ~selector:local;
  Handle.recompute_view h;
  print_s [%sexp (attr h local "aria-selected" : string option)];
  (* the typography card's feedback dialog *)
  print_s [%sexp (count h "[role=dialog]" : int)];
  Handle.click_on h ~get_vdom:Fn.id ~selector:"[data-slot=dialog-trigger]";
  Handle.recompute_view h;
  print_s [%sexp (texts h "[role=dialog] [data-slot=dialog-title]" : string list)];
  [%expect {|
    (false)
    (true)
    0
    ("Share Feedback")
    |}]
;;
