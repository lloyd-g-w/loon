open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let ignore_ _ = Bonsai_web.Effect.Ignore
let wrap node = Node.div [ node ]

let parts ?side sheet =
  [ Sheet.trigger sheet (Button.view ~variant:Outline [ Node.text "Open" ])
  ; Sheet.content
      ?side
      sheet
      [ Sheet.header
          [ Sheet.title sheet [ Node.text "Edit profile" ]
          ; Sheet.description
              sheet
              [ Node.text "Make changes to your profile here." ]
          ]
      ; Sheet.footer
          [ Sheet.close
              sheet
              (Button.view ~variant:Outline [ Node.text "Close" ])
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes, open on the right" =
  Render.html
    (wrap
     @@ Sheet.view
          ~id:"s"
          ~open_:true
          ~on_open_change:ignore_
          (parts ?side:None));
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="sheet-trigger"
              data-variant="outline"
              data-size="default"
              id="s-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="s-content"
              data-state="open"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
              @on_click> Open </button>
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
        <div data-slot="sheet-overlay"
             data-state="open"
             class="cn-sheet-overlay data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0 duration-100 fixed inset-0 z-50"
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
             id="s-content"
             aria-describedby="s-description"
             aria-labelledby="s-title"
             data-state="open"
             tabindex="-1"
             data-slot="sheet-content"
             data-side="right"
             class="cn-sheet-content data-[side=bottom]:data-closed:slide-out-to-bottom-10 data-[side=bottom]:data-open:slide-in-from-bottom-10 data-[side=left]:data-closed:slide-out-to-left-10 data-[side=left]:data-open:slide-in-from-left-10 data-[side=right]:data-closed:slide-out-to-right-10 data-[side=right]:data-open:slide-in-from-right-10 data-[side=top]:data-closed:slide-out-to-top-10 data-[side=top]:data-open:slide-in-from-top-10 data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0"
             loon-dismiss=(()false true)
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="sheet-header" class="cn-sheet-header flex flex-col">
            <h2 data-slot="sheet-title" id="s-title" class="cn-font-heading cn-sheet-title"> Edit profile </h2>
            <p data-slot="sheet-description" id="s-description" class="cn-sheet-description"> Make changes to your profile here. </p>
          </div>
          <div data-slot="sheet-footer" class="cn-sheet-footer flex flex-col mt-auto">
            <button type="button"
                    data-slot="sheet-close"
                    data-variant="outline"
                    data-size="default"
                    class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
                    @on_click> Close </button>
          </div>
          <button type="button"
                  data-slot="sheet-close"
                  data-variant="ghost"
                  data-size="icon-sm"
                  class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-icon-sm cn-button-variant-ghost cn-sheet-close disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
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

let%expect_test "each side's classes" =
  List.iter Sheet.Side.all ~f:(fun side ->
    print_endline (Sheet.Side.name side);
    Render.html
      ~selector:"[data-slot=sheet-content]"
      (wrap
       @@ Sheet.view ~id:"s" ~open_:true ~on_open_change:ignore_ (fun sheet ->
         [ Sheet.content ~side ~show_close_button:false sheet [] ])));
  [%expect
    {|
    top
    <div role="dialog"
         id="s-content"
         aria-describedby="s-description"
         aria-labelledby="s-title"
         data-state="open"
         tabindex="-1"
         data-slot="sheet-content"
         data-side="top"
         class="cn-sheet-content data-[side=bottom]:data-closed:slide-out-to-bottom-10 data-[side=bottom]:data-open:slide-in-from-bottom-10 data-[side=left]:data-closed:slide-out-to-left-10 data-[side=left]:data-open:slide-in-from-left-10 data-[side=right]:data-closed:slide-out-to-right-10 data-[side=right]:data-open:slide-in-from-right-10 data-[side=top]:data-closed:slide-out-to-top-10 data-[side=top]:data-open:slide-in-from-top-10 data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0"
         loon-dismiss=(()false true)
         loon-focus-on-mount=First_tabbable
         loon-scroll-lock=()
         @on_keydown
         style={
           pointer-events: auto;
         }> </div>
    right
    <div role="dialog"
         id="s-content"
         aria-describedby="s-description"
         aria-labelledby="s-title"
         data-state="open"
         tabindex="-1"
         data-slot="sheet-content"
         data-side="right"
         class="cn-sheet-content data-[side=bottom]:data-closed:slide-out-to-bottom-10 data-[side=bottom]:data-open:slide-in-from-bottom-10 data-[side=left]:data-closed:slide-out-to-left-10 data-[side=left]:data-open:slide-in-from-left-10 data-[side=right]:data-closed:slide-out-to-right-10 data-[side=right]:data-open:slide-in-from-right-10 data-[side=top]:data-closed:slide-out-to-top-10 data-[side=top]:data-open:slide-in-from-top-10 data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0"
         loon-dismiss=(()false true)
         loon-focus-on-mount=First_tabbable
         loon-scroll-lock=()
         @on_keydown
         style={
           pointer-events: auto;
         }> </div>
    bottom
    <div role="dialog"
         id="s-content"
         aria-describedby="s-description"
         aria-labelledby="s-title"
         data-state="open"
         tabindex="-1"
         data-slot="sheet-content"
         data-side="bottom"
         class="cn-sheet-content data-[side=bottom]:data-closed:slide-out-to-bottom-10 data-[side=bottom]:data-open:slide-in-from-bottom-10 data-[side=left]:data-closed:slide-out-to-left-10 data-[side=left]:data-open:slide-in-from-left-10 data-[side=right]:data-closed:slide-out-to-right-10 data-[side=right]:data-open:slide-in-from-right-10 data-[side=top]:data-closed:slide-out-to-top-10 data-[side=top]:data-open:slide-in-from-top-10 data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0"
         loon-dismiss=(()false true)
         loon-focus-on-mount=First_tabbable
         loon-scroll-lock=()
         @on_keydown
         style={
           pointer-events: auto;
         }> </div>
    left
    <div role="dialog"
         id="s-content"
         aria-describedby="s-description"
         aria-labelledby="s-title"
         data-state="open"
         tabindex="-1"
         data-slot="sheet-content"
         data-side="left"
         class="cn-sheet-content data-[side=bottom]:data-closed:slide-out-to-bottom-10 data-[side=bottom]:data-open:slide-in-from-bottom-10 data-[side=left]:data-closed:slide-out-to-left-10 data-[side=left]:data-open:slide-in-from-left-10 data-[side=right]:data-closed:slide-out-to-right-10 data-[side=right]:data-open:slide-in-from-right-10 data-[side=top]:data-closed:slide-out-to-top-10 data-[side=top]:data-open:slide-in-from-top-10 data-closed:animate-out data-closed:fade-out-0 data-open:animate-in data-open:fade-in-0"
         loon-dismiss=(()false true)
         loon-focus-on-mount=First_tabbable
         loon-scroll-lock=()
         @on_keydown
         style={
           pointer-events: auto;
         }> </div>
    |}]
;;

let component graph =
  Bonsai.map
    (Sheet.component (Bonsai.return (parts ~side:Left)) graph)
    ~f:(fun n -> Node.div [ n ])
;;

let%expect_test
    "the trigger opens it; Escape, the X, Close and the overlay close it"
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
              data-slot="sheet-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click> Open </button>
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
        <div data-slot="sheet-overlay" data-state="open" @on_click style={ pointer-events: auto; }> </div>
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
             data-slot="sheet-content"
             data-side="left"
             loon-dismiss=(()false true)
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
             }>
          <div data-slot="sheet-header">
            <h2 data-slot="sheet-title" id="bonsai_path_replaced_in_test-title"> Edit profile </h2>
            <p data-slot="sheet-description" id="bonsai_path_replaced_in_test-description"> Make changes to your profile here. </p>
          </div>
          <div data-slot="sheet-footer">
            <button type="button"
                    data-slot="sheet-close"
                    data-variant="outline"
                    data-size="default"
                    @on_click> Close </button>
          </div>
          <button type="button"
                  data-slot="sheet-close"
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
  Drive.click handle "[data-slot=sheet-content] > button";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=sheet-footer] button";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=sheet-overlay]";
  summary ();
  [%expect {| open: false |}]
;;
