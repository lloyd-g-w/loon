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
            class="border border-transparent dark:data-[state=unchecked]:bg-input/80 data-[size=default]:h-[1.15rem] data-[size=default]:w-8 data-[size=sm]:h-3.5 data-[size=sm]:w-6 data-[state=checked]:bg-primary data-[state=unchecked]:bg-input disabled:cursor-not-allowed disabled:opacity-50 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 group/switch inline-flex items-center outline-none peer rounded-full shadow-xs shrink-0 transition-all"
            #value="on"
            @on_click>
      <span data-state="unchecked"
            data-slot="switch-thumb"
            class="bg-background block dark:data-[state=checked]:bg-primary-foreground dark:data-[state=unchecked]:bg-foreground data-[state=checked]:translate-x-[calc(100%-2px)] data-[state=unchecked]:translate-x-0 group-data-[size=default]/switch:size-4 group-data-[size=sm]/switch:size-3 pointer-events-none ring-0 rounded-full transition-transform"> </span>
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
