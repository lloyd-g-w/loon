open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let groups =
  [ Select.Group.create
      ~label:"Fruit"
      [ Select.Option_.create "Apple"
      ; Select.Option_.create ~disabled:true "Banana"
      ; Select.Option_.create "Blueberry"
      ]
  ; Select.Group.create
      ~label:"Vegetables"
      [ Select.Option_.create ~label:"Carrot" "carrot" ]
  ]
;;

let with_value component graph =
  let%arr.Bonsai value, view = component graph in
  Vdom.Node.div
    [ Vdom.Node.p [ Vdom.Node.text (Option.value value ~default:"(none)") ]
    ; view
    ]
;;

let%expect_test "select: open, move, choose, typeahead" =
  let handle =
    Render.handle
      (with_value
         (Select.component ~placeholder:"Pick one" (Bonsai.return groups)))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> (none) </p>
      <div data-state="closed" class="loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="closed"
                type="button"
                role="combobox"
                data-placeholder=""
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Pick one </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> (none) </p>
      <div data-state="open" class="loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="true"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="open"
                type="button"
                role="combobox"
                data-placeholder=""
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Pick one </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
        <div aria-hidden="true" class="loon-click-away" @on_click> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             data-side="bottom"
             data-align="start"
             data-match-width=""
             role="listbox"
             tabindex="-1"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
             aria-activedescendant="loonbonsai_path_replaced_in_test-option-Apple"
             class="loon-floating-content loon-listbox"
             always-focus-hook=()
             loon-keep-in-view=()
             @on_keydown>
          <div role="group"
               aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
               class="loon-option-group">
            <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Fruit </div>
            <div role="option"
                 id="loonbonsai_path_replaced_in_test-option-Apple"
                 aria-selected="false"
                 data-highlighted=""
                 class="loon-option"
                 @on_click
                 @on_mousemove>
              <span class="loon-menu-text"> Apple </span>
              <span class="loon-option-check"> </span>
            </div>
            <div role="option"
                 id="loonbonsai_path_replaced_in_test-option-Banana"
                 aria-selected="false"
                 aria-disabled="true"
                 data-disabled=""
                 class="loon-option">
              <span class="loon-menu-text"> Banana </span>
              <span class="loon-option-check"> </span>
            </div>
            <div role="option"
                 id="loonbonsai_path_replaced_in_test-option-Blueberry"
                 aria-selected="false"
                 class="loon-option"
                 @on_click
                 @on_mousemove>
              <span class="loon-menu-text"> Blueberry </span>
              <span class="loon-option-check"> </span>
            </div>
          </div>
          <div>
            <div class="loon-menu-separator"> </div>
            <div role="group"
                 aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
                 class="loon-option-group">
              <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Vegetables </div>
              <div role="option"
                   id="loonbonsai_path_replaced_in_test-option-carrot"
                   aria-selected="false"
                   class="loon-option"
                   @on_click
                   @on_mousemove>
                <span class="loon-menu-text"> Carrot </span>
                <span class="loon-option-check"> </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle "[role=listbox]" ArrowDown;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key ArrowDown))

                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true"
                 class="loon-select-chevron lucide lucide-chevrons-up-down">
              <path d="m7 15 5 5 5-5"> </path>
              <path d="m7 9 5-5 5 5"> </path>
            </svg>
          </button>
          <div aria-hidden="true" class="loon-click-away" @on_click> </div>
          <div id="loonbonsai_path_replaced_in_test-content"
               data-side="bottom"
               data-align="start"
               data-match-width=""
               role="listbox"
               tabindex="-1"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
    -|         aria-activedescendant="loonbonsai_path_replaced_in_test-option-Apple"
    +|         aria-activedescendant="loonbonsai_path_replaced_in_test-option-Blueberry"
               class="loon-floating-content loon-listbox"
               always-focus-hook=()
               loon-keep-in-view=()
               @on_keydown>
            <div role="group"
                 aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
                 class="loon-option-group">
              <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Fruit </div>
              <div role="option"
                   id="loonbonsai_path_replaced_in_test-option-Apple"
                   aria-selected="false"
    -|             data-highlighted=""
                   class="loon-option"
                   @on_click
                   @on_mousemove>
                <span class="loon-menu-text"> Apple </span>
                <span class="loon-option-check"> </span>
              </div>
              <div role="option"
                   id="loonbonsai_path_replaced_in_test-option-Banana"
                   aria-selected="false"
                   aria-disabled="true"
                   data-disabled=""
                   class="loon-option">
                <span class="loon-menu-text"> Banana </span>
                <span class="loon-option-check"> </span>
              </div>
              <div role="option"
                   id="loonbonsai_path_replaced_in_test-option-Blueberry"
                   aria-selected="false"
    +|             data-highlighted=""
                   class="loon-option"
                   @on_click
                   @on_mousemove>
                <span class="loon-menu-text"> Blueberry </span>
                <span class="loon-option-check"> </span>
              </div>
            </div>
            <div>
              <div class="loon-menu-separator"> </div>
              <div role="group"
                   aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
                   class="loon-option-group">
                <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Vegetables </div>
                <div role="option"
                     id="loonbonsai_path_replaced_in_test-option-carrot"
                     aria-selected="false"
    |}];
  Drive.key handle "[role=listbox]" Enter;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Enter))
    <div>
      <p> Blueberry </p>
      <div data-state="closed" class="loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="closed"
                type="button"
                role="combobox"
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Blueberry </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}];
  (* Typeahead on the closed select changes the value. *)
  Drive.key handle "button" KeyC;
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> carrot </p>
      <div data-state="closed" class="loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="closed"
                type="button"
                role="combobox"
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Carrot </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}];
  (* Opening by keyboard highlights the current value; clicking an option chooses it. *)
  Drive.key handle "button" Enter;
  Drive.click handle "[role=option]";
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Enter))
    <div>
      <p> Apple </p>
      <div data-state="closed" class="loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="closed"
                type="button"
                role="combobox"
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Apple </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}]
;;

