open! Core
open Loon
module Handle = Bonsai_web_test.Handle

(* Expected values in the comments are what Recharts 3.8 and d3 compute for
   the same input (d3-shape's paths to 3 decimals, as d3-path's digits(3)). *)

let print_floats l = print_endline (String.concat ~sep:" " (List.map l ~f:Chart_scale.num))

let%expect_test "nice ticks, as Recharts' getNiceTickValues" =
  List.iter
    [ (0., 305.), 5, true
    ; (0., 1.), 5, true
    ; (-207., 214.), 5, true
    ; (0., 1260.), 5, false
    ; (0., 73.), 3, true
    ; (0., 0.6), 5, true
    ; (37., 37.), 5, true
    ]
    ~f:(fun (domain, count, allow_decimals) ->
      print_floats (Chart_scale.nice_ticks ~count ~allow_decimals domain));
  print_floats (Chart_scale.fixed_domain_ticks ~count:5 (0., 100.));
  (* Recharts: [0,80,160,240,320] [0,0.25,0.5,0.75,1] [-300,-150,0,150,300]
     [0,350,700,1050,1400] [0,40,80] [0,0.15,0.3,0.45,0.6] [35,36,37,38,39]
     [0,25,50,75,100] *)
  [%expect {|
    0 80 160 240 320
    0 0.25 0.5 0.75 1
    -300 -150 0 150 300
    0 350 700 1050 1400
    0 40 80
    0 0.15 0.3 0.45 0.6
    35 36 37 38 39
    0 25 50 75 100
    |}]
;;

let%expect_test "band and point scales, as d3's" =
  let b =
    Chart_scale.Band.create ~padding_inner:0.1 ~padding_outer:0.1 ~n:6 ~range:(12., 488.) ()
  in
  print_floats [ Chart_scale.Band.bandwidth b; Chart_scale.Band.step b ];
  print_floats (List.map [ 0; 1; 5 ] ~f:(Chart_scale.Band.apply b));
  let p = Chart_scale.Band.create ~point:true ~n:6 ~range:(12., 488.) () in
  print_floats (Chart_scale.Band.step p :: List.map [ 0; 1; 5 ] ~f:(Chart_scale.Band.apply p));
  print_s
    [%sexp
      (List.map [ 0.; 60.; 110.; 487. ] ~f:(Chart_scale.Band.index_at p) : int option list)];
  (* d3: bandwidth 70.22950819672131, step 78.0327868852459,
     [19.803278688524586, 97.83606557377048, 409.9672131147541];
     point: step 95.2, [12, 107.2, 488] *)
  [%expect {|
    70.22950819672131 78.0327868852459
    19.803278688524586 97.83606557377048 409.9672131147541
    95.2 12 107.2 488
    ((0) (1) (1) (5))
    |}]
;;

let%expect_test "linear scale" =
  let s = { Chart_scale.Linear.domain = 0., 320.; range = 250., 0. } in
  print_floats [ Chart_scale.Linear.apply s 186.; Chart_scale.Linear.invert s 125. ];
  [%expect {| 104.68749999999999 160 |}]
;;

let points = [ 0., 10.; 50., 80.; 100., 30.; 150., 60.; 200., 20. ]

