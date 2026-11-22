open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html (Input.view ~type_:Email ~placeholder:"Email" ());
  [%expect
    {|
    <input type="email"
           data-slot="input"
           placeholder="Email"
           class="cn-input disabled:cursor-not-allowed disabled:opacity-50 disabled:pointer-events-none file:bg-transparent file:border-0 file:inline-flex file:text-foreground min-w-0 outline-none placeholder:text-muted-foreground w-full"/>
    |}]
;;

let%expect_test
    "attributes: id, name, required, disabled, invalid, controlled value"
  =
  Render.html
    ~classes:false
    (Input.view
       ~type_:Password
       ~id:"pw"
       ~name:"password"
       ~required:true
       ~disabled:true
       ~invalid:true
       ~value:"hunter2"
       ~on_input:(fun _ -> Bonsai_web.Effect.Ignore)
       ());
  [%expect
    {|
    <input type="password"
           data-slot="input"
           id="pw"
           name="password"
           disabled=""
           required=""
           aria-invalid="true"
           #value="hunter2"
           @on_input/>
    |}]
;;

let%expect_test "every type's name" =
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
    file
    date
    time
    |}]
;;

let%expect_test "component keeps what is typed" =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Input.component ~default_value:"a" ~id:"x")
  in
  Handle.show handle;
  Drive.type_ handle "input" "hello";
  Handle.show handle;
  [%expect
    {|
    <div>
      <input type="text" data-slot="input" id="x" #value="a" @on_input/>
      <output> a </output>
    </div>
    <div>
      <input type="text" data-slot="input" id="x" #value="hello" @on_input/>
      <output> hello </output>
    </div>
    |}]
;;
