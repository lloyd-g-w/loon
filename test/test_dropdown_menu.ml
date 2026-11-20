open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let say s = Effect.of_thunk (fun () -> print_endline ("selected " ^ s))

let menu graph =
  let bold, set_bold = Bonsai.state false graph in
  let items =
    let%arr.Bonsai bold
    and set_bold in
    Dropdown_menu.Item.
      [ label "Edit"
      ; action ~icon:Pencil ~shortcut:"⌘E" ~on_select:(say "rename") "Rename"
      ; action ~disabled:true ~on_select:(say "move") "Move"
      ; checkbox ~checked:bold ~on_change:set_bold "Bold"
      ; separator
      ; action ~danger:true ~on_select:(say "delete") "Delete"
      ]
  in
  Dropdown_menu.component
    ~trigger:(fun attrs -> Button.view ~attrs [ Vdom.Node.text "Menu" ])
    items
    graph
;;

let%expect_test "opens on click, arrows skip disabled items, Enter chooses" =
  let handle = Render.handle menu in
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div data-state="open" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
      <div aria-hidden="true" class="loon-click-away" @on_click> </div>
      <div id="loonbonsai_path_replaced_in_test-content"
           data-side="bottom"
           data-align="start"
           role="menu"
           tabindex="-1"
           aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
           class="loon-floating-content loon-menu"
           always-focus-hook=()
           loon-keep-in-view=()
           @on_keydown>
        <div class="loon-menu-label"> Edit </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-1"
             tabindex="-1"
             class="loon-menu-item"
             @on_click
             @on_mousemove>
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-pencil">
            <path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"> </path>
            <path d="m15 5 4 4"> </path>
          </svg>
          <span class="loon-menu-text"> Rename </span>
          <span class="loon-menu-shortcut"> ⌘E </span>
        </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-2"
             tabindex="-1"
             aria-disabled="true"
             data-disabled=""
             class="loon-menu-item">
          <span class="loon-menu-text"> Move </span>
        </div>
        <div role="menuitemcheckbox"
             id="loonbonsai_path_replaced_in_test-item-3"
             tabindex="-1"
             aria-checked="false"
             class="loon-menu-item"
             @on_click
             @on_mousemove>
          <span class="loon-menu-indicator"> </span>
          <span class="loon-menu-text"> Bold </span>
        </div>
        <div role="separator" class="loon-menu-separator"> </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-5"
             tabindex="-1"
             class="loon-menu-item loon-menu-item-danger"
             @on_click
             @on_mousemove>
          <span class="loon-menu-text"> Delete </span>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle "[role=menu]" ArrowDown;
  Drive.key handle "[role=menu]" ArrowDown;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key ArrowDown))
    ("default prevented" (key ArrowDown))

        <button id="loonbonsai_path_replaced_in_test-trigger"
                aria-haspopup="menu"
                aria-expanded="true"
                aria-controls="loonbonsai_path_replaced_in_test-content"
                data-state="open"
                type="button"
                class="loon-button loon-button-md loon-button-primary"
                @on_click
                @on_keydown> Menu </button>
        <div aria-hidden="true" class="loon-click-away" @on_click> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             data-side="bottom"
             data-align="start"
             role="menu"
             tabindex="-1"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
    +|       aria-activedescendant="loonbonsai_path_replaced_in_test-item-3"
             class="loon-floating-content loon-menu"
             always-focus-hook=()
             loon-keep-in-view=()
             @on_keydown>
          <div class="loon-menu-label"> Edit </div>
          <div role="menuitem"
               id="loonbonsai_path_replaced_in_test-item-1"
               tabindex="-1"
               class="loon-menu-item"
               @on_click
               @on_mousemove>
            <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-pencil">
              <path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"> </path>
              <path d="m15 5 4 4"> </path>
            </svg>
            <span class="loon-menu-text"> Rename </span>
            <span class="loon-menu-shortcut"> ⌘E </span>
          </div>
          <div role="menuitem"
               id="loonbonsai_path_replaced_in_test-item-2"
               tabindex="-1"
               aria-disabled="true"
               data-disabled=""
               class="loon-menu-item">
            <span class="loon-menu-text"> Move </span>
          </div>
          <div role="menuitemcheckbox"
               id="loonbonsai_path_replaced_in_test-item-3"
               tabindex="-1"
               aria-checked="false"
    +|         data-highlighted=""
               class="loon-menu-item"
               @on_click
               @on_mousemove>
            <span class="loon-menu-indicator"> </span>
            <span class="loon-menu-text"> Bold </span>
          </div>
          <div role="separator" class="loon-menu-separator"> </div>
          <div role="menuitem"
               id="loonbonsai_path_replaced_in_test-item-5"
               tabindex="-1"
               class="loon-menu-item loon-menu-item-danger"
               @on_click
               @on_mousemove>
            <span class="loon-menu-text"> Delete </span>
          </div>
        </div>
    |}];
  (* A checkbox item toggles and keeps the menu open. *)
  Drive.key handle "[role=menu]" Enter;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key Enter))

              <path d="m15 5 4 4"> </path>
            </svg>
            <span class="loon-menu-text"> Rename </span>
            <span class="loon-menu-shortcut"> ⌘E </span>
          </div>
          <div role="menuitem"
               id="loonbonsai_path_replaced_in_test-item-2"
               tabindex="-1"
               aria-disabled="true"
               data-disabled=""
               class="loon-menu-item">
            <span class="loon-menu-text"> Move </span>
          </div>
          <div role="menuitemcheckbox"
               id="loonbonsai_path_replaced_in_test-item-3"
               tabindex="-1"
    -|         aria-checked="false"
    +|         aria-checked="true"
               data-highlighted=""
               class="loon-menu-item"
               @on_click
               @on_mousemove>
    -|      <span class="loon-menu-indicator"> </span>
    +|      <span class="loon-menu-indicator">
    +|        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-check">
    +|          <path d="M20 6 9 17l-5-5"> </path>
    +|        </svg>
    +|      </span>
            <span class="loon-menu-text"> Bold </span>
          </div>
          <div role="separator" class="loon-menu-separator"> </div>
          <div role="menuitem"
               id="loonbonsai_path_replaced_in_test-item-5"
               tabindex="-1"
               class="loon-menu-item loon-menu-item-danger"
               @on_click
               @on_mousemove>
            <span class="loon-menu-text"> Delete </span>
          </div>
        </div>
      </div>
    |}];
  (* Typeahead: d jumps to Delete. *)
  Drive.key handle "[role=menu]" KeyD;
  Drive.key handle "[role=menu]" Enter;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key KeyD))
    ("default prevented" (key Enter))
    selected delete
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
    </div>
    |}]
