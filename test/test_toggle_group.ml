open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let items group =
  [ Toggle_group.item group ~value:"bold" [ Node.text "B" ]
  ; Toggle_group.item group ~value:"italic" [ Node.text "I" ]
  ; Toggle_group.item group ~value:"strike" ~disabled:true [ Node.text "S" ]
  ; Toggle_group.item group ~value:"underline" [ Node.text "U" ]
  ]
;;

let item n = sprintf "[data-slot=toggle-group-item]:nth-child(%d)" n

let%expect_test "shadcn's classes" =
  Render.html
    (Toggle_group.multiple
       ~variant:Outline
       ~value:[ "bold" ]
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun group ->
          [ Toggle_group.item group ~value:"bold" [ Node.text "B" ]
          ; Toggle_group.item group ~value:"italic" [ Node.text "I" ]
          ]));
  [%expect
    {|
    <div role="toolbar"
         dir="ltr"
         data-slot="toggle-group"
         tabindex="0"
         data-variant="outline"
         data-spacing="2"
         data-orientation="horizontal"
         class="cn-toggle-group data-vertical:flex-col data-vertical:items-stretch flex flex-row gap-[--spacing(var(--gap))] group/toggle-group items-center w-fit"
         custom-css-vars=((--gap 2))
         @on_focusout
         @on_focus>
      <button type="button"
              data-state="on"
              aria-pressed="true"
              tabindex="-1"
              data-slot="toggle-group-item"
              data-variant="outline"
              data-size="default"
              data-spacing="2"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle cn-toggle-group-item cn-toggle-size-default cn-toggle-variant-outline disabled:opacity-50 disabled:pointer-events-none focus-visible:ring-[3px] focus-visible:z-10 focus:z-10 group-data-horizontal/toggle-group:data-[spacing=0]:data-[variant=outline]:border-l-0 group-data-horizontal/toggle-group:data-[spacing=0]:data-[variant=outline]:first:border-l group-data-vertical/toggle-group:data-[spacing=0]:data-[variant=outline]:border-t-0 group-data-vertical/toggle-group:data-[spacing=0]:data-[variant=outline]:first:border-t group/toggle hover:bg-muted inline-flex items-center justify-center outline-none shrink-0 whitespace-nowrap"
              @on_click
              @on_focus
              @on_keydown> B </button>
      <button type="button"
              data-state="off"
              aria-pressed="false"
              tabindex="-1"
              data-slot="toggle-group-item"
              data-variant="outline"
              data-size="default"
              data-spacing="2"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-toggle cn-toggle-group-item cn-toggle-size-default cn-toggle-variant-outline disabled:opacity-50 disabled:pointer-events-none focus-visible:ring-[3px] focus-visible:z-10 focus:z-10 group-data-horizontal/toggle-group:data-[spacing=0]:data-[variant=outline]:border-l-0 group-data-horizontal/toggle-group:data-[spacing=0]:data-[variant=outline]:first:border-l group-data-vertical/toggle-group:data-[spacing=0]:data-[variant=outline]:border-t-0 group-data-vertical/toggle-group:data-[spacing=0]:data-[variant=outline]:first:border-t group/toggle hover:bg-muted inline-flex items-center justify-center outline-none shrink-0 whitespace-nowrap"
              @on_click
              @on_focus
              @on_keydown> I </button>
    </div>
    |}]
;;

let%expect_test "spacing, size and vertical orientation" =
  Render.html
    ~classes:false
    (Toggle_group.single
       ~size:Sm
       ~spacing:2
       ~orientation:Vertical
       ~value:None
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun group -> [ Toggle_group.item group ~value:"a" [ Node.text "A" ] ]));
  [%expect
    {|
    <div role="radiogroup"
         dir="ltr"
         data-slot="toggle-group"
         tabindex="0"
         data-size="sm"
         data-spacing="2"
         data-orientation="vertical"
         custom-css-vars=((--gap 2))
         @on_focusout
         @on_focus>
      <button type="button"
              data-state="off"
              role="radio"
              aria-checked="false"
              tabindex="-1"
              data-slot="toggle-group-item"
              data-variant="default"
              data-size="sm"
              data-spacing="2"
              @on_click
              @on_focus
              @on_keydown> A </button>
    </div>
    |}]
;;

