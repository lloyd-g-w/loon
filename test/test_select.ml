open! Core
open Bonsai_web
open Loon
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let item ?disabled value text =
  Select.item
    ~attrs:[ Vdom.Attr.create "data-test" value ]
    ?disabled
    ~value
    [ Node.text text ]
;;

let fruits =
  Select.content
    [ Select.group
        [ Select.label [ Node.text "Fruits" ]
        ; item "apple" "Apple"
        ; item "banana" "Banana" ~disabled:true
        ; item "blueberry" "Blueberry"
        ]
    ; Select.separator ()
    ; Select.group
        [ Select.label [ Node.text "Vegetables" ]; item "carrot" "Carrot" ]
    ]
;;

let with_value ?name ?default_value ?(content = fruits) () graph =
  let%arr.Bonsai value, view =
    Select.component
      ?name
      ?default_value
      (Bonsai.return
         (Select.trigger ~class_:"w-[180px]" ~placeholder:"Select a fruit" ()))
      (Bonsai.return content)
      graph
  in
  Node.div [ Node.p [ Node.text (Option.value value ~default:"(none)") ]; view ]
;;

let trigger = "[data-slot=select-trigger]"
let content = "[data-slot=select-content]"
let on value = sprintf "[data-test=%s]" value

(* The value, whether it is open, and the highlighted item. *)
let status handle =
  Handle.recompute_view handle;
  let node = Handle.last_result handle in
  let module H = Virtual_dom_test_helpers.Node_helpers in
  let node = H.unsafe_convert_exn node in
  let text n = String.strip (H.inner_text n) in
  let one selector = List.hd (H.select node ~selector) in
  printf
    "value: %s; trigger shows: %s; %s\n"
    (Option.value_map (one "p") ~default:"?" ~f:text)
    (Option.value_map (one "[data-slot=select-value]") ~default:"?" ~f:text)
    (match one content with
     | None -> "closed"
     | Some _ ->
       sprintf
         "open, highlighted: %s"
         (Option.value_map (one "[data-highlighted]") ~default:"none" ~f:text))
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Node.div
       [ Select.view
           ~id:"s"
           ~value:(Some "apple")
           ~on_value_change:(fun _ -> Effect.Ignore)
           ~state:{ open_ = true; highlighted = Some "apple" }
           ~on_state_change:(fun _ -> Effect.Ignore)
           (Select.trigger ~class_:"w-[180px]" ())
           (Select.content
              ~position:Popper
              [ Select.group
                  [ Select.label [ Node.text "Fruits" ]
                  ; Select.item ~value:"apple" [ Node.text "Apple" ]
                  ]
              ; Select.separator ()
              ])
       ]);
  [%expect
    {|
    <div>
      <button type="button"
              role="combobox"
              aria-controls="s-content"
              aria-expanded="true"
              aria-autocomplete="none"
              id="s-trigger"
              dir="ltr"
              data-state="open"
              data-slot="select-trigger"
              data-size="default"
              class="*:data-[slot=select-value]:flex *:data-[slot=select-value]:items-center *:data-[slot=select-value]:line-clamp-1 [&_svg]:pointer-events-none [&_svg]:shrink-0 cn-select-trigger disabled:cursor-not-allowed disabled:opacity-50 flex items-center justify-between outline-none w-[180px] whitespace-nowrap"
              @on_click
              @on_keydown>
        <span data-slot="select-value" style={ pointer-events: none; }> Apple </span>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             class="cn-select-trigger-icon lucide lucide-chevron-down pointer-events-none">
          <path d="m6 9 6 6 6-6"> </path>
        </svg>
      </button>
      <div loon-dismiss=((s-trigger)false true) loon-scroll-lock=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 0)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 10)(anchor(Element s-trigger))(name select)))
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
          <div data-slot="select-content"
               data-align-trigger="false"
               role="listbox"
               id="s-content"
               data-state="open"
               dir="ltr"
               data-side="bottom"
               data-align="center"
               tabindex="-1"
               class="cn-menu-target cn-menu-translucent cn-select-content data-[align-trigger=true]:animate-none data-[side=bottom]:translate-y-1 data-[side=left]:-translate-x-1 data-[side=right]:translate-x-1 data-[side=top]:-translate-y-1 max-h-(--radix-select-content-available-height) origin-(--radix-select-content-transform-origin) overflow-x-hidden overflow-y-auto relative z-50"
               loon-focus-on-mount=Self
               loon-select-scroll=true
               @on_keydown
               style={
                 box-sizing: border-box;
                 display: flex;
                 flex-direction: column;
                 outline: none;
               }>
            <div data-slot="select-scroll-up-button"
                 aria-hidden="true"
                 hidden=""
                 class="cn-select-scroll-up-button"
                 @on_pointermove
                 style={
                   flex-shrink: 0;
                 }>
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-chevron-up">
                <path d="m18 15-6-6-6 6"> </path>
              </svg>
            </div>
            <style>
              [data-radix-select-viewport]{scrollbar-width:none;-ms-overflow-style:none;-webkit-overflow-scrolling:touch;}[data-radix-select-viewport]::-webkit-scrollbar{display:none}
            </style>
            <div data-radix-select-viewport=""
                 role="presentation"
                 data-position="popper"
                 class="cn-select-viewport data-[position=popper]:h-(--radix-select-trigger-height) data-[position=popper]:min-w-(--radix-select-trigger-width) data-[position=popper]:w-full"
                 style={
                   position: relative;
                   flex: 1;
                   overflow: hidden auto;
                 }>
              <div role="group" data-slot="select-group" class="cn-select-group">
                <div data-slot="select-label" class="cn-select-label"> Fruits </div>
                <div role="option"
                     aria-labelledby="s-item-0-text"
                     data-highlighted=""
                     aria-selected="true"
                     data-state="checked"
                     tabindex="-1"
                     id="s-item-0"
                     data-slot="select-item"
                     class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-select-item cursor-default data-disabled:opacity-50 data-disabled:pointer-events-none flex items-center outline-hidden relative select-none w-full"
                     loon-focus-when=true
                     @on_click
                     @on_pointerleave
                     @on_pointermove>
                  <span class="cn-select-item-indicator">
                    <svg xmlns="http://www.w3.org/2000/svg"
                         width="24"
                         height="24"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round"
                         class="cn-select-item-indicator-icon lucide lucide-check pointer-events-none">
                      <path d="M20 6 9 17l-5-5"> </path>
                    </svg>
                  </span>
                  <span id="s-item-0-text"> Apple </span>
                </div>
              </div>
              <div aria-hidden="true"
                   data-slot="select-separator"
                   class="cn-select-separator pointer-events-none"> </div>
            </div>
            <div data-slot="select-scroll-down-button"
                 aria-hidden="true"
                 hidden=""
                 class="cn-select-scroll-down-button"
                 @on_pointermove
                 style={
                   flex-shrink: 0;
                 }>
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </div>
          </div>
        </div>
      </div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "closed, with a placeholder and the hidden native select" =
  let handle = Render.handle ~classes:false (with_value ~name:"fruit" ()) in
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> (none) </p>
      <button type="button"
              role="combobox"
              aria-controls="bonsai_path_replaced_in_test-content"
              aria-expanded="false"
              aria-autocomplete="none"
              id="bonsai_path_replaced_in_test-trigger"
              dir="ltr"
              data-state="closed"
              data-placeholder=""
              data-slot="select-trigger"
              data-size="default"
              @on_click
              @on_keydown>
        <span data-slot="select-value" style={ pointer-events: none; }> Select a fruit </span>
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
      <select aria-hidden="true"
              tabindex="-1"
              name="fruit"
              style="position:absolute;border:0;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap">
        <option #value=""> </option>
        <option #value="apple"> Apple </option>
        <option #value="banana"> Banana </option>
        <option #value="blueberry"> Blueberry </option>
        <option #value="carrot"> Carrot </option>
      </select>
    </div>
    |}]
