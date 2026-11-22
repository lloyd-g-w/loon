open! Core
open Loon
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let trigger = "button[aria-haspopup=menu]"
let content = "[data-slot=dropdown-menu-content]"
let sub_content = "[data-slot=dropdown-menu-sub-content]"
let print h = Menu_probe.print ~triggers:trigger h

let choose text = Effect.of_thunk (fun () -> printf "chose %s\n" text)

let menu (local_ graph) =
  let status_bar, set_status_bar = Bonsai.state true graph in
  let position, set_position = Bonsai.state "bottom" graph in
  Dropdown_menu.component
    (let%arr status_bar and set_status_bar and position and set_position in
     fun menu ->
       let item ?disabled text =
         Dropdown_menu.item ?disabled ~on_select:(choose text) [ Node.text text ]
       in
       [ Dropdown_menu.trigger menu (Button.view [ Node.text "Open" ])
       ; Dropdown_menu.content
           menu
           [ Dropdown_menu.label [ Node.text "My Account" ]
           ; Dropdown_menu.group
               [ Dropdown_menu.item
                   ~on_select:(choose "Profile")
                   [ Node.text "Profile"; Dropdown_menu.shortcut [ Node.text "⇧⌘P" ] ]
               ; item "Billing"
               ; item ~disabled:true "API"
               ; Dropdown_menu.sub
                   (Dropdown_menu.sub_trigger [ Node.text "Invite users" ])
                   (Dropdown_menu.sub_content [ item "Email"; item "Message" ])
               ]
           ; Dropdown_menu.separator ()
           ; Dropdown_menu.checkbox_item
               ~checked:status_bar
               ~on_checked_change:set_status_bar
               [ Node.text "Status Bar" ]
           ; Dropdown_menu.radio_group
               ~value:position
               ~on_value_change:set_position
               [ Dropdown_menu.radio_item ~value:"top" [ Node.text "Top" ]
               ; Dropdown_menu.radio_item ~value:"bottom" [ Node.text "Bottom" ]
               ]
           ; item "Log out"
           ]
       ])
    graph
;;

