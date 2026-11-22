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
         class="*:focus-visible:relative *:focus-visible:z-10 [&>*:not(:first-child)]:border-l-0 [&>*:not(:first-child)]:rounded-l-none [&>*:not(:last-child)]:rounded-r-none [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1 cn-button-group cn-button-group-orientation-horizontal flex group/button-group items-stretch w-fit">
      <button type="button"
              data-slot="button"
              data-variant="outline"
              data-size="default"
              class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-button cn-button-size-default cn-button-variant-outline disabled:opacity-50 disabled:pointer-events-none group/button inline-flex items-center justify-center outline-none select-none shrink-0 transition-all whitespace-nowrap"> Archive </button>
      <div data-slot="button-group-separator"
           role="none"
           data-orientation="vertical"
           class="bg-border cn-button-group-separator data-horizontal:h-px data-horizontal:mx-px data-horizontal:w-auto data-vertical:h-auto data-vertical:my-px data-vertical:self-stretch data-vertical:w-px relative self-stretch shrink-0"> </div>
      <div class="[&_svg]:pointer-events-none cn-button-group-text flex items-center"> Report </div>
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
    cn-button-group group/button-group flex w-fit items-stretch *:focus-visible:relative *:focus-visible:z-10 [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1 cn-button-group-orientation-vertical flex-col [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 [&>*:not(:last-child)]:rounded-b-none
    |}]
;;
