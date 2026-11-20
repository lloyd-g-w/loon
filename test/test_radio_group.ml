open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let items =
  [ Radio_group.Item.create ~value:"default" "Default"
  ; Radio_group.Item.create
      ~value:"comfortable"
      ~description:"More room between rows."
      "Comfortable"
  ; Radio_group.Item.create ~disabled:true ~value:"compact" "Compact"
  ; Radio_group.Item.create ~value:"spacious" "Spacious"
  ]
;;

let%expect_test "nothing chosen: the first item is the tab stop" =
  let handle =
    Control_render.handle
      [%sexp_of: string option]
      (Radio_group.component items)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: () </span>
      <div role="radiogroup"
           aria-orientation="vertical"
           class="loon-radio-group loon-radio-group-vertical">
        <label data-disabled="false" class="loon-radio-item">
          <button type="button"
                  role="radio"
                  id="loonbonsai_path_replaced_in_test-radio-default"
                  aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
                  aria-checked="false"
                  data-state="unchecked"
                  tabindex="0"
                  class="loon-radio"
                  @on_click
                  @on_keydown>
            <span class="loon-radio-dot"> </span>
          </button>
          <span class="loon-radio-text">
            <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
          </span>
        </label>
        <label data-disabled="false" class="loon-radio-item">
          <button type="button"
                  role="radio"
                  id="loonbonsai_path_replaced_in_test-radio-comfortable"
                  aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                  aria-checked="false"
                  data-state="unchecked"
                  tabindex="-1"
                  aria-describedby="loonbonsai_path_replaced_in_test-radio-comfortable-description"
                  class="loon-radio"
                  @on_click
                  @on_keydown>
            <span class="loon-radio-dot"> </span>
          </button>
          <span class="loon-radio-text">
            <span id="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                  class="loon-radio-label"> Comfortable </span>
            <span id="loonbonsai_path_replaced_in_test-radio-comfortable-description"
                  class="loon-radio-description"> More room between rows. </span>
          </span>
        </label>
        <label data-disabled="true" class="loon-radio-item">
          <button type="button"
                  role="radio"
                  id="loonbonsai_path_replaced_in_test-radio-compact"
                  aria-labelledby="loonbonsai_path_replaced_in_test-radio-compact-label"
                  aria-checked="false"
                  data-state="unchecked"
                  tabindex="-1"
                  disabled=""
                  class="loon-radio">
            <span class="loon-radio-dot"> </span>
          </button>
          <span class="loon-radio-text">
            <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
          </span>
        </label>
        <label data-disabled="false" class="loon-radio-item">
          <button type="button"
                  role="radio"
                  id="loonbonsai_path_replaced_in_test-radio-spacious"
                  aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
                  aria-checked="false"
                  data-state="unchecked"
                  tabindex="-1"
                  class="loon-radio"
                  @on_click
                  @on_keydown>
            <span class="loon-radio-dot"> </span>
          </button>
          <span class="loon-radio-text">
            <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
          </span>
        </label>
      </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=radio-comfortable]";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: () </span>
    +|  <span> value: (comfortable) </span>
        <div role="radiogroup"
             aria-orientation="vertical"
             class="loon-radio-group loon-radio-group-vertical">
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-default"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
                    aria-checked="false"
                    data-state="unchecked"
    -|              tabindex="0"
    +|              tabindex="-1"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-comfortable"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
    -|              aria-checked="false"
    +|              aria-checked="true"
    -|              data-state="unchecked"
    +|              data-state="checked"
    -|              tabindex="-1"
    +|              tabindex="0"
                    aria-describedby="loonbonsai_path_replaced_in_test-radio-comfortable-description"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                    class="loon-radio-label"> Comfortable </span>
              <span id="loonbonsai_path_replaced_in_test-radio-comfortable-description"
                    class="loon-radio-description"> More room between rows. </span>
            </span>
          </label>
          <label data-disabled="true" class="loon-radio-item">
            <button type="button"
                    role="radio"
    |}]
;;

