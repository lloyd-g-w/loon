open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts nav =
  [ Navigation_menu.list
      nav
      [ Navigation_menu.item
          [ Navigation_menu.trigger nav ~value:"home" [ Node.text "Home" ]
          ; Navigation_menu.content
              nav
              ~value:"home"
              [ Navigation_menu.link ~href:"/intro" [ Node.text "Introduction" ]
              ]
          ]
      ; Navigation_menu.item
          [ Navigation_menu.trigger
              nav
              ~value:"components"
              [ Node.text "Components" ]
          ; Navigation_menu.content
              nav
              ~value:"components"
              [ Navigation_menu.link ~href:"/tabs" [ Node.text "Tabs" ] ]
          ]
      ; Navigation_menu.item
          [ Navigation_menu.link
              ~active:true
              ~class_:(Navigation_menu.trigger_style ())
              ~href:"/docs"
              [ Node.text "Docs" ]
          ]
      ; Navigation_menu.indicator nav
      ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Navigation_menu.view
       ~value:(Some "home")
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       parts);
  [%expect
    {|
    <nav id="navigation-menu"
         aria-label="Main"
         data-orientation="horizontal"
         dir="ltr"
         data-slot="navigation-menu"
         data-viewport="true"
         class="cn-navigation-menu flex flex-1 group/navigation-menu items-center justify-center max-w-max relative"
         @on_focusin_global
         @on_mousedown_global
         @on_click
         @on_keydown>
      <div style={ position: relative; }>
        <ul data-orientation="horizontal"
            dir="ltr"
            data-slot="navigation-menu-list"
            class="cn-navigation-menu-list flex flex-1 group items-center justify-center list-none"
            @on_keydown>
          <li data-slot="navigation-menu-item" class="cn-navigation-menu-item relative">
            <button id="navigation-menu-trigger-home"
                    type="button"
                    data-state="open"
                    aria-expanded="true"
                    aria-controls="navigation-menu-content-home"
                    data-slot="navigation-menu-trigger"
                    class="cn-navigation-menu-trigger disabled:pointer-events-none group group/navigation-menu-trigger h-9 inline-flex items-center justify-center outline-none w-max"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Home

              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="cn-navigation-menu-trigger-icon lucide lucide-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </li>
          <li data-slot="navigation-menu-item" class="cn-navigation-menu-item relative">
            <button id="navigation-menu-trigger-components"
                    type="button"
                    data-state="closed"
                    aria-expanded="false"
                    data-slot="navigation-menu-trigger"
                    class="cn-navigation-menu-trigger disabled:pointer-events-none group group/navigation-menu-trigger h-9 inline-flex items-center justify-center outline-none w-max"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Components

              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="cn-navigation-menu-trigger-icon lucide lucide-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </li>
          <li data-slot="navigation-menu-item" class="cn-navigation-menu-item relative">
            <a aria-current="page"
               data-active="true"
               data-slot="navigation-menu-link"
               href="/docs"
               class="cn-navigation-menu-link cn-navigation-menu-trigger disabled:pointer-events-none group/navigation-menu-trigger h-9 inline-flex items-center justify-center outline-none w-max"> Docs </a>
          </li>
          <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        </ul>
        <div aria-hidden="true"
             data-state="visible"
             data-orientation="horizontal"
             data-slot="navigation-menu-indicator"
             class="cn-navigation-menu-indicator flex h-1.5 items-end justify-center overflow-hidden top-full z-1"
             loon-after-render-navigation-menu-indicator=<opaque>
             style={
               position: absolute;
               left: 0px;
             }>
          <div class="cn-navigation-menu-indicator-arrow h-2 relative rotate-45 top-[60%] w-2"> </div>
        </div>
      </div>
      <div class="absolute cn-navigation-menu-viewport-wrapper flex isolate justify-center left-0 top-full z-50">
        <div data-state="open"
             data-orientation="horizontal"
             data-slot="navigation-menu-viewport"
             class="cn-navigation-menu-viewport h-(--radix-navigation-menu-viewport-height) md:w-(--radix-navigation-menu-viewport-width) mt-1.5 origin-top-center overflow-hidden relative w-full"
             loon-after-render-navigation-menu-viewport=<opaque>
             @on_pointerenter
             @on_pointerleave>
          <div id="navigation-menu-content-home"
               aria-labelledby="navigation-menu-trigger-home"
               data-orientation="horizontal"
               data-state="open"
               data-slot="navigation-menu-content"
               class="**:data-[slot=navigation-menu-link]:focus:outline-none **:data-[slot=navigation-menu-link]:focus:ring-0 cn-navigation-menu-content group-data-[viewport=false]/navigation-menu:mt-1.5 group-data-[viewport=false]/navigation-menu:overflow-hidden group-data-[viewport=false]/navigation-menu:top-full left-0 md:absolute md:w-auto top-0 w-full"
               @on_keydown>
            <a data-slot="navigation-menu-link" href="/intro" class="cn-navigation-menu-link"> Introduction </a>
          </div>
        </div>
      </div>
    </nav>
    |}]
;;

let%expect_test "triggers open their content in the viewport; Esc closes it" =
  let handle =
    Render.handle
      ~classes:false
      (Navigation_menu.component (Bonsai_web.Bonsai.return parts))
  in
  Handle.show handle;
  [%expect
    {|
    <nav id="bonsai_path_replaced_in_test"
         aria-label="Main"
         data-orientation="horizontal"
         dir="ltr"
         data-slot="navigation-menu"
         data-viewport="true"
         @on_click
         @on_keydown>
      <div style={ position: relative; }>
        <ul data-orientation="horizontal" dir="ltr" data-slot="navigation-menu-list" @on_keydown>
          <li data-slot="navigation-menu-item">
            <button id="bonsai_path_replaced_in_test-trigger-home"
                    type="button"
                    data-state="closed"
                    aria-expanded="false"
                    data-slot="navigation-menu-trigger"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Home

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
            </button>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </li>
          <li data-slot="navigation-menu-item">
            <button id="bonsai_path_replaced_in_test-trigger-components"
                    type="button"
                    data-state="closed"
                    aria-expanded="false"
                    data-slot="navigation-menu-trigger"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Components

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
            </button>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </li>
          <li data-slot="navigation-menu-item">
            <a aria-current="page" data-active="true" data-slot="navigation-menu-link" href="/docs"> Docs </a>
          </li>
          <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        </ul>
      </div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </nav>
    |}];
  Drive.click handle "[id$=trigger-home]";
  Handle.show_diff handle;
  [%expect
    {|
      <nav id="bonsai_path_replaced_in_test"
           aria-label="Main"
           data-orientation="horizontal"
           dir="ltr"
           data-slot="navigation-menu"
           data-viewport="true"
    +|     @on_focusin_global
    +|     @on_mousedown_global
           @on_click
           @on_keydown>
        <div style={ position: relative; }>
          <ul data-orientation="horizontal" dir="ltr" data-slot="navigation-menu-list" @on_keydown>
            <li data-slot="navigation-menu-item">
              <button id="bonsai_path_replaced_in_test-trigger-home"
                      type="button"
    -|                data-state="closed"
    +|                data-state="open"
    -|                aria-expanded="false"
    +|                aria-expanded="true"
    +|                aria-controls="bonsai_path_replaced_in_test-content-home"
                      data-slot="navigation-menu-trigger"
                      @on_click
                      @on_keydown
                      @on_pointerenter
                      @on_pointerleave>
                Home

                <svg xmlns="http://www.w3.org/2000/svg"
                     width="24"
                     height="24"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">

                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">
                  <path d="m6 9 6 6 6-6"> </path>
                </svg>
              </button>
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            </li>
            <li data-slot="navigation-menu-item">
              <a aria-current="page" data-active="true" data-slot="navigation-menu-link" href="/docs"> Docs </a>
            </li>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </ul>
    -|  </div>
    -|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    +|    <div aria-hidden="true"
    +|         data-state="visible"
    +|         data-orientation="horizontal"
    +|         data-slot="navigation-menu-indicator"
    +|         loon-after-render-navigation-menu-indicator=<opaque>
    +|         style={
    +|           position: absolute;
    +|           left: 0px;
    +|         }>
    +|      <div> </div>
    +|    </div>
    +|  </div>
    +|  <div>
    +|    <div data-state="open"
    +|         data-orientation="horizontal"
    +|         data-slot="navigation-menu-viewport"
    +|         loon-after-render-navigation-menu-viewport=<opaque>
    +|         @on_pointerenter
    +|         @on_pointerleave>
    +|      <div id="bonsai_path_replaced_in_test-content-home"
    +|           aria-labelledby="bonsai_path_replaced_in_test-trigger-home"
    +|           data-orientation="horizontal"
    +|           data-state="open"
    +|           data-slot="navigation-menu-content"
    +|           @on_keydown>
    +|        <a data-slot="navigation-menu-link" href="/intro"> Introduction </a>
    +|      </div>
    +|    </div>
    +|  </div>
      </nav>
    |}];
  (* Another trigger: its content slides in from the end. *)
  Drive.click handle "[id$=trigger-components]";
  Handle.show_diff handle;
  [%expect
    {|
      <nav id="bonsai_path_replaced_in_test"
           aria-label="Main"
           data-orientation="horizontal"
           dir="ltr"
           data-slot="navigation-menu"
           data-viewport="true"
           @on_focusin_global
           @on_mousedown_global
           @on_click
           @on_keydown>
        <div style={ position: relative; }>
          <ul data-orientation="horizontal" dir="ltr" data-slot="navigation-menu-list" @on_keydown>
            <li data-slot="navigation-menu-item">
              <button id="bonsai_path_replaced_in_test-trigger-home"
                      type="button"
    -|                data-state="open"
    +|                data-state="closed"
    -|                aria-expanded="true"
    -|                aria-controls="bonsai_path_replaced_in_test-content-home"
    +|                aria-expanded="false"
                      data-slot="navigation-menu-trigger"
                      @on_click
                      @on_keydown
                      @on_pointerenter
                      @on_pointerleave>
                Home

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
              </button>
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            </li>
            <li data-slot="navigation-menu-item">
              <button id="bonsai_path_replaced_in_test-trigger-components"
                      type="button"
    -|                data-state="closed"
    +|                data-state="open"
    -|                aria-expanded="false"
    +|                aria-expanded="true"
    +|                aria-controls="bonsai_path_replaced_in_test-content-components"
                      data-slot="navigation-menu-trigger"
                      @on_click
                      @on_keydown
                      @on_pointerenter
                      @on_pointerleave>
                Components

                <svg xmlns="http://www.w3.org/2000/svg"
                     width="24"
                     height="24"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">

               data-slot="navigation-menu-indicator"
               loon-after-render-navigation-menu-indicator=<opaque>
               style={
                 position: absolute;
                 left: 0px;
               }>
            <div> </div>
          </div>
        </div>
        <div>
          <div data-state="open"
               data-orientation="horizontal"
               data-slot="navigation-menu-viewport"
               loon-after-render-navigation-menu-viewport=<opaque>
               @on_pointerenter
               @on_pointerleave>
    -|      <div id="bonsai_path_replaced_in_test-content-home"
    +|      <div id="bonsai_path_replaced_in_test-content-components"
    -|           aria-labelledby="bonsai_path_replaced_in_test-trigger-home"
    +|           aria-labelledby="bonsai_path_replaced_in_test-trigger-components"
                 data-orientation="horizontal"
                 data-state="open"
                 data-slot="navigation-menu-content"
                 @on_keydown>
    -|        <a data-slot="navigation-menu-link" href="/intro"> Introduction </a>
    +|        <a data-slot="navigation-menu-link" href="/tabs"> Tabs </a>
            </div>
          </div>
        </div>
      </nav>
    |}];
  Drive.key handle "nav" Escape;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key Escape))

      <nav id="bonsai_path_replaced_in_test"
           aria-label="Main"
           data-orientation="horizontal"
           dir="ltr"
           data-slot="navigation-menu"
           data-viewport="true"
    -|     @on_focusin_global
    -|     @on_mousedown_global
           @on_click
           @on_keydown>
        <div style={ position: relative; }>
          <ul data-orientation="horizontal" dir="ltr" data-slot="navigation-menu-list" @on_keydown>
            <li data-slot="navigation-menu-item">
              <button id="bonsai_path_replaced_in_test-trigger-home"
                      type="button"
                      data-state="closed"
                      aria-expanded="false"
                      data-slot="navigation-menu-trigger"
                      @on_click
                      @on_keydown
                      @on_pointerenter
                      @on_pointerleave>
                Home


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
              </button>
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            </li>
            <li data-slot="navigation-menu-item">
              <button id="bonsai_path_replaced_in_test-trigger-components"
                      type="button"
    -|                data-state="open"
    +|                data-state="closed"
    -|                aria-expanded="true"
    -|                aria-controls="bonsai_path_replaced_in_test-content-components"
    +|                aria-expanded="false"
                      data-slot="navigation-menu-trigger"
                      @on_click
                      @on_keydown
                      @on_pointerenter
                      @on_pointerleave>
                Components

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
              </button>
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            </li>
            <li data-slot="navigation-menu-item">
              <a aria-current="page" data-active="true" data-slot="navigation-menu-link" href="/docs"> Docs </a>
            </li>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </ul>
    -|    <div aria-hidden="true"
    -|         data-state="visible"
    -|         data-orientation="horizontal"
    -|         data-slot="navigation-menu-indicator"
    -|         loon-after-render-navigation-menu-indicator=<opaque>
    -|         style={
    -|           position: absolute;
    -|           left: 0px;
    -|         }>
    -|      <div> </div>
    -|    </div>
    -|  </div>
    -|  <div>
    -|    <div data-state="open"
    -|         data-orientation="horizontal"
    -|         data-slot="navigation-menu-viewport"
    -|         loon-after-render-navigation-menu-viewport=<opaque>
    -|         @on_pointerenter
    -|         @on_pointerleave>
    -|      <div id="bonsai_path_replaced_in_test-content-components"
    -|           aria-labelledby="bonsai_path_replaced_in_test-trigger-components"
    -|           data-orientation="horizontal"
    -|           data-state="open"
    -|           data-slot="navigation-menu-content"
    -|           @on_keydown>
    -|        <a data-slot="navigation-menu-link" href="/tabs"> Tabs </a>
    -|      </div>
    -|    </div>
    -|  </div>
    +|  </div>
    +|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </nav>
    |}];
  (* Clicking an open trigger closes it. *)
  Drive.click handle "[id$=trigger-home]";
  Drive.click handle "[id$=trigger-home]";
  Handle.show_diff handle;
  [%expect {| |}]
