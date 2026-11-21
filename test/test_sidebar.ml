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
                                ~tooltip:"Home"
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
  [%expect {|
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
             class="bg-transparent duration-200 ease-linear group-data-[collapsible=icon]:w-(--sidebar-width-icon) group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative transition-[width] w-(--sidebar-width)"> </div>
        <div data-slot="sidebar-container"
             class="duration-200 ease-linear fixed group-data-[collapsible=icon]:w-(--sidebar-width-icon) group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)] group-data-[side=left]:border-r group-data-[side=right]:border-l h-svh hidden inset-y-0 left-0 md:flex transition-[left,right,width] w-(--sidebar-width) z-10">
          <div data-sidebar="sidebar"
               data-slot="sidebar-inner"
               class="bg-sidebar flex flex-col group-data-[variant=floating]:border group-data-[variant=floating]:border-sidebar-border group-data-[variant=floating]:rounded-lg group-data-[variant=floating]:shadow-sm h-full w-full">
            <div data-slot="sidebar-header" data-sidebar="header" class="flex flex-col gap-2 p-2"> Acme </div>
            <div data-slot="sidebar-content"
                 data-sidebar="content"
                 class="flex flex-1 flex-col gap-2 group-data-[collapsible=icon]:overflow-hidden min-h-0 overflow-auto">
              <div data-slot="sidebar-group"
                   data-sidebar="group"
                   class="flex flex-col min-w-0 p-2 relative w-full">
                <div data-slot="sidebar-group-label"
                     data-sidebar="group-label"
                     class="[&>svg]:shrink-0 [&>svg]:size-4 duration-200 ease-linear flex focus-visible:ring-2 font-medium group-data-[collapsible=icon]:-mt-8 group-data-[collapsible=icon]:opacity-0 h-8 items-center outline-hidden px-2 ring-sidebar-ring rounded-md shrink-0 text-sidebar-foreground/70 text-xs transition-[margin,opacity]"> Application </div>
                <button type="button"
                        data-slot="sidebar-group-action"
                        data-sidebar="group-action"
                        class="[&>svg]:shrink-0 [&>svg]:size-4 absolute after:-inset-2 after:absolute aspect-square flex focus-visible:ring-2 group-data-[collapsible=icon]:hidden hover:bg-sidebar-accent hover:text-sidebar-accent-foreground items-center justify-center md:after:hidden outline-hidden p-0 right-3 ring-sidebar-ring rounded-md text-sidebar-foreground top-3.5 transition-transform w-5"> + </button>
                <div data-slot="sidebar-group-content"
                     data-sidebar="group-content"
                     class="text-sm w-full">
                  <ul data-slot="sidebar-menu"
                      data-sidebar="menu"
                      class="flex flex-col gap-1 min-w-0 w-full">
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <a href="#home"
                         data-slot="sidebar-menu-button"
                         data-sidebar="menu-button"
                         data-size="default"
                         data-active="true"
                         class="[&>span:last-child]:truncate [&>svg]:shrink-0 [&>svg]:size-4 active:bg-sidebar-accent active:text-sidebar-accent-foreground aria-disabled:opacity-50 aria-disabled:pointer-events-none data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium data-[active=true]:text-sidebar-accent-foreground data-[state=open]:hover:bg-sidebar-accent data-[state=open]:hover:text-sidebar-accent-foreground disabled:opacity-50 disabled:pointer-events-none flex focus-visible:ring-2 gap-2 group-data-[collapsible=icon]:p-2! group-data-[collapsible=icon]:size-8! group-has-data-[sidebar=menu-action]/menu-item:pr-8 h-8 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground items-center outline-hidden overflow-hidden p-2 peer/menu-button ring-sidebar-ring rounded-md text-left text-sm transition-[width,height,padding] w-full"
                         @on_focus
                         @on_pointerenter>
                        <span> Home </span>
                      </a>
                      <div role="tooltip"
                           data-slot="tooltip-content"
                           data-side="right"
                           class="-translate-y-1/2 animate-in bg-foreground data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 fade-in-0 fixed group-data-[collapsible=icon]:peer-focus-visible/menu-button:block group-data-[collapsible=icon]:peer-hover/menu-button:block hidden origin-(--radix-tooltip-content-transform-origin) pointer-events-none px-3 py-1.5 rounded-md text-background text-balance text-xs w-fit z-50 zoom-in-95">
                        Home
                        <div class="-translate-x-1/2 -translate-y-1/2 absolute bg-foreground fill-foreground left-0 rotate-45 rounded-[2px] size-2.5 top-1/2 z-50"> </div>
                      </div>
                      <div data-slot="sidebar-menu-badge"
                           data-sidebar="menu-badge"
                           class="absolute flex font-medium group-data-[collapsible=icon]:hidden h-5 items-center justify-center min-w-5 peer-data-[active=true]/menu-button:text-sidebar-accent-foreground peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 peer-data-[size=sm]/menu-button:top-1 peer-hover/menu-button:text-sidebar-accent-foreground pointer-events-none px-1 right-1 rounded-md select-none tabular-nums text-sidebar-foreground text-xs"> 3 </div>
                    </li>
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <button type="button"
                              data-slot="sidebar-menu-button"
                              data-sidebar="menu-button"
                              data-size="lg"
                              data-active="false"
                              class="[&>span:last-child]:truncate [&>svg]:shrink-0 [&>svg]:size-4 active:bg-sidebar-accent active:text-sidebar-accent-foreground aria-disabled:opacity-50 aria-disabled:pointer-events-none bg-background data-[active=true]:bg-sidebar-accent data-[active=true]:font-medium data-[active=true]:text-sidebar-accent-foreground data-[state=open]:hover:bg-sidebar-accent data-[state=open]:hover:text-sidebar-accent-foreground disabled:opacity-50 disabled:pointer-events-none flex focus-visible:ring-2 gap-2 group-data-[collapsible=icon]:p-0! group-data-[collapsible=icon]:size-8! group-has-data-[sidebar=menu-action]/menu-item:pr-8 h-12 hover:bg-sidebar-accent hover:shadow-[0_0_0_1px_var(--sidebar-accent)] hover:text-sidebar-accent-foreground items-center outline-hidden overflow-hidden p-2 peer/menu-button ring-sidebar-ring rounded-md shadow-[0_0_0_1px_var(--sidebar-border)] text-left text-sm transition-[width,height,padding] w-full"> Inbox </button>
                      <button type="button"
                              data-slot="sidebar-menu-action"
                              data-sidebar="menu-action"
                              class="[&>svg]:shrink-0 [&>svg]:size-4 absolute after:-inset-2 after:absolute aspect-square data-[state=open]:opacity-100 flex focus-visible:ring-2 group-data-[collapsible=icon]:hidden group-focus-within/menu-item:opacity-100 group-hover/menu-item:opacity-100 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground items-center justify-center md:after:hidden md:opacity-0 outline-hidden p-0 peer-data-[active=true]/menu-button:text-sidebar-accent-foreground peer-data-[size=default]/menu-button:top-1.5 peer-data-[size=lg]/menu-button:top-2.5 peer-data-[size=sm]/menu-button:top-1 peer-hover/menu-button:text-sidebar-accent-foreground right-1 ring-sidebar-ring rounded-md text-sidebar-foreground top-1.5 transition-transform w-5"> … </button>
                      <ul data-slot="sidebar-menu-sub"
                          data-sidebar="menu-sub"
                          class="border-l border-sidebar-border flex flex-col gap-1 group-data-[collapsible=icon]:hidden min-w-0 mx-3.5 px-2.5 py-0.5 translate-x-px">
                        <li data-slot="sidebar-menu-sub-item"
                            data-sidebar="menu-sub-item"
                            class="group/menu-sub-item relative">
                          <a data-slot="sidebar-menu-sub-button"
                             data-sidebar="menu-sub-button"
                             data-size="sm"
                             data-active="false"
                             href="#unread"
                             class="-translate-x-px [&>span:last-child]:truncate [&>svg]:shrink-0 [&>svg]:size-4 [&>svg]:text-sidebar-accent-foreground active:bg-sidebar-accent active:text-sidebar-accent-foreground aria-disabled:opacity-50 aria-disabled:pointer-events-none data-[active=true]:bg-sidebar-accent data-[active=true]:text-sidebar-accent-foreground disabled:opacity-50 disabled:pointer-events-none flex focus-visible:ring-2 gap-2 group-data-[collapsible=icon]:hidden h-7 hover:bg-sidebar-accent hover:text-sidebar-accent-foreground items-center min-w-0 outline-hidden overflow-hidden px-2 ring-sidebar-ring rounded-md text-sidebar-foreground text-xs"> Unread </a>
                        </li>
                      </ul>
                    </li>
                    <li data-slot="sidebar-menu-item"
                        data-sidebar="menu-item"
                        class="group/menu-item relative">
                      <div data-slot="sidebar-menu-skeleton"
                           data-sidebar="menu-skeleton"
                           class="flex gap-2 h-8 items-center px-2 rounded-md">
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-icon"
                             class="animate-pulse bg-accent rounded-md size-4"> </div>
                        <div data-slot="skeleton"
                             data-sidebar="menu-skeleton-text"
                             class="animate-pulse bg-accent flex-1 h-4 max-w-(--skeleton-width) rounded-md"
                             custom-css-vars=((--skeleton-width 70%))> </div>
                      </div>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
            <div data-slot="sidebar-footer" data-sidebar="footer" class="flex flex-col gap-2 p-2"> Me </div>
            <button type="button"
                    data-sidebar="rail"
                    data-slot="sidebar-rail"
                    aria-label="Toggle Sidebar"
                    tabindex="-1"
                    title="Toggle Sidebar"
                    class="-translate-x-1/2 [[data-side=left][data-collapsible=offcanvas]_&]:-right-2 [[data-side=left][data-state=collapsed]_&]:cursor-e-resize [[data-side=right][data-collapsible=offcanvas]_&]:-left-2 [[data-side=right][data-state=collapsed]_&]:cursor-w-resize absolute after:absolute after:inset-y-0 after:left-1/2 after:w-[2px] ease-linear group-data-[collapsible=offcanvas]:after:left-full group-data-[collapsible=offcanvas]:translate-x-0 group-data-[side=left]:-right-4 group-data-[side=right]:left-0 hidden hover:after:bg-sidebar-border hover:group-data-[collapsible=offcanvas]:bg-sidebar in-data-[side=left]:cursor-w-resize in-data-[side=right]:cursor-e-resize inset-y-0 sm:flex transition-all w-4 z-20"
                    @on_click> </button>
          </div>
        </div>
      </div>
      <main data-slot="sidebar-inset"
            class="bg-background flex flex-1 flex-col md:peer-data-[variant=inset]:m-2 md:peer-data-[variant=inset]:ml-0 md:peer-data-[variant=inset]:peer-data-[state=collapsed]:ml-2 md:peer-data-[variant=inset]:rounded-xl md:peer-data-[variant=inset]:shadow-sm relative w-full">
        <button type="button"
                data-variant="ghost"
                data-size="icon"
                data-sidebar="trigger"
                data-slot="sidebar-trigger"
                class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 dark:hover:bg-accent/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none rounded-md shrink-0 size-7 text-sm transition-all whitespace-nowrap"
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
               class="lucide lucide-panel-left">
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
  [%expect {|
    <div data-slot="sidebar-gap"
         class="bg-transparent duration-200 ease-linear group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))] group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative transition-[width] w-(--sidebar-width)"> </div>
    <div data-slot="sidebar-container"
         class="duration-200 ease-linear fixed group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)] group-data-[collapsible=offcanvas]:right-[calc(var(--sidebar-width)*-1)] h-svh hidden inset-y-0 md:flex p-2 right-0 transition-[left,right,width] w-(--sidebar-width) z-10">
      <div data-sidebar="sidebar"
           data-slot="sidebar-inner"
           class="bg-sidebar flex flex-col group-data-[variant=floating]:border group-data-[variant=floating]:border-sidebar-border group-data-[variant=floating]:rounded-lg group-data-[variant=floating]:shadow-sm h-full w-full"> </div>
    </div>
    <div data-slot="sidebar-gap"
         class="bg-transparent duration-200 ease-linear group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4)))] group-data-[collapsible=offcanvas]:w-0 group-data-[side=right]:rotate-180 relative transition-[width] w-(--sidebar-width)"> </div>
    <div data-slot="sidebar-container"
         class="duration-200 ease-linear fixed group-data-[collapsible=icon]:w-[calc(var(--sidebar-width-icon)+(--spacing(4))+2px)] group-data-[collapsible=offcanvas]:left-[calc(var(--sidebar-width)*-1)] h-svh hidden inset-y-0 left-0 md:flex p-2 transition-[left,right,width] w-(--sidebar-width) z-10">
      <div data-sidebar="sidebar"
           data-slot="sidebar-inner"
           class="bg-sidebar flex flex-col group-data-[variant=floating]:border group-data-[variant=floating]:border-sidebar-border group-data-[variant=floating]:rounded-lg group-data-[variant=floating]:shadow-sm h-full w-full"> </div>
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
  [%expect {|
    <div data-slot="sidebar-wrapper"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <div data-state="expanded"
           data-collapsible=""
           data-variant="sidebar"
           data-side="left"
           data-slot="sidebar">
        <div data-slot="sidebar-gap"> </div>
        <div data-slot="sidebar-container">
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
                         @on_focus
                         @on_pointerenter>
                        <span> Home </span>
                      </a>
                      <div role="tooltip" data-slot="tooltip-content" data-side="right">
                        Home
                        <div> </div>
                      </div>
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
                data-size="icon"
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
               stroke-linejoin="round"
               aria-hidden="true">
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
  [%expect {|
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
          <div data-slot="sidebar-container">
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
  [%expect {|
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
          <div data-slot="sidebar-container">
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
  [%expect {|
    <div data-slot="sidebar-wrapper"
         custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
         @on_keydown_global>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <main data-slot="sidebar-inset">
        <button type="button"
                data-variant="ghost"
                data-size="icon"
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
               stroke-linejoin="round"
               aria-hidden="true">
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
  [%expect {|
      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    +|  <div>
    +|    <div data-state="open" data-slot="sheet-overlay" @on_click> </div>
    +|    <div tabindex="0" aria-hidden="true" @on_focus> </div>
    +|    <div id="sidebar-mobile"
    +|         role="dialog"
    +|         aria-modal="true"
    +|         aria-labelledby="sidebar-mobile-title"
    +|         aria-describedby="sidebar-mobile-description"
    +|         data-state="open"
    +|         tabindex="-1"
    +|         data-sidebar="sidebar"
    +|         data-slot="sidebar"
    +|         data-mobile="true"
    +|         custom-css-vars=((--sidebar-width 18rem))
    +|         loon-after-render-sidebar-mobile-focus=<opaque>
    +|         @on_keydown>
    +|      <div data-slot="sheet-header">
    +|        <h2 id="sidebar-mobile-title" data-slot="sheet-title"> Sidebar </h2>
    +|        <p id="sidebar-mobile-description" data-slot="sheet-description"> Displays the mobile sidebar. </p>
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
    +|                     @on_focus
    +|                     @on_pointerenter>
    +|                    <span> Home </span>
    +|                  </a>
    +|                  <div role="tooltip" data-slot="tooltip-content" data-side="right">
    +|                    Home
    +|                    <div> </div>
    +|                  </div>
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
    +|    </div>
    +|    <div tabindex="0" aria-hidden="true" @on_focus> </div>
    +|  </div>
        <main data-slot="sidebar-inset">
          <button type="button"
                  data-variant="ghost"
                  data-size="icon"
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
                 stroke-linejoin="round"
    |}];
  Drive.key handle "[data-mobile=true]" Escape;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key Escape))

      <div data-slot="sidebar-wrapper"
           custom-css-vars=((--sidebar-width 16rem)(--sidebar-width-icon 3rem))
           @on_keydown_global>
    -|  <div>
    -|    <div data-state="open" data-slot="sheet-overlay" @on_click> </div>
    -|    <div tabindex="0" aria-hidden="true" @on_focus> </div>
    -|    <div id="sidebar-mobile"
    -|         role="dialog"
    -|         aria-modal="true"
    -|         aria-labelledby="sidebar-mobile-title"
    -|         aria-describedby="sidebar-mobile-description"
    -|         data-state="open"
    -|         tabindex="-1"
    -|         data-sidebar="sidebar"
    -|         data-slot="sidebar"
    -|         data-mobile="true"
    -|         custom-css-vars=((--sidebar-width 18rem))
    -|         loon-after-render-sidebar-mobile-focus=<opaque>
    -|         @on_keydown>
    -|      <div data-slot="sheet-header">
    -|        <h2 id="sidebar-mobile-title" data-slot="sheet-title"> Sidebar </h2>
    -|        <p id="sidebar-mobile-description" data-slot="sheet-description"> Displays the mobile sidebar. </p>
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
    -|                     @on_focus
    -|                     @on_pointerenter>
    -|                    <span> Home </span>
    -|                  </a>
    -|                  <div role="tooltip" data-slot="tooltip-content" data-side="right">
    -|                    Home
    -|                    <div> </div>
    -|                  </div>
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
    -|    </div>
    -|    <div tabindex="0" aria-hidden="true" @on_focus> </div>
    -|  </div>
    +|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        <main data-slot="sidebar-inset">
          <button type="button"
                  data-variant="ghost"
                  data-size="icon"
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
                 stroke-linejoin="round"
    |}];
  (* A click on the overlay closes it too. *)
  Drive.click handle "[data-slot=sidebar-trigger]";
  Drive.click handle "[data-slot=sheet-overlay]";
  Handle.show_diff handle;
  [%expect {| |}]
;;
