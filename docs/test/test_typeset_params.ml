open! Core
module P = Loon_docs.Typeset_params

let%expect_test "values" =
  List.iter P.Key.all ~f:(fun k ->
    print_s [%message (P.Key.name k) ~values:(P.values k : string list)]);
  [%expect
    {|
    (body
     (values
      (geist inter noto-sans nunito-sans figtree roboto raleway dm-sans
       public-sans outfit oxanium manrope space-grotesk montserrat ibm-plex-sans
       source-sans-3 instrument-sans jetbrains-mono geist-mono noto-serif
       roboto-slab merriweather lora)))
    (heading
     (values
      (inherit geist inter noto-sans nunito-sans figtree roboto raleway dm-sans
       public-sans outfit oxanium manrope space-grotesk montserrat ibm-plex-sans
       source-sans-3 instrument-sans jetbrains-mono geist-mono noto-serif
       roboto-slab merriweather lora)))
    (mono
     (values
      (geist inter noto-sans nunito-sans figtree roboto raleway dm-sans
       public-sans outfit oxanium manrope space-grotesk montserrat ibm-plex-sans
       source-sans-3 instrument-sans jetbrains-mono geist-mono noto-serif
       roboto-slab merriweather lora)))
    (scale (values (14 15 16 18)))
    (measure (values (60 70 80 90)))
    (flow (values (1em 1.25em 2em)))
    (leading (values (1.6 1.75 1.9)))
    (item (values (docs chat article changelog notes)))
    |}]
;;

let%expect_test "of_query: defaults, valid and invalid values" =
  print_s [%sexp (P.default : P.t)];
  print_s [%sexp (P.of_query "" : P.t)];
  print_s
    [%sexp
      (P.of_query
         "body=lora&heading=inherit&mono=nope&scale=18&measure=70&flow=2em&leading=1.6&item=chat&x=1"
       : P.t)];
  print_s
    [%sexp
      (P.of_query "heading=instrument-serif&body=roboto-slab&scale=15.5" : P.t)];
  [%expect
    {|
    ((body geist) (heading inherit) (mono geist-mono) (scale 15) (measure 80)
     (flow 1.25em) (leading 1.75) (item docs))
    ((body geist) (heading inherit) (mono geist-mono) (scale 15) (measure 80)
     (flow 1.25em) (leading 1.75) (item docs))
    ((body lora) (heading inherit) (mono geist-mono) (scale 18) (measure 70)
     (flow 2em) (leading 1.6) (item chat))
    ((body roboto-slab) (heading inherit) (mono geist-mono) (scale 15)
     (measure 80) (flow 1.25em) (leading 1.75) (item docs))
    |}]
;;

let%expect_test "coerce" =
  List.iter
    [ P.Key.Body, "inter"
    ; Body, "inherit"
    ; Heading, "inherit"
    ; Heading, "jetbrains-mono"
    ; Mono, "inter"
    ; Scale, "16"
    ; Scale, "16px"
    ; Measure, "60"
    ; Item, "elements"
    ; Item, "nope"
    ]
    ~f:(fun (k, v) ->
      print_s [%message (P.Key.name k) v ~_:(P.coerce k v : string option)]);
  [%expect
    {|
    (body inter (inter))
    (body inherit ())
    (heading inherit (inherit))
    (heading jetbrains-mono (jetbrains-mono))
    (mono inter (inter))
    (scale 16 (16))
    (scale 16px ())
    (measure 60 (60))
    (item elements ())
    (item nope ())
    |}]
;;

let%expect_test "to_query round trips, leaving defaults out" =
  let show p =
    let q = P.to_query p in
    print_endline (if String.is_empty q then "(empty)" else q);
    assert (P.equal (P.of_query q) p)
  in
  show P.default;
  show { P.default with body = "lora"; item = "notes" };
  show (P.apply P.default [ Heading, "inter"; Scale, "18"; Leading, "1.6" ]);
  print_s
    [%sexp
      (List.map P.measures ~f:(fun (o, w) -> o.value, w)
       : (string * string) list)];
  print_s [%sexp (P.measure_width "80" : string option)];
  [%expect
    {|
    (empty)
    body=lora&item=notes
    heading=inter&scale=18&leading=1.6
    ((60 28em) (70 33em) (80 37em) (90 42em))
    (37em)
    |}]
;;
