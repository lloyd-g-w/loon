open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let ignore_ _ = Bonsai_web.Effect.Ignore
let wrap node = Node.div [ node ]

let parts ?size d =
  [ Alert_dialog.trigger
      d
      (Button.view ~variant:Outline [ Node.text "Show Dialog" ])
  ; Alert_dialog.content
      ?size
      d
      [ Alert_dialog.header
          [ Alert_dialog.title d [ Node.text "Are you absolutely sure?" ]
          ; Alert_dialog.description
              d
              [ Node.text "This action cannot be undone." ]
          ]
      ; Alert_dialog.footer
          [ Alert_dialog.cancel d [ Node.text "Cancel" ]
          ; Alert_dialog.action
              d
              ~on_click:
                (Bonsai_web.Effect.of_thunk (fun () ->
                   print_endline "continued"))
              [ Node.text "Continue" ]
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes, open" =
  Render.html
    (wrap
     @@ Alert_dialog.view
          ~id:"a"
          ~open_:true
          ~on_open_change:ignore_
          (parts ?size:None));
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="alert-dialog-trigger"
              data-variant="outline"
              data-size="default"
              id="a-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="a-content"
              data-state="open"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
              @on_click> Show Dialog </button>
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
        <div data-slot="alert-dialog-overlay"
             data-state="open"
             class="cn-alert-dialog-overlay fixed inset-0 z-50"
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
        <div role="alertdialog"
             id="a-content"
             aria-describedby="a-description"
             aria-labelledby="a-title"
             data-state="open"
             tabindex="-1"
             data-slot="alert-dialog-content"
             data-size="default"
             class="-translate-x-1/2 -translate-y-1/2 cn-alert-dialog-content fixed grid group/alert-dialog-content left-1/2 outline-none top-1/2 w-full z-50"
             loon-dismiss=(()false true)
             loon-focus-on-mount=(Selector [data-slot=alert-dialog-cancel])
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="alert-dialog-header" class="cn-alert-dialog-header">
            <h2 data-slot="alert-dialog-title"
                id="a-title"
                class="cn-alert-dialog-title cn-font-heading"> Are you absolutely sure? </h2>
            <p data-slot="alert-dialog-description"
               id="a-description"
               class="cn-alert-dialog-description"> This action cannot be undone. </p>
          </div>
          <div data-slot="alert-dialog-footer"
               class="cn-alert-dialog-footer flex flex-col-reverse gap-2 group-data-[size=sm]/alert-dialog-content:grid group-data-[size=sm]/alert-dialog-content:grid-cols-2 sm:flex-row sm:justify-end">
            <button type="button"
                    data-slot="alert-dialog-cancel"
                    data-variant="outline"
                    data-size="default"
                    class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-alert-dialog-cancel cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
                    @on_click> Cancel </button>
            <button type="button"
                    data-slot="alert-dialog-action"
                    data-variant="default"
                    data-size="default"
                    class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-alert-dialog-action cn-button cn-button-size-default cn-button-variant-default disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
                    @on_click> Continue </button>
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

let%expect_test "size sm, with media" =
  Render.html
    ~classes:false
    (wrap
     @@ Alert_dialog.view ~id:"a" ~open_:true ~on_open_change:ignore_ (fun d ->
       [ Alert_dialog.content
           ~size:Sm
           d
           [ Alert_dialog.header
               [ Alert_dialog.media [ Icon.view Circle ]
               ; Alert_dialog.title d [ Node.text "Sure?" ]
               ]
           ]
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
        <div data-slot="alert-dialog-overlay" data-state="open" style={ pointer-events: auto; }> </div>
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
        <div role="alertdialog"
             id="a-content"
             aria-describedby="a-description"
             aria-labelledby="a-title"
             data-state="open"
             tabindex="-1"
             data-slot="alert-dialog-content"
             data-size="sm"
             loon-dismiss=(()false true)
             loon-focus-on-mount=(Selector [data-slot=alert-dialog-cancel])
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="alert-dialog-header">
            <div data-slot="alert-dialog-media">
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
            </div>
            <h2 data-slot="alert-dialog-title" id="a-title"> Sure? </h2>
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

let component graph =
  Bonsai.map
    (Alert_dialog.component (Bonsai.return (parts ?size:None)) graph)
    ~f:(fun n -> Node.div [ n ])
;;

let%expect_test
    "the overlay does not close it; Escape, Cancel and the action do"
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
    printf "open: %b\n" (has "[role=alertdialog]")
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
              data-slot="alert-dialog-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click> Show Dialog </button>
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
        <div data-slot="alert-dialog-overlay" data-state="open" style={ pointer-events: auto; }> </div>
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
        <div role="alertdialog"
             id="bonsai_path_replaced_in_test-content"
             aria-describedby="bonsai_path_replaced_in_test-description"
             aria-labelledby="bonsai_path_replaced_in_test-title"
             data-state="open"
             tabindex="-1"
             data-slot="alert-dialog-content"
             data-size="default"
             loon-dismiss=(()false true)
             loon-focus-on-mount=(Selector [data-slot=alert-dialog-cancel])
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="alert-dialog-header">
            <h2 data-slot="alert-dialog-title" id="bonsai_path_replaced_in_test-title"> Are you absolutely sure? </h2>
            <p data-slot="alert-dialog-description" id="bonsai_path_replaced_in_test-description"> This action cannot be undone. </p>
          </div>
          <div data-slot="alert-dialog-footer">
            <button type="button"
                    data-slot="alert-dialog-cancel"
                    data-variant="outline"
                    data-size="default"
                    @on_click> Cancel </button>
            <button type="button"
                    data-slot="alert-dialog-action"
                    data-variant="default"
                    data-size="default"
                    @on_click> Continue </button>
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
    |}];
  (match Drive.click handle "[data-slot=alert-dialog-overlay]" with
   | () -> print_endline "the overlay closed it"
   | exception _ -> print_endline "the overlay ignores clicks");
  [%expect {| the overlay ignores clicks |}];
  Drive.key handle "[role=alertdialog]" Escape;
  summary ();
  [%expect
    {|
    ("default prevented" (key Escape))
    open: false
    |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=alert-dialog-cancel]";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=alert-dialog-action]";
  summary ();
  [%expect
    {|
    continued
    open: false
    |}]
;;
