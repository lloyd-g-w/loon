open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let items =
  [ Accordion.Item.create ~id:"a" ~title:"Is it accessible?" (Node.text "Yes.")
  ; Accordion.Item.create ~id:"b" ~title:"Is it styled?" (Node.text "Yes.")
  ; Accordion.Item.create
      ~disabled:true
      ~id:"c"
      ~title:"Is it animated?"
      (Node.text "Yes.")
  ]
;;

let%expect_test "toggled" =
  let single = Accordion.Kind.Single { collapsible = true } in
  let fixed = Accordion.Kind.Single { collapsible = false } in
  print_s
    [%message
      ""
        ~open_single:(Accordion.toggled single ~open_:[] "a" : string list)
        ~switch_single:
          (Accordion.toggled single ~open_:[ "a" ] "b" : string list)
        ~close_single:
          (Accordion.toggled single ~open_:[ "a" ] "a" : string list)
        ~close_fixed:(Accordion.toggled fixed ~open_:[ "a" ] "a" : string list)
        ~add_multiple:
          (Accordion.toggled Multiple ~open_:[ "a" ] "b" : string list)
        ~remove_multiple:
          (Accordion.toggled Multiple ~open_:[ "a"; "b" ] "a" : string list)];
  [%expect
    {|
    ((open_single (a)) (switch_single (b)) (close_single ()) (close_fixed (a))
     (add_multiple (a b)) (remove_multiple (b)))
    |}]
;;

