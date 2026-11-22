open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

(* With [List.map], the items are created in order (a list literal makes
   them last first), which is the order arrow keys follow without a DOM. *)
let items group =
  List.map
    [ "default", "r1", false
    ; "comfortable", "r2", false
    ; "disabled", "r3", true
    ; "compact", "r4", false
    ]
    ~f:(fun (value, id, disabled) ->
      Radio_group.item group ~value ~id ~disabled)
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Radio_group.view
       ~value:(Some "a")
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun group ->
          [ Radio_group.item group ~value:"a" ~id:"a"
          ; Radio_group.item group ~value:"b" ~id:"b"
          ]));
  [%expect
    {|
    <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group" class="gap-3 grid">
      <button type="button"
              role="radio"
              aria-checked="true"
              data-state="checked"
              tabindex="0"
              data-slot="radio-group-item"
              id="a"
              class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 aspect-square border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 disabled:cursor-not-allowed disabled:opacity-50 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none rounded-full shadow-xs shrink-0 size-4 text-primary transition-[color,box-shadow]"
              #value="a"
              @on_click
              @on_keydown>
        <span data-state="checked"
              data-slot="radio-group-indicator"
              class="flex items-center justify-center relative">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               class="-translate-x-1/2 -translate-y-1/2 absolute fill-primary left-1/2 lucide lucide-circle size-2 top-1/2">
            <circle cx="12" cy="12" r="10"> </circle>
          </svg>
        </span>
      </button>
      <button type="button"
              role="radio"
              aria-checked="false"
              data-state="unchecked"
              tabindex="-1"
              data-slot="radio-group-item"
              id="b"
              class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 aspect-square border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 disabled:cursor-not-allowed disabled:opacity-50 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none rounded-full shadow-xs shrink-0 size-4 text-primary transition-[color,box-shadow]"
              #value="b"
              @on_click
              @on_keydown> </button>
    </div>
    |}]
;;

let component ?default_value () =
  Control_render.handle
    [%sexp_of: string option]
    (Radio_group.component ?default_value (Bonsai_web.Bonsai.return items))
;;

let%expect_test "with nothing checked every enabled item is a tab stop" =
  let handle = component () in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r1"
                #value="default"
                @on_click
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r2"
                #value="comfortable"
                @on_click
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r3"
                data-disabled=""
                disabled=""
                #value="disabled"
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r4"
                #value="compact"
                @on_click
                @on_keydown> </button>
      </div>
      <output> () </output>
    </div>
    |}]
;;

let%expect_test "a click checks an item" =
  let handle = component ~default_value:"default" () in
  Drive.click handle "#r2";
  Handle.show handle;
  [%expect
    {|
    <div>
      <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r1"
                #value="default"
                @on_click
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="true"
                data-state="checked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r2"
                #value="comfortable"
                @on_click
                @on_keydown>
          <span data-state="checked" data-slot="radio-group-indicator">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"> </circle>
            </svg>
          </span>
        </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r3"
                data-disabled=""
                disabled=""
                #value="disabled"
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r4"
                #value="compact"
                @on_click
                @on_keydown> </button>
      </div>
      <output> (comfortable) </output>
    </div>
    |}]
;;

