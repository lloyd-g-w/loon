open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let say s = Effect.of_thunk (fun () -> print_endline ("ran " ^ s))

let groups =
  Command_palette.
    [ Group.create
        ~heading:"Suggestions"
        [ Item.create ~icon:Calendar ~on_select:(say "calendar") "Calendar"
        ; Item.create
            ~keywords:[ "find" ]
            ~on_select:(say "search")
            "Search files"
        ; Item.create ~disabled:true ~on_select:(say "inbox") "Inbox"
        ]
    ; Group.create
        ~heading:"Settings"
        [ Item.create ~shortcut:"⌘P" ~on_select:(say "profile") "Profile"
        ; Item.create ~on_select:(say "settings") "Settings"
        ]
    ]
;;

let print_filter query =
  Command_palette.filter ~query groups
  |> List.iter ~f:(fun (g : Command_palette.Group.t) ->
    printf
      "%s: %s\n"
      (Option.value g.heading ~default:"-")
      (String.concat ~sep:", " (List.map g.items ~f:(fun i -> i.label))))
;;

let%expect_test "filtering keeps groups in order and items best first" =
  print_filter "";
  [%expect
    {|
    Suggestions: Calendar, Search files, Inbox
    Settings: Profile, Settings
    |}];
  print_filter "se";
  [%expect
    {|
    Suggestions: Search files
    Settings: Settings
    |}];
  print_filter "find";
  [%expect {| Suggestions: Search files |}];
  print_filter "zzz";
  [%expect {| |}]
;;

