open! Core
open Loon

let%expect_test "shadcn's classes, sized by the caller" =
  Render.html (Skeleton.view ~class_:"h-4 w-[250px] rounded-full" []);
  [%expect {| <div data-slot="skeleton" class="animate-pulse bg-accent h-4 rounded-full w-[250px]"> </div> |}]
;;
