open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle
module Bonsai = Bonsai_web.Bonsai
module Effect = Bonsai_web.Effect

let parts sidebar =
  Sidebar.provider
    sidebar
    [ Sidebar.root
        ~collapsible:Icon
        sidebar
        [ Sidebar.header [ Node.text "Acme" ]
        ; Sidebar.content
            [ Sidebar.group
                [ Sidebar.group_label [ Node.text "Application" ]
                ; Sidebar.group_action [ Node.text "+" ]
                ; Sidebar.group_content
                    [ Sidebar.menu
                        [ Sidebar.menu_item
                            [ Sidebar.menu_button
                                ~href:"#home"
                                ~is_active:true
                                ~tooltip:(Sidebar.menu_tooltip sidebar "Home")
                                [ Node.span [ Node.text "Home" ] ]
                            ; Sidebar.menu_badge [ Node.text "3" ]
                            ]
                        ; Sidebar.menu_item
                            [ Sidebar.menu_button
                                ~size:Lg
                                ~variant:Outline
                                [ Node.text "Inbox" ]
                            ; Sidebar.menu_action
                                ~show_on_hover:true
                                [ Node.text "…" ]
                            ; Sidebar.menu_sub
                                [ Sidebar.menu_sub_item
                                    [ Sidebar.menu_sub_button
                                        ~href:"#unread"
                                        ~size:Sm
                                        [ Node.text "Unread" ]
                                    ]
                                ]
                            ]
                        ; Sidebar.menu_item
                            [ Sidebar.menu_skeleton ~show_icon:true () ]
                        ]
                    ]
                ]
            ]
        ; Sidebar.footer [ Node.text "Me" ]
        ; Sidebar.rail sidebar
        ]
    ; Sidebar.inset [ Sidebar.trigger sidebar ]
    ]
;;

let controlled ?(open_ = true) ?(open_mobile = false) ~is_mobile () =
  Sidebar.create
    ~persist:false
    ~open_
    ~on_open_change:(fun _ -> Effect.Ignore)
    ~open_mobile
    ~on_open_mobile_change:(fun _ -> Effect.Ignore)
    ~is_mobile
    ()
;;