let%expect_test "arrow keys choose the next enabled item, wrapping" =
  let handle =
    Control_render.handle
      [%sexp_of: string option]
      (Radio_group.component
         ~orientation:Horizontal
         ~default:"comfortable"
         items)
  in
  let key selector key =
    Handle.keydown handle ~get_vdom:Fn.id ~selector ~key;
    Handle.show_diff handle
  in
  key "[id$=radio-comfortable]" ArrowDown;
  [%expect
    {|
    ("default prevented" (key ArrowDown))

    +|<div>
    +|  <span> value: (spacious) </span>
    +|  <div role="radiogroup"
    +|       aria-orientation="horizontal"
    +|       class="loon-radio-group loon-radio-group-horizontal">
    +|    <label data-disabled="false" class="loon-radio-item">
    +|      <button type="button"
    +|              role="radio"
    +|              id="loonbonsai_path_replaced_in_test-radio-default"
    +|              aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
    +|              aria-checked="false"
    +|              data-state="unchecked"
    +|              tabindex="-1"
    +|              class="loon-radio"
    +|              @on_click
    +|              @on_keydown>
    +|        <span class="loon-radio-dot"> </span>
    +|      </button>
    +|      <span class="loon-radio-text">
    +|        <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
    +|      </span>
    +|    </label>
    +|    <label data-disabled="false" class="loon-radio-item">
    +|      <button type="button"
    +|              role="radio"
    +|              id="loonbonsai_path_replaced_in_test-radio-comfortable"
    +|              aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
    +|              aria-checked="false"
    +|              data-state="unchecked"
    +|              tabindex="-1"
    +|              aria-describedby="loonbonsai_path_replaced_in_test-radio-comfortable-description"
    +|              class="loon-radio"
    +|              @on_click
    +|              @on_keydown>
    +|        <span class="loon-radio-dot"> </span>
    +|      </button>
    +|      <span class="loon-radio-text">
    +|        <span id="loonbonsai_path_replaced_in_test-radio-comfortable-label"
    +|              class="loon-radio-label"> Comfortable </span>
    +|        <span id="loonbonsai_path_replaced_in_test-radio-comfortable-description"
    +|              class="loon-radio-description"> More room between rows. </span>
    +|      </span>
    +|    </label>
    +|    <label data-disabled="true" class="loon-radio-item">
    +|      <button type="button"
    +|              role="radio"
    +|              id="loonbonsai_path_replaced_in_test-radio-compact"
    +|              aria-labelledby="loonbonsai_path_replaced_in_test-radio-compact-label"
    +|              aria-checked="false"
    +|              data-state="unchecked"
    +|              tabindex="-1"
    +|              disabled=""
    +|              class="loon-radio">
    +|        <span class="loon-radio-dot"> </span>
    +|      </button>
    +|      <span class="loon-radio-text">
    +|        <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
    +|      </span>
    +|    </label>
    +|    <label data-disabled="false" class="loon-radio-item">
    +|      <button type="button"
    +|              role="radio"
    +|              id="loonbonsai_path_replaced_in_test-radio-spacious"
    +|              aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
    +|              aria-checked="true"
    +|              data-state="checked"
    +|              tabindex="0"
    +|              class="loon-radio"
    +|              @on_click
    +|              @on_keydown>
    +|        <span class="loon-radio-dot"> </span>
    +|      </button>
    +|      <span class="loon-radio-text">
    +|        <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
    +|      </span>
    +|    </label>
    +|  </div>
    +|</div>
    |}];
  key "[id$=radio-spacious]" ArrowRight;
  [%expect
    {|
    ("default prevented" (key ArrowRight))

      <div>
    -|  <span> value: (spacious) </span>
    +|  <span> value: (default) </span>
        <div role="radiogroup"
             aria-orientation="horizontal"
             class="loon-radio-group loon-radio-group-horizontal">
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-default"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
    -|              aria-checked="false"
    +|              aria-checked="true"
    -|              data-state="unchecked"
    +|              data-state="checked"
    -|              tabindex="-1"
    +|              tabindex="0"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-comfortable"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                    aria-checked="false"
                    data-state="unchecked"

                    aria-checked="false"
                    data-state="unchecked"
                    tabindex="-1"
                    disabled=""
                    class="loon-radio">
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-spacious"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
    -|              aria-checked="true"
    +|              aria-checked="false"
    -|              data-state="checked"
    +|              data-state="unchecked"
    -|              tabindex="0"
    +|              tabindex="-1"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
            </span>
          </label>
        </div>
      </div>
    |}];
  key "[id$=radio-default]" End;
  [%expect
    {|
    ("default prevented" (key End))

      <div>
    -|  <span> value: (default) </span>
    +|  <span> value: (spacious) </span>
        <div role="radiogroup"
             aria-orientation="horizontal"
             class="loon-radio-group loon-radio-group-horizontal">
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-default"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
    -|              aria-checked="true"
    +|              aria-checked="false"
    -|              data-state="checked"
    +|              data-state="unchecked"
    -|              tabindex="0"
    +|              tabindex="-1"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-comfortable"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                    aria-checked="false"
                    data-state="unchecked"

                    aria-checked="false"
                    data-state="unchecked"
                    tabindex="-1"
                    disabled=""
                    class="loon-radio">
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-spacious"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
    -|              aria-checked="false"
    +|              aria-checked="true"
    -|              data-state="unchecked"
    +|              data-state="checked"
    -|              tabindex="-1"
    +|              tabindex="0"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
            </span>
          </label>
        </div>
      </div>
    |}];
  key "[id$=radio-spacious]" Home;
  [%expect
    {|
    ("default prevented" (key Home))

      <div>
    -|  <span> value: (spacious) </span>
    +|  <span> value: (default) </span>
        <div role="radiogroup"
             aria-orientation="horizontal"
             class="loon-radio-group loon-radio-group-horizontal">
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-default"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
    -|              aria-checked="false"
    +|              aria-checked="true"
    -|              data-state="unchecked"
    +|              data-state="checked"
    -|              tabindex="-1"
    +|              tabindex="0"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-comfortable"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                    aria-checked="false"
                    data-state="unchecked"

                    aria-checked="false"
                    data-state="unchecked"
                    tabindex="-1"
                    disabled=""
                    class="loon-radio">
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-spacious"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
    -|              aria-checked="true"
    +|              aria-checked="false"
    -|              data-state="checked"
    +|              data-state="unchecked"
    -|              tabindex="0"
    +|              tabindex="-1"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
            </span>
          </label>
        </div>
      </div>
    |}];
  key "[id$=radio-default]" ArrowUp;
  [%expect
    {|
    ("default prevented" (key ArrowUp))

      <div>
    -|  <span> value: (default) </span>
    +|  <span> value: (spacious) </span>
        <div role="radiogroup"
             aria-orientation="horizontal"
             class="loon-radio-group loon-radio-group-horizontal">
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-default"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-default-label"
    -|              aria-checked="true"
    +|              aria-checked="false"
    -|              data-state="checked"
    +|              data-state="unchecked"
    -|              tabindex="0"
    +|              tabindex="-1"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-default-label" class="loon-radio-label"> Default </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-comfortable"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-comfortable-label"
                    aria-checked="false"
                    data-state="unchecked"

                    aria-checked="false"
                    data-state="unchecked"
                    tabindex="-1"
                    disabled=""
                    class="loon-radio">
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-compact-label" class="loon-radio-label"> Compact </span>
            </span>
          </label>
          <label data-disabled="false" class="loon-radio-item">
            <button type="button"
                    role="radio"
                    id="loonbonsai_path_replaced_in_test-radio-spacious"
                    aria-labelledby="loonbonsai_path_replaced_in_test-radio-spacious-label"
    -|              aria-checked="false"
    +|              aria-checked="true"
    -|              data-state="unchecked"
    +|              data-state="checked"
    -|              tabindex="-1"
    +|              tabindex="0"
                    class="loon-radio"
                    @on_click
                    @on_keydown>
              <span class="loon-radio-dot"> </span>
            </button>
            <span class="loon-radio-text">
              <span id="loonbonsai_path_replaced_in_test-radio-spacious-label" class="loon-radio-label"> Spacious </span>
            </span>
          </label>
        </div>
      </div>
    |}]
