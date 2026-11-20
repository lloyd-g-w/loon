open! Import
open Js_of_ocaml

let focusable =
  "a[href], button:not([disabled]), input:not([disabled]), \
   select:not([disabled]), textarea:not([disabled]), \
   [tabindex]:not([tabindex=\"-1\"])"
;;

let in_browser () = Js.Optdef.test (Js.Unsafe.global##.document : _ Js.Optdef.t)

let focus_nth id ~last =
  Effect.of_thunk (fun () ->
    if in_browser ()
    then (
      match
        Js.Opt.to_option (Dom_html.document##getElementById (Js.string id))
      with
      | None -> ()
      | Some root ->
        let all =
          Dom.list_of_nodeList (root##querySelectorAll (Js.string focusable))
        in
        let all = if last then List.rev all else all in
        (match all with
         | el :: _ -> el##focus
         | [] -> root##focus)))
;;

let first_in id = focus_nth id ~last:false
let last_in id = focus_nth id ~last:true

let guard ~id side =
  Node.div
    ~attrs:
      [ Attr.class_ "loon-focus-guard"
      ; Attr.tabindex 0
      ; aria "hidden" "true"
      ; Attr.on_focus (fun _ ->
          match side with
          | `Start -> last_in id
          | `End -> first_in id)
      ]
    []
;;
