open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let%expect_test "shadcn's classes" =
  Render.html (Textarea.view ~placeholder:"Type your message here." ());
  [%expect
    {|
    <textarea data-slot="textarea"
              placeholder="Type your message here."
              class="cn-textarea disabled:cursor-not-allowed disabled:opacity-50 field-sizing-content flex min-h-16 outline-none placeholder:text-muted-foreground w-full"> </textarea>
    |}]
;;

let%expect_test "component keeps what is typed" =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Textarea.component ~id:"message" ~rows:4 ~invalid:true)
  in
  Handle.show handle;
  Drive.type_ handle "textarea" "Hi there";
  Handle.show handle;
  [%expect
    {|
    <div>
      <textarea data-slot="textarea" id="message" rows="4" aria-invalid="true" #value="" @on_input> </textarea>
      <output> "" </output>
    </div>
    <div>
      <textarea data-slot="textarea"
                id="message"
                rows="4"
                aria-invalid="true"
                #value="Hi there"
                @on_input> </textarea>
      <output> "Hi there" </output>
    </div>
    |}]
;;
