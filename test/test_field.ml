open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Attr = Virtual_dom.Vdom.Attr

let ignore_input (_ : string) = Bonsai_web.Effect.Ignore

let%expect_test "a label" =
  Render.html (Label.text ~for_:"name" "Name");
  Render.html (Label.text ~required:true "Email");
  [%expect
    {|
    <label for="name" class="loon-label"> Name </label>
    <label class="loon-label">
      Email
      <span aria-hidden="true" class="loon-label-required"> * </span>
    </label>
    |}]
;;

let%expect_test "a field wires its label, description and error to the control" =
  Render.html
    (Field.view
       ~id:"email"
       ~label:"Email"
       ~description:"We'll never share it."
       ~error:"Enter an email address."
       ~required:true
       (fun attrs ->
          Input.view ~attrs ~type_:Email ~value:"" ~on_input:ignore_input ()));
  [%expect
    {|
    <div data-invalid="true" class="loon-field loon-field-vertical">
      <label for="email" class="loon-label">
        Email
        <span aria-hidden="true" class="loon-label-required"> * </span>
      </label>
      <input id="email"
             aria-describedby="email-description email-error"
             aria-invalid="true"
             aria-required="true"
             type="email"
             class="loon-input"
             #value=""
             @on_input/>
      <p id="email-description" class="loon-field-description"> We'll never share it. </p>
      <p id="email-error" role="alert" class="loon-field-error">
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-alert-circle">
          <circle cx="12." cy="12." r="9.5"> </circle>
          <path d="M12 7.5v5M12 16h.01"> </path>
        </svg>
        Enter an email address.
      </p>
    </div>
    |}]
;;

let%expect_test "a field with only a label" =
  Render.html
    (Field.view ~id:"name" ~label:"Name" (fun attrs ->
       Input.view ~attrs ~value:"" ~on_input:ignore_input ()));
  [%expect
    {|
    <div class="loon-field loon-field-vertical">
      <label for="name" class="loon-label"> Name </label>
      <input id="name" type="text" class="loon-input" #value="" @on_input/>
    </div>
    |}]
;;

let%expect_test "a horizontal field (control first)" =
  Render.html
    (Field.view
       ~orientation:Horizontal
       ~id:"terms"
       ~label:"Accept the terms"
       ~description:"You agree to our Terms of Service."
       (fun attrs ->
          Checkbox.view
            ~attrs
            ~state:Unchecked
            ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
            ()));
  [%expect
    {|
    <div class="loon-field loon-field-horizontal">
      <button id="terms"
              aria-describedby="terms-description"
              type="button"
              role="checkbox"
              aria-checked="false"
              data-state="unchecked"
              class="loon-checkbox"
              @on_click> </button>
      <div class="loon-field-text">
        <label for="terms" class="loon-label"> Accept the terms </label>
        <p id="terms-description" class="loon-field-description"> You agree to our Terms of Service. </p>
      </div>
    </div>
    |}]
;;

let%expect_test "a fieldset" =
  Render.html
    (Field.set
       ~legend:"Notifications"
       ~description:"How we reach you."
       [ Node.text "fields" ]);
  [%expect
    {|
    <fieldset class="loon-fieldset">
      <legend class="loon-fieldset-legend"> Notifications </legend>
      <p class="loon-field-description"> How we reach you. </p>
      fields
    </fieldset>
    |}]
;;
