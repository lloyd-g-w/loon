open! Core
open Loon
module Handle = Bonsai_web_test.Handle

let slots ?(n = 6) () =
  Bonsai_web.Bonsai.return (fun otp ->
    [ Input_otp.group
        (List.init (n / 2) ~f:(fun index -> Input_otp.slot otp ~index))
    ; Input_otp.separator ()
    ; Input_otp.group
        (List.init
           (n - (n / 2))
           ~f:(fun i -> Input_otp.slot otp ~index:(i + (n / 2))))
    ])
;;

let%expect_test "shadcn's classes" =
  let handle =
    Control_render.handle
      ~classes:true
      String.sexp_of_t
      (Input_otp.component ~max_length:2 ~default_value:"1" (slots ~n:2 ()))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div data-input-otp-container="true"
           class="flex gap-2 has-disabled:opacity-50 items-center"
           style={
             position: relative;
             cursor: text;
             user-select: none;
             -webkit-user-select: none;
             pointer-events: none;
           }>
        <div data-slot="input-otp-group" class="flex items-center">
          <div data-slot="input-otp-slot"
               data-active="false"
               class="aria-invalid:border-destructive border-input border-r border-y dark:bg-input/30 dark:data-[active=true]:aria-invalid:ring-destructive/40 data-[active=true]:aria-invalid:border-destructive data-[active=true]:aria-invalid:ring-destructive/20 data-[active=true]:border-ring data-[active=true]:ring-[3px] data-[active=true]:ring-ring/50 data-[active=true]:z-10 first:border-l first:rounded-l-md flex h-9 items-center justify-center last:rounded-r-md outline-none relative shadow-xs text-sm transition-all w-9"> 1 </div>
        </div>
        <div data-slot="input-otp-separator" role="separator">
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
               class="lucide lucide-minus">
            <path d="M5 12h14"> </path>
          </svg>
        </div>
        <div data-slot="input-otp-group" class="flex items-center">
          <div data-slot="input-otp-slot"
               data-active="false"
               class="aria-invalid:border-destructive border-input border-r border-y dark:bg-input/30 dark:data-[active=true]:aria-invalid:ring-destructive/40 data-[active=true]:aria-invalid:border-destructive data-[active=true]:aria-invalid:ring-destructive/20 data-[active=true]:border-ring data-[active=true]:ring-[3px] data-[active=true]:ring-ring/50 data-[active=true]:z-10 first:border-l first:rounded-l-md flex h-9 items-center justify-center last:rounded-r-md outline-none relative shadow-xs text-sm transition-all w-9"> </div>
        </div>
        <div style={ position: absolute; inset: 0; pointer-events: none; }>
          <input autocomplete="one-time-code"
                 data-input-otp="true"
                 inputmode="numeric"
                 maxlength="2"
                 data-slot="input-otp"
                 class="disabled:cursor-not-allowed"
                 #value="1"
                 @on_blur
                 @on_focus
                 @on_input
                 style={
                   position: absolute;
                   inset: 0;
                   width: 100%;
                   height: 100%;
                   display: flex;
                   text-align: left;
                   opacity: 1;
                   color: transparent;
                   pointer-events: all;
                   background: transparent;
                   caret-color: transparent;
                   border: 0 solid transparent;
                   outline: 0 solid transparent;
                   box-shadow: none;
                   line-height: 1;
                   letter-spacing: -.5em;
                   font-size: 36px;
                   font-family: monospace;
                   font-variant-numeric: tabular-nums;
                 }/>
        </div>
      </div>
      <output> 1 </output>
    </div>
    |}]
;;

