open! Core
open Loon
open Bonsai_web
module Node = Vdom.Node
module Attr = Vdom.Attr
module Handle = Bonsai_web_test.Handle

(* A toaster and buttons that send toasts. *)
let app ?expand ?close_button buttons (local_ graph) =
  let toaster = Sonner.toaster ?expand ?close_button graph in
  let%map.Bonsai toaster in
  Node.div
    (List.mapi buttons ~f:(fun i on_click ->
       Node.button
         ~attrs:[ Attr.id (sprintf "b%d" i); Attr.on_click (fun _ -> on_click) ]
         [])
     @ [ toaster ])
;;

let app_with_sleep buttons (local_ graph) =
  let sleep = Bonsai.Clock.sleep graph in
  let toaster = Sonner.toaster graph in
  let%map.Bonsai toaster
  and sleep in
  Node.div
    (List.mapi (buttons sleep) ~f:(fun i on_click ->
       Node.button
         ~attrs:[ Attr.id (sprintf "b%d" i); Attr.on_click (fun _ -> on_click) ]
         [])
     @ [ toaster ])
;;

let press h i = Drive.click h (sprintf "#b%d" i)
let flush h = Handle.recompute_view_until_stable h

let%expect_test "a toast, with shadcn's colours and Sonner's DOM" =
  let h =
    Render.handle
      (app
         [ Sonner.toast
             ~description:"Sunday, December 03, 2023 at 9:00 AM"
             ~action:("Undo", Effect.print_s [%message "Undo"])
             "Event has been created"
         ])
  in
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global> </section>
    </div>
    |}];
  press h 0;
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global>
        <ol dir="ltr"
            tabindex="-1"
            data-sonner-toaster="true"
            data-sonner-theme="system"
            data-y-position="bottom"
            data-x-position="right"
            style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
            class="group toaster"
            @on_mouseenter
            @on_mouseleave
            @on_mousemove
            @on_pointerdown
            @on_pointerup>
          <li @key=1
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="0"
              data-front="true"
              data-swiping="false"
              data-dismissible="true"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Event has been created\nSunday, December 03, 2023 at 9:00 AM\nUndo\n\nDefault">
            <div data-content="">
              <div data-title=""> Event has been created </div>
              <div data-description=""> Sunday, December 03, 2023 at 9:00 AM </div>
            </div>
            <button data-button="true" data-action="true" @on_click> Undo </button>
          </li>
        </ol>
      </section>
    </div>
    |}];
  (* The action runs and dismisses; the toast goes after its exit. *)
  Drive.click h "[data-action]";
  flush h;
  Handle.show_diff h;
  [%expect
    {|
    Undo

              data-x-position="right"
              style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
              class="group toaster"
              @on_mouseenter
              @on_mouseleave
              @on_mousemove
              @on_pointerdown
              @on_pointerup>
            <li @key=1
                tabindex="0"
                data-sonner-toast=""
                data-rich-colors="false"
                data-styled="true"
                data-mounted="false"
                data-promise="false"
                data-swiped="false"
    -|          data-removed="false"
    +|          data-removed="true"
                data-visible="true"
                data-y-position="bottom"
                data-x-position="right"
                data-index="0"
                data-front="true"
                data-swiping="false"
                data-dismissible="true"
                data-invert="false"
                data-swipe-out="false"
                data-expanded="false"
                style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
                loon-sonner-measure="Event has been created\nSunday, December 03, 2023 at 9:00 AM\nUndo\n\nDefault">
              <div data-content="">
                <div data-title=""> Event has been created </div>
                <div data-description=""> Sunday, December 03, 2023 at 9:00 AM </div>
              </div>
    |}];
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 200);
  flush h;
  Handle.show_diff h;
  [%expect
    {|
      <div>
        <button id="b0" @on_click> </button>
        <section aria-label="Notifications alt+T"
                 tabindex="-1"
                 aria-live="polite"
                 aria-relevant="additions text"
                 aria-atomic="false"
    -|           @on_keydown_global>
    -|    <ol dir="ltr"
    -|        tabindex="-1"
    -|        data-sonner-toaster="true"
    -|        data-sonner-theme="system"
    -|        data-y-position="bottom"
    -|        data-x-position="right"
    -|        style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
    -|        class="group toaster"
    -|        @on_mouseenter
    -|        @on_mouseleave
    -|        @on_mousemove
    -|        @on_pointerdown
    -|        @on_pointerup>
    -|      <li @key=1
    -|          tabindex="0"
    -|          data-sonner-toast=""
    -|          data-rich-colors="false"
    -|          data-styled="true"
    -|          data-mounted="false"
    -|          data-promise="false"
    -|          data-swiped="false"
    -|          data-removed="true"
    -|          data-visible="true"
    -|          data-y-position="bottom"
    -|          data-x-position="right"
    -|          data-index="0"
    -|          data-front="true"
    -|          data-swiping="false"
    -|          data-dismissible="true"
    -|          data-invert="false"
    -|          data-swipe-out="false"
    -|          data-expanded="false"
    -|          style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
    -|          loon-sonner-measure="Event has been created\nSunday, December 03, 2023 at 9:00 AM\nUndo\n\nDefault">
    -|        <div data-content="">
    -|          <div data-title=""> Event has been created </div>
    -|          <div data-description=""> Sunday, December 03, 2023 at 9:00 AM </div>
    -|        </div>
    -|        <button data-button="true" data-action="true" @on_click> Undo </button>
    -|      </li>
    -|    </ol>
    -|  </section>
    +|           @on_keydown_global> </section>
      </div>
    |}]
