open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts popover =
  [ Popover.trigger
      popover
      (Button.view ~variant:Outline [ Node.text "Open popover" ])
  ; Popover.content
      popover
      ~class_:"w-80"
      [ Popover.header
          [ Popover.title [ Node.text "Dimensions" ]
          ; Popover.description
              [ Node.text "Set the dimensions for the layer." ]
          ]
      ; Node.input ()
      ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Node.div
       [ Popover.view
           ~id:"p"
           ~open_:true
           ~on_open_change:(fun _ -> Bonsai_web.Effect.Ignore)
           parts
       ]);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              id="p-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="p-content"
              data-state="open"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
              @on_click> Open popover </button>
      <div loon-dismiss=((p-trigger)true false) loon-presence=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element p-trigger))(name popover)))
             style={
               inset: auto;
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
             }>
          <div data-slot="popover-content"
               id="p-content"
               role="dialog"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               class="bg-popover border data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 origin-(--radix-popover-content-transform-origin) outline-hidden p-4 rounded-md shadow-md text-popover-foreground w-80 z-50"
               loon-focus-on-mount=First_tabbable
               @on_keydown>
            <div data-slot="popover-header" class="flex flex-col gap-1 text-sm">
              <div data-slot="popover-title" class="font-medium"> Dimensions </div>
              <p data-slot="popover-description" class="text-muted-foreground"> Set the dimensions for the layer. </p>
            </div>
            <input/>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "the trigger toggles it; Esc closes it" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      Bonsai_web.Bonsai.map
        (Popover.component (Bonsai_web.Bonsai.return parts) graph)
        ~f:(fun n -> Node.div [ n ]))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="closed"
              @on_click> Open popover </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "[data-slot=popover-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="true"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="open"
              @on_click> Open popover </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)true false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name popover)))
             style={
               inset: auto;
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
             }>
          <div data-slot="popover-content"
               id="bonsai_path_replaced_in_test-content"
               role="dialog"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               loon-focus-on-mount=First_tabbable
               @on_keydown>
            <div data-slot="popover-header">
              <div data-slot="popover-title"> Dimensions </div>
              <p data-slot="popover-description"> Set the dimensions for the layer. </p>
            </div>
            <input/>
          </div>
        </div>
      </div>
    </div>
    |}];
  Drive.click handle "[data-slot=popover-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="closed"
              @on_click> Open popover </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Drive.click handle "[data-slot=popover-trigger]";
  Drive.key handle "[data-slot=popover-content]" Escape;
  Handle.show handle;
  [%expect
    {|
    ("default prevented" (key Escape))
    <div>
      <button type="button"
              data-slot="popover-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              aria-haspopup="dialog"
              aria-expanded="false"
              aria-controls="bonsai_path_replaced_in_test-content"
              data-state="closed"
              @on_click> Open popover </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}]
;;

let%expect_test "modal: focus guards around the content" =
  Render.html
    ~classes:false
    (Node.div
       [ Popover.view
           ~id:"p"
           ~modal:true
           ~open_:true
           ~on_open_change:(fun _ -> Bonsai_web.Effect.Ignore)
           (fun p -> [ Popover.content p [ Node.text "Hi" ] ])
       ]);
  [%expect
    {|
    <div>
      <div loon-dismiss=((p-trigger)false true) loon-presence=() style={ display: contents; }>
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
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element p-trigger))(name popover)))
             style={
               inset: auto;
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
             }>
          <div data-slot="popover-content"
               id="p-content"
               role="dialog"
               data-state="open"
               tabindex="-1"
               data-side="bottom"
               data-align="center"
               loon-focus-on-mount=First_tabbable
               @on_keydown> Hi </div>
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
