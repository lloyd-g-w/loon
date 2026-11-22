open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "the default button: shadcn's classes and slots" =
  Render.html (Button.view [ Node.text "Button" ]);
  [%expect {|
    <button type="button"
            data-slot="button"
            data-variant="default"
            data-size="default"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-default disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"> Button </button>
    |}]
;;

let%expect_test "variants and sizes set data-variant, data-size and their classes" =
  List.iter Button.Variant.all ~f:(fun variant ->
    print_endline (Button.classes ~variant ()));
  [%expect {|
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-destructive cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-outline cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-secondary cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-ghost cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-link cn-button-size-default
    |}];
  List.iter Button.Size.all ~f:(fun size -> print_endline (Button.classes ~size ()));
  [%expect {|
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-default
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-xs
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-sm
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-lg
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-icon
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-icon-xs
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-icon-sm
    cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-icon-lg
    |}];
  Render.html
    ~classes:false
    (Button.view ~variant:Outline ~size:Icon_sm ~disabled:true [ Icon.view Plus ]);
  [%expect {|
    <button type="button" data-slot="button" data-variant="outline" data-size="icon-sm" disabled="">
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round">
        <path d="M5 12h14"> </path>
        <path d="M12 5v14"> </path>
      </svg>
    </button>
    |}]
;;

let%expect_test "class_ is merged last" =
  print_endline (Button.classes ~size:Icon ~class_:"rounded-full size-12" ());
  [%expect {| cn-button group/button inline-flex shrink-0 items-center justify-center whitespace-nowrap transition-all outline-none select-none disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button-variant-default cn-button-size-icon rounded-full size-12 |}]
;;

let%expect_test "submit buttons and links" =
  Render.html ~classes:false (Button.view ~type_:`Submit [ Node.text "Save" ]);
  [%expect {| <button type="submit" data-slot="button" data-variant="default" data-size="default"> Save </button> |}];
  Render.html
    ~classes:false
    (Button.link ~variant:Outline ~href:"/docs" [ Node.text "Docs" ]);
  [%expect {| <a data-slot="button" data-variant="outline" data-size="default" href="/docs"> Docs </a> |}]
;;
