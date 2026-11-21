open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Attr = Virtual_dom.Vdom.Attr
module Handle = Bonsai_web_test.Handle

let ignore_input (_ : string) = Bonsai_web.Effect.Ignore

let%expect_test "a plain input" =
  Render.html
    (Input.view
       ~attrs:[ Attr.id "email"; Attr.name "email" ]
       ~type_:Email
       ~placeholder:"you@example.com"
       ~value:""
       ~on_input:ignore_input
       ());
  [%expect
    {|
    <input id="email"
           name="email"
           type="email"
           placeholder="you@example.com"
           class="loon-input"
           #value=""
           @on_input/>
    |}]
;;

let%expect_test "invalid and disabled" =
  Render.html (Input.view ~invalid:true ~value:"x" ~on_input:ignore_input ());
  Render.html (Input.view ~disabled:true ~value:"x" ~on_input:ignore_input ());
  [%expect
    {|
    <input type="text" aria-invalid="true" class="loon-input" #value="x" @on_input/>
    <input type="text" disabled="" class="loon-input" #value="x" @on_input/>
    |}]
;;

let%expect_test "a leading icon and a trailing addon" =
  Render.html
    (Input.view
       ~type_:Search
       ~leading:Search
       ~trailing:(Node.kbd [ Node.text "⌘K" ])
       ~value:""
       ~on_input:ignore_input
       ());
  [%expect
    {|
    <div data-disabled="false"
         class="loon-input-group loon-input-group-leading loon-input-group-trailing">
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           aria-hidden="true"
           class="loon-input-icon lucide lucide-search">
        <path d="m21 21-4.34-4.34"> </path>
        <circle cx="11" cy="11" r="8"> </circle>
      </svg>
      <input type="search" class="loon-input" #value="" @on_input/>
      <div class="loon-input-addon">
        <kbd> ⌘K </kbd>
      </div>
    </div>
    |}]
;;

let%expect_test "typing updates the component's value" =
  let handle =
    Control_render.handle
      [%sexp_of: string]
      (Input.component ~placeholder:"Name")
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: "" </span>
      <input type="text" placeholder="Name" class="loon-input" #value="" @on_input/>
    </div>
    |}];
  Handle.input_text handle ~get_vdom:Fn.id ~selector:"input" ~text:"Ada";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: "" </span>
    +|  <span> value: Ada </span>
    -|  <input type="text" placeholder="Name" class="loon-input" #value="" @on_input/>
    +|  <input type="text" placeholder="Name" class="loon-input" #value="Ada" @on_input/>
      </div>
    |}]
;;

let%expect_test "Enter runs on_enter" =
  let handle =
    Render.handle (fun _graph ->
      Bonsai_web.Bonsai.return
        (Input.view
           ~on_enter:
             (Bonsai_web.Effect.of_thunk (fun () ->
                print_s [%message "submitted"]))
           ~value:""
           ~on_input:ignore_input
           ()))
  in
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"input" ~key:Enter;
  Handle.keydown handle ~get_vdom:Fn.id ~selector:"input" ~key:KeyA;
  [%expect {| submitted |}]
;;

let%expect_test "every type" =
  List.iter Input.Type.all ~f:(fun t -> print_endline (Input.Type.name t));
  [%expect
    {|
    text
    email
    password
    search
    number
    url
    tel
    |}]
;;

let%expect_test "a textarea" =
  let handle =
    Control_render.handle
      [%sexp_of: string]
      (Textarea.component ~rows:4 ~placeholder:"Bio")
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <span> value: "" </span>
      <textarea rows="4" placeholder="Bio" class="loon-textarea" #value="" @on_input> </textarea>
    </div>
    |}];
  Handle.input_text
    handle
    ~get_vdom:Fn.id
    ~selector:"textarea"
    ~text:"Hello\nthere";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
    -|  <span> value: "" </span>
    +|  <span> value: "Hello\nthere" </span>
    -|  <textarea rows="4" placeholder="Bio" class="loon-textarea" #value="" @on_input> </textarea>
    +|  <textarea rows="4" placeholder="Bio" class="loon-textarea" #value="Hello
    +|there" @on_input> </textarea>
      </div>
    |}]
;;
