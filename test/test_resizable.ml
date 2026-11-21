open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let children ?with_handle () =
  [ Resizable.panel ~default_size:25. [ Node.text "One" ]
  ; Resizable.handle ?with_handle ()
  ; Resizable.panel ~min_size:50. [ Node.text "Two" ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Resizable.view
       ~orientation:Horizontal
       ~class_:"rounded-lg border"
       ~layout:[]
       ~on_layout_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (children ~with_handle:true ()));
  [%expect {|
    <div data-slot="resizable-panel-group"
         data-group=""
         aria-orientation="horizontal"
         id="resizable"
         class="aria-[orientation=vertical]:flex-col border flex h-full rounded-lg w-full"
         style={
           height: 100%;
           width: 100%;
           overflow: hidden;
           display: flex;
           flex-direction: row;
           flex-wrap: nowrap;
           touch-action: pan-y;
         }>
      <div data-slot="resizable-panel"
           data-panel=""
           id="resizable-panel-0"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 25;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-y;
             }> One </div>
      </div>
      <div role="separator"
           id="resizable-handle-0"
           aria-orientation="vertical"
           data-slot="resizable-handle"
           data-separator="inactive"
           aria-controls="resizable-panel-0"
           aria-valuemax="50"
           aria-valuemin="0"
           aria-valuenow="25"
           tabindex="0"
           class="[&[aria-orientation=horizontal]>div]:rotate-90 after:-translate-x-1/2 after:absolute after:inset-y-0 after:left-1/2 after:w-1 aria-[orientation=horizontal]:after:-translate-y-1/2 aria-[orientation=horizontal]:after:h-1 aria-[orientation=horizontal]:after:left-0 aria-[orientation=horizontal]:after:translate-x-0 aria-[orientation=horizontal]:after:w-full aria-[orientation=horizontal]:h-px aria-[orientation=horizontal]:w-full bg-border flex focus-visible:outline-hidden focus-visible:ring-1 focus-visible:ring-offset-1 focus-visible:ring-ring items-center justify-center relative w-px"
           @on_blur
           @on_focus
           @on_keydown
           @on_pointerdown
           @on_pointerenter
           @on_pointerleave
           @on_pointermove
           @on_pointerup
           style={
             flex-basis: auto;
             cursor: ew-resize;
             flex-grow: 0;
             flex-shrink: 0;
             touch-action: none;
           }>
        <div class="bg-border border flex h-4 items-center justify-center rounded-xs w-3 z-10">
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
               class="lucide lucide-grip-vertical size-2.5">
            <circle cx="9" cy="12" r="1"> </circle>
            <circle cx="9" cy="5" r="1"> </circle>
            <circle cx="9" cy="19" r="1"> </circle>
            <circle cx="15" cy="12" r="1"> </circle>
            <circle cx="15" cy="5" r="1"> </circle>
            <circle cx="15" cy="19" r="1"> </circle>
          </svg>
        </div>
      </div>
      <div data-slot="resizable-panel"
           data-panel=""
           id="resizable-panel-1"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 75;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-y;
             }> Two </div>
      </div>
    </div>
    |}]
;;

let%expect_test "default layouts" =
  let show children = print_s [%sexp (Resizable.default_layout children : float list)] in
  show (children ());
  show [ Resizable.panel [] ; Resizable.handle (); Resizable.panel []; Resizable.handle (); Resizable.panel [] ];
  show [ Resizable.panel ~default_size:1. []; Resizable.panel ~default_size:3. [] ];
  show [ Resizable.panel ~max_size:20. []; Resizable.panel [] ];
  [%expect {|
    (25 75)
    (33.333333333333336 33.333333333333336 33.333333333333336)
    (25 75)
    (20 80)
    |}]
;;

let%expect_test "adjusting stops at the limits, cascading through the shrinking panels" =
  let children =
    [ Resizable.panel ~min_size:10. []
    ; Resizable.handle ()
    ; Resizable.panel ~min_size:20. []
    ; Resizable.handle ()
    ; Resizable.panel ~max_size:50. []
    ]
  in
  let layout = [ 30.; 30.; 40. ] in
  List.iter [ -5.; -100.; 5.; 100. ] ~f:(fun delta ->
    print_s
      [%sexp
        (delta : float), (Resizable.adjust children ~layout ~pivot:0 ~delta : float list)]);
  print_s [%sexp (Resizable.adjust children ~layout ~pivot:1 ~delta:(-100.) : float list)];
  [%expect {|
    (-5 (25 35 40))
    (-100 (10 50 40))
    (5 (35 25 40))
    (100 (80 20 0))
    (30 20 50)
    |}]
