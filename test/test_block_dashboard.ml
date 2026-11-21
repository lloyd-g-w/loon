open! Core
module Handle = Bonsai_web_test.Handle

let block = Option.value_exn (Loon_blocks.Block.find "dashboard-01")

let%expect_test "dashboard-01 renders" =
  Block_summary.show (Block_summary.handle "dashboard-01");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x6
      sidebar-menu-item x15
      sidebar-menu-button x14
      sidebar-content
      sidebar-group x3
      sidebar-group-content x2
      button x17
      sidebar-group-label
      dropdown-menu-trigger x15
      sidebar-footer
      avatar
      avatar-image
      avatar-fallback
      sidebar-inset
      sidebar-trigger
      separator
      card x5
      card-header x5
      card-description x5
      card-title x5
      card-action x5
      badge x26
      card-footer x4
      toggle-group
      toggle-group-item x3
      select-trigger x6
      select-value x6
      card-content
      chart
      tabs
      label x25
      tabs-list
      tabs-trigger x4
      tabs-content x4
      table-container
      table
      table-header
      table-row x11
      table-head x9
      checkbox x11
      table-body
      table-cell x90
      drawer-trigger x10
      input x20
    text:
      Acme Inc. Quick Create Inbox Dashboard Lifecycle Analytics Projects Team
      Documents Data Library More Reports More Word Assistant More More Settings
      Get Help Search CN shadcn m@example.com Toggle Sidebar Documents GitHub
      Total Revenue $1,250.00 +12.5% Trending up this month Visitors for the last
      6 months New Customers 1,234 -20% Down 20% this period Acquisition needs
      attention Active Accounts 45,678 +12.5% Strong user retention Engagement
      exceed targets Growth Rate 4.5% +4.5% Steady performance increase Meets
      growth projections Total Visitors Total for the last 3 months Last 3 months
      Last 3 months Last 30 days Last 7 days Last 3 months
      [data-chart=chart-bonsai_path_y_x_x_x_x] { --color-desktop: var(--primary);
      --color-mobile: var(--primary); } .dark
      [data-chart=chart-bonsai_path_y_x_x_x_x] { --color-desktop: var(--primary);
      --color-mobile: var(--primary); } Apr 6 Apr 26 May 17 Jun 6 Jun 30 View
      Outline Outline Past Performance 3 Key Personnel 2 Focus Documents Customize
      Columns Columns Add Section To pick up a draggable item, press the space
      bar. While dragging, use the arrow keys to move the item. Press space again
      to drop the item in its new position, or press escape to cancel. Header
      Section Type Status Target Limit Reviewer Drag to reorder Cover page Cover
      page In Process Target Limit Eddie Lake Open menu Drag to reorder Table of
      contents Table of contents Done Target Limit Eddie Lake Open menu Drag to
      reorder Executive summary Narrative Done Target Limit Eddie Lake Open menu
      Drag to reorder Technical approach Narrative Done Target Limit Jamik
      Tashpulatov Open menu Drag to reorder Design Narrative In Process Target
      Limit Jamik Tashpulatov Open menu Drag to reorder Capabilities Narrative In
      Process Target Limit Jamik Tashpulatov Open menu Drag to reorder Integration
      with existing systems Narrative In Process Target Limit Jamik Tashpulatov
      Open menu Drag to reorder Innovation and Advantages Narrative Done Target
      Limit Reviewer Assign reviewer Open menu Drag to reorder Overview of EMR's
      Innovative Solutions Technical content Done Target Limit Reviewer Assign
      reviewer Open menu Drag to reorder Advanced Algorithms and Machine Learning
      Narrative Done Target Limit Reviewer Assign reviewer Open menu 0 of 68
      row(s) selected. Rows per page 10 Page 1 of 7 Go to first page Go to
      previous page Go to next page Go to last page
    |}]
;;

module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let rec text : Node_helpers.t -> string = function
  | Text s -> s
  | Widget -> ""
  | Element e -> String.concat ~sep:" " (List.map e.children ~f:text)
;;

let squash s =
  String.split_on_chars s ~on:[ ' '; '\n' ]
  |> List.filter ~f:(Fn.non String.is_empty)
  |> String.concat ~sep:" "
;;

(* The table's state: its headers, the first rows' header cells (checked
   ones starred), the selection count and the page. *)