;;

let%expect_test "types and their icons" =
  let h =
    Render.handle
      (app
         [ Sonner.success "Success"
         ; Sonner.info "Info"
         ; Sonner.warning "Warning"
         ; Sonner.error "Error"
         ; Sonner.loading "Loading"
         ])
  in
  flush h;
  List.iter [ 0; 1; 2; 3; 4 ] ~f:(press h);
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <button id="b1" @on_click> </button>
      <button id="b2" @on_click> </button>
      <button id="b3" @on_click> </button>
      <button id="b4" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global>
        <ol dir="ltr"
            tabindex="-1"
            data-sonner-toaster="true"
            data-sonner-theme="system"
            data-y-position="bottom"
            data-x-position="right"
            style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
            class="group toaster"
            @on_mouseenter
            @on_mouseleave
            @on_mousemove
            @on_pointerdown
            @on_pointerup>
          <li @key=6
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="0"
              data-front="true"
              data-swiping="false"
              data-dismissible="true"
              data-type="loading"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 0; --toasts-before: 0; --z-index: 5; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Loading\n\n\n\nLoading">
            <div data-icon="">
              <div data-visible="true" class="sonner-loader">
                <svg xmlns="http://www.w3.org/2000/svg"
                     width="24"
                     height="24"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round"
                     class="animate-spin lucide lucide-loader-circle size-4">
                  <path d="M21 12a9 9 0 1 1-6.219-8.56"> </path>
                </svg>
              </div>
            </div>
            <div data-content="">
              <div data-title=""> Loading </div>
            </div>
          </li>
          <li @key=5
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="1"
              data-front="false"
              data-swiping="false"
              data-dismissible="true"
              data-type="error"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 1; --toasts-before: 1; --z-index: 4; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Error\n\n\n\nError">
            <div data-icon="">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-octagon-x size-4">
                <path d="m15 9-6 6"> </path>
                <path d="M2.586 16.726A2 2 0 0 1 2 15.312V8.688a2 2 0 0 1 .586-1.414l4.688-4.688A2 2 0 0 1 8.688 2h6.624a2 2 0 0 1 1.414.586l4.688 4.688A2 2 0 0 1 22 8.688v6.624a2 2 0 0 1-.586 1.414l-4.688 4.688a2 2 0 0 1-1.414.586H8.688a2 2 0 0 1-1.414-.586z"> </path>
                <path d="m9 9 6 6"> </path>
              </svg>
            </div>
            <div data-content="">
              <div data-title=""> Error </div>
            </div>
          </li>
          <li @key=4
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="2"
              data-front="false"
              data-swiping="false"
              data-dismissible="true"
              data-type="warning"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 2; --toasts-before: 2; --z-index: 3; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Warning\n\n\n\nWarning">
            <div data-icon="">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-triangle-alert size-4">
                <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"> </path>
                <path d="M12 9v4"> </path>
                <path d="M12 17h.01"> </path>
              </svg>
            </div>
            <div data-content="">
              <div data-title=""> Warning </div>
            </div>
          </li>
          <li @key=3
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="false"
              data-y-position="bottom"
              data-x-position="right"
              data-index="3"
              data-front="false"
              data-swiping="false"
              data-dismissible="true"
              data-type="info"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 3; --toasts-before: 3; --z-index: 2; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Info\n\n\n\nInfo">
            <div data-icon="">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-info size-4">
                <circle cx="12" cy="12" r="10"> </circle>
                <path d="M12 16v-4"> </path>
                <path d="M12 8h.01"> </path>
              </svg>
            </div>
            <div data-content="">
              <div data-title=""> Info </div>
            </div>
          </li>
          <li @key=2
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="false"
              data-y-position="bottom"
              data-x-position="right"
              data-index="4"
              data-front="false"
              data-swiping="false"
              data-dismissible="true"
              data-type="success"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 4; --toasts-before: 4; --z-index: 1; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Success\n\n\n\nSuccess">
            <div data-icon="">
              <svg xmlns="http://www.w3.org/2000/svg"
                   width="24"
                   height="24"
                   viewBox="0 0 24 24"
                   fill="none"
                   stroke="currentColor"
                   stroke-width="2"
                   stroke-linecap="round"
                   stroke-linejoin="round"
                   class="lucide lucide-circle-check size-4">
                <circle cx="12" cy="12" r="10"> </circle>
                <path d="m9 12 2 2 4-4"> </path>
              </svg>
            </div>
            <div data-content="">
              <div data-title=""> Success </div>
            </div>
          </li>
        </ol>
      </section>
    </div>
    |}]
