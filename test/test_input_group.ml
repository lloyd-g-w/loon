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
         class="border border-input dark:bg-input/30 dark:has-[[data-slot][aria-invalid=true]]:ring-destructive/40 flex group/input-group h-9 has-[>[data-align=block-end]]:[&>input]:pt-3 has-[>[data-align=block-end]]:flex-col has-[>[data-align=block-end]]:h-auto has-[>[data-align=block-start]]:[&>input]:pb-3 has-[>[data-align=block-start]]:flex-col has-[>[data-align=block-start]]:h-auto has-[>[data-align=inline-end]]:[&>input]:pr-2 has-[>[data-align=inline-start]]:[&>input]:pl-2 has-[>textarea]:h-auto has-[[data-slot=input-group-control]:focus-visible]:border-ring has-[[data-slot=input-group-control]:focus-visible]:ring-[3px] has-[[data-slot=input-group-control]:focus-visible]:ring-ring/50 has-[[data-slot][aria-invalid=true]]:border-destructive has-[[data-slot][aria-invalid=true]]:ring-destructive/20 items-center min-w-0 outline-none relative rounded-md shadow-xs transition-[color,box-shadow] w-full">
      <input type="text"
             data-slot="input-group-control"
             placeholder="Search..."
             class="aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-transparent border-0 border-input dark:aria-invalid:ring-destructive/40 dark:bg-transparent disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:font-medium file:h-7 file:inline-flex file:text-foreground file:text-sm flex-1 focus-visible:border-ring focus-visible:ring-0 focus-visible:ring-ring/50 h-9 md:text-sm min-w-0 outline-none placeholder:text-muted-foreground px-3 py-1 rounded-none selection:bg-primary selection:text-primary-foreground shadow-none text-base transition-[color,box-shadow] w-full"/>
      <div role="group"
           data-slot="input-group-addon"
           data-align="inline-start"
           class="[&>kbd]:rounded-[calc(var(--radius)-5px)] [&>svg:not([class*='size-'])]:size-4 cursor-text flex font-medium gap-2 group-data-[disabled=true]/input-group:opacity-50 h-auto has-[>button]:ml-[-0.45rem] has-[>kbd]:ml-[-0.35rem] items-center justify-center order-first pl-3 py-1.5 select-none text-muted-foreground text-sm"
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
           class="[&>kbd]:rounded-[calc(var(--radius)-5px)] [&>svg:not([class*='size-'])]:size-4 cursor-text flex font-medium gap-2 group-data-[disabled=true]/input-group:opacity-50 h-auto has-[>button]:mr-[-0.45rem] has-[>kbd]:mr-[-0.35rem] items-center justify-center order-last pr-3 py-1.5 select-none text-muted-foreground text-sm"
           @on_click>
        <span class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none flex gap-2 items-center text-muted-foreground text-sm"> 12 results </span>
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
            class="[&>svg:not([class*='size-'])]:size-3.5 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 dark:hover:bg-accent/50 disabled:opacity-50 disabled:pointer-events-none flex focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1 h-6 has-[>svg]:px-2 hover:bg-accent hover:text-accent-foreground items-center justify-center outline-none px-2 py-2 rounded-[calc(var(--radius)-5px)] shadow-none shrink-0 text-sm transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="sm"
            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 dark:hover:bg-accent/50 disabled:opacity-50 disabled:pointer-events-none flex focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1.5 h-8 has-[>svg]:px-2.5 hover:bg-accent hover:text-accent-foreground items-center justify-center outline-none px-2.5 py-2 rounded-md shadow-none shrink-0 text-sm transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon-xs"
            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 dark:hover:bg-accent/50 disabled:opacity-50 disabled:pointer-events-none flex focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 has-[>svg]:p-0 hover:bg-accent hover:text-accent-foreground items-center justify-center outline-none p-0 rounded-[calc(var(--radius)-5px)] shadow-none shrink-0 size-6 text-sm transition-all whitespace-nowrap"> x </button>
    <button type="button"
            data-slot="button"
            data-variant="ghost"
            data-size="icon-sm"
            class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 dark:hover:bg-accent/50 disabled:opacity-50 disabled:pointer-events-none flex focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 has-[>svg]:p-0 hover:bg-accent hover:text-accent-foreground items-center justify-center outline-none p-0 rounded-md shadow-none shrink-0 size-8 text-sm transition-all whitespace-nowrap"> x </button>
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
