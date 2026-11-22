open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html
    (Input_group.root
       [ Input_group.input ~placeholder:"Search..." ()
       ; Input_group.addon [ Icon.view Search ]
       ; Input_group.addon
           ~align:Inline_end
           [ Input_group.text [ Node.text "12 results" ] ]
       ]);
  [%expect
    {|
    <div data-slot="input-group"
         role="group"
         class="cn-input-group flex group/input-group has-[>textarea]:h-auto items-center min-w-0 outline-none relative w-full">
      <input type="text"
             data-slot="input-group-control"
             placeholder="Search..."
             class="cn-input cn-input-group-input disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:inline-flex file:text-foreground flex-1 min-w-0 outline-none placeholder:text-muted-foreground w-full"/>
      <div role="group"
           data-slot="input-group-addon"
           data-align="inline-start"
           class="cn-input-group-addon cn-input-group-addon-align-inline-start cursor-text flex items-center justify-center order-first select-none"
           @on_click>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             class="lucide lucide-search">
          <circle cx="11" cy="11" r="8"> </circle>
          <path d="m21 21-4.3-4.3"> </path>
        </svg>
      </div>
      <div role="group"
           data-slot="input-group-addon"
           data-align="inline-end"
           class="cn-input-group-addon cn-input-group-addon-align-inline-end cursor-text flex items-center justify-center order-last select-none"
           @on_click>
        <span class="[&_svg]:pointer-events-none cn-input-group-text flex items-center"> 12 results </span>
      </div>
    </div>
    |}]
;;

let%expect_test "addons on every side, a textarea, buttons" =
  List.iter Input_group.Align.all ~f:(fun align ->
    Render.html ~classes:false (Input_group.addon ~align [ Node.text "x" ]));
  Render.html
    ~classes:false
    (Input_group.root
       ~disabled:true
       [ Input_group.textarea
           ~placeholder:"Ask, search or chat..."
           ~invalid:true
           ()
       ; Input_group.addon
           ~align:Block_end
           [ Input_group.button
               ~size:Icon_xs
               ~variant:Default
               [ Icon.view Arrow_up ]
           ; Input_group.button [ Node.text "Auto" ]
           ]
       ]);
  [%expect
    {|
    <div role="group" data-slot="input-group-addon" data-align="inline-start" @on_click> x </div>
    <div role="group" data-slot="input-group-addon" data-align="inline-end" @on_click> x </div>
    <div role="group" data-slot="input-group-addon" data-align="block-start" @on_click> x </div>
    <div role="group" data-slot="input-group-addon" data-align="block-end" @on_click> x </div>
    <div data-slot="input-group" role="group" data-disabled="true">
      <textarea data-slot="input-group-control"
                placeholder="Ask, search or chat..."
                aria-invalid="true"> </textarea>
      <div role="group" data-slot="input-group-addon" data-align="block-end" @on_click>
        <button type="button" data-slot="button" data-variant="default" data-size="icon-xs">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round">
            <path d="m5 12 7-7 7 7"> </path>
            <path d="M12 19V5"> </path>
          </svg>
        </button>
        <button type="button" data-slot="button" data-variant="ghost" data-size="xs"> Auto </button>
      </div>
    </div>
    |}]
;;

let%expect_test "button sizes" =
  List.iter Input_group.Button_size.all ~f:(fun size ->
    Render.html (Input_group.button ~size [ Node.text "x" ]));
  [%expect
    {|
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="xs"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-input-group-button cn-input-group-button-size-xs disabled:opacity-50 disabled:pointer-events-none flex group/button items-center justify-center outline-none select-none shadow-none shrink-0 transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="sm"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-input-group-button cn-input-group-button-size-sm disabled:opacity-50 disabled:pointer-events-none flex group/button items-center justify-center outline-none select-none shadow-none shrink-0 transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon-xs"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-input-group-button cn-input-group-button-size-icon-xs disabled:opacity-50 disabled:pointer-events-none flex group/button items-center justify-center outline-none select-none shadow-none shrink-0 transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon-sm"
            class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-ghost cn-input-group-button cn-input-group-button-size-icon-sm disabled:opacity-50 disabled:pointer-events-none flex group/button items-center justify-center outline-none select-none shadow-none shrink-0 transition-all whitespace-nowrap"> x </button>
    |}]
;;

let%expect_test "the input is controlled through on_input" =
  let typed = ref [] in
  let handle =
    Render.handle ~classes:false (fun _ ->
      Bonsai_web.Bonsai.return
        (Input_group.root
           [ Input_group.input
               ~value:""
               ~on_input:(fun s ->
                 typed := s :: !typed;
                 Bonsai_web.Effect.Ignore)
               ()
           ]))
  in
  Drive.type_ handle "input" "abc";
  print_s [%sexp (!typed : string list)];
  [%expect {| (abc) |}]
;;
