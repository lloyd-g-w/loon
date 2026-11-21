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
    <fieldset data-slot="field-set"
              class="flex flex-col gap-6 has-[>[data-slot=checkbox-group]]:gap-3 has-[>[data-slot=radio-group]]:gap-3">
      <legend data-slot="field-legend"
              data-variant="legend"
              class="data-[variant=label]:text-sm data-[variant=legend]:text-base font-medium mb-3"> Profile </legend>
      <p data-slot="field-description"
         class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 [[data-variant=legend]+&]:-mt-1.5 font-normal group-has-[[data-orientation=horizontal]]/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1 text-muted-foreground text-sm"> About you. </p>
      <div data-slot="field-group"
           class="@container/field-group [&>[data-slot=field-group]]:gap-4 data-[slot=checkbox-group]:gap-3 flex flex-col gap-7 group/field-group w-full">
        <div role="group"
             data-slot="field"
             data-orientation="vertical"
             class="[&>*]:w-full [&>.sr-only]:w-auto data-[invalid=true]:text-destructive flex flex-col gap-3 group/field w-full">
          <label data-slot="field-label"
                 for="name"
                 class="[&>*]:data-[slot=field]:p-4 dark:has-data-[state=checked]:bg-primary/10 flex font-medium gap-2 group-data-[disabled=true]/field:opacity-50 group-data-[disabled=true]:opacity-50 group-data-[disabled=true]:pointer-events-none group/field-label has-[>[data-slot=field]]:border has-[>[data-slot=field]]:flex-col has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:w-full has-data-[state=checked]:bg-primary/5 has-data-[state=checked]:border-primary items-center leading-snug peer-disabled:cursor-not-allowed peer-disabled:opacity-50 peer/field-label select-none text-sm w-fit"
                 @on_mousedown> Name </label>
          <input type="text"
                 data-slot="input"
                 id="name"
                 class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:font-medium file:h-7 file:inline-flex file:text-foreground file:text-sm focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 h-9 md:text-sm min-w-0 outline-none placeholder:text-muted-foreground px-3 py-1 rounded-md selection:bg-primary selection:text-primary-foreground shadow-xs text-base transition-[color,box-shadow] w-full"/>
          <p data-slot="field-description"
             class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 [[data-variant=legend]+&]:-mt-1.5 font-normal group-has-[[data-orientation=horizontal]]/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1 text-muted-foreground text-sm"> Your full name. </p>
        </div>
        <div data-slot="field-separator"
             data-content="true"
             class="-my-2 group-data-[variant=outline]/field-group:-mb-2 h-5 relative text-sm">
          <div data-slot="separator"
               role="none"
               data-orientation="horizontal"
               class="absolute bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px inset-0 shrink-0 top-1/2"> </div>
          <span data-slot="field-separator-content"
                class="bg-background block mx-auto px-2 relative text-muted-foreground w-fit"> Or </span>
        </div>
        <div role="group"
             data-slot="field"
             data-orientation="horizontal"
             class="[&>[data-slot=field-label]]:flex-auto data-[invalid=true]:text-destructive flex flex-row gap-3 group/field has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px has-[>[data-slot=field-content]]:items-start items-center w-full">
          <button type="button"
                  role="checkbox"
                  aria-checked="false"
                  aria-required="false"
                  data-state="unchecked"
                  data-slot="checkbox"
                  id="news"
                  class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 border border-input dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:data-[state=checked]:bg-primary data-[state=checked]:bg-primary data-[state=checked]:border-primary data-[state=checked]:text-primary-foreground disabled:cursor-not-allowed disabled:opacity-50 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none peer rounded-[4px] shadow-xs shrink-0 size-4 transition-shadow"
                  #value="on"
                  @on_click
                  @on_keydown> </button>
          <div data-slot="field-content"
               class="flex flex-1 flex-col gap-1.5 group/field-content leading-snug">
            <div data-slot="field-label"
                 class="flex font-medium gap-2 group-data-[disabled=true]/field:opacity-50 items-center leading-snug text-sm w-fit"> Newsletter </div>
            <p data-slot="field-description"
               class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 [[data-variant=legend]+&]:-mt-1.5 font-normal group-has-[[data-orientation=horizontal]]/field:text-balance last:mt-0 leading-normal nth-last-2:-mt-1 text-muted-foreground text-sm"> Weekly. </p>
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
