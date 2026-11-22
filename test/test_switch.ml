open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let ignore_ _ = Bonsai_web.Effect.Ignore

let%expect_test "shadcn's classes" =
  Render.html
    (Switch.view ~id:"airplane-mode" ~checked:false ~on_change:ignore_ ());
  [%expect
    {|
    <button type="button"
            role="switch"
            aria-checked="false"
            data-state="unchecked"
            data-slot="switch"
            data-size="default"
            id="airplane-mode"
            class="after:-inset-x-3 after:-inset-y-2 after:absolute cn-switch data-disabled:cursor-not-allowed data-disabled:opacity-50 group/switch inline-flex items-center outline-none peer relative transition-all"
            #value="on"
            @on_click>
      <span data-state="unchecked"
            data-slot="switch-thumb"
            class="block cn-switch-thumb pointer-events-none ring-0 transition-transform"> </span>
    </button>
    |}]
;;

let%expect_test "sizes, disabled, invalid" =
  List.iter Switch.Size.all ~f:(fun size ->
    Render.html
      ~classes:false
      (Switch.view ~size ~checked:true ~on_change:ignore_ ()));
  Render.html
    ~classes:false
    (Switch.view
       ~disabled:true
       ~invalid:true
       ~checked:false
       ~on_change:ignore_
       ());
  [%expect
    {|
    <button type="button"
            role="switch"
            aria-checked="true"
            data-state="checked"
            data-slot="switch"
            data-size="default"
            #value="on"
            @on_click>
      <span data-state="checked" data-slot="switch-thumb"> </span>
    </button>
    <button type="button"
            role="switch"
            aria-checked="true"
            data-state="checked"
            data-slot="switch"
            data-size="sm"
            #value="on"
            @on_click>
      <span data-state="checked" data-slot="switch-thumb"> </span>
    </button>
    <button type="button"
            role="switch"
            aria-checked="false"
            data-state="unchecked"
            data-slot="switch"
            data-size="default"
            aria-invalid="true"
            data-disabled=""
            disabled=""
            #value="on">
      <span data-state="unchecked" data-slot="switch-thumb" data-disabled=""> </span>
    </button>
    |}]
;;

let%expect_test "a click toggles" =
  let handle =
    Control_render.handle Bool.sexp_of_t (Switch.component ~id:"s")
  in
  Handle.show handle;
  Drive.click handle "#s";
  Handle.show handle;
  Drive.click handle "#s";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              role="switch"
              aria-checked="false"
              data-state="unchecked"
              data-slot="switch"
              data-size="default"
              id="s"
              #value="on"
              @on_click>
        <span data-state="unchecked" data-slot="switch-thumb"> </span>
      </button>
      <output> false </output>
    </div>
    <div>
      <button type="button"
              role="switch"
              aria-checked="true"
              data-state="checked"
              data-slot="switch"
              data-size="default"
              id="s"
              #value="on"
              @on_click>
        <span data-state="checked" data-slot="switch-thumb"> </span>
      </button>
      <output> true </output>
    </div>
    <div>
      <button type="button"
              role="switch"
              aria-checked="false"
              data-state="unchecked"
              data-slot="switch"
              data-size="default"
              id="s"
              #value="on"
              @on_click>
        <span data-state="unchecked" data-slot="switch-thumb"> </span>
      </button>
      <output> false </output>
    </div>
    |}]
;;