;;

let%expect_test
    "stacked, the newest in front; hovering expands and pauses the timers"
  =
  let h =
    Render.handle
      ~classes:false
      (app [ Sonner.toast "One"; Sonner.toast "Two" ])
  in
  flush h;
  press h 0;
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 1000);
  press h 1;
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <button id="b1" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global>
        <ol dir="ltr"
            tabindex="-1"
            data-sonner-toaster="true"
            data-sonner-theme="system"
            data-y-position="bottom"
            data-x-position="right"
            style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
            @on_mouseenter
            @on_mouseleave
            @on_mousemove
            @on_pointerdown
            @on_pointerup>
          <li @key=8
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="0"
              data-front="true"
              data-swiping="false"
              data-dismissible="true"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 0; --toasts-before: 0; --z-index: 2; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Two\n\n\n\nDefault">
            <div data-content="">
              <div data-title=""> Two </div>
            </div>
          </li>
          <li @key=7
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="1"
              data-front="false"
              data-swiping="false"
              data-dismissible="true"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 1; --toasts-before: 1; --z-index: 1; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="One\n\n\n\nDefault">
            <div data-content="">
              <div data-title=""> One </div>
            </div>
          </li>
        </ol>
      </section>
    </div>
    |}];
  Handle.mouseenter h ~get_vdom:Fn.id ~selector:"[data-sonner-toaster]";
  flush h;
  Handle.show_diff h;
  [%expect
    {|
                data-sonner-toast=""
                data-rich-colors="false"
                data-styled="true"
                data-mounted="false"
                data-promise="false"
                data-swiped="false"
                data-removed="false"
                data-visible="true"
                data-y-position="bottom"
                data-x-position="right"
                data-index="0"
                data-front="true"
                data-swiping="false"
                data-dismissible="true"
                data-invert="false"
                data-swipe-out="false"
    -|          data-expanded="false"
    +|          data-expanded="true"
                style="--index: 0; --toasts-before: 0; --z-index: 2; --offset: 0px; --initial-height: 0px;"
                loon-sonner-measure="Two\n\n\n\nDefault">
              <div data-content="">
                <div data-title=""> Two </div>
              </div>
            </li>
            <li @key=7
                tabindex="0"
                data-sonner-toast=""
                data-rich-colors="false"
                data-styled="true"
                data-mounted="false"
                data-promise="false"
                data-swiped="false"
                data-removed="false"
                data-visible="true"
                data-y-position="bottom"
                data-x-position="right"
                data-index="1"
                data-front="false"
                data-swiping="false"
                data-dismissible="true"
                data-invert="false"
                data-swipe-out="false"
    -|          data-expanded="false"
    +|          data-expanded="true"
                style="--index: 1; --toasts-before: 1; --z-index: 1; --offset: 0px; --initial-height: 0px;"
                loon-sonner-measure="One\n\n\n\nDefault">
              <div data-content="">
                <div data-title=""> One </div>
              </div>
            </li>
          </ol>
        </section>
      </div>
    |}];
  (* Paused: nothing expires. *)
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 10_000);
  flush h;
  Handle.show_diff h;
  [%expect {| |}]
