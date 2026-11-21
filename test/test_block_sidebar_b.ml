open! Core
module Handle = Bonsai_web_test.Handle

let smoke name = Block_summary.show (Block_summary.handle name)

let%expect_test "sidebar-09" =
  smoke "sidebar-09";
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar x3
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header x2
      sidebar-menu x3
      sidebar-menu-item x7
      sidebar-menu-button x6
      sidebar-content x2
      sidebar-group x2
      sidebar-group-content x2
      tooltip-content x5
      sidebar-footer
      dropdown-menu-trigger
      avatar
      avatar-image
      avatar-fallback
      label
      switch
      switch-thumb
      input
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
      Acme Inc Enterprise Inbox Inbox Drafts Drafts Sent Sent Junk Junk Trash
      Trash CN shadcn m@example.com Inbox Unreads William Smith 09:34 AM Meeting
      Tomorrow Hi team, just a reminder about our meeting tomorrow at 10 AM.
      Please come prepared with your project updates. Alice Smith Yesterday Re:
      Project Update Thanks for the update. The progress looks great so far. Let's
      schedule a call to discuss the next steps. Bob Johnson 2 days ago Weekend
      Plans Hey everyone! I'm thinking of organizing a team outing this weekend.
      Would you be interested in a hiking trip or a beach day? Emily Davis 2 days
      ago Re: Question about Budget I've reviewed the budget numbers you sent
      over. Can we set up a quick call to discuss some potential adjustments?
      Michael Wilson 1 week ago Important Announcement Please join us for an
      all-hands meeting this Friday at 3 PM. We have some exciting news to share
      about the company's future. Sarah Brown 1 week ago Re: Feedback on Proposal
      Thank you for sending over the proposal. I've reviewed it and have some
      thoughts. Could we schedule a meeting to discuss my feedback in detail?
      David Lee 1 week ago New Project Idea I've been brainstorming and came up
      with an interesting project concept. Do you have time this week to discuss
      its potential impact and feasibility? Olivia Wilson 1 week ago Vacation
      Plans Just a heads up that I'll be taking a two-week vacation next month.
      I'll make sure all my projects are up to date before I leave. James Martin 1
      week ago Re: Conference Registration I've completed the registration for the
      upcoming tech conference. Let me know if you need any additional information
      from my end. Sophia White 1 week ago Team Dinner To celebrate our recent
      project success, I'd like to organize a team dinner. Are you available next
      Friday evening? Please let me know your preferences. Toggle Sidebar All
      Inboxes Inbox
    |}]
;;

let%expect_test "sidebar-10" =
  smoke "sidebar-10";
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar x2
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x9
      sidebar-menu-item x40
      dropdown-menu-trigger x11
      sidebar-menu-button x39
      sidebar-content x2
      sidebar-group x7
      sidebar-group-label x2
      sidebar-group-content x6
      collapsible x5
      collapsible-trigger x5
      sidebar-menu-action x5
      collapsible-content x5
      sidebar-menu-sub x5
      sidebar-menu-sub-item x15
      sidebar-menu-sub-button x15
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item
      breadcrumb-page
      button
      popover-trigger
      popover-content
    text:
      Acme Inc Search Ask AI Home Inbox Favorites 📊 Project Management & Task
      Tracking More 🍳 Family Recipe Collection & Meal Planning More 💪
      Fitness Tracker & Workout Routines More 📚 Book Notes & Reading List More
      🌱 Sustainable Gardening Tips & Plant Care More 🗣️ Language Learning
      Progress & Resources More 🏠 Home Renovation Ideas & Budget Tracker More
      💰 Personal Finance & Investment Portfolio More 🎬 Movie & TV Show
      Watchlist with Reviews More ✅ Daily Habit Tracker & Goal Setting More More
      Workspaces 🏠 Personal Life Management 📔 Daily Journal & Reflection
      🍏 Health & Wellness Tracker 🌟 Personal Growth & Learning Goals 💼
      Professional Development 🎯 Career Objectives & Milestones 🧠 Skill
      Acquisition & Training Log 🤝 Networking Contacts & Events 🎨 Creative
      Projects ✍️ Writing Ideas & Story Outlines 🖼️ Art & Design
      Portfolio 🎵 Music Composition & Practice Log 🏡 Home Management 💰
      Household Budget & Expense Tracking 🔧 Home Maintenance Schedule & Tasks
      📅 Family Calendar & Event Planning 🧳 Travel & Adventure 🗺️ Trip
      Planning & Itineraries 🌎 Travel Bucket List & Inspiration 📸 Travel
      Journal & Photo Gallery More Calendar Settings Templates Trash Help Toggle
      Sidebar Project Management & Task Tracking Edit Oct 08 Customize Page Turn
      into wiki Copy Link Duplicate Move to Move to Trash Undo View analytics
      Version History Show delete pages Notifications Import Export
    |}]
