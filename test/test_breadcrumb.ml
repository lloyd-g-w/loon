open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Breadcrumb.root
       [ Breadcrumb.list
           [ Breadcrumb.item [ Breadcrumb.link ~href:"/" [ Node.text "Home" ] ]
           ; Breadcrumb.separator ()
           ; Breadcrumb.item [ Breadcrumb.ellipsis () ]
           ; Breadcrumb.separator ~children:[ Node.text "/" ] ()
           ; Breadcrumb.item
               [ Breadcrumb.page ~class_:"max-w-20 truncate" [ Node.text "Breadcrumb" ] ]
           ]
       ]);
  [%expect {|
    <nav aria-label="breadcrumb" data-slot="breadcrumb" class="cn-breadcrumb">
      <ol data-slot="breadcrumb-list"
          class="cn-breadcrumb-list flex flex-wrap items-center wrap-break-word">
        <li data-slot="breadcrumb-item" class="cn-breadcrumb-item inline-flex items-center">
          <a data-slot="breadcrumb-link" href="/" class="cn-breadcrumb-link"> Home </a>
        </li>
        <li data-slot="breadcrumb-separator"
            role="presentation"
            aria-hidden="true"
            class="cn-breadcrumb-separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               class="cn-rtl-flip lucide lucide-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li data-slot="breadcrumb-item" class="cn-breadcrumb-item inline-flex items-center">
          <span data-slot="breadcrumb-ellipsis"
                role="presentation"
                aria-hidden="true"
                class="cn-breadcrumb-ellipsis flex items-center justify-center">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 class="lucide lucide-ellipsis">
              <circle cx="12" cy="12" r="1"> </circle>
              <circle cx="19" cy="12" r="1"> </circle>
              <circle cx="5" cy="12" r="1"> </circle>
            </svg>
            <span class="sr-only"> More </span>
          </span>
        </li>
        <li data-slot="breadcrumb-separator"
            role="presentation"
            aria-hidden="true"
            class="cn-breadcrumb-separator"> / </li>
        <li data-slot="breadcrumb-item" class="cn-breadcrumb-item inline-flex items-center">
          <span data-slot="breadcrumb-page"
                role="link"
                aria-disabled="true"
                aria-current="page"
                class="cn-breadcrumb-page max-w-20 truncate"> Breadcrumb </span>
        </li>
      </ol>
    </nav>
    |}]
;;
