open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test "each state" =
  List.iter Checkbox.State.all ~f:(fun state ->
    Render.html
      (Checkbox.view ~state ~on_change:(fun _ -> Bonsai_web.Effect.Ignore) ()));
  [%expect
    {|
    <button type="button"
            role="checkbox"
            aria-checked="true"
            data-state="checked"
            class="loon-checkbox"
            @on_click>
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-checkbox-mark loon-icon loon-icon-check">
        <path d="M20 6 9 17l-5-5"> </path>
      </svg>
    </button>
    <button type="button"
            role="checkbox"
            aria-checked="false"
            data-state="unchecked"
            class="loon-checkbox"
            @on_click> </button>
    <button type="button"
            role="checkbox"
            aria-checked="mixed"
            data-state="indeterminate"
            class="loon-checkbox"
            @on_click>
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-checkbox-mark loon-icon loon-icon-minus">
        <path d="M5 12h14"> </path>
      </svg>
    </button>
    |}]
;;

let%expect_test "indeterminate becomes checked" =
  let handle =
    Render.handle (fun _ ->
      Bonsai_web.Bonsai.return
        (Checkbox.view
           ~state:Indeterminate
           ~on_change:(fun b ->
             Bonsai_web.Effect.of_thunk (fun () ->
               print_s [%message (b : bool)]))
           ()))
  in
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"button";
  [%expect {| (b true) |}]
;;

let%expect_test "clicking toggles it; disabled ones have no handler" =
  let handle =
    Control_render.handle
      [%sexp_of: bool]
      (Checkbox.component ~label:"Remember me")
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: false </span>
      <label data-disabled="false" class="loon-checkbox-label">
        <button type="button"
                role="checkbox"
                aria-checked="false"
                data-state="unchecked"
                class="loon-checkbox"
                @on_click> </button>
        <span> Remember me </span>
      </label>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"button";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: false </span>
    +|  <span> value: true </span>
        <label data-disabled="false" class="loon-checkbox-label">
          <button type="button"
                  role="checkbox"
    -|            aria-checked="false"
    +|            aria-checked="true"
    -|            data-state="unchecked"
    +|            data-state="checked"
    -|            class="loon-checkbox"
    -|            @on_click> </button>
    +|            class="loon-checkbox"
    +|            @on_click>
    +|      <svg viewBox="0 0 24 24"
    +|           aria-hidden="true"
    +|           class="loon-checkbox-mark loon-icon loon-icon-check">
    +|        <path d="M20 6 9 17l-5-5"> </path>
    +|      </svg>
    +|    </button>
          <span> Remember me </span>
        </label>
      </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"button";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: true </span>
    +|  <span> value: false </span>
        <label data-disabled="false" class="loon-checkbox-label">
          <button type="button"
                  role="checkbox"
    -|            aria-checked="true"
    +|            aria-checked="false"
    -|            data-state="checked"
    +|            data-state="unchecked"
    -|            class="loon-checkbox"
    -|            @on_click>
    -|      <svg viewBox="0 0 24 24"
    -|           aria-hidden="true"
    -|           class="loon-checkbox-mark loon-icon loon-icon-check">
    -|        <path d="M20 6 9 17l-5-5"> </path>
    -|      </svg>
    -|    </button>
    +|            class="loon-checkbox"
    +|            @on_click> </button>
          <span> Remember me </span>
        </label>
      </div>
    |}];
  Render.html
    (Checkbox.view
       ~disabled:true
       ~label:"Locked"
       ~state:Checked
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       ());
  [%expect
    {|
    <label data-disabled="true" class="loon-checkbox-label">
      <button type="button"
              role="checkbox"
              aria-checked="true"
              data-state="checked"
              disabled=""
              class="loon-checkbox">
        <svg viewBox="0 0 24 24"
             aria-hidden="true"
             class="loon-checkbox-mark loon-icon loon-icon-check">
          <path d="M20 6 9 17l-5-5"> </path>
        </svg>
      </button>
      <span> Locked </span>
    </label>
    |}]
;;
