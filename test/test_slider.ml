open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let%expect_test "the value is shown, and the track filled up to it" =
  let handle =
    Control_render.handle
      [%sexp_of: float]
      (Slider.component
         ~min:0.
         ~max:2.
         ~step:0.25
         ~default:0.5
         ~show_value:true)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: 0.5 </span>
      <div data-disabled="false" class="loon-slider" custom-css-vars=((--loon-slider-fill 25.00%))>
        <input type="range"
               min="0"
               max="2"
               step="0.25"
               aria-valuetext="0.50"
               class="loon-slider-input"
               #value="0.5"
               @on_input/>
        <output class="loon-slider-value"> 0.50 </output>
      </div>
    </div>
    |}];
  Handle.input_text handle ~get_vdom:Fn.id ~selector:"input" ~text:"1.75";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: 0.5 </span>
    +|  <span> value: 1.75 </span>
    -|  <div data-disabled="false" class="loon-slider" custom-css-vars=((--loon-slider-fill 25.00%))>
    +|  <div data-disabled="false" class="loon-slider" custom-css-vars=((--loon-slider-fill 87.50%))>
          <input type="range"
                 min="0"
                 max="2"
                 step="0.25"
    -|           aria-valuetext="0.50"
    +|           aria-valuetext="1.75"
                 class="loon-slider-input"
    -|           #value="0.5"
    +|           #value="1.75"
                 @on_input/>
    -|    <output class="loon-slider-value"> 0.50 </output>
    +|    <output class="loon-slider-value"> 1.75 </output>
        </div>
      </div>
    |}]
;;

let%expect_test "values outside the range are clamped; custom format" =
  Render.html
    (Slider.view
       ~value:150.
       ~show_value:true
       ~format:(fun v -> sprintf "%.0f%%" v)
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       ());
  [%expect
    {|
    <div data-disabled="false" class="loon-slider" custom-css-vars=((--loon-slider-fill 100.00%))>
      <input type="range"
             min="0"
             max="100"
             step="1"
             aria-valuetext="100%"
             class="loon-slider-input"
             #value="100"
             @on_input/>
      <output class="loon-slider-value"> 100% </output>
    </div>
    |}]
;;