;;

let%expect_test "keyboard opening, clicking items, Escape and clicking away" =
  let handle = Render.handle menu in
  Drive.key handle "button" ArrowUp;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key ArrowUp))
    <div data-state="open" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
      <div aria-hidden="true" class="loon-click-away" @on_click> </div>
      <div id="loonbonsai_path_replaced_in_test-content"
           data-side="bottom"
           data-align="start"
           role="menu"
           tabindex="-1"
           aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
           aria-activedescendant="loonbonsai_path_replaced_in_test-item-5"
           class="loon-floating-content loon-menu"
           always-focus-hook=()
           loon-keep-in-view=()
           @on_keydown>
        <div class="loon-menu-label"> Edit </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-1"
             tabindex="-1"
             class="loon-menu-item"
             @on_click
             @on_mousemove>
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-pencil">
            <path d="M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"> </path>
            <path d="m15 5 4 4"> </path>
          </svg>
          <span class="loon-menu-text"> Rename </span>
          <span class="loon-menu-shortcut"> ⌘E </span>
        </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-2"
             tabindex="-1"
             aria-disabled="true"
             data-disabled=""
             class="loon-menu-item">
          <span class="loon-menu-text"> Move </span>
        </div>
        <div role="menuitemcheckbox"
             id="loonbonsai_path_replaced_in_test-item-3"
             tabindex="-1"
             aria-checked="false"
             class="loon-menu-item"
             @on_click
             @on_mousemove>
          <span class="loon-menu-indicator"> </span>
          <span class="loon-menu-text"> Bold </span>
        </div>
        <div role="separator" class="loon-menu-separator"> </div>
        <div role="menuitem"
             id="loonbonsai_path_replaced_in_test-item-5"
             tabindex="-1"
             data-highlighted=""
             class="loon-menu-item loon-menu-item-danger"
             @on_click
             @on_mousemove>
          <span class="loon-menu-text"> Delete </span>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle "[role=menu]" Escape;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Escape))
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
    </div>
    |}];
  Drive.click handle "button";
  Drive.click handle "[role=menuitem]";
  [%expect {| selected rename |}];
  Drive.click handle "button";
  (* Disabled items have no click handler. *)
  Drive.click handle ".loon-click-away";
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="menu"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click
              @on_keydown> Menu </button>
    </div>
    |}]
;;
