open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts tabs =
  [ Tabs.list
      tabs
      [ Tabs.trigger ~value:"account" [ Node.text "Account" ]
      ; Tabs.trigger ~value:"password" [ Node.text "Password" ]
      ; Tabs.trigger ~disabled:true ~value:"billing" [ Node.text "Billing" ]
      ]
  ; Tabs.content tabs ~value:"account" [ Node.text "Your account" ]
  ; Tabs.content tabs ~value:"password" [ Node.text "Change it" ]
  ; Tabs.content tabs ~value:"billing" [ Node.text "Pay" ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Tabs.view ~value:"account" ~on_change:(fun _ -> Bonsai_web.Effect.Ignore) (fun tabs ->
       [ Tabs.list tabs [ Tabs.trigger ~value:"account" [ Node.text "Account" ] ]
       ; Tabs.content tabs ~value:"account" [ Node.text "Your account" ]
       ]));
  [%expect {|
    <div data-slot="tabs"
         dir="ltr"
         data-orientation="horizontal"
         class="data-[orientation=horizontal]:flex-col flex gap-2 group/tabs">
      <div role="tablist"
           aria-orientation="horizontal"
           data-slot="tabs-list"
           data-variant="default"
           class="bg-muted data-[variant=line]:rounded-none group-data-[orientation=horizontal]/tabs:h-9 group-data-[orientation=vertical]/tabs:flex-col group-data-[orientation=vertical]/tabs:h-fit group/tabs-list inline-flex items-center justify-center p-[3px] rounded-lg text-muted-foreground w-fit"
           @on_keydown>
        <button type="button"
                role="tab"
                aria-selected="true"
                aria-controls="tabs-content-account"
                data-state="active"
                id="tabs-trigger-account"
                data-orientation="horizontal"
                tabindex="0"
                data-slot="tabs-trigger"
                class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 after:absolute after:bg-foreground after:opacity-0 after:transition-opacity border border-transparent dark:data-[state=active]:bg-input/30 dark:data-[state=active]:border-input dark:data-[state=active]:text-foreground dark:group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent dark:group-data-[variant=line]/tabs-list:data-[state=active]:border-transparent dark:hover:text-foreground dark:text-muted-foreground data-[state=active]:bg-background data-[state=active]:text-foreground disabled:opacity-50 disabled:pointer-events-none flex-1 focus-visible:border-ring focus-visible:outline-1 focus-visible:outline-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1.5 group-data-[orientation=horizontal]/tabs:after:bottom-[-5px] group-data-[orientation=horizontal]/tabs:after:h-0.5 group-data-[orientation=horizontal]/tabs:after:inset-x-0 group-data-[orientation=vertical]/tabs:after:-right-1 group-data-[orientation=vertical]/tabs:after:inset-y-0 group-data-[orientation=vertical]/tabs:after:w-0.5 group-data-[orientation=vertical]/tabs:justify-start group-data-[orientation=vertical]/tabs:w-full group-data-[variant=default]/tabs-list:data-[state=active]:shadow-sm group-data-[variant=line]/tabs-list:bg-transparent group-data-[variant=line]/tabs-list:data-[state=active]:after:opacity-100 group-data-[variant=line]/tabs-list:data-[state=active]:bg-transparent group-data-[variant=line]/tabs-list:data-[state=active]:shadow-none h-[calc(100%-1px)] hover:text-foreground inline-flex items-center justify-center px-2 py-1 relative rounded-md text-foreground/60 text-sm transition-all whitespace-nowrap"
                @on_click> Account </button>
      </div>
      <div data-state="active"
           data-orientation="horizontal"
           role="tabpanel"
           aria-labelledby="tabs-trigger-account"
           id="tabs-content-account"
           tabindex="0"
           data-slot="tabs-content"
           class="flex-1 outline-none"> Your account </div>
    </div>
    |}]
;;

let%expect_test "clicking and arrow keys switch tabs, skipping disabled ones" =
  let handle =
    Render.handle
      ~classes:false
      (Tabs.component ~default_value:"account" (Bonsai_web.Bonsai.return parts))
  in
  Handle.show handle;
  [%expect {|
    <div data-slot="tabs" dir="ltr" data-orientation="horizontal">
      <div role="tablist"
           aria-orientation="horizontal"
           data-slot="tabs-list"
           data-variant="default"
           @on_keydown>
        <button type="button"
                role="tab"
                aria-selected="true"
                aria-controls="bonsai_path_replaced_in_test-content-account"
                data-state="active"
                id="bonsai_path_replaced_in_test-trigger-account"
                data-orientation="horizontal"
                tabindex="0"
                data-slot="tabs-trigger"
                @on_click> Account </button>
        <button type="button"
                role="tab"
                aria-selected="false"
                aria-controls="bonsai_path_replaced_in_test-content-password"
                data-state="inactive"
                id="bonsai_path_replaced_in_test-trigger-password"
                data-orientation="horizontal"
                tabindex="-1"
                data-slot="tabs-trigger"
                @on_click> Password </button>
        <button type="button"
                role="tab"
                aria-selected="false"
                aria-controls="bonsai_path_replaced_in_test-content-billing"
                data-state="inactive"
                id="bonsai_path_replaced_in_test-trigger-billing"
                data-orientation="horizontal"
                tabindex="-1"
                data-slot="tabs-trigger"
                disabled=""
                data-disabled=""> Billing </button>
      </div>
      <div data-state="active"
           data-orientation="horizontal"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-account"
           id="bonsai_path_replaced_in_test-content-account"
           tabindex="0"
           data-slot="tabs-content"> Your account </div>
      <div data-state="inactive"
           data-orientation="horizontal"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
           id="bonsai_path_replaced_in_test-content-password"
           tabindex="0"
           data-slot="tabs-content"
           hidden=""> </div>
      <div data-state="inactive"
           data-orientation="horizontal"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-billing"
           id="bonsai_path_replaced_in_test-content-billing"
           tabindex="0"
           data-slot="tabs-content"
           hidden=""> </div>
    </div>
    |}];
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"[aria-controls$=content-password]";
  Handle.show_diff handle;
  [%expect {|
      <div data-slot="tabs" dir="ltr" data-orientation="horizontal">
        <div role="tablist"
             aria-orientation="horizontal"
             data-slot="tabs-list"
             data-variant="default"
             @on_keydown>
          <button type="button"
                  role="tab"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-account"
    -|            data-state="active"
    +|            data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-account"
                  data-orientation="horizontal"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="bonsai_path_replaced_in_test-content-password"
    -|            data-state="inactive"
    +|            data-state="active"
                  id="bonsai_path_replaced_in_test-trigger-password"
                  data-orientation="horizontal"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-billing"
                  data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-billing"
                  data-orientation="horizontal"
                  tabindex="-1"
                  data-slot="tabs-trigger"
                  disabled=""
                  data-disabled=""> Billing </button>
        </div>
    -|  <div data-state="active"
    +|  <div data-state="inactive"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-account"
             id="bonsai_path_replaced_in_test-content-account"
             tabindex="0"
    -|       data-slot="tabs-content"> Your account </div>
    +|       data-slot="tabs-content"
    +|       hidden=""> </div>
    -|  <div data-state="inactive"
    +|  <div data-state="active"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
             id="bonsai_path_replaced_in_test-content-password"
             tabindex="0"
    -|       data-slot="tabs-content"
    -|       hidden=""> </div>
    +|       data-slot="tabs-content"> Change it </div>
        <div data-state="inactive"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-billing"
             id="bonsai_path_replaced_in_test-content-billing"
             tabindex="0"
             data-slot="tabs-content"
             hidden=""> </div>
      </div>
    |}];
  (* Right from Password skips the disabled Billing and wraps to Account. *)
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"[role=tablist]" ~key:ArrowRight;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key ArrowRight))

      <div data-slot="tabs" dir="ltr" data-orientation="horizontal">
        <div role="tablist"
             aria-orientation="horizontal"
             data-slot="tabs-list"
             data-variant="default"
             @on_keydown>
          <button type="button"
                  role="tab"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="bonsai_path_replaced_in_test-content-account"
    -|            data-state="inactive"
    +|            data-state="active"
                  id="bonsai_path_replaced_in_test-trigger-account"
                  data-orientation="horizontal"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-password"
    -|            data-state="active"
    +|            data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-password"
                  data-orientation="horizontal"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-billing"
                  data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-billing"
                  data-orientation="horizontal"
                  tabindex="-1"
                  data-slot="tabs-trigger"
                  disabled=""
                  data-disabled=""> Billing </button>
        </div>
    -|  <div data-state="inactive"
    +|  <div data-state="active"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-account"
             id="bonsai_path_replaced_in_test-content-account"
             tabindex="0"
    -|       data-slot="tabs-content"
    -|       hidden=""> </div>
    +|       data-slot="tabs-content"> Your account </div>
    -|  <div data-state="active"
    +|  <div data-state="inactive"
    -|       data-orientation="horizontal"
    -|       role="tabpanel"
    -|       aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
    -|       id="bonsai_path_replaced_in_test-content-password"
    -|       tabindex="0"
    -|       data-slot="tabs-content"> Change it </div>
    +|       data-orientation="horizontal"
    +|       role="tabpanel"
    +|       aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
    +|       id="bonsai_path_replaced_in_test-content-password"
    +|       tabindex="0"
    +|       data-slot="tabs-content"
    +|       hidden=""> </div>
        <div data-state="inactive"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-billing"
             id="bonsai_path_replaced_in_test-content-billing"
             tabindex="0"
             data-slot="tabs-content"
             hidden=""> </div>
      </div>
    |}];
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"[role=tablist]" ~key:End;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key End))

      <div data-slot="tabs" dir="ltr" data-orientation="horizontal">
        <div role="tablist"
             aria-orientation="horizontal"
             data-slot="tabs-list"
             data-variant="default"
             @on_keydown>
          <button type="button"
                  role="tab"
    -|            aria-selected="true"
    +|            aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-account"
    -|            data-state="active"
    +|            data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-account"
                  data-orientation="horizontal"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="tabs-trigger"
                  @on_click> Account </button>
          <button type="button"
                  role="tab"
    -|            aria-selected="false"
    +|            aria-selected="true"
                  aria-controls="bonsai_path_replaced_in_test-content-password"
    -|            data-state="inactive"
    +|            data-state="active"
                  id="bonsai_path_replaced_in_test-trigger-password"
                  data-orientation="horizontal"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="tabs-trigger"
                  @on_click> Password </button>
          <button type="button"
                  role="tab"
                  aria-selected="false"
                  aria-controls="bonsai_path_replaced_in_test-content-billing"
                  data-state="inactive"
                  id="bonsai_path_replaced_in_test-trigger-billing"
                  data-orientation="horizontal"
                  tabindex="-1"
                  data-slot="tabs-trigger"
                  disabled=""
                  data-disabled=""> Billing </button>
        </div>
    -|  <div data-state="active"
    +|  <div data-state="inactive"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-account"
             id="bonsai_path_replaced_in_test-content-account"
             tabindex="0"
    -|       data-slot="tabs-content"> Your account </div>
    +|       data-slot="tabs-content"
    +|       hidden=""> </div>
    -|  <div data-state="inactive"
    +|  <div data-state="active"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
             id="bonsai_path_replaced_in_test-content-password"
             tabindex="0"
    -|       data-slot="tabs-content"
    -|       hidden=""> </div>
    +|       data-slot="tabs-content"> Change it </div>
        <div data-state="inactive"
             data-orientation="horizontal"
             role="tabpanel"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-billing"
             id="bonsai_path_replaced_in_test-content-billing"
             tabindex="0"
             data-slot="tabs-content"
             hidden=""> </div>
      </div>
    |}]
