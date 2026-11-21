open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let trigger name attrs = Button.view ~attrs [ Vdom.Node.text name ]

let%expect_test
    "dialog: opens, closes with Escape, the close button and the scrim"
  =
  let handle =
    Render.handle
      (Dialog.component
         ~title:"Edit profile"
         ~description:"Make changes."
         ~trigger:(trigger "Edit")
         (Bonsai.return (fun ~close ->
            ( [ Vdom.Node.text "Body" ]
            , [ Button.view
                  ~attrs:[ Vdom.Attr.id "done" ]
                  ~on_click:close
                  [ Vdom.Node.text "Done" ]
              ] ))))
  in
  Handle.show handle;
  [%expect
    {|
    <div class="loon-modal-anchor">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="default"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
              @on_click> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div class="loon-modal-anchor">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="default"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
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
            <button type="button"
                    data-slot="button"
                    data-variant="default"
                    data-size="default"
                    id="done"
                    class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
                    @on_click> Done </button>
          </div>
          <button type="button" aria-label="Close" class="loon-dialog-close" @on_click>
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true"
                 class="lucide lucide-x">
              <path d="M18 6 6 18"> </path>
              <path d="m6 6 12 12"> </path>
            </svg>
          </button>
        </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
      </div>
    </div>
    |}];
  Drive.key handle ".loon-modal" Escape;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Escape))
    <div class="loon-modal-anchor">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="default"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
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
  [%expect
    {|
    <div class="loon-modal-anchor">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="default"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="closed"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
              @on_click> Edit </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test
    "alert dialog: the scrim does not close it; confirm runs the effect"
  =
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
  [%expect
    {|
    <div class="loon-modal-anchor">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="default"
              id="loonbonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="loonbonsai_path_replaced_in_test-content"
              data-state="open"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
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
                    data-slot="button"
                    data-variant="outline"
                    data-size="default"
                    class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
                    always-focus-hook=()
                    @on_click> Cancel </button>
            <button type="button"
                    data-slot="button"
                    data-variant="destructive"
                    data-size="default"
                    class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-destructive dark:aria-invalid:ring-destructive/40 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-destructive/20 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-destructive/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-sm text-white transition-all whitespace-nowrap"
                    @on_click> Delete </button>
          </div>
        </div>
        <div tabindex="0" aria-hidden="true" class="loon-focus-guard" @on_focus> </div>
      </div>
    </div>
    |}];
  (* The scrim has no click handler: only the buttons and Esc close it. *)
  Drive.click handle ".loon-button-danger";
  Handle.show handle;
  [%expect.unreachable]
[@@expect.uncaught_exn {|
  ("Failed to find element matching selector" (selector .loon-button-danger)
    (from_node
       "<div class=\"loon-modal-anchor\">\
      \n  <button type=\"button\"\
      \n          data-slot=\"button\"\
      \n          data-variant=\"default\"\
      \n          data-size=\"default\"\
      \n          id=\"loonbonsai_path_replaced_in_test-trigger\"\
      \n          aria-haspopup=\"dialog\"\
      \n          aria-expanded=\"true\"\
      \n          aria-controls=\"loonbonsai_path_replaced_in_test-content\"\
      \n          data-state=\"open\"\
      \n          class=\"[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap\"\
      \n          @on_click> Delete </button>\
      \n  <div class=\"loon-alert-dialog-root loon-modal\" @on_keydown>\
      \n    <div aria-hidden=\"true\" class=\"loon-scrim\"> </div>\
      \n    <div tabindex=\"0\" aria-hidden=\"true\" class=\"loon-focus-guard\" @on_focus> </div>\
      \n    <div id=\"loonbonsai_path_replaced_in_test-content\"\
      \n         role=\"alertdialog\"\
      \n         aria-modal=\"true\"\
      \n         aria-labelledby=\"loonbonsai_path_replaced_in_test-title\"\
      \n         tabindex=\"-1\"\
      \n         data-state=\"open\"\
      \n         aria-describedby=\"loonbonsai_path_replaced_in_test-description\"\
      \n         class=\"loon-alert-dialog\"\
      \n         always-focus-hook=()>\
      \n      <div class=\"loon-dialog-header\">\
      \n        <h2 id=\"loonbonsai_path_replaced_in_test-title\" class=\"loon-dialog-title\"> Sure? </h2>\
      \n        <p id=\"loonbonsai_path_replaced_in_test-description\" class=\"loon-dialog-description\"> It cannot be undone. </p>\
      \n      </div>\
      \n      <div class=\"loon-dialog-footer\">\
      \n        <button type=\"button\"\
      \n                data-slot=\"button\"\
      \n                data-variant=\"outline\"\
      \n                data-size=\"default\"\
      \n                class=\"[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap\"\
      \n                always-focus-hook=()\
      \n                @on_click> Cancel </button>\
      \n        <button type=\"button\"\
      \n                data-slot=\"button\"\
      \n                data-variant=\"destructive\"\
      \n                data-size=\"default\"\
      \n                class=\"[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-destructive dark:aria-invalid:ring-destructive/40 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-destructive/20 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-destructive/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-sm text-white transition-all whitespace-nowrap\"\
      \n                @on_click> Delete </button>\
      \n      </div>\
      \n    </div>\
      \n    <div tabindex=\"0\" aria-hidden=\"true\" class=\"loon-focus-guard\" @on_focus> </div>\
      \n  </div>\
      \n</div>"))
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
  [%expect
    {|
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
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true"
             class="lucide lucide-x">
          <path d="M18 6 6 18"> </path>
          <path d="m6 6 12 12"> </path>
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
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true"
             class="lucide lucide-x">
          <path d="M18 6 6 18"> </path>
          <path d="m6 6 12 12"> </path>
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
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true"
             class="lucide lucide-x">
          <path d="M18 6 6 18"> </path>
          <path d="m6 6 12 12"> </path>
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
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true"
             class="lucide lucide-x">
          <path d="M18 6 6 18"> </path>
          <path d="m6 6 12 12"> </path>
        </svg>
      </button>
    </div>
    |}]
;;
