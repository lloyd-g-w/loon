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
    <nav aria-label="breadcrumb" data-slot="breadcrumb">
      <ol data-slot="breadcrumb-list"
          class="break-words flex flex-wrap gap-1.5 items-center sm:gap-2.5 text-muted-foreground text-sm">
        <li data-slot="breadcrumb-item" class="gap-1.5 inline-flex items-center">
          <a data-slot="breadcrumb-link" href="/" class="hover:text-foreground transition-colors"> Home </a>
        </li>
        <li data-slot="breadcrumb-separator"
            role="presentation"
            aria-hidden="true"
            class="[&>svg]:size-3.5">
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
        <li data-slot="breadcrumb-item" class="gap-1.5 inline-flex items-center">
          <span data-slot="breadcrumb-ellipsis"
                role="presentation"
                aria-hidden="true"
                class="flex items-center justify-center size-9">
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
                 class="lucide lucide-ellipsis size-4">
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
            class="[&>svg]:size-3.5"> / </li>
        <li data-slot="breadcrumb-item" class="gap-1.5 inline-flex items-center">
          <span data-slot="breadcrumb-page"
                role="link"
                aria-disabled="true"
                aria-current="page"
                class="font-normal max-w-20 text-foreground truncate"> Breadcrumb </span>
        </li>
      </ol>
    </nav>
    |}]
;;
