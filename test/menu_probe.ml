open! Core
open Js_of_ocaml
module Handle = Bonsai_web_test.Handle
module N = Virtual_dom_test_helpers.Node_helpers

let attr (node : N.t) name =
  match node with
  | Element e -> List.Assoc.find e.attributes name ~equal:String.equal
  | Text _ | Widget -> None
;;

let text node = String.strip (N.inner_text node)

let describe node =
  let flags =
    List.filter_map
      [ "data-state", "state"; "aria-checked", "checked"; "data-disabled", "disabled" ]
      ~f:(fun (a, label) ->
        Option.map (attr node a) ~f:(fun v ->
          if String.is_empty v then label else sprintf "%s=%s" label v))
  in
  String.concat ~sep:" " (text node :: flags)
;;

let print ?triggers h =
  let root = N.unsafe_convert_exn (Handle.last_result h) in
  Option.iter triggers ~f:(fun selector ->
    List.iter (N.select root ~selector) ~f:(fun t ->
      printf "trigger %s\n" (describe t)));
  match N.select root ~selector:"[role=menu]" with
  | [] -> print_endline "closed"
  | menus ->
    List.iter menus ~f:(fun menu ->
      printf "%s\n" (Option.value (attr menu "data-slot") ~default:"?");
      (* the items of this level: those whose closest menu is this one *)
      let rec items (node : N.t) =
        match node with
        | Text _ | Widget -> []
        | Element e ->
          List.concat_map e.children ~f:(fun (child : N.t) ->
            match attr child "role" with
            | Some "menu" -> []
            | Some ("menuitem" | "menuitemcheckbox" | "menuitemradio") -> [ child ]
            | _ -> items child)
      in
      List.iter (items menu) ~f:(fun item ->
        let mark = if Option.is_some (attr item "data-highlighted") then ">" else " " in
        printf "  %s %s\n" mark (describe item)))
;;

let right_click h selector ~client_x ~client_y =
  let root = N.unsafe_convert_exn (Handle.last_result h) in
  N.trigger
    ~extra_fields:
      [ "clientX", Js.Unsafe.inject (Js.float client_x)
      ; "clientY", Js.Unsafe.inject (Js.float client_y)
      ; ( "preventDefault"
        , Js.Unsafe.inject
            (Js.wrap_callback (fun () -> print_endline "(default prevented)")) )
      ]
    (N.select_first_exn root ~selector)
    ~event_name:"oncontextmenu";
  Handle.recompute_view h
;;

let hover h selector =
  Handle.mousemove h ~get_vdom:Fn.id ~selector;
  Handle.recompute_view h
;;
