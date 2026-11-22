open! Core
open Loon

let%expect_test "shadcn's classes" =
  Render.html (Progress.view ~value:13. ());
  [%expect {|
    <div aria-valuemax="100"
         aria-valuemin="0"
         aria-valuenow="13"
         aria-valuetext="13%"
         role="progressbar"
         data-state="loading"
         data-value="13"
         data-max="100"
         data-slot="progress"
         class="cn-progress flex items-center overflow-x-hidden relative w-full">
      <div data-state="loading"
           data-value="13"
           data-max="100"
           data-slot="progress-indicator"
           class="cn-progress-indicator flex-1 size-full transition-all"
           style={
             transform: translateX(-87%);
           }> </div>
    </div>
    |}]
;;

let%expect_test "complete, out of another max, indeterminate" =
  Render.html ~classes:false (Progress.view ~value:100. ());
  Render.html ~classes:false (Progress.view ~max:4. ~value:1. ());
  Render.html ~classes:false (Progress.view ());
  [%expect {|
    <div aria-valuemax="100"
         aria-valuemin="0"
         aria-valuenow="100"
         aria-valuetext="100%"
         role="progressbar"
         data-state="complete"
         data-value="100"
         data-max="100"
         data-slot="progress">
      <div data-state="complete"
           data-value="100"
           data-max="100"
           data-slot="progress-indicator"
           style={
             transform: translateX(-0%);
           }> </div>
    </div>
    <div aria-valuemax="4"
         aria-valuemin="0"
         aria-valuenow="1"
         aria-valuetext="25%"
         role="progressbar"
         data-state="loading"
         data-value="1"
         data-max="4"
         data-slot="progress">
      <div data-state="loading"
           data-value="1"
           data-max="4"
           data-slot="progress-indicator"
           style={
             transform: translateX(-99%);
           }> </div>
    </div>
    <div aria-valuemax="100"
         aria-valuemin="0"
         role="progressbar"
         data-state="indeterminate"
         data-max="100"
         data-slot="progress">
      <div data-state="indeterminate"
           data-max="100"
           data-slot="progress-indicator"
           style={
             transform: translateX(-100%);
           }> </div>
    </div>
    |}]
;;