let%expect_test "curves, as d3's" =
  List.iter Chart_path.Curve.all ~f:(fun curve ->
    printf "%s %s\n" (Chart_path.Curve.name curve) (Chart_path.line curve points));
  (* d3 (digits 3):
     linear     M0,10L50,80L100,30L150,60L200,20
     natural    M0,10C16.667,46.369,33.333,82.738,50,80C66.667,77.262,83.333,35.417,100,30
                C116.667,24.583,133.333,55.595,150,60C166.667,64.405,183.333,42.202,200,20
     monotoneX  M0,10C16.667,45,33.333,80,50,80C66.667,80,83.333,30,100,30C116.667,30,
                133.333,60,150,60C166.667,60,183.333,40,200,20
     step       M0,10L25,10L25,80L75,80L75,30L125,30L125,60L175,60L175,20L200,20
     stepBefore M0,10L0,80L50,80L50,30L100,30L100,60L150,60L150,20L200,20
     stepAfter  M0,10L50,10L50,80L100,80L100,30L150,30L150,60L200,60L200,20 *)
  [%expect {|
    linear M0,10L50,80L100,30L150,60L200,20
    natural M0,10C16.667,46.369,33.333,82.738,50,80C66.667,77.262,83.333,35.417,100,30C116.667,24.583,133.333,55.595,150,60C166.667,64.405,183.333,42.202,200,20
    monotone M0,10C16.667,45,33.333,80,50,80C66.667,80,83.333,30,100,30C116.667,30,133.333,60,150,60C166.667,60,183.333,40,200,20
    step M0,10L25,10L25,80L75,80L75,30L125,30L125,60L175,60L175,20L200,20
    stepBefore M0,10L0,80L50,80L50,30L100,30L100,60L150,60L150,20L200,20
    stepAfter M0,10L50,10L50,80L100,80L100,30L150,30L150,60L200,60L200,20
    bump M0,10C25,10,25,80,50,80C75,80,75,30,100,30C125,30,125,60,150,60C175,60,175,20,200,20
    linearClosed M0,10L50,80L100,30L150,60L200,20Z
    |}];
  print_endline
    (Chart_path.area Natural ~top:points ~base:(List.map points ~f:(fun (x, _) -> x, 100.)));
  [%expect {| M0,10C16.667,46.369,33.333,82.738,50,80C66.667,77.262,83.333,35.417,100,30C116.667,24.583,133.333,55.595,150,60C166.667,64.405,183.333,42.202,200,20L200,100C183.333,100,166.667,100,150,100C133.333,100,116.667,100,100,100C83.333,100,66.667,100,50,100C33.333,100,16.667,100,0,100Z |}]
;;

let%expect_test "Recharts' rectangle and sector paths" =
  print_endline
    (Chart_path.rectangle ~radius:(`All 4.) ~x:19.8 ~y:104.69 ~width:70.23 ~height:145.31 ());
  print_endline
    (Option.value_exn
       (Chart_path.sector
          ~cx:125.
          ~cy:125.
          ~inner_radius:60.
          ~outer_radius:80.
          ~start_angle:0.
          ~end_angle:90.
          ()));
  print_endline
    (Option.value_exn
       (Chart_path.sector
          ~corner_radius:5.
          ~cx:125.
          ~cy:125.
          ~inner_radius:80.
          ~outer_radius:110.
          ~start_angle:0.
          ~end_angle:180.
          ()));
  [%expect {|
    M 19.8,108.69
                A 4,4,0,0,1,23.8,104.69
                L 86.03,104.69
                A 4,4,0,0,1,90.03,108.69
                L 90.03,246
                A 4,4,0,0,1,86.03,250
                L 23.8,250
                A 4,4,0,0,1,19.8,246 Z
    M 205,125
        A 80,80,0,
        0,0,
        125,45
      L 125,65
                A 60,60,0,
                0,1,
                185,125 Z
    M 229.8809,125
        A5,5,0,0,0,234.8752,119.7619
        A110,110,0,0,0,15.1248,119.7619
        A5,5,0,0,0,20.1191,125
      L40.1472,125
          A5,5,0,0,0,45.1385,120.2941
          A80,80,0,0,1,204.8615,120.2941
          A5,5,0,0,0,209.8528,125Z
    |}]
;;

let data =
  List.map
    [ "January", 186., 80.; "February", 305., 200.; "March", 237., 120. ]
    ~f:(fun (month, desktop, mobile) ->
      [ "month", `Text month; "desktop", `Num desktop; "mobile", `Num mobile ])
;;

let config : Chart.Config.t =
  [ "desktop", Chart.Config.item ~label:"Desktop" ~color:"var(--chart-1)" ()
  ; "mobile", Chart.Config.item ~label:"Mobile" ~theme:("#2563eb", "#60a5fa") ()
  ]
;;

