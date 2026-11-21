open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts card =
  [ Hover_card.trigger card (Button.view ~variant:Link [ Node.text "@nextjs" ])
  ; Hover_card.content
      card
      ~class_:"w-80"
      [ Node.h4 [ Node.text "@nextjs" ]
      ; Node.p
          [ Node.text "The React Framework – created and maintained by @vercel."
          ]
      ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Node.div
       [ Hover_card.view
           ~id:"h"
           ~open_:true
           ~on_open_change:(fun _ -> Bonsai_web.Effect.Ignore)
           parts
       ]);
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="h-trigger"
              data-state="open"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:underline inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shrink-0 text-primary text-sm transition-all underline-offset-4 whitespace-nowrap"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <div loon-dismiss=((h-trigger)false false) loon-presence=() style={ display: contents; }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element h-trigger))(name hover-card)))
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
          <div data-slot="hover-card-content"
               data-state="open"
               data-side="bottom"
               data-align="center"
               class="bg-popover border data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:zoom-out-95 data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 origin-(--radix-hover-card-content-transform-origin) outline-hidden p-4 rounded-md shadow-md text-popover-foreground w-80 z-50"
               @on_mouseenter
               @on_mouseleave>
            <h4> @nextjs </h4>
            <p> The React Framework – created and maintained by @vercel. </p>
          </div>
        </div>
      </div>
    </div>
    |}]
;;

(* Outside a browser the delays are skipped. *)
let%expect_test "the pointer on the trigger or focus opens it; blur closes it" =
  let handle =
    Render.handle ~classes:false (fun graph ->
      Bonsai_web.Bonsai.map
        (Hover_card.component (Bonsai_web.Bonsai.return parts) graph)
        ~f:(fun n -> Node.div [ n ]))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="closed"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Handle.mouseenter
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=hover-card-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="open"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name hover-card)))
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
          <div data-slot="hover-card-content"
               data-state="open"
               data-side="bottom"
               data-align="center"
               @on_mouseenter
               @on_mouseleave>
            <h4> @nextjs </h4>
            <p> The React Framework – created and maintained by @vercel. </p>
          </div>
        </div>
      </div>
    </div>
    |}];
  Handle.mouseenter
    handle
    ~get_vdom:Fn.id
    ~selector:"[data-slot=hover-card-content]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="open"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name hover-card)))
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
          <div data-slot="hover-card-content"
               data-state="open"
               data-side="bottom"
               data-align="center"
               @on_mouseenter
               @on_mouseleave>
            <h4> @nextjs </h4>
            <p> The React Framework – created and maintained by @vercel. </p>
          </div>
        </div>
      </div>
    </div>
    |}];
  Handle.blur handle ~get_vdom:Fn.id ~selector:"[data-slot=hover-card-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="closed"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    |}];
  Handle.focus handle ~get_vdom:Fn.id ~selector:"[data-slot=hover-card-trigger]";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              data-slot="hover-card-trigger"
              data-variant="link"
              data-size="default"
              id="bonsai_path_replaced_in_test-trigger"
              data-state="open"
              @on_blur
              @on_focus
              @on_mouseenter
              @on_mouseleave> @nextjs </button>
      <div loon-dismiss=((bonsai_path_replaced_in_test-trigger)false false)
           loon-presence=()
           style={
             display: contents;
           }>
        <div data-radix-popper-content-wrapper=""
             popover="manual"
             loon-popper=(Popper((side Bottom)(side_offset 4)(align Center)(align_offset 0)(avoid_collisions true)(collision_padding 0)(anchor(Element bonsai_path_replaced_in_test-trigger))(name hover-card)))
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
          <div data-slot="hover-card-content"
               data-state="open"
               data-side="bottom"
               data-align="center"
               @on_mouseenter
               @on_mouseleave>
            <h4> @nextjs </h4>
            <p> The React Framework – created and maintained by @vercel. </p>
          </div>
        </div>
      </div>
    </div>
    |}]
;;
