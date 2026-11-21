open! Core
open Loon

let show strings = print_endline (Cn.cn strings)

let%expect_test "later classes override earlier ones they conflict with" =
  show [ "px-2 py-1 bg-red-500 hover:bg-red-600"; "p-3 bg-primary" ];
  [%expect {| hover:bg-red-600 p-3 bg-primary |}];
  show [ "p-3"; "px-5" ];
  [%expect {| p-3 px-5 |}];
  show [ "h-9 w-9"; "size-4" ];
  [%expect {| size-4 |}];
  show [ "size-4"; "h-9" ];
  [%expect {| size-4 h-9 |}]
;;

let%expect_test "text sizes, colours and alignment are separate" =
  show [ "text-sm text-muted-foreground text-left"; "text-lg"; "text-primary/80" ];
  [%expect {| text-left text-lg text-primary/80 |}];
  show [ "text-[13px] text-[#333]"; "text-xs" ];
  [%expect {| text-[#333] text-xs |}]
;;

let%expect_test "variants keep their own groups" =
  show [ "hover:bg-accent dark:hover:bg-accent/50 bg-background"; "hover:bg-muted" ];
  [%expect {| dark:hover:bg-accent/50 bg-background hover:bg-muted |}];
  show [ "data-[state=active]:bg-background has-[>svg]:px-3"; "has-[>svg]:px-2" ];
  [%expect {| data-[state=active]:bg-background has-[>svg]:px-2 |}]
;;

let%expect_test "borders, radii, rings, shadows, display" =
  show [ "border border-input rounded-md shadow-xs flex"; "border-2 rounded-full shadow-none grid" ];
  [%expect {| border-input border-2 rounded-full shadow-none grid |}];
  show [ "rounded-t-lg"; "rounded-md" ];
  [%expect {| rounded-md |}];
  show [ "focus-visible:ring-[3px] focus-visible:ring-ring/50"; "focus-visible:ring-destructive/20" ];
  [%expect {| focus-visible:ring-[3px] focus-visible:ring-destructive/20 |}]
;;

let%expect_test "unknown classes and duplicates" =
  show [ "foo bar  foo"; "\n baz bar" ];
  [%expect {| foo baz bar |}];
  show [ "[&_svg:not([class*='size-'])]:size-4"; "[&_svg:not([class*='size-'])]:size-3" ];
  [%expect {| [&_svg:not([class*='size-'])]:size-3 |}]
;;

let%expect_test "arbitrary properties conflict by property" =
  show [ "p-3 [--cell-size:--spacing(8)]"; "p-0 [--cell-size:--spacing(9.5)]" ];
  [%expect {| p-0 [--cell-size:--spacing(9.5)] |}];
  show [ "[--cell-size:--spacing(8)]"; "md:[--cell-size:--spacing(12)]" ];
  [%expect {| [--cell-size:--spacing(8)] md:[--cell-size:--spacing(12)] |}]
;;
