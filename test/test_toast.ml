open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

(* A page with a toaster and buttons that push toasts. *)
let page (local_ graph) =
  let toaster = Toast.component graph in
  let open Bonsai.Let_syntax in
  let%arr { Toast.Toaster.view; push; dismiss_all } = toaster in
  Vdom.Node.div
    [ Button.view
        ~attrs:[ Vdom.Attr.id "saved" ]
        ~on_click:(push (Toast.create ~variant:Success ~description:"All good." "Saved"))
        [ Vdom.Node.text "Save" ]
    ; Button.view
        ~attrs:[ Vdom.Attr.id "sticky" ]
        ~on_click:
          (push
             (Toast.create
                ~duration:None
                ~action:("Undo", Effect.print_s [%message "undone"])
                "Message deleted"))
        [ Vdom.Node.text "Delete" ]
    ; Button.view
        ~attrs:[ Vdom.Attr.id "clear" ]
        ~on_click:dismiss_all
        [ Vdom.Node.text "Clear" ]
    ; view
    ]
;;

let toasts handle =
  Handle.last_result handle
  |> Virtual_dom_test_helpers.Node_helpers.unsafe_convert_exn
  |> (fun n -> Virtual_dom_test_helpers.Node_helpers.select n ~selector:".loon-toast")
  |> List.map ~f:(fun n ->
    let title =
      Virtual_dom_test_helpers.Node_helpers.select_first_exn n ~selector:".loon-toast-title"
      |> Virtual_dom_test_helpers.Node_helpers.inner_text
    in
    let state =
      match n with
      | Element { attributes; _ } ->
        List.Assoc.find attributes ~equal:String.equal "data-state"
        |> Option.value ~default:"?"
      | _ -> "?"
    in
    sprintf "%s (%s)" title state)
  |> String.concat ~sep:", "
  |> fun s -> print_endline (if String.is_empty s then "(none)" else s)
;;

let click handle id = Handle.click_on handle ~get_vdom:Fn.id ~selector:("#" ^ id)
let wait handle secs =
  Handle.recompute_view handle;
  Handle.advance_clock_by handle (Time_ns.Span.of_sec secs);
  Handle.recompute_view handle
;;

let%expect_test "a toast's HTML" =
  let handle = Render.handle page in
  click handle "saved";
  click handle "sticky";
  Handle.recompute_view handle;
  Render.html ~selector:".loon-toaster" (Handle.last_result handle);
  [%expect {|
    <section aria-label="Notifications" tabindex="-1" class="loon-toaster loon-toaster-bottom-right">
      <ol class="loon-toaster-list">
        <li @key=0
            role="status"
            aria-atomic="true"
            data-state="open"
            class="loon-toast loon-toast-success">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true"
               class="loon-toast-icon lucide lucide-circle-check">
            <circle cx="12" cy="12" r="10"> </circle>
            <path d="m16 9-5.5 5.5L8 12"> </path>
          </svg>
          <div class="loon-toast-body">
            <div class="loon-toast-title"> Saved </div>
            <div class="loon-toast-description"> All good. </div>
          </div>
          <button type="button" aria-label="Dismiss" class="loon-toast-close" @on_click>
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true"
                 class="lucide lucide-x">
              <path d="M18 6 6 18"> </path>
              <path d="m6 6 12 12"> </path>
            </svg>
          </button>
        </li>
        <li @key=1
            role="status"
            aria-atomic="true"
            data-state="open"
            class="loon-toast loon-toast-neutral">
          <div class="loon-toast-body">
            <div class="loon-toast-title"> Message deleted </div>
          </div>
          <button type="button" class="loon-toast-action" @on_click> Undo </button>
          <button type="button" aria-label="Dismiss" class="loon-toast-close" @on_click>
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true"
                 class="lucide lucide-x">
              <path d="M18 6 6 18"> </path>
              <path d="m6 6 12 12"> </path>
            </svg>
          </button>
        </li>
      </ol>
    </section>
    |}]
;;

let%expect_test "toasts dismiss themselves after their duration" =
  let handle = Render.handle page in
  click handle "saved";
  Handle.recompute_view handle;
  toasts handle;
  wait handle 4.9;
  toasts handle;
  wait handle 0.1;
  toasts handle;
  wait handle 0.2;
  toasts handle;
  [%expect {|
    Saved (open)
    Saved (open)
    Saved (closed)
    (none)
    |}]
;;

let%expect_test "sticky toasts, actions, the close button and the cap" =
  let handle = Render.handle page in
  click handle "sticky";
  wait handle 60.;
  toasts handle;
  Handle.click_on handle ~get_vdom:Fn.id ~selector:".loon-toast-action";
  wait handle 1.;
  toasts handle;
  [%expect {|
    Message deleted (open)
    undone
    (none)
    |}];
  List.iter [ "sticky"; "saved"; "saved"; "sticky" ] ~f:(click handle);
  Handle.recompute_view handle;
  toasts handle;
  Handle.click_on handle ~get_vdom:Fn.id ~selector:".loon-toast-close";
  wait handle 0.3;
  toasts handle;
  click handle "clear";
  wait handle 0.3;
  toasts handle;
  [%expect {|
    Saved (open), Saved (open), Message deleted (open)
    Message deleted (open), Saved (open), Message deleted (open)
    (none)
    |}]
;;
