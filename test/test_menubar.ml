open! Core
open Loon
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let trigger = "[data-slot=menubar-trigger]"
let content = "[data-slot=menubar-content]"
let print h = Menu_probe.print ~triggers:trigger h
let nth_trigger n = sprintf "%s[id$=\"-%d-trigger\"]" trigger (n - 1)

let bar (local_ graph) =
  let bookmarks, set_bookmarks = Bonsai.state false graph in
  Menubar.component
    (let%arr bookmarks and set_bookmarks in
     [ Menubar.menu
         (Menubar.trigger [ Node.text "File" ])
         (Menubar.content
            [ Menubar.item [ Node.text "New Tab"; Menubar.shortcut [ Node.text "⌘T" ] ]
            ; Menubar.item [ Node.text "New Window" ]
            ; Menubar.sub
                (Menubar.sub_trigger [ Node.text "Share" ])
                (Menubar.sub_content
                   [ Menubar.item [ Node.text "Email link" ]
                   ; Menubar.item [ Node.text "Messages" ]
                   ])
            ; Menubar.separator ()
            ; Menubar.item [ Node.text "Print..." ]
            ])
     ; Menubar.menu
         (Menubar.trigger ~disabled:true [ Node.text "Edit" ])
         (Menubar.content [ Menubar.item [ Node.text "Undo" ] ])
     ; Menubar.menu
         (Menubar.trigger [ Node.text "View" ])
         (Menubar.content
            [ Menubar.checkbox_item
                ~checked:bookmarks
                ~on_checked_change:set_bookmarks
                [ Node.text "Always Show Bookmarks Bar" ]
            ; Menubar.item ~inset:true [ Node.text "Reload" ]
            ])
     ])
    graph
;;

