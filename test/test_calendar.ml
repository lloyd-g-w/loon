open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let date = Date.of_string

let%expect_test "weeks" =
  Calendar.weeks ~week_start:Mon (date "2026-11-20")
  |> List.iter ~f:(fun week ->
    List.map week ~f:(fun d -> sprintf "%2d" (Date.day d))
    |> String.concat ~sep:" "
    |> print_endline);
  [%expect {|
    26 27 28 29 30 31  1
     2  3  4  5  6  7  8
     9 10 11 12 13 14 15
    16 17 18 19 20 21 22
    23 24 25 26 27 28 29
    30  1  2  3  4  5  6
    |}];
  Calendar.weeks ~week_start:Sun (date "2026-02-01")
  |> List.hd_exn
  |> List.hd_exn
  |> Date.to_string
  |> print_endline;
  [%expect {| 2026-02-01 |}]
;;

let%expect_test "moved" =
  let d = date "2026-01-31" in
  List.iter
    Js_of_ocaml.Dom_html.Keyboard_code.
      [ "left", ArrowLeft
      ; "right", ArrowRight
      ; "up", ArrowUp
      ; "down", ArrowDown
      ; "home", Home
      ; "end", End
      ; "pageup", PageUp
      ; "pagedown", PageDown
      ; "a", KeyA
      ]
    ~f:(fun (name, key) ->
      print_s
        [%message
          name
            ~_:(Calendar.moved ~week_start:Mon ~shift:false ~key d : Date.t option)]);
  print_s [%sexp (Calendar.moved ~week_start:Mon ~shift:true ~key:PageDown d : Date.t option)];
  [%expect {|
    (left (2026-01-30))
    (right (2026-02-01))
    (up (2026-01-24))
    (down (2026-02-07))
    (home (2026-01-26))
    (end (2026-02-01))
    (pageup (2025-12-31))
    (pagedown (2026-02-28))
    (a ())
    (2027-01-31)
    |}]
;;

let get_vdom (t : Calendar.t) = t.view

let component () =
  Calendar.component
    ~today:(date "2026-11-20")
    ~min:(date "2026-10-15")
    ~is_disabled:(fun d ->
      match Date.day_of_week d with
      | Sat | Sun -> true
      | _ -> false)


let%expect_test "the month" =
  let handle =
    Bonsai_web_test.Handle.create (Bonsai_web_test.Result_spec.vdom get_vdom) (component ())
  in
  Handle.show handle;
  [%expect {|
    <div class="loon-calendar">
      <div class="loon-calendar-header">
        <button type="button" aria-label="Previous month" class="loon-calendar-nav" @on_click>
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-left">
            <path d="m15 18-6-6 6-6"> </path>
          </svg>
        </button>
        <div id="loonbonsai_path_replaced_in_test-caption"
             aria-live="polite"
             class="loon-calendar-caption"> November 2026 </div>
        <button type="button" aria-label="Next month" class="loon-calendar-nav" @on_click>
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </button>
      </div>
      <table id="loonbonsai_path_replaced_in_test-grid"
             role="grid"
             aria-labelledby="loonbonsai_path_replaced_in_test-caption"
             class="loon-calendar-grid"
             @on_keydown>
        <thead>
          <tr>
            <th scope="col" abbr="Monday" class="loon-calendar-weekday"> Mo </th>
            <th scope="col" abbr="Tuesday" class="loon-calendar-weekday"> Tu </th>
            <th scope="col" abbr="Wednesday" class="loon-calendar-weekday"> We </th>
            <th scope="col" abbr="Thursday" class="loon-calendar-weekday"> Th </th>
            <th scope="col" abbr="Friday" class="loon-calendar-weekday"> Fr </th>
            <th scope="col" abbr="Saturday" class="loon-calendar-weekday"> Sa </th>
            <th scope="col" abbr="Sunday" class="loon-calendar-weekday"> Su </th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-26"
                      aria-label="Monday, 26 October 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 26 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-27"
                      aria-label="Tuesday, 27 October 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 27 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-28"
                      aria-label="Wednesday, 28 October 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 28 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-29"
                      aria-label="Thursday, 29 October 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 29 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-30"
                      aria-label="Friday, 30 October 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 30 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-10-31"
                      aria-label="Saturday, 31 October 2026"
                      tabindex="-1"
                      data-outside=""
                      aria-disabled="true"
                      class="loon-calendar-day"> 31 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-01"
                      aria-label="Sunday, 1 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 1 </button>
            </td>
          </tr>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-02"
                      aria-label="Monday, 2 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 2 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-03"
                      aria-label="Tuesday, 3 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 3 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-04"
                      aria-label="Wednesday, 4 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 4 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-05"
                      aria-label="Thursday, 5 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 5 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-06"
                      aria-label="Friday, 6 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 6 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-07"
                      aria-label="Saturday, 7 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 7 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-08"
                      aria-label="Sunday, 8 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 8 </button>
            </td>
          </tr>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-09"
                      aria-label="Monday, 9 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 9 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-10"
                      aria-label="Tuesday, 10 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 10 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-11"
                      aria-label="Wednesday, 11 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 11 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-12"
                      aria-label="Thursday, 12 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 12 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-13"
                      aria-label="Friday, 13 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 13 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-14"
                      aria-label="Saturday, 14 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 14 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-15"
                      aria-label="Sunday, 15 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 15 </button>
            </td>
          </tr>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-16"
                      aria-label="Monday, 16 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 16 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-17"
                      aria-label="Tuesday, 17 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 17 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-18"
                      aria-label="Wednesday, 18 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 18 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-19"
                      aria-label="Thursday, 19 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 19 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-20"
                      aria-label="Friday, 20 November 2026"
                      tabindex="0"
                      aria-current="date"
                      class="loon-calendar-day"
                      @on_click> 20 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-21"
                      aria-label="Saturday, 21 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 21 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-22"
                      aria-label="Sunday, 22 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 22 </button>
            </td>
          </tr>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-23"
                      aria-label="Monday, 23 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 23 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-24"
                      aria-label="Tuesday, 24 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 24 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-25"
                      aria-label="Wednesday, 25 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 25 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-26"
                      aria-label="Thursday, 26 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 26 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-27"
                      aria-label="Friday, 27 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 27 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-28"
                      aria-label="Saturday, 28 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 28 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-29"
                      aria-label="Sunday, 29 November 2026"
                      tabindex="-1"
                      aria-disabled="true"
                      class="loon-calendar-day"> 29 </button>
            </td>
          </tr>
          <tr>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-11-30"
                      aria-label="Monday, 30 November 2026"
                      tabindex="-1"
                      class="loon-calendar-day"
                      @on_click> 30 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-01"
                      aria-label="Tuesday, 1 December 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 1 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-02"
                      aria-label="Wednesday, 2 December 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 2 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-03"
                      aria-label="Thursday, 3 December 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 3 </button>
            </td>
            <td role="gridcell" aria-selected="false" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-04"
                      aria-label="Friday, 4 December 2026"
                      tabindex="-1"
                      data-outside=""
                      class="loon-calendar-day"
                      @on_click> 4 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-05"
                      aria-label="Saturday, 5 December 2026"
                      tabindex="-1"
                      data-outside=""
                      aria-disabled="true"
                      class="loon-calendar-day"> 5 </button>
            </td>
            <td role="gridcell" aria-selected="false" aria-disabled="true" class="loon-calendar-cell">
              <button type="button"
                      id="loonbonsai_path_replaced_in_test-day-2026-12-06"
                      aria-label="Sunday, 6 December 2026"
                      tabindex="-1"
                      data-outside=""
                      aria-disabled="true"
                      class="loon-calendar-day"> 6 </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    |}]