let%expect_test "arrow keys check the next enabled item, wrapping; Home and End"
  =
  let handle = component ~default_value:"comfortable" () in
  let key selector k =
    Drive.key handle selector k;
    Handle.show_diff handle
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r1"
                #value="default"
                @on_click
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="true"
                data-state="checked"
                tabindex="0"
                data-slot="radio-group-item"
                id="r2"
                #value="comfortable"
                @on_click
                @on_keydown>
          <span data-state="checked" data-slot="radio-group-indicator">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round">
              <circle cx="12" cy="12" r="10"> </circle>
            </svg>
          </span>
        </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r3"
                data-disabled=""
                disabled=""
                #value="disabled"
                @on_keydown> </button>
        <button type="button"
                role="radio"
                aria-checked="false"
                data-state="unchecked"
                tabindex="-1"
                data-slot="radio-group-item"
                id="r4"
                #value="compact"
                @on_click
                @on_keydown> </button>
      </div>
      <output> (comfortable) </output>
    </div>
    |}];
  (* Down from r2 skips the disabled r3. *)
  key "#r2" ArrowDown;
  [%expect
    {|
    ("default prevented" (key ArrowDown))

      <div>
        <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
          <button type="button"
                  role="radio"
                  aria-checked="false"
                  data-state="unchecked"
                  tabindex="-1"
                  data-slot="radio-group-item"
                  id="r1"
                  #value="default"
                  @on_click
                  @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r2"
    +|            #value="comfortable"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r3"
    +|            data-disabled=""
    +|            disabled=""
    +|            #value="disabled"
    +|            @on_keydown> </button>
          <button type="button"
                  role="radio"
                  aria-checked="true"
                  data-state="checked"
                  tabindex="0"
                  data-slot="radio-group-item"
    -|            id="r2"
    +|            id="r4"
    -|            #value="comfortable"
    +|            #value="compact"
                  @on_click
                  @on_keydown>
            <span data-state="checked" data-slot="radio-group-indicator">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"> </circle>
              </svg>
            </span>
          </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r3"
    -|            data-disabled=""
    -|            disabled=""
    -|            #value="disabled"
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r4"
    -|            #value="compact"
    -|            @on_click
    -|            @on_keydown> </button>
        </div>
    -|  <output> (comfortable) </output>
    +|  <output> (compact) </output>
      </div>
    |}];
  (* Right from the last wraps to the first. *)
  key "#r4" ArrowRight;
  [%expect
    {|
    ("default prevented" (key ArrowRight))

      <div>
        <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r1"
    -|            #value="default"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r2"
    -|            #value="comfortable"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r3"
    -|            data-disabled=""
    -|            disabled=""
    -|            #value="disabled"
    -|            @on_keydown> </button>
          <button type="button"
                  role="radio"
                  aria-checked="true"
                  data-state="checked"
                  tabindex="0"
                  data-slot="radio-group-item"
    -|            id="r4"
    +|            id="r1"
    -|            #value="compact"
    +|            #value="default"
                  @on_click
                  @on_keydown>
            <span data-state="checked" data-slot="radio-group-indicator">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"> </circle>
              </svg>
            </span>
          </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r2"
    +|            #value="comfortable"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r3"
    +|            data-disabled=""
    +|            disabled=""
    +|            #value="disabled"
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r4"
    +|            #value="compact"
    +|            @on_click
    +|            @on_keydown> </button>
        </div>
    -|  <output> (compact) </output>
    +|  <output> (default) </output>
      </div>
    |}];
  (* Up from the first wraps to the last. *)
  key "#r1" ArrowUp;
  [%expect
    {|
    ("default prevented" (key ArrowUp))

      <div>
        <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r1"
    +|            #value="default"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r2"
    +|            #value="comfortable"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r3"
    +|            data-disabled=""
    +|            disabled=""
    +|            #value="disabled"
    +|            @on_keydown> </button>
          <button type="button"
                  role="radio"
                  aria-checked="true"
                  data-state="checked"
                  tabindex="0"
                  data-slot="radio-group-item"
    -|            id="r1"
    +|            id="r4"
    -|            #value="default"
    +|            #value="compact"
                  @on_click
                  @on_keydown>
            <span data-state="checked" data-slot="radio-group-indicator">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"> </circle>
              </svg>
            </span>
          </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r2"
    -|            #value="comfortable"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r3"
    -|            data-disabled=""
    -|            disabled=""
    -|            #value="disabled"
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r4"
    -|            #value="compact"
    -|            @on_click
    -|            @on_keydown> </button>
        </div>
    -|  <output> (default) </output>
    +|  <output> (compact) </output>
      </div>
    |}];
  key "#r4" Home;
  [%expect
    {|
    ("default prevented" (key Home))

      <div>
        <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r1"
    -|            #value="default"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r2"
    -|            #value="comfortable"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r3"
    -|            data-disabled=""
    -|            disabled=""
    -|            #value="disabled"
    -|            @on_keydown> </button>
          <button type="button"
                  role="radio"
                  aria-checked="true"
                  data-state="checked"
                  tabindex="0"
                  data-slot="radio-group-item"
    -|            id="r4"
    +|            id="r1"
    -|            #value="compact"
    +|            #value="default"
                  @on_click
                  @on_keydown>
            <span data-state="checked" data-slot="radio-group-indicator">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"> </circle>
              </svg>
            </span>
          </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r2"
    +|            #value="comfortable"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r3"
    +|            data-disabled=""
    +|            disabled=""
    +|            #value="disabled"
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r4"
    +|            #value="compact"
    +|            @on_click
    +|            @on_keydown> </button>
        </div>
    -|  <output> (compact) </output>
    +|  <output> (default) </output>
      </div>
    |}];
  key "#r1" End;
  [%expect
    {|
    ("default prevented" (key End))

      <div>
        <div role="radiogroup" aria-required="false" dir="ltr" data-slot="radio-group">
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r1"
    +|            #value="default"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r2"
    +|            #value="comfortable"
    +|            @on_click
    +|            @on_keydown> </button>
    +|    <button type="button"
    +|            role="radio"
    +|            aria-checked="false"
    +|            data-state="unchecked"
    +|            tabindex="-1"
    +|            data-slot="radio-group-item"
    +|            id="r3"
    +|            data-disabled=""
    +|            disabled=""
    +|            #value="disabled"
    +|            @on_keydown> </button>
          <button type="button"
                  role="radio"
                  aria-checked="true"
                  data-state="checked"
                  tabindex="0"
                  data-slot="radio-group-item"
    -|            id="r1"
    +|            id="r4"
    -|            #value="default"
    +|            #value="compact"
                  @on_click
                  @on_keydown>
            <span data-state="checked" data-slot="radio-group-indicator">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"> </circle>
              </svg>
            </span>
          </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r2"
    -|            #value="comfortable"
    -|            @on_click
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r3"
    -|            data-disabled=""
    -|            disabled=""
    -|            #value="disabled"
    -|            @on_keydown> </button>
    -|    <button type="button"
    -|            role="radio"
    -|            aria-checked="false"
    -|            data-state="unchecked"
    -|            tabindex="-1"
    -|            data-slot="radio-group-item"
    -|            id="r4"
    -|            #value="compact"
    -|            @on_click
    -|            @on_keydown> </button>
        </div>
    -|  <output> (default) </output>
    +|  <output> (compact) </output>
      </div>
    |}];
  (* Enter does nothing (Radix). *)
  key "#r4" Enter;
  [%expect {| ("default prevented" (key Enter)) |}]
;;

let%expect_test "a disabled group" =
  Render.html
    ~classes:false
    (Radio_group.view
       ~disabled:true
       ~required:true
       ~orientation:Horizontal
       ~value:None
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun group -> [ Radio_group.item group ~value:"a" ~invalid:true ]));
  [%expect
    {|
    <div role="radiogroup"
         aria-required="true"
         dir="ltr"
         data-slot="radio-group"
         aria-orientation="horizontal"
         data-disabled="">
      <button type="button"
              role="radio"
              aria-checked="false"
              data-state="unchecked"
              tabindex="0"
              data-slot="radio-group-item"
              aria-required="true"
              aria-invalid="true"
              data-disabled=""
              disabled=""
              #value="a"
              @on_keydown> </button>
    </div>
    |}]
;;
