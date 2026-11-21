open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html
    (Slider.view
       ~class_:"w-[60%]"
       ~value:[ 50. ]
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       ());
  [%expect
    {|
    <span dir="ltr"
          data-orientation="horizontal"
          aria-disabled="false"
          data-slot="slider"
          class="data-[disabled]:opacity-50 data-[orientation=vertical]:flex-col data-[orientation=vertical]:h-full data-[orientation=vertical]:min-h-44 data-[orientation=vertical]:w-auto flex items-center relative select-none touch-none w-[60%]"
          @on_pointerdown
          @on_pointermove
          @on_pointerup
          style={
            --radix-slider-thumb-transform: translateX(-50%);
          }>
      <span data-orientation="horizontal"
            data-slot="slider-track"
            class="bg-muted data-[orientation=horizontal]:h-1.5 data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-1.5 grow overflow-hidden relative rounded-full">
        <span data-orientation="horizontal"
              data-slot="slider-range"
              class="absolute bg-primary data-[orientation=horizontal]:h-full data-[orientation=vertical]:w-full"
              style={
                left: 0%;
                right: 50%;
              }> </span>
      </span>
      <span style={
              transform: var(--radix-slider-thumb-transform);
              position: absolute;
              left: calc(50% + 0px);
            }>
        <span role="slider"
              aria-valuemin="0"
              aria-valuemax="100"
              aria-orientation="horizontal"
              data-orientation="horizontal"
              data-slot="slider-thumb"
              aria-valuenow="50"
              tabindex="0"
              class="bg-white block border border-primary disabled:opacity-50 disabled:pointer-events-none focus-visible:outline-hidden focus-visible:ring-4 hover:ring-4 ring-ring/50 rounded-full shadow-sm shrink-0 size-4 transition-[color,box-shadow]"
              @on_keydown> </span>
      </span>
    </span>
    |}]
;;

let slider
      ?min
      ?max
      ?step
      ?min_steps_between_thumbs
      ?orientation
      ?disabled
      default_value
  =
  Control_render.handle
    [%sexp_of: float list]
    (Slider.component
       ?min
       ?max
       ?step
       ?min_steps_between_thumbs
       ?orientation
       ?disabled
       ~default_value)
;;

let value handle =
  Render.html ~classes:false ~selector:"output" (Handle.last_result handle)
;;

let%expect_test "one thumb, no classes" =
  let handle = slider [ 50. ] in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span dir="ltr"
            data-orientation="horizontal"
            aria-disabled="false"
            data-slot="slider"
            @on_pointerdown
            @on_pointermove
            @on_pointerup
            style={
              --radix-slider-thumb-transform: translateX(-50%);
            }>
        <span data-orientation="horizontal" data-slot="slider-track">
          <span data-orientation="horizontal" data-slot="slider-range" style={ left: 0%; right: 50%; }> </span>
        </span>
        <span style={
                transform: var(--radix-slider-thumb-transform);
                position: absolute;
                left: calc(50% + 0px);
              }>
          <span role="slider"
                aria-valuemin="0"
                aria-valuemax="100"
                aria-orientation="horizontal"
                data-orientation="horizontal"
                data-slot="slider-thumb"
                aria-valuenow="50"
                tabindex="0"
                @on_keydown> </span>
        </span>
      </span>
      <output> (50) </output>
    </div>
    |}]
;;

let%expect_test
    "keys: arrows step, Shift and Page Up/Down by ten, Home and End; clamped"
  =
  let handle = slider ~step:5. [ 50. ] in
  let press ?shift key =
    Handle.keydown
      handle
      ~get_vdom:Fn.id
      ?shift_key_down:shift
      ~selector:"[role=slider]"
      ~key;
    Handle.recompute_view handle;
    value handle
  in
  press ArrowRight;
  press ArrowUp;
  press ArrowLeft;
  press ArrowDown;
  press ~shift:true ArrowRight;
  press PageDown;
  press PageUp;
  press End;
  press ArrowRight;
  press Home;
  press ArrowLeft;
  press ~shift:true ArrowLeft;
  press KeyA;
  [%expect
    {|
    ("default prevented" (key ArrowRight))
    <output> (55) </output>
    ("default prevented" (key ArrowUp))
    <output> (60) </output>
    ("default prevented" (key ArrowLeft))
    <output> (55) </output>
    ("default prevented" (key ArrowDown))
    <output> (50) </output>
    ("default prevented" (key ArrowRight))
    <output> (100) </output>
    ("default prevented" (key PageDown))
    <output> (50) </output>
    ("default prevented" (key PageUp))
    <output> (100) </output>
    ("default prevented" (key End))
    <output> (100) </output>
    ("default prevented" (key ArrowRight))
    <output> (100) </output>
    ("default prevented" (key Home))
    <output> (0) </output>
    ("default prevented" (key ArrowLeft))
    <output> (0) </output>
    ("default prevented" (key ArrowLeft))
    <output> (0) </output>
    <output> (0) </output>
    |}]