;;

let%expect_test "open: the structure, groups, labels and the separator" =
  let handle =
    Render.handle ~classes:false (with_value ~default_value:"blueberry" ())
  in
  Drive.click handle trigger;
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> blueberry </p>
      <button type="button"
              role="combobox"
              aria-controls="bonsai_path_replaced_in_test-content"
              aria-expanded="true"
              aria-autocomplete="none"
              id="bonsai_path_replaced_in_test-trigger"
              dir="ltr"
              data-state="open"
              data-slot="select-trigger"
              data-size="default"
              @on_click
              @on_keydown>
        <span data-slot="select-value" style={ pointer-events: none; }> Blueberry </span>
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
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false true)
           loon-scroll-lock=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Item_aligned bonsai_path_replaced_in_test-trigger)
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
          <div data-slot="select-content"
               data-align-trigger="true"
               role="listbox"
               id="bonsai_path_replaced_in_test-content"
               data-state="open"
               dir="ltr"
               tabindex="-1"
               loon-focus-on-mount=Self
               loon-select-scroll=false
               @on_keydown
               style={
                 box-sizing: border-box;
                 display: flex;
                 flex-direction: column;
                 outline: none;
               }>
            <div data-slot="select-scroll-up-button"
                 aria-hidden="true"
                 hidden=""
                 @on_pointermove
                 style={
                   flex-shrink: 0;
                 }>
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <path d="m18 15-6-6-6 6"> </path>
              </svg>
            </div>
            <style>
              [data-radix-select-viewport]{scrollbar-width:none;-ms-overflow-style:none;-webkit-overflow-scrolling:touch;}[data-radix-select-viewport]::-webkit-scrollbar{display:none}
            </style>
            <div data-radix-select-viewport=""
                 role="presentation"
                 data-position="item-aligned"
                 style={
                   position: relative;
                   flex: 1;
                   overflow: hidden auto;
                 }>
              <div role="group" data-slot="select-group">
                <div data-slot="select-label"> Fruits </div>
                <div role="option"
                     aria-labelledby="bonsai_path_replaced_in_test-item-0-text"
                     aria-selected="false"
                     data-state="unchecked"
                     tabindex="-1"
                     id="bonsai_path_replaced_in_test-item-0"
                     data-slot="select-item"
                     data-test="apple"
                     loon-focus-when=false
                     @on_click
                     @on_pointerleave
                     @on_pointermove>
                  <span> </span>
                  <span id="bonsai_path_replaced_in_test-item-0-text"> Apple </span>
                </div>
                <div role="option"
                     aria-labelledby="bonsai_path_replaced_in_test-item-1-text"
                     aria-selected="false"
                     data-state="unchecked"
                     aria-disabled="true"
                     data-disabled=""
                     tabindex="-1"
                     id="bonsai_path_replaced_in_test-item-1"
                     data-slot="select-item"
                     data-test="banana"
                     loon-focus-when=false
                     @on_pointermove>
                  <span> </span>
                  <span id="bonsai_path_replaced_in_test-item-1-text"> Banana </span>
                </div>
                <div role="option"
                     aria-labelledby="bonsai_path_replaced_in_test-item-2-text"
                     data-highlighted=""
                     aria-selected="true"
                     data-state="checked"
                     tabindex="-1"
                     id="bonsai_path_replaced_in_test-item-2"
                     data-slot="select-item"
                     data-test="blueberry"
                     loon-focus-when=true
                     @on_click
                     @on_pointerleave
                     @on_pointermove>
                  <span>
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
                  <span id="bonsai_path_replaced_in_test-item-2-text"> Blueberry </span>
                </div>
              </div>
              <div aria-hidden="true" data-slot="select-separator"> </div>
              <div role="group" data-slot="select-group">
                <div data-slot="select-label"> Vegetables </div>
                <div role="option"
                     aria-labelledby="bonsai_path_replaced_in_test-item-3-text"
                     aria-selected="false"
                     data-state="unchecked"
                     tabindex="-1"
                     id="bonsai_path_replaced_in_test-item-3"
                     data-slot="select-item"
                     data-test="carrot"
                     loon-focus-when=false
                     @on_click
                     @on_pointerleave
                     @on_pointermove>
                  <span> </span>
                  <span id="bonsai_path_replaced_in_test-item-3-text"> Carrot </span>
                </div>
              </div>
            </div>
            <div data-slot="select-scroll-down-button"
                 aria-hidden="true"
                 hidden=""
                 @on_pointermove
                 style={
                   flex-shrink: 0;
                 }>
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
            </div>
          </div>
        </div>
      </div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "a click opens it on the first item; clicking an item picks it" =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.click handle trigger;
  status handle;
  Drive.click handle (on "blueberry");
  status handle;
  Drive.click handle trigger;
  status handle;
  Drive.click handle trigger;
  status handle;
  [%expect
    {|
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    value: blueberry; trigger shows: Blueberry; closed
    value: blueberry; trigger shows: Blueberry; open, highlighted: Blueberry
    value: blueberry; trigger shows: Blueberry; closed
    |}]