;;

let%expect_test "sidebar-11" =
  smoke "sidebar-11";
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-content
      sidebar-group x2
      sidebar-group-label x2
      sidebar-group-content x2
      sidebar-menu x2
      sidebar-menu-item x11
      sidebar-menu-button x20
      sidebar-menu-badge x3
      collapsible x8
      collapsible-trigger x8
      collapsible-content x8
      sidebar-menu-sub x8
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x3
      breadcrumb-link x2
      breadcrumb-separator x2
      breadcrumb-page
    text:
      Changes README.md M api/hello/route.ts U app/layout.tsx M Files app api
      hello route.ts page.tsx layout.tsx blog page.tsx components ui button.tsx
      card.tsx header.tsx footer.tsx lib util.ts public favicon.ico vercel.svg
      .eslintrc.json .gitignore next.config.js tailwind.config.js package.json
      README.md Toggle Sidebar components ui button.tsx
    |}]
;;

let%expect_test "sidebar-12" =
  smoke "sidebar-12";
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
      sidebar-menu-item x10
      dropdown-menu-trigger
      avatar
      avatar-image
      avatar-fallback
      sidebar-content
      sidebar-group x4
      sidebar-group-content x4
      calendar
      button x35
      separator x5
      collapsible x3
      collapsible-trigger x3
      collapsible-content x3
      sidebar-menu-button x9
      sidebar-footer
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      breadcrumb
      breadcrumb-list
      breadcrumb-item
      breadcrumb-page
    text:
      CN shadcn m@example.com November 2026 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9
      10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 My
      Calendars Personal Work Family Favorites Holidays Birthdays Other Travel
      Reminders Deadlines New Calendar Toggle Sidebar October 2024
    |}]
;;

let%expect_test "sidebar-13" =
  smoke "sidebar-13";
  [%expect
    {|
    slots:
      dialog-trigger
      dialog-overlay
      dialog-content
      dialog-title
      dialog-description
      sidebar-wrapper
      sidebar
      sidebar-content
      sidebar-group
      sidebar-group-content
      sidebar-menu
      sidebar-menu-item x12
      sidebar-menu-button x12
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
      dialog-close
    text:
      Open Dialog Settings Customize your settings here. Notifications Navigation
      Home Appearance Messages & media Language & region Accessibility Mark as
      read Audio & video Connected accounts Privacy & visibility Advanced Settings
      Messages & media Close
    |}]
;;

let%expect_test "sidebar-14" =
  smoke "sidebar-14";
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar-inset
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
      sidebar-trigger
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-content
      sidebar-group
      sidebar-group-label
      sidebar-group-content
      sidebar-menu
      sidebar-menu-item x5
      sidebar-menu-button x5
      sidebar-menu-sub x5
      sidebar-menu-sub-item x26
      sidebar-menu-sub-button x26
      sidebar-rail
    text:
      Build Your Application Data Fetching Toggle Sidebar Table of Contents
      Getting Started Installation Project Structure Build Your Application
      Routing Data Fetching Rendering Caching Styling Optimizing Configuring
      Testing Authentication Deploying Upgrading Examples API Reference Components
      File Conventions Functions next.config.js Options CLI Edge Runtime
      Architecture Accessibility Fast Refresh Next.js Compiler Supported Browsers
      Turbopack Community Contribution Guide
    |}]
;;