;;

let%expect_test "toasts expire after their duration" =
  let h =
    Render.handle
      ~classes:false
      (app
         [ Sonner.toast "One"
         ; Sonner.toast ~duration:(Time_ns.Span.of_int_ms 1000) "Short"
         ])
  in
  flush h;
  press h 0;
  press h 1;
  flush h;
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 1000);
  flush h;
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 200);
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <button id="b1" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global>
        <ol dir="ltr"
            tabindex="-1"
            data-sonner-toaster="true"
            data-sonner-theme="system"
            data-y-position="bottom"
            data-x-position="right"
            style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
            @on_mouseenter
            @on_mouseleave
            @on_mousemove
            @on_pointerdown
            @on_pointerup>
          <li @key=9
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="false"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="0"
              data-front="true"
              data-swiping="false"
              data-dismissible="true"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="One\n\n\n\nDefault">
            <div data-content="">
              <div data-title=""> One </div>
            </div>
          </li>
        </ol>
      </section>
    </div>
    |}];
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 3000);
  flush h;
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 200);
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <button id="b1" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global> </section>
    </div>
    |}]
;;

let%expect_test "promise: loading, then success, in the same toast" =
  let h =
    Render.handle
      ~classes:false
      (app_with_sleep (fun sleep ->
         [ Sonner.promise
             ~loading:"Loading..."
             ~success:(fun name -> name ^ " has been created")
             ~error:(fun _ -> "Error")
             (let%map.Effect () = sleep (Time_ns.Span.of_int_ms 2000) in
              Ok "Event")
         ]))
  in
  flush h;
  press h 0;
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global>
        <ol dir="ltr"
            tabindex="-1"
            data-sonner-toaster="true"
            data-sonner-theme="system"
            data-y-position="bottom"
            data-x-position="right"
            style="--front-toast-height: 0px; --width: 356px; --gap: 14px; --normal-bg: var(--popover); --normal-text: var(--popover-foreground); --normal-border: var(--border); --border-radius: var(--radius); --offset-top: 24px; --mobile-offset-top: 16px; --offset-right: 24px; --mobile-offset-right: 16px; --offset-bottom: 24px; --mobile-offset-bottom: 16px; --offset-left: 24px; --mobile-offset-left: 16px;"
            @on_mouseenter
            @on_mouseleave
            @on_mousemove
            @on_pointerdown
            @on_pointerup>
          <li @key=11
              tabindex="0"
              data-sonner-toast=""
              data-rich-colors="false"
              data-styled="true"
              data-mounted="false"
              data-promise="true"
              data-swiped="false"
              data-removed="false"
              data-visible="true"
              data-y-position="bottom"
              data-x-position="right"
              data-index="0"
              data-front="true"
              data-swiping="false"
              data-dismissible="true"
              data-type="loading"
              data-invert="false"
              data-swipe-out="false"
              data-expanded="false"
              style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
              loon-sonner-measure="Loading...\n\n\n\nLoading">
            <div data-icon="">
              <div data-visible="true">
                <svg xmlns="http://www.w3.org/2000/svg"
                     width="24"
                     height="24"
                     viewBox="0 0 24 24"
                     fill="none"
                     stroke="currentColor"
                     stroke-width="2"
                     stroke-linecap="round"
                     stroke-linejoin="round">
                  <path d="M21 12a9 9 0 1 1-6.219-8.56"> </path>
                </svg>
              </div>
            </div>
            <div data-content="">
              <div data-title=""> Loading... </div>
            </div>
          </li>
        </ol>
      </section>
    </div>
    |}];
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 2000);
  flush h;
  Handle.show_diff h;
  [%expect
    {|
            <li @key=11
                tabindex="0"
                data-sonner-toast=""
                data-rich-colors="false"
                data-styled="true"
                data-mounted="false"
                data-promise="true"
                data-swiped="false"
                data-removed="false"
                data-visible="true"
                data-y-position="bottom"
                data-x-position="right"
                data-index="0"
                data-front="true"
                data-swiping="false"
                data-dismissible="true"
    -|          data-type="loading"
    +|          data-type="success"
                data-invert="false"
                data-swipe-out="false"
                data-expanded="false"
                style="--index: 0; --toasts-before: 0; --z-index: 1; --offset: 0px; --initial-height: 0px;"
    -|          loon-sonner-measure="Loading...\n\n\n\nLoading">
    +|          loon-sonner-measure="Event has been created\n\n\n\nSuccess">
              <div data-icon="">
    -|          <div data-visible="true">
    +|          <div data-visible="false">
                  <svg xmlns="http://www.w3.org/2000/svg"
                       width="24"
                       height="24"
                       viewBox="0 0 24 24"
                       fill="none"
                       stroke="currentColor"
                       stroke-width="2"
                       stroke-linecap="round"
                       stroke-linejoin="round">
                    <path d="M21 12a9 9 0 1 1-6.219-8.56"> </path>
                  </svg>
                </div>
    +|          <svg xmlns="http://www.w3.org/2000/svg"
    +|               width="24"
    +|               height="24"
    +|               viewBox="0 0 24 24"
    +|               fill="none"
    +|               stroke="currentColor"
    +|               stroke-width="2"
    +|               stroke-linecap="round"
    +|               stroke-linejoin="round">
    +|            <circle cx="12" cy="12" r="10"> </circle>
    +|            <path d="m9 12 2 2 4-4"> </path>
    +|          </svg>
              </div>
              <div data-content="">
    -|          <div data-title=""> Loading... </div>
    +|          <div data-title=""> Event has been created </div>
              </div>
            </li>
          </ol>
        </section>
      </div>
    |}]
;;

let%expect_test "dismiss closes every toast" =
  let h =
    Render.handle ~classes:false (app [ Sonner.toast "One"; Sonner.dismiss () ])
  in
  flush h;
  press h 0;
  press h 0;
  flush h;
  press h 1;
  flush h;
  Handle.advance_clock_by h (Time_ns.Span.of_int_ms 200);
  flush h;
  Handle.show h;
  [%expect
    {|
    <div>
      <button id="b0" @on_click> </button>
      <button id="b1" @on_click> </button>
      <section aria-label="Notifications alt+T"
               tabindex="-1"
               aria-live="polite"
               aria-relevant="additions text"
               aria-atomic="false"
               @on_keydown_global> </section>
    </div>
    |}]
;;