let%expect_test "shadcn's classes" =
  Render.html (parts (controlled ~is_mobile:false ()));
  [%expect
    {|
    <div data-slot="sidebar-wrapper"
         class="flex group/sidebar-wrapper has-data-[variant=inset]:bg-sidebar min-h-svh w-full"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <div data-state="expanded"
           data-collapsible=""
           data-variant="sidebar"
           data-side="left"
           data-slot="sidebar"
           class="group hidden md:block peer text-sidebar-foreground">
        <div data-slot="sidebar-gap"
             class="bg-transparent cn-sidebar-gap group-data-[collapsible=icon]:w-(--sidebar-width-icon) group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative w-(--sidebar-width)"> </div>
        <div data-slot="sidebar-container"
             data-side="left"
             class="data-[side=left]:group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)] data-[side=left]:left-0 data-[side=right]:group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)] data-[side=right]:right-0 duration-200 ease-linear fixed group-data-[collapsible=icon]:w-(--sidebar-width-icon) group-data-[side=left]:border-r group-data-[side=right]:border-l h-svh hidden inset-y-0 md:flex transition-[left,right,width] w-(--sidebar-width) z-10">
          <div data-sidebar="sidebar"
               data-slot="sidebar-inner"
               class="cn-sidebar-inner flex flex-col size-full">
            <div data-slot="sidebar-header"
                 data-sidebar="header"
                 class="cn-sidebar-header flex flex-col"> Acme </div>
            <div data-slot="sidebar-content"
                 data-sidebar="content"
                 class="cn-sidebar-content flex flex-1 flex-col group-data-[collapsible=icon]:overflow-hidden min-h-0 overflow-auto">
              <div data-slot="sidebar-group"
                   data-sidebar="group"
                   class="cn-sidebar-group flex flex-col min-w-0 relative w-full">
                <div data-slot="sidebar-group-label"
                     data-sidebar="group-label"
                     class="[&>svg]:shrink-0 cn-sidebar-group-label flex items-center outline-hidden shrink-0"> Application </div>
                <button type="button"
                        data-slot="sidebar-group-action"
                        data-sidebar="group-action"
                        class="[&>svg]:shrink-0 after:-inset-2 after:absolute aspect-square cn-sidebar-group-action flex group-data-[collapsible=icon]:hidden items-center justify-center md:after:hidden outline-hidden transition-transform"> + </button>
                <div data-slot="sidebar-group-content"
                     data-sidebar="group-content"
                     class="cn-sidebar-group-content w-full">
                  <ul data-slot="sidebar-menu"
                      data-sidebar="menu"
                      class="cn-sidebar-menu flex flex-col min-w-0 w-full">
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <a href="#home"
                         data-slot="sidebar-menu-button"
                         data-sidebar="menu-button"
                         data-size="default"
                         data-active="true"
                         id="sidebar-tooltip-Home-trigger"
                         data-state="closed"
                         class="[&>span:last-child]:truncate [&_svg]:shrink-0 [&_svg]:size-4 aria-disabled:opacity-50 aria-disabled:pointer-events-none cn-sidebar-menu-button cn-sidebar-menu-button-size-default cn-sidebar-menu-button-variant-default disabled:opacity-50 disabled:pointer-events-none flex group/menu-button items-center outline-hidden overflow-hidden peer/menu-button w-full"
                         @on_blur
                         @on_focus
                         @on_mouseleave
                         @on_mousemove
                         @on_pointerdown>
                        <span> Home </span>
                      </a>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <div data-slot="sidebar-menu-badge"
                           data-sidebar="menu-badge"
                           class="cn-sidebar-menu-badge flex group-data-[collapsible=icon]:hidden items-center justify-center select-none tabular-nums"> 3 </div>
                    </li>
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <button type="button"
                              data-slot="sidebar-menu-button"
                              data-sidebar="menu-button"
                              data-size="lg"
                              data-active="false"
                              class="[&>span:last-child]:truncate [&_svg]:shrink-0 [&_svg]:size-4 aria-disabled:opacity-50 aria-disabled:pointer-events-none cn-sidebar-menu-button cn-sidebar-menu-button-size-lg cn-sidebar-menu-button-variant-outline disabled:opacity-50 disabled:pointer-events-none flex group/menu-button items-center outline-hidden overflow-hidden peer/menu-button w-full"> Inbox </button>
                      <button type="button"
                              data-slot="sidebar-menu-action"
                              data-sidebar="menu-action"
                              class="[&>svg]:shrink-0 after:-inset-2 after:absolute aria-expanded:opacity-100 cn-sidebar-menu-action flex group-data-[collapsible=icon]:hidden group-focus-within/menu-item:opacity-100 group-hover/menu-item:opacity-100 items-center justify-center md:after:hidden md:opacity-0 outline-hidden peer-data-active/menu-button:text-sidebar-accent-foreground transition-transform"> … </button>
                      <ul data-slot="sidebar-menu-sub"
                          data-sidebar="menu-sub"
                          class="cn-sidebar-menu-sub flex flex-col group-data-[collapsible=icon]:hidden min-w-0">
                        <li data-slot="sidebar-menu-sub-item"
                            data-sidebar="menu-sub-item"
                            class="group/menu-sub-item relative">
                          <a data-slot="sidebar-menu-sub-button"
                             data-sidebar="menu-sub-button"
                             data-size="sm"
                             data-active="false"
                             href="#unread"
                             class="-translate-x-px [&>span:last-child]:truncate [&>svg]:shrink-0 aria-disabled:opacity-50 aria-disabled:pointer-events-none cn-sidebar-menu-sub-button disabled:opacity-50 disabled:pointer-events-none flex group-data-[collapsible=icon]:hidden items-center min-w-0 outline-hidden overflow-hidden"> Unread </a>
                        </li>
                      </ul>
                    </li>
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <div data-slot="sidebar-menu-skeleton"
                           data-sidebar="menu-skeleton"
                           class="cn-sidebar-menu-skeleton flex items-center">
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-icon"
                             class="animate-pulse cn-sidebar-menu-skeleton-icon cn-skeleton"> </div>
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-text"
                             class="animate-pulse cn-sidebar-menu-skeleton-text cn-skeleton flex-1 max-w-(--skeleton-width)"
                             custom-css-vars=((--skeleton-width 70%))> </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
            <div data-slot="sidebar-footer"
                 data-sidebar="footer"
                 class="cn-sidebar-footer flex flex-col"> Me </div>
            <button type="button"
                    data-sidebar="rail"
                    data-slot="sidebar-rail"
                    aria-label="Toggle Sidebar"
                    tabindex="-1"
                    title="Toggle Sidebar"
                    class="[[data-side=left][data-collapsible=offcanvas]_&]:-right-2 [[data-side=left][data-state=collapsed]_&]:cursor-e-resize [[data-side=right][data-collapsible=offcanvas]_&]:-left-2 [[data-side=right][data-state=collapsed]_&]:cursor-w-resize absolute after:absolute after:inset-y-0 after:start-1/2 after:w-[2px] cn-sidebar-rail ease-linear group-data-[collapsible=offcanvas]:after:left-full group-data-[collapsible=offcanvas]:translate-x-0 group-data-[side=left]:-right-4 group-data-[side=right]:left-0 hidden hover:group-data-[collapsible=offcanvas]:bg-sidebar in-data-[side=left]:cursor-w-resize in-data-[side=right]:cursor-e-resize inset-y-0 ltr:-translate-x-1/2 rtl:-translate-x-1/2 sm:flex transition-all w-4 z-20"
                    @on_click> </button>
          </div>
        </div>
      </div>
      <main data-slot="sidebar-inset" class="cn-sidebar-inset flex flex-1 flex-col relative w-full">
        <button type="button"
                data-variant="ghost"
                data-size="icon-sm"
                data-sidebar="trigger"
                data-slot="sidebar-trigger"
                class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-icon-sm cn-button-variant-ghost cn-sidebar-trigger disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
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
               class="cn-rtl-flip lucide lucide-panel-left">
            <rect width="18" height="18" x="3" y="3" rx="2"> </rect>
            <path d="M9 3v18"> </path>
          </svg>
          <span class="sr-only"> Toggle Sidebar </span>
        </button>
      </main>
    </div>
    |}]
