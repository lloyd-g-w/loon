open! Core
module Block = Loon_blocks.Block

let%expect_test "every block, with its categories" =
  List.iter Block.all ~f:(fun (b : Block.t) ->
    printf
      "%s [%s] %s\n"
      b.name
      (String.concat ~sep:", " (List.map b.categories ~f:Block.Category.name))
      b.description);
  [%expect
    {|
    dashboard-01 [Dashboard] A dashboard with sidebar, charts and data table.
    sidebar-01 [Sidebar, Dashboard] A simple sidebar with navigation grouped by section.
    sidebar-02 [Sidebar, Dashboard] A sidebar with collapsible sections.
    sidebar-03 [Sidebar, Dashboard] A sidebar with submenus.
    sidebar-04 [Sidebar, Dashboard] A floating sidebar with submenus.
    sidebar-05 [Sidebar, Dashboard] A sidebar with collapsible submenus.
    sidebar-06 [Sidebar, Dashboard] A sidebar with submenus as dropdowns.
    sidebar-07 [Sidebar, Dashboard] A sidebar that collapses to icons.
    sidebar-08 [Sidebar, Dashboard] An inset sidebar with secondary navigation.
    sidebar-09 [Sidebar, Dashboard] Collapsible nested sidebars.
    sidebar-10 [Sidebar, Dashboard] A sidebar in a popover.
    sidebar-11 [Sidebar, Dashboard] A sidebar with a collapsible file tree.
    sidebar-12 [Sidebar, Dashboard] A sidebar with a calendar.
    sidebar-13 [Sidebar, Dashboard] A sidebar in a dialog.
    sidebar-14 [Sidebar, Dashboard] A sidebar on the right.
    sidebar-15 [Sidebar, Dashboard] A left and right sidebar.
    sidebar-16 [Sidebar, Dashboard] A sidebar with a sticky site header.
    login-01 [Authentication, Login] A simple login form.
    login-02 [Authentication, Login] A two column login page with a cover image.
    login-03 [Authentication, Login] A login page with a muted background color.
    login-04 [Authentication, Login] A login page with form and image.
    login-05 [Authentication, Login] A simple email-only login page.
    signup-01 [Authentication, Signup] A simple signup form.
    signup-02 [Authentication, Signup] A two column signup page with a cover image.
    signup-03 [Authentication, Signup] A signup page with a muted background color.
    signup-04 [Authentication, Signup] A signup page with form and image.
    signup-05 [Authentication, Signup] A simple signup form with social providers.
    calendar-01 [Calendar] A simple calendar.
    calendar-02 [Calendar] Multiple months with single selection.
    calendar-03 [Calendar] Multiple months with multiple selection.
    calendar-04 [Calendar] Single month with range selection
    calendar-05 [Calendar] Multiple months with range selection
    calendar-06 [Calendar] Range selection with minimum days
    calendar-07 [Calendar] Range selection with minimum and maximum days
    calendar-08 [Calendar] Calendar with disabled days
    calendar-09 [Calendar] Calendar with disabled weekends
    calendar-10 [Calendar] Today button
    calendar-11 [Calendar] Start and end of month
    calendar-12 [Calendar] Localized calendar
    calendar-13 [Calendar] With Month and Year Dropdown
    calendar-14 [Calendar] With Booked/Unavailable Days
    calendar-15 [Calendar] With Week Numbers
    calendar-16 [Calendar] With time picker
    calendar-17 [Calendar] With time picker inline
    calendar-18 [Calendar] Variable size
    calendar-19 [Calendar] With presets
    calendar-20 [Calendar] With time presets
    calendar-21 [Calendar] Custom days and formatters
    calendar-22 [Calendar] Date picker
    calendar-23 [Calendar] Date range picker
    calendar-24 [Calendar] Date and Time picker
    calendar-25 [Calendar] Date and Time range picker
    calendar-26 [Calendar] Date range picker with time
    calendar-27 [Calendar] Chart filter
    calendar-28 [Calendar] Input with date picker
    calendar-29 [Calendar] Natural language date picker
    calendar-30 [Calendar] With little-date
    calendar-31 [Calendar] With event slots
    calendar-32 [Calendar] Date picker in a drawer
    |}]
;;

let%expect_test "featured" =
  print_endline
    (String.concat
       ~sep:" "
       (List.map Block.featured ~f:(fun (b : Block.t) -> b.name)));
  [%expect {| dashboard-01 sidebar-07 sidebar-03 login-03 login-04 |}]
;;