;;

let%expect_test "vertical tabs move with up and down" =
  let handle =
    Render.handle
      ~classes:false
      (Tabs.component
         ~orientation:Vertical
         ~default_value:"account"
         (Bonsai_web.Bonsai.return parts))
  in
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"[role=tablist]" ~key:ArrowDown;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key ArrowDown))
    <div data-slot="tabs" dir="ltr" data-orientation="vertical">
      <div role="tablist"
           aria-orientation="vertical"
           data-slot="tabs-list"
           data-variant="default"
           @on_keydown>
        <button type="button"
                role="tab"
                aria-selected="false"
                aria-controls="bonsai_path_replaced_in_test-content-account"
                data-state="inactive"
                id="bonsai_path_replaced_in_test-trigger-account"
                data-orientation="vertical"
                tabindex="-1"
                data-slot="tabs-trigger"
                @on_click> Account </button>
        <button type="button"
                role="tab"
                aria-selected="true"
                aria-controls="bonsai_path_replaced_in_test-content-password"
                data-state="active"
                id="bonsai_path_replaced_in_test-trigger-password"
                data-orientation="vertical"
                tabindex="0"
                data-slot="tabs-trigger"
                @on_click> Password </button>
        <button type="button"
                role="tab"
                aria-selected="false"
                aria-controls="bonsai_path_replaced_in_test-content-billing"
                data-state="inactive"
                id="bonsai_path_replaced_in_test-trigger-billing"
                data-orientation="vertical"
                tabindex="-1"
                data-slot="tabs-trigger"
                disabled=""
                data-disabled=""> Billing </button>
      </div>
      <div data-state="inactive"
           data-orientation="vertical"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-account"
           id="bonsai_path_replaced_in_test-content-account"
           tabindex="0"
           data-slot="tabs-content"
           hidden=""> </div>
      <div data-state="active"
           data-orientation="vertical"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-password"
           id="bonsai_path_replaced_in_test-content-password"
           tabindex="0"
           data-slot="tabs-content"> Change it </div>
      <div data-state="inactive"
           data-orientation="vertical"
           role="tabpanel"
           aria-labelledby="bonsai_path_replaced_in_test-trigger-billing"
           id="bonsai_path_replaced_in_test-content-billing"
           tabindex="0"
           data-slot="tabs-content"
           hidden=""> </div>
    </div>
    |}]
;;
