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
    <div role="group"
         dir="ltr"
         data-slot="toggle-group"
         data-variant="outline"
         data-spacing="0"
         class="data-[spacing=default]:data-[variant=outline]:shadow-xs flex gap-[--spacing(var(--gap))] group/toggle-group items-center rounded-md w-fit"
         custom-css-vars=((--gap 0))>
      <button type="button"
              data-state="on"
              aria-pressed="true"
              tabindex="0"
              data-slot="toggle-group-item"
              data-variant="outline"
              data-spacing="0"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border border-input dark:aria-invalid:ring-destructive/40 data-[spacing=0]:data-[variant=outline]:border-l-0 data-[spacing=0]:data-[variant=outline]:first:border-l data-[spacing=0]:first:rounded-l-md data-[spacing=0]:last:rounded-r-md data-[spacing=0]:rounded-none data-[spacing=0]:shadow-none data-[state=on]:bg-accent data-[state=on]:text-accent-foreground disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:z-10 focus:z-10 font-medium gap-2 h-9 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center min-w-0 outline-none px-3 rounded-md shadow-xs shrink-0 text-sm transition-[color,box-shadow] w-auto whitespace-nowrap"
              #value="bold"
              @on_click
              @on_keydown> B </button>
      <button type="button"
              data-state="off"
              aria-pressed="false"
              tabindex="-1"
              data-slot="toggle-group-item"
              data-variant="outline"
              data-spacing="0"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border border-input dark:aria-invalid:ring-destructive/40 data-[spacing=0]:data-[variant=outline]:border-l-0 data-[spacing=0]:data-[variant=outline]:first:border-l data-[spacing=0]:first:rounded-l-md data-[spacing=0]:last:rounded-r-md data-[spacing=0]:rounded-none data-[spacing=0]:shadow-none data-[state=on]:bg-accent data-[state=on]:text-accent-foreground disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:z-10 focus:z-10 font-medium gap-2 h-9 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center min-w-0 outline-none px-3 rounded-md shadow-xs shrink-0 text-sm transition-[color,box-shadow] w-auto whitespace-nowrap"
              #value="italic"
              @on_click
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
    <div role="group"
         dir="ltr"
         data-slot="toggle-group"
         data-size="sm"
         data-spacing="2"
         data-orientation="vertical"
         custom-css-vars=((--gap 2))>
      <button type="button"
              data-state="off"
              role="radio"
              aria-checked="false"
              tabindex="0"
              data-slot="toggle-group-item"
              data-size="sm"
              data-spacing="2"
              #value="a"
              @on_click
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
      <div role="group"
           dir="ltr"
           data-slot="toggle-group"
           data-spacing="0"
           custom-css-vars=((--gap 0))>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="0"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="bold"
                @on_click
                @on_keydown> B </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="0"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="italic"
                @on_click
                @on_keydown> I </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="0"
                data-slot="toggle-group-item"
                data-spacing="0"
                data-disabled=""
                disabled=""
                #value="strike"
                @on_keydown> S </button>
        <button type="button"
                data-state="off"
                role="radio"
                aria-checked="false"
                tabindex="0"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="underline"
                @on_click
                @on_keydown> U </button>
      </div>
      <output> () </output>
    </div>
    |}];
  Drive.click handle (item 2);
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div role="group"
             dir="ltr"
             data-slot="toggle-group"
             data-spacing="0"
             custom-css-vars=((--gap 0))>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="bold"
                  @on_click
                  @on_keydown> B </button>
          <button type="button"
    -|            data-state="off"
    +|            data-state="on"
                  role="radio"
    -|            aria-checked="false"
    +|            aria-checked="true"
                  tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="italic"
                  @on_click
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  data-disabled=""
                  disabled=""
                  #value="strike"
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="underline"
                  @on_click
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
        <div role="group"
             dir="ltr"
             data-slot="toggle-group"
             data-spacing="0"
             custom-css-vars=((--gap 0))>
    -|    <button type="button"
    -|            data-state="off"
    -|            role="radio"
    -|            aria-checked="false"
    -|            tabindex="-1"
    -|            data-slot="toggle-group-item"
    -|            data-spacing="0"
    -|            #value="bold"
    -|            @on_click
    -|            @on_keydown> B </button>
          <button type="button"
                  data-state="on"
                  role="radio"
                  aria-checked="true"
                  tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
    +|            #value="bold"
    +|            @on_click
    +|            @on_keydown> B </button>
    +|    <button type="button"
    +|            data-state="off"
    +|            role="radio"
    +|            aria-checked="false"
    +|            tabindex="-1"
    +|            data-slot="toggle-group-item"
    +|            data-spacing="0"
                  #value="italic"
                  @on_click
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  data-disabled=""
                  disabled=""
                  #value="strike"
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="underline"
                  @on_click
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
        <div role="group"
             dir="ltr"
             data-slot="toggle-group"
             data-spacing="0"
             custom-css-vars=((--gap 0))>
          <button type="button"
    -|            data-state="on"
    +|            data-state="off"
                  role="radio"
    -|            aria-checked="true"
    +|            aria-checked="false"
                  tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="bold"
                  @on_click
                  @on_keydown> B </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="italic"
                  @on_click
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  data-disabled=""
                  disabled=""
                  #value="strike"
                  @on_keydown> S </button>
          <button type="button"
                  data-state="off"
                  role="radio"
                  aria-checked="false"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="underline"
                  @on_click
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
      <div role="group"
           dir="ltr"
           data-slot="toggle-group"
           data-spacing="0"
           custom-css-vars=((--gap 0))>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="bold"
                @on_click
                @on_keydown> B </button>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="italic"
                @on_click
                @on_keydown> I </button>
        <button type="button"
                data-state="off"
                aria-pressed="false"
                tabindex="-1"
                data-slot="toggle-group-item"
                data-spacing="0"
                data-disabled=""
                disabled=""
                #value="strike"
                @on_keydown> S </button>
        <button type="button"
                data-state="on"
                aria-pressed="true"
                tabindex="0"
                data-slot="toggle-group-item"
                data-spacing="0"
                #value="underline"
                @on_click
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
        <div role="group"
             dir="ltr"
             data-slot="toggle-group"
             data-spacing="0"
             custom-css-vars=((--gap 0))>
          <button type="button"
    -|            data-state="off"
    +|            data-state="on"
    -|            aria-pressed="false"
    +|            aria-pressed="true"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="bold"
                  @on_click
                  @on_keydown> B </button>
          <button type="button"
                  data-state="off"
                  aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="italic"
                  @on_click
                  @on_keydown> I </button>
          <button type="button"

                  data-slot="toggle-group-item"
                  data-spacing="0"
                  data-disabled=""
                  disabled=""
                  #value="strike"
                  @on_keydown> S </button>
          <button type="button"
                  data-state="on"
                  aria-pressed="true"
                  tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="underline"
                  @on_click
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
      <div>
        <div role="group"
             dir="ltr"
             data-slot="toggle-group"
             data-spacing="0"
             custom-css-vars=((--gap 0))>
          <button type="button"
                  data-state="on"
                  aria-pressed="true"
    -|            tabindex="-1"
    +|            tabindex="0"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="bold"
                  @on_click
                  @on_keydown> B </button>
          <button type="button"
                  data-state="off"
                  aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="italic"
                  @on_click
                  @on_keydown> I </button>
          <button type="button"
                  data-state="off"
                  aria-pressed="false"
                  tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  data-disabled=""
                  disabled=""
                  #value="strike"
                  @on_keydown> S </button>
          <button type="button"
    -|            data-state="on"
    +|            data-state="off"
    -|            aria-pressed="true"
    +|            aria-pressed="false"
    -|            tabindex="0"
    +|            tabindex="-1"
                  data-slot="toggle-group-item"
                  data-spacing="0"
                  #value="underline"
                  @on_click
                  @on_keydown> U </button>
        </div>
    -|  <output> (underline bold) </output>
    +|  <output> (bold) </output>
      </div>
    |}]
;;
