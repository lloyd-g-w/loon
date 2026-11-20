open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test "popover: toggles on its trigger, closes on Escape and when told" =
  let handle =
    Render.handle
      (Popover.component
         ~side:Right
         ~align:Center
         ~trigger:(fun attrs -> Button.view ~attrs [ Vdom.Node.text "Open" ])
         (Bonsai.return (fun ~close ->
            [ Popover.header ~description:"Details" "Title"
            ; Popover.footer
                [ Button.view ~attrs:[ Vdom.Attr.id "x" ] ~on_click:close [ Vdom.Node.text "Close" ]
                ]
            ])))
  in
  Handle.show handle;
  [%expect {|
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Open </button>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect {|
    <div data-state="open" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Open </button>
      <div aria-hidden="true" class="loon-click-away" @on_click> </div>
      <div id="loonbonsai_path_replaced_in_test-content"
           data-side="right"
           data-align="center"
           role="dialog"
           tabindex="-1"
           aria-labelledby="loonbonsai_path_replaced_in_test-trigger"
           class="loon-floating-content loon-popover"
           always-focus-hook=()
           loon-keep-in-view=()
           @on_keydown>
        <div class="loon-popover-header">
          <h4 class="loon-popover-title"> Title </h4>
          <p class="loon-popover-description"> Details </p>
        </div>
        <div class="loon-popover-footer">
          <button id="x"
                  type="button"
                  class="loon-button loon-button-md loon-button-primary"
                  @on_click> Close </button>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle ".loon-floating-content" Escape;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key Escape))
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Open </button>
    </div>
    |}];
  Drive.click handle "button";
  Drive.click handle "#x";
  Handle.show handle;
  [%expect {|
    <div data-state="closed" class="loon-floating">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Open </button>
    </div>
    |}]
;;

let%expect_test "tooltip" =
  Render.html
    (Tooltip.view ~side:Bottom ~id:"tip" ~content:"Copy" (fun attrs ->
       Button.view ~attrs ~size:Icon [ Icon.view Copy ]));
  [%expect {|
    <span data-side="bottom" class="loon-tooltip">
      <button aria-describedby="tip"
              type="button"
              class="loon-button loon-button-icon loon-button-primary">
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-copy">
          <path d="M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H10a1 1 0 0 1-1-1Z"> </path>
          <path d="M5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1"> </path>
        </svg>
      </button>
      <span role="tooltip" id="tip" class="loon-tooltip-content"> Copy </span>
    </span>
    |}]
;;