;;

let%expect_test
    "the pointer highlights items; leaving one, or moving onto a scroll button, \
     highlights none (Radix's onItemLeave)"
  =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.click handle trigger;
  status handle;
  Drive.event handle (on "carrot") "onpointermove";
  status handle;
  Drive.event handle (on "carrot") "onpointerleave";
  status handle;
  Drive.event handle (on "apple") "onpointermove";
  status handle;
  Drive.event handle "[data-slot=select-scroll-down-button]" "onpointermove";
  status handle;
  Drive.event handle (on "apple") "onpointermove";
  Drive.event handle (on "banana") "onpointermove";
  status handle;
  [%expect
    {|
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    value: (none); trigger shows: Select a fruit; open, highlighted: Carrot
    value: (none); trigger shows: Select a fruit; open, highlighted: none
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    value: (none); trigger shows: Select a fruit; open, highlighted: none
    value: (none); trigger shows: Select a fruit; open, highlighted: none
    |}]
;;

let%expect_test "the viewport hides its scrollbar, as Radix's does" =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.click handle trigger;
  let module H = Virtual_dom_test_helpers.Node_helpers in
  let node = H.unsafe_convert_exn (Handle.last_result handle) in
  List.iter (H.select node ~selector:"[data-slot=select-content] > style") ~f:(fun n ->
    print_endline (H.inner_text n));
  [%expect {| [data-radix-select-viewport]{scrollbar-width:none;-ms-overflow-style:none;-webkit-overflow-scrolling:touch;}[data-radix-select-viewport]::-webkit-scrollbar{display:none} |}]
