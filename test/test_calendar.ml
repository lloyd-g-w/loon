open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let date = Date.of_string
let today = date "2025-06-12"

let%expect_test "shadcn's classes" =
  (* February 2026 starts on a Sunday and fills four weeks. *)
  let node =
    Calendar.view
      ~today
      ~month:(date "2026-02-01")
      ~on_month_change:(fun _ -> Bonsai_web.Effect.Ignore)
      ~focused:None
      ~on_focus:(fun _ -> Bonsai_web.Effect.Ignore)
      ~selected:(Single (Some (date "2026-02-03")))
      ~on_select:(fun _ -> Bonsai_web.Effect.Ignore)
      ~disabled:(fun d -> Date.equal d (date "2026-02-04"))
      ()
  in
  (* The root's own attributes, then a part of each kind (the first lines
     of those whose children follow). *)
  let module H = Virtual_dom_test_helpers.Node_helpers in
  let tree = H.unsafe_convert_exn node in
  List.iter
    [ "[data-slot=calendar]", 4
    ; ".rdp-months", 1
    ; ".rdp-nav", 100
    ; ".rdp-month", 1
    ; ".rdp-month_caption", 100
    ; "table", 4
    ; "thead", 1
    ; "tr.rdp-weekdays", 1
    ; "th[aria-label=Sunday]", 100
    ; "tbody", 1
    ; "tr.rdp-week", 1
    ; "td[data-day='2026-02-03']", 100
    ; "td[data-day='2026-02-04']", 100
    ]
    ~f:(fun (selector, n) ->
      let element = List.hd_exn (H.select tree ~selector) in
      H.to_string_html element
      |> String.split_lines
      |> Fn.flip List.take n
      |> List.iter ~f:print_endline);
  [%expect {|
    <div data-slot="calendar"
         id="calendar"
         data-mode="single"
         class="bg-background cn-calendar group/calendar in-data-[slot=card-content]:bg-transparent in-data-[slot=popover-content]:bg-transparent rdp-root rtl:**:[.rdp-button\_next>svg]:rotate-180 rtl:**:[.rdp-button\_previous>svg]:rotate-180 w-fit">
    <div class="flex flex-col gap-4 md:flex-row rdp-months relative">
    <nav aria-label="Navigation bar"
         class="absolute flex gap-1 inset-x-0 items-center justify-between rdp-nav top-0 w-full">
      <button type="button"
              aria-label="Go to the Previous Month"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 aria-disabled:opacity-50 cn-button cn-button-size-default cn-button-variant-ghost disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none p-0 rdp-button_previous select-none shrink-0 size-(--cell-size) transition-all whitespace-nowrap"
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
             class="cn-rtl-flip lucide lucide-chevron-left rdp-chevron size-4">
          <path d="m15 18-6-6 6-6"> </path>
        </svg>
      </button>
      <button type="button"
              aria-label="Go to the Next Month"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 aria-disabled:opacity-50 cn-button cn-button-size-default cn-button-variant-ghost disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none p-0 rdp-button_next select-none shrink-0 size-(--cell-size) transition-all whitespace-nowrap"
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
             class="cn-rtl-flip lucide lucide-chevron-right rdp-chevron size-4">
          <path d="m9 18 6-6-6-6"> </path>
        </svg>
      </button>
    </nav>
    <div class="flex flex-col gap-4 rdp-month w-full">
    <div class="flex h-(--cell-size) items-center justify-center px-(--cell-size) rdp-month_caption w-full">
      <span role="status"
            aria-live="polite"
            class="cn-calendar-caption font-medium rdp-caption_label select-none text-sm"> February 2026 </span>
    </div>
    <table role="grid"
           aria-multiselectable="false"
           aria-label="February 2026"
           class="border-collapse rdp-month_grid w-full">
    <thead aria-hidden="true">
    <tr class="flex rdp-weekdays">
    <th aria-label="Sunday"
        scope="col"
        class="flex-1 font-normal rdp-weekday rounded-(--cell-radius) select-none text-[0.8rem] text-muted-foreground"> Su </th>
    <tbody class="rdp-weeks">
    <tr class="flex mt-2 rdp-week w-full">
    <td role="gridcell"
        aria-selected="true"
        data-day="2026-02-03"
        data-selected="true"
        class="[&:first-child[data-selected=true]_button]:rounded-l-(--cell-radius) [&:last-child[data-selected=true]_button]:rounded-r-(--cell-radius) aspect-square group/day h-full p-0 rdp-day rdp-selected relative rounded-(--cell-radius) select-none text-center w-full">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              data-day="2/3/2026"
              data-selected-single="true"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="0"
              aria-label="Tuesday, February 3rd, 2026, selected"
              class="[&>span]:opacity-70 [&>span]:text-xs [&_svg]:pointer-events-none [&_svg]:shrink-0 aspect-square border-0 cn-button cn-button-size-icon cn-button-variant-ghost cn-calendar-day-button dark:hover:text-foreground data-[range-end=true]:bg-primary data-[range-end=true]:rounded-(--cell-radius) data-[range-end=true]:rounded-r-(--cell-radius) data-[range-end=true]:text-primary-foreground data-[range-middle=true]:bg-muted data-[range-middle=true]:rounded-none data-[range-middle=true]:text-foreground data-[range-start=true]:bg-primary data-[range-start=true]:rounded-(--cell-radius) data-[range-start=true]:rounded-l-(--cell-radius) data-[range-start=true]:text-primary-foreground data-[selected-single=true]:bg-primary data-[selected-single=true]:text-primary-foreground disabled:opacity-50 disabled:pointer-events-none flex flex-col font-normal gap-1 group-data-[focused=true]/day:border-ring group-data-[focused=true]/day:relative group-data-[focused=true]/day:ring-[3px] group-data-[focused=true]/day:ring-ring/50 group-data-[focused=true]/day:z-10 group/button isolate items-center justify-center leading-none min-w-(--cell-size) outline-none rdp-day rdp-day_button relative select-none shrink-0 size-auto transition-all w-full whitespace-nowrap z-10"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 3 </button>
    </td>
    <td role="gridcell"
        data-day="2026-02-04"
        data-disabled="true"
        class="[&:first-child[data-selected=true]_button]:rounded-l-(--cell-radius) [&:last-child[data-selected=true]_button]:rounded-r-(--cell-radius) aspect-square group/day h-full opacity-50 p-0 rdp-day rdp-disabled relative rounded-(--cell-radius) select-none text-center text-muted-foreground w-full">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              disabled=""
              data-day="2/4/2026"
              data-selected-single="false"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="-1"
              aria-label="Wednesday, February 4th, 2026"
              class="[&>span]:opacity-70 [&>span]:text-xs [&_svg]:pointer-events-none [&_svg]:shrink-0 aspect-square border-0 cn-button cn-button-size-icon cn-button-variant-ghost cn-calendar-day-button dark:hover:text-foreground data-[range-end=true]:bg-primary data-[range-end=true]:rounded-(--cell-radius) data-[range-end=true]:rounded-r-(--cell-radius) data-[range-end=true]:text-primary-foreground data-[range-middle=true]:bg-muted data-[range-middle=true]:rounded-none data-[range-middle=true]:text-foreground data-[range-start=true]:bg-primary data-[range-start=true]:rounded-(--cell-radius) data-[range-start=true]:rounded-l-(--cell-radius) data-[range-start=true]:text-primary-foreground data-[selected-single=true]:bg-primary data-[selected-single=true]:text-primary-foreground disabled:opacity-50 disabled:pointer-events-none flex flex-col font-normal gap-1 group-data-[focused=true]/day:border-ring group-data-[focused=true]/day:relative group-data-[focused=true]/day:ring-[3px] group-data-[focused=true]/day:ring-ring/50 group-data-[focused=true]/day:z-10 group/button isolate items-center justify-center leading-none min-w-(--cell-size) outline-none rdp-day rdp-day_button relative select-none shrink-0 size-auto transition-all w-full whitespace-nowrap z-10"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 4 </button>
    </td>
    |}]