let%expect_test
    "typing fills the slots; the focused one where the next goes shows a caret"
  =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Input_otp.component ~max_length:6 (slots ()))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div data-input-otp-container="true"
           style={
             position: relative;
             cursor: text;
             user-select: none;
             -webkit-user-select: none;
             pointer-events: none;
           }>
        <div data-slot="input-otp-group">
          <div data-slot="input-otp-slot" data-active="false"> </div>
          <div data-slot="input-otp-slot" data-active="false"> </div>
          <div data-slot="input-otp-slot" data-active="false"> </div>
        </div>
        <div data-slot="input-otp-separator" role="separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true">
            <path d="M5 12h14"> </path>
          </svg>
        </div>
        <div data-slot="input-otp-group">
          <div data-slot="input-otp-slot" data-active="false"> </div>
          <div data-slot="input-otp-slot" data-active="false"> </div>
          <div data-slot="input-otp-slot" data-active="false"> </div>
        </div>
        <div style={ position: absolute; inset: 0; pointer-events: none; }>
          <input autocomplete="one-time-code"
                 data-input-otp="true"
                 inputmode="numeric"
                 maxlength="6"
                 data-slot="input-otp"
                 #value=""
                 @on_blur
                 @on_focus
                 @on_input
                 style={
                   position: absolute;
                   inset: 0;
                   width: 100%;
                   height: 100%;
                   display: flex;
                   text-align: left;
                   opacity: 1;
                   color: transparent;
                   pointer-events: all;
                   background: transparent;
                   caret-color: transparent;
                   border: 0 solid transparent;
                   outline: 0 solid transparent;
                   box-shadow: none;
                   line-height: 1;
                   letter-spacing: -.5em;
                   font-size: 36px;
                   font-family: monospace;
                   font-variant-numeric: tabular-nums;
                 }/>
        </div>
      </div>
      <output> "" </output>
    </div>
    |}];
  Handle.focus handle ~get_vdom:Fn.id ~selector:"input";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div data-input-otp-container="true"
             style={
               position: relative;
               cursor: text;
               user-select: none;
               -webkit-user-select: none;
               pointer-events: none;
             }>
          <div data-slot="input-otp-group">
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
    +|      <div data-slot="input-otp-slot" data-active="true">
    +|        <div>
    +|          <div> </div>
    +|        </div>
    +|      </div>
            <div data-slot="input-otp-slot" data-active="false"> </div>
            <div data-slot="input-otp-slot" data-active="false"> </div>
          </div>
          <div data-slot="input-otp-separator" role="separator">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M5 12h14"> </path>
            </svg>
    |}];
  Drive.type_ handle "input" "12";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div data-input-otp-container="true"
             style={
               position: relative;
               cursor: text;
               user-select: none;
               -webkit-user-select: none;
               pointer-events: none;
             }>
          <div data-slot="input-otp-group">
    +|      <div data-slot="input-otp-slot" data-active="false"> 1 </div>
    +|      <div data-slot="input-otp-slot" data-active="false"> 2 </div>
            <div data-slot="input-otp-slot" data-active="true">
              <div>
                <div> </div>
              </div>
            </div>
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
          </div>
          <div data-slot="input-otp-separator" role="separator">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M5 12h14"> </path>
            </svg>
          </div>
          <div data-slot="input-otp-group">
            <div data-slot="input-otp-slot" data-active="false"> </div>
            <div data-slot="input-otp-slot" data-active="false"> </div>
            <div data-slot="input-otp-slot" data-active="false"> </div>
          </div>
          <div style={ position: absolute; inset: 0; pointer-events: none; }>
            <input autocomplete="one-time-code"
                   data-input-otp="true"
                   inputmode="numeric"
                   maxlength="6"
                   data-slot="input-otp"
    -|             #value=""
    +|             #value="12"
                   @on_blur
                   @on_focus
                   @on_input
                   style={
                     position: absolute;
                     inset: 0;
                     width: 100%;
                     height: 100%;
                     display: flex;
                     text-align: left;
                     opacity: 1;
                     color: transparent;
                     pointer-events: all;
                     background: transparent;
                     caret-color: transparent;
                     border: 0 solid transparent;
                     outline: 0 solid transparent;
                     box-shadow: none;
                     line-height: 1;
                     letter-spacing: -.5em;
                     font-size: 36px;
                     font-family: monospace;
                     font-variant-numeric: tabular-nums;
                   }/>
          </div>
        </div>
    -|  <output> "" </output>
    +|  <output> 12 </output>
      </div>
    |}];
  (* Past max_length the rest is dropped; the last slot stays active. *)
  Drive.type_ handle "input" "12345678";
  Handle.show_diff handle;
  [%expect
    {|
      <div>
        <div data-input-otp-container="true"
             style={
               position: relative;
               cursor: text;
               user-select: none;
               -webkit-user-select: none;
               pointer-events: none;
             }>
          <div data-slot="input-otp-group">
            <div data-slot="input-otp-slot" data-active="false"> 1 </div>
            <div data-slot="input-otp-slot" data-active="false"> 2 </div>
    -|      <div data-slot="input-otp-slot" data-active="true">
    -|        <div>
    -|          <div> </div>
    -|        </div>
    -|      </div>
    +|      <div data-slot="input-otp-slot" data-active="false"> 3 </div>
          </div>
          <div data-slot="input-otp-separator" role="separator">
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M5 12h14"> </path>
            </svg>
          </div>
          <div data-slot="input-otp-group">
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
    +|      <div data-slot="input-otp-slot" data-active="false"> 4 </div>
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
    +|      <div data-slot="input-otp-slot" data-active="false"> 5 </div>
    -|      <div data-slot="input-otp-slot" data-active="false"> </div>
    +|      <div data-slot="input-otp-slot" data-active="true"> 6 </div>
          </div>
          <div style={ position: absolute; inset: 0; pointer-events: none; }>
            <input autocomplete="one-time-code"
                   data-input-otp="true"
                   inputmode="numeric"
                   maxlength="6"
                   data-slot="input-otp"
    -|             #value="12"
    +|             #value="123456"
                   @on_blur
                   @on_focus
                   @on_input
                   style={
                     position: absolute;
                     inset: 0;
                     width: 100%;
                     height: 100%;
                     display: flex;
                     text-align: left;
                     opacity: 1;
                     color: transparent;
                     pointer-events: all;
                     background: transparent;
                     caret-color: transparent;
                     border: 0 solid transparent;
                     outline: 0 solid transparent;
                     box-shadow: none;
                     line-height: 1;
                     letter-spacing: -.5em;
                     font-size: 36px;
                     font-family: monospace;
                     font-variant-numeric: tabular-nums;
                   }/>
          </div>
        </div>
    -|  <output> 12 </output>
    +|  <output> 123456 </output>
      </div>
    |}];
  Handle.blur handle ~get_vdom:Fn.id ~selector:"input";
  Handle.show_diff handle;
  [%expect
    {|
            <svg xmlns="http://www.w3.org/2000/svg"
                 width="24"
                 height="24"
                 viewBox="0 0 24 24"
                 fill="none"
                 stroke="currentColor"
                 stroke-width="2"
                 stroke-linecap="round"
                 stroke-linejoin="round"
                 aria-hidden="true">
              <path d="M5 12h14"> </path>
            </svg>
          </div>
          <div data-slot="input-otp-group">
            <div data-slot="input-otp-slot" data-active="false"> 4 </div>
            <div data-slot="input-otp-slot" data-active="false"> 5 </div>
    -|      <div data-slot="input-otp-slot" data-active="true"> 6 </div>
    +|      <div data-slot="input-otp-slot" data-active="false"> 6 </div>
          </div>
          <div style={ position: absolute; inset: 0; pointer-events: none; }>
            <input autocomplete="one-time-code"
                   data-input-otp="true"
                   inputmode="numeric"
                   maxlength="6"
                   data-slot="input-otp"
                   #value="123456"
                   @on_blur
                   @on_focus
                   @on_input
                   style={
                     position: absolute;
                     inset: 0;
                     width: 100%;
                     height: 100%;
    |}]
;;

let%expect_test "a pattern refuses other characters" =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Input_otp.component ~max_length:6 ~pattern:Digits (slots ()))
  in
  Drive.type_ handle "input" "12";
  Drive.type_ handle "input" "12a";
  Render.html ~classes:false ~selector:"output" (Handle.last_result handle);
  Drive.type_ handle "input" "";
  Render.html ~classes:false ~selector:"output" (Handle.last_result handle);
  [%expect
    {|
    <output> 12 </output>
    <output> "" </output>
    |}];
  List.iter Input_otp.Pattern.all ~f:(fun p ->
    print_s
      [%sexp
        (Input_otp.Pattern.regexp p : string)
      , (List.map [ "123"; "abc"; "a1"; "a-1" ] ~f:(Input_otp.Pattern.matches p)
         : bool list)]);
  [%expect
    {|
    ("^\\d+$" (true false false false))
    (^[a-zA-Z]+$ (false true false false))
    (^[a-zA-Z0-9]+$ (true true true false))
    |}]