let%expect_test "shadcn's classes" =
  let handle =
    Render.handle (fun graph ->
      Dropdown_menu.component
        ~default_open:true
        (Bonsai.return (fun menu ->
           [ Dropdown_menu.trigger menu (Button.view [ Node.text "Open" ])
           ; Dropdown_menu.content
               menu
               [ Dropdown_menu.label ~inset:true [ Node.text "Label" ]
               ; Dropdown_menu.item
                   ~variant:Destructive
                   [ Node.text "Delete"; Dropdown_menu.shortcut [ Node.text "⌘⌫" ] ]
               ; Dropdown_menu.checkbox_item
                   ~checked:true
                   ~on_checked_change:(fun _ -> Effect.Ignore)
                   [ Node.text "Check" ]
               ; Dropdown_menu.radio_group
                   ~value:"a"
                   ~on_value_change:(fun _ -> Effect.Ignore)
                   [ Dropdown_menu.radio_item ~value:"a" [ Node.text "A" ] ]
               ; Dropdown_menu.separator ()
               ; Dropdown_menu.sub
                   (Dropdown_menu.sub_trigger [ Node.text "More" ])
                   (Dropdown_menu.sub_content [ Dropdown_menu.item [ Node.text "x" ] ])
               ]
           ]))
        graph)
  in
  Handle.show handle;
  [%expect {|
    <div>
      <button type="button"
              data-slot="dropdown-menu-trigger"
              data-variant="default"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-default disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
              @on_click
              @on_keydown> Open </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false true)
           loon-presence=()
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name dropdown-menu)))
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
          <div data-slot="dropdown-menu-content"
               id="bonsai_path_replaced_in_test-content"
               role="menu"
               aria-orientation="vertical"
               aria-labelledby="bonsai_path_replaced_in_test-trigger"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               class="cn-dropdown-menu-content cn-menu-target cn-menu-translucent data-[state=closed]:overflow-hidden max-h-(--radix-dropdown-menu-content-available-height) origin-(--radix-dropdown-menu-content-transform-origin) overflow-x-hidden overflow-y-auto w-(--radix-dropdown-menu-trigger-width) z-50"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="dropdown-menu-label" data-inset="" class="cn-dropdown-menu-label"> Label </div>
            <div data-slot="dropdown-menu-item"
                 data-variant="destructive"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-dropdown-menu-item cursor-default data-disabled:opacity-50 data-disabled:pointer-events-none flex group/dropdown-menu-item items-center outline-hidden relative select-none"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              Delete
              <span data-slot="dropdown-menu-shortcut" class="cn-dropdown-menu-shortcut"> ⌘⌫ </span>
            </div>
            <div data-slot="dropdown-menu-checkbox-item"
                 role="menuitemcheckbox"
                 aria-checked="true"
                 data-state="checked"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-dropdown-menu-checkbox-item cursor-default data-disabled:opacity-50 data-disabled:pointer-events-none flex items-center outline-hidden relative select-none"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              <span data-slot="dropdown-menu-checkbox-item-indicator"
                    class="cn-dropdown-menu-item-indicator pointer-events-none">
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
                       class="lucide lucide-check">
                    <path d="M20 6 9 17l-5-5"> </path>
                  </svg>
                </span>
              </span>
              Check
            </div>
            <div data-slot="dropdown-menu-radio-group" role="group">
              <div data-slot="dropdown-menu-radio-item"
                   role="menuitemradio"
                   aria-checked="true"
                   data-state="checked"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-dropdown-menu-radio-item cursor-default data-disabled:opacity-50 data-disabled:pointer-events-none flex items-center outline-hidden relative select-none"
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                <span data-slot="dropdown-menu-radio-item-indicator"
                      class="cn-dropdown-menu-item-indicator pointer-events-none">
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
                         class="lucide lucide-check">
                      <path d="M20 6 9 17l-5-5"> </path>
                    </svg>
                  </span>
                </span>
                A
              </div>
            </div>
            <div data-slot="dropdown-menu-separator"
                 role="separator"
                 aria-orientation="horizontal"
                 class="cn-dropdown-menu-separator"> </div>
            <div data-slot="dropdown-menu-sub-trigger"
                 id="bonsai_path_replaced_in_test-sub-3-trigger"
                 role="menuitem"
                 aria-haspopup="menu"
                 aria-expanded="false"
                 data-state="closed"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-dropdown-menu-sub-trigger cursor-default flex items-center outline-hidden select-none"
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
                   class="cn-rtl-flip lucide lucide-chevron-right ml-auto">
                <path d="m9 18 6-6-6-6"> </path>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "a click opens it, without a highlight; Esc closes it" =
  let handle = Render.handle ~classes:false menu in
  print handle;
  [%expect {|
    trigger Open state=closed
    closed
    |}];
  Drive.click handle trigger;
  Handle.show handle;
  [%expect {|
    <div>
      <button type="button"
              data-slot="dropdown-menu-trigger"
              data-variant="default"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click
              @on_keydown> Open </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false true)
           loon-presence=()
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name dropdown-menu)))
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
          <div data-slot="dropdown-menu-content"
               id="bonsai_path_replaced_in_test-content"
               role="menu"
               aria-orientation="vertical"
               aria-labelledby="bonsai_path_replaced_in_test-trigger"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="dropdown-menu-label"> My Account </div>
            <div data-slot="dropdown-menu-group" role="group">
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                Profile
                <span data-slot="dropdown-menu-shortcut"> ⇧⌘P </span>
              </div>
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove> Billing </div>
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   aria-disabled="true"
                   data-disabled=""
                   loon-focus-when=false
                   @on_mouseleave
                   @on_mousemove> API </div>
              <div data-slot="dropdown-menu-sub-trigger"
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
                Invite users
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
              </div>
            </div>
            <div data-slot="dropdown-menu-separator" role="separator" aria-orientation="horizontal"> </div>
            <div data-slot="dropdown-menu-checkbox-item"
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
              <span data-slot="dropdown-menu-checkbox-item-indicator">
                <span data-state="checked">
                  <svg xmlns="http://www.w3.org/2000/svg"
                       width="24"
                       height="24"
                       viewBox="0 0 24 24"
                       fill="none"
                       stroke="currentColor"
                       stroke-width="2"
                       stroke-linecap="round"
                       stroke-linejoin="round">
                    <path d="M20 6 9 17l-5-5"> </path>
                  </svg>
                </span>
              </span>
              Status Bar
            </div>
            <div data-slot="dropdown-menu-radio-group" role="group">
              <div data-slot="dropdown-menu-radio-item"
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
                <span data-slot="dropdown-menu-radio-item-indicator"> </span>
                Top
              </div>
              <div data-slot="dropdown-menu-radio-item"
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
                <span data-slot="dropdown-menu-radio-item-indicator">
                  <span data-state="checked">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         width="24"
                         height="24"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round">
                      <path d="M20 6 9 17l-5-5"> </path>
                    </svg>
                  </span>
                </span>
                Bottom
              </div>
            </div>
            <div data-slot="dropdown-menu-item"
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Log out </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle content Escape;
  print handle;
  [%expect {|
    ("default prevented" (key Escape))
    trigger Open state=closed
    closed
    |}]
