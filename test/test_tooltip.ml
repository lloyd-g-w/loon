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
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"
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
               white-space: normal;
               text-align: start;
               font-weight: normal;
               font-style: normal;
               letter-spacing: normal;
               text-transform: none;
             }>
          <div data-slot="tooltip-content"
               id="t-content"
               data-state="delayed-open"
               data-side="top"
               data-align="center"
               class="bg-foreground cn-tooltip-content max-w-xs origin-(--radix-tooltip-content-transform-origin) text-background w-fit z-50"
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
                   class="bg-foreground cn-tooltip-arrow fill-foreground translate-y-[calc(-50%_-_2px)] z-50"
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
               white-space: normal;
               text-align: start;
               font-weight: normal;
               font-style: normal;
               letter-spacing: normal;
               text-transform: none;
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
               white-space: normal;
               text-align: start;
               font-weight: normal;
               font-style: normal;
               letter-spacing: normal;
               text-transform: none;
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