;;

let%expect_test "variants, sides and collapsible none" =
  let sidebar = controlled ~open_:false ~is_mobile:false () in
  List.iter
    [ Sidebar.Variant.Floating, Sidebar.Side.Right; Inset, Left ]
    ~f:(fun (variant, side) ->
      Render.html
        ~selector:"[data-slot=sidebar] > *"
        (Sidebar.root ~variant ~side ~collapsible:Offcanvas sidebar []));
  Render.html (Sidebar.root ~collapsible:None sidebar []);
  [%expect
    {|
    <div data-slot="sidebar-gap"
         class="bg-transparent cn-sidebar-gap group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))] group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative w-(--sidebar-width)"> </div>
    <div data-slot="sidebar-container"
         data-side="right"
         class="data-[side=left]:group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)] data-[side=left]:left-0 data-[side=right]:group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)] data-[side=right]:right-0 duration-200 ease-linear fixed group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)] h-svh hidden inset-y-0 md:flex p-2 transition-[left,right,width] w-(--sidebar-width) z-10">
      <div data-sidebar="sidebar"
           data-slot="sidebar-inner"
           class="cn-sidebar-inner flex flex-col size-full"> </div>
    </div>
    <div data-slot="sidebar-gap"
         class="bg-transparent cn-sidebar-gap group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))] group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative w-(--sidebar-width)"> </div>
    <div data-slot="sidebar-container"
         data-side="left"
         class="data-[side=left]:group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)] data-[side=left]:left-0 data-[side=right]:group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)] data-[side=right]:right-0 duration-200 ease-linear fixed group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)] h-svh hidden inset-y-0 md:flex p-2 transition-[left,right,width] w-(--sidebar-width) z-10">
      <div data-sidebar="sidebar"
           data-slot="sidebar-inner"
           class="cn-sidebar-inner flex flex-col size-full"> </div>
    </div>
    <div data-slot="sidebar"
         class="bg-sidebar flex flex-col h-full text-sidebar-foreground w-(--sidebar-width)"> </div>
    |}]
;;

