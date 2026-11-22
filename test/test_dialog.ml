open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Attr = Virtual_dom.Vdom.Attr
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let ignore_ _ = Bonsai_web.Effect.Ignore
let wrap node = Node.div [ node ]

let parts dialog =
  [ Dialog.trigger
      dialog
      (Button.view ~variant:Outline [ Node.text "Open Dialog" ])
  ; Dialog.content
      dialog
      [ Dialog.header
          [ Dialog.title dialog [ Node.text "Edit profile" ]
          ; Dialog.description
              dialog
              [ Node.text "Make changes to your profile here." ]
          ]
      ; Node.input ~attrs:[ Attr.id "name" ] ()
      ; Dialog.footer
          [ Dialog.close
              dialog
              (Button.view ~variant:Outline [ Node.text "Cancel" ])
          ; Button.view ~attrs:[ Attr.id "save" ] [ Node.text "Save changes" ]
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes, open" =
  Render.html
    (wrap @@ Dialog.view ~id:"d" ~open_:true ~on_open_change:ignore_ parts);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="dialog-trigger"
              data-variant="outline"
              data-size="default"
              id="d-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="d-content"
              data-state="open"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
              @on_click> Open Dialog </button>
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
             white-space: normal;
             text-align: start;
             font-weight: normal;
             font-style: normal;
             letter-spacing: normal;
             text-transform: none;
             position: fixed;
             width: 100%;
             height: 100%;
             pointer-events: none;
             z-index: 50;
           }>
        <div data-slot="dialog-overlay"
             data-state="open"
             class="cn-dialog-overlay fixed inset-0 isolate z-50"
             @on_click
             style={
               pointer-events: auto;
             }> </div>
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
             class="-translate-x-1/2 -translate-y-1/2 cn-dialog-content fixed left-1/2 outline-none top-1/2 w-full z-50"
             loon-dismiss=(()false true)
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="dialog-header" class="cn-dialog-header flex flex-col">
            <h2 data-slot="dialog-title" id="d-title" class="cn-dialog-title cn-font-heading"> Edit profile </h2>
            <p data-slot="dialog-description" id="d-description" class="cn-dialog-description"> Make changes to your profile here. </p>
          </div>
          <input id="name"/>
          <div data-slot="dialog-footer"
               class="cn-dialog-footer flex flex-col-reverse gap-2 sm:flex-row sm:justify-end">
            <button type="button"
                    data-slot="dialog-close"
                    data-variant="outline"
                    data-size="default"
                    class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
                    @on_click> Cancel </button>
            <button type="button"
                    data-slot="button"
                    data-variant="default"
                    data-size="default"
                    id="save"
                    class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-default disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"> Save changes </button>
          </div>
          <button type="button"
                  data-slot="dialog-close"
                  data-variant="ghost"
                  data-size="icon-sm"
                  class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-icon-sm cn-button-variant-ghost cn-dialog-close disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
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
                 class="lucide lucide-x">
              <path d="M18 6 6 18"> </path>
              <path d="m6 6 12 12"> </path>
            </svg>
            <span class="sr-only"> Close </span>
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
    |}]
;;

let%expect_test "closed: only the trigger" =
  Render.html
    ~classes:false
    (wrap @@ Dialog.view ~id:"d" ~open_:false ~on_open_change:ignore_ parts);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="dialog-trigger"
              data-variant="outline"
              data-size="default"
              id="d-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="d-content"
              data-state="closed"
              @on_click> Open Dialog </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let component graph =
  Bonsai.map
    (Dialog.component (Bonsai.return parts) graph)
    ~f:(fun n -> Node.div [ n ])
;;

let%expect_test
    "the trigger opens it; Escape, the X, Cancel and the overlay close it"
  =
  let handle = Render.handle ~classes:false component in
  let summary () =
    let vdom = Handle.last_result handle in
    let has selector =
      not
        (List.is_empty
           (Node_helpers.select
              (Node_helpers.unsafe_convert_exn vdom)
              ~selector))
    in
    printf "open: %b\n" (has "[role=dialog]")
  in
  let opened () =
    Drive.click handle "[aria-haspopup=dialog]";
    summary ()
  in
  opened ();
  Handle.show handle;
  [%expect
    {|
    open: true
    <div>
      <button type="button"
              data-slot="dialog-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click> Open Dialog </button>
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
             white-space: normal;
             text-align: start;
             font-weight: normal;
             font-style: normal;
             letter-spacing: normal;
             text-transform: none;
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
             id="bonsai_path_replaced_in_test-content"
             aria-describedby="bonsai_path_replaced_in_test-description"
             aria-labelledby="bonsai_path_replaced_in_test-title"
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
          <div data-slot="dialog-header">
            <h2 data-slot="dialog-title" id="bonsai_path_replaced_in_test-title"> Edit profile </h2>
            <p data-slot="dialog-description" id="bonsai_path_replaced_in_test-description"> Make changes to your profile here. </p>
          </div>
          <input id="name"/>
          <div data-slot="dialog-footer">
            <button type="button"
                    data-slot="dialog-close"
                    data-variant="outline"
                    data-size="default"
                    @on_click> Cancel </button>
            <button type="button"
                    data-slot="button"
                    data-variant="default"
                    data-size="default"
                    id="save"> Save changes </button>
          </div>
          <button type="button"
                  data-slot="dialog-close"
                  data-variant="ghost"
                  data-size="icon-sm"
                  @on_click>
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round">
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
  summary ();
  [%expect
    {|
    ("default prevented" (key Escape))
    open: false
    |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=dialog-content] > [data-slot=dialog-close]";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=dialog-footer] button";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=dialog-overlay]";
  summary ();
  [%expect {| open: false |}]
;;

let%expect_test
    "no X with ~show_close_button:false; a Close button in the footer"
  =
  Render.html
    ~classes:false
    (wrap
     @@ Dialog.view ~id:"d" ~open_:true ~on_open_change:ignore_ (fun dialog ->
       [ Dialog.content
           ~show_close_button:false
           dialog
           [ Dialog.footer ~show_close_button:dialog [] ]
       ]));
  [%expect
    {|
    <div>
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
             white-space: normal;
             text-align: start;
             font-weight: normal;
             font-style: normal;
             letter-spacing: normal;
             text-transform: none;
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
          <div data-slot="dialog-footer">
            <button type="button"
                    data-slot="dialog-close"
                    data-variant="outline"
                    data-size="default"
                    @on_click> Close </button>
          </div>
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
    |}]
;;
