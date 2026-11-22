open! Core
open Loon
module Handle = Bonsai_web_test.Handle
module Node = Virtual_dom.Vdom.Node

let show ~page ~pages =
  Pagination.entries ~page ~pages ()
  |> List.map ~f:(function
    | Pagination.Entry.Page p when p = page -> sprintf "[%d]" p
    | Page p -> Int.to_string p
    | Ellipsis -> "…")
  |> String.concat ~sep:" "
  |> print_endline
;;

let%expect_test "entries" =
  show ~page:1 ~pages:5;
  List.iter [ 1; 3; 4; 5; 6; 7; 10 ] ~f:(fun page -> show ~page ~pages:10);
  show ~page:50 ~pages:10;
  show ~page:1 ~pages:0;
  [%expect
    {|
    [1] 2 3 4 5
    [1] 2 3 4 5 … 10
    1 2 [3] 4 5 … 10
    1 2 3 [4] 5 … 10
    1 … 4 [5] 6 … 10
    1 … 5 [6] 7 … 10
    1 … 6 [7] 8 9 10
    1 … 6 7 8 9 [10]
    1 … 6 7 8 9 10
    |}];
  print_s
    [%sexp
      (Pagination.entries ~siblings:2 ~page:10 ~pages:20 ()
       : Pagination.Entry.t list)];
  [%expect
    {|
    ((Page 1) Ellipsis (Page 8) (Page 9) (Page 10) (Page 11) (Page 12) Ellipsis
     (Page 20))
    |}]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Pagination.root
       [ Pagination.content
           [ Pagination.item [ Pagination.previous ~href:"#" () ]
           ; Pagination.item [ Pagination.link ~href:"#" [ Node.text "1" ] ]
           ; Pagination.item [ Pagination.link ~href:"#" ~is_active:true [ Node.text "2" ] ]
           ; Pagination.item [ Pagination.ellipsis () ]
           ; Pagination.item [ Pagination.next ~href:"#" () ]
           ]
       ]);
  [%expect {|
    <nav role="navigation"
         aria-label="pagination"
         data-slot="pagination"
         class="cn-pagination flex justify-center mx-auto w-full">
      <ul data-slot="pagination-content" class="cn-pagination-content flex items-center">
        <li data-slot="pagination-item">
          <a data-slot="pagination-link"
             data-variant="ghost"
             data-size="default"
             href="#"
             aria-label="Go to previous page"
             class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-pagination-link cn-pagination-previous disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 data-icon="inline-start"
                 class="cn-rtl-flip lucide lucide-chevron-left">
              <path d="m15 18-6-6 6-6"> </path>
            </svg>
            <span class="cn-pagination-previous-text hidden sm:block"> Previous </span>
          </a>
        </li>
        <li data-slot="pagination-item">
          <a data-slot="pagination-link"
             data-variant="ghost"
             data-size="icon"
             href="#"
             class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-icon cn-button-variant-ghost cn-pagination-link disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"> 1 </a>
        </li>
        <li data-slot="pagination-item">
          <a data-slot="pagination-link"
             data-variant="outline"
             data-size="icon"
             aria-current="page"
             data-active="true"
             href="#"
             class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-icon cn-button-variant-outline cn-pagination-link disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"> 2 </a>
        </li>
        <li data-slot="pagination-item">
          <span aria-hidden="true"
                data-slot="pagination-ellipsis"
                class="cn-pagination-ellipsis flex items-center justify-center">
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
            <span class="sr-only"> More pages </span>
          </span>
        </li>
        <li data-slot="pagination-item">
          <a data-slot="pagination-link"
             data-variant="ghost"
             data-size="default"
             href="#"
             aria-label="Go to next page"
             class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-pagination-link cn-pagination-next disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap">
            <span class="cn-pagination-next-text hidden sm:block"> Next </span>
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 data-icon="inline-end"
                 class="cn-rtl-flip lucide lucide-chevron-right">
              <path d="m9 18 6-6-6-6"> </path>
            </svg>
          </a>
        </li>
      </ul>
    </nav>
    |}]
;;

let%expect_test "on_click changes page without following the link" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let open Bonsai_web.Bonsai.Let_syntax in
      let page, set_page = Bonsai_web.Bonsai.state 1 graph in
      let%arr page and set_page in
      Pagination.content
        (List.map [ 1; 2 ] ~f:(fun p ->
           Pagination.item
             [ Pagination.link
                 ~href:"#"
                 ~is_active:(p = page)
                 ~on_click:(set_page p)
                 [ Node.text (Int.to_string p) ]
             ])))
  in
  Handle.show handle;
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"li:nth-child(2) a";
  Handle.show_diff handle;
  [%expect {|
    <ul data-slot="pagination-content">
      <li data-slot="pagination-item">
        <a data-slot="pagination-link"
           data-variant="outline"
           data-size="icon"
           aria-current="page"
           data-active="true"
           href="#"
           @on_click> 1 </a>
      </li>
      <li data-slot="pagination-item">
        <a data-slot="pagination-link" data-variant="ghost" data-size="icon" href="#" @on_click> 2 </a>
      </li>
    </ul>

      <ul data-slot="pagination-content">
    +|  <li data-slot="pagination-item">
    +|    <a data-slot="pagination-link" data-variant="ghost" data-size="icon" href="#" @on_click> 1 </a>
    +|  </li>
        <li data-slot="pagination-item">
          <a data-slot="pagination-link"
             data-variant="outline"
             data-size="icon"
             aria-current="page"
             data-active="true"
             href="#"
    -|       @on_click> 1 </a>
    -|  </li>
    -|  <li data-slot="pagination-item">
    -|    <a data-slot="pagination-link" data-variant="ghost" data-size="icon" href="#" @on_click> 2 </a>
    +|       @on_click> 2 </a>
        </li>
      </ul>
    |}]
;;
