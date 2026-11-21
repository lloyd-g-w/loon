open! Core
open Loon
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let trigger = "[data-slot=context-menu-trigger]"
let content = "[data-slot=context-menu-content]"
let print h = Menu_probe.print ~triggers:trigger h
let choose text = Effect.of_thunk (fun () -> printf "chose %s\n" text)

let menu (local_ graph) =
  let bookmarks, set_bookmarks = Bonsai.state true graph in
  let person, set_person = Bonsai.state "pedro" graph in
  Context_menu.component
    (let%arr bookmarks and set_bookmarks and person and set_person in
     fun menu ->
       [ Context_menu.trigger
           menu
           ~class_:"flex h-[150px] w-[300px]"
           [ Node.text "Right click here" ]
       ; Context_menu.content
           menu
           ~class_:"w-52"
           [ Context_menu.item
               ~inset:true
               ~on_select:(choose "Back")
               [ Node.text "Back"; Context_menu.shortcut [ Node.text "⌘[" ] ]
           ; Context_menu.item ~inset:true ~disabled:true [ Node.text "Forward" ]
           ; Context_menu.item ~inset:true ~on_select:(choose "Reload") [ Node.text "Reload" ]
           ; Context_menu.sub
               (Context_menu.sub_trigger ~inset:true [ Node.text "More Tools" ])
               (Context_menu.sub_content
                  ~class_:"w-44"
                  [ Context_menu.item [ Node.text "Save Page..." ]
                  ; Context_menu.item [ Node.text "Developer Tools" ]
                  ])
           ; Context_menu.separator ()
           ; Context_menu.checkbox_item
               ~checked:bookmarks
               ~on_checked_change:set_bookmarks
               [ Node.text "Show Bookmarks" ]
           ; Context_menu.radio_group
               ~value:person
               ~on_value_change:set_person
               [ Context_menu.label ~inset:true [ Node.text "People" ]
               ; Context_menu.radio_item ~value:"pedro" [ Node.text "Pedro Duarte" ]
               ; Context_menu.radio_item ~value:"colm" [ Node.text "Colm Tuite" ]
               ]
           ]
       ])
    graph
;;