let%expect_test "the trigger and the rail collapse and expand it" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let open Bonsai.Let_syntax in
      let sidebar = Sidebar.component ~persist:false graph in
      let%arr sidebar in
      parts sidebar)
  in
  Handle.show handle;
  [%expect
    {|
    <div data-slot="sidebar-wrapper"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <div data-state="expanded"
           data-collapsible=""
           data-variant="sidebar"
           data-side="left"
           data-slot="sidebar">
        <div data-slot="sidebar-gap"> </div>
        <div data-slot="sidebar-container" data-side="left">
          <div data-sidebar="sidebar" data-slot="sidebar-inner">
            <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
            <div data-slot="sidebar-content" data-sidebar="content">
              <div data-slot="sidebar-group" data-sidebar="group">
                <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                <div data-slot="sidebar-group-content" data-sidebar="group-content">
                  <ul data-slot="sidebar-menu" data-sidebar="menu">
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <a href="#home"
                         data-slot="sidebar-menu-button"
                         data-sidebar="menu-button"
                         data-size="default"
                         data-active="true"
                         id="sidebar-tooltip-Home-trigger"
                         data-state="closed"
                         @on_blur
                         @on_focus
                         @on_mouseleave
                         @on_mousemove
                         @on_pointerdown>
                        <span> Home </span>
                      </a>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <div data-slot="sidebar-menu-badge" data-sidebar="menu-badge"> 3 </div>
                    </li>
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <button type="button"
                              data-slot="sidebar-menu-button"
                              data-sidebar="menu-button"
                              data-size="lg"
                              data-active="false"> Inbox </button>
                      <button type="button" data-slot="sidebar-menu-action" data-sidebar="menu-action"> … </button>
                      <ul data-slot="sidebar-menu-sub" data-sidebar="menu-sub">
                        <li data-slot="sidebar-menu-sub-item" data-sidebar="menu-sub-item">
                          <a data-slot="sidebar-menu-sub-button"
                             data-sidebar="menu-sub-button"
                             data-size="sm"
                             data-active="false"
                             href="#unread"> Unread </a>
                        </li>
                      </ul>
                    </li>
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <div data-slot="sidebar-menu-skeleton" data-sidebar="menu-skeleton">
                        <div data-slot="skeleton" data-sidebar="menu-skeleton-icon"> </div>
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-text"
                             custom-css-vars=((--skeleton-width 70%))> </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
            <div data-slot="sidebar-footer" data-sidebar="footer"> Me </div>
            <button type="button"
                    data-sidebar="rail"
                    data-slot="sidebar-rail"
                    aria-label="Toggle Sidebar"
                    tabindex="-1"
                    title="Toggle Sidebar"
                    @on_click> </button>
          </div>
        </div>
      </div>
      <main data-slot="sidebar-inset">
        <button type="button"
                data-variant="ghost"
                data-size="icon-sm"
                data-sidebar="trigger"
                data-slot="sidebar-trigger"
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
            <rect width="18" height="18" x="3" y="3" rx="2"> </rect>
            <path d="M9 3v18"> </path>
          </svg>
          <span> Toggle Sidebar </span>
        </button>
      </main>
    </div>
    |}];
  Drive.click handle "[data-slot=sidebar-trigger]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <div data-state="expanded"
    +|  <div data-state="collapsed"
    -|       data-collapsible=""
    +|       data-collapsible="icon"
             data-variant="sidebar"
             data-side="left"
             data-slot="sidebar">
          <div data-slot="sidebar-gap"> </div>
          <div data-slot="sidebar-container" data-side="left">
            <div data-sidebar="sidebar" data-slot="sidebar-inner">
              <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
              <div data-slot="sidebar-content" data-sidebar="content">
                <div data-slot="sidebar-group" data-sidebar="group">
                  <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                  <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                  <div data-slot="sidebar-group-content" data-sidebar="group-content">
                    <ul data-slot="sidebar-menu" data-sidebar="menu">
                      <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                        <a href="#home"
                           data-slot="sidebar-menu-button"
    |}];
  Drive.click handle "[data-slot=sidebar-rail]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <div data-state="collapsed"
    +|  <div data-state="expanded"
    -|       data-collapsible="icon"
    +|       data-collapsible=""
             data-variant="sidebar"
             data-side="left"
             data-slot="sidebar">
          <div data-slot="sidebar-gap"> </div>
          <div data-slot="sidebar-container" data-side="left">
            <div data-sidebar="sidebar" data-slot="sidebar-inner">
              <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
              <div data-slot="sidebar-content" data-sidebar="content">
                <div data-slot="sidebar-group" data-sidebar="group">
                  <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                  <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                  <div data-slot="sidebar-group-content" data-sidebar="group-content">
                    <ul data-slot="sidebar-menu" data-sidebar="menu">
                      <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                        <a href="#home"
                           data-slot="sidebar-menu-button"
    |}]
;;

