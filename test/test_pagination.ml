open! Core
open Loon
module Handle = Bonsai_web_test.Handle

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

let%expect_test "next, previous and page links" =
  let handle =
    Bonsai_web_test.Handle.create
      (Bonsai_web_test.Result_spec.vdom (fun (t : Pagination.t) -> t.view))
      (Pagination.component ~pages:(Bonsai_web.Bonsai.return 10))
  in
  Handle.show handle;
  [%expect
    {|
    <nav aria-label="Pagination" class="loon-pagination">
      <ul class="loon-pagination-list">
        <li>
          <button type="button"
                  aria-label="Previous page"
                  disabled=""
                  class="loon-pagination-link loon-pagination-step">
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
                 class="lucide lucide-chevron-left">
              <path d="m15 18-6-6 6-6"> </path>
            </svg>
            <span class="loon-pagination-step-text"> Previous </span>
          </button>
        </li>
        <li>
          <button type="button"
                  aria-label="Page 1"
                  aria-current="page"
                  data-state="active"
                  class="loon-pagination-link"
                  @on_click> 1 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 2" class="loon-pagination-link" @on_click> 2 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 3" class="loon-pagination-link" @on_click> 3 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 4" class="loon-pagination-link" @on_click> 4 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 5" class="loon-pagination-link" @on_click> 5 </button>
        </li>
        <li>
          <span aria-hidden="true" class="loon-pagination-ellipsis">
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
        <li>
          <button type="button" aria-label="Page 10" class="loon-pagination-link" @on_click> 10 </button>
        </li>
        <li>
          <button type="button"
                  aria-label="Next page"
                  class="loon-pagination-link loon-pagination-step"
                  @on_click>
            <span class="loon-pagination-step-text"> Next </span>
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
          </button>
        </li>
      </ul>
    </nav>
    |}];
  Handle.click_on
    handle
    ~get_vdom:(fun t -> t.view)
    ~selector:"[aria-label='Next page']";
  Handle.click_on
    handle
    ~get_vdom:(fun t -> t.view)
    ~selector:"[aria-label='Page 5']";
  Handle.show_diff handle;
  [%expect
    {|
      <nav aria-label="Pagination" class="loon-pagination">
        <ul class="loon-pagination-list">
          <li>
            <button type="button"
                    aria-label="Previous page"
    -|              disabled=""
    -|              class="loon-pagination-link loon-pagination-step">
    +|              class="loon-pagination-link loon-pagination-step"
    +|              @on_click>
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
                   class="lucide lucide-chevron-left">
                <path d="m15 18-6-6 6-6"> </path>
              </svg>
              <span class="loon-pagination-step-text"> Previous </span>
            </button>
          </li>
    +|    <li>
    +|      <button type="button" aria-label="Page 1" class="loon-pagination-link" @on_click> 1 </button>
    +|    </li>
    +|    <li>
    +|      <span aria-hidden="true" class="loon-pagination-ellipsis">
    +|        <svg xmlns="http://www.w3.org/2000/svg"
    +|             width="24"
    +|             height="24"
    +|             viewBox="0 0 24 24"
    +|             fill="none"
    +|             stroke="currentColor"
    +|             stroke-width="2"
    +|             stroke-linecap="round"
    +|             stroke-linejoin="round"
    +|             aria-hidden="true"
    +|             class="lucide lucide-ellipsis">
    +|          <circle cx="12" cy="12" r="1"> </circle>
    +|          <circle cx="19" cy="12" r="1"> </circle>
    +|          <circle cx="5" cy="12" r="1"> </circle>
    +|        </svg>
    +|      </span>
    +|    </li>
    +|    <li>
    +|      <button type="button" aria-label="Page 4" class="loon-pagination-link" @on_click> 4 </button>
    +|    </li>
          <li>
            <button type="button"
    -|              aria-label="Page 1"
    +|              aria-label="Page 5"
                    aria-current="page"
                    data-state="active"
                    class="loon-pagination-link"
    -|              @on_click> 1 </button>
    +|              @on_click> 5 </button>
          </li>
          <li>
    -|      <button type="button" aria-label="Page 2" class="loon-pagination-link" @on_click> 2 </button>
    -|    </li>
    -|    <li>
    -|      <button type="button" aria-label="Page 3" class="loon-pagination-link" @on_click> 3 </button>
    -|    </li>
    -|    <li>
    -|      <button type="button" aria-label="Page 4" class="loon-pagination-link" @on_click> 4 </button>
    -|    </li>
    -|    <li>
    -|      <button type="button" aria-label="Page 5" class="loon-pagination-link" @on_click> 5 </button>
    +|      <button type="button" aria-label="Page 6" class="loon-pagination-link" @on_click> 6 </button>
          </li>
          <li>
            <span aria-hidden="true" class="loon-pagination-ellipsis">
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
    |}];
  Handle.click_on
    handle
    ~get_vdom:(fun t -> t.view)
    ~selector:"[aria-label='Page 10']";
  Handle.show handle;
  [%expect
    {|
    <nav aria-label="Pagination" class="loon-pagination">
      <ul class="loon-pagination-list">
        <li>
          <button type="button"
                  aria-label="Previous page"
                  class="loon-pagination-link loon-pagination-step"
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
                 aria-hidden="true"
                 class="lucide lucide-chevron-left">
              <path d="m15 18-6-6 6-6"> </path>
            </svg>
            <span class="loon-pagination-step-text"> Previous </span>
          </button>
        </li>
        <li>
          <button type="button" aria-label="Page 1" class="loon-pagination-link" @on_click> 1 </button>
        </li>
        <li>
          <span aria-hidden="true" class="loon-pagination-ellipsis">
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
        <li>
          <button type="button" aria-label="Page 6" class="loon-pagination-link" @on_click> 6 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 7" class="loon-pagination-link" @on_click> 7 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 8" class="loon-pagination-link" @on_click> 8 </button>
        </li>
        <li>
          <button type="button" aria-label="Page 9" class="loon-pagination-link" @on_click> 9 </button>
        </li>
        <li>
          <button type="button"
                  aria-label="Page 10"
                  aria-current="page"
                  data-state="active"
                  class="loon-pagination-link"
                  @on_click> 10 </button>
        </li>
        <li>
          <button type="button"
                  aria-label="Next page"
                  disabled=""
                  class="loon-pagination-link loon-pagination-step">
            <span class="loon-pagination-step-text"> Next </span>
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
          </button>
        </li>
      </ul>
    </nav>
    |}]
;;
