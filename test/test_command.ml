open! Core
open Loon
open Bonsai_web
open Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr
module Handle = Bonsai_web_test.Handle

let parts ~on_select =
  let item ?disabled ?shortcut icon value =
    Command.item
      ?disabled
      ~value
      ~on_select:(on_select value)
      ([ Icon.view icon; Node.span [ Node.text value ] ]
       @ Option.value_map shortcut ~default:[] ~f:(fun s ->
         [ Command.shortcut [ Node.text s ] ]))
  in
  [ Command.input ~placeholder:"Type a command or search..." ()
  ; Command.list
      [ Command.empty [ Node.text "No results found." ]
      ; Command.group
          ~heading:"Suggestions"
          [ item Calendar "Calendar"
          ; item Face_slightly_smiling "Search Emoji"
          ; item ~disabled:true Calculator "Calculator"
          ]
      ; Command.separator ()
      ; Command.group
          ~heading:"Settings"
          [ item User "Profile" ~shortcut:"⌘P"
          ; item Credit_card "Billing" ~shortcut:"⌘B"
          ; item Settings "Settings" ~shortcut:"⌘S"
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Command.view
       ~id:"c"
       ~state:Command.State.empty
       ~on_change:(fun _ -> Effect.Ignore)
       [ Command.input ~placeholder:"Search..." ()
       ; Command.list
           [ Command.empty [ Node.text "No results found." ]
           ; Command.group
               ~heading:"Suggestions"
               [ Command.item
                   [ Node.text "Calendar"; Command.shortcut [ Node.text "⌘C" ] ]
               ]
           ; Command.separator ()
           ]
       ]);
  [%expect {|
    <div tabindex="-1"
         cmdk-root=""
         data-slot="command"
         class="bg-popover flex flex-col h-full overflow-hidden rounded-md text-popover-foreground w-full"
         @on_keydown>
      <label cmdk-label=""
             for="c-input"
             id="c-label"
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
               aria-controls="c-list"
               aria-labelledby="c-label"
               aria-activedescendant="c-item-0"
               id="c-input"
               type="text"
               data-slot="command-input"
               placeholder="Search..."
               class="bg-transparent disabled:cursor-not-allowed disabled:opacity-50 flex h-10 outline-hidden placeholder:text-muted-foreground py-3 rounded-md text-sm w-full"
               #value=""
               @on_input/>
      </div>
      <div cmdk-list=""
           role="listbox"
           tabindex="-1"
           aria-activedescendant="c-item-0"
           aria-label="Suggestions"
           id="c-list"
           data-slot="command-list"
           class="max-h-[300px] overflow-x-hidden overflow-y-auto scroll-py-1">
        <div cmdk-list-sizer="">
          <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          <div cmdk-group=""
               role="presentation"
               data-value="Suggestions"
               data-slot="command-group"
               class="[&_[cmdk-group-heading]]:font-medium [&_[cmdk-group-heading]]:px-2 [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-muted-foreground [&_[cmdk-group-heading]]:text-xs overflow-hidden p-1 text-foreground">
            <div cmdk-group-heading="" aria-hidden="true" id="c-group-0"> Suggestions </div>
            <div cmdk-group-items="" role="group" aria-labelledby="c-group-0">
              <div cmdk-item=""
                   role="option"
                   aria-disabled="false"
                   aria-selected="true"
                   data-disabled="false"
                   data-selected="true"
                   data-value="Calendar"
                   id="c-item-0"
                   data-slot="command-item"
                   class="[&_svg:not([class*='size-'])]:size-4 [&_svg:not([class*='text-'])]:text-muted-foreground [&_svg]:pointer-events-none [&_svg]:shrink-0 cursor-default data-[disabled=true]:opacity-50 data-[disabled=true]:pointer-events-none data-[selected=true]:bg-accent data-[selected=true]:text-accent-foreground flex gap-2 items-center outline-hidden px-2 py-1.5 relative rounded-sm select-none text-sm"
                   @on_click
                   @on_pointermove>
                Calendar
                <span data-slot="command-shortcut"
                      class="ml-auto text-muted-foreground text-xs tracking-widest"> ⌘C </span>
              </div>
            </div>
          </div>
          <div cmdk-separator=""
               role="separator"
               data-slot="command-separator"
               class="-mx-1 bg-border h-px"> </div>
        </div>
      </div>
    </div>
    |}]
;;

let app (local_ graph) =
  let chosen, set_chosen = Bonsai.state "" graph in
  let command =
    Command.component
      (let%arr set_chosen in
       parts ~on_select:(fun v -> set_chosen v))
      graph
  in
  let%arr command and chosen in
  Node.div [ Node.p [ Node.text ("chosen: " ^ chosen) ]; command ]
;;

let input = "[cmdk-input]"
let root = "[cmdk-root]"

module H = Virtual_dom_test_helpers.Node_helpers

(* The menu in short: what was chosen, then each group (hidden ones in
   brackets) with its items in order, the selected one marked [>], disabled
   ones [-]; and the empty message when shown. *)
let summary node =
  let node = H.unsafe_convert_exn node in
  let attr (e : H.t) name =
    match e with
    | Element e -> List.Assoc.find e.attributes name ~equal:String.equal
    | _ -> None
  in
  let rec text (n : H.t) =
    match n with
    | Text s -> s
    | Element e -> String.concat (List.map e.children ~f:text)
    | Widget -> ""
  in
  List.iter (H.select node ~selector:"p") ~f:(fun p -> print_endline (String.strip (text p)));
  let rec walk (n : H.t) =
    match n with
    | Text _ | Widget -> ()
    | Element e ->
      if Option.is_some (attr n "cmdk-empty")
      then printf "empty: %s\n" (String.strip (text n))
      else if Option.is_some (attr n "cmdk-separator")
      then print_endline "---"
      else if Option.is_some (attr n "cmdk-group")
      then (
        let heading = Option.value (attr n "data-value") ~default:"" in
        let hidden = Option.is_some (attr n "hidden") in
        printf "%s\n" (if hidden then "[" ^ heading ^ "]" else heading);
        List.iter e.children ~f:walk)
      else if Option.is_some (attr n "cmdk-item")
      then (
        let mark =
          match attr n "data-selected", attr n "data-disabled" with
          | Some "true", _ -> ">"
          | _, Some "true" -> "-"
          | _ -> " "
        in
        printf "  %s %s\n" mark (Option.value (attr n "data-value") ~default:""))
      else List.iter e.children ~f:walk
  in
  walk node
;;

let show handle = summary (Handle.last_result handle)

let%expect_test "the first item is selected; arrows, Home and End move, skipping disabled \
                 ones; Enter chooses"
  =
  let handle = Render.handle ~classes:false app in
  show handle;
  [%expect {|
    chosen:
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}];
  Drive.key handle root ArrowDown;
  show handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    chosen:
    Suggestions
        Calendar
      > Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}];
  Drive.key handle root ArrowDown;
  show handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    chosen:
    Suggestions
        Calendar
        Search Emoji
      - Calculator
    ---
    Settings
      > Profile
        Billing
        Settings
    |}];
  Drive.key handle root ArrowUp;
  Drive.key handle root ArrowUp;
  Drive.key handle root ArrowUp;
  show handle;
  [%expect {|
    ("default prevented" (key ArrowUp))
    ("default prevented" (key ArrowUp))
    ("default prevented" (key ArrowUp))
    chosen:
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}];
  Drive.key handle root End;
  Drive.key handle root ArrowDown;
  show handle;
  [%expect {|
    ("default prevented" (key End))
    ("default prevented" (key ArrowDown))
    chosen:
    Suggestions
        Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
      > Settings
    |}];
  Drive.key handle root Enter;
  show handle;
  [%expect {|
    ("default prevented" (key Enter))
    chosen: Settings
    Suggestions
        Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
      > Settings
    |}];
  Drive.key handle root Home;
  show handle;
  [%expect {|
    ("default prevented" (key Home))
    chosen: Settings
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}];
  Drive.click handle "[data-value=Billing]";
  show handle;
  [%expect {|
    chosen: Billing
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}]
;;

