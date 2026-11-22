open! Core
open Loon

let%expect_test "shadcn's classes, sized and coloured by the caller" =
  Render.html (Spinner.view ());
  Render.html ~selector:"svg" (Spinner.view ~class_:"size-6 text-red-500" ());
  [%expect {|
    <svg xmlns="http://www.w3.org/2000/svg"
         width="24"
         height="24"
         viewBox="0 0 24 24"
         fill="none"
         stroke="currentColor"
         stroke-width="2"
         stroke-linecap="round"
         stroke-linejoin="round"
         data-slot="spinner"
         role="status"
         aria-label="Loading"
         class="animate-spin lucide lucide-loader-circle size-4">
      <path d="M21 12a9 9 0 1 1-6.219-8.56"> </path>
    </svg>
    <svg xmlns="http://www.w3.org/2000/svg"
         width="24"
         height="24"
         viewBox="0 0 24 24"
         fill="none"
         stroke="currentColor"
         stroke-width="2"
         stroke-linecap="round"
         stroke-linejoin="round"
         data-slot="spinner"
         role="status"
         aria-label="Loading"
         class="animate-spin lucide lucide-loader-circle size-6 text-red-500">
      <path d="M21 12a9 9 0 1 1-6.219-8.56"> </path>
    </svg>
    |}]
;;
