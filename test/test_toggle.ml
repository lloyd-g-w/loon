open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Attr = Virtual_dom.Vdom.Attr
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html
    (Toggle.view
       ~attrs:[ Attr.create "aria-label" "Toggle bold" ]
       ~pressed:false
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       [ Icon.view Bold ]);
  [%expect
    {|
    <button type="button"
            aria-pressed="false"
            data-state="off"
            data-slot="toggle"
            aria-label="Toggle bold"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle cn-toggle-size-default cn-toggle-variant-default disabled:opacity-50 disabled:pointer-events-none focus-visible:ring-[3px] group/toggle hover:bg-muted inline-flex items-center justify-center outline-none whitespace-nowrap"
            @on_click>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           class="lucide lucide-bold">
        <path d="M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8"> </path>
      </svg>
    </button>
    |}]
;;

let%expect_test "variants and sizes" =
  List.iter Toggle.Variant.all ~f:(fun variant ->
    List.iter Toggle.Size.all ~f:(fun size ->
      print_endline
        (sprintf
           "%s %s: %s"
           (Toggle.Variant.name variant)
           (Toggle.Size.name size)
           (Toggle.classes ~variant ~size ()))));
  [%expect
    {|
    default default: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-default cn-toggle-size-default
    default sm: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-default cn-toggle-size-sm
    default lg: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-default cn-toggle-size-lg
    outline default: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-outline cn-toggle-size-default
    outline sm: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-outline cn-toggle-size-sm
    outline lg: cn-toggle group/toggle inline-flex items-center justify-center whitespace-nowrap outline-none hover:bg-muted focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle-variant-outline cn-toggle-size-lg
    |}]
;;

let%expect_test "a click presses and releases" =
  let handle =
    Control_render.handle Bool.sexp_of_t (Toggle.component [ Node.text "B" ])
  in
  Handle.show handle;
  Drive.click handle "button";
  Handle.show handle;
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button" aria-pressed="false" data-state="off" data-slot="toggle" @on_click> B </button>
      <output> false </output>
    </div>
    <div>
      <button type="button" aria-pressed="true" data-state="on" data-slot="toggle" @on_click> B </button>
      <output> true </output>
    </div>
    <div>
      <button type="button" aria-pressed="false" data-state="off" data-slot="toggle" @on_click> B </button>
      <output> false </output>
    </div>
    |}]
;;

let%expect_test "disabled: no click handler" =
  let handle =
    Control_render.handle
      Bool.sexp_of_t
      (Toggle.component ~disabled:true ~default_pressed:true [ Node.text "B" ])
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              aria-pressed="true"
              data-state="on"
              data-slot="toggle"
              data-disabled=""
              disabled=""> B </button>
      <output> true </output>
    </div>
    |}]
;;