;;

let%expect_test "roving focus skips disabled items" =
  let enabled = [ true; false; true; false ] in
  List.iter
    [ 0, "ArrowRight", Js_of_ocaml.Dom_html.Keyboard_code.ArrowRight
    ; 2, "ArrowRight", ArrowRight
    ; 0, "ArrowLeft", ArrowLeft
    ; 2, "Home", Home
    ; 0, "End", End
    ; 0, "KeyA", KeyA
    ]
    ~f:(fun (current, name, key) ->
      print_s
        [%message
          (current : int)
            ~key:name
            ~moves_to:(Roving.move ~enabled ~current key : int option)]);
  print_s
    [%message (Roving.move ~enabled:[] ~current:0 ArrowRight : int option)];
  print_s
    [%message
      (Roving.move ~enabled:[ false; false ] ~current:0 ArrowRight : int option)];
  [%expect
    {|
    ((current 0) (key ArrowRight) (moves_to (2)))
    ((current 2) (key ArrowRight) (moves_to (0)))
    ((current 0) (key ArrowLeft) (moves_to (2)))
    ((current 2) (key Home) (moves_to (0)))
    ((current 0) (key End) (moves_to (2)))
    ((current 0) (key KeyA) (moves_to ()))
    ("Roving.move ~enabled:[] ~current:0 ArrowRight" ())
    ("Roving.move ~enabled:[false; false] ~current:0 ArrowRight" ())
    |}]
;;
