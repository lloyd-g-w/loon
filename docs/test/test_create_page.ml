open! Core
open Bonsai_web
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

(* The page, its query and mode in variables, as the docs app keeps them
   in the hash and the site's theme. *)
let page ?(query = "") () =
  let query = Bonsai.Expert.Var.create query in
  let mode = Bonsai.Expert.Var.create Loon.Theme.Mode.Light in
  let set var =
    Bonsai.return (fun v -> Effect.of_thunk (fun () -> Bonsai.Expert.Var.set var v))
  in
  let handle =
    Handle.create
      (Bonsai_web_test.Result_spec.vdom
         ~filter_printed_attributes:(fun ~key ~data:_ -> not (String.equal key "class"))
         Fn.id)
      (fun graph ->
        Loon_docs.Create_page.component
          ~mode:(Bonsai.Expert.Var.value mode)
          ~set_mode:(set mode)
          ~query:(Bonsai.Expert.Var.value query)
          ~set_query:(set query)
          graph)
  in
  Handle.recompute_view handle;
  handle, query, mode
;;

let view h =
  Handle.recompute_view h;
  Node_helpers.unsafe_convert_exn (Handle.last_result h)
;;

let click h selector =
  Handle.click_on h ~get_vdom:Fn.id ~selector;
  Handle.recompute_view h
;;

(* A key pressed anywhere: the page's global listener. *)
let key h ?(shift = false) ?(ctrl = false) (k : Js_of_ocaml.Dom_html.Keyboard_code.t) =
  Node_helpers.select_first_exn (view h) ~selector:"[data-tool=create]"
  |> Node_helpers.User_actions.global_keydown ~shift_key_down:shift ~ctrl_key_down:ctrl ~key:k;
  Handle.recompute_view h
;;

let query q = print_endline ("query: " ^ Bonsai.Expert.Var.get q)

(* Each match's text (without the inline SVG logos). *)
let texts h selector =
  List.iter (Node_helpers.select (view h) ~selector) ~f:(fun n ->
    let t = Node_helpers.inner_text n in
    let t =
      match String.substr_index t ~pattern:"<svg" with
      | Some i -> String.prefix t i
      | None -> t
    in
    print_endline (String.strip t))
;;

(* The preview root's variables named [names]. *)
let vars h names =
  match Node_helpers.select_first_exn (view h) ~selector:"[data-create-preview]" with
  | Element { attributes; _ } ->
    let vars =
      List.Assoc.find attributes "custom-css-vars" ~equal:String.equal
      |> Option.value ~default:"()"
      |> Sexp.of_string
      |> [%of_sexp: (string * string) list]
    in
    List.iter names ~f:(fun n ->
      printf "%s: %s\n" n (List.Assoc.find vars n ~equal:String.equal |> Option.value ~default:"-"))
  | _ -> print_endline "?"
;;

(* Opens the picker, chooses, and closes it (on desktop a choice leaves it
   open, as shadcn's). *)
let choose h picker value =
  let trigger = sprintf "[data-picker=%s]" picker in
  click h trigger;
  click h (sprintf "[data-value=%s]" value);
  click h trigger
;;

let%expect_test "first load writes the preset; the pickers show it" =
  let h, q, _ = page () in
  query q;
  texts h "[data-picker]";
  vars h [ "--primary"; "--radius" ];
  [%expect {| |}]
;;

let%expect_test "base colour, theme and radius update the query and the preview" =
  let h, q, _ = page () in
  choose h "baseColor" "stone";
  query q;
  choose h "theme" "blue";
  query q;
  choose h "radius" "large";
  query q;
  vars h [ "--background"; "--primary"; "--radius" ];
  [%expect {| |}]
;;

let%expect_test "undo and redo" =
  let h, q, _ = page () in
  choose h "theme" "blue";
  choose h "theme" "red";
  query q;
  key h ~ctrl:true KeyZ;
  query q;
  key h ~ctrl:true KeyZ;
  query q;
  key h ~ctrl:true ~shift:true KeyZ;
  query q;
  [%expect {| |}]
;;

let%expect_test "a lock keeps its field through Shuffle" =
  let h, q, _ = page () in
  choose h "theme" "blue";
  click h "[data-lock=theme]";
  List.iter (List.range 0 5) ~f:(fun _ ->
    click h "[data-action=shuffle]";
    let p =
      Loon_docs.Create_params.of_query (Bonsai.Expert.Var.get q)
    in
    print_endline p.preset.theme);
  [%expect {| |}]
;;

let%expect_test "reset asks first" =
  let h, q, _ = page ~query:"preset=b4DxGlzePJ" () in
  key h ~shift:true KeyR;
  texts h "[role=alertdialog] h2";
  click h "[data-action=confirm-reset]";
  query q;
  [%expect {| |}]
;;

let%expect_test "open preset" =
  let h, q, _ = page () in
  key h KeyO;
  Handle.input_text h ~get_vdom:Fn.id ~selector:"#preset-code" ~text:"--preset b4DxGlzePJ";
  Handle.submit_form h ~get_vdom:Fn.id ~selector:"form";
  Handle.recompute_view h;
  query q;
  texts h "[data-picker=theme]";
  [%expect {| |}]
;;

let%expect_test "copy preset and get code" =
  let h, _, _ = page ~query:"preset=b4DxGlzePJ" () in
  texts h "[data-action=copy-preset]";
  click h "[data-action=copy-preset]";
  texts h "[data-action=copy-preset]";
  click h "[data-action=get-code]";
  texts h "[data-slot=dialog-content] pre";
  click h "[data-tab=Theme]";
  texts h "[data-slot=dialog-content] pre";
  [%expect {| |}]
;;

let%expect_test "D toggles the site's mode" =
  let h, _, mode = page () in
  key h KeyD;
  print_s [%sexp (Bonsai.Expert.Var.get mode : Loon.Theme.Mode.t)];
  [%expect {| |}]
;;