let%expect_test
    "single: a click presses one, another moves it, again releases it"
  =
  let handle =
    Control_render.handle
      [%sexp_of: string option]
      (Toggle_group.single_component (Bonsai_web.Bonsai.return items))
  in
  (* Nothing pressed: every enabled item is a tab stop. *)
  Handle.show handle;
  [%expect
    {|
    <div>
      <div role="radiogroup"
           dir="ltr"
           data-slot="toggle-group"
           tabindex="0"
           data-spacing="2"
           data-orientation="horizontal"
           custom-css-vars=((--gap 2))
           @on_focusout
           @on_focus>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> B </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> I </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                data-disabled=""
                disabled=""
                @on_focus
                @on_keydown> S </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> U </button>
      </div>
      <output> () </output>
    </div>
    |}];
  Drive.click handle (item 2);
  Handle.show_diff handle;
  [%expect
    {|
             custom-css-vars=((--gap 2))
             @on_focusout
             @on_focus>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> B </button>
          <button type="button"
    -|            data-state="off"
    +|            data-state="on"
                  role="radio"
    -|            aria-checked="false"
    +|            aria-checked="true"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"

                  disabled=""
                  @on_focus
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> U </button>
        </div>
    -|  <output> () </output>
    +|  <output> (italic) </output>
      </div>
    |}];
  Drive.click handle (item 1);
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div role="radiogroup"
             dir="ltr"
             data-slot="toggle-group"
             tabindex="0"
             data-spacing="2"
             data-orientation="horizontal"
             custom-css-vars=((--gap 2))
             @on_focusout
             @on_focus>
    -|    <button type="button"
    -|            data-state="off"
    -|            role="radio"
    -|            aria-checked="false"
    -|            tabindex="-1"
    -|            data-slot="toggle-group-item"
    -|            data-variant="default"
    -|            data-size="default"
    -|            data-spacing="2"
    -|            @on_click
    -|            @on_focus
    -|            @on_keydown> B </button>
          <button type="button"
                  data-state="on"
                  role="radio"
                  aria-checked="true"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
    +|            @on_keydown> B </button>
    +|    <button type="button"
    +|            data-state="off"
    +|            role="radio"
    +|            aria-checked="false"
    +|            tabindex="-1"
    +|            data-slot="toggle-group-item"
    +|            data-variant="default"
    +|            data-size="default"
    +|            data-spacing="2"
    +|            @on_click
    +|            @on_focus
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  data-disabled=""
                  disabled=""
                  @on_focus
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> U </button>
        </div>
    -|  <output> (italic) </output>
    +|  <output> (bold) </output>
      </div>
    |}];
  Drive.click handle (item 1);
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div role="radiogroup"
             dir="ltr"
             data-slot="toggle-group"
             tabindex="0"
             data-spacing="2"
             data-orientation="horizontal"
             custom-css-vars=((--gap 2))
             @on_focusout
             @on_focus>
          <button type="button"
    -|            data-state="on"
    +|            data-state="off"
                  role="radio"
    -|            aria-checked="true"
    +|            aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> B </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"

                  disabled=""
                  @on_focus
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> U </button>
        </div>
    -|  <output> (bold) </output>
    +|  <output> () </output>
      </div>
    |}];
  (* Arrow keys move focus only, never the value. *)
  Drive.key handle (item 1) ArrowRight;
  Handle.show_diff handle;
  [%expect {| ("default prevented" (key ArrowRight)) |}]
;;

let%expect_test
    "multiple: clicks add and remove; the first pressed is the tab stop"
  =
  let handle =
    Control_render.handle
      [%sexp_of: string list]
      (Toggle_group.multiple_component
         ~default_value:[ "underline" ]
         (Bonsai_web.Bonsai.return items))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div role="toolbar"
           dir="ltr"
           data-slot="toggle-group"
           tabindex="0"
           data-spacing="2"
           data-orientation="horizontal"
           custom-css-vars=((--gap 2))
           @on_focusout
           @on_focus>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> B </button>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> I </button>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                data-disabled=""
                disabled=""
                @on_focus
                @on_keydown> S </button>
        <button type="button"
                data-state="on"
                aria-pressed="true"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-variant="default"
                data-size="default"
                data-spacing="2"
                @on_click
                @on_focus
                @on_keydown> U </button>
      </div>
      <output> (underline) </output>
    </div>
    |}];
  Drive.click handle (item 1);
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div role="toolbar"
             dir="ltr"
             data-slot="toggle-group"
             tabindex="0"
             data-spacing="2"
             data-orientation="horizontal"
             custom-css-vars=((--gap 2))
             @on_focusout
             @on_focus>
          <button type="button"
    -|            data-state="off"
    +|            data-state="on"
    -|            aria-pressed="false"
    +|            aria-pressed="true"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> B </button>
          <button type="button"
                  data-state="off"
                  aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"

                  data-disabled=""
                  disabled=""
                  @on_focus
                  @on_keydown> S </button>
          <button type="button"
                  data-state="on"
                  aria-pressed="true"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> U </button>
        </div>
    -|  <output> (underline) </output>
    +|  <output> (underline bold) </output>
      </div>
    |}];
  Drive.click handle (item 4);
  (* The disabled item has no click handler. *)
  Handle.show_diff handle;
  [%expect
    {|
                  @on_click
                  @on_focus
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  data-disabled=""
                  disabled=""
                  @on_focus
                  @on_keydown> S </button>
          <button type="button"
    -|            data-state="on"
    +|            data-state="off"
    -|            aria-pressed="true"
    +|            aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-variant="default"
                  data-size="default"
                  data-spacing="2"
                  @on_click
                  @on_focus
                  @on_keydown> U </button>
        </div>
    -|  <output> (underline bold) </output>
    +|  <output> (bold) </output>
      </div>
    |}]
;;
