open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes and Radix's DOM" =
  Render.html
    (Scroll_area.root
       ~class_:"h-72 w-48 rounded-md border"
       [ Node.text "Tags"; Scroll_area.scroll_bar ~orientation:Horizontal () ]);
  [%expect
    {|
    <div dir="ltr"
         data-slot="scroll-area"
         style="position: relative; --radix-scroll-area-corner-width: 0px; --radix-scroll-area-corner-height: 0px;"
         class="border h-72 relative rounded-md w-48"
         loon-scroll-area=(Hover 600ms)>
      <style>
        [data-radix-scroll-area-viewport]{scrollbar-width:none;-ms-overflow-style:none;-webkit-overflow-scrolling:touch;}[data-radix-scroll-area-viewport]::-webkit-scrollbar{display:none}
      </style>
      <div data-radix-scroll-area-viewport=""
           data-slot="scroll-area-viewport"
           style="overflow: hidden;"
           class="focus-visible:outline-1 focus-visible:ring-[3px] focus-visible:ring-ring/50 outline-none rounded-[inherit] size-full transition-[color,box-shadow]">
        <div style="min-width: 100%; display: table;">
          Tags
          <div data-state="hidden"
               data-orientation="horizontal"
               data-slot="scroll-area-scrollbar"
               style="position: absolute; bottom: 0px; left: 0px; right: var(--radix-scroll-area-corner-width); display: none;"
               class="border-t border-t-transparent flex flex-col h-2.5 p-px select-none touch-none transition-colors">
            <div data-state="hidden"
                 data-slot="scroll-area-thumb"
                 style="width: var(--radix-scroll-area-thumb-width); height: var(--radix-scroll-area-thumb-height);"
                 class="bg-border flex-1 relative rounded-full"> </div>
          </div>
        </div>
      </div>
      <div data-state="hidden"
           data-orientation="vertical"
           data-slot="scroll-area-scrollbar"
           style="position: absolute; top: 0px; right: 0px; bottom: var(--radix-scroll-area-corner-height); display: none;"
           class="border-l border-l-transparent flex h-full p-px select-none touch-none transition-colors w-2.5">
        <div data-state="hidden"
             data-slot="scroll-area-thumb"
             style="width: var(--radix-scroll-area-thumb-width); height: var(--radix-scroll-area-thumb-height);"
             class="bg-border flex-1 relative rounded-full"> </div>
      </div>
    </div>
    |}]
;;
