(* The stateless display components' HTML. *)

open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "breadcrumb" =
  let items =
    Breadcrumb.Item.
      [ create ~href:"/" "Home"
      ; create ~href:"/docs" "Docs"
      ; create ~href:"/docs/components" "Components"
      ; create ~href:"/docs/components/display" "Display"
      ; create "Breadcrumb"
      ]
  in
  Render.html (Breadcrumb.view (List.take items 2));
  [%expect
    {|
    <nav aria-label="Breadcrumb" class="loon-breadcrumb">
      <ol class="loon-breadcrumb-list">
        <li class="loon-breadcrumb-item">
          <a href="/" class="loon-breadcrumb-link"> Home </a>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true"
               class="lucide lucide-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-current="page" class="loon-breadcrumb-page"> Docs </span>
        </li>
      </ol>
    </nav>
    |}];
  Render.html (Breadcrumb.view ~max_items:3 items);
  [%expect
    {|
    <nav aria-label="Breadcrumb" class="loon-breadcrumb">
      <ol class="loon-breadcrumb-list">
        <li class="loon-breadcrumb-item">
          <a href="/" class="loon-breadcrumb-link"> Home </a>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true"
               class="lucide lucide-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-label="3 more" role="img" class="loon-breadcrumb-ellipsis">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true"
                 class="lucide lucide-ellipsis">
              <circle cx="12" cy="12" r="1"> </circle>
              <circle cx="19" cy="12" r="1"> </circle>
              <circle cx="5" cy="12" r="1"> </circle>
            </svg>
          </span>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true"
               class="lucide lucide-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-current="page" class="loon-breadcrumb-page"> Breadcrumb </span>
        </li>
      </ol>
    </nav>
    |}]
;;

let%expect_test "theme root" =
  Render.html (Theme.root [ Node.text "inherits" ]);
  Render.html (Theme.root ~mode:Dark [ Node.text "dark" ]);
  [%expect {|
    <div class="bg-background loon text-foreground"> inherits </div>
    <div class="bg-background dark loon text-foreground"> dark </div>
    |}]
;;
