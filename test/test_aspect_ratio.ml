open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "a 16:9 box" =
  Render.html
    (Aspect_ratio.view ~ratio:(16. /. 9.) ~class_:"rounded-lg bg-muted" [ Node.text "x" ]);
  Render.html ~classes:false (Aspect_ratio.view [ Node.text "square" ]);
  [%expect {|
    <div data-radix-aspect-ratio-wrapper=""
         style={
           position: relative;
           width: 100%;
           padding-bottom: 56.25%;
         }>
      <div data-slot="aspect-ratio"
           class="bg-muted rounded-lg"
           style={
             position: absolute;
             top: 0;
             right: 0;
             bottom: 0;
             left: 0;
           }> x </div>
    </div>
    <div data-radix-aspect-ratio-wrapper=""
         style={
           position: relative;
           width: 100%;
           padding-bottom: 100%;
         }>
      <div data-slot="aspect-ratio"
           style={
             position: absolute;
             top: 0;
             right: 0;
             bottom: 0;
             left: 0;
           }> square </div>
    </div>
    |}]
;;
