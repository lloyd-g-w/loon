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
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-between outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all w-[200px] whitespace-nowrap"
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
             aria-hidden="true"
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
               class="bg-popover border data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 origin-(--radix-popover-content-transform-origin) outline-hidden p-0 rounded-md shadow-md text-popover-foreground w-[200px] z-50"
               loon-focus-on-mount=First_tabbable
               @on_keydown>
            <div tabindex="-1"
                 cmdk-root=""
                 data-slot="command"
                 class="bg-popover flex flex-col h-full overflow-hidden rounded-md text-popover-foreground w-full"
                 @on_keydown>
              <label cmdk-label=""
                     for="cb-command-input"
                     id="cb-command-label"
                     style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;border-width:0">  </label>
              <div data-slot="command-input-wrapper" class="border-b flex gap-2 h-9 items-center px-3">
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
                     class="lucide lucide-search opacity-50 shrink-0 size-4">
                  <path d="m21 21-4.34-4.34"> </path>
                  <circle cx="11" cy="11" r="8"> </circle>
                </svg>
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
                       class="bg-transparent disabled:cursor-not-allowed disabled:opacity-50 flex h-9 outline-hidden placeholder:text-muted-foreground py-3 rounded-md text-sm w-full"
                       #value=""
                       @on_input/>
              </div>
              <div cmdk-list=""
                   role="listbox"
                   tabindex="-1"
                   aria-activedescendant="cb-command-item-0"
                   aria-label="Suggestions"
                   id="cb-command-list"
                   data-slot="command-list"
                   class="max-h-[300px] overflow-x-hidden overflow-y-auto scroll-py-1">
                <div cmdk-list-sizer="">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <div cmdk-group=""
                       role="presentation"
                       data-slot="command-group"
                       class="[&_[cmdk-group-heading]]:font-medium [&_[cmdk-group-heading]]:px-2 [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-muted-foreground [&_[cmdk-group-heading]]:text-xs overflow-hidden p-1 text-foreground">
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
                           class="[&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 cursor-default data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground flex gap-2 items-center outline-hidden px-2 py-1.5 relative rounded-sm select-none text-sm"
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
                             aria-hidden="true"
                             class="lucide lucide-check ml-auto opacity-0">
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
                           class="[&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 cursor-default data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground flex gap-2 items-center outline-hidden px-2 py-1.5 relative rounded-sm select-none text-sm"
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
                             aria-hidden="true"
                             class="lucide lucide-check ml-auto opacity-0">
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
              aria-controls="bonsai_path_replaced_in_test-content"
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
             stroke-linejoin="round"
             aria-hidden="true">
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
             stroke-linejoin="round"
             aria-hidden="true">
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
                  <path d="m21 21-4.34-4.34"> </path>
                  <circle cx="11" cy="11" r="8"> </circle>
                </svg>
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
                             stroke-linejoin="round"
                             aria-hidden="true">
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
              aria-controls="bonsai_path_replaced_in_test-content"
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
             stroke-linejoin="round"
             aria-hidden="true">
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
            aria-controls="bonsai_path_replaced_in_test-content"
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
           stroke-linejoin="round"
           aria-hidden="true">
        <path d="m7 15 5 5 5-5"> </path>
        <path d="m7 9 5-5 5 5"> </path>
      </svg>
    </button>
    |}]
;;