let%expect_test "shadcn's classes" =
  let handle =
    Render.handle (fun _graph ->
      Bonsai.return
        (Menubar.view
           ~state:{ value = Some "0"; current = Some "0"; menu = Menu.State.initial }
           ~on_change:(fun _ -> Effect.Ignore)
           [ Menubar.menu
               (Menubar.trigger [ Node.text "File" ])
               (Menubar.content
                  [ Menubar.label [ Node.text "Label" ]
                  ; Menubar.item [ Node.text "New Tab" ]
                  ; Menubar.sub
                      (Menubar.sub_trigger [ Node.text "Share" ])
                      (Menubar.sub_content [ Menubar.item [ Node.text "Email" ] ])
                  ])
           ]))
  in
  Handle.show handle;
  [%expect {|
    <div data-slot="menubar" role="menubar" class="cn-menubar flex items-center">
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="menubar-0-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="menubar-0-content"
              data-state="open"
              tabindex="0"
              class="cn-menubar-trigger flex items-center outline-hidden select-none"
              @on_blur
              @on_click
              @on_focus
              @on_keydown
              @on_mouseenter> File </button>
      <div loon-dismiss=((menubar-0-trigger)false false) loon-presence=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 8)(align Start)(align_offset -4)(avoid_collisions true)(collision_padding 0)(anchor(Element menubar-0-trigger))(name menubar)))
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
          <div data-slot="menubar-content"
               id="menubar-0-content"
               role="menu"
               aria-orientation="vertical"
               aria-labelledby="menubar-0-trigger"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="start"
               class="cn-menu-target cn-menu-translucent cn-menubar-content origin-(--radix-menubar-content-transform-origin) overflow-hidden z-50"
               loon-focus-on-mount=Self
               @on_keydown
               style={
                 outline: none;
               }>
            <div data-slot="menubar-label" class="cn-menubar-label"> Label </div>
            <div data-slot="menubar-item"
                 data-variant="default"
                 role="menuitem"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-menubar-item cursor-default data-disabled:pointer-events-none flex group/menubar-item items-center outline-hidden relative select-none"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove> New Tab </div>
            <div data-slot="menubar-sub-trigger"
                 id="menubar-0-sub-1-trigger"
                 role="menuitem"
                 aria-haspopup="menu"
                 aria-expanded="false"
                 data-state="closed"
                 tabindex="-1"
                 data-orientation="vertical"
                 data-radix-collection-item=""
                 class="cn-menubar-sub-trigger cursor-default flex items-center outline-none select-none"
                 loon-focus-when=false
                 @on_click
                 @on_mouseleave
                 @on_mousemove>
              Share
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="cn-rtl-flip lucide lucide-chevron-right ml-auto size-4">
                <path d="m9 18 6-6-6-6"> </path>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "a click opens a menu; hovering another trigger switches to it" =
  let handle = Render.handle ~classes:false bar in
  Handle.show handle;
  [%expect {|
    <div data-slot="menubar" role="menubar">
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-0-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="0"
              @on_blur
              @on_click
              @on_focus
              @on_keydown
              @on_mouseenter> File </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-1-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="-1"
              disabled=""
              data-disabled=""> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-2-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="-1"
              @on_blur
              @on_click
              @on_focus
              @on_keydown
              @on_mouseenter> View </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle (nth_trigger 1);
  print handle;
  [%expect {|
    trigger File state=open
    trigger Edit state=closed disabled
    trigger View state=closed
    menubar-content
        New Tab ⌘T
        New Window
        Share state=closed
        Print...
    |}];
  Handle.mouseenter handle ~get_vdom:Fn.id ~selector:(nth_trigger 3);
  Handle.recompute_view handle;
  print handle;
  [%expect {|
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=open
    menubar-content
        Always Show Bookmarks Bar state=unchecked checked=false
        Reload
    |}];
  Drive.click handle (nth_trigger 3);
  print handle;
  [%expect {|
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=closed
    closed
    |}]
;;

let%expect_test "the keyboard: arrows between triggers and between open menus" =
  let handle = Render.handle ~classes:false bar in
  (* the roving tab stop moves past the disabled Edit *)
  Drive.key handle (nth_trigger 1) ArrowRight;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key ArrowRight))
    <div data-slot="menubar" role="menubar">
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-0-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="-1"
              @on_blur
              @on_click
              @on_focus
              @on_keydown
              @on_mouseenter> File </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-1-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="-1"
              disabled=""
              data-disabled=""> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <button data-slot="menubar-trigger"
              type="button"
              role="menuitem"
              id="bonsai_path_replaced_in_test-2-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
              tabindex="0"
              @on_blur
              @on_click
              @on_focus
              @on_keydown
              @on_mouseenter> View </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.key handle (nth_trigger 3) ArrowDown;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=open
    menubar-content
      > Always Show Bookmarks Bar state=unchecked checked=false
        Reload
    |}];
  (* ArrowRight on an item without a sub-menu: the next menu, wrapping, with
     nothing highlighted (as Radix's) *)
  Drive.key handle content ArrowRight;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowRight))
    trigger File state=open
    trigger Edit state=closed disabled
    trigger View state=closed
    menubar-content
        New Tab ⌘T
        New Window
        Share state=closed
        Print...
    |}];
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowDown;
  Drive.key handle content ArrowRight;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowRight))
    trigger File state=open
    trigger Edit state=closed disabled
    trigger View state=closed
    menubar-content
        New Tab ⌘T
        New Window
        Share state=open
        Print...
    menubar-sub-content
      > Email link
        Messages
    |}];
  Drive.key handle "[data-slot=menubar-sub-content]" ArrowLeft;
  Drive.key handle content ArrowLeft;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowLeft))
    ("default prevented" (key ArrowLeft))
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=open
    menubar-content
        Always Show Bookmarks Bar state=unchecked checked=false
        Reload
    |}];
  Drive.key handle content ArrowDown;
  Drive.key handle content Enter;
  print handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key Enter))
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=closed
    closed
    |}];
  Drive.key handle (nth_trigger 3) Enter;
  Drive.key handle content Escape;
  print handle;
  [%expect {|
    ("default prevented" (key Enter))
    ("default prevented" (key Escape))
    trigger File state=closed
    trigger Edit state=closed disabled
    trigger View state=closed
    closed
    |}]
;;
