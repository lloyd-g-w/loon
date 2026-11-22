open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Field.set
       [ Field.legend [ Node.text "Profile" ]
       ; Field.description [ Node.text "About you." ]
       ; Field.group
           [ Field.root
               [ Field.label ~for_:"name" [ Node.text "Name" ]
               ; Input.view ~id:"name" ()
               ; Field.description [ Node.text "Your full name." ]
               ]
           ; Field.separator [ Node.text "Or" ]
           ; Field.root
               ~orientation:Horizontal
               [ Checkbox.view
                   ~id:"news"
                   ~checked:Unchecked
                   ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
                   ()
               ; Field.content
                   [ Field.title [ Node.text "Newsletter" ]
                   ; Field.description [ Node.text "Weekly." ]
                   ]
               ]
           ]
       ]);
  [%expect
    {|
    <fieldset data-slot="field-set" class="cn-field-set flex flex-col">
      <legend data-slot="field-legend" data-variant="legend" class="cn-field-legend"> Profile </legend>
      <p data-slot="field-description"
         class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 cn-field-description font-normal group-has-data-horizontal/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1"> About you. </p>
      <div data-slot="field-group"
           class="@container/field-group cn-field-group flex flex-col group/field-group w-full">
        <div role="group"
             data-slot="field"
             data-orientation="vertical"
             class="*:w-full [&>.sr-only]:w-auto cn-field cn-field-orientation-vertical flex flex-col group/field w-full">
          <label data-slot="field-label"
                 for="name"
                 class="cn-field-label cn-label flex group-data-[disabled=true]:pointer-events-none group/field-label has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:w-full items-center peer-disabled:cursor-not-allowed peer/field-label select-none w-fit"
                 @on_mousedown> Name </label>
          <input type="text"
                 data-slot="input"
                 id="name"
                 class="cn-input disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:inline-flex file:text-foreground min-w-0 outline-none placeholder:text-muted-foreground w-full"/>
          <p data-slot="field-description"
             class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 cn-field-description font-normal group-has-data-horizontal/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1"> Your full name. </p>
        </div>
        <div data-slot="field-separator" data-content="true" class="cn-field-separator relative">
          <div data-slot="separator"
               role="none"
               data-orientation="horizontal"
               class="absolute bg-border data-horizontal:h-px data-horizontal:w-full data-vertical:self-stretch data-vertical:w-px inset-0 shrink-0 top-1/2"> </div>
          <span data-slot="field-separator-content"
                class="bg-background block cn-field-separator-content mx-auto relative w-fit"> Or </span>
        </div>
        <div role="group"
             data-slot="field"
             data-orientation="horizontal"
             class="*:data-[slot=field-label]:flex-auto cn-field cn-field-orientation-horizontal flex flex-row group/field has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px has-[>[data-slot=field-content]]:items-start items-center w-full">
          <button type="button"
                  role="checkbox"
                  aria-checked="false"
                  data-state="unchecked"
                  data-slot="checkbox"
                  id="news"
                  class="after:-inset-x-3 after:-inset-y-2 after:absolute cn-checkbox disabled:cursor-not-allowed disabled:opacity-50 outline-none peer relative shrink-0"
                  #value="on"
                  @on_click
                  @on_keydown> </button>
          <div data-slot="field-content"
               class="cn-field-content flex flex-1 flex-col group/field-content leading-snug">
            <div data-slot="field-label" class="cn-field-title flex items-center w-fit"> Newsletter </div>
            <p data-slot="field-description"
               class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 cn-field-description font-normal group-has-data-horizontal/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1"> Weekly. </p>
          </div>
        </div>
      </div>
    </fieldset>
    |}]
;;

let%expect_test "orientations and variants" =
  List.iter Field.Orientation.all ~f:(fun orientation ->
    Render.html ~classes:false (Field.root ~orientation [ Node.text "x" ]));
  List.iter Field.Legend_variant.all ~f:(fun variant ->
    Render.html ~classes:false (Field.legend ~variant [ Node.text "x" ]));
  [%expect
    {|
    <div role="group" data-slot="field" data-orientation="vertical"> x </div>
    <div role="group" data-slot="field" data-orientation="horizontal"> x </div>
    <div role="group" data-slot="field" data-orientation="responsive"> x </div>
    <legend data-slot="field-legend" data-variant="legend"> x </legend>
    <legend data-slot="field-legend" data-variant="label"> x </legend>
    |}]
;;

let%expect_test "invalid and disabled fields" =
  Render.html
    ~classes:false
    (Field.root
       ~invalid:true
       ~disabled:true
       [ Field.label ~for_:"email" [ Node.text "Email" ]
       ; Input.view ~id:"email" ~invalid:true ()
       ; Field.error ~errors:[ "Enter an email." ] []
       ]);
  [%expect
    {|
    <div role="group"
         data-slot="field"
         data-orientation="vertical"
         data-invalid="true"
         data-disabled="true">
      <label data-slot="field-label" for="email" @on_mousedown> Email </label>
      <input type="text" data-slot="input" id="email" aria-invalid="true"/>
      <div role="alert" data-slot="field-error"> Enter an email. </div>
    </div>
    |}]
;;

let%expect_test "errors: none, one, several (duplicates dropped), children win" =
  let show node = Render.html ~classes:false (Node.div [ node ]) in
  show (Field.error []);
  show (Field.error ~errors:[] []);
  show (Field.error ~errors:[ "Too short."; "Too short." ] []);
  show (Field.error ~errors:[ "Too short."; "No digit."; "Too short." ] []);
  show (Field.error ~errors:[ "ignored" ] [ Node.text "Custom message" ]);
  [%expect
    {|
    <div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    <div>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </div>
    <div>
      <div role="alert" data-slot="field-error"> Too short. </div>
    </div>
    <div>
      <div role="alert" data-slot="field-error">
        <ul>
          <li> Too short. </li>
          <li> No digit. </li>
        </ul>
      </div>
    </div>
    <div>
      <div role="alert" data-slot="field-error"> Custom message </div>
    </div>
    |}]
;;

let%expect_test "separator without content" =
  Render.html ~classes:false (Field.separator []);
  [%expect
    {|
    <div data-slot="field-separator" data-content="false">
      <div data-slot="separator" role="none" data-orientation="horizontal"> </div>
    </div>
    |}]
;;
