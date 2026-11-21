open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html
    (Collapsible.view
       ~open_:true
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun c ->
          [ Collapsible.trigger c [ Node.text "Toggle" ]
          ; Collapsible.content c [ Node.text "Hidden" ]
          ]));
  [%expect
    {|
    <div data-state="open" data-slot="collapsible">
      <button type="button"
              aria-controls="collapsible-content"
              aria-expanded="true"
              data-state="open"
              data-slot="collapsible-trigger"
              @on_click> Toggle </button>
      <div data-state="open"
           id="collapsible-content"
           data-slot="collapsible-content"
           loon-collapsible-presence=true> Hidden </div>
    </div>
    |}]
;;

let%expect_test "the trigger opens and closes it; trigger_attrs on a Button" =
  let handle =
    Render.handle
      ~classes:false
      (Collapsible.component
         (Bonsai_web.Bonsai.return (fun c ->
            [ Button.view
                ~attrs:(Collapsible.trigger_attrs c)
                ~variant:Ghost
                [ Node.text "Toggle" ]
            ; Collapsible.content c [ Node.text "Hidden" ]
            ])))
  in
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" data-slot="collapsible">
      <button type="button"
              data-slot="button"
              data-variant="ghost"
              data-size="default"
              aria-controls="bonsai_path_replaced_in_test-content"
              aria-expanded="false"
              data-state="closed"
              @on_click> Toggle </button>
      <div data-state="closed"
           id="bonsai_path_replaced_in_test-content"
           hidden=""
           data-slot="collapsible-content"
           loon-collapsible-presence=false> Hidden </div>
    </div>
    |}];
  Drive.click handle "[aria-controls]";
  Handle.show_diff handle;
  [%expect
    {|
    -|<div data-state="closed" data-slot="collapsible">
    +|<div data-state="open" data-slot="collapsible">
        <button type="button"
                data-slot="button"
                data-variant="ghost"
                data-size="default"
                aria-controls="bonsai_path_replaced_in_test-content"
    -|          aria-expanded="false"
    +|          aria-expanded="true"
    -|          data-state="closed"
    +|          data-state="open"
                @on_click> Toggle </button>
    -|  <div data-state="closed"
    +|  <div data-state="open"
             id="bonsai_path_replaced_in_test-content"
    -|       hidden=""
             data-slot="collapsible-content"
    -|       loon-collapsible-presence=false> Hidden </div>
    +|       loon-collapsible-presence=true> Hidden </div>
      </div>
    |}];
  Drive.click handle "[aria-controls]";
  Handle.show_diff handle;
  [%expect
    {|
    -|<div data-state="open" data-slot="collapsible">
    +|<div data-state="closed" data-slot="collapsible">
        <button type="button"
                data-slot="button"
                data-variant="ghost"
                data-size="default"
                aria-controls="bonsai_path_replaced_in_test-content"
    -|          aria-expanded="true"
    +|          aria-expanded="false"
    -|          data-state="open"
    +|          data-state="closed"
                @on_click> Toggle </button>
    -|  <div data-state="open"
    +|  <div data-state="closed"
             id="bonsai_path_replaced_in_test-content"
    +|       hidden=""
             data-slot="collapsible-content"
    -|       loon-collapsible-presence=true> Hidden </div>
    +|       loon-collapsible-presence=false> Hidden </div>
      </div>
    |}]
;;

let%expect_test "disabled" =
  let handle =
    Render.handle
      ~classes:false
      (Collapsible.component
         ~disabled:true
         (Bonsai_web.Bonsai.return (fun c ->
            [ Collapsible.trigger c [ Node.text "Toggle" ]
            ; Collapsible.content c [ Node.text "Hidden" ]
            ])))
  in
  Handle.show handle;
  [%expect
    {|
    <div data-state="closed" data-slot="collapsible" data-disabled="">
      <button type="button"
              aria-controls="bonsai_path_replaced_in_test-content"
              aria-expanded="false"
              data-state="closed"
              data-disabled=""
              disabled=""
              data-slot="collapsible-trigger"> Toggle </button>
      <div data-state="closed"
           id="bonsai_path_replaced_in_test-content"
           data-disabled=""
           hidden=""
           data-slot="collapsible-content"
           loon-collapsible-presence=false> Hidden </div>
    </div>
    |}]
;;