;;

let%expect_test
    "Enter, Space, ArrowDown and ArrowUp open it on the selected item"
  =
  let handle =
    Render.handle ~classes:false (with_value ~default_value:"blueberry" ())
  in
  List.iter
    [ Js_of_ocaml.Dom_html.Keyboard_code.Enter; Space; ArrowDown; ArrowUp ]
    ~f:(fun key ->
      Drive.key handle trigger key;
      status handle;
      Drive.key handle content Escape;
      status handle);
  [%expect
    {|
    ("default prevented" (key Enter))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Blueberry
    ("default prevented" (key Escape))
    ("default prevented" (key Escape))
    value: blueberry; trigger shows: Blueberry; closed
    ("default prevented" (key Space))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Blueberry
    ("default prevented" (key Escape))
    ("default prevented" (key Escape))
    value: blueberry; trigger shows: Blueberry; closed
    ("default prevented" (key ArrowDown))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Blueberry
    ("default prevented" (key Escape))
    ("default prevented" (key Escape))
    value: blueberry; trigger shows: Blueberry; closed
    ("default prevented" (key ArrowUp))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Blueberry
    ("default prevented" (key Escape))
    ("default prevented" (key Escape))
    value: blueberry; trigger shows: Blueberry; closed
    |}]
;;

let%expect_test "arrows skip disabled items and stop at the ends; Home and End" =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.click handle trigger;
  status handle;
  Drive.key handle content ArrowUp;
  status handle;
  Drive.key handle content ArrowDown;
  status handle;
  Drive.key handle content ArrowDown;
  status handle;
  Drive.key handle content ArrowDown;
  status handle;
  Drive.key handle content Home;
  status handle;
  Drive.key handle content End;
  status handle;
  [%expect
    {|
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    ("default prevented" (key ArrowUp))
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    ("default prevented" (key ArrowDown))
    value: (none); trigger shows: Select a fruit; open, highlighted: Blueberry
    ("default prevented" (key ArrowDown))
    value: (none); trigger shows: Select a fruit; open, highlighted: Carrot
    ("default prevented" (key ArrowDown))
    value: (none); trigger shows: Select a fruit; open, highlighted: Carrot
    ("default prevented" (key Home))
    value: (none); trigger shows: Select a fruit; open, highlighted: Apple
    ("default prevented" (key End))
    value: (none); trigger shows: Select a fruit; open, highlighted: Carrot
    |}]
