open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Button_group.root
       [ Button.view ~variant:Outline [ Node.text "Archive" ]
       ; Button_group.separator ()
       ; Button_group.text [ Node.text "Report" ]
       ]);
  [%expect
    {|
    <div role="group"
         data-slot="button-group"
         class="[&>*:not(:first-child)]:border-l-0 [&>*:not(:first-child)]:rounded-l-none [&>*:not(:last-child)]:rounded-r-none [&>*]:focus-visible:relative [&>*]:focus-visible:z-10 [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1 flex has-[>[data-slot=button-group]]:gap-2 has-[select[aria-hidden=true]:last-child]:[&>[data-slot=select-trigger]:last-of-type]:rounded-r-md items-stretch w-fit">
      <button type="button"
              data-slot="button"
              data-variant="outline"
              data-size="default"
              class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 h-9 has-[>svg]:px-3 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none px-4 py-2 rounded-md shadow-xs shrink-0 text-sm transition-all whitespace-nowrap"> Archive </button>
      <div data-slot="button-group-separator"
           role="none"
           data-orientation="vertical"
           class="bg-input data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-auto data-[orientation=vertical]:w-px m-0! relative self-stretch shrink-0"> </div>
      <div class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none bg-muted border flex font-medium gap-2 items-center px-4 rounded-md shadow-xs text-sm"> Report </div>
    </div>
    |}]
;;

let%expect_test "vertical, nested" =
  Render.html
    ~classes:false
    (Button_group.root
       [ Button_group.root
           ~orientation:Vertical
           [ Button.view [ Node.text "Up" ]
           ; Button_group.separator ~orientation:Horizontal ()
           ; Button.view [ Node.text "Down" ]
           ]
       ]);
  print_endline (Button_group.classes ~orientation:Vertical ());
  [%expect
    {|
    <div role="group" data-slot="button-group">
      <div role="group" data-slot="button-group" data-orientation="vertical">
        <button type="button" data-slot="button" data-variant="default" data-size="default"> Up </button>
        <div data-slot="button-group-separator" role="none" data-orientation="horizontal"> </div>
        <button type="button" data-slot="button" data-variant="default" data-size="default"> Down </button>
      </div>
    </div>
    flex w-fit items-stretch has-[>[data-slot=button-group]]:gap-2 [&>*]:focus-visible:relative [&>*]:focus-visible:z-10 has-[select[aria-hidden=true]:last-child]:[&>[data-slot=select-trigger]:last-of-type]:rounded-r-md [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1 flex-col [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 [&>*:not(:last-child)]:rounded-b-none
    |}]
;;
