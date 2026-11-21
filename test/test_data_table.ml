open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

type person =
  { name : string
  ; role : string
  ; age : int
  }

let people =
  [ { name = "Ada"; role = "Mathematician"; age = 36 }
  ; { name = "Grace"; role = "Admiral"; age = 85 }
  ; { name = "Alan"; role = "Mathematician"; age = 41 }
  ; { name = "Edsger"; role = "Programmer"; age = 72 }
  ]
;;

let columns =
  Data_table.Column.
    [ text ~id:"name" "Name" (fun p -> p.name)
    ; text ~secondary:true ~id:"role" "Role" (fun p -> p.role)
    ; create
        ~align:Right
        ~sort:(fun a b -> Int.compare a.age b.age)
        ~id:"age"
        "Age"
        (fun p -> Node.text (Int.to_string p.age))
    ]
;;

let names rows =
  List.map rows ~f:(fun p -> p.name) |> String.concat ~sep:" " |> print_endline
;;

let%expect_test "visible_rows" =
  names (Data_table.visible_rows ~columns ~filter:"" ~sort:None people);
  names (Data_table.visible_rows ~columns ~filter:" MATH " ~sort:None people);
  names
    (Data_table.visible_rows
       ~columns
       ~filter:""
       ~sort:(Some ("age", Descending))
       people);
  names
    (Data_table.visible_rows
       ~columns
       ~filter:"a"
       ~sort:(Some ("name", Ascending))
       people);
  [%expect
    {|
    Ada Grace Alan Edsger
    Ada Alan
    Grace Edsger Alan Ada
    Ada Alan Edsger Grace
    |}]
;;

let component ?page_size () =
  Data_table.component
    ~selectable:true
    ?page_size
    ~columns:(Bonsai_web.Bonsai.return columns)
    ~key:(fun p -> p.name)
    (Bonsai_web.Bonsai.return people)
;;

let get_vdom (t : Data_table.t) = t.view

let rows handle =
  Handle.recompute_view handle;
  Handle.last_result handle
  |> get_vdom
  |> Virtual_dom_test_helpers.Node_helpers.unsafe_convert_exn
  |> (fun n ->
  Virtual_dom_test_helpers.Node_helpers.select
    n
    ~selector:"tbody td:nth-child(2)")
  |> List.map ~f:Virtual_dom_test_helpers.Node_helpers.inner_text
  |> String.concat ~sep:" "
  |> print_endline
;;

let%expect_test "the whole table" =
  let handle =
    Bonsai_web_test.Handle.create
      (Bonsai_web_test.Result_spec.vdom get_vdom)
      (component ())
  in
  Handle.show handle;
  [%expect
    {|
    <div class="loon-data-table">
      <div class="loon-data-table-toolbar">
        <div class="loon-data-table-filter">
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
               class="lucide lucide-search">
            <path d="m21 21-4.34-4.34"> </path>
            <circle cx="11" cy="11" r="8"> </circle>
          </svg>
          <input type="search" placeholder="Filter…" aria-label="Filter rows" #value="" @on_input/>
        </div>
      </div>
      <div class="loon-data-table-frame">
        <div class="loon-table-container">
          <table class="loon-table loon-table-hover">
            <thead class="loon-table-header">
              <tr class="loon-table-row">
                <th scope="col" data-align="left" class="loon-data-table-select loon-table-head">
                  <input type="checkbox"
                         aria-label="Select all"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </th>
                <th aria-sort="none" scope="col" data-align="left" class="loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Name
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
                <th aria-sort="none"
                    scope="col"
                    data-align="left"
                    class="loon-data-table-secondary loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Role
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
                <th aria-sort="none" scope="col" data-align="right" class="loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Age
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
              </tr>
            </thead>
            <tbody class="loon-table-body">
              <tr @key=Ada class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Ada </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Mathematician </td>
                <td data-align="right" class="loon-table-cell"> 36 </td>
              </tr>
              <tr @key=Grace class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Grace </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Admiral </td>
                <td data-align="right" class="loon-table-cell"> 85 </td>
              </tr>
              <tr @key=Alan class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Alan </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Mathematician </td>
                <td data-align="right" class="loon-table-cell"> 41 </td>
              </tr>
              <tr @key=Edsger class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Edsger </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Programmer </td>
                <td data-align="right" class="loon-table-cell"> 72 </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="loon-data-table-footer">
        <div aria-live="polite" class="loon-data-table-status"> 0 of 4 rows selected </div>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </div>
    </div>
    |}]
;;

