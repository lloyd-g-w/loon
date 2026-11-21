open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html (Kbd.group [ Kbd.view [ Node.text "Ctrl" ]; Kbd.view [ Node.text "B" ] ]);
  [%expect {|
    <kbd data-slot="kbd-group" class="gap-1 inline-flex items-center">
      <kbd data-slot="kbd"
           class="[&_svg:not([class*='size-'])]:size-3 [[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background bg-muted dark:[[data-slot=tooltip-content]_&]:bg-background/10 font-medium font-sans gap-1 h-5 inline-flex items-center justify-center min-w-5 pointer-events-none px-1 rounded-sm select-none text-muted-foreground text-xs w-fit"> Ctrl </kbd>
      <kbd data-slot="kbd"
           class="[&_svg:not([class*='size-'])]:size-3 [[data-slot=tooltip-content]_&]:bg-background/20 [[data-slot=tooltip-content]_&]:text-background bg-muted dark:[[data-slot=tooltip-content]_&]:bg-background/10 font-medium font-sans gap-1 h-5 inline-flex items-center justify-center min-w-5 pointer-events-none px-1 rounded-sm select-none text-muted-foreground text-xs w-fit"> B </kbd>
    </kbd>
    |}]
;;