let%expect_test "typing filters, arrows move, Enter runs" =
  let handle =
    Render.handle (Command_palette.component (Bonsai.return groups))
  in
  Handle.show handle;
  [%expect
    {|
    <div class="loon-command">
      <div class="loon-command-search">
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-search">
          <circle cx="11." cy="11." r="7."> </circle>
          <path d="m20 20-3.5-3.5"> </path>
        </svg>
        <input type="text"
               role="combobox"
               placeholder="Type a command or search…"
               autocomplete="off"
               spellcheck="false"
               aria-autocomplete="list"
               aria-expanded="true"
               aria-controls="loonbonsai_path_replaced_in_test-list"
               aria-label="Type a command or search…"
               aria-activedescendant="loonbonsai_path_replaced_in_test-item-Calendar"
               class="loon-command-input"
               #value=""
               @on_input
               @on_keydown/>
      </div>
      <div role="listbox" id="loonbonsai_path_replaced_in_test-list" class="loon-command-list">
        <div role="group"
             aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
             class="loon-command-group">
          <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Suggestions </div>
          <div @key=Calendar
               role="option"
               id="loonbonsai_path_replaced_in_test-item-Calendar"
               aria-selected="true"
               data-highlighted=""
               class="loon-option"
               @on_click
               @on_mousemove>
            <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-calendar">
              <path d="M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"> </path>
              <path d="M16 2v4M8 2v4M3 10h18"> </path>
            </svg>
            <span class="loon-menu-text"> Calendar </span>
          </div>
          <div @key=Search files
               role="option"
               id="loonbonsai_path_replaced_in_test-item-Search_files"
               aria-selected="false"
               class="loon-option"
               @on_click
               @on_mousemove>
            <span class="loon-menu-text"> Search files </span>
          </div>
          <div @key=Inbox
               role="option"
               id="loonbonsai_path_replaced_in_test-item-Inbox"
               aria-selected="false"
               aria-disabled="true"
               data-disabled=""
               class="loon-option">
            <span class="loon-menu-text"> Inbox </span>
          </div>
        </div>
        <div role="group"
             aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
             class="loon-command-group">
          <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Settings </div>
          <div @key=Profile
               role="option"
               id="loonbonsai_path_replaced_in_test-item-Profile"
               aria-selected="false"
               class="loon-option"
               @on_click
               @on_mousemove>
            <span class="loon-menu-text"> Profile </span>
            <span class="loon-menu-shortcut"> ⌘P </span>
          </div>
          <div @key=Settings
               role="option"
               id="loonbonsai_path_replaced_in_test-item-Settings"
               aria-selected="false"
               class="loon-option"
               @on_click
               @on_mousemove>
            <span class="loon-menu-text"> Settings </span>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.type_ handle "input" "s";
  Handle.show_diff handle;
  [%expect
    {|
      <div class="loon-command">
        <div class="loon-command-search">
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-search">
            <circle cx="11." cy="11." r="7."> </circle>
            <path d="m20 20-3.5-3.5"> </path>
          </svg>
          <input type="text"
                 role="combobox"
                 placeholder="Type a command or search…"
                 autocomplete="off"
                 spellcheck="false"
                 aria-autocomplete="list"
                 aria-expanded="true"
                 aria-controls="loonbonsai_path_replaced_in_test-list"
                 aria-label="Type a command or search…"
    -|           aria-activedescendant="loonbonsai_path_replaced_in_test-item-Calendar"
    +|           aria-activedescendant="loonbonsai_path_replaced_in_test-item-Search_files"
                 class="loon-command-input"
    -|           #value=""
    +|           #value="s"
                 @on_input
                 @on_keydown/>
        </div>
        <div role="listbox" id="loonbonsai_path_replaced_in_test-list" class="loon-command-list">
          <div role="group"
               aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
               class="loon-command-group">
            <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Suggestions </div>
    -|      <div @key=Calendar
    +|      <div @key=Search files
                 role="option"
    -|           id="loonbonsai_path_replaced_in_test-item-Calendar"
    +|           id="loonbonsai_path_replaced_in_test-item-Search_files"
                 aria-selected="true"
                 data-highlighted=""
                 class="loon-option"
                 @on_click
                 @on_mousemove>
    -|        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-calendar">
    -|          <path d="M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"> </path>
    -|          <path d="M16 2v4M8 2v4M3 10h18"> </path>
    -|        </svg>
    -|        <span class="loon-menu-text"> Calendar </span>
    -|      </div>
    -|      <div @key=Search files
    -|           role="option"
    -|           id="loonbonsai_path_replaced_in_test-item-Search_files"
    -|           aria-selected="false"
    -|           class="loon-option"
    -|           @on_click
    -|           @on_mousemove>
    -|        <span class="loon-menu-text"> Search files </span>
    -|      </div>
    -|      <div @key=Inbox
    -|           role="option"
    -|           id="loonbonsai_path_replaced_in_test-item-Inbox"
    -|           aria-selected="false"
    -|           aria-disabled="true"
    -|           data-disabled=""
    -|           class="loon-option">
    -|        <span class="loon-menu-text"> Inbox </span>
    +|        <span class="loon-menu-text"> Search files </span>
            </div>
          </div>
          <div role="group"
               aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
               class="loon-command-group">
            <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Settings </div>
    -|      <div @key=Profile
    -|           role="option"
    -|           id="loonbonsai_path_replaced_in_test-item-Profile"
    -|           aria-selected="false"
    -|           class="loon-option"
    -|           @on_click
    -|           @on_mousemove>
    -|        <span class="loon-menu-text"> Profile </span>
    -|        <span class="loon-menu-shortcut"> ⌘P </span>
    -|      </div>
            <div @key=Settings
                 role="option"
                 id="loonbonsai_path_replaced_in_test-item-Settings"
                 aria-selected="false"
                 class="loon-option"
                 @on_click
                 @on_mousemove>
              <span class="loon-menu-text"> Settings </span>
            </div>
          </div>
        </div>
      </div>
    |}];
  Drive.key handle "input" ArrowDown;
  Handle.show_diff handle;
  [%expect
    {|
    ("default prevented" (key ArrowDown))

      <div class="loon-command">
        <div class="loon-command-search">
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-search">
            <circle cx="11." cy="11." r="7."> </circle>
            <path d="m20 20-3.5-3.5"> </path>
          </svg>
          <input type="text"
                 role="combobox"
                 placeholder="Type a command or search…"
                 autocomplete="off"
                 spellcheck="false"
                 aria-autocomplete="list"
                 aria-expanded="true"
                 aria-controls="loonbonsai_path_replaced_in_test-list"
                 aria-label="Type a command or search…"
    -|           aria-activedescendant="loonbonsai_path_replaced_in_test-item-Search_files"
    +|           aria-activedescendant="loonbonsai_path_replaced_in_test-item-Settings"
                 class="loon-command-input"
                 #value="s"
                 @on_input
                 @on_keydown/>
        </div>
        <div role="listbox" id="loonbonsai_path_replaced_in_test-list" class="loon-command-list">
          <div role="group"
               aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
               class="loon-command-group">
            <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Suggestions </div>
            <div @key=Search files
                 role="option"
                 id="loonbonsai_path_replaced_in_test-item-Search_files"
    -|           aria-selected="true"
    -|           data-highlighted=""
    +|           aria-selected="false"
                 class="loon-option"
                 @on_click
                 @on_mousemove>
              <span class="loon-menu-text"> Search files </span>
            </div>
          </div>
          <div role="group"
               aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
               class="loon-command-group">
            <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Settings </div>
            <div @key=Settings
                 role="option"
                 id="loonbonsai_path_replaced_in_test-item-Settings"
    -|           aria-selected="false"
    +|           aria-selected="true"
    +|           data-highlighted=""
                 class="loon-option"
                 @on_click
                 @on_mousemove>
              <span class="loon-menu-text"> Settings </span>
            </div>
          </div>
        </div>
      </div>
    |}];
  Drive.key handle "input" Enter;
  [%expect
    {|
    ("default prevented" (key Enter))
    ran settings
    |}];
  Drive.type_ handle "input" "qqq";
  Handle.show handle;
  [%expect
    {|
    <div class="loon-command">
      <div class="loon-command-search">
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-search">
          <circle cx="11." cy="11." r="7."> </circle>
          <path d="m20 20-3.5-3.5"> </path>
        </svg>
        <input type="text"
               role="combobox"
               placeholder="Type a command or search…"
               autocomplete="off"
               spellcheck="false"
               aria-autocomplete="list"
               aria-expanded="true"
               aria-controls="loonbonsai_path_replaced_in_test-list"
               aria-label="Type a command or search…"
               class="loon-command-input"
               #value="qqq"
               @on_input
               @on_keydown/>
      </div>
      <div role="listbox" id="loonbonsai_path_replaced_in_test-list" class="loon-command-list">
        <div class="loon-command-empty"> No results found. </div>
      </div>
    </div>
    |}]
;;

let%expect_test "the palette opens in a dialog and closes when an item runs" =
  let handle =
    Render.handle (fun graph ->
      let palette = Command_palette.dialog (Bonsai.return groups) graph in
      let%arr.Bonsai view, open_ = palette in
      Vdom.Node.div
        [ Vdom.Node.button
            ~attrs:[ Vdom.Attr.id "open"; Vdom.Attr.on_click (fun _ -> open_) ]
            [ Vdom.Node.text "Open" ]
        ; view
        ])
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button id="open" @on_click> Open </button>
      <div class="loon-modal-anchor" @on_keydown_global>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </div>
    </div>
    |}];
  Drive.click handle "#open";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button id="open" @on_click> Open </button>
      <div class="loon-modal-anchor" @on_keydown_global>
        <div class="loon-command-dialog-root loon-modal" @on_keydown>
          <div aria-hidden="true" class="loon-scrim" @on_click> </div>
          <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
          <div id="loonbonsai_path_replaced_in_test-content"
               role="dialog"
               aria-modal="true"
               aria-labelledby="loonbonsai_path_replaced_in_test-title"
               tabindex="-1"
               data-state="open"
               class="loon-command-dialog"
               always-focus-hook=()>
            <h2 id="loonbonsai_path_replaced_in_test-title" class="loon-visually-hidden"> Command palette </h2>
            <div class="loon-command">
              <div class="loon-command-search">
                <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-search">
                  <circle cx="11." cy="11." r="7."> </circle>
                  <path d="m20 20-3.5-3.5"> </path>
                </svg>
                <input type="text"
                       role="combobox"
                       placeholder="Type a command or search…"
                       autocomplete="off"
                       spellcheck="false"
                       aria-autocomplete="list"
                       aria-expanded="true"
                       aria-controls="loonbonsai_path_replaced_in_test-list"
                       aria-label="Type a command or search…"
                       aria-activedescendant="loonbonsai_path_replaced_in_test-item-Calendar"
                       class="loon-command-input"
                       #value=""
                       always-focus-hook=()
                       @on_input
                       @on_keydown/>
              </div>
              <div role="listbox" id="loonbonsai_path_replaced_in_test-list" class="loon-command-list">
                <div role="group"
                     aria-labelledby="loonbonsai_path_replaced_in_test-group-0"
                     class="loon-command-group">
                  <div id="loonbonsai_path_replaced_in_test-group-0" class="loon-menu-label"> Suggestions </div>
                  <div @key=Calendar
                       role="option"
                       id="loonbonsai_path_replaced_in_test-item-Calendar"
                       aria-selected="true"
                       data-highlighted=""
                       class="loon-option"
                       @on_click
                       @on_mousemove>
                    <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-calendar">
                      <path d="M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"> </path>
                      <path d="M16 2v4M8 2v4M3 10h18"> </path>
                    </svg>
                    <span class="loon-menu-text"> Calendar </span>
                  </div>
                  <div @key=Search files
                       role="option"
                       id="loonbonsai_path_replaced_in_test-item-Search_files"
                       aria-selected="false"
                       class="loon-option"
                       @on_click
                       @on_mousemove>
                    <span class="loon-menu-text"> Search files </span>
                  </div>
                  <div @key=Inbox
                       role="option"
                       id="loonbonsai_path_replaced_in_test-item-Inbox"
                       aria-selected="false"
                       aria-disabled="true"
                       data-disabled=""
                       class="loon-option">
                    <span class="loon-menu-text"> Inbox </span>
                  </div>
                </div>
                <div role="group"
                     aria-labelledby="loonbonsai_path_replaced_in_test-group-1"
                     class="loon-command-group">
                  <div id="loonbonsai_path_replaced_in_test-group-1" class="loon-menu-label"> Settings </div>
                  <div @key=Profile
                       role="option"
                       id="loonbonsai_path_replaced_in_test-item-Profile"
                       aria-selected="false"
                       class="loon-option"
                       @on_click
                       @on_mousemove>
                    <span class="loon-menu-text"> Profile </span>
                    <span class="loon-menu-shortcut"> ⌘P </span>
                  </div>
                  <div @key=Settings
                       role="option"
                       id="loonbonsai_path_replaced_in_test-item-Settings"
                       aria-selected="false"
                       class="loon-option"
                       @on_click
                       @on_mousemove>
                    <span class="loon-menu-text"> Settings </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
        </div>
      </div>
    </div>
    |}];
  Drive.click handle "[role=option]:not([aria-disabled])";
  Handle.show handle;
  [%expect
    {|
    ran calendar
    <div>
      <button id="open" @on_click> Open </button>
      <div class="loon-modal-anchor" @on_keydown_global>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </div>
    </div>
    |}]
;;