let table handle =
  let node = Node_helpers.unsafe_convert_exn (Handle.last_result handle) in
  let select selector = Node_helpers.select node ~selector in
  let first selector = List.hd_exn (select selector) in
  let heads =
    select "[data-slot=tabs-content][data-state=active] thead th"
    |> List.map ~f:(fun th -> squash (text th))
    |> List.filter ~f:(Fn.non String.is_empty)
  in
  printf "columns: %s\n" (String.concat ~sep:", " heads);
  List.iter
    (List.take
       (select "[data-slot=tabs-content][data-state=active] tbody tr")
       3)
    ~f:(fun tr ->
      let cells = Node_helpers.select tr ~selector:"td" in
      let checked =
        not
          (List.is_empty
             (Node_helpers.select
                tr
                ~selector:"[aria-label='Select row'][data-state=checked]"))
      in
      printf
        "  %s%s\n"
        (if checked then "* " else "")
        (squash (text (List.nth_exn cells 2))));
  let footer =
    squash
      (text
         (first "[data-slot=tabs-content][data-state=active] > div:last-child"))
  in
  print_endline footer
;;

let click handle selector =
  Handle.click_on handle ~get_vdom:Fn.id ~selector;
  Handle.recompute_view handle
;;

let%expect_test "data table: selection, pagination, column visibility" =
  let handle = Render.handle ~classes:false block.view in
  table handle;
  [%expect
    {|
    columns: Header, Section Type, Status, Target, Limit, Reviewer
      Cover page
      Table of contents
      Executive summary
    0 of 68 row(s) selected. Rows per page 10 Page 1 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}];
  click handle "tbody tr:nth-child(2) [aria-label='Select row']";
  table handle;
  [%expect
    {|
    columns: Header, Section Type, Status, Target, Limit, Reviewer
      Cover page
      * Table of contents
      Executive summary
    1 of 68 row(s) selected. Rows per page 10 Page 1 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}];
  (* Go to next page *)
  click
    handle
    "[data-slot=tabs-content][data-state=active] > div:last-child > div > \
     div:last-child > button:nth-child(3)";
  table handle;
  [%expect
    {|
    columns: Header, Section Type, Status, Target, Limit, Reviewer
      Adaptive Communication Protocols
      Advantages Over Current Technologies
      Past Performance
    1 of 68 row(s) selected. Rows per page 10 Page 2 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}];
  click
    handle
    "[data-slot=tabs] > div:first-child [data-slot=dropdown-menu-trigger]";
  click handle "[data-slot=dropdown-menu-checkbox-item]:nth-child(2)";
  table handle;
  [%expect
    {|
    columns: Header, Section Type, Target, Limit, Reviewer
      Adaptive Communication Protocols
      Advantages Over Current Technologies
      Past Performance
    1 of 68 row(s) selected. Rows per page 10 Page 2 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}]
;;

let%expect_test "data table: reordering rows by keyboard" =
  let handle = Render.handle ~classes:false block.view in
  let key key =
    Handle.keydown
      handle
      ~get_vdom:Fn.id
      ~selector:"tbody tr:nth-child(1) [aria-roledescription=sortable]"
      ~key;
    Handle.recompute_view handle
  in
  key Space;
  key ArrowDown;
  key ArrowDown;
  table handle;
  [%expect
    {|
    ("default prevented" (key Space))
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    columns: Header, Section Type, Status, Target, Limit, Reviewer
      Cover page
      Table of contents
      Executive summary
    0 of 68 row(s) selected. Rows per page 10 Page 1 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}];
  key Space;
  table handle;
  [%expect
    {|
    ("default prevented" (key Space))
    columns: Header, Section Type, Status, Target, Limit, Reviewer
      Table of contents
      Executive summary
      Cover page
    0 of 68 row(s) selected. Rows per page 10 Page 1 of 7 Go to first page Go to previous page Go to next page Go to last page
    |}]
;;

let%expect_test "chart: the time range" =
  let handle = Render.handle ~classes:false block.view in
  let ticks () =
    let node = Node_helpers.unsafe_convert_exn (Handle.last_result handle) in
    Node_helpers.select node ~selector:"[data-slot=toggle-group-item]"
    |> List.iter ~f:(fun n ->
      match n with
      | Element e ->
        printf
          "%s %s\n"
          (squash (text n))
          (Option.value
             ~default:""
             (List.Assoc.find e.attributes "data-state" ~equal:String.equal))
      | _ -> ());
    Node_helpers.select
      node
      ~selector:"[data-slot=card-action] [data-slot=select-value]"
    |> List.iter ~f:(fun n -> printf "select: %s\n" (squash (text n)))
  in
  ticks ();
  [%expect
    {|
    Last 3 months on
    Last 30 days off
    Last 7 days off
    select: Last 3 months
    |}];
  click handle "[data-slot=toggle-group-item]:nth-child(3)";
  ticks ();
  [%expect
    {|
    Last 3 months off
    Last 30 days off
    Last 7 days on
    select: Last 7 days
    |}]
;;