let%expect_test "ARIA: the input points at the selected item" =
  let handle = Render.handle ~classes:false app in
  Drive.key handle root ArrowDown;
  Render.html ~classes:false ~selector:"[cmdk-input]" (Handle.last_result handle);
  [%expect {|
    ("default prevented" (key ArrowDown))
    <input cmdk-input=""
           autocomplete="off"
           autocorrect="off"
           spellcheck="false"
           aria-autocomplete="list"
           role="combobox"
           aria-expanded="true"
           aria-controls="bonsai_path_replaced_in_test-list"
           aria-labelledby="bonsai_path_replaced_in_test-label"
           aria-activedescendant="bonsai_path_replaced_in_test-item-1"
           id="bonsai_path_replaced_in_test-input"
           type="text"
           data-slot="command-input"
           placeholder="Type a command or search..."
           #value=""
           @on_input/>
    |}]
;;

let%expect_test "typing filters and ranks; empty groups hide; nothing matching shows Empty" =
  let handle = Render.handle ~classes:false app in
  Drive.type_ handle input "se";
  show handle;
  [%expect {|
    chosen:
    Suggestions
      > Search Emoji
    Settings
        Settings
    |}];
  Drive.type_ handle input "bil";
  show handle;
  [%expect {|
    chosen:
    Settings
      > Billing
    [Suggestions]
    |}];
  Drive.type_ handle input "qqq";
  show handle;
  [%expect {|
    chosen:
    empty: No results found.
    [Suggestions]
    [Settings]
    |}];
  Drive.key handle root Enter;
  Drive.type_ handle input "";
  show handle;
  [%expect {|
    chosen:
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}]
;;