let bar_spec ?(tooltip = Chart.tooltip ~content:(Chart.tooltip_content ()) ()) () =
  Chart.bar_chart
    ~data
    [ Chart.cartesian_grid ~vertical:false ()
    ; Chart.x_axis
        ~data_key:"month"
        ~tick_line:false
        ~tick_margin:10.
        ~axis_line:false
        ~tick_formatter:(fun v -> String.prefix v 3)
        ()
    ; tooltip
    ; Chart.legend ~content:(Chart.legend_content ()) ()
    ; Chart.bar ~data_key:"desktop" ~fill:"var(--color-desktop)" ~radius:(`All 4.) ()
    ; Chart.bar ~data_key:"mobile" ~fill:"var(--color-mobile)" ~radius:(`All 4.) ()
    ]
;;

let%expect_test "shadcn's classes: the container, its style and a bar chart" =
  Render.html
    (Chart.container
       ~id:"bars"
       ~class_:"min-h-[200px] w-full"
       ~config
       (Chart.static ~width:300. ~height:200. ())
       (bar_spec ()));
  [%expect {|
    <div data-slot="chart"
         data-chart="chart-bars"
         class="[&_.recharts-cartesian-axis-tick_text]:fill-muted-foreground [&_.recharts-cartesian-grid_line[stroke='#ccc']]:stroke-border/50 [&_.recharts-curve.recharts-tooltip-cursor]:stroke-border [&_.recharts-dot[stroke='#fff']]:stroke-transparent [&_.recharts-layer]:outline-hidden [&_.recharts-polar-grid_[stroke='#ccc']]:stroke-border [&_.recharts-radial-bar-background-sector]:fill-muted [&_.recharts-rectangle.recharts-tooltip-cursor]:fill-muted [&_.recharts-reference-line_[stroke='#ccc']]:stroke-border [&_.recharts-sector[stroke='#fff']]:stroke-transparent [&_.recharts-sector]:outline-hidden [&_.recharts-surface]:outline-hidden aspect-video cn-chart flex justify-center min-h-[200px] text-xs w-full">
      <style>

     [data-chart=chart-bars] {
      --color-desktop: var(--chart-1);
      --color-mobile: #2563eb;
    }


    .dark [data-chart=chart-bars] {
      --color-desktop: var(--chart-1);
      --color-mobile: #60a5fa;
    }

      </style>
      <div class="recharts-responsive-container"
           loon-chart-size=<measure>
           style={
             width: 100%;
             height: 100%;
             min-width: 0;
           }>
        <div class="recharts-bar-chart recharts-wrapper"
             @on_mouseleave
             @on_mousemove
             style={
               position: relative;
               cursor: default;
               width: 300px;
               height: 200px;
             }>
          <svg role="application"
               tabindex="0"
               width="300"
               height="200"
               viewBox="0 0 300 200"
               class="recharts-surface"
               @on_blur
               @on_keydown
               style={
                 width: 100%;
                 height: 100%;
                 display: block;
               }>
            <g class="recharts-cartesian-grid">
              <g class="recharts-cartesian-grid-horizontal">
                <line stroke="#ccc"
                      fill="none"
                      x="5"
                      y="5"
                      width="290"
                      height="132"
                      x1="5"
                      y1="137"
                      x2="295"
                      y2="137"> </line>
                <line stroke="#ccc"
                      fill="none"
                      x="5"
                      y="5"
                      width="290"
                      height="132"
                      x1="5"
                      y1="104"
                      x2="295"
                      y2="104"> </line>
                <line stroke="#ccc"
                      fill="none"
                      x="5"
                      y="5"
                      width="290"
                      height="132"
                      x1="5"
                      y1="71"
                      x2="295"
                      y2="71"> </line>
                <line stroke="#ccc"
                      fill="none"
                      x="5"
                      y="5"
                      width="290"
                      height="132"
                      x1="5"
                      y1="38"
                      x2="295"
                      y2="38"> </line>
                <line stroke="#ccc"
                      fill="none"
                      x="5"
                      y="5"
                      width="290"
                      height="132"
                      x1="5"
                      y1="5"
                      x2="295"
                      y2="5"> </line>
              </g>
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            </g>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            <g class="recharts-bar recharts-layer">
              <g class="recharts-bar-rectangles recharts-layer">
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-desktop)"
                        x="14.6667"
                        y="60.275"
                        width="36"
                        height="76.725"
                        d="M 14.6667,64.275
                A 4,4,0,0,1,18.6667,60.275
                L 46.6667,60.275
                A 4,4,0,0,1,50.6667,64.275
                L 50.6667,133
                A 4,4,0,0,1,46.6667,137
                L 18.6667,137
                A 4,4,0,0,1,14.6667,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-desktop)"
                        x="111.3333"
                        y="11.1875"
                        width="36"
                        height="125.8125"
                        d="M 111.3333,15.1875
                A 4,4,0,0,1,115.3333,11.1875
                L 143.3333,11.1875
                A 4,4,0,0,1,147.3333,15.1875
                L 147.3333,133
                A 4,4,0,0,1,143.3333,137
                L 115.3333,137
                A 4,4,0,0,1,111.3333,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-desktop)"
                        x="208"
                        y="39.2375"
                        width="36"
                        height="97.7625"
                        d="M 208,43.2375
                A 4,4,0,0,1,212,39.2375
                L 240,39.2375
                A 4,4,0,0,1,244,43.2375
                L 244,133
                A 4,4,0,0,1,240,137
                L 212,137
                A 4,4,0,0,1,208,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
              </g>
            </g>
            <g class="recharts-bar recharts-layer">
              <g class="recharts-bar-rectangles recharts-layer">
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-mobile)"
                        x="54.6667"
                        y="104"
                        width="36"
                        height="33"
                        d="M 54.6667,108
                A 4,4,0,0,1,58.6667,104
                L 86.6667,104
                A 4,4,0,0,1,90.6667,108
                L 90.6667,133
                A 4,4,0,0,1,86.6667,137
                L 58.6667,137
                A 4,4,0,0,1,54.6667,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-mobile)"
                        x="151.3333"
                        y="54.5"
                        width="36"
                        height="82.5"
                        d="M 151.3333,58.5
                A 4,4,0,0,1,155.3333,54.5
                L 183.3333,54.5
                A 4,4,0,0,1,187.3333,58.5
                L 187.3333,133
                A 4,4,0,0,1,183.3333,137
                L 155.3333,137
                A 4,4,0,0,1,151.3333,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
                <g class="recharts-bar-rectangle recharts-layer">
                  <path fill="var(--color-mobile)"
                        x="248"
                        y="87.5"
                        width="36"
                        height="49.5"
                        d="M 248,91.5
                A 4,4,0,0,1,252,87.5
                L 280,87.5
                A 4,4,0,0,1,284,91.5
                L 284,133
                A 4,4,0,0,1,280,137
                L 252,137
                A 4,4,0,0,1,248,133 Z"
                        class="recharts-rectangle"> </path>
                </g>
              </g>
            </g>
            <g class="recharts-cartesian-axis recharts-layer recharts-xAxis xAxis">
              <Vdom.Node.none-widget> </Vdom.Node.none-widget>
              <g class="recharts-cartesian-axis-ticks">
                <g class="recharts-cartesian-axis-tick recharts-layer">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <text stroke="none"
                        x="53.333333333333336"
                        y="153"
                        text-anchor="middle"
                        fill="#666"
                        orientation="bottom"
                        width="290"
                        height="30"
                        class="recharts-cartesian-axis-tick-value recharts-text">
                    <tspan x="53.333333333333336" dy="0.71em"> Jan </tspan>
                  </text>
                </g>
                <g class="recharts-cartesian-axis-tick recharts-layer">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <text stroke="none"
                        x="150"
                        y="153"
                        text-anchor="middle"
                        fill="#666"
                        orientation="bottom"
                        width="290"
                        height="30"
                        class="recharts-cartesian-axis-tick-value recharts-text">
                    <tspan x="150" dy="0.71em"> Feb </tspan>
                  </text>
                </g>
                <g class="recharts-cartesian-axis-tick recharts-layer">
                  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                  <text stroke="none"
                        x="246.66666666666669"
                        y="153"
                        text-anchor="middle"
                        fill="#666"
                        orientation="bottom"
                        width="290"
                        height="30"
                        class="recharts-cartesian-axis-tick-value recharts-text">
                    <tspan x="246.66666666666669" dy="0.71em"> Mar </tspan>
                  </text>
                </g>
              </g>
            </g>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
            <Vdom.Node.none-widget> </Vdom.Node.none-widget>
          </svg>
          <div class="recharts-legend-wrapper"
               loon-chart-legend=<measure>
               style={
                 position: absolute;
                 width: 290px;
                 height: auto;
                 left: 5px;
                 bottom: 5px;
               }>
            <div class="flex gap-4 items-center justify-center pt-3">
              <div class="[&>svg]:h-3 [&>svg]:text-muted-foreground [&>svg]:w-3 flex gap-1.5 items-center">
                <div class="h-2 rounded-[2px] shrink-0 w-2"
                     style={
                       background-color: var(--color-desktop);
                     }> </div>
                Desktop
              </div>
              <div class="[&>svg]:h-3 [&>svg]:text-muted-foreground [&>svg]:w-3 flex gap-1.5 items-center">
                <div class="h-2 rounded-[2px] shrink-0 w-2"
                     style={
                       background-color: var(--color-mobile);
                     }> </div>
                Mobile
              </div>
            </div>
          </div>
          <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        </div>
      </div>
    </div>
    |}]
