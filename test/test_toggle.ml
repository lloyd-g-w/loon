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
            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent dark:aria-invalid:ring-destructive/40 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 hover:bg-muted hover:text-muted-foreground inline-flex items-center justify-center min-w-9 outline-none px-2 rounded-md text-sm transition-[color,box-shadow] whitespace-nowrap"
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
    default default: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-transparent h-9 min-w-9 px-2
    default sm: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-transparent h-8 min-w-8 px-1.5
    default lg: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none hover:bg-muted hover:text-muted-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-transparent h-10 min-w-10 px-2.5
    outline default: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground h-9 min-w-9 px-2
    outline sm: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground h-8 min-w-8 px-1.5
    outline lg: inline-flex items-center justify-center gap-2 rounded-md text-sm font-medium whitespace-nowrap transition-[color,box-shadow] outline-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground dark:aria-invalid:ring-destructive/40 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 border border-input bg-transparent shadow-xs hover:bg-accent hover:text-accent-foreground h-10 min-w-10 px-2.5
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
