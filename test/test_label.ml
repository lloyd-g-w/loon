open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html
    (Label.view ~for_:"terms" [ Node.text "Accept terms and conditions" ]);
  [%expect
    {|
    <label data-slot="label"
           for="terms"
           class="flex font-medium gap-2 group-data-[disabled=true]:opacity-50 group-data-[disabled=true]:pointer-events-none items-center leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-50 select-none text-sm"
           @on_mousedown> Accept terms and conditions </label>
    |}]
;;

let%expect_test "the caller's class wins" =
  Render.html (Label.view ~class_:"text-base" [ Node.text "Big" ]);
  [%expect
    {|
    <label data-slot="label"
           class="flex font-medium gap-2 group-data-[disabled=true]:opacity-50 group-data-[disabled=true]:pointer-events-none items-center peer-disabled:cursor-not-allowed peer-disabled:opacity-50 select-none text-base"
           @on_mousedown> Big </label>
    |}]
;;

let%expect_test "a double click does not select the label's text" =
  let handle =
    Render.handle ~classes:false (fun _ ->
      Bonsai_web.Bonsai.return (Label.view [ Node.text "Name" ]))
  in
  let mousedown detail =
    Handle.mousedown
      handle
      ~get_vdom:Fn.id
      ~selector:"label"
      ~extra_event_fields:
        [ "detail", Js_of_ocaml.Js.Unsafe.inject detail
        ; ( "preventDefault"
          , Js_of_ocaml.Js.Unsafe.inject
              (Js_of_ocaml.Js.wrap_callback (fun () ->
                 print_endline "default prevented")) )
        ]
  in
  print_endline "single:";
  mousedown 1;
  print_endline "double:";
  mousedown 2;
  [%expect
    {|
    single:
    double:
    default prevented
    |}]
;;
