open! Core
open Bonsai_web
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

(* The page, its query and mode in variables, as the docs app keeps them
   in the hash and the site's theme. *)
let page ?(query = "") () =
  let query = Bonsai.Expert.Var.create query in
  let mode = Bonsai.Expert.Var.create Loon.Theme.Mode.Light in
  let set var = Bonsai.return (fun v -> Effect.of_thunk (fun () -> Bonsai.Expert.Var.set var v)) in
  let handle =
    Handle.create
      (Bonsai_web_test.Result_spec.vdom
         ~filter_printed_attributes:(fun ~key ~data:_ -> not (String.equal key "class"))
         Fn.id)
      (fun graph ->
        Loon_docs.Typeset_page.component
          ~mode:(Bonsai.Expert.Var.value mode)
          ~set_mode:(set mode)
          ~query:(Bonsai.Expert.Var.value query)
          ~set_query:(set query)
          graph)
  in
  handle, query, mode
;;

let click h selector =
  Handle.click_on h ~get_vdom:Fn.id ~selector;
  Handle.recompute_view h
;;

let print_query query =
  let q = Bonsai.Expert.Var.get query in
  print_endline ("query: " ^ if String.is_empty q then "(empty)" else q)
;;

(* The elements [selector] matches in the current view, without classes. *)
let show h selector =
  Handle.recompute_view h;
  let node = Node_helpers.unsafe_convert_exn (Handle.last_result h) in
  List.iter (Node_helpers.select node ~selector) ~f:(fun n ->
    print_endline
      (Node_helpers.to_string_html
         ~filter_printed_attributes:(fun ~key ~data:_ ->
           not (List.mem [ "class"; "d" ] key ~equal:String.equal))
         n))
;;

let preview_style h =
  Handle.recompute_view h;
  let node = Node_helpers.unsafe_convert_exn (Handle.last_result h) in
  match Node_helpers.select_first_exn node ~selector:"[data-slot=typeset-preview]" with
  | Element { attributes; _ } ->
    List.Assoc.find attributes "style" ~equal:String.equal
    |> Option.value ~default:""
    |> String.split ~on:';'
    |> List.filter ~f:(fun s -> String.is_substring s ~substring:"--preview-font-heading"
                                || String.is_substring s ~substring:"--preview-size")
    |> String.concat ~sep:";"
    |> print_endline
  | _ -> print_endline "?"
;;

(* Each match's text. *)
let texts h selector =
  Handle.recompute_view h;
  let node = Node_helpers.unsafe_convert_exn (Handle.last_result h) in
  List.iter (Node_helpers.select node ~selector) ~f:(fun n ->
    print_endline (Node_helpers.inner_text n))
;;

let trigger param = sprintf "[data-param=%s] button[aria-haspopup=menu]" param

let%expect_test "the customiser's pickers, closed" =
  let h, _, _ = page () in
  texts h "[data-param]";
  show h "[data-param=heading]";
  [%expect {|
    Measure 80ch
    Heading Geist Aa
    Body Geist Aa
    Mono Geist Mono Aa
    Size 15px
    Leading Regular (1.75)
    Flow Regular (1.25em)
    <div data-param="heading">
      <button type="button"
              data-slot="dropdown-menu-trigger"
              id="picker-bonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              @on_click
              @on_keydown>
        <div>
          <div> Heading </div>
          <div> Geist </div>
        </div>
        <div style="font-family: var(--font-geist-sans), 'Geist Variable', sans-serif"> Aa </div>
      </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <button type="button" title="Lock" aria-label="Lock" data-locked="false" @on_click>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true">
          <rect width="18" height="11" x="3" y="11" rx="2" ry="2"> </rect>
          <path> </path>
        </svg>
      </button>
    </div>
    |}]
;;

let%expect_test "picking a font: the query and the preview" =
  let h, query, _ = page () in
  click h (trigger "heading");
  texts h "[role=menu] [data-slot=dropdown-menu-label]";
  show h "[role=menu] [data-value=inherit]";
  show h "[role=menu] [data-value=roboto-slab]";
  (* Hovering previews without committing. *)
  Handle.mousemove h ~get_vdom:Fn.id ~selector:"[role=menuitemradio][data-value=lora]";
  preview_style h;
  print_query query;
  click h "[role=menuitemradio][data-value=lora]";
  print_query query;
  preview_style h;
  show h (trigger "heading");
  [%expect {|
    Sans
    Serif
    Mono
    <div data-slot="dropdown-menu-radio-item"
         role="menuitemradio"
         aria-checked="true"
         data-state="checked"
         tabindex="-1"
         data-orientation="vertical"
         data-radix-collection-item=""
         data-value="inherit"
         loon-focus-when=false
         @on_click
         @on_focus
         @on_mouseleave
         @on_mousemove>
      <span>
        <span data-state="checked">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true">
            <path> </path>
          </svg>
        </span>
      </span>
      Geist
    </div>
    <div data-slot="dropdown-menu-radio-item"
         role="menuitemradio"
         aria-checked="false"
         data-state="unchecked"
         tabindex="-1"
         data-orientation="vertical"
         data-radix-collection-item=""
         aria-disabled="true"
         data-disabled=""
         data-value="roboto-slab"
         loon-focus-when=false
         @on_focus
         @on_mouseleave
         @on_mousemove>
      <span> </span>
      <span> Roboto Slab </span>
      <span> Not bundled </span>
    </div>
    --preview-size: 15px;--preview-font-heading: var(--font-lora), 'Lora Variable', serif
    query: (empty)
    query: heading=lora
    --preview-size: 15px;--preview-font-heading: var(--font-lora), 'Lora Variable', serif
    <button type="button"
            data-slot="dropdown-menu-trigger"
            id="picker-bonsai_path_replaced_in_test-trigger"
            aria-haspopup="menu"
            aria-expanded="true"
            aria-controls="picker-bonsai_path_replaced_in_test-content"
            data-popup-open=""
            @on_click
            @on_keydown>
      <div>
        <div> Heading </div>
        <div> Lora </div>
      </div>
      <div style="font-family: var(--font-lora), 'Lora Variable', serif"> Aa </div>
    </button>
    |}]
;;

let%expect_test "an option, the item, undo and redo" =
  let h, query, _ = page () in
  click h (trigger "scale");
  click h "[role=menuitemradio][data-value='18']";
  print_query query;
  preview_style h;
  click h "[data-item=chat]";
  print_query query;
  click h "[data-slot=card-header] button[aria-haspopup=menu]";
  click h "[data-action=undo]";
  print_query query;
  click h "[data-slot=card-header] button[aria-haspopup=menu]";
  click h "[data-action=undo]";
  print_query query;
  click h "[data-slot=card-header] button[aria-haspopup=menu]";
  show h "[data-action=undo]";
  show h "[data-action=redo]";
  click h "[data-action=redo]";
  print_query query;
  [%expect {|
    query: scale=18
    --preview-size: 18px;--preview-font-heading: var(--font-geist-sans), 'Geist Variable', sans-serif
    query: scale=18&item=chat
    query: scale=18
    query: (empty)
    <div data-slot="dropdown-menu-item"
         data-variant="default"
         role="menuitem"
         tabindex="-1"
         data-orientation="vertical"
         data-radix-collection-item=""
         aria-disabled="true"
         data-disabled=""
         data-action="undo"
         loon-focus-when=false
         @on_mouseleave
         @on_mousemove>
      Undo
      <span data-slot="dropdown-menu-shortcut"> Ctrl+Z </span>
    </div>
    <div data-slot="dropdown-menu-item"
         data-variant="default"
         role="menuitem"
         tabindex="-1"
         data-orientation="vertical"
         data-radix-collection-item=""
         data-action="redo"
         loon-focus-when=false
         @on_click
         @on_mouseleave
         @on_mousemove>
      Redo
      <span data-slot="dropdown-menu-shortcut"> Ctrl+Shift+Z </span>
    </div>
    query: scale=18
    |}]
;;

let%expect_test "shuffle keeps the locked params and the item; reset" =
  let h, query, _ = page ~query:"body=lora&item=notes" () in
  click h "[data-param=body] button[aria-label=Lock]";
  click h "[data-param=measure] button[aria-label=Lock]";
  show h "[data-param=body] button[data-locked]";
  show h "[data-param=scale] button[data-locked]";
  for _ = 1 to 3 do
    click h "[data-slot=card-footer] [data-action=shuffle]";
    print_query query
  done;
  click h "[data-slot=card-header] button[aria-haspopup=menu]";
  click h "[data-action=reset]";
  print_query query;
  [%expect {|
    <button type="button" title="Unlock" aria-label="Unlock" data-locked="true" @on_click>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           aria-hidden="true">
        <rect width="18" height="11" x="3" y="11" rx="2" ry="2"> </rect>
        <path> </path>
      </svg>
    </button>
    <button type="button" title="Lock" aria-label="Lock" data-locked="false" @on_click>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           aria-hidden="true">
        <rect width="18" height="11" x="3" y="11" rx="2" ry="2"> </rect>
        <path> </path>
      </svg>
    </button>
    query: body=lora&heading=noto-serif&mono=jetbrains-mono&scale=14&flow=1em&leading=1.9&item=notes
    query: body=lora&heading=lora&leading=1.9&item=notes
    query: body=lora&heading=oxanium&flow=1em&item=notes
    query: (empty)
    |}]
;;

let%expect_test "the mode switch" =
  let h, _, mode = page () in
  click h "[data-slot=card-header] button[aria-haspopup=menu]";
  click h "[data-action=theme]";
  print_s [%sexp (Bonsai.Expert.Var.get mode : Loon.Theme.Mode.t)];
  [%expect {| Dark |}]
;;