let%expect_test "opening and closing" =
  let handle =
    Render.handle (Accordion.component (Bonsai_web.Bonsai.return items))
  in
  Handle.show handle;
  [%expect
    {|
    <div class="loon-accordion">
      <div @key=a data-state="closed" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-a"
                  aria-expanded="false"
                  aria-controls="loonbonsai_path_replaced_in_test-content-a"
                  data-state="closed"
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it accessible? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-a"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-a"
             data-state="closed"
             inert=""
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
      <div @key=b data-state="closed" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-b"
                  aria-expanded="false"
                  aria-controls="loonbonsai_path_replaced_in_test-content-b"
                  data-state="closed"
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it styled? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-b"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-b"
             data-state="closed"
             inert=""
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
      <div @key=c data-state="closed" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-c"
                  aria-expanded="false"
                  aria-controls="loonbonsai_path_replaced_in_test-content-c"
                  data-state="closed"
                  disabled=""
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it animated? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-c"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-c"
             data-state="closed"
             inert=""
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=trigger-a]";
  Handle.show_diff handle;
  [%expect
    {|
      <div class="loon-accordion">
    -|  <div @key=a data-state="closed" class="loon-accordion-item">
    +|  <div @key=a data-state="open" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-a"
    -|              aria-expanded="false"
    +|              aria-expanded="true"
                    aria-controls="loonbonsai_path_replaced_in_test-content-a"
    -|              data-state="closed"
    +|              data-state="open"
                    class="loon-accordion-trigger"
                    @on_click
                    @on_keydown>
              <span class="loon-accordion-title"> Is it accessible? </span>
              <svg viewBox="0 0 24 24"
                   aria-hidden="true"
                   class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
          <div id="loonbonsai_path_replaced_in_test-content-a"
               role="region"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger-a"
    -|         data-state="closed"
    -|         inert=""
    +|         data-state="open"
               class="loon-accordion-content">
            <div class="loon-accordion-inner">
              <div class="loon-accordion-body"> Yes. </div>
            </div>
          </div>
        </div>
        <div @key=b data-state="closed" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-b"
                    aria-expanded="false"
                    aria-controls="loonbonsai_path_replaced_in_test-content-b"
                    data-state="closed"
                    class="loon-accordion-trigger"
                    @on_click
                    @on_keydown>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=trigger-b]";
  Handle.show_diff handle;
  [%expect
    {|
      <div class="loon-accordion">
    -|  <div @key=a data-state="open" class="loon-accordion-item">
    +|  <div @key=a data-state="closed" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-a"
    -|              aria-expanded="true"
    +|              aria-expanded="false"
                    aria-controls="loonbonsai_path_replaced_in_test-content-a"
    -|              data-state="open"
    +|              data-state="closed"
                    class="loon-accordion-trigger"
                    @on_click
                    @on_keydown>
              <span class="loon-accordion-title"> Is it accessible? </span>
              <svg viewBox="0 0 24 24"
                   aria-hidden="true"
                   class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
          <div id="loonbonsai_path_replaced_in_test-content-a"
               role="region"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger-a"
    -|         data-state="open"
    +|         data-state="closed"
    +|         inert=""
               class="loon-accordion-content">
            <div class="loon-accordion-inner">
              <div class="loon-accordion-body"> Yes. </div>
            </div>
          </div>
        </div>
    -|  <div @key=b data-state="closed" class="loon-accordion-item">
    +|  <div @key=b data-state="open" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-b"
    -|              aria-expanded="false"
    +|              aria-expanded="true"
                    aria-controls="loonbonsai_path_replaced_in_test-content-b"
    -|              data-state="closed"
    +|              data-state="open"
                    class="loon-accordion-trigger"
                    @on_click
                    @on_keydown>
              <span class="loon-accordion-title"> Is it styled? </span>
              <svg viewBox="0 0 24 24"
                   aria-hidden="true"
                   class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
          <div id="loonbonsai_path_replaced_in_test-content-b"
               role="region"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger-b"
    -|         data-state="closed"
    -|         inert=""
    +|         data-state="open"
               class="loon-accordion-content">
            <div class="loon-accordion-inner">
              <div class="loon-accordion-body"> Yes. </div>
            </div>
          </div>
        </div>
        <div @key=c data-state="closed" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-c"
                    aria-expanded="false"
                    aria-controls="loonbonsai_path_replaced_in_test-content-c"
                    data-state="closed"
                    disabled=""
                    class="loon-accordion-trigger"
                    @on_click
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=trigger-b]";
  Handle.show_diff handle;
  [%expect
    {|
                   class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
          <div id="loonbonsai_path_replaced_in_test-content-a"
               role="region"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger-a"
               data-state="closed"
               inert=""
               class="loon-accordion-content">
            <div class="loon-accordion-inner">
              <div class="loon-accordion-body"> Yes. </div>
            </div>
          </div>
        </div>
    -|  <div @key=b data-state="open" class="loon-accordion-item">
    +|  <div @key=b data-state="closed" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-b"
    -|              aria-expanded="true"
    +|              aria-expanded="false"
                    aria-controls="loonbonsai_path_replaced_in_test-content-b"
    -|              data-state="open"
    +|              data-state="closed"
                    class="loon-accordion-trigger"
                    @on_click
                    @on_keydown>
              <span class="loon-accordion-title"> Is it styled? </span>
              <svg viewBox="0 0 24 24"
                   aria-hidden="true"
                   class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
          <div id="loonbonsai_path_replaced_in_test-content-b"
               role="region"
               aria-labelledby="loonbonsai_path_replaced_in_test-trigger-b"
    -|         data-state="open"
    +|         data-state="closed"
    +|         inert=""
               class="loon-accordion-content">
            <div class="loon-accordion-inner">
              <div class="loon-accordion-body"> Yes. </div>
            </div>
          </div>
        </div>
        <div @key=c data-state="closed" class="loon-accordion-item">
          <h3 class="loon-accordion-heading">
            <button type="button"
                    id="loonbonsai_path_replaced_in_test-trigger-c"
                    aria-expanded="false"
                    aria-controls="loonbonsai_path_replaced_in_test-content-c"
                    data-state="closed"
                    disabled=""
                    class="loon-accordion-trigger"
                    @on_click
    |}]
;;

let%expect_test "multiple" =
  let handle =
    Render.handle
      (Accordion.component ~kind:Multiple (Bonsai_web.Bonsai.return items))
  in
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=trigger-a]";
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[id$=trigger-b]";
  Handle.show handle;
  [%expect
    {|
    <div class="loon-accordion">
      <div @key=a data-state="open" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-a"
                  aria-expanded="true"
                  aria-controls="loonbonsai_path_replaced_in_test-content-a"
                  data-state="open"
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it accessible? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-a"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-a"
             data-state="open"
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
      <div @key=b data-state="open" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-b"
                  aria-expanded="true"
                  aria-controls="loonbonsai_path_replaced_in_test-content-b"
                  data-state="open"
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it styled? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-b"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-b"
             data-state="open"
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
      <div @key=c data-state="closed" class="loon-accordion-item">
        <h3 class="loon-accordion-heading">
          <button type="button"
                  id="loonbonsai_path_replaced_in_test-trigger-c"
                  aria-expanded="false"
                  aria-controls="loonbonsai_path_replaced_in_test-content-c"
                  data-state="closed"
                  disabled=""
                  class="loon-accordion-trigger"
                  @on_click
                  @on_keydown>
            <span class="loon-accordion-title"> Is it animated? </span>
            <svg viewBox="0 0 24 24"
                 aria-hidden="true"
                 class="loon-accordion-chevron loon-icon loon-icon-chevron-down">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div id="loonbonsai_path_replaced_in_test-content-c"
             role="region"
             aria-labelledby="loonbonsai_path_replaced_in_test-trigger-c"
             data-state="closed"
             inert=""
             class="loon-accordion-content">
          <div class="loon-accordion-inner">
            <div class="loon-accordion-body"> Yes. </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  (* Arrow keys only move the focus. *)
  Handle.keydown
    handle
    ~get_vdom:Fn.id
    ~selector:"[id$=trigger-a]"
    ~key:ArrowDown;
  Handle.show_diff handle;
  [%expect {| ("default prevented" (key ArrowDown)) |}]
;;

let%expect_test "collapsible" =
  let handle =
    Render.handle
      (Collapsible.component
         ~trigger:(Bonsai_web.Bonsai.return [ Node.text "3 more" ])
         (Bonsai_web.Bonsai.return [ Node.text "hidden things" ]))
  in
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" class="loon-collapsible">
      <button type="button"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              class="loon-collapsible-trigger"
              @on_click>
        3 more
        <svg viewBox="0 0 24 24"
             aria-hidden="true"
             class="loon-collapsible-chevron loon-icon loon-icon-chevron-down">
          <path d="m6 9 6 6 6-6"> </path>
        </svg>
      </button>
      <div id="loonbonsai_path_replaced_in_test-content"
           data-state="closed"
           inert=""
           class="loon-collapsible-content">
        <div class="loon-collapsible-inner"> hidden things </div>
      </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:".loon-collapsible-trigger";
  Handle.show_diff handle;
  [%expect
    {|
    -|<div data-state="closed" class="loon-collapsible">
    +|<div data-state="open" class="loon-collapsible">
        <button type="button"
                id="loonbonsai_path_replaced_in_test-trigger"
    -|          aria-expanded="false"
    +|          aria-expanded="true"
                aria-controls="loonbonsai_path_replaced_in_test-content"
    -|          data-state="closed"
    +|          data-state="open"
                class="loon-collapsible-trigger"
                @on_click>
          3 more
          <svg viewBox="0 0 24 24"
               aria-hidden="true"
               class="loon-collapsible-chevron loon-icon loon-icon-chevron-down">
            <path d="m6 9 6 6 6-6"> </path>
          </svg>
        </button>
        <div id="loonbonsai_path_replaced_in_test-content"
    -|       data-state="closed"
    -|       inert=""
    +|       data-state="open"
             class="loon-collapsible-content">
          <div class="loon-collapsible-inner"> hidden things </div>
        </div>
      </div>
    |}]
;;
