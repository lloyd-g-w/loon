open! Core
open Loon
open Bonsai_web
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let frameworks : Combobox.Option_.t list =
  [ { value = "next.js"; label = "Next.js" }
  ; { value = "sveltekit"; label = "SvelteKit" }
  ; { value = "nuxt.js"; label = "Nuxt.js" }
  ; { value = "remix"; label = "Remix" }
  ; { value = "astro"; label = "Astro" }
  ]
;;

let app (local_ graph) =
  let open Bonsai.Let_syntax in
  let r =
    Combobox.component
      ~placeholder:"Select framework..."
      ~search_placeholder:"Search framework..."
      ~empty:"No framework found."
      (Bonsai.return frameworks)
      graph
  in
  let%arr value, view = r in
  Node.div
    [ Node.p [ Node.text ("value: " ^ Option.value value ~default:"none") ]; view ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Node.div [ Combobox.view
       ~id:"cb"
       ~value:(Some "remix")
       ~on_value_change:(fun _ -> Effect.Ignore)
       ~open_:true
       ~on_open_change:(fun _ -> Effect.Ignore)
       ~command:Command.State.empty
       ~on_command_change:(fun _ -> Effect.Ignore)
       (List.take frameworks 2) ]);
  [%expect {|
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              role="combobox"
              id="cb-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="cb-content"
              data-state="open"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-between outline-none select-none shrink-0 transition-all w-[200px] whitespace-nowrap"
              @on_click>
        Select an option...
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             class="lucide lucide-chevrons-up-down opacity-50">
          <path d="m7 15 5 5 5-5"> </path>
          <path d="m7 9 5-5 5 5"> </path>
        </svg>
      </button>
      <div loon-dismiss=((cb-trigger)true false) loon-presence=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element cb-trigger))(name popover)))
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
          <div data-slot="popover-content"
               id="cb-content"
               role="dialog"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               class="cn-popover-content origin-(--radix-popover-content-transform-origin) outline-hidden p-0 w-[200px] z-50"
               loon-focus-on-mount=First_tabbable
               @on_keydown>
            <div tabindex="-1"
                 cmdk-root=""
                 data-slot="command"
                 class="cn-command flex flex-col overflow-hidden size-full"
                 @on_keydown>
              <label cmdk-label=""
                     for="cb-command-input"
                     id="cb-command-label"
                     style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;border-width:0">  </label>
              <div data-slot="command-input-wrapper" class="cn-command-input-wrapper">
                <div data-slot="input-group"
                     role="group"
                     class="cn-command-input-group cn-input-group flex group/input-group has-[>textarea]:h-auto items-center min-w-0 outline-none relative w-full">
                  <input cmdk-input=""
                         autocomplete="off"
                         autocorrect="off"
                         spellcheck="false"
                         aria-autocomplete="list"
                         role="combobox"
                         aria-expanded="true"
                         aria-controls="cb-command-list"
                         aria-labelledby="cb-command-label"
                         aria-activedescendant="cb-command-item-0"
                         id="cb-command-input"
                         type="text"
                         data-slot="command-input"
                         placeholder="Search..."
                         class="cn-command-input disabled:cursor-not-allowed disabled:opacity-50 h-9 outline-hidden"
                         #value=""
                         @on_input/>
                  <div role="group"
                       data-slot="input-group-addon"
                       data-align="inline-start"
                       class="cn-input-group-addon cn-input-group-addon-align-inline-start cursor-text flex items-center justify-center order-first select-none"
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
                         class="cn-command-input-icon lucide lucide-search">
                      <circle cx="11" cy="11" r="8"> </circle>
                      <path d="m21 21-4.3-4.3"> </path>
                    </svg>
                  </div>
                </div>
              </div>
              <div cmdk-list=""
                   role="listbox"
                   tabindex="-1"
                   aria-activedescendant="cb-command-item-0"
                   aria-label="Suggestions"
                   id="cb-command-list"
                   data-slot="command-list"
                   class="cn-command-list overflow-x-hidden overflow-y-auto">
                <div cmdk-list-sizer="">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <div cmdk-group=""
                       role="presentation"
                       data-slot="command-group"
                       class="cn-command-group">
                    <div cmdk-group-items="" role="group">
                      <div cmdk-item=""
                           role="option"
                           aria-disabled="false"
                           aria-selected="true"
                           data-disabled="false"
                           data-selected="true"
                           data-value="next.js"
                           id="cb-command-item-0"
                           data-slot="command-item"
                           class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-command-item data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none group/command-item"
                           @on_click
                           @on_pointermove>
                        Next.js
                        <svg xmlns="http://www.w3.org/2000/svg"
                             width="24"
                             height="24"
                             viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round"
                             class="lucide lucide-check ml-auto opacity-0">
                          <path d="M20 6 9 17l-5-5"> </path>
                        </svg>
                        <svg xmlns="http://www.w3.org/2000/svg"
                             width="24"
                             height="24"
                             viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round"
                             class="cn-command-item-indicator group-data-[checked=true]/command-item:opacity-100 group-has-data-[slot=command-shortcut]/command-item:hidden lucide lucide-check ml-auto opacity-0">
                          <path d="M20 6 9 17l-5-5"> </path>
                        </svg>
                      </div>
                      <div cmdk-item=""
                           role="option"
                           aria-disabled="false"
                           aria-selected="false"
                           data-disabled="false"
                           data-selected="false"
                           data-value="sveltekit"
                           id="cb-command-item-1"
                           data-slot="command-item"
                           class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-command-item data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none group/command-item"
                           @on_click
                           @on_pointermove>
                        SvelteKit
                        <svg xmlns="http://www.w3.org/2000/svg"
                             width="24"
                             height="24"
                             viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round"
                             class="lucide lucide-check ml-auto opacity-0">
                          <path d="M20 6 9 17l-5-5"> </path>
                        </svg>
                        <svg xmlns="http://www.w3.org/2000/svg"
                             width="24"
                             height="24"
                             viewBox="0 0 24 24"
                             fill="none"
                             stroke="currentColor"
                             stroke-width="2"
                             stroke-linecap="round"
                             stroke-linejoin="round"
                             class="cn-command-item-indicator group-data-[checked=true]/command-item:opacity-100 group-has-data-[slot=command-shortcut]/command-item:hidden lucide lucide-check ml-auto opacity-0">
                          <path d="M20 6 9 17l-5-5"> </path>
                        </svg>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "open, search, choose; choosing the value again clears it" =
  let handle = Render.handle ~classes:false app in
  Handle.show handle;
  [%expect {|
    <div>
      <p> value: none </p>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              role="combobox"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              data-state="closed"
              @on_click>
        Select framework...
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="m7 15 5 5 5-5"> </path>
          <path d="m7 9 5-5 5 5"> </path>
        </svg>
      </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "[role=combobox]";
  Drive.type_ handle "[cmdk-input]" "nux";
  Handle.show handle;
  [%expect {|
    <div>
      <p> value: none </p>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              role="combobox"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click>
        Select framework...
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="m7 15 5 5 5-5"> </path>
          <path d="m7 9 5-5 5 5"> </path>
        </svg>
      </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)true false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name popover)))
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
          <div data-slot="popover-content"
               id="bonsai_path_replaced_in_test-content"
               role="dialog"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               loon-focus-on-mount=First_tabbable
               @on_keydown>
            <div tabindex="-1" cmdk-root="" data-slot="command" @on_keydown>
              <label cmdk-label=""
                     for="bonsai_path_replaced_in_test-command-input"
                     id="bonsai_path_replaced_in_test-command-label"
                     style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;border-width:0">  </label>
              <div data-slot="command-input-wrapper">
                <div data-slot="input-group" role="group">
                  <input cmdk-input=""
                         autocomplete="off"
                         autocorrect="off"
                         spellcheck="false"
                         aria-autocomplete="list"
                         role="combobox"
                         aria-expanded="true"
                         aria-controls="bonsai_path_replaced_in_test-command-list"
                         aria-labelledby="bonsai_path_replaced_in_test-command-label"
                         aria-activedescendant="bonsai_path_replaced_in_test-command-item-2"
                         id="bonsai_path_replaced_in_test-command-input"
                         type="text"
                         data-slot="command-input"
                         placeholder="Search framework..."
                         #value="nux"
                         @on_input/>
                  <div role="group" data-slot="input-group-addon" data-align="inline-start" @on_click>
                    <svg xmlns="http://www.w3.org/2000/svg"
                         width="24"
                         height="24"
                         viewBox="0 0 24 24"
                         fill="none"
                         stroke="currentColor"
                         stroke-width="2"
                         stroke-linecap="round"
                         stroke-linejoin="round">
                      <circle cx="11" cy="11" r="8"> </circle>
                      <path d="m21 21-4.3-4.3"> </path>
                    </svg>
                  </div>
                </div>
              </div>
              <div cmdk-list=""
                   role="listbox"
                   tabindex="-1"
                   aria-activedescendant="bonsai_path_replaced_in_test-command-item-2"
                   aria-label="Suggestions"
                   id="bonsai_path_replaced_in_test-command-list"
                   data-slot="command-list">
                <div cmdk-list-sizer="">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <div cmdk-group="" role="presentation" data-slot="command-group">
                    <div cmdk-group-items="" role="group">
                      <div cmdk-item=""
                           role="option"
                           aria-disabled="false"
                           aria-selected="true"
                           data-disabled="false"
                           data-selected="true"
                           data-value="nuxt.js"
                           id="bonsai_path_replaced_in_test-command-item-2"
                           data-slot="command-item"
                           @on_click
                           @on_pointermove>
                        Nuxt.js
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
                      </div>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle "[cmdk-root]" Enter;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key Enter))
    <div>
      <p> value: nuxt.js </p>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              role="combobox"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              data-state="closed"
              @on_click>
        Nuxt.js
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="m7 15 5 5 5-5"> </path>
          <path d="m7 9 5-5 5 5"> </path>
        </svg>
      </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "[role=combobox]";
  Drive.click handle "[data-value='nuxt.js']";
  Render.html ~classes:false ~selector:"p" (Handle.last_result handle);
  [%expect {| <p> value: none </p> |}];
  Drive.click handle "[role=combobox]";
  Drive.key handle "[data-slot=popover-content]" Escape;
  Render.html ~classes:false ~selector:"[role=combobox]" (Handle.last_result handle);
  [%expect {|
    ("default prevented" (key Escape))
    <button type="button"
            data-slot="popover-trigger"
            data-variant="outline"
            data-size="default"
            role="combobox"
            id="bonsai_path_replaced_in_test-trigger"
            aria-haspopup="dialog"
            aria-expanded="false"
            data-state="closed"
            @on_click>
      Select framework...
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round">
        <path d="m7 15 5 5 5-5"> </path>
        <path d="m7 9 5-5 5 5"> </path>
      </svg>
    </button>
    |}]
;;
