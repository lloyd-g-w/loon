open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let tabs =
  [ Tabs.Tab.create ~id:"account" ~label:"Account" (Node.text "Your account")
  ; Tabs.Tab.create ~id:"password" ~label:"Password" (Node.text "Change it")
  ; Tabs.Tab.create ~disabled:true ~id:"billing" ~label:"Billing" (Node.text "Pay")
  ]
;;

let%expect_test "clicking and arrow keys switch tabs" =
  let handle = Render.handle (Tabs.component (Bonsai_web.Bonsai.return tabs)) in
  Handle.show handle;
  [%expect {|
    <div class="loon-tabs loon-tabs-segmented">
      <div role="tablist" class="loon-tabs-list" @on_keydown>
        <button type="button"
                role="tab"
                id="loonbonsai_path_replaced_in_test-tab-account"
                aria-selected="true"
                aria-controls="loonbonsai_path_replaced_in_test-panel-account"
                data-state="active"
                tabindex="0"
                class="loon-tabs-trigger"
                @on_click> Account </button>
        <button type="button"
                role="tab"
                id="loonbonsai_path_replaced_in_test-tab-password"
                aria-selected="false"
                aria-controls="loonbonsai_path_replaced_in_test-panel-password"
                data-state="inactive"
                tabindex="-1"
                class="loon-tabs-trigger"
                @on_click> Password </button>
        <button type="button"
                role="tab"
                id="loonbonsai_path_replaced_in_test-tab-billing"
                aria-selected="false"
                aria-controls="loonbonsai_path_replaced_in_test-panel-billing"
                data-state="inactive"
                tabindex="-1"
                disabled=""
                class="loon-tabs-trigger"
                @on_click> Billing </button>
      </div>
      <div @key=account
           role="tabpanel"
           id="loonbonsai_path_replaced_in_test-panel-account"
           aria-labelledby="loonbonsai_path_replaced_in_test-tab-account"
           tabindex="0"
           class="loon-tabs-panel"> Your account </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[aria-controls$=panel-password]";
  Handle.show_diff handle;
  [%expect {|
      <div class="loon-tabs loon-tabs-segmented">
        <div role="tablist" class="loon-tabs-list" @on_keydown>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-account"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-account"
    -|            data-state="active"
    +|            data-state="inactive"
    -|            tabindex="0"
    +|            tabindex="-1"
                  class="loon-tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-password"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-password"
    -|            data-state="inactive"
    +|            data-state="active"
    -|            tabindex="-1"
    +|            tabindex="0"
                  class="loon-tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-billing"
                  aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-billing"
                  data-state="inactive"
                  tabindex="-1"
                  disabled=""
                  class="loon-tabs-trigger"
                  @on_click> Billing </button>
        </div>
    -|  <div @key=account
    +|  <div @key=password
             role="tabpanel"
    -|       id="loonbonsai_path_replaced_in_test-panel-account"
    +|       id="loonbonsai_path_replaced_in_test-panel-password"
    -|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-account"
    +|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-password"
             tabindex="0"
    -|       class="loon-tabs-panel"> Your account </div>
    +|       class="loon-tabs-panel"> Change it </div>
      </div>
    |}];
  Handle.keydown handle ~get_vdom:Fn.id ~selector:".loon-tabs-list" ~key:ArrowRight;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key ArrowRight))

      <div class="loon-tabs loon-tabs-segmented">
        <div role="tablist" class="loon-tabs-list" @on_keydown>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-account"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-account"
    -|            data-state="inactive"
    +|            data-state="active"
    -|            tabindex="-1"
    +|            tabindex="0"
                  class="loon-tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-password"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-password"
    -|            data-state="active"
    +|            data-state="inactive"
    -|            tabindex="0"
    +|            tabindex="-1"
                  class="loon-tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-billing"
                  aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-billing"
                  data-state="inactive"
                  tabindex="-1"
                  disabled=""
                  class="loon-tabs-trigger"
                  @on_click> Billing </button>
        </div>
    -|  <div @key=password
    +|  <div @key=account
             role="tabpanel"
    -|       id="loonbonsai_path_replaced_in_test-panel-password"
    +|       id="loonbonsai_path_replaced_in_test-panel-account"
    -|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-password"
    +|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-account"
             tabindex="0"
    -|       class="loon-tabs-panel"> Change it </div>
    +|       class="loon-tabs-panel"> Your account </div>
      </div>
    |}];
  Handle.keydown handle ~get_vdom:Fn.id ~selector:".loon-tabs-list" ~key:End;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key End))

      <div class="loon-tabs loon-tabs-segmented">
        <div role="tablist" class="loon-tabs-list" @on_keydown>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-account"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-account"
    -|            data-state="active"
    +|            data-state="inactive"
    -|            tabindex="0"
    +|            tabindex="-1"
                  class="loon-tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-password"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-password"
    -|            data-state="inactive"
    +|            data-state="active"
    -|            tabindex="-1"
    +|            tabindex="0"
                  class="loon-tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  id="loonbonsai_path_replaced_in_test-tab-billing"
                  aria-selected="false"
                  aria-controls="loonbonsai_path_replaced_in_test-panel-billing"
                  data-state="inactive"
                  tabindex="-1"
                  disabled=""
                  class="loon-tabs-trigger"
                  @on_click> Billing </button>
        </div>
    -|  <div @key=account
    +|  <div @key=password
             role="tabpanel"
    -|       id="loonbonsai_path_replaced_in_test-panel-account"
    +|       id="loonbonsai_path_replaced_in_test-panel-password"
    -|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-account"
    +|       aria-labelledby="loonbonsai_path_replaced_in_test-tab-password"
             tabindex="0"
    -|       class="loon-tabs-panel"> Your account </div>
    +|       class="loon-tabs-panel"> Change it </div>
      </div>
    |}]
;;