;;

let%expect_test "weeks and week numbers" =
  let show ?fixed_weeks ?week_starts_on month =
    Calendar.weeks ?fixed_weeks ?week_starts_on (date month)
    |> List.iter ~f:(fun week ->
      printf "%02d |" (Calendar.week_number (List.hd_exn week));
      List.iter week ~f:(fun d -> printf " %2d" (Date.day d));
      print_endline "")
  in
  show "2025-06-09";
  [%expect {|
    23 |  1  2  3  4  5  6  7
    24 |  8  9 10 11 12 13 14
    25 | 15 16 17 18 19 20 21
    26 | 22 23 24 25 26 27 28
    27 | 29 30  1  2  3  4  5
    |}];
  show ~fixed_weeks:true "2026-02-01";
  [%expect {|
    06 |  1  2  3  4  5  6  7
    07 |  8  9 10 11 12 13 14
    08 | 15 16 17 18 19 20 21
    09 | 22 23 24 25 26 27 28
    10 |  1  2  3  4  5  6  7
    11 |  8  9 10 11 12 13 14
    |}];
  show ~week_starts_on:Mon "2025-12-01";
  [%expect {|
    49 |  1  2  3  4  5  6  7
    50 |  8  9 10 11 12 13 14
    51 | 15 16 17 18 19 20 21
    52 | 22 23 24 25 26 27 28
    01 | 29 30 31  1  2  3  4
    |}]
