open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let trigger name attrs = Button.view ~attrs [ Vdom.Node.text name ]

let%expect_test "dialog: opens, closes with Escape, the close button and the scrim" =
  let handle =
    Render.handle
      (Dialog.component
         ~title:"Edit profile"
         ~description:"Make changes."
         ~trigger:(trigger "Edit")
         (Bonsai.return (fun ~close ->
            ( [ Vdom.Node.text "Body" ]
            , [ Button.view ~attrs:[ Vdom.Attr.id "done" ] ~on_click:close [ Vdom.Node.text "Done" ] ] ))))
  in
  Handle.show handle;
  [%expect {|
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect {|
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Edit </button>
      <div class="loon-dialog-root loon-modal" @on_keydown>
        <div aria-hidden="true" class="loon-scrim" @on_click> </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             role="dialog"
             aria-modal="true"
             aria-labelledby="loonbonsai_path_replaced_in_test-title"
             tabindex="-1"
             data-state="open"
             aria-describedby="loonbonsai_path_replaced_in_test-description"
             class="loon-dialog loon-dialog-md"
             always-focus-hook=()>
          <div class="loon-dialog-header">
            <h2 id="loonbonsai_path_replaced_in_test-title" class="loon-dialog-title"> Edit profile </h2>
            <p id="loonbonsai_path_replaced_in_test-description" class="loon-dialog-description"> Make changes. </p>
          </div>
          <div class="loon-dialog-body"> Body </div>
          <div class="loon-dialog-footer">
            <button id="done"
                    type="button"
                    class="loon-button loon-button-md loon-button-primary"
                    @on_click> Done </button>
          </div>
          <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
            <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-x">
              <path d="M18 6 6 18M6 6l12 12"> </path>
            </svg>
          </button>
        </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
      </div>
    </div>
    |}];
  Drive.key handle ".loon-modal" Escape;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key Escape))
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "button";
  Drive.click handle ".loon-dialog-close";
  Drive.click handle "button";
  Drive.click handle ".loon-scrim";
  Drive.click handle "button";
  Drive.click handle "#done";
  Handle.show handle;
  [%expect {|
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "alert dialog: the scrim does not close it; confirm runs the effect" =
  let handle =
    Render.handle
      (Alert_dialog.component
         ~danger:true
         ~confirm_label:"Delete"
         ~title:"Sure?"
         ~description:"It cannot be undone."
         ~trigger:(trigger "Delete")
         (Bonsai.return (Effect.of_thunk (fun () -> print_endline "deleted"))))
  in
  Drive.click handle "button";
  Handle.show handle;
  [%expect {|
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Delete </button>
      <div class="loon-alert-dialog-root loon-modal" @on_keydown>
        <div aria-hidden="true" class="loon-scrim"> </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
        <div id="loonbonsai_path_replaced_in_test-content"
             role="alertdialog"
             aria-modal="true"
             aria-labelledby="loonbonsai_path_replaced_in_test-title"
             tabindex="-1"
             data-state="open"
             aria-describedby="loonbonsai_path_replaced_in_test-description"
             class="loon-alert-dialog"
             always-focus-hook=()>
          <div class="loon-dialog-header">
            <h2 id="loonbonsai_path_replaced_in_test-title" class="loon-dialog-title"> Sure? </h2>
            <p id="loonbonsai_path_replaced_in_test-description" class="loon-dialog-description"> It cannot be undone. </p>
          </div>
          <div class="loon-dialog-footer">
            <button type="button"
                    class="loon-button loon-button-md loon-button-outline"
                    always-focus-hook=()
                    @on_click> Cancel </button>
            <button type="button" class="loon-button loon-button-danger loon-button-md" @on_click> Delete </button>
          </div>
        </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
      </div>
    </div>
    |}];
  (* The scrim has no click handler: only the buttons and Esc close it. *)
  Drive.click handle ".loon-button-danger";
  Handle.show handle;
  [%expect {|
    deleted
    <div class="loon-modal-anchor">
      <button id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              type="button"
              class="loon-button loon-button-md loon-button-primary"
              @on_click> Delete </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "sheet: sides" =
  List.iter Sheet.Side.all ~f:(fun side ->
    Render.html
      ~selector:".loon-sheet"
      (Sheet.view
         ~side
         ~keep_side_on_phones:(Sheet.Side.equal side Left)
         ~id:"s"
         ~open_:true
         ~on_change:(fun _ -> Effect.Ignore)
         ~title:"Filters"
         [ Vdom.Node.text "Body" ]));
  [%expect {|
    <div id="s-content"
         role="dialog"
         aria-modal="true"
         aria-labelledby="s-title"
         tabindex="-1"
         data-state="open"
         data-side="left"
         data-keep-side=""
         class="loon-sheet"
         always-focus-hook=()>
      <div aria-hidden="true" class="loon-sheet-handle"> </div>
      <div class="loon-dialog-header">
        <h2 id="s-title" class="loon-dialog-title"> Filters </h2>
      </div>
      <div class="loon-sheet-body"> Body </div>
      <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-x">
          <path d="M18 6 6 18M6 6l12 12"> </path>
        </svg>
      </button>
    </div>
    <div id="s-content"
         role="dialog"
         aria-modal="true"
         aria-labelledby="s-title"
         tabindex="-1"
         data-state="open"
         data-side="right"
         class="loon-sheet"
         always-focus-hook=()>
      <div aria-hidden="true" class="loon-sheet-handle"> </div>
      <div class="loon-dialog-header">
        <h2 id="s-title" class="loon-dialog-title"> Filters </h2>
      </div>
      <div class="loon-sheet-body"> Body </div>
      <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-x">
          <path d="M18 6 6 18M6 6l12 12"> </path>
        </svg>
      </button>
    </div>
    <div id="s-content"
         role="dialog"
         aria-modal="true"
         aria-labelledby="s-title"
         tabindex="-1"
         data-state="open"
         data-side="top"
         class="loon-sheet"
         always-focus-hook=()>
      <div aria-hidden="true" class="loon-sheet-handle"> </div>
      <div class="loon-dialog-header">
        <h2 id="s-title" class="loon-dialog-title"> Filters </h2>
      </div>
      <div class="loon-sheet-body"> Body </div>
      <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-x">
          <path d="M18 6 6 18M6 6l12 12"> </path>
        </svg>
      </button>
    </div>
    <div id="s-content"
         role="dialog"
         aria-modal="true"
         aria-labelledby="s-title"
         tabindex="-1"
         data-state="open"
         data-side="bottom"
         class="loon-sheet"
         always-focus-hook=()>
      <div aria-hidden="true" class="loon-sheet-handle"> </div>
      <div class="loon-dialog-header">
        <h2 id="s-title" class="loon-dialog-title"> Filters </h2>
      </div>
      <div class="loon-sheet-body"> Body </div>
      <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-x">
          <path d="M18 6 6 18M6 6l12 12"> </path>
        </svg>
      </button>
    </div>
    |}]
;;