;;

let%expect_test "disabled" =
  let handle =
    Control_render.handle
      String.sexp_of_t
      (Input_otp.component
         ~max_length:2
         ~disabled:true
         ~id:"otp"
         (slots ~n:2 ()))
  in
  Handle.show handle;
  [%expect
    {|
    <div>
      <div data-input-otp-container="true"
           style={
             position: relative;
             cursor: default;
             user-select: none;
             -webkit-user-select: none;
             pointer-events: none;
           }>
        <div data-slot="input-otp-group">
          <div data-slot="input-otp-slot" data-active="false"> </div>
        </div>
        <div data-slot="input-otp-separator" role="separator">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true">
            <path d="M5 12h14"> </path>
          </svg>
        </div>
        <div data-slot="input-otp-group">
          <div data-slot="input-otp-slot" data-active="false"> </div>
        </div>
        <div style={ position: absolute; inset: 0; pointer-events: none; }>
          <input autocomplete="one-time-code"
                 data-input-otp="true"
                 inputmode="numeric"
                 maxlength="2"
                 data-slot="input-otp"
                 id="otp"
                 disabled=""
                 #value=""
                 @on_blur
                 @on_focus
                 @on_input
                 style={
                   position: absolute;
                   inset: 0;
                   width: 100%;
                   height: 100%;
                   display: flex;
                   text-align: left;
                   opacity: 1;
                   color: transparent;
                   pointer-events: all;
                   background: transparent;
                   caret-color: transparent;
                   border: 0 solid transparent;
                   outline: 0 solid transparent;
                   box-shadow: none;
                   line-height: 1;
                   letter-spacing: -.5em;
                   font-size: 36px;
                   font-family: monospace;
                   font-variant-numeric: tabular-nums;
                 }/>
        </div>
      </div>
      <output> "" </output>
    </div>
    |}]
;;
