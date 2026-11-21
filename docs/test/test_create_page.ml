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
  [%expect {|
    query: preset=bIkeymG&item=preview-02
    Menu
    Base Radix UI
    Style Vega
    Base Color Neutral
    Theme Neutral
    Chart Color Neutral
    Heading Inter Aa
    Font Inter Aa
    Icon Library Lucide
    Radius Default
    Menu Default
    Menu Accent Subtle
    --primary: -
    --radius: -
    |}]
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
  [%expect {|
    query: preset=bJfDPe2y&item=preview-02
    query: preset=bJfEY2ZE&item=preview-02
    query: preset=bJfEY2dM&item=preview-02
    --background: -
    --primary: -
    --radius: -
    |}]
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
  [%expect {|
    query: preset=bIouxjE&item=preview-02
    ("default prevented" (key KeyZ))
    query: preset=bIm4yQa&item=preview-02
    ("default prevented" (key KeyZ))
    query: preset=bIkeymG&item=preview-02
    ("default prevented" (key KeyZ))
    query: preset=bIm4yQa&item=preview-02
    |}]
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
  [%expect {|
    blue
    blue
    blue
    blue
    blue
    |}]
;;

let%expect_test "reset asks first" =
  let h, q, _ = page ~query:"preset=b4DxGlzePJ" () in
  key h ~shift:true KeyR;
  texts h "[role=alertdialog] h2";
  click h "[data-action=confirm-reset]";
  query q;
  [%expect {|
    ("default prevented" (key KeyR))
    Reset to defaults?
    query: preset=bIkeymG&item=preview-02
    |}]
;;

let%expect_test "open preset" =
  let h, q, _ = page () in
  key h KeyO;
  Handle.input_text h ~get_vdom:Fn.id ~selector:"#preset-code" ~text:"--preset b4DxGlzePJ";
  Handle.submit_form h ~get_vdom:Fn.id ~selector:"form";
  Handle.recompute_view h;
  query q;
  texts h "[data-picker=theme]";
  [%expect {|
    ("default prevented" (key KeyO))
    query: preset=bIkeymG&item=preview-02
    Theme Neutral
    |}]
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
  [%expect {|
    --preset b4DxGlzePJ
    Copied
    loon init -dir lib/ui
    :root {
      --background: oklch(1 0 0);
      --foreground: oklch(0.141 0.005 285.823);
      --card: oklch(1 0 0);
      --card-foreground: oklch(0.141 0.005 285.823);
      --popover: oklch(1 0 0);
      --popover-foreground: oklch(0.141 0.005 285.823);
      --primary: oklch(0.488 0.243 264.376);
      --primary-foreground: oklch(0.97 0.014 254.604);
      --secondary: oklch(0.967 0.001 286.375);
      --secondary-foreground: oklch(0.21 0.006 285.885);
      --muted: oklch(0.967 0.001 286.375);
      --muted-foreground: oklch(0.552 0.016 285.938);
      --accent: oklch(0.488 0.243 264.376);
      --accent-foreground: oklch(0.97 0.014 254.604);
      --destructive: oklch(0.577 0.245 27.325);
      --border: oklch(0.92 0.004 286.32);
      --input: oklch(0.92 0.004 286.32);
      --ring: oklch(0.705 0.015 286.067);
      --chart-1: oklch(0.845 0.143 164.978);
      --chart-2: oklch(0.696 0.17 162.48);
      --chart-3: oklch(0.596 0.145 163.225);
      --chart-4: oklch(0.508 0.118 165.612);
      --chart-5: oklch(0.432 0.095 166.913);
      --radius: 0.875rem;
      --sidebar: oklch(0.985 0 0);
      --sidebar-foreground: oklch(0.141 0.005 285.823);
      --sidebar-primary: oklch(0.546 0.245 262.881);
      --sidebar-primary-foreground: oklch(0.97 0.014 254.604);
      --sidebar-accent: oklch(0.967 0.001 286.375);
      --sidebar-accent-foreground: oklch(0.21 0.006 285.885);
      --sidebar-border: oklch(0.92 0.004 286.32);
      --sidebar-ring: oklch(0.705 0.015 286.067);
    }

    .dark {
      --background: oklch(0.141 0.005 285.823);
      --foreground: oklch(0.985 0 0);
      --card: oklch(0.21 0.006 285.885);
      --card-foreground: oklch(0.985 0 0);
      --popover: oklch(0.21 0.006 285.885);
      --popover-foreground: oklch(0.985 0 0);
      --primary: oklch(0.424 0.199 265.638);
      --primary-foreground: oklch(0.97 0.014 254.604);
      --secondary: oklch(0.274 0.006 286.033);
      --secondary-foreground: oklch(0.985 0 0);
      --muted: oklch(0.274 0.006 286.033);
      --muted-foreground: oklch(0.705 0.015 286.067);
      --accent: oklch(0.424 0.199 265.638);
      --accent-foreground: oklch(0.97 0.014 254.604);
      --destructive: oklch(0.704 0.191 22.216);
      --border: oklch(1 0 0 / 10%);
      --input: oklch(1 0 0 / 15%);
      --ring: oklch(0.552 0.016 285.938);
      --chart-1: oklch(0.845 0.143 164.978);
      --chart-2: oklch(0.696 0.17 162.48);
      --chart-3: oklch(0.596 0.145 163.225);
      --chart-4: oklch(0.508 0.118 165.612);
      --chart-5: oklch(0.432 0.095 166.913);
      --sidebar: oklch(0.21 0.006 285.885);
      --sidebar-foreground: oklch(0.985 0 0);
      --sidebar-primary: oklch(0.623 0.214 259.815);
      --sidebar-primary-foreground: oklch(0.97 0.014 254.604);
      --sidebar-accent: oklch(0.274 0.006 286.033);
      --sidebar-accent-foreground: oklch(0.985 0 0);
      --sidebar-border: oklch(1 0 0 / 10%);
      --sidebar-ring: oklch(0.552 0.016 285.938);
    }

    @theme inline {
      --font-sans: 'Geist Variable', sans-serif;
      --font-heading: 'Lora Variable', serif;
    }
    |}]
;;

let%expect_test "D toggles the site's mode" =
  let h, _, mode = page () in
  key h KeyD;
  print_s [%sexp (Bonsai.Expert.Var.get mode : Loon.Theme.Mode.t)];
  [%expect {|
    ("default prevented" (key KeyD))
    Dark
    |}]
;;