;;

let%expect_test "stacked and expanded areas" =
  Render.html
    ~classes:false
    ~selector:".recharts-area"
    (Chart.container
       ~config
       (Chart.static ~width:300. ~height:200. ())
       (Chart.area_chart
          ~data
          ~stack_offset:Expand
          [ Chart.area ~data_key:"mobile" ~type_:Linear ~stack_id:"a" ()
          ; Chart.area ~data_key:"desktop" ~type_:Linear ~stack_id:"a" ()
          ]));
  [%expect {|
    <g>
      <g>
        <path stroke-width="1"
              fill="#3182bd"
              stroke="none"
              d="M5,137.857L150,119.752L295,131.134L295,195L150,195L5,195Z"> </path>
        <path stroke-width="1" fill="none" stroke="#3182bd" d="M5,137.857L150,119.752L295,131.134"> </path>
      </g>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </g>
    <g>
      <g>
        <path stroke-width="1"
              fill="#3182bd"
              stroke="none"
              d="M5,5L150,5L295,5L295,131.134L150,119.752L5,137.857Z"> </path>
        <path stroke-width="1" fill="none" stroke="#3182bd" d="M5,5L150,5L295,5"> </path>
      </g>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </g>
    |}]
;;

let%expect_test "hovering shows the tooltip of the category under the pointer" =
  let handle =
    Render.handle (fun graph ->
      let chart = Chart.component graph in
      let%map.Bonsai chart in
      Chart.container ~config chart (bar_spec ()))
  in
  let show () =
    Handle.recompute_view handle;
    Render.html
      ~classes:false
      ~selector:".recharts-tooltip-wrapper"
      (Handle.last_result handle);
    Render.html
      ~classes:false
      ~selector:".recharts-tooltip-cursor"
      (Handle.last_result handle)
  in
  Handle.trigger_hook
    handle
    ~get_vdom:Fn.id
    ~selector:".recharts-responsive-container"
    ~name:"loon-chart-size"
    Chart.For_testing.measure_type_id
    (300., 200.);
  show ();
  [%expect {| |}];
  let move x =
    Handle.mousemove
      handle
      ~get_vdom:Fn.id
      ~selector:".recharts-wrapper"
      ~extra_event_fields:
        [ "clientX", Js_of_ocaml.Js.Unsafe.inject (Js_of_ocaml.Js.number_of_float x)
        ; "clientY", Js_of_ocaml.Js.Unsafe.inject (Js_of_ocaml.Js.number_of_float 50.)
        ]
  in
  move 150.;
  show ();
  [%expect {|
    <div tabindex="-1"
         loon-chart-tooltip=<measure>
         style={
           visibility: visible;
           pointer-events: none;
           position: absolute;
           top: 0px;
           left: 0px;
           transition: transform 400ms ease;
           transform: translate(160px, 60px);
         }>
      <div>
        <div> February </div>
        <div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-desktop)")(--color-border"var(--color-desktop)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Desktop </span>
              </div>
              <span> 305 </span>
            </div>
          </div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-mobile)")(--color-border"var(--color-mobile)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Mobile </span>
              </div>
              <span> 200 </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <path fill="#ccc"
          x="101.6667"
          y="5.5"
          width="96.6667"
          height="131"
          d="M 101.6667,5.5 h 96.6667 v 131 h -96.6667 Z"
          stroke="none"
          pointer-events="none"> </path>
    |}];
  move 20.;
  show ();
  [%expect {|
    <div tabindex="-1"
         loon-chart-tooltip=<measure>
         style={
           visibility: visible;
           pointer-events: none;
           position: absolute;
           top: 0px;
           left: 0px;
           transition: transform 400ms ease;
           transform: translate(30px, 60px);
         }>
      <div>
        <div> January </div>
        <div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-desktop)")(--color-border"var(--color-desktop)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Desktop </span>
              </div>
              <span> 186 </span>
            </div>
          </div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-mobile)")(--color-border"var(--color-mobile)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Mobile </span>
              </div>
              <span> 80 </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    <path fill="#ccc"
          x="5"
          y="5.5"
          width="96.6667"
          height="131"
          d="M 5,5.5 h 96.6667 v 131 h -96.6667 Z"
          stroke="none"
          pointer-events="none"> </path>
    |}]