;;

let%expect_test "the keyboard opens it on the first item and moves the highlight" =
  let handle = Render.handle ~classes:false menu in
  Drive.key handle trigger ArrowDown;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    trigger Open state=open
    dropdown-menu-content
      > Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  (* ArrowDown skips the disabled item and stops at the end *)
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowDown;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
      > Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  Drive.key handle content End;
  print handle;
  [%expect {|
    ("default prevented" (key End))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
      > Log out
    |}];
  Drive.key handle content ArrowDown;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
      > Log out
    |}];
  Drive.key handle content Home;
  Drive.key handle content ArrowUp;
  print handle;
  [%expect {|
    ("default prevented" (key Home))
    ("default prevented" (key ArrowUp))
    trigger Open state=open
    dropdown-menu-content
      > Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  (* typeahead *)
  Drive.key handle content KeyL;
  print handle;
  [%expect {|
    ("default prevented" (key KeyL))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
      > Log out
    |}];
  Drive.key handle content Enter;
  print handle;
  [%expect {|
    ("default prevented" (key Enter))
    chose Log out
    trigger Open state=closed
    closed
    |}]
;;

let%expect_test "Enter and Space open it too; a disabled trigger does nothing" =
  let handle = Render.handle ~classes:false menu in
  Drive.key handle trigger Enter;
  print handle;
  [%expect {|
    ("default prevented" (key Enter))
    trigger Open state=open
    dropdown-menu-content
      > Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  Drive.key handle content Escape;
  Drive.key handle trigger Space;
  print handle;
  [%expect {|
    ("default prevented" (key Escape))
    ("default prevented" (key Space))
    trigger Open state=open
    dropdown-menu-content
      > Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  let handle =
    Render.handle ~classes:false (fun graph ->
      Dropdown_menu.component
        (Bonsai.return (fun menu ->
           [ Dropdown_menu.trigger ~disabled:true menu (Button.view [ Node.text "Open" ])
           ; Dropdown_menu.content menu [ Dropdown_menu.item [ Node.text "x" ] ]
           ]))
        graph)
  in
  Handle.show handle;
  [%expect {|
    <div>
      <button type="button"
              data-slot="dropdown-menu-trigger"
              data-variant="default"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              disabled=""
              data-disabled=""> Open </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "sub-menus: ArrowRight opens, ArrowLeft closes, the pointer opens" =
  let handle = Render.handle ~classes:false menu in
  Drive.key handle trigger ArrowDown;
  Drive.key handle content KeyI;
  Drive.key handle content ArrowRight;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key KeyI))
    ("default prevented" (key ArrowRight))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=open
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    dropdown-menu-sub-content
      > Email
        Message
    |}];
  Handle.show handle;
  [%expect {|
    <div>
      <button type="button"
              data-slot="dropdown-menu-trigger"
              data-variant="default"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click
              @on_keydown> Open </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false true)
           loon-presence=()
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name dropdown-menu)))
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
          <div data-slot="dropdown-menu-content"
               id="bonsai_path_replaced_in_test-content"
               role="menu"
               aria-orientation="vertical"
               aria-labelledby="bonsai_path_replaced_in_test-trigger"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="dropdown-menu-label"> My Account </div>
            <div data-slot="dropdown-menu-group" role="group">
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                Profile
                <span data-slot="dropdown-menu-shortcut"> ⇧⌘P </span>
              </div>
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove> Billing </div>
              <div data-slot="dropdown-menu-item"
                   data-variant="default"
                   role="menuitem"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   aria-disabled="true"
                   data-disabled=""
                   loon-focus-when=false
                   @on_mouseleave
                   @on_mousemove> API </div>
              <div data-slot="dropdown-menu-sub-trigger"
                   id="bonsai_path_replaced_in_test-sub-3-trigger"
                   role="menuitem"
                   aria-haspopup="menu"
                   aria-expanded="true"
                   aria-controls="bonsai_path_replaced_in_test-sub-3"
                   data-state="open"
                   tabindex="-1"
                   data-orientation="vertical"
                   data-radix-collection-item=""
                   loon-focus-when=false
                   @on_click
                   @on_mouseleave
                   @on_mousemove>
                Invite users
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
              </div>
            </div>
            <div data-slot="dropdown-menu-separator" role="separator" aria-orientation="horizontal"> </div>
            <div data-slot="dropdown-menu-checkbox-item"
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
              <span data-slot="dropdown-menu-checkbox-item-indicator">
                <span data-state="checked">
                  <svg xmlns="http://www.w3.org/2000/svg"
                       width="24"
                       height="24"
                       viewBox="0 0 24 24"
                       fill="none"
                       stroke="currentColor"
                       stroke-width="2"
                       stroke-linecap="round"
                       stroke-linejoin="round">
                    <path d="M20 6 9 17l-5-5"> </path>
                  </svg>
                </span>
              </span>
              Status Bar
            </div>
            <div data-slot="dropdown-menu-radio-group" role="group">
              <div data-slot="dropdown-menu-radio-item"
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
                <span data-slot="dropdown-menu-radio-item-indicator"> </span>
                Top
              </div>
              <div data-slot="dropdown-menu-radio-item"
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
                <span data-slot="dropdown-menu-radio-item-indicator">
                  <span data-state="checked">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         width="24"
                         height="24"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round">
                      <path d="M20 6 9 17l-5-5"> </path>
                    </svg>
                  </span>
                </span>
                Bottom
              </div>
            </div>
            <div data-slot="dropdown-menu-item"
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Log out </div>
          </div>
        </div>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Right)(side_offset 0)(align Start)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-sub-3-trigger))(name dropdown-menu)))
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
          <div data-slot="dropdown-menu-sub-content"
               id="bonsai_path_replaced_in_test-sub-3"
               role="menu"
               aria-orientation="vertical"
               aria-labelledby="bonsai_path_replaced_in_test-sub-3-trigger"
               data-state="open"
               data-orientation="vertical"
               tabindex="-1"
               data-side="right"
               data-align="start"
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="dropdown-menu-item"
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 data-highlighted=""
                 loon-focus-when=true
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Email </div>
            <div data-slot="dropdown-menu-item"
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> Message </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle sub_content ArrowDown;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=open
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    dropdown-menu-sub-content
        Email
      > Message
    |}];
  Drive.key handle sub_content ArrowLeft;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowLeft))
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
      > Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  Menu_probe.hover handle "[data-slot=dropdown-menu-sub-trigger]";
  print handle;
  [%expect {|
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
      > Invite users state=open
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    dropdown-menu-sub-content
        Email
        Message
    |}];
  Menu_probe.hover handle "[data-slot=dropdown-menu-item]";
  print handle;
  [%expect {|
    trigger Open state=open
    dropdown-menu-content
      > Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=checked checked=true
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  Menu_probe.hover handle "[data-slot=dropdown-menu-sub-trigger]";
  Drive.click handle (sub_content ^ " [data-slot=dropdown-menu-item]");
  print handle;
  [%expect {|
    chose Email
    trigger Open state=closed
    closed
    |}]
;;

let%expect_test "checkbox and radio items" =
  let handle = Render.handle ~classes:false menu in
  Drive.click handle trigger;
  Drive.click handle "[data-slot=dropdown-menu-checkbox-item]";
  print handle;
  [%expect {|
    trigger Open state=closed
    closed
    |}];
  Drive.click handle trigger;
  print handle;
  [%expect {|
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=unchecked checked=false
        Top state=unchecked checked=false
        Bottom state=checked checked=true
        Log out
    |}];
  Drive.click handle "[data-slot=dropdown-menu-radio-item]";
  Drive.click handle trigger;
  print handle;
  [%expect {|
    trigger Open state=open
    dropdown-menu-content
        Profile ⇧⌘P
        Billing
        API disabled
        Invite users state=closed
        Status Bar state=unchecked checked=false
        Top state=checked checked=true
        Bottom state=unchecked checked=false
        Log out
    |}]
;;

let%expect_test "a click on the open trigger closes it" =
  let handle = Render.handle ~classes:false menu in
  Drive.click handle trigger;
  Drive.click handle trigger;
  print handle;
  [%expect {|
    trigger Open state=closed
    closed
    |}]
;;