let%expect_test "sidebar-15" =
  smoke "sidebar-15";
  [%expect
    {|
    slots:
      sidebar-wrapper
      sidebar x2
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header x2
      sidebar-menu x10
      sidebar-menu-item x37
      dropdown-menu-trigger x12
      sidebar-menu-button x35
      sidebar-content x2
      sidebar-group x7
      sidebar-group-label x2
      sidebar-group-content x6
      collapsible x8
      collapsible-trigger x8
      sidebar-menu-action x5
      collapsible-content x8
      sidebar-menu-sub x5
      sidebar-menu-sub-item x15
      sidebar-menu-sub-button x15
      sidebar-rail
      sidebar-inset
      sidebar-trigger
      separator x5
      breadcrumb
      breadcrumb-list
      breadcrumb-item
      breadcrumb-page
      avatar
      avatar-image
      avatar-fallback
      calendar
      button x35
      sidebar-footer
    text:
      Acme Inc Search Ask AI Home Inbox Favorites 📊 Project Management & Task
      Tracking More 🍳 Family Recipe Collection & Meal Planning More 💪
      Fitness Tracker & Workout Routines More 📚 Book Notes & Reading List More
      🌱 Sustainable Gardening Tips & Plant Care More 🗣️ Language Learning
      Progress & Resources More 🏠 Home Renovation Ideas & Budget Tracker More
      💰 Personal Finance & Investment Portfolio More 🎬 Movie & TV Show
      Watchlist with Reviews More ✅ Daily Habit Tracker & Goal Setting More More
      Workspaces 🏠 Personal Life Management 📔 Daily Journal & Reflection
      🍏 Health & Wellness Tracker 🌟 Personal Growth & Learning Goals 💼
      Professional Development 🎯 Career Objectives & Milestones 🧠 Skill
      Acquisition & Training Log 🤝 Networking Contacts & Events 🎨 Creative
      Projects ✍️ Writing Ideas & Story Outlines 🖼️ Art & Design
      Portfolio 🎵 Music Composition & Practice Log 🏡 Home Management 💰
      Household Budget & Expense Tracking 🔧 Home Maintenance Schedule & Tasks
      📅 Family Calendar & Event Planning 🧳 Travel & Adventure 🗺️ Trip
      Planning & Itineraries 🌎 Travel Bucket List & Inspiration 📸 Travel
      Journal & Photo Gallery More Calendar Settings Templates Trash Help Toggle
      Sidebar Project Management & Task Tracking CN shadcn m@example.com November
      2026 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
      21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 My Calendars Personal Work Family
      Favorites Holidays Birthdays Other Travel Reminders Deadlines New Calendar
    |}]
;;

let%expect_test "sidebar-16" =
  smoke "sidebar-16";
  [%expect
    {|
    slots:
      sidebar-wrapper
      button
      separator
      breadcrumb
      breadcrumb-list
      breadcrumb-item x2
      breadcrumb-link
      breadcrumb-separator
      breadcrumb-page
      label
      input
      sidebar
      sidebar-gap
      sidebar-container
      sidebar-inner
      sidebar-header
      sidebar-menu x5
      sidebar-menu-item x12
      sidebar-menu-button x11
      sidebar-content
      sidebar-group x3
      sidebar-group-label x2
      tooltip-content x4
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
    text:
      Build Your Application Data Fetching Search Acme Inc Enterprise Platform
      Playground Playground Toggle History Starred Settings Models Models Toggle
      Genesis Explorer Quantum Documentation Documentation Toggle Introduction Get
      Started Tutorials Changelog Settings Settings Toggle General Team Billing
      Limits Projects Design Engineering More Sales & Marketing More Travel More
      More Support Feedback CN shadcn m@example.com
    |}]
;;

let%expect_test "sidebar-09: the nav picks the inbox list, Unreads toggles" =
  let h = Block_summary.handle "sidebar-09" in
  let heading () =
    Render.html
      ~classes:false
      ~selector:"[data-slot=sidebar-header] div.text-base"
      (Handle.last_result h)
  in
  heading ();
  Drive.click
    h
    "[data-slot=sidebar-menu-item]:nth-child(3) [data-slot=sidebar-menu-button]";
  heading ();
  Drive.click h "[data-slot=switch]";
  Render.html
    ~classes:false
    ~selector:"[data-slot=switch]"
    (Handle.last_result h);
  [%expect
    {|
    <div> Inbox </div>
    <div> Sent </div>
    <button type="button"
            role="switch"
            aria-checked="true"
            data-state="checked"
            data-slot="switch"
            data-size="default"
            #value="on"
            @on_click>
      <span data-state="checked" data-slot="switch-thumb"> </span>
    </button>
    |}]
;;

let%expect_test
    "sidebar-13: the dialog is open, Esc closes it, the button opens it"
  =
  let h = Block_summary.handle "sidebar-13" in
  let dialogs () =
    printf
      "dialogs: %d\n"
      (List.length
         (Virtual_dom_test_helpers.Node_helpers.select
            (Virtual_dom_test_helpers.Node_helpers.unsafe_convert_exn
               (Handle.last_result h))
            ~selector:"[role=dialog]"))
  in
  dialogs ();
  Drive.key h "[role=dialog]" Escape;
  dialogs ();
  Drive.click h "[data-slot=dialog-trigger]";
  dialogs ();
  [%expect
    {|
    dialogs: 1
    ("default prevented" (key Escape))
    dialogs: 0
    dialogs: 1
    |}]
;;

let%expect_test "sidebar-11: folders open and close" =
  let h = Block_summary.handle "sidebar-11" in
  let opened () =
    Virtual_dom_test_helpers.Node_helpers.select
      (Virtual_dom_test_helpers.Node_helpers.unsafe_convert_exn
         (Handle.last_result h))
      ~selector:"[aria-expanded=true]"
    |> List.length
    |> printf "open folders: %d\n"
  in
  opened ();
  Drive.click h "[aria-expanded=false]";
  opened ();
  [%expect
    {|
    open folders: 2
    open folders: 3
    |}]
;;