let%expect_test "the dialog: opened and closed by its state, the search cleared" =
  let app (local_ graph) =
    let open_, set_open = Bonsai.state false graph in
    let state, set_state = Bonsai.state Command.State.empty graph in
    let%arr open_ and set_open and state and set_state in
    Node.div
      [ Node.button
          ~attrs:[ Attr.id "open"; Attr.on_click (fun _ -> set_open true) ]
          [ Node.text "Open" ]
      ; Command.dialog
          ~id:"d"
          ~open_
          ~on_open_change:set_open
          ~state
          ~on_change:set_state
          (parts ~on_select:(fun _ -> set_open false))
      ]
  in
  let handle = Render.handle ~classes:false app in
  Handle.show handle;
  [%expect {|
    <div>
      <button id="open" @on_click> Open </button>
      <div data-slot="dialog-header">
        <h2 data-slot="dialog-title" id="d-title"> Command Palette </h2>
        <p data-slot="dialog-description" id="d-description"> Search for a command to run... </p>
      </div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "#open";
  Drive.type_ handle input "bil";
  Handle.show handle;
  [%expect {|
    <div>
      <button id="open" @on_click> Open </button>
      <div data-slot="dialog-header">
        <h2 data-slot="dialog-title" id="d-title"> Command Palette </h2>
        <p data-slot="dialog-description" id="d-description"> Search for a command to run... </p>
      </div>
      <div popover="manual"
           loon-portal=()
           loon-presence=()
           style={
             inset: 0;
             margin: 0;
             border: 0;
             padding: 0;
             background: transparent;
             color: inherit;
             overflow: visible;
             max-width: none;
             max-height: none;
             position: fixed;
             width: 100%;
             height: 100%;
             pointer-events: none;
             z-index: 50;
           }>
        <div data-slot="dialog-overlay" data-state="open" @on_click style={ pointer-events: auto; }> </div>
        <div data-focus-guard=""
             tabindex="0"
             aria-hidden="true"
             @on_focus
             style={
               position: fixed;
               opacity: 0;
               outline: none;
               pointer-events: none;
             }> </div>
        <div role="dialog"
             id="d-content"
             aria-describedby="d-description"
             aria-labelledby="d-title"
             data-state="open"
             tabindex="-1"
             data-slot="dialog-content"
             loon-dismiss=(()false true)
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div tabindex="-1" cmdk-root="" data-slot="command" @on_keydown>
            <label cmdk-label=""
                   for="d-command-input"
                   id="d-command-label"
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
                     aria-controls="d-command-list"
                     aria-labelledby="d-command-label"
                     aria-activedescendant="d-command-item-4"
                     id="d-command-input"
                     type="text"
                     data-slot="command-input"
                     placeholder="Type a command or search..."
                     #value="bil"
                     @on_input/>
            </div>
            <div cmdk-list=""
                 role="listbox"
                 tabindex="-1"
                 aria-activedescendant="d-command-item-4"
                 aria-label="Suggestions"
                 id="d-command-list"
                 data-slot="command-list">
              <div cmdk-list-sizer="">
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <div cmdk-group="" role="presentation" data-value="Settings" data-slot="command-group">
                  <div cmdk-group-heading="" aria-hidden="true" id="d-command-group-4"> Settings </div>
                  <div cmdk-group-items="" role="group" aria-labelledby="d-command-group-4">
                    <div cmdk-item=""
                         role="option"
                         aria-disabled="false"
                         aria-selected="true"
                         data-disabled="false"
                         data-selected="true"
                         data-value="Billing"
                         id="d-command-item-4"
                         data-slot="command-item"
                         @on_click
                         @on_pointermove>
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
                        <rect width="20" height="14" x="2" y="5" rx="2"> </rect>
                        <line x1="2" x2="22" y1="10" y2="10"> </line>
                        <path d="M6 14h2"> </path>
                      </svg>
                      <span> Billing </span>
                      <span data-slot="command-shortcut"> ⌘B </span>
                    </div>
                    <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                    <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  </div>
                </div>
                <div cmdk-group=""
                     role="presentation"
                     data-value="Suggestions"
                     hidden=""
                     data-slot="command-group">
                  <div cmdk-group-heading="" aria-hidden="true" id="d-command-group-0"> Suggestions </div>
                  <div cmdk-group-items="" role="group" aria-labelledby="d-command-group-0">
                    <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                    <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                    <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <button type="button" data-slot="dialog-close" @on_click>
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
              <path d="M18 6 6 18"> </path>
              <path d="m6 6 12 12"> </path>
            </svg>
            <span> Close </span>
          </button>
        </div>
        <div data-focus-guard=""
             tabindex="0"
             aria-hidden="true"
             @on_focus
             style={
               position: fixed;
               opacity: 0;
               outline: none;
               pointer-events: none;
             }> </div>
      </div>
    </div>
    |}];
  Drive.key handle "[role=dialog]" Escape;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key Escape))
    <div>
      <button id="open" @on_click> Open </button>
      <div data-slot="dialog-header">
        <h2 data-slot="dialog-title" id="d-title"> Command Palette </h2>
        <p data-slot="dialog-description" id="d-description"> Search for a command to run... </p>
      </div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "#open";
  show handle;
  [%expect {|
    Search for a command to run...
    Suggestions
      > Calendar
        Search Emoji
      - Calculator
    ---
    Settings
        Profile
        Billing
        Settings
    |}]
;;
