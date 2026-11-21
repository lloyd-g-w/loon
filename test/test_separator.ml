open! Core
open Loon

let%expect_test "shadcn's classes" =
  Render.html (Separator.view ());
  [%expect {|
    <div data-slot="separator"
         role="none"
         data-orientation="horizontal"
         class="bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px shrink-0"> </div>
    |}]
;;

let%expect_test "vertical; semantic ones are separators" =
  Render.html ~classes:false (Separator.view ~orientation:Vertical ());
  Render.html ~classes:false (Separator.view ~decorative:false ());
  Render.html ~classes:false (Separator.view ~orientation:Vertical ~decorative:false ());
  [%expect {|
    <div data-slot="separator" role="none" data-orientation="vertical"> </div>
    <div data-slot="separator" role="separator" data-orientation="horizontal"> </div>
    <div data-slot="separator"
         role="separator"
         aria-orientation="vertical"
         data-orientation="vertical"> </div>
    |}]
;;
