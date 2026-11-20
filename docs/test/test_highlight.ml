open! Core
module Highlight = Loon_docs.Highlight

let show lang code =
  let tokens = Highlight.tokenize lang code in
  assert (String.equal code (String.concat (List.map tokens ~f:snd)));
  List.iter tokens ~f:(fun (kind, text) ->
    match kind with
    | Plain when String.for_all text ~f:Char.is_whitespace -> ()
    | _ -> print_s [%message (kind : Highlight.Kind.t) text])
;;

let%expect_test "ocaml" =
  show
    Ocaml
    {x|let%arr count and set = state in
(* a (* nested *) comment *)
Button.view ~variant:Outline ?size [ Node.text "a \"q\" b"; Node.textf "%d" 42 ]
[@@deriving sexp_of] |> fun x' -> 'c' :: [%expect {| ok |}] 0x1F 1.5e3|x};
  [%expect {xxx|
    ((kind Ppx) let%arr)
    ((kind Plain) " count ")
    ((kind Keyword) and)
    ((kind Plain) " set ")
    ((kind Operator) =)
    ((kind Plain) " state ")
    ((kind Keyword) in)
    ((kind Comment) "(* a (* nested *) comment *)")
    ((kind Module) Button)
    ((kind Operator) .)
    ((kind Plain) "view ")
    ((kind Label) ~variant)
    ((kind Operator) :)
    ((kind Constructor) Outline)
    ((kind Label) ?size)
    ((kind Punctuation) [)
    ((kind Module) Node)
    ((kind Operator) .)
    ((kind Plain) "text ")
    ((kind String) "\"a \\\"q\\\" b\"")
    ((kind Punctuation) ";")
    ((kind Module) Node)
    ((kind Operator) .)
    ((kind Plain) "textf ")
    ((kind String) "\"%d\"")
    ((kind Number) 42)
    ((kind Punctuation) ])
    ((kind Ppx) [@@deriving)
    ((kind Plain) " sexp_of")
    ((kind Punctuation) ])
    ((kind Operator) |>)
    ((kind Keyword) fun)
    ((kind Plain) " x' ")
    ((kind Operator) ->)
    ((kind String) 'c')
    ((kind Operator) ::)
    ((kind Ppx) [%expect)
    ((kind String) "{| ok |}")
    ((kind Punctuation) ])
    ((kind Number) 0x1F)
    ((kind Number) 1.5e3)
    |xxx}]
;;

let%expect_test "dune and shell" =
  show Dune {|(executable
 (name main) ; a comment
 (libraries loon "x y"))|};
  show Shell {|$ loon add button --dir src # copy it
dune build @runtest|};
  [%expect {|
    ((kind Keyword) "(executable")
    ((kind Keyword) "(name")
    ((kind Plain) " main")
    ((kind Punctuation) ")")
    ((kind Comment) "; a comment")
    ((kind Keyword) "(libraries")
    ((kind Plain) " loon ")
    ((kind String) "\"x y\"")
    ((kind Punctuation) "))")
    ((kind Operator) $)
    ((kind Plain) " loon add button ")
    ((kind Label) --dir)
    ((kind Plain) " src ")
    ((kind Comment) "# copy it")
    ((kind Keyword) dune)
    ((kind Plain) " build @runtest")
    |}]
;;

let%expect_test "css" =
  show Css {|.loon-dark { --loon-accent: oklch(0.6 0.2 340); /* brand */ }|};
  [%expect {|
    ((kind Keyword) .loon-dark)
    ((kind Punctuation) {)
    ((kind Label) --loon-accent)
    ((kind Keyword) :)
    ((kind Plain) " oklch")
    ((kind Punctuation) "(")
    ((kind Number) 0.6)
    ((kind Number) 0.2)
    ((kind Number) 340)
    ((kind Punctuation) ");")
    ((kind Comment) "/* brand */")
    ((kind Punctuation) })
    |}]
;;

let%expect_test "partial code never fails" =
  List.iter
    [ "\"unterminated"; "(* open"; "{x|quoted"; "'"; "let%"; "~"; "" ]
    ~f:(fun code -> show Ocaml code);
  [%expect {|
    ((kind String) "\"unterminated")
    ((kind Comment) "(* open")
    ((kind String) {x|quoted)
    ((kind Plain) ')
    ((kind Ppx) let%)
    ((kind Operator) ~)
    |}]
;;
