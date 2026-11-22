open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html (Kbd.group [ Kbd.view [ Node.text "Ctrl" ]; Kbd.view [ Node.text "B" ] ]);
  [%expect {|
    <kbd data-slot="kbd-group" class="cn-kbd-group inline-flex items-center">
      <kbd data-slot="kbd"
           class="cn-kbd inline-flex items-center justify-center pointer-events-none select-none"> Ctrl </kbd>
      <kbd data-slot="kbd"
           class="cn-kbd inline-flex items-center justify-center pointer-events-none select-none"> B </kbd>
    </kbd>
    |}]
;;