;;

let%expect_test "Enter and Space pick the highlighted item and close" =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.click handle trigger;
  Drive.key handle content ArrowDown;
  Drive.key handle content Enter;
  status handle;
  Drive.key handle trigger Enter;
  Drive.key handle content End;
  Drive.key handle content Space;
  status handle;
  [%expect
    {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key Enter))
    value: blueberry; trigger shows: Blueberry; closed
    ("default prevented" (key Enter))
    ("default prevented" (key End))
    ("default prevented" (key Space))
    value: carrot; trigger shows: Carrot; closed
    |}]
;;

let%expect_test
    "typeahead: on the closed trigger it picks; in the list it highlights"
  =
  let handle = Render.handle ~classes:false (with_value ()) in
  Drive.key handle trigger KeyC;
  status handle;
  Drive.key handle trigger KeyA;
  status handle;
  Drive.key handle trigger KeyB;
  status handle;
  Drive.click handle trigger;
  Drive.key handle content KeyC;
  status handle;
  Drive.key handle content KeyA;
  status handle;
  [%expect
    {|
    value: carrot; trigger shows: Carrot; closed
    value: apple; trigger shows: Apple; closed
    value: blueberry; trigger shows: Blueberry; closed
    ("default prevented" (key KeyC))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Carrot
    ("default prevented" (key KeyA))
    value: blueberry; trigger shows: Blueberry; open, highlighted: Apple
    |}]
;;

let%expect_test "disabled: the trigger does not open" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      let%arr.Bonsai _, view =
        Select.component
          ~disabled:true
          (Bonsai.return (Select.trigger ~placeholder:"Theme" ()))
          (Bonsai.return fruits)
          graph
      in
      Node.div [ view ])
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              role="combobox"
              aria-controls="bonsai_path_replaced_in_test-content"
              aria-expanded="false"
              aria-autocomplete="none"
              id="bonsai_path_replaced_in_test-trigger"
              dir="ltr"
              data-state="closed"
              disabled=""
              data-disabled=""
              data-placeholder=""
              data-slot="select-trigger"
              data-size="default"
              @on_click
              @on_keydown>
        <span data-slot="select-value" style={ pointer-events: none; }> Theme </span>
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
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "the trigger's own id, for a label" =
  let node =
    Select.view
      ~id:"sel"
      ~value:None
      ~on_value_change:(fun _ -> Effect.Ignore)
      ~state:Select.State.closed
      ~on_state_change:(fun _ -> Effect.Ignore)
      (Select.trigger ~id:"dropdown" ~placeholder:"Dropdown" ())
      fruits
  in
  Render.html ~classes:false ~selector:"button" node;
  [%expect {|
    <button type="button"
            role="combobox"
            aria-controls="sel-content"
            aria-expanded="false"
            aria-autocomplete="none"
            id="dropdown"
            dir="ltr"
            data-state="closed"
            data-placeholder=""
            data-slot="select-trigger"
            data-size="default"
            @on_click
            @on_keydown>
      <span data-slot="select-value" style={ pointer-events: none; }> Dropdown </span>
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
    |}]
;;