;;

let%expect_test "picking, keys and months" =
  let handle =
    Bonsai_web_test.Handle.create (Bonsai_web_test.Result_spec.vdom get_vdom) (component ())
  in
  let selected () =
    Handle.recompute_view handle;
    print_s [%sexp ((Handle.last_result handle).selected : Date.t option)] in
  let caption () =
    Handle.recompute_view handle;
    Render.html ~selector:".loon-calendar-caption" (get_vdom (Handle.last_result handle))
  in
  Handle.click_on handle ~get_vdom ~selector:"[id$=day-2026-11-24]";
  selected ();
  [%expect {| (2026-11-24) |}];
  (* weekends can't be picked *)
  Render.html ~selector:"[id$=day-2026-11-22]" (get_vdom (Handle.last_result handle));
  [%expect {|
    <button type="button"
            id="loonbonsai_path_replaced_in_test-day-2026-11-22"
            aria-label="Sunday, 22 November 2026"
            tabindex="-1"
            aria-disabled="true"
            class="loon-calendar-day"> 22 </button>
    |}];
  Handle.keydown handle ~get_vdom ~selector:".loon-calendar-grid" ~key:ArrowDown;
  Handle.keydown handle ~get_vdom ~selector:".loon-calendar-grid" ~key:ArrowDown;
  caption ();
  Handle.recompute_view handle;
  Render.html ~selector:"[tabindex='0']" (get_vdom (Handle.last_result handle));
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    <div id="loonbonsai_path_replaced_in_test-caption"
         aria-live="polite"
         class="loon-calendar-caption"> December 2026 </div>
    <button type="button"
            id="loonbonsai_path_replaced_in_test-day-2026-12-08"
            aria-label="Tuesday, 8 December 2026"
            tabindex="0"
            class="loon-calendar-day"
            @on_click> 8 </button>
    |}];
  Handle.click_on handle ~get_vdom ~selector:"[aria-label='Previous month']";
  Handle.click_on handle ~get_vdom ~selector:"[aria-label='Previous month']";
  caption ();
  (* not before [min] *)
  Render.html ~selector:"[aria-label='Previous month']" (get_vdom (Handle.last_result handle));
  Handle.recompute_view handle;
  Render.html ~selector:"[tabindex='0']" (get_vdom (Handle.last_result handle));
  [%expect {|
    <div id="loonbonsai_path_replaced_in_test-caption"
         aria-live="polite"
         class="loon-calendar-caption"> October 2026 </div>
    <button type="button" aria-label="Previous month" disabled="" class="loon-calendar-nav">
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-left">
        <path d="m15 18-6-6 6-6"> </path>
      </svg>
    </button>
    <button type="button"
            id="loonbonsai_path_replaced_in_test-day-2026-10-15"
            aria-label="Thursday, 15 October 2026"
            tabindex="0"
            class="loon-calendar-day"
            @on_click> 15 </button>
    |}];
  Handle.keydown handle ~get_vdom ~selector:".loon-calendar-grid" ~key:PageUp;
  Handle.recompute_view handle;
  Render.html ~selector:"[tabindex='0']" (get_vdom (Handle.last_result handle));
  [%expect {|
    ("default prevented" (key PageUp))
    <button type="button"
            id="loonbonsai_path_replaced_in_test-day-2026-10-15"
            aria-label="Thursday, 15 October 2026"
            tabindex="0"
            class="loon-calendar-day"
            @on_click> 15 </button>
    |}]
;;
