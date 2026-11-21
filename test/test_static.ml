(* The stateless display components' HTML. *)

open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "theme root" =
  Render.html (Theme.root [ Node.text "inherits" ]);
  Render.html (Theme.root ~mode:Dark [ Node.text "dark" ]);
  [%expect {|
    <div class="bg-background loon text-foreground"> inherits </div>
    <div class="bg-background dark loon text-foreground"> dark </div>
    |}]
;;
