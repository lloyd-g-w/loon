open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let ignore_ _ = Bonsai_web.Effect.Ignore

let%expect_test "shadcn's classes" =
  Render.html (Checkbox.view ~id:"terms" ~checked:Checked ~on_change:ignore_ ());
  [%expect
    {|
    <button type="button"
            role="checkbox"
            aria-checked="true"
            data-state="checked"
            data-slot="checkbox"
            id="terms"
            class="after:-inset-x-3 after:-inset-y-2 after:absolute cn-checkbox disabled:cursor-not-allowed disabled:opacity-50 outline-none peer relative shrink-0"
            #value="on"
            @on_click
            @on_keydown>
      <span data-state="checked"
            data-slot="checkbox-indicator"
            class="cn-checkbox-indicator grid place-content-center text-current transition-none"
            style={
              pointer-events: none;
            }>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             class="lucide lucide-check">
          <path d="M20 6 9 17l-5-5"> </path>
        </svg>
      </span>
    </button>
    |}]
;;

let%expect_test
    "states: unchecked, checked, indeterminate; disabled, required, invalid"
  =
  List.iter Checkbox.State.all ~f:(fun checked ->
    Render.html ~classes:false (Checkbox.view ~checked ~on_change:ignore_ ()));
  Render.html
    ~classes:false
    (Checkbox.view
       ~disabled:true
       ~required:true
       ~invalid:true
       ~checked:Unchecked
       ~on_change:ignore_
       ());
  [%expect
    {|
    <button type="button"
            role="checkbox"
            aria-checked="true"
            data-state="checked"
            data-slot="checkbox"
            #value="on"
            @on_click
            @on_keydown>
      <span data-state="checked" data-slot="checkbox-indicator" style={ pointer-events: none; }>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="M20 6 9 17l-5-5"> </path>
        </svg>
      </span>
    </button>
    <button type="button"
            role="checkbox"
            aria-checked="false"
            data-state="unchecked"
            data-slot="checkbox"
            #value="on"
            @on_click
            @on_keydown> </button>
    <button type="button"
            role="checkbox"
            aria-checked="mixed"
            data-state="indeterminate"
            data-slot="checkbox"
            #value="on"
            @on_click
            @on_keydown>
      <span data-state="indeterminate" data-slot="checkbox-indicator" style={ pointer-events: none; }>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round">
          <path d="M20 6 9 17l-5-5"> </path>
        </svg>
      </span>
    </button>
    <button type="button"
            role="checkbox"
            aria-checked="false"
            aria-required="true"
            data-state="unchecked"
            data-slot="checkbox"
            aria-invalid="true"
            data-disabled=""
            disabled=""
            #value="on"
            @on_keydown> </button>
    |}]
;;

let%expect_test "a click toggles; an indeterminate box becomes checked" =
  let handle =
    Control_render.handle Bool.sexp_of_t (Checkbox.component ~id:"c")
  in
  Handle.show handle;
  Drive.click handle "#c";
  Handle.show handle;
  Drive.click handle "#c";
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              role="checkbox"
              aria-checked="false"
              data-state="unchecked"
              data-slot="checkbox"
              id="c"
              #value="on"
              @on_click
              @on_keydown> </button>
      <output> false </output>
    </div>
    <div>
      <button type="button"
              role="checkbox"
              aria-checked="true"
              data-state="checked"
              data-slot="checkbox"
              id="c"
              #value="on"
              @on_click
              @on_keydown>
        <span data-state="checked" data-slot="checkbox-indicator" style={ pointer-events: none; }>
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round">
            <path d="M20 6 9 17l-5-5"> </path>
          </svg>
        </span>
      </button>
      <output> true </output>
    </div>
    <div>
      <button type="button"
              role="checkbox"
              aria-checked="false"
              data-state="unchecked"
              data-slot="checkbox"
              id="c"
              #value="on"
              @on_click
              @on_keydown> </button>
      <output> false </output>
    </div>
    |}];
  let clicked = ref [] in
  let indeterminate =
    Checkbox.view
      ~checked:Indeterminate
      ~on_change:(fun b ->
        clicked := b :: !clicked;
        Bonsai_web.Effect.Ignore)
      ()
  in
  let handle =
    Render.handle ~classes:false (fun _ ->
      Bonsai_web.Bonsai.return indeterminate)
  in
  Drive.click handle "button";
  print_s [%sexp (!clicked : bool list)];
  [%expect {| (true) |}]
;;

let%expect_test "a disabled box has no click handler" =
  let handle =
    Control_render.handle
      Bool.sexp_of_t
      (Checkbox.component ~id:"c" ~disabled:true)
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <button type="button"
              role="checkbox"
              aria-checked="false"
              data-state="unchecked"
              data-slot="checkbox"
              id="c"
              data-disabled=""
              disabled=""
              #value="on"
              @on_keydown> </button>
      <output> false </output>
    </div>
    |}]
;;

let%expect_test "Enter does not toggle (Radix: only Space, the button's click)" =
  let handle =
    Control_render.handle Bool.sexp_of_t (Checkbox.component ~id:"c")
  in
  Drive.key handle "#c" Enter;
  Render.html ~classes:false ~selector:"output" (Handle.last_result handle);
  [%expect
    {|
    ("default prevented" (key Enter))
    <output> false </output>
    |}]
;;
