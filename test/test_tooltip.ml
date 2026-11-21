open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts tooltip =
  [ Tooltip.trigger tooltip (Button.view ~variant:Outline [ Node.text "Hover" ])
  ; Tooltip.content tooltip [ Node.p [ Node.text "Add to library" ] ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Node.div
       [ Tooltip.view
           ~id:"t"
           ~open_:true
           ~on_open_change:(fun _ -> Bonsai_web.Effect.Ignore)
           parts
       ]);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="tooltip-trigger"
              data-variant="outline"
              data-size="default"
              id="t-trigger"
              data-state="delayed-open"
              aria-describedby="t-tooltip"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"
              @on_blur
              @on_focus
              @on_mouseleave
              @on_mousemove
              @on_pointerdown> Hover </button>
      <div loon-dismiss=((t-trigger)false false) loon-presence=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Top)(side_offset 0)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element t-trigger))(name tooltip)))
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
             }>
          <div data-slot="tooltip-content"
               id="t-content"
               data-state="delayed-open"
               data-side="top"
               data-align="center"
               class="animate-in bg-foreground data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 fade-in-0 origin-(--radix-tooltip-content-transform-origin) px-3 py-1.5 rounded-md text-background text-balance text-xs w-fit z-50 zoom-in-95"
               @on_mouseleave>
            <p> Add to library </p>
            <span id="t-tooltip"
                  role="tooltip"
                  style="position:absolute;border:0;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;word-wrap:normal">
              <p> Add to library </p>
            </span>
            <span data-popper-arrow="" style={ position: absolute; }>
              <svg width="10"
                   height="5"
                   viewBox="0 0 30 10"
                   preserveAspectRatio="none"
                   class="bg-foreground fill-foreground rotate-45 rounded-[2px] size-2.5 translate-y-[calc(-50%_-_2px)] z-50"
                   style={
                     display: block;
                   }>
                <polygon points="0,0 30,0 15,10"> </polygon>
              </svg>
            </span>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "the pointer or focus opens it; blur closes it" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      Bonsai_web.Bonsai.map
        (Tooltip.component (Bonsai_web.Bonsai.return parts) graph)
        ~f:(fun n -> Node.div [ n ]))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="tooltip-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="closed"
              @on_blur
              @on_focus
              @on_mouseleave
              @on_mousemove
              @on_pointerdown> Hover </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Handle.mousemove
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=tooltip-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="tooltip-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="delayed-open"
              aria-describedby="bonsai_path_replaced_in_test-tooltip"
              @on_blur
              @on_focus
              @on_mouseleave
              @on_mousemove
              @on_pointerdown> Hover </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Top)(side_offset 0)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name tooltip)))
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
             }>
          <div data-slot="tooltip-content"
               id="bonsai_path_replaced_in_test-content"
               data-state="delayed-open"
               data-side="top"
               data-align="center"
               @on_mouseleave>
            <p> Add to library </p>
            <span id="bonsai_path_replaced_in_test-tooltip"
                  role="tooltip"
                  style="position:absolute;border:0;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;word-wrap:normal">
              <p> Add to library </p>
            </span>
            <span data-popper-arrow="" style={ position: absolute; }>
              <svg width="10"
                   height="5"
                   viewBox="0 0 30 10"
                   preserveAspectRatio="none"
                   style={
                     display: block;
                   }>
                <polygon points="0,0 30,0 15,10"> </polygon>
              </svg>
            </span>
          </div>
        </div>
      </div>
    </div>
    |}];
  Handle.blur handle ~get_vdom:Fn.id ~selector:"[data-slot=tooltip-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="tooltip-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="closed"
              @on_blur
              @on_focus
              @on_mouseleave
              @on_mousemove
              @on_pointerdown> Hover </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Handle.focus handle ~get_vdom:Fn.id ~selector:"[data-slot=tooltip-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="tooltip-trigger"
              data-variant="outline"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="delayed-open"
              aria-describedby="bonsai_path_replaced_in_test-tooltip"
              @on_blur
              @on_focus
              @on_mouseleave
              @on_mousemove
              @on_pointerdown> Hover </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Top)(side_offset 0)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name tooltip)))
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
             }>
          <div data-slot="tooltip-content"
               id="bonsai_path_replaced_in_test-content"
               data-state="delayed-open"
               data-side="top"
               data-align="center"
               @on_mouseleave>
            <p> Add to library </p>
            <span id="bonsai_path_replaced_in_test-tooltip"
                  role="tooltip"
                  style="position:absolute;border:0;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0, 0, 0, 0);white-space:nowrap;word-wrap:normal">
              <p> Add to library </p>
            </span>
            <span data-popper-arrow="" style={ position: absolute; }>
              <svg width="10"
                   height="5"
                   viewBox="0 0 30 10"
                   preserveAspectRatio="none"
                   style={
                     display: block;
                   }>
                <polygon points="0,0 30,0 15,10"> </polygon>
              </svg>
            </span>
          </div>
        </div>
      </div>
    </div>
    |}]
;;