let%expect_test "combobox: search then choose" =
  let handle =
    Render.handle
      (with_value
         (Combobox.component ~placeholder:"Pick one" (Bonsai.return groups)))
  in
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> (none) </p>
      <div data-state="open" class="loon-combobox loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="true"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="open"
                type="button"
                role="combobox"
                data-placeholder=""
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Pick one </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
        <div aria-hidden="true" class="loon-click-away" @on_click> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             data-side="bottom"
             data-align="start"
             data-match-width=""
             class="loon-combobox-content loon-floating-content"
             loon-keep-in-view=()
             @on_keydown>
          <div class="loon-command">
            <div class="loon-command-search">
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
                   class="lucide lucide-search">
                <path d="m21 21-4.34-4.34"> </path>
                <circle cx="11" cy="11" r="8"> </circle>
              </svg>
              <input type="text"
                     role="combobox"
                     placeholder="Search…"
                     autocomplete="off"
                     spellcheck="false"
                     aria-autocomplete="list"
                     aria-expanded="true"
                     aria-controls="loonbonsai_path_replaced_in_test-command-list"
                     aria-label="Search…"
                     aria-activedescendant="loonbonsai_path_replaced_in_test-command-item-Apple"
                     class="loon-command-input"
                     #value=""
                     always-focus-hook=()
                     @on_input
                     @on_keydown/>
            </div>
            <div role="listbox"
                 id="loonbonsai_path_replaced_in_test-command-list"
                 class="loon-command-list">
              <div role="group"
                   aria-labelledby="loonbonsai_path_replaced_in_test-command-group-0"
                   class="loon-command-group">
                <div id="loonbonsai_path_replaced_in_test-command-group-0" class="loon-menu-label"> Fruit </div>
                <div @key=Apple
                     role="option"
                     id="loonbonsai_path_replaced_in_test-command-item-Apple"
                     aria-selected="true"
                     data-highlighted=""
                     class="loon-option"
                     @on_click
                     @on_mousemove>
                  <span class="loon-menu-text"> Apple </span>
                </div>
                <div @key=Banana
                     role="option"
                     id="loonbonsai_path_replaced_in_test-command-item-Banana"
                     aria-selected="false"
                     aria-disabled="true"
                     data-disabled=""
                     class="loon-option">
                  <span class="loon-menu-text"> Banana </span>
                </div>
                <div @key=Blueberry
                     role="option"
                     id="loonbonsai_path_replaced_in_test-command-item-Blueberry"
                     aria-selected="false"
                     class="loon-option"
                     @on_click
                     @on_mousemove>
                  <span class="loon-menu-text"> Blueberry </span>
                </div>
              </div>
              <div role="group"
                   aria-labelledby="loonbonsai_path_replaced_in_test-command-group-1"
                   class="loon-command-group">
                <div id="loonbonsai_path_replaced_in_test-command-group-1" class="loon-menu-label"> Vegetables </div>
                <div @key=carrot
                     role="option"
                     id="loonbonsai_path_replaced_in_test-command-item-carrot"
                     aria-selected="false"
                     class="loon-option"
                     @on_click
                     @on_mousemove>
                  <span class="loon-menu-text"> Carrot </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.type_ handle "input" "car";
  Handle.show handle;
  [%expect
    {|
    <div>
      <p> (none) </p>
      <div data-state="open" class="loon-combobox loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="true"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="open"
                type="button"
                role="combobox"
                data-placeholder=""
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Pick one </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
        <div aria-hidden="true" class="loon-click-away" @on_click> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             data-side="bottom"
             data-align="start"
             data-match-width=""
             class="loon-combobox-content loon-floating-content"
             loon-keep-in-view=()
             @on_keydown>
          <div class="loon-command">
            <div class="loon-command-search">
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
                   class="lucide lucide-search">
                <path d="m21 21-4.34-4.34"> </path>
                <circle cx="11" cy="11" r="8"> </circle>
              </svg>
              <input type="text"
                     role="combobox"
                     placeholder="Search…"
                     autocomplete="off"
                     spellcheck="false"
                     aria-autocomplete="list"
                     aria-expanded="true"
                     aria-controls="loonbonsai_path_replaced_in_test-command-list"
                     aria-label="Search…"
                     aria-activedescendant="loonbonsai_path_replaced_in_test-command-item-carrot"
                     class="loon-command-input"
                     #value="car"
                     always-focus-hook=()
                     @on_input
                     @on_keydown/>
            </div>
            <div role="listbox"
                 id="loonbonsai_path_replaced_in_test-command-list"
                 class="loon-command-list">
              <div role="group"
                   aria-labelledby="loonbonsai_path_replaced_in_test-command-group-0"
                   class="loon-command-group">
                <div id="loonbonsai_path_replaced_in_test-command-group-0" class="loon-menu-label"> Vegetables </div>
                <div @key=carrot
                     role="option"
                     id="loonbonsai_path_replaced_in_test-command-item-carrot"
                     aria-selected="true"
                     data-highlighted=""
                     class="loon-option"
                     @on_click
                     @on_mousemove>
                  <span class="loon-menu-text"> Carrot </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle "input" Enter;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Enter))
    <div>
      <p> carrot </p>
      <div data-state="closed" class="loon-combobox loon-floating loon-select">
        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="listbox"
                aria-expanded="false"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="closed"
                type="button"
                role="combobox"
                class="loon-select-trigger"
                @on_click
                @on_keydown>
          <span class="loon-select-value"> Carrot </span>
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
               class="loon-select-chevron lucide lucide-chevrons-up-down">
            <path d="m7 15 5 5 5-5"> </path>
            <path d="m7 9 5-5 5 5"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}]
;;