let%expect_test "sorting, filtering and selecting" =
  let handle =
    Bonsai_web_test.Handle.create
      (Bonsai_web_test.Result_spec.vdom get_vdom)
      (component ())
  in
  let click selector = Handle.click_on handle ~get_vdom ~selector in
  click "th:nth-child(4) button";
  rows handle;
  click "th:nth-child(4) button";
  rows handle;
  click "th:nth-child(4) button";
  rows handle;
  [%expect
    {|
    Ada Alan Edsger Grace
    Grace Edsger Alan Ada
    Ada Grace Alan Edsger
    |}];
  Handle.input_text handle ~get_vdom ~selector:"input[type=search]" ~text:"math";
  rows handle;
  click "th input";
  Handle.recompute_view handle;
  print_s [%sexp ((Handle.last_result handle).selected : String.Set.t)];
  Handle.input_text handle ~get_vdom ~selector:"input[type=search]" ~text:"";
  rows handle;
  click "tr:nth-child(2) td input";
  Handle.recompute_view handle;
  print_s [%sexp ((Handle.last_result handle).selected : String.Set.t)];
  [%expect
    {|
    Ada Alan
    (Ada Alan)
    Ada Grace Alan Edsger
    (Ada Alan Grace)
    |}];
  Handle.show handle;
  [%expect
    {|
    <div class="loon-data-table">
      <div class="loon-data-table-toolbar">
        <div class="loon-data-table-filter">
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
               class="lucide lucide-search">
            <path d="m21 21-4.34-4.34"> </path>
            <circle cx="11" cy="11" r="8"> </circle>
          </svg>
          <input type="search" placeholder="Filter…" aria-label="Filter rows" #value="" @on_input/>
        </div>
      </div>
      <div class="loon-data-table-frame">
        <div class="loon-table-container">
          <table class="loon-table loon-table-hover">
            <thead class="loon-table-header">
              <tr class="loon-table-row">
                <th scope="col" data-align="left" class="loon-data-table-select loon-table-head">
                  <input type="checkbox"
                         aria-label="Select all"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="true"
                         @on_click/>
                </th>
                <th aria-sort="none" scope="col" data-align="left" class="loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Name
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
                <th aria-sort="none"
                    scope="col"
                    data-align="left"
                    class="loon-data-table-secondary loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Role
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
                <th aria-sort="none" scope="col" data-align="right" class="loon-table-head">
                  <button type="button" data-sort="none" class="loon-data-table-sort" @on_click>
                    Age
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
                         class="loon-data-table-sort-icon lucide lucide-chevrons-up-down">
                      <path d="m7 15 5 5 5-5"> </path>
                      <path d="m7 9 5-5 5 5"> </path>
                    </svg>
                  </button>
                </th>
              </tr>
            </thead>
            <tbody class="loon-table-body">
              <tr @key=Ada data-state="selected" aria-selected="true" class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="true"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Ada </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Mathematician </td>
                <td data-align="right" class="loon-table-cell"> 36 </td>
              </tr>
              <tr @key=Grace data-state="selected" aria-selected="true" class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="true"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Grace </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Admiral </td>
                <td data-align="right" class="loon-table-cell"> 85 </td>
              </tr>
              <tr @key=Alan data-state="selected" aria-selected="true" class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="true"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Alan </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Mathematician </td>
                <td data-align="right" class="loon-table-cell"> 41 </td>
              </tr>
              <tr @key=Edsger class="loon-table-row">
                <td data-align="left" class="loon-data-table-select loon-table-cell">
                  <input type="checkbox"
                         aria-label="Select row"
                         class="loon-data-table-check"
                         #checked="false"
                         #indeterminate="false"
                         @on_click/>
                </td>
                <td data-align="left" class="loon-table-cell"> Edsger </td>
                <td data-align="left" class="loon-data-table-secondary loon-table-cell"> Programmer </td>
                <td data-align="right" class="loon-table-cell"> 72 </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="loon-data-table-footer">
        <div aria-live="polite" class="loon-data-table-status"> 3 of 4 rows selected </div>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </div>
    </div>
    |}];
  Handle.input_text
    handle
    ~get_vdom
    ~selector:"input[type=search]"
    ~text:"nobody";
  Handle.recompute_view handle;
  Render.html ~selector:"tbody" (get_vdom (Handle.last_result handle));
  [%expect
    {|
    <tbody class="loon-table-body">
      <tr class="loon-table-row">
        <td data-align="center" colspan="4" class="loon-data-table-empty loon-table-cell"> No results. </td>
      </tr>
    </tbody>
    |}]
;;

let%expect_test "pages" =
  let handle =
    Bonsai_web_test.Handle.create
      (Bonsai_web_test.Result_spec.vdom get_vdom)
      (component ~page_size:3 ())
  in
  rows handle;
  Render.html
    ~selector:".loon-data-table-footer"
    (get_vdom (Handle.last_result handle));
  Handle.click_on handle ~get_vdom ~selector:".loon-data-table-footer button:last-child";
  rows handle;
  [%expect
    {|
    Ada Grace Alan
    <div class="loon-data-table-footer">
      <div aria-live="polite" class="loon-data-table-status"> 0 of 4 rows selected </div>
      <div class="flex gap-2 items-center">
        <button type="button"
                data-slot="button"
                data-variant="outline"
                data-size="sm"
                disabled=""
                class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1.5 h-8 has-[>svg]:px-2.5 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-3 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
                @on_click> Previous </button>
        <button type="button"
                data-slot="button"
                data-variant="outline"
                data-size="sm"
                class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1.5 h-8 has-[>svg]:px-2.5 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-3 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
                @on_click> Next </button>
      </div>
    </div>
    Edsger
    |}]
;;
