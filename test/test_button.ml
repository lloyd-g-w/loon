open! Core
open Loon

let%expect_test "variants and sizes" =
  List.iter Button.Variant.all ~f:(fun variant ->
    Render.html (Button.view ~variant [ Virtual_dom.Vdom.Node.text "Save" ]));
  [%expect {|
    <button type="button" class="loon-button loon-button-md loon-button-primary"> Save </button>
    <button type="button" class="loon-button loon-button-md loon-button-secondary"> Save </button>
    <button type="button" class="loon-button loon-button-md loon-button-outline"> Save </button>
    <button type="button" class="loon-button loon-button-ghost loon-button-md"> Save </button>
    <button type="button" class="loon-button loon-button-accent loon-button-md"> Save </button>
    <button type="button" class="loon-button loon-button-danger loon-button-md"> Save </button>
    <button type="button" class="loon-button loon-button-link loon-button-md"> Save </button>
    |}];
  Render.html (Button.view ~size:Icon ~loading:true [ Icon.view Plus ]);
  [%expect {|
    <button type="button"
            disabled=""
            aria-busy="true"
            class="loon-button loon-button-icon loon-button-primary">
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-loader loon-spin">
        <path d="M21 12a9 9 0 1 1-6.2-8.6"> </path>
      </svg>
    </button>
    |}];
  Render.html (Button.link ~variant:Outline ~href:"/docs" [ Virtual_dom.Vdom.Node.text "Docs" ]);
  [%expect {| <a href="/docs" class="loon-button loon-button-md loon-button-outline"> Docs </a> |}]
;;