;;

let%expect_test "without a viewport, the content drops down in its item" =
  let handle =
    Render.handle
      ~classes:false
      (Navigation_menu.component
         ~viewport:false
         ~default_value:"components"
         (Bonsai_web.Bonsai.return parts))
  in
  Handle.show handle;
  [%expect
    {|
    <nav id="bonsai_path_replaced_in_test"
         aria-label="Main"
         data-orientation="horizontal"
         dir="ltr"
         data-slot="navigation-menu"
         data-viewport="false"
         @on_focusin_global
         @on_mousedown_global
         @on_click
         @on_keydown>
      <div style={ position: relative; }>
        <ul data-orientation="horizontal" dir="ltr" data-slot="navigation-menu-list" @on_keydown>
          <li data-slot="navigation-menu-item">
            <button id="bonsai_path_replaced_in_test-trigger-home"
                    type="button"
                    data-state="closed"
                    aria-expanded="false"
                    data-slot="navigation-menu-trigger"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Home

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
            </button>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </li>
          <li data-slot="navigation-menu-item">
            <button id="bonsai_path_replaced_in_test-trigger-components"
                    type="button"
                    data-state="open"
                    aria-expanded="true"
                    aria-controls="bonsai_path_replaced_in_test-content-components"
                    data-slot="navigation-menu-trigger"
                    @on_click
                    @on_keydown
                    @on_pointerenter
                    @on_pointerleave>
              Components

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
            </button>
            <div id="bonsai_path_replaced_in_test-content-components"
                 aria-labelledby="bonsai_path_replaced_in_test-trigger-components"
                 data-orientation="horizontal"
                 data-state="open"
                 data-slot="navigation-menu-content"
                 loon-presence=()
                 @on_keydown
                 @on_pointerenter
                 @on_pointerleave>
              <a data-slot="navigation-menu-link" href="/tabs"> Tabs </a>
            </div>
          </li>
          <li data-slot="navigation-menu-item">
            <a aria-current="page" data-active="true" data-slot="navigation-menu-link" href="/docs"> Docs </a>
          </li>
          <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        </ul>
        <div aria-hidden="true"
             data-state="visible"
             data-orientation="horizontal"
             data-slot="navigation-menu-indicator"
             loon-after-render-navigation-menu-indicator=<opaque>
             style={
               position: absolute;
               left: 0px;
             }>
          <div> </div>
        </div>
      </div>
    </nav>
    |}]
;;
