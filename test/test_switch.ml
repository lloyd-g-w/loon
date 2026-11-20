open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test "sizes" =
  List.iter Switch.Size.all ~f:(fun size ->
    Render.html
      (Switch.view
         ~size
         ~checked:true
         ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
         ()));
  [%expect
    {|
    <button type="button"
            role="switch"
            aria-checked="true"
            data-state="checked"
            class="loon-switch loon-switch-sm"
            @on_click>
      <span class="loon-switch-thumb"> </span>
    </button>
    <button type="button"
            role="switch"
            aria-checked="true"
            data-state="checked"
            class="loon-switch loon-switch-md"
            @on_click>
      <span class="loon-switch-thumb"> </span>
    </button>
    |}]
;;

let%expect_test "clicking flips it" =
  let handle =
    Control_render.handle
      [%sexp_of: bool]
      (Switch.component ~label:"Airplane mode")
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: false </span>
      <label data-disabled="false" class="loon-switch-label">
        <button type="button"
                role="switch"
                aria-checked="false"
                data-state="unchecked"
                class="loon-switch loon-switch-md"
                @on_click>
          <span class="loon-switch-thumb"> </span>
        </button>
        <span> Airplane mode </span>
      </label>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[role=switch]";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: false </span>
    +|  <span> value: true </span>
        <label data-disabled="false" class="loon-switch-label">
          <button type="button"
                  role="switch"
    -|            aria-checked="false"
    +|            aria-checked="true"
    -|            data-state="unchecked"
    +|            data-state="checked"
                  class="loon-switch loon-switch-md"
                  @on_click>
            <span class="loon-switch-thumb"> </span>
          </button>
          <span> Airplane mode </span>
        </label>
      </div>
    |}]
;;