;;

let%expect_test "arrow keys, Home and End move the handle" =
  let handle =
    Render.handle
      ~classes:false
      (Resizable.component
         ~orientation:Horizontal
         (Bonsai_web.Bonsai.return (children ())))
  in
  Handle.show handle;
  [%expect {|
    <div data-slot="resizable-panel-group"
         data-group=""
         aria-orientation="horizontal"
         id="bonsai_path_replaced_in_test"
         style={
           height: 100%;
           width: 100%;
           overflow: hidden;
           display: flex;
           flex-direction: row;
           flex-wrap: nowrap;
           touch-action: pan-y;
         }>
      <div data-slot="resizable-panel"
           data-panel=""
           id="bonsai_path_replaced_in_test-panel-0"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 25;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-y;
             }> One </div>
      </div>
      <div role="separator"
           id="bonsai_path_replaced_in_test-handle-0"
           aria-orientation="vertical"
           data-slot="resizable-handle"
           data-separator="inactive"
           aria-controls="bonsai_path_replaced_in_test-panel-0"
           aria-valuemax="50"
           aria-valuemin="0"
           aria-valuenow="25"
           tabindex="0"
           @on_blur
           @on_focus
           @on_keydown
           @on_pointerdown
           @on_pointerenter
           @on_pointerleave
           @on_pointermove
           @on_pointerup
           style={
             flex-basis: auto;
             cursor: ew-resize;
             flex-grow: 0;
             flex-shrink: 0;
             touch-action: none;
           }> </div>
      <div data-slot="resizable-panel"
           data-panel=""
           id="bonsai_path_replaced_in_test-panel-1"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 75;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-y;
             }> Two </div>
      </div>
    </div>
    |}];
  Drive.key handle "[role=separator]" ArrowRight;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key ArrowRight))

             height: 100%;
             width: 100%;
             overflow: hidden;
             display: flex;
             flex-direction: row;
             flex-wrap: nowrap;
             touch-action: pan-y;
           }>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-0"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 25;
    +|         flex-grow: 30;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> One </div>
        </div>
        <div role="separator"
             id="bonsai_path_replaced_in_test-handle-0"
             aria-orientation="vertical"
             data-slot="resizable-handle"
             data-separator="inactive"
             aria-controls="bonsai_path_replaced_in_test-panel-0"
             aria-valuemax="50"
             aria-valuemin="0"
    -|       aria-valuenow="25"
    +|       aria-valuenow="30"
             tabindex="0"
             @on_blur
             @on_focus
             @on_keydown
             @on_pointerdown
             @on_pointerenter
             @on_pointerleave
             @on_pointermove
             @on_pointerup
             style={
               flex-basis: auto;
               cursor: ew-resize;
               flex-grow: 0;
               flex-shrink: 0;
               touch-action: none;
             }> </div>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-1"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 75;
    +|         flex-grow: 70;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> Two </div>
        </div>
      </div>
    |}];
  (* Up and down do nothing in a horizontal group. *)
  Drive.key handle "[role=separator]" ArrowDown;
  Handle.show_diff handle;
  [%expect {| ("default prevented" (key ArrowDown)) |}];
  Drive.key handle "[role=separator]" End;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key End))

             height: 100%;
             width: 100%;
             overflow: hidden;
             display: flex;
             flex-direction: row;
             flex-wrap: nowrap;
             touch-action: pan-y;
           }>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-0"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 30;
    +|         flex-grow: 50;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> One </div>
        </div>
        <div role="separator"
             id="bonsai_path_replaced_in_test-handle-0"
             aria-orientation="vertical"
             data-slot="resizable-handle"
             data-separator="inactive"
             aria-controls="bonsai_path_replaced_in_test-panel-0"
             aria-valuemax="50"
             aria-valuemin="0"
    -|       aria-valuenow="30"
    +|       aria-valuenow="50"
             tabindex="0"
             @on_blur
             @on_focus
             @on_keydown
             @on_pointerdown
             @on_pointerenter
             @on_pointerleave
             @on_pointermove
             @on_pointerup
             style={
               flex-basis: auto;
               cursor: ew-resize;
               flex-grow: 0;
               flex-shrink: 0;
               touch-action: none;
             }> </div>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-1"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 70;
    +|         flex-grow: 50;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> Two </div>
        </div>
      </div>
    |}];
  Drive.key handle "[role=separator]" Home;
  Handle.show_diff handle;
  [%expect {|
    ("default prevented" (key Home))

             height: 100%;
             width: 100%;
             overflow: hidden;
             display: flex;
             flex-direction: row;
             flex-wrap: nowrap;
             touch-action: pan-y;
           }>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-0"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 50;
    +|         flex-grow: 0;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> One </div>
        </div>
        <div role="separator"
             id="bonsai_path_replaced_in_test-handle-0"
             aria-orientation="vertical"
             data-slot="resizable-handle"
             data-separator="inactive"
             aria-controls="bonsai_path_replaced_in_test-panel-0"
             aria-valuemax="50"
             aria-valuemin="0"
    -|       aria-valuenow="50"
    +|       aria-valuenow="0"
             tabindex="0"
             @on_blur
             @on_focus
             @on_keydown
             @on_pointerdown
             @on_pointerenter
             @on_pointerleave
             @on_pointermove
             @on_pointerup
             style={
               flex-basis: auto;
               cursor: ew-resize;
               flex-grow: 0;
               flex-shrink: 0;
               touch-action: none;
             }> </div>
        <div data-slot="resizable-panel"
             data-panel=""
             id="bonsai_path_replaced_in_test-panel-1"
             style={
               display: flex;
               flex-basis: 0;
               flex-shrink: 1;
               overflow: visible;
    -|         flex-grow: 50;
    +|         flex-grow: 100;
             }>
          <div style={
                 max-height: 100%;
                 max-width: 100%;
                 flex-grow: 1;
                 overflow: auto;
                 touch-action: pan-y;
               }> Two </div>
        </div>
      </div>
    |}]