;;

let%expect_test "format" =
  List.iter
    [ "PPPP"; "PPP"; "PP"; "P"; "LLL dd, y"; "LLLL y"; "EEE do 'of' MMMM"; "yyyy-MM-dd" ]
    ~f:(fun pattern -> print_endline (Calendar.format pattern (date "2025-06-09")));
  [%expect {|
    Monday, June 9th, 2025
    June 9th, 2025
    Jun 9, 2025
    06/09/2025
    Jun 09, 2025
    June 2025
    Mon 9th of June
    2025-06-09
    |}];
  List.iter [ 1; 2; 3; 4; 11; 12; 13; 21; 22; 23; 31 ] ~f:(fun d ->
    printf "%s " (Calendar.format "do" (Date.create_exn ~y:2025 ~m:Jan ~d)));
  [%expect {| 1st 2nd 3rd 4th 11th 12th 13th 21st 22nd 23rd 31st |}]
;;

let%expect_test "select, as react-day-picker" =
  let show s = print_s [%sexp (s : Calendar.Selection.t)] in
  let d = date in
  show (Calendar.select (Single None) (d "2025-06-09"));
  show (Calendar.select (Single (Some (d "2025-06-09"))) (d "2025-06-09"));
  show (Calendar.select ~required:true (Single (Some (d "2025-06-09"))) (d "2025-06-09"));
  [%expect {|
    (Single (2025-06-09))
    (Single ())
    (Single (2025-06-09))
    |}];
  show (Calendar.select (Multiple [ d "2025-06-01" ]) (d "2025-06-09"));
  show (Calendar.select (Multiple [ d "2025-06-01"; d "2025-06-09" ]) (d "2025-06-01"));
  show (Calendar.select ~max:1 (Multiple [ d "2025-06-01" ]) (d "2025-06-09"));
  [%expect {|
    (Multiple (2025-06-01 2025-06-09))
    (Multiple (2025-06-09))
    (Multiple (2025-06-01))
    |}];
  (* Range: a first click picks one day, the next extends it either way. *)
  let r = Calendar.select (Range None) (d "2025-06-09") in
  show r;
  let r = Calendar.select r (d "2025-06-12") in
  show r;
  show (Calendar.select r (d "2025-06-02"));
  show (Calendar.select r (d "2025-06-20"));
  show (Calendar.select r (d "2025-06-09"));
  show (Calendar.select ~max:5 r (d "2025-06-20"));
  [%expect {|
    (Range (((from 2025-06-09) (to_ (2025-06-09)))))
    (Range (((from 2025-06-09) (to_ (2025-06-12)))))
    (Range (((from 2025-06-02) (to_ (2025-06-12)))))
    (Range (((from 2025-06-09) (to_ (2025-06-20)))))
    (Range (((from 2025-06-09) (to_ (2025-06-09)))))
    (Range (((from 2025-06-20) (to_ ()))))
    |}]
;;

let%expect_test "moved" =
  let d = date "2025-01-31" in
  List.iter
    Js_of_ocaml.Dom_html.Keyboard_code.
      [ "left", ArrowLeft, false
      ; "right", ArrowRight, false
      ; "up", ArrowUp, false
      ; "down", ArrowDown, false
      ; "home", Home, false
      ; "end", End, false
      ; "pageup", PageUp, false
      ; "pagedown", PageDown, false
      ; "shift+pagedown", PageDown, true
      ]
    ~f:(fun (name, key, shift) ->
      printf
        "%s: %s\n"
        name
        (Option.value_map (Calendar.moved ~shift ~key d) ~default:"-" ~f:Date.to_string));
  [%expect {|
    left: 2025-01-30
    right: 2025-02-01
    up: 2025-01-24
    down: 2025-02-07
    home: 2025-01-26
    end: 2025-02-01
    pageup: 2024-12-31
    pagedown: 2025-02-28
    shift+pagedown: 2026-01-31
    |}]
;;