let%expect_test "collapsed to icons, a menu button's tooltip shows on hover" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let open Bonsai.Let_syntax in
      let sidebar = Sidebar.component ~persist:false graph in
      let%arr sidebar in
      parts sidebar)
  in
  let hover () =
    Handle.mousemove
      handle
      ~get_vdom:Fn.id
      ~selector:"#sidebar-tooltip-Home-trigger"
  in
  Handle.show handle;
  [%expect
    {|
    <div data-slot="sidebar-wrapper"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <div data-state="expanded"
           data-collapsible=""
           data-variant="sidebar"
           data-side="left"
           data-slot="sidebar">
        <div data-slot="sidebar-gap"> </div>
        <div data-slot="sidebar-container" data-side="left">
          <div data-sidebar="sidebar" data-slot="sidebar-inner">
            <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
            <div data-slot="sidebar-content" data-sidebar="content">
              <div data-slot="sidebar-group" data-sidebar="group">
                <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                <div data-slot="sidebar-group-content" data-sidebar="group-content">
                  <ul data-slot="sidebar-menu" data-sidebar="menu">
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <a href="#home"
                         data-slot="sidebar-menu-button"
                         data-sidebar="menu-button"
                         data-size="default"
                         data-active="true"
                         id="sidebar-tooltip-Home-trigger"
                         data-state="closed"
                         @on_blur
                         @on_focus
                         @on_mouseleave
                         @on_mousemove
                         @on_pointerdown>
                        <span> Home </span>
                      </a>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <div data-slot="sidebar-menu-badge" data-sidebar="menu-badge"> 3 </div>
                    </li>
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <button type="button"
                              data-slot="sidebar-menu-button"
                              data-sidebar="menu-button"
                              data-size="lg"
                              data-active="false"> Inbox </button>
                      <button type="button" data-slot="sidebar-menu-action" data-sidebar="menu-action"> … </button>
                      <ul data-slot="sidebar-menu-sub" data-sidebar="menu-sub">
                        <li data-slot="sidebar-menu-sub-item" data-sidebar="menu-sub-item">
                          <a data-slot="sidebar-menu-sub-button"
                             data-sidebar="menu-sub-button"
                             data-size="sm"
                             data-active="false"
                             href="#unread"> Unread </a>
                        </li>
                      </ul>
                    </li>
                    <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                      <div data-slot="sidebar-menu-skeleton" data-sidebar="menu-skeleton">
                        <div data-slot="skeleton" data-sidebar="menu-skeleton-icon"> </div>
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-text"
                             custom-css-vars=((--skeleton-width 70%))> </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
            <div data-slot="sidebar-footer" data-sidebar="footer"> Me </div>
            <button type="button"
                    data-sidebar="rail"
                    data-slot="sidebar-rail"
                    aria-label="Toggle Sidebar"
                    tabindex="-1"
                    title="Toggle Sidebar"
                    @on_click> </button>
          </div>
        </div>
      </div>
      <main data-slot="sidebar-inset">
        <button type="button"
                data-variant="ghost"
                data-size="icon-sm"
                data-sidebar="trigger"
                data-slot="sidebar-trigger"
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
            <rect width="18" height="18" x="3" y="3" rx="2"> </rect>
            <path d="M9 3v18"> </path>
          </svg>
          <span> Toggle Sidebar </span>
        </button>
      </main>
    </div>
    |}];
  (* Expanded: hidden, as shadcn's [hidden={state !== "collapsed"}]. *)
  hover ();
  Handle.show_diff handle;
  [%expect {| |}];
  Drive.click handle "[data-slot=sidebar-trigger]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <div data-state="expanded"
    +|  <div data-state="collapsed"
    -|       data-collapsible=""
    +|       data-collapsible="icon"
             data-variant="sidebar"
             data-side="left"
             data-slot="sidebar">
          <div data-slot="sidebar-gap"> </div>
          <div data-slot="sidebar-container" data-side="left">
            <div data-sidebar="sidebar" data-slot="sidebar-inner">
              <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
              <div data-slot="sidebar-content" data-sidebar="content">
                <div data-slot="sidebar-group" data-sidebar="group">
                  <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                  <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                  <div data-slot="sidebar-group-content" data-sidebar="group-content">
                    <ul data-slot="sidebar-menu" data-sidebar="menu">
                      <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                        <a href="#home"
                           data-slot="sidebar-menu-button"
    |}];
  hover ();
  Handle.show_diff handle;
  [%expect
    {|
          <div data-slot="sidebar-container" data-side="left">
            <div data-sidebar="sidebar" data-slot="sidebar-inner">
              <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
              <div data-slot="sidebar-content" data-sidebar="content">
                <div data-slot="sidebar-group" data-sidebar="group">
                  <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
                  <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
                  <div data-slot="sidebar-group-content" data-sidebar="group-content">
                    <ul data-slot="sidebar-menu" data-sidebar="menu">
                      <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                        <a href="#home"
                           data-slot="sidebar-menu-button"
                           data-sidebar="menu-button"
                           data-size="default"
                           data-active="true"
                           id="sidebar-tooltip-Home-trigger"
    -|                     data-state="closed"
    +|                     data-state="delayed-open"
    +|                     aria-describedby="sidebar-tooltip-Home-tooltip"
                           @on_blur
                           @on_focus
                           @on_mouseleave
                           @on_mousemove
                           @on_pointerdown>
                          <span> Home </span>
                        </a>
    -|                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    +|                  <div loon-dismiss=((sidebar-tooltip-Home-trigger)false false)
    +|                       loon-presence=()
    +|                       style={
    +|                         display: contents;
    +|                       }>
    +|                    <div data-radix-popper-content-wrapper=""
    +|                         popover="manual"
    +|                         loon-popper=(Popper((side Right)(side_offset 0)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element sidebar-tooltip-Home-trigger))(name tooltip)))
    +|                         style={
    +|                           inset: auto;
    +|                           margin: 0;
    +|                           border: 0;
    +|                           padding: 0;
    +|                           background: transparent;
    +|                           color: inherit;
    +|                           overflow: visible;
    +|                           max-width: none;
    +|                           max-height: none;
    +|                           white-space: normal;
    +|                           text-align: start;
    +|                           font-weight: normal;
    +|                           font-style: normal;
    +|                           letter-spacing: normal;
    +|                           text-transform: none;
    +|                         }>
    +|                      <div data-slot="tooltip-content"
    +|                           id="sidebar-tooltip-Home-content"
    +|                           data-state="delayed-open"
    +|                           data-side="right"
    +|                           data-align="center"
    +|                           @on_mouseleave>
    +|                        Home
    +|                        <span id="sidebar-tooltip-Home-tooltip"
    +|                              role="tooltip"
    +|                              style="position:absolute;border:0;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;word-wrap:normal"> Home </span>
    +|                        <span data-popper-arrow="" style={ position: absolute; }>
    +|                          <svg width="10"
    +|                               height="5"
    +|                               viewBox="0 0 30 10"
    +|                               preserveAspectRatio="none"
    +|                               style={
    +|                                 display: block;
    +|                               }>
    +|                            <polygon points="0,0 30,0 15,10"> </polygon>
    +|                          </svg>
    +|                        </span>
    +|                      </div>
    +|                    </div>
    +|                  </div>
                        <div data-slot="sidebar-menu-badge" data-sidebar="menu-badge"> 3 </div>
                      </li>
                      <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
                        <button type="button"
                                data-slot="sidebar-menu-button"
                                data-sidebar="menu-button"
                                data-size="lg"
                                data-active="false"> Inbox </button>
                        <button type="button" data-slot="sidebar-menu-action" data-sidebar="menu-action"> … </button>
                        <ul data-slot="sidebar-menu-sub" data-sidebar="menu-sub">
                          <li data-slot="sidebar-menu-sub-item" data-sidebar="menu-sub-item">
                            <a data-slot="sidebar-menu-sub-button"
                               data-sidebar="menu-sub-button"
                               data-size="sm"
                               data-active="false"
                               href="#unread"> Unread </a>
    |}]