;;

let%expect_test "vertical groups use up and down" =
  let handle =
    Render.handle
      ~classes:false
      (Resizable.component
         ~orientation:Vertical
         (Bonsai_web.Bonsai.return
            [ Resizable.panel [ Node.text "Header" ]
            ; Resizable.handle ()
            ; Resizable.panel [ Node.text "Content" ]
            ; Resizable.handle ~disabled:true ()
            ; Resizable.panel [ Node.text "Footer" ]
            ]))
  in
  Drive.key handle "[role=separator]" ArrowUp;
  Handle.show handle;
  [%expect {|
    ("default prevented" (key ArrowUp))
    <div data-slot="resizable-panel-group"
         data-group=""
         aria-orientation="vertical"
         id="bonsai_path_replaced_in_test"
         style={
           height: 100%;
           width: 100%;
           overflow: hidden;
           display: flex;
           flex-direction: column;
           flex-wrap: nowrap;
           touch-action: pan-x;
         }>
      <div data-slot="resizable-panel"
           data-panel=""
           id="bonsai_path_replaced_in_test-panel-0"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 28.333;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-x;
             }> Header </div>
      </div>
      <div role="separator"
           id="bonsai_path_replaced_in_test-handle-0"
           aria-orientation="horizontal"
           data-slot="resizable-handle"
           data-separator="inactive"
           aria-controls="bonsai_path_replaced_in_test-panel-0"
           aria-valuemax="100"
           aria-valuemin="0"
           aria-valuenow="28.333"
           tabindex="0"
           @on_blur
           @on_focus
           @on_keydown
           @on_pointerdown
           @on_pointerenter
           @on_pointerleave
           @on_pointermove
           @on_pointerup
           style={
             flex-basis: auto;
             cursor: ns-resize;
             flex-grow: 0;
             flex-shrink: 0;
             touch-action: none;
           }> </div>
      <div data-slot="resizable-panel"
           data-panel=""
           id="bonsai_path_replaced_in_test-panel-1"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 38.333;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-x;
             }> Content </div>
      </div>
      <div role="separator"
           id="bonsai_path_replaced_in_test-handle-1"
           aria-orientation="horizontal"
           data-slot="resizable-handle"
           data-separator="disabled"
           aria-controls="bonsai_path_replaced_in_test-panel-1"
           aria-valuemax="71.667"
           aria-valuemin="0"
           aria-valuenow="38.333"
           aria-disabled="true"
           style={
             flex-basis: auto;
             cursor: not-allowed;
             flex-grow: 0;
             flex-shrink: 0;
             touch-action: none;
           }> </div>
      <div data-slot="resizable-panel"
           data-panel=""
           id="bonsai_path_replaced_in_test-panel-2"
           style={
             display: flex;
             flex-basis: 0;
             flex-shrink: 1;
             overflow: visible;
             flex-grow: 33.333;
           }>
        <div style={
               max-height: 100%;
               max-width: 100%;
               flex-grow: 1;
               overflow: auto;
               touch-action: pan-x;
             }> Footer </div>
      </div>
    </div>
    |}]
;;