;;

let%expect_test "a range: thumbs are labelled, and the range spans them" =
  let handle = slider [ 25.; 75. ] in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span dir="ltr"
            data-orientation="horizontal"
            aria-disabled="false"
            data-slot="slider"
            @on_pointerdown
            @on_pointermove
            @on_pointerup
            style={
              --radix-slider-thumb-transform: translateX(-50%);
            }>
        <span data-orientation="horizontal" data-slot="slider-track">
          <span data-orientation="horizontal"
                data-slot="slider-range"
                style={
                  left: 25%;
                  right: 25%;
                }> </span>
        </span>
        <span style={
                transform: var(--radix-slider-thumb-transform);
                position: absolute;
                left: calc(25% + 4px);
              }>
          <span role="slider"
                aria-valuemin="0"
                aria-valuemax="100"
                aria-orientation="horizontal"
                data-orientation="horizontal"
                data-slot="slider-thumb"
                aria-valuenow="25"
                aria-label="Minimum"
                tabindex="0"
                @on_keydown> </span>
        </span>
        <span style={
                transform: var(--radix-slider-thumb-transform);
                position: absolute;
                left: calc(75% + -4px);
              }>
          <span role="slider"
                aria-valuemin="0"
                aria-valuemax="100"
                aria-orientation="horizontal"
                data-orientation="horizontal"
                data-slot="slider-thumb"
                aria-valuenow="75"
                aria-label="Maximum"
                tabindex="0"
                @on_keydown> </span>
        </span>
      </span>
      <output> (25 75) </output>
    </div>
    |}]
;;

let%expect_test
    "multiple thumbs: labels, keys move each, and crossing thumbs swap"
  =
  let handle = slider ~step:10. [ 10.; 20.; 70. ] in
  let thumb i =
    sprintf "[data-slot=slider] > span:nth-child(%d) > [role=slider]" (i + 2)
  in
  let press i ?shift key =
    Handle.keydown
      handle
      ~get_vdom:Fn.id
      ?shift_key_down:shift
      ~selector:(thumb i)
      ~key;
    Handle.recompute_view handle;
    value handle
  in
  Render.html
    ~classes:false
    ~selector:"[role=slider]"
    (Handle.last_result handle);
  [%expect
    {|
    <span role="slider"
          aria-valuemin="0"
          aria-valuemax="100"
          aria-orientation="horizontal"
          data-orientation="horizontal"
          data-slot="slider-thumb"
          aria-valuenow="10"
          aria-label="Value 1 of 3"
          tabindex="0"
          @on_keydown> </span>
    <span role="slider"
          aria-valuemin="0"
          aria-valuemax="100"
          aria-orientation="horizontal"
          data-orientation="horizontal"
          data-slot="slider-thumb"
          aria-valuenow="20"
          aria-label="Value 2 of 3"
          tabindex="0"
          @on_keydown> </span>
    <span role="slider"
          aria-valuemin="0"
          aria-valuemax="100"
          aria-orientation="horizontal"
          data-orientation="horizontal"
          data-slot="slider-thumb"
          aria-valuenow="70"
          aria-label="Value 3 of 3"
          tabindex="0"
          @on_keydown> </span>
    |}];
  press 0 ArrowRight;
  (* 20, 20, 70: the first thumb meets the second. Further, they swap: *)
  press 0 ArrowRight;
  press 2 Home;
  press 1 End;
  [%expect
    {|
    ("default prevented" (key ArrowRight))
    <output> (20 20 70) </output>
    ("default prevented" (key ArrowRight))
    <output> (20 30 70) </output>
    ("default prevented" (key Home))
    <output> (0 20 30) </output>
    ("default prevented" (key End))
    <output> (0 30 100) </output>
    |}]
;;

