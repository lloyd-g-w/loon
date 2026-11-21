open! Core
module Handle = Bonsai_web_test.Handle

let%expect_test "sidebar-01" =
  Block_summary.show (Block_summary.handle "sidebar-01");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x5
      sidebar-menu-item x26
      dropdown-menu-trigger
      sidebar-group x5
      sidebar-group-content x5
      label
      input
      sidebar-content
      sidebar-group-label x4
      sidebar-menu-button x25
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.1 Search Getting Started Installation Project Structure
      Build Your Application Routing Data Fetching Rendering Caching Styling
      Optimizing Configuring Testing Authentication Deploying Upgrading Examples
      API Reference Components File Conventions Functions next.config.js Options
      CLI Edge Runtime Architecture Accessibility Fast Refresh Next.js Compiler
      Supported Browsers Turbopack Toggle Sidebar Build Your Application Data
      Fetching
    |}]
;;

let%expect_test "sidebar-02" =
  Block_summary.show (Block_summary.handle "sidebar-02");
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
      sidebar-menu-item x27
      dropdown-menu-trigger
      sidebar-group x6
      sidebar-group-content x6
      label
      input
      sidebar-content
      collapsible x5
      sidebar-group-label x5
      collapsible-content x5
      sidebar-menu-button x26
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.1 Search Getting Started Installation Project Structure
      Build Your Application Routing Data Fetching Rendering Caching Styling
      Optimizing Configuring Testing Authentication Deploying Upgrading Examples
      API Reference Components File Conventions Functions next.config.js Options
      CLI Edge Runtime Architecture Accessibility Fast Refresh Next.js Compiler
      Supported Browsers Turbopack Community Contribution Guide Toggle Sidebar
      Build Your Application Data Fetching
    |}]
;;

let%expect_test "sidebar-03" =
  Block_summary.show (Block_summary.handle "sidebar-03");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x2
      sidebar-menu-item x6
      sidebar-menu-button x6
      sidebar-content
      sidebar-group
      sidebar-menu-sub x5
      sidebar-menu-sub-item x26
      sidebar-menu-sub-button x26
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.0 Getting Started Installation Project Structure Build
      Your Application Routing Data Fetching Rendering Caching Styling Optimizing
      Configuring Testing Authentication Deploying Upgrading Examples API
      Reference Components File Conventions Functions next.config.js Options CLI
      Edge Runtime Architecture Accessibility Fast Refresh Next.js Compiler
      Supported Browsers Turbopack Community Contribution Guide Toggle Sidebar
      Build Your Application Data Fetching
    |}]
;;

let%expect_test "sidebar-04" =
  Block_summary.show (Block_summary.handle "sidebar-04");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x2
      sidebar-menu-item x6
      sidebar-menu-button x6
      sidebar-content
      sidebar-group
      sidebar-menu-sub x5
      sidebar-menu-sub-item x26
      sidebar-menu-sub-button x26
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.0 Getting Started Installation Project Structure Build
      Your Application Routing Data Fetching Rendering Caching Styling Optimizing
      Configuring Testing Authentication Deploying Upgrading Examples API
      Reference Components File Conventions Functions next.config.js Options CLI
      Edge Runtime Architecture Accessibility Fast Refresh Next.js Compiler
      Supported Browsers Turbopack Community Contribution Guide Toggle Sidebar
      Build Your Application Data Fetching
    |}]
;;

let%expect_test "sidebar-05" =
  Block_summary.show (Block_summary.handle "sidebar-05");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x2
      sidebar-menu-item x6
      sidebar-menu-button
      sidebar-group x2
      sidebar-group-content
      label
      input
      sidebar-content
      collapsible x5
      collapsible-trigger x5
      collapsible-content x5
      sidebar-menu-sub x5
      sidebar-menu-sub-item x26
      sidebar-menu-sub-button x26
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.0 Search Getting Started Installation Project Structure
      Build Your Application Routing Data Fetching Rendering Caching Styling
      Optimizing Configuring Testing Authentication Deploying Upgrading Examples
      API Reference Components File Conventions Functions next.config.js Options
      CLI Edge Runtime Architecture Accessibility Fast Refresh Next.js Compiler
      Supported Browsers Turbopack Community Contribution Guide Toggle Sidebar
      Build Your Application Data Fetching
    |}]
;;