let%expect_test "shadcn's classes" =
  let handle =
    Render.handle (fun _graph ->
      Context_menu.view
        ~state:(Open { x = 10.; y = 20.; menu = Menu.State.initial })
        ~on_change:(fun _ -> Effect.Ignore)
        (fun menu ->
          [ Context_menu.trigger menu [ Node.text "Right click here" ]
          ; Context_menu.content
              menu
              [ Context_menu.label [ Node.text "Label" ]
              ; Context_menu.item ~variant:Destructive [ Node.text "Delete" ]
              ; Context_menu.sub
                  (Context_menu.sub_trigger [ Node.text "More" ])
                  (Context_menu.sub_content [ Context_menu.item [ Node.text "x" ] ])
              ]
          ])
      |> Bonsai.return)
  in
  Handle.show handle;
  [%expect {|
    <div>
      <span data-slot="context-menu-trigger"
            id="context-menu-trigger"
            data-state="open"
            @on_contextmenu
            style={
              -webkit-touch-callout: none;
            }> Right click here </span>
      <div loon-dismiss=(()false true)
           loon-presence=()
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Right)(side_offset 2)(align Start)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Point(x 10)(y 20)))(name context-menu)))
             style={
               inset: auto;
               margin: 0;
               border: 0;
               padding: 0;
               background: transparent;
               color: inherit;
               overflow: visible;
               max-width: none;
               max-height: none;
               white-space: normal;
               text-align: start;
               font-weight: normal;
               font-style: normal;
               letter-spacing: normal;
               text-transform: none;
             }>
          <div data-slot="context-menu-content"
               id="context-menu-content"
               role="menu"
               aria-orientation="vertical"
               data-state="open"
               tabindex="-1"
               data-side="right"
               data-align="start"
               class="bg-popover border data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 max-h-(--radix-context-menu-content-available-height) min-w-[8rem] origin-(--radix-context-menu-content-transform-origin) overflow-x-hidden overflow-y-auto p-1 rounded-md shadow-md text-popover-foreground z-50"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="context-menu-label"
                 class="data-[inset]:pl-8 font-medium px-2 py-1.5 text-foreground text-sm"> Label </div>
            <div data-slot="context-menu-item"
                 data-variant="destructive"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 cursor-default dark:data-[variant=destructive]:focus:bg-destructive/20 data-[disabled]:opacity-50 data-[disabled]:pointer-events-none data-[inset]:pl-8 data-[variant=destructive]:*:[svg]:text-destructive! data-[variant=destructive]:focus:bg-destructive/10 data-[variant=destructive]:focus:text-destructive data-[variant=destructive]:text-destructive flex focus:bg-accent focus:text-accent-foreground gap-2 items-center outline-hidden px-2 py-1.5 relative rounded-sm select-none text-sm"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Delete </div>
            <div data-slot="context-menu-sub-trigger"
                 id="context-menu-sub-1-trigger"
                 role="menuitem"
                 aria-haspopup="menu"
                 aria-expanded="false"
                 data-state="closed"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 cursor-default data-[inset]:pl-8 data-[state=open]:bg-accent data-[state=open]:text-accent-foreground flex focus:bg-accent focus:text-accent-foreground items-center outline-hidden px-2 py-1.5 rounded-sm select-none text-sm"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              More
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
                   class="lucide lucide-chevron-right ml-auto">
                <path d="m9 18 6-6-6-6"> </path>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "a right click opens it at the pointer; Esc closes it" =
  let handle = Render.handle ~classes:false menu in
  print handle;
  [%expect {|
    trigger Right click here state=closed
    closed
    |}];
  Menu_probe.right_click handle trigger ~client_x:120. ~client_y:40.;
  Handle.show handle;
  [%expect {|
    (default prevented)
    <div>
      <span data-slot="context-menu-trigger"
            id="bonsai_path_replaced_in_test-trigger"
            data-state="open"
            @on_contextmenu
            style={
              -webkit-touch-callout: none;
            }> Right click here </span>
      <div loon-dismiss=(()false true)
           loon-presence=()
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Right)(side_offset 2)(align Start)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Point(x 120)(y 40)))(name context-menu)))
             style={
               inset: auto;
               margin: 0;
               border: 0;
               padding: 0;
               background: transparent;
               color: inherit;
               overflow: visible;
               max-width: none;
               max-height: none;
               white-space: normal;
               text-align: start;
               font-weight: normal;
               font-style: normal;
               letter-spacing: normal;
               text-transform: none;
             }>
          <div data-slot="context-menu-content"
               id="bonsai_path_replaced_in_test-content"
               role="menu"
               aria-orientation="vertical"
               data-state="open"
               tabindex="-1"
               data-side="right"
               data-align="start"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="context-menu-item"
                 data-inset=""
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              Back
              <span data-slot="context-menu-shortcut"> ⌘[ </span>
            </div>
            <div data-slot="context-menu-item"
                 data-inset=""
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 aria-disabled="true"
                 data-disabled=""
                 loon-focus-when=false
                 @on_mouseleave
                 @on_mousemove> Forward </div>
            <div data-slot="context-menu-item"
                 data-inset=""
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Reload </div>
            <div data-slot="context-menu-sub-trigger"
                 data-inset=""
                 id="bonsai_path_replaced_in_test-sub-3-trigger"
                 role="menuitem"
                 aria-haspopup="menu"
                 aria-expanded="false"
                 data-state="closed"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              More Tools
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
                <path d="m9 18 6-6-6-6"> </path>
              </svg>
            </div>
            <div data-slot="context-menu-separator" role="separator" aria-orientation="horizontal"> </div>
            <div data-slot="context-menu-checkbox-item"
                 role="menuitemcheckbox"
                 aria-checked="true"
                 data-state="checked"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              <span>
                <span data-state="checked">
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
                    <path d="M20 6 9 17l-5-5"> </path>
                  </svg>
                </span>
              </span>
              Show Bookmarks
            </div>
            <div data-slot="context-menu-radio-group" role="group">
              <div data-slot="context-menu-label" data-inset=""> People </div>
              <div data-slot="context-menu-radio-item"
                   role="menuitemradio"
                   aria-checked="true"
                   data-state="checked"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                <span>
                  <span data-state="checked">
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
                      <circle cx="12" cy="12" r="10"> </circle>
                    </svg>
                  </span>
                </span>
                Pedro Duarte
              </div>
              <div data-slot="context-menu-radio-item"
                   role="menuitemradio"
                   aria-checked="false"
                   data-state="unchecked"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                <span> </span>
                Colm Tuite
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle content Escape;
  print handle;
  [%expect {|
    ("default prevented" (key Escape))
    trigger Right click here state=closed
    closed
    |}]
;;

let%expect_test "the keyboard: arrows skip disabled items, sub-menus, choosing" =
  let handle = Render.handle ~classes:false menu in
  Menu_probe.right_click handle trigger ~client_x:0. ~client_y:0.;
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowDown;
  print handle;
  [%expect {|
    (default prevented)
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    trigger Right click here state=open
    context-menu-content
        Back ⌘[
        Forward disabled
      > Reload
        More Tools state=closed
        Show Bookmarks state=checked checked=true
        Pedro Duarte state=checked checked=true
        Colm Tuite state=unchecked checked=false
    |}];
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowRight;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowRight))
    trigger Right click here state=open
    context-menu-content
        Back ⌘[
        Forward disabled
        Reload
        More Tools state=open
        Show Bookmarks state=checked checked=true
        Pedro Duarte state=checked checked=true
        Colm Tuite state=unchecked checked=false
    context-menu-sub-content
      > Save Page...
        Developer Tools
    |}];
  Drive.key handle "[data-slot=context-menu-sub-content]" ArrowLeft;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowLeft))
    trigger Right click here state=open
    context-menu-content
        Back ⌘[
        Forward disabled
        Reload
      > More Tools state=closed
        Show Bookmarks state=checked checked=true
        Pedro Duarte state=checked checked=true
        Colm Tuite state=unchecked checked=false
    |}];
  Drive.key handle content KeyC;
  Drive.key handle content Space;
  print handle;
  [%expect {|
    ("default prevented" (key KeyC))
    ("default prevented" (key Space))
    trigger Right click here state=closed
    closed
    |}];
  Menu_probe.right_click handle trigger ~client_x:0. ~client_y:0.;
  Drive.click handle "[data-slot=context-menu-checkbox-item]";
  Menu_probe.right_click handle trigger ~client_x:0. ~client_y:0.;
  print handle;
  [%expect {|
    (default prevented)
    (default prevented)
    trigger Right click here state=open
    context-menu-content
        Back ⌘[
        Forward disabled
        Reload
        More Tools state=closed
        Show Bookmarks state=unchecked checked=false
        Pedro Duarte state=unchecked checked=false
        Colm Tuite state=checked checked=true
    |}];
  Drive.click handle "[data-slot=context-menu-item]";
  print handle;
  [%expect {|
    chose Back
    trigger Right click here state=closed
    closed
    |}]
;;