;;

let%expect_test "on phones it is a sheet, which Esc closes" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let open Bonsai.Let_syntax in
      let open_mobile, set_open_mobile = Bonsai.state false graph in
      let%arr open_mobile
      and set_open_mobile in
      parts
        (Sidebar.create
           ~persist:false
           ~open_:true
           ~on_open_change:(fun _ -> Effect.Ignore)
           ~open_mobile
           ~on_open_mobile_change:set_open_mobile
           ~is_mobile:true
           ()))
  in
  Handle.show handle;
  [%expect
    {|
    <div data-slot="sidebar-wrapper"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <main data-slot="sidebar-inset">
        <button type="button"
                data-variant="ghost"
                data-size="icon-sm"
                data-sidebar="trigger"
                data-slot="sidebar-trigger"
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
            <rect width="18" height="18" x="3" y="3" rx="2"> </rect>
            <path d="M9 3v18"> </path>
          </svg>
          <span> Toggle Sidebar </span>
        </button>
      </main>
    </div>
    |}];
  Drive.click handle "[data-slot=sidebar-trigger]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    +|  <div popover="manual"
    +|       loon-portal=()
    +|       loon-presence=()
    +|       style={
    +|         inset: 0;
    +|         margin: 0;
    +|         border: 0;
    +|         padding: 0;
    +|         background: transparent;
    +|         color: inherit;
    +|         overflow: visible;
    +|         max-width: none;
    +|         max-height: none;
    +|         white-space: normal;
    +|         text-align: start;
    +|         font-weight: normal;
    +|         font-style: normal;
    +|         letter-spacing: normal;
    +|         text-transform: none;
    +|         position: fixed;
    +|         width: 100%;
    +|         height: 100%;
    +|         pointer-events: none;
    +|         z-index: 50;
    +|       }>
    +|    <div data-slot="sheet-overlay" data-state="open" @on_click style={ pointer-events: auto; }> </div>
    +|    <div data-focus-guard=""
    +|         tabindex="0"
    +|         aria-hidden="true"
    +|         @on_focus
    +|         style={
    +|           position: fixed;
    +|           opacity: 0;
    +|           outline: none;
    +|           pointer-events: none;
    +|         }> </div>
    +|    <div role="dialog"
    +|         id="sidebar-mobile-content"
    +|         aria-describedby="sidebar-mobile-description"
    +|         aria-labelledby="sidebar-mobile-title"
    +|         data-state="open"
    +|         tabindex="-1"
    +|         data-slot="sidebar"
    +|         data-side="left"
    +|         data-sidebar="sidebar"
    +|         data-mobile="true"
    +|         custom-css-vars=((--sidebar-width 18rem))
    +|         loon-dismiss=(()false true)
    +|         loon-focus-on-mount=First_tabbable
    +|         loon-scroll-lock=()
    +|         @on_keydown
    +|         style={
    +|           pointer-events: auto;
    +|         }>
    +|      <div data-slot="sheet-header">
    +|        <h2 data-slot="sheet-title" id="sidebar-mobile-title"> Sidebar </h2>
    +|        <p data-slot="sheet-description" id="sidebar-mobile-description"> Displays the mobile sidebar. </p>
    +|      </div>
    +|      <div>
    +|        <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
    +|        <div data-slot="sidebar-content" data-sidebar="content">
    +|          <div data-slot="sidebar-group" data-sidebar="group">
    +|            <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
    +|            <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
    +|            <div data-slot="sidebar-group-content" data-sidebar="group-content">
    +|              <ul data-slot="sidebar-menu" data-sidebar="menu">
    +|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    +|                  <a href="#home"
    +|                     data-slot="sidebar-menu-button"
    +|                     data-sidebar="menu-button"
    +|                     data-size="default"
    +|                     data-active="true"
    +|                     id="sidebar-tooltip-Home-trigger"
    +|                     data-state="closed"
    +|                     @on_blur
    +|                     @on_focus
    +|                     @on_mouseleave
    +|                     @on_mousemove
    +|                     @on_pointerdown>
    +|                    <span> Home </span>
    +|                  </a>
    +|                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    +|                  <div data-slot="sidebar-menu-badge" data-sidebar="menu-badge"> 3 </div>
    +|                </li>
    +|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    +|                  <button type="button"
    +|                          data-slot="sidebar-menu-button"
    +|                          data-sidebar="menu-button"
    +|                          data-size="lg"
    +|                          data-active="false"> Inbox </button>
    +|                  <button type="button" data-slot="sidebar-menu-action" data-sidebar="menu-action"> … </button>
    +|                  <ul data-slot="sidebar-menu-sub" data-sidebar="menu-sub">
    +|                    <li data-slot="sidebar-menu-sub-item" data-sidebar="menu-sub-item">
    +|                      <a data-slot="sidebar-menu-sub-button"
    +|                         data-sidebar="menu-sub-button"
    +|                         data-size="sm"
    +|                         data-active="false"
    +|                         href="#unread"> Unread </a>
    +|                    </li>
    +|                  </ul>
    +|                </li>
    +|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    +|                  <div data-slot="sidebar-menu-skeleton" data-sidebar="menu-skeleton">
    +|                    <div data-slot="skeleton" data-sidebar="menu-skeleton-icon"> </div>
    +|                    <div data-slot="skeleton"
    +|                         data-sidebar="menu-skeleton-text"
    +|                         custom-css-vars=((--skeleton-width 70%))> </div>
    +|                  </div>
    +|                </li>
    +|              </ul>
    +|            </div>
    +|          </div>
    +|        </div>
    +|        <div data-slot="sidebar-footer" data-sidebar="footer"> Me </div>
    +|        <button type="button"
    +|                data-sidebar="rail"
    +|                data-slot="sidebar-rail"
    +|                aria-label="Toggle Sidebar"
    +|                tabindex="-1"
    +|                title="Toggle Sidebar"
    +|                @on_click> </button>
    +|      </div>
    +|      <button type="button"
    +|              data-slot="sheet-close"
    +|              data-variant="ghost"
    +|              data-size="icon-sm"
    +|              @on_click>
    +|        <svg xmlns="http://www.w3.org/2000/svg"
    +|             width="24"
    +|             height="24"
    +|             viewBox="0 0 24 24"
    +|             fill="none"
    +|             stroke="currentColor"
    +|             stroke-width="2"
    +|             stroke-linecap="round"
    +|             stroke-linejoin="round">
    +|          <path d="M18 6 6 18"> </path>
    +|          <path d="m6 6 12 12"> </path>
    +|        </svg>
    +|        <span> Close </span>
    +|      </button>
    +|    </div>
    +|    <div data-focus-guard=""
    +|         tabindex="0"
    +|         aria-hidden="true"
    +|         @on_focus
    +|         style={
    +|           position: fixed;
    +|           opacity: 0;
    +|           outline: none;
    +|           pointer-events: none;
    +|         }> </div>
    +|  </div>
        <main data-slot="sidebar-inset">
          <button type="button"
                  data-variant="ghost"
                  data-size="icon-sm"
                  data-sidebar="trigger"
                  data-slot="sidebar-trigger"
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
    |}];
  Drive.key handle "[data-mobile=true]" Escape;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key Escape))

      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <div popover="manual"
    -|       loon-portal=()
    -|       loon-presence=()
    -|       style={
    -|         inset: 0;
    -|         margin: 0;
    -|         border: 0;
    -|         padding: 0;
    -|         background: transparent;
    -|         color: inherit;
    -|         overflow: visible;
    -|         max-width: none;
    -|         max-height: none;
    -|         white-space: normal;
    -|         text-align: start;
    -|         font-weight: normal;
    -|         font-style: normal;
    -|         letter-spacing: normal;
    -|         text-transform: none;
    -|         position: fixed;
    -|         width: 100%;
    -|         height: 100%;
    -|         pointer-events: none;
    -|         z-index: 50;
    -|       }>
    -|    <div data-slot="sheet-overlay" data-state="open" @on_click style={ pointer-events: auto; }> </div>
    -|    <div data-focus-guard=""
    -|         tabindex="0"
    -|         aria-hidden="true"
    -|         @on_focus
    -|         style={
    -|           position: fixed;
    -|           opacity: 0;
    -|           outline: none;
    -|           pointer-events: none;
    -|         }> </div>
    -|    <div role="dialog"
    -|         id="sidebar-mobile-content"
    -|         aria-describedby="sidebar-mobile-description"
    -|         aria-labelledby="sidebar-mobile-title"
    -|         data-state="open"
    -|         tabindex="-1"
    -|         data-slot="sidebar"
    -|         data-side="left"
    -|         data-sidebar="sidebar"
    -|         data-mobile="true"
    -|         custom-css-vars=((--sidebar-width 18rem))
    -|         loon-dismiss=(()false true)
    -|         loon-focus-on-mount=First_tabbable
    -|         loon-scroll-lock=()
    -|         @on_keydown
    -|         style={
    -|           pointer-events: auto;
    -|         }>
    -|      <div data-slot="sheet-header">
    -|        <h2 data-slot="sheet-title" id="sidebar-mobile-title"> Sidebar </h2>
    -|        <p data-slot="sheet-description" id="sidebar-mobile-description"> Displays the mobile sidebar. </p>
    -|      </div>
    -|      <div>
    -|        <div data-slot="sidebar-header" data-sidebar="header"> Acme </div>
    -|        <div data-slot="sidebar-content" data-sidebar="content">
    -|          <div data-slot="sidebar-group" data-sidebar="group">
    -|            <div data-slot="sidebar-group-label" data-sidebar="group-label"> Application </div>
    -|            <button type="button" data-slot="sidebar-group-action" data-sidebar="group-action"> + </button>
    -|            <div data-slot="sidebar-group-content" data-sidebar="group-content">
    -|              <ul data-slot="sidebar-menu" data-sidebar="menu">
    -|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    -|                  <a href="#home"
    -|                     data-slot="sidebar-menu-button"
    -|                     data-sidebar="menu-button"
    -|                     data-size="default"
    -|                     data-active="true"
    -|                     id="sidebar-tooltip-Home-trigger"
    -|                     data-state="closed"
    -|                     @on_blur
    -|                     @on_focus
    -|                     @on_mouseleave
    -|                     @on_mousemove
    -|                     @on_pointerdown>
    -|                    <span> Home </span>
    -|                  </a>
    -|                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    -|                  <div data-slot="sidebar-menu-badge" data-sidebar="menu-badge"> 3 </div>
    -|                </li>
    -|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    -|                  <button type="button"
    -|                          data-slot="sidebar-menu-button"
    -|                          data-sidebar="menu-button"
    -|                          data-size="lg"
    -|                          data-active="false"> Inbox </button>
    -|                  <button type="button" data-slot="sidebar-menu-action" data-sidebar="menu-action"> … </button>
    -|                  <ul data-slot="sidebar-menu-sub" data-sidebar="menu-sub">
    -|                    <li data-slot="sidebar-menu-sub-item" data-sidebar="menu-sub-item">
    -|                      <a data-slot="sidebar-menu-sub-button"
    -|                         data-sidebar="menu-sub-button"
    -|                         data-size="sm"
    -|                         data-active="false"
    -|                         href="#unread"> Unread </a>
    -|                    </li>
    -|                  </ul>
    -|                </li>
    -|                <li data-slot="sidebar-menu-item" data-sidebar="menu-item">
    -|                  <div data-slot="sidebar-menu-skeleton" data-sidebar="menu-skeleton">
    -|                    <div data-slot="skeleton" data-sidebar="menu-skeleton-icon"> </div>
    -|                    <div data-slot="skeleton"
    -|                         data-sidebar="menu-skeleton-text"
    -|                         custom-css-vars=((--skeleton-width 70%))> </div>
    -|                  </div>
    -|                </li>
    -|              </ul>
    -|            </div>
    -|          </div>
    -|        </div>
    -|        <div data-slot="sidebar-footer" data-sidebar="footer"> Me </div>
    -|        <button type="button"
    -|                data-sidebar="rail"
    -|                data-slot="sidebar-rail"
    -|                aria-label="Toggle Sidebar"
    -|                tabindex="-1"
    -|                title="Toggle Sidebar"
    -|                @on_click> </button>
    -|      </div>
    -|      <button type="button"
    -|              data-slot="sheet-close"
    -|              data-variant="ghost"
    -|              data-size="icon-sm"
    -|              @on_click>
    -|        <svg xmlns="http://www.w3.org/2000/svg"
    -|             width="24"
    -|             height="24"
    -|             viewBox="0 0 24 24"
    -|             fill="none"
    -|             stroke="currentColor"
    -|             stroke-width="2"
    -|             stroke-linecap="round"
    -|             stroke-linejoin="round">
    -|          <path d="M18 6 6 18"> </path>
    -|          <path d="m6 6 12 12"> </path>
    -|        </svg>
    -|        <span> Close </span>
    -|      </button>
    -|    </div>
    -|    <div data-focus-guard=""
    -|         tabindex="0"
    -|         aria-hidden="true"
    -|         @on_focus
    -|         style={
    -|           position: fixed;
    -|           opacity: 0;
    -|           outline: none;
    -|           pointer-events: none;
    -|         }> </div>
    -|  </div>
    +|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        <main data-slot="sidebar-inset">
          <button type="button"
                  data-variant="ghost"
                  data-size="icon-sm"
                  data-sidebar="trigger"
                  data-slot="sidebar-trigger"
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
    |}];
  (* A click on the overlay closes it too. *)
  Drive.click handle "[data-slot=sidebar-trigger]";
  Drive.click handle "[data-slot=sheet-overlay]";
  Handle.show_diff handle;
  [%expect {| |}]
;;
