open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let ignore_ _ = Bonsai_web.Effect.Ignore
let wrap node = Node.div [ node ]

let parts drawer =
  [ Drawer.trigger
      drawer
      (Button.view ~variant:Outline [ Node.text "Open Drawer" ])
  ; Drawer.content
      drawer
      [ Drawer.header
          [ Drawer.title drawer [ Node.text "Move Goal" ]
          ; Drawer.description
              drawer
              [ Node.text "Set your daily activity goal." ]
          ]
      ; Drawer.footer
          [ Button.view [ Node.text "Submit" ]
          ; Drawer.close
              drawer
              (Button.view ~variant:Outline [ Node.text "Cancel" ])
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes, open from the bottom (with the handle)" =
  Render.html
    (wrap @@ Drawer.view ~id:"v" ~open_:true ~on_open_change:ignore_ parts);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="drawer-trigger"
              data-variant="outline"
              data-size="default"
              id="v-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="v-content"
              data-state="open"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
              @on_click> Open Drawer </button>
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
        <div data-slot="drawer-overlay"
             data-state="open"
             class="bg-black/50 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:animate-in data-[state=open]:fade-in-0 fixed inset-0 z-50"
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
             id="v-content"
             aria-describedby="v-description"
             aria-labelledby="v-title"
             data-state="open"
             tabindex="-1"
             data-slot="drawer-content"
             data-vaul-drawer-direction="bottom"
             class="bg-background data-[state=closed]:animate-out data-[state=closed]:slide-out-to-bottom data-[state=open]:animate-in data-[state=open]:slide-in-from-bottom data-[vaul-drawer-direction=bottom]:border-t data-[vaul-drawer-direction=bottom]:bottom-0 data-[vaul-drawer-direction=bottom]:inset-x-0 data-[vaul-drawer-direction=bottom]:max-h-[80vh] data-[vaul-drawer-direction=bottom]:mt-24 data-[vaul-drawer-direction=bottom]:rounded-t-lg data-[vaul-drawer-direction=left]:border-r data-[vaul-drawer-direction=left]:inset-y-0 data-[vaul-drawer-direction=left]:left-0 data-[vaul-drawer-direction=left]:sm:max-w-sm data-[vaul-drawer-direction=left]:w-3/4 data-[vaul-drawer-direction=right]:border-l data-[vaul-drawer-direction=right]:inset-y-0 data-[vaul-drawer-direction=right]:right-0 data-[vaul-drawer-direction=right]:sm:max-w-sm data-[vaul-drawer-direction=right]:w-3/4 data-[vaul-drawer-direction=top]:border-b data-[vaul-drawer-direction=top]:inset-x-0 data-[vaul-drawer-direction=top]:max-h-[80vh] data-[vaul-drawer-direction=top]:mb-24 data-[vaul-drawer-direction=top]:rounded-b-lg data-[vaul-drawer-direction=top]:top-0 duration-500 ease-[cubic-bezier(0.32,0.72,0,1)] fixed flex flex-col group/drawer-content h-auto z-50"
             loon-dismiss=(()false true)
             loon-drawer-drag=<close>
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
               touch-action: none;
             }>
          <div class="bg-muted group-data-[vaul-drawer-direction=bottom]/drawer-content:block h-2 hidden mt-4 mx-auto rounded-full shrink-0 w-[100px]"> </div>
          <div data-slot="drawer-header"
               class="flex flex-col gap-0.5 group-data-[vaul-drawer-direction=bottom]/drawer-content:text-center group-data-[vaul-drawer-direction=top]/drawer-content:text-center md:gap-1.5 md:text-left p-4">
            <h2 data-slot="drawer-title" id="v-title" class="font-semibold text-foreground"> Move Goal </h2>
            <p data-slot="drawer-description" id="v-description" class="text-muted-foreground text-sm"> Set your daily activity goal. </p>
          </div>
          <div data-slot="drawer-footer" class="flex flex-col gap-2 mt-auto p-4">
            <button type="button"
                    data-slot="button"
                    data-variant="default"
                    data-size="default"
                    class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-primary/90 inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary-foreground text-sm transition-all whitespace-nowrap"> Submit </button>
            <button type="button"
                    data-slot="drawer-close"
                    data-variant="outline"
                    data-size="default"
                    class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
                    @on_click> Cancel </button>
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

let%expect_test "from the right: no drag, the direction on the content" =
  Render.html
    ~classes:false
    ~selector:"[data-slot=drawer-content]"
    (wrap
     @@ Drawer.view
          ~id:"v"
          ~direction:Right
          ~open_:true
          ~on_open_change:ignore_
          parts);
  [%expect
    {|
    <div role="dialog"
         id="v-content"
         aria-describedby="v-description"
         aria-labelledby="v-title"
         data-state="open"
         tabindex="-1"
         data-slot="drawer-content"
         data-vaul-drawer-direction="right"
         loon-dismiss=(()false true)
         loon-focus-on-mount=First_tabbable
         loon-scroll-lock=()
         @on_keydown
         style={
           pointer-events: auto;
         }>
      <div> </div>
      <div data-slot="drawer-header">
        <h2 data-slot="drawer-title" id="v-title"> Move Goal </h2>
        <p data-slot="drawer-description" id="v-description"> Set your daily activity goal. </p>
      </div>
      <div data-slot="drawer-footer">
        <button type="button" data-slot="button" data-variant="default" data-size="default"> Submit </button>
        <button type="button"
                data-slot="drawer-close"
                data-variant="outline"
                data-size="default"
                @on_click> Cancel </button>
      </div>
    </div>
    |}]
;;

let component graph =
  Bonsai.map
    (Drawer.component (Bonsai.return parts) graph)
    ~f:(fun n -> Node.div [ n ])
;;

let%expect_test "the trigger opens it; Escape, Cancel and the overlay close it" =
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
              data-slot="drawer-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click> Open Drawer </button>
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
        <div data-slot="drawer-overlay" data-state="open" @on_click style={ pointer-events: auto; }> </div>
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
             data-slot="drawer-content"
             data-vaul-drawer-direction="bottom"
             loon-dismiss=(()false true)
             loon-drawer-drag=<close>
             loon-focus-on-mount=First_tabbable
             loon-scroll-lock=()
             @on_keydown
             style={
               pointer-events: auto;
               touch-action: none;
             }>
          <div> </div>
          <div data-slot="drawer-header">
            <h2 data-slot="drawer-title" id="bonsai_path_replaced_in_test-title"> Move Goal </h2>
            <p data-slot="drawer-description" id="bonsai_path_replaced_in_test-description"> Set your daily activity goal. </p>
          </div>
          <div data-slot="drawer-footer">
            <button type="button" data-slot="button" data-variant="default" data-size="default"> Submit </button>
            <button type="button"
                    data-slot="drawer-close"
                    data-variant="outline"
                    data-size="default"
                    @on_click> Cancel </button>
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
  Drive.key handle "[role=dialog]" Escape;
  summary ();
  [%expect
    {|
    ("default prevented" (key Escape))
    open: false
    |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=drawer-footer] [data-variant=outline]";
  summary ();
  [%expect {| open: false |}];
  opened ();
  [%expect {| open: true |}];
  Drive.click handle "[data-slot=drawer-overlay]";
  summary ();
  [%expect {| open: false |}]
;;