;;

let%expect_test "tooltip content: indicators, hidden label, formatters" =
  let show content =
    Render.html
      ~classes:false
      ~selector:".recharts-tooltip-wrapper"
      (Chart.container
         ~config
         (Chart.static ~width:300. ~height:200. ())
         (bar_spec ~tooltip:(Chart.tooltip ~default_index:1 ~content ()) ()))
  in
  show (Chart.tooltip_content ~indicator:Line ~hide_label:true ());
  [%expect {|
    <div tabindex="-1"
         loon-chart-tooltip=<measure>
         style={
           visibility: visible;
           pointer-events: none;
           position: absolute;
           top: 0px;
           left: 0px;
           transition: transform 400ms ease;
           transform: translate(160px, 5px);
         }>
      <div>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        <div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-desktop)")(--color-border"var(--color-desktop)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Desktop </span>
              </div>
              <span> 305 </span>
            </div>
          </div>
          <div>
            <div custom-css-vars=((--color-bg"var(--color-mobile)")(--color-border"var(--color-mobile)"))> </div>
            <div>
              <div>
                <Vdom.Node.none-widget> </Vdom.Node.none-widget>
                <span> Mobile </span>
              </div>
              <span> 200 </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    |}];
  show
    (Chart.tooltip_content
       ~indicator:Dashed
       ~label_formatter:(fun label _ -> [ Virtual_dom.Vdom.Node.text ("Month: " ^ label) ])
       ~formatter:(fun item _ ->
         [ Virtual_dom.Vdom.Node.text
             (item.name ^ " = " ^ Option.value_map item.value ~default:"" ~f:Chart.Value.to_string)
         ])
       ());
  [%expect {|
    <div tabindex="-1"
         loon-chart-tooltip=<measure>
         style={
           visibility: visible;
           pointer-events: none;
           position: absolute;
           top: 0px;
           left: 0px;
           transition: transform 400ms ease;
           transform: translate(160px, 5px);
         }>
      <div>
        <div> Month: February </div>
        <div>
          <div> desktop = 305 </div>
          <div> mobile = 200 </div>
        </div>
      </div>
    </div>
    |}]
;;
