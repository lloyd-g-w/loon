open! Core
open Bonsai_web
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test
    "popover: toggles on its trigger, closes on Escape and when told"
  =
  let handle =
    Render.handle
      (Popover.component
         ~side:Right
         ~align:Center
         ~trigger:(fun attrs -> Button.view ~attrs [ Vdom.Node.text "Open" ])
         (Bonsai.return (fun ~close ->
            [ Popover.header ~description:"Details" "Title"
            ; Popover.footer
                [ Button.view
                    ~attrs:[ Vdom.Attr.id "x" ]
                    ~on_click:close
                    [ Vdom.Node.text "Close" ]
                ]
            ])))
  in
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" class="loon-floating">
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
              @on_click> Open </button>
    </div>
    |}];
  Drive.click handle "button";
  Handle.show handle;
  [%expect
    {|
    <div data-state="open" class="loon-floating">
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
          <button type="button"
                  data-slot="button"
                  data-variant="default"
                  data-size="default"
                  id="x"
                  class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"
                  @on_click> Close </button>
        </div>
      </div>
    </div>
    |}];
  Drive.key handle ".loon-floating-content" Escape;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Escape))
    <div data-state="closed" class="loon-floating">
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
              @on_click> Open </button>
    </div>
    |}];
  Drive.click handle "button";
  Drive.click handle "#x";
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" class="loon-floating">
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
              @on_click> Open </button>
    </div>
    |}]
;;

let%expect_test "tooltip" =
  Render.html
    (Tooltip.view ~side:Bottom ~id:"tip" ~content:"Copy" (fun attrs ->
       Button.view ~attrs ~size:Icon [ Icon.view Copy ]));
  [%expect
    {|
    <span data-side="bottom" class="loon-tooltip">
      <button type="button"
              data-slot="button"
              data-variant="default"
              data-size="icon"
              aria-describedby="tip"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 hover:bg-primary/90 inline-flex items-center justify-center outline-none rounded-md shrink-0 size-9 text-primary-foreground text-sm transition-all whitespace-nowrap">
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
             class="lucide lucide-copy">
          <rect width="14" height="14" x="8" y="8" rx="2" ry="2"> </rect>
          <path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"> </path>
        </svg>
      </button>
      <span role="tooltip" id="tip" class="loon-tooltip-content"> Copy </span>
    </span>
    |}]
;;
