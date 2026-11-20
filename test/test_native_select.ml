open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let items =
  [ Native_select.Item.create ~value:"au" "Australia"
  ; Native_select.Item.create ~value:"nz" "New Zealand"
  ; Native_select.Item.create ~disabled:true ~value:"aq" "Antarctica"
  ]
;;

let%expect_test "a placeholder until something is chosen" =
  let handle =
    Control_render.handle
      [%sexp_of: string]
      (Native_select.component ~placeholder:"Choose a country" items)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: "" </span>
      <div data-disabled="false" class="loon-native-select">
        <select data-placeholder="true" class="loon-native-select-control" #value="" @on_change>
          <option selected="" disabled="" #value=""> Choose a country </option>
          <option #value="au"> Australia </option>
          <option #value="nz"> New Zealand </option>
          <option disabled="" #value="aq"> Antarctica </option>
        </select>
        <svg viewBox="0 0 24 24"
             aria-hidden="true"
             class="loon-icon loon-icon-chevrons-up-down loon-native-select-chevron">
          <path d="m7 15 5 5 5-5M7 9l5-5 5 5"> </path>
        </svg>
      </div>
    </div>
    |}];
  Handle.change handle ~get_vdom:Fn.id ~selector:"select" ~value:"nz";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: "" </span>
    +|  <span> value: nz </span>
        <div data-disabled="false" class="loon-native-select">
    -|    <select data-placeholder="true" class="loon-native-select-control" #value="" @on_change>
    +|    <select data-placeholder="false" class="loon-native-select-control" #value="nz" @on_change>
    -|      <option selected="" disabled="" #value=""> Choose a country </option>
    +|      <option disabled="" #value=""> Choose a country </option>
            <option #value="au"> Australia </option>
    -|      <option #value="nz"> New Zealand </option>
    +|      <option selected="" #value="nz"> New Zealand </option>
            <option disabled="" #value="aq"> Antarctica </option>
          </select>
          <svg viewBox="0 0 24 24"
               aria-hidden="true"
               class="loon-icon loon-icon-chevrons-up-down loon-native-select-chevron">
            <path d="m7 15 5 5 5-5M7 9l5-5 5 5"> </path>
          </svg>
        </div>
      </div>
    |}]
;;