let%expect_test "min_steps_between_thumbs keeps thumbs apart" =
  let handle = slider ~step:10. ~min_steps_between_thumbs:1 [ 10.; 30. ] in
  let thumb i =
    sprintf "[data-slot=slider] > span:nth-child(%d) > [role=slider]" (i + 2)
  in
  let press i key =
    Handle.keydown handle ~get_vdom:Fn.id ~selector:(thumb i) ~key;
    Handle.recompute_view handle;
    value handle
  in
  press 0 ArrowRight;
  press 0 ArrowRight;
  press 1 ArrowLeft;
  [%expect
    {|
    ("default prevented" (key ArrowRight))
    <output> (20 30) </output>
    ("default prevented" (key ArrowRight))
    <output> (20 30) </output>
    ("default prevented" (key ArrowLeft))
    <output> (20 30) </output>
    |}]
;;

let%expect_test
    "update snaps to the step, clamps, sorts, and says where the thumb went"
  =
  let update values ~index ~value ?(min_steps_between_thumbs = 0) () =
    print_s
      [%sexp
        (Slider.update
           values
           ~index
           ~value
           ~min:0.
           ~max:1.
           ~step:0.1
           ~min_steps_between_thumbs
         : (float list * int) option)]
  in
  update [ 0.3; 0.7 ] ~index:0 ~value:0.44 ();
  update [ 0.3; 0.7 ] ~index:0 ~value:0.9 ();
  update [ 0.3; 0.7 ] ~index:1 ~value:(-3.) ();
  update [ 0.3; 0.7 ] ~index:1 ~value:7. ();
  update [ 0.3; 0.7 ] ~index:0 ~value:0.65 ~min_steps_between_thumbs:1 ();
  update [ 0.1 ] ~index:0 ~value:(0.1 +. 0.2) ();
  [%expect
    {|
    (((0.4 0.7) 0))
    (((0.7 0.9) 1))
    (((0 0.3) 0))
    (((0.3 1) 1))
    ()
    (((0.3) 0))
    |}]
;;

let%expect_test "vertical, with a min and max" =
  let handle = slider ~min:(-10.) ~max:10. ~orientation:Vertical [ 0. ] in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span dir="ltr"
            data-orientation="vertical"
            aria-disabled="false"
            data-slot="slider"
            @on_pointerdown
            @on_pointermove
            @on_pointerup
            style={
              --radix-slider-thumb-transform: translateY(50%);
            }>
        <span data-orientation="vertical" data-slot="slider-track">
          <span data-orientation="vertical" data-slot="slider-range" style={ bottom: 0%; top: 50%; }> </span>
        </span>
        <span style={
                transform: var(--radix-slider-thumb-transform);
                position: absolute;
                bottom: calc(50% + 0px);
              }>
          <span role="slider"
                aria-valuemin="-10"
                aria-valuemax="10"
                aria-orientation="vertical"
                data-orientation="vertical"
                data-slot="slider-thumb"
                aria-valuenow="0"
                tabindex="0"
                @on_keydown> </span>
        </span>
      </span>
      <output> (0) </output>
    </div>
    |}];
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"[role=slider]" ~key:ArrowUp;
  Handle.recompute_view handle;
  value handle;
  [%expect
    {|
    ("default prevented" (key ArrowUp))
    <output> (1) </output>
    |}]
;;

let%expect_test "disabled: no tab stop, keys ignored" =
  let handle = slider ~disabled:true [ 50. ] in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span dir="ltr"
            data-orientation="horizontal"
            aria-disabled="true"
            data-disabled=""
            data-slot="slider"
            @on_pointerdown
            @on_pointermove
            @on_pointerup
            style={
              --radix-slider-thumb-transform: translateX(-50%);
            }>
        <span data-orientation="horizontal" data-slot="slider-track" data-disabled="">
          <span data-orientation="horizontal"
                data-disabled=""
                data-slot="slider-range"
                style={
                  left: 0%;
                  right: 50%;
                }> </span>
        </span>
        <span style={
                transform: var(--radix-slider-thumb-transform);
                position: absolute;
                left: calc(50% + 0px);
              }>
          <span role="slider"
                aria-valuemin="0"
                aria-valuemax="100"
                aria-orientation="horizontal"
                data-orientation="horizontal"
                data-slot="slider-thumb"
                aria-valuenow="50"
                data-disabled=""> </span>
        </span>
      </span>
      <output> (50) </output>
    </div>
    |}]
;;
