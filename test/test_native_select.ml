open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let options =
  [ Native_select.option ~value:"" [ Node.text "Select status" ]
  ; Native_select.opt_group
      ~label:"Open"
      [ Native_select.option ~value:"todo" [ Node.text "Todo" ]
      ; Native_select.option ~value:"in-progress" [ Node.text "In Progress" ]
      ]
  ; Native_select.option ~value:"done" ~disabled:true [ Node.text "Done" ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Native_select.view
       [ Native_select.option ~value:"" [ Node.text "Select status" ]
       ; Native_select.opt_group
           ~label:"Open"
           [ Native_select.option ~value:"todo" [ Node.text "Todo" ] ]
       ]);
  [%expect
    {|
    <div data-slot="native-select-wrapper"
         data-size="default"
         class="cn-native-select-wrapper group/native-select has-[select:disabled]:opacity-50 relative w-fit">
      <select data-slot="native-select"
              data-size="default"
              class="cn-native-select disabled:cursor-not-allowed disabled:pointer-events-none outline-none">
        <option data-slot="native-select-option" class="bg-[Canvas] text-[CanvasText]" #value=""> Select status </option>
        <optgroup data-slot="native-select-optgroup"
                  label="Open"
                  class="bg-[Canvas] text-[CanvasText]">
          <option data-slot="native-select-option" class="bg-[Canvas] text-[CanvasText]" #value="todo"> Todo </option>
        </optgroup>
      </select>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           data-slot="native-select-icon"
           class="absolute cn-native-select-icon lucide lucide-chevron-down pointer-events-none select-none">
        <path d="m6 9 6 6 6-6"> </path>
      </svg>
    </div>
    |}]
;;

let%expect_test "sizes, disabled, invalid" =
  List.iter Native_select.Size.all ~f:(fun size ->
    Render.html ~classes:false (Native_select.view ~size []));
  Render.html
    ~classes:false
    (Native_select.view
       ~id:"s"
       ~name:"status"
       ~disabled:true
       ~required:true
       ~invalid:true
       []);
  [%expect
    {|
    <div data-slot="native-select-wrapper" data-size="default">
      <select data-slot="native-select" data-size="default"> </select>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           data-slot="native-select-icon">
        <path d="m6 9 6 6 6-6"> </path>
      </svg>
    </div>
    <div data-slot="native-select-wrapper" data-size="sm">
      <select data-slot="native-select" data-size="sm"> </select>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           data-slot="native-select-icon">
        <path d="m6 9 6 6 6-6"> </path>
      </svg>
    </div>
    <div data-slot="native-select-wrapper" data-size="default">
      <select data-slot="native-select"
              data-size="default"
              id="s"
              name="status"
              disabled=""
              required=""
              aria-invalid="true"> </select>
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           data-slot="native-select-icon">
        <path d="m6 9 6 6 6-6"> </path>
      </svg>
    </div>
    |}]
;;

let%expect_test "choosing an option sets the value" =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Native_select.component ~id:"status" ~default_value:"todo" options)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div data-slot="native-select-wrapper" data-size="default">
        <select data-slot="native-select"
                data-size="default"
                id="status"
                #value="todo"
                native-select-value=todo
                @on_change>
          <option data-slot="native-select-option" #value=""> Select status </option>
          <optgroup data-slot="native-select-optgroup" label="Open">
            <option data-slot="native-select-option" #value="todo"> Todo </option>
            <option data-slot="native-select-option" #value="in-progress"> In Progress </option>
          </optgroup>
          <option data-slot="native-select-option" disabled="" #value="done"> Done </option>
        </select>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             data-slot="native-select-icon">
          <path d="m6 9 6 6 6-6"> </path>
        </svg>
      </div>
      <output> todo </output>
    </div>
    |}];
  Handle.change handle ~get_vdom:Fn.id ~selector:"select" ~value:"in-progress";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div data-slot="native-select-wrapper" data-size="default">
          <select data-slot="native-select"
                  data-size="default"
                  id="status"
    -|            #value="todo"
    +|            #value="in-progress"
    -|            native-select-value=todo
    +|            native-select-value=in-progress
                  @on_change>
            <option data-slot="native-select-option" #value=""> Select status </option>
            <optgroup data-slot="native-select-optgroup" label="Open">
              <option data-slot="native-select-option" #value="todo"> Todo </option>
              <option data-slot="native-select-option" #value="in-progress"> In Progress </option>
            </optgroup>
            <option data-slot="native-select-option" disabled="" #value="done"> Done </option>
          </select>
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               data-slot="native-select-icon">
            <path d="m6 9 6 6 6-6"> </path>
          </svg>
        </div>
    -|  <output> todo </output>
    +|  <output> in-progress </output>
      </div>
    |}]
;;