let%expect_test "sidebar-06" =
  Block_summary.show (Block_summary.handle "sidebar-06");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x2
      sidebar-menu-item x5
      sidebar-menu-button
      sidebar-content
      sidebar-group
      dropdown-menu-trigger x4
      sidebar-footer
      card
      card-header
      card-title
      card-description
      card-content
      input
      button
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Documentation v1.0.0 Getting Started Build Your Application API Reference
      Architecture Subscribe to our newsletter Opt-in to receive updates and news
      about the sidebar. Subscribe Toggle Sidebar Build Your Application Data
      Fetching
    |}]
;;

let%expect_test "sidebar-07" =
  Block_summary.show (Block_summary.handle "sidebar-07");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x4
      sidebar-menu-item x6
      dropdown-menu-trigger x5
      sidebar-content
      sidebar-group x2
      sidebar-group-label x2
      collapsible x4
      collapsible-trigger x4
      collapsible-content x4
      sidebar-menu-sub x4
      sidebar-menu-sub-item x14
      sidebar-menu-sub-button x14
      sidebar-menu-button x4
      sidebar-footer
      avatar
      avatar-image
      avatar-fallback
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Acme Inc Enterprise Platform Playground History Starred Settings Models
      Genesis Explorer Quantum Documentation Introduction Get Started Tutorials
      Changelog Settings General Team Billing Limits Projects Design Engineering
      More Sales & Marketing More Travel More More CN shadcn m@example.com Toggle
      Sidebar Build Your Application Data Fetching
    |}]
;;

let%expect_test "sidebar-08" =
  Block_summary.show (Block_summary.handle "sidebar-08");
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x5
      sidebar-menu-item x8
      sidebar-menu-button x11
      sidebar-content
      sidebar-group x3
      sidebar-group-label x2
      collapsible x4
      collapsible-trigger x4
      collapsible-content x4
      sidebar-menu-sub x4
      sidebar-menu-sub-item x14
      sidebar-menu-sub-button x14
      dropdown-menu-trigger x4
      sidebar-group-content
      sidebar-footer
      avatar
      avatar-image
      avatar-fallback
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
    text:
      Acme Inc Enterprise Platform Playground Toggle History Starred Settings
      Models Toggle Genesis Explorer Quantum Documentation Toggle Introduction Get
      Started Tutorials Changelog Settings Toggle General Team Billing Limits
      Projects Design Engineering More Sales & Marketing More Travel More More
      Support Feedback CN shadcn m@example.com Toggle Sidebar Build Your
      Application Data Fetching
    |}]
;;

let state handle ~selector =
  Handle.recompute_view handle;
  let node =
    Virtual_dom_test_helpers.Node_helpers.unsafe_convert_exn
      (Handle.last_result handle)
  in
  List.iter
    (Virtual_dom_test_helpers.Node_helpers.select node ~selector)
    ~f:(fun node ->
      match node with
      | Element { attributes; _ } ->
        print_endline
          (List.Assoc.find attributes ~equal:String.equal "data-state"
           |> Option.value ~default:"-")
      | Text _ | Widget -> ())
;;

let%expect_test "sidebar-07: the trigger collapses the sidebar to its icons" =
  let handle = Block_summary.handle "sidebar-07" in
  state handle ~selector:"[data-slot=sidebar]";
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[data-sidebar=trigger]";
  state handle ~selector:"[data-slot=sidebar]";
  [%expect
    {|
    expanded
    collapsed
    |}]
;;

let%expect_test "sidebar-07: a section's chevron toggles it" =
  let handle = Block_summary.handle "sidebar-07" in
  state handle ~selector:"[data-slot=collapsible]";
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=collapsible-trigger][aria-expanded=false]";
  state handle ~selector:"[data-slot=collapsible]";
  [%expect
    {|
    open
    closed
    closed
    closed
    open
    open
    closed
    closed
    |}]
;;

let%expect_test
    "sidebar-05: Build Your Application closes, Getting Started opens"
  =
  let handle = Block_summary.handle "sidebar-05" in
  state handle ~selector:"[data-slot=collapsible]";
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=collapsible-trigger][aria-expanded=true]";
  Handle.click_on
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=collapsible-trigger][aria-expanded=false]";
  state handle ~selector:"[data-slot=collapsible]";
  [%expect
    {|
    closed
    open
    closed
    closed
    closed
    open
    closed
    closed
    closed
    closed
    |}]
;;
