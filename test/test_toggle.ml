open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Attr = Virtual_dom.Vdom.Attr
module Handle = Bonsai_web_test.Handle

let%expect_test "variants and sizes" =
  List.iter Toggle.Variant.all ~f:(fun variant ->
    List.iter Toggle.Size.all ~f:(fun size ->
      Render.html
        (Toggle.view
           ~variant
           ~size
           ~pressed:false
           ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
           [ Node.text "B" ])));
  [%expect
    {|
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-ghost loon-toggle-sm"
            @on_click> B </button>
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-ghost loon-toggle-md"
            @on_click> B </button>
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-ghost loon-toggle-lg"
            @on_click> B </button>
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-outline loon-toggle-sm"
            @on_click> B </button>
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-md loon-toggle-outline"
            @on_click> B </button>
    <button type="button"
            aria-pressed="false"
            data-state="off"
            class="loon-toggle loon-toggle-lg loon-toggle-outline"
            @on_click> B </button>
    |}]
;;

let%expect_test "clicking presses and releases it" =
  let handle =
    Control_render.handle
      [%sexp_of: bool]
      (Toggle.component
         ~attrs:[ Attr.create "aria-label" "Bold" ]
         [ Icon.view Pencil ])
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: false </span>
      <button aria-label="Bold"
              type="button"
              aria-pressed="false"
              data-state="off"
              class="loon-toggle loon-toggle-ghost loon-toggle-md"
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
             aria-hidden="true"
             class="lucide lucide-pencil">
          <path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"> </path>
          <path d="m15 5 4 4"> </path>
        </svg>
      </button>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"button";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: false </span>
    +|  <span> value: true </span>
        <button aria-label="Bold"
                type="button"
    -|          aria-pressed="false"
    +|          aria-pressed="true"
    -|          data-state="off"
    +|          data-state="on"
                class="loon-toggle loon-toggle-ghost loon-toggle-md"
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
               aria-hidden="true"
               class="lucide lucide-pencil">
            <path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"> </path>
            <path d="m15 5 4 4"> </path>
          </svg>
    |}]
;;

let items =
  [ Toggle_group.Item.text ~value:"left" "Left"
  ; Toggle_group.Item.text ~value:"center" "Center"
  ; Toggle_group.Item.text ~disabled:true ~value:"justify" "Justify"
  ; Toggle_group.Item.icon ~value:"right" ~label:"Right" Arrow_right
  ]
;;

let%expect_test "single: one at most, pressing again releases" =
  let handle =
    Control_render.handle
      [%sexp_of: string option]
      (Toggle_group.single_component ~variant:Outline ~default:"left" items)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: (left) </span>
      <div role="radiogroup" class="loon-toggle-group">
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-left"
                data-state="on"
                tabindex="0"
                role="radio"
                aria-checked="true"
                class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                @on_click
                @on_keydown> Left </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-center"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                @on_click
                @on_keydown> Center </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-justify"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                disabled=""
                class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"> Justify </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-right"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                aria-label="Right"
                class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                @on_click
                @on_keydown>
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
               class="lucide lucide-arrow-right">
            <path d="M5 12h14"> </path>
            <path d="m12 5 7 7-7 7"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=toggle-center]";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: (left) </span>
    +|  <span> value: (center) </span>
        <div role="radiogroup" class="loon-toggle-group">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-left"
    -|            data-state="on"
    +|            data-state="off"
    -|            tabindex="0"
    +|            tabindex="-1"
                  role="radio"
    -|            aria-checked="true"
    +|            aria-checked="false"
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                  @on_click
                  @on_keydown> Left </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-center"
    -|            data-state="off"
    +|            data-state="on"
    -|            tabindex="-1"
    +|            tabindex="0"
                  role="radio"
    -|            aria-checked="false"
    +|            aria-checked="true"
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                  @on_click
                  @on_keydown> Center </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-justify"
                  data-state="off"
                  tabindex="-1"
                  role="radio"
                  aria-checked="false"
                  disabled=""
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"> Justify </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-right"
                  data-state="off"
                  tabindex="-1"
                  role="radio"
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=toggle-center]";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: (center) </span>
    +|  <span> value: () </span>
        <div role="radiogroup" class="loon-toggle-group">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-left"
                  data-state="off"
    -|            tabindex="-1"
    +|            tabindex="0"
                  role="radio"
                  aria-checked="false"
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                  @on_click
                  @on_keydown> Left </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-center"
    -|            data-state="on"
    +|            data-state="off"
    -|            tabindex="0"
    +|            tabindex="-1"
                  role="radio"
    -|            aria-checked="true"
    +|            aria-checked="false"
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"
                  @on_click
                  @on_keydown> Center </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-justify"
                  data-state="off"
                  tabindex="-1"
                  role="radio"
                  aria-checked="false"
                  disabled=""
                  class="loon-toggle loon-toggle-group-item loon-toggle-md loon-toggle-outline"> Justify </button>
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-toggle-right"
                  data-state="off"
                  tabindex="-1"
                  role="radio"
    |}]
;;

let%expect_test "single and required: pressing the pressed one does nothing" =
  let handle =
    Control_render.handle
      [%sexp_of: string option]
      (Toggle_group.single_component ~required:true ~default:"left" items)
  in
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=toggle-left]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: (left) </span>
      <div role="radiogroup" class="loon-toggle-group">
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-left"
                data-state="on"
                tabindex="0"
                role="radio"
                aria-checked="true"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown> Left </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-center"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown> Center </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-justify"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                disabled=""
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"> Justify </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-right"
                data-state="off"
                tabindex="-1"
                role="radio"
                aria-checked="false"
                aria-label="Right"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown>
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
               class="lucide lucide-arrow-right">
            <path d="M5 12h14"> </path>
            <path d="m12 5 7 7-7 7"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}]
;;

let%expect_test "multiple: any number; arrow keys move focus only" =
  let handle =
    Control_render.handle
      [%sexp_of: String.Set.t]
      (Toggle_group.multiple_component items)
  in
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=toggle-left]";
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=toggle-right]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: (left right) </span>
      <div role="group" class="loon-toggle-group">
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-left"
                data-state="on"
                tabindex="0"
                aria-pressed="true"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown> Left </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-center"
                data-state="off"
                tabindex="-1"
                aria-pressed="false"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown> Center </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-justify"
                data-state="off"
                tabindex="-1"
                aria-pressed="false"
                disabled=""
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"> Justify </button>
        <button type="button"
                id="loonbonsai_path_replaced_in_test-toggle-right"
                data-state="on"
                tabindex="-1"
                aria-pressed="true"
                aria-label="Right"
                class="loon-toggle loon-toggle-ghost loon-toggle-group-item loon-toggle-md"
                @on_click
                @on_keydown>
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
               class="lucide lucide-arrow-right">
            <path d="M5 12h14"> </path>
            <path d="m12 5 7 7-7 7"> </path>
          </svg>
        </button>
      </div>
    </div>
    |}];
  Handle.keydown
    handle
    ~get_vdom:Fn.id
    ~selector:"[id$=toggle-left]"
    ~key:ArrowLeft;
  Handle.show_diff handle;
  [%expect {| ("default prevented" (key ArrowLeft)) |}]
;;