let component ?caption_layout ?show_week_number ?number_of_months ?disabled ~default () =
  Render.handle ~classes:false (fun graph ->
    let calendar =
      Calendar.component
        ?caption_layout
        ?show_week_number
        ?number_of_months
        ?disabled
        ~today
        ~default
        graph
    in
    let open Bonsai_web.Bonsai.Let_syntax in
    let%arr calendar in
    Node.div
      [ calendar.view
      ; Node.p
          [ Node.text
              (Sexp.to_string_hum [%sexp (calendar.selected : Calendar.Selection.t)])
          ]
      ])
;;

(* The parts of the calendar a test looks at. *)
let show
  ?(selectors =
    [ ".rdp-caption_label"; "td[data-focused]"; "p" ])
  handle
  =
  Handle.recompute_view handle;
  List.iter selectors ~f:(fun selector ->
    Render.html ~classes:false ~selector (Handle.last_result handle))
;;

let%expect_test "clicking a day selects it; keys move the focus, across months" =
  let handle = component ~default:(Single None) () in
  (* Today is the focus target at first. *)
  show handle;
  [%expect {|
    <span role="status" aria-live="polite"> June 2025 </span>
    <p> (Single ()) </p>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"td[data-day='2025-06-09'] button";
  show handle;
  [%expect {|
    <span role="status" aria-live="polite"> June 2025 </span>
    <td role="gridcell"
        aria-selected="true"
        data-day="2025-06-09"
        data-selected="true"
        data-focused="true">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              data-day="6/9/2025"
              data-selected-single="true"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="0"
              aria-label="Monday, June 9th, 2025, selected"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 9 </button>
    </td>
    <p> (Single (2025-06-09)) </p>
    |}];
  Handle.keydown
    handle
    ~get_vdom:Fn.id
    ~selector:"td[data-day='2025-06-09'] button"
    ~key:PageDown;
  show handle;
  [%expect {|
    ("default prevented" (key PageDown))
    <span role="status" aria-live="polite"> July 2025 </span>
    <td role="gridcell" data-day="2025-07-09" data-focused="true">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              data-day="7/9/2025"
              data-selected-single="false"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="0"
              aria-label="Wednesday, July 9th, 2025"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 9 </button>
    </td>
    <p> (Single (2025-06-09)) </p>
    |}];
  Handle.keydown
    handle
    ~get_vdom:Fn.id
    ~selector:"td[data-day='2025-07-09'] button"
    ~key:ArrowUp;
  show handle ~selectors:[ ".rdp-caption_label"; "td[data-focused]" ];
  [%expect {|
    ("default prevented" (key ArrowUp))
    <span role="status" aria-live="polite"> July 2025 </span>
    <td role="gridcell" data-day="2025-07-02" data-focused="true">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              data-day="7/2/2025"
              data-selected-single="false"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="0"
              aria-label="Wednesday, July 2nd, 2025"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 2 </button>
    </td>
    |}];
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"button[aria-label='Go to the Previous Month']";
  show handle ~selectors:[ ".rdp-caption_label" ];
  [%expect {| <span role="status" aria-live="polite"> June 2025 </span> |}]
;;

let%expect_test "keys skip disabled days" =
  let handle =
    component
      ~disabled:(fun d ->
        match Date.day_of_week d with
        | Sat | Sun -> true
        | _ -> false)
      ~default:(Single (Some (date "2025-06-13")))
      ()
  in
  Handle.keydown
    handle
    ~get_vdom:Fn.id
    ~selector:"td[data-day='2025-06-13'] button"
    ~key:ArrowRight;
  show handle ~selectors:[ "td[data-focused]"; "td[data-day='2025-06-14']" ];
  [%expect {|
    ("default prevented" (key ArrowRight))
    <td role="gridcell" data-day="2025-06-16" data-focused="true">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              data-day="6/16/2025"
              data-selected-single="false"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="0"
              aria-label="Monday, June 16th, 2025"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 16 </button>
    </td>
    <td role="gridcell" data-day="2025-06-14" data-disabled="true">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="icon"
              disabled=""
              data-day="6/14/2025"
              data-selected-single="false"
              data-range-start="false"
              data-range-end="false"
              data-range-middle="false"
              tabindex="-1"
              aria-label="Saturday, June 14th, 2025"
              @on_blur
              @on_click
              @on_focus
              @on_keydown> 14 </button>
    </td>
    |}]
;;

let%expect_test "range over two months" =
  let handle = component ~number_of_months:2 ~default:(Range None) () in
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"td[data-day='2025-06-29']:not([data-outside]) button";
  Handle.recompute_view handle;
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"td[data-day='2025-07-02']:not([data-outside]) button";
  show
    handle
    ~selectors:
      [ "[data-slot=calendar]>div>.rdp-month .rdp-caption_label"
      ; "td[data-selected]:not([data-outside]) button[data-range-start=true]"
      ; "td[data-selected]:not([data-outside]) button[data-range-middle=true]"
      ; "td[data-selected]:not([data-outside]) button[data-range-end=true]"
      ; "p"
      ];
  [%expect {|
    <span role="status" aria-live="polite"> June 2025 </span>
    <span role="status" aria-live="polite"> July 2025 </span>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon"
            data-day="6/29/2025"
            data-selected-single="false"
            data-range-start="true"
            data-range-end="false"
            data-range-middle="false"
            tabindex="-1"
            aria-label="Sunday, June 29th, 2025, selected"
            @on_blur
            @on_click
            @on_focus
            @on_keydown> 29 </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon"
            data-day="6/30/2025"
            data-selected-single="false"
            data-range-start="false"
            data-range-end="false"
            data-range-middle="true"
            tabindex="-1"
            aria-label="Monday, June 30th, 2025, selected"
            @on_blur
            @on_click
            @on_focus
            @on_keydown> 30 </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon"
            data-day="7/1/2025"
            data-selected-single="false"
            data-range-start="false"
            data-range-end="false"
            data-range-middle="true"
            tabindex="-1"
            aria-label="Tuesday, July 1st, 2025, selected"
            @on_blur
            @on_click
            @on_focus
            @on_keydown> 1 </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon"
            data-day="7/2/2025"
            data-selected-single="false"
            data-range-start="false"
            data-range-end="true"
            data-range-middle="false"
            tabindex="0"
            aria-label="Wednesday, July 2nd, 2025, selected"
            @on_blur
            @on_click
            @on_focus
            @on_keydown> 2 </button>
    <p> (Range (((from 2025-06-29) (to_ (2025-07-02))))) </p>
    |}]
;;

let%expect_test "dropdown caption and week numbers" =
  let handle =
    component ~caption_layout:Dropdown ~show_week_number:true ~default:(Single None) ()
  in
  Handle.recompute_view handle;
  let module H = Virtual_dom_test_helpers.Node_helpers in
  let tree = H.unsafe_convert_exn (Handle.last_result handle) in
  List.concat_map
    [ ".rdp-dropdowns"; "thead tr"; ".rdp-week:first-child>td:first-child" ]
    ~f:(fun selector ->
      List.concat_map (H.select tree ~selector) ~f:(fun node ->
        String.split_lines
          (H.to_string_html
             ~filter_printed_attributes:(fun ~key ~data:_ -> not (String.equal key "class"))
             node)))
  (* Ten decades of years: only the first and last few. *)
  |> List.filter ~f:(fun line ->
    not
      (String.is_substring line ~substring:"<option"
       && not
            (List.exists [ "1925"; "1926"; "2024"; "2025"; "value=\"0\""; "value=\"11\"" ]
               ~f:(fun substring -> String.is_substring line ~substring))))
  |> List.iter ~f:print_endline;
  [%expect {|
    <div>
      <span>
        <select aria-label="Choose the Month" @on_change>
          <option #value="0" #selected="false"> Jan </option>
          <option #value="11" #selected="false"> Dec </option>
        </select>
        <span aria-hidden="true">
          Jun
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round">
            <path d="m6 9 6 6 6-6"> </path>
          </svg>
        </span>
      </span>
      <span>
        <select aria-label="Choose the Year" @on_change>
          <option #value="1925" #selected="false"> 1925 </option>
          <option #value="1926" #selected="false"> 1926 </option>
          <option #value="2024" #selected="false"> 2024 </option>
          <option #value="2025" #selected="true"> 2025 </option>
        </select>
        <span aria-hidden="true">
          2025
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round">
            <path d="m6 9 6 6 6-6"> </path>
          </svg>
        </span>
      </span>
      <span role="status"
            aria-live="polite"
            style="border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px; white-space: nowrap; word-wrap: normal"> June 2025 </span>
    </div>
    <tr>
      <th aria-label="Week Number" scope="col"> </th>
      <th aria-label="Sunday" scope="col"> Su </th>
      <th aria-label="Monday" scope="col"> Mo </th>
      <th aria-label="Tuesday" scope="col"> Tu </th>
      <th aria-label="Wednesday" scope="col"> We </th>
      <th aria-label="Thursday" scope="col"> Th </th>
      <th aria-label="Friday" scope="col"> Fr </th>
      <th aria-label="Saturday" scope="col"> Sa </th>
    </tr>
    <td aria-label="Week 23" role="rowheader" scope="row">
      <div> 23 </div>
    </td>
    |}];
  Handle.change handle ~get_vdom:Fn.id ~selector:".rdp-years_dropdown" ~value:"2001";
  Handle.recompute_view handle;
  Handle.change handle ~get_vdom:Fn.id ~selector:".rdp-months_dropdown" ~value:"1";
  show handle ~selectors:[ ".rdp-dropdowns [role=status]" ];
  [%expect {|
    <span role="status"
          aria-live="polite"
          style="border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px; white-space: nowrap; word-wrap: normal"> February 2001 </span>
    |}]
;;

let%expect_test "excludeDisabled: a range holding a disabled day starts again" =
  let weekend d =
    match Date.day_of_week d with
    | Sat | Sun -> true
    | _ -> false
  in
  let show s = print_s [%sexp (s : Calendar.Selection.t)] in
  let r =
    Calendar.Selection.Range
      (Some { from = date "2025-06-17"; to_ = Some (date "2025-06-20") })
  in
  show (Calendar.select ~excluded:weekend r (date "2025-06-19"));
  show (Calendar.select ~excluded:weekend r (date "2025-06-24"));
  [%expect {|
    (Range (((from 2025-06-17) (to_ (2025-06-19)))))
    (Range (((from 2025-06-24) (to_ ()))))
    |}]
;;

let%expect_test "locale, formatters, disabled navigation, initial month in bounds" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let open Bonsai_web.Bonsai.Let_syntax in
      let calendar =
        Calendar.component
          ~locale:Calendar.Locale.es
          ~format_weekday_name:(fun d ->
            (* 1 June 2025 is a Sunday. *)
            Calendar.format "EEE" (Date.add_days (date "2025-06-01") (Day_of_week.to_int d)))
          ~disable_navigation:true
          ~start_month:(date "2025-06-01")
          ~end_month:(date "2025-07-31")
          ~number_of_months:2
          ~today
          ~default_month:(date "2026-11-01")
          ~default:(Range None)
          graph
      in
      let%arr calendar in
      calendar.view)
  in
  Handle.recompute_view handle;
  List.iter
    [ ".rdp-nav"; ".rdp-caption_label"; "thead tr"; "td[data-day='2025-06-09'] button" ]
    ~f:(fun selector ->
      Render.html ~classes:false ~selector (Handle.last_result handle));
  [%expect {|
    <nav aria-label="Navigation bar">
      <button type="button"
              tabindex="-1"
              aria-disabled="true"
              aria-label="Go to the Previous Month"
              @on_click>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="m15 18-6-6 6-6"> </path>
        </svg>
      </button>
      <button type="button"
              tabindex="-1"
              aria-disabled="true"
              aria-label="Go to the Next Month"
              @on_click>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="m9 18 6-6-6-6"> </path>
        </svg>
      </button>
    </nav>
    <span role="status" aria-live="polite"> junio 2025 </span>
    <span role="status" aria-live="polite"> julio 2025 </span>
    <tr>
      <th aria-label="lunes" scope="col"> Mon </th>
      <th aria-label="martes" scope="col"> Tue </th>
      <th aria-label="miércoles" scope="col"> Wed </th>
      <th aria-label="jueves" scope="col"> Thu </th>
      <th aria-label="viernes" scope="col"> Fri </th>
      <th aria-label="sábado" scope="col"> Sat </th>
      <th aria-label="domingo" scope="col"> Sun </th>
    </tr>
    <tr>
      <th aria-label="lunes" scope="col"> Mon </th>
      <th aria-label="martes" scope="col"> Tue </th>
      <th aria-label="miércoles" scope="col"> Wed </th>
      <th aria-label="jueves" scope="col"> Thu </th>
      <th aria-label="viernes" scope="col"> Fri </th>
      <th aria-label="sábado" scope="col"> Sat </th>
      <th aria-label="domingo" scope="col"> Sun </th>
    </tr>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon"
            data-day="6/9/2025"
            data-selected-single="false"
            data-range-start="false"
            data-range-end="false"
            data-range-middle="false"
            tabindex="-1"
            aria-label="lunes, 9 de junio de 2025"
            @on_blur
            @on_click
            @on_focus
            @on_keydown> 9 </button>
    |}]
;;
