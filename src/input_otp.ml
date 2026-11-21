open! Import
open Js_of_ocaml

module Pattern = struct
  type t =
    | Digits
    | Chars
    | Digits_and_chars
  [@@deriving enumerate, sexp_of, compare, equal]

  let regexp = function
    | Digits -> "^\\d+$"
    | Chars -> "^[a-zA-Z]+$"
    | Digits_and_chars -> "^[a-zA-Z0-9]+$"
  ;;

  let matches t s =
    String.for_all s ~f:(fun c ->
      match t with
      | Digits -> Char.is_digit c
      | Chars -> Char.is_alpha c
      | Digits_and_chars -> Char.is_alphanum c)
  ;;
end

type t =
  { value : string
  ; focused : bool
  ; max_length : int
  }

let style fields =
  Attr.style
    (Css_gen.concat (List.map fields ~f:(fun (field, value) -> Css_gen.create ~field ~value)))
;;

(* On the event's [<input>]; tests' fake events have none. *)
let on_target (ev : Dom_html.event Js.t) f =
  Effect.of_thunk (fun () ->
    match (Js.Unsafe.get ev "target" : Dom_html.inputElement Js.t) with
    | exception _ -> ()
    | input -> (try f input with _ -> ()))
;;

let set_input_value ev value = on_target ev (fun input -> input##.value := Js.string value)

let caret_to_end ev =
  on_target ev (fun input ->
    let n = input##.value##.length in
    input##setSelectionRange n n)
;;

let view
  ?(attrs = [])
  ?class_
  ?container_class
  ?id
  ?(disabled = false)
  ?pattern
  ~max_length
  ~value
  ~focused
  ~on_change
  ~on_focus_change
  children
  =
  let t = { value; focused; max_length } in
  let on_input ev s =
    let s = String.prefix s max_length in
    match pattern with
    | Some p when (not (String.is_empty s)) && not (Pattern.matches p s) ->
      set_input_value ev value
    | _ -> on_change s
  in
  let opt f = Option.value_map ~default:[] ~f:(fun x -> [ f x ]) in
  Node.div
    ~attrs:
      [ data "input-otp-container" "true"
      ; Cn.with_class
          ?class_:container_class
          [ "flex items-center gap-2 has-disabled:opacity-50" ]
      ; style
          [ "position", "relative"
          ; "cursor", if disabled then "default" else "text"
          ; "user-select", "none"
          ; "-webkit-user-select", "none"
          ; "pointer-events", "none"
          ]
      ]
    (children t
     @ [ Node.div
           ~attrs:[ style [ "position", "absolute"; "inset", "0"; "pointer-events", "none" ] ]
           [ Node.input
               ~attrs:
                 ([ Attr.create "autocomplete" "one-time-code"
                  ; Cn.with_class ?class_ [ "disabled:cursor-not-allowed" ]
                  ; data "input-otp" "true"
                  ; Attr.create
                      "inputmode"
                      (match pattern with
                       | None | Some Digits -> "numeric"
                       | Some (Chars | Digits_and_chars) -> "text")
                  ; Attr.create "maxlength" (Int.to_string max_length)
                  ; data "slot" "input-otp"
                  ; Attr.value value
                  ; style
                      [ "position", "absolute"
                      ; "inset", "0"
                      ; "width", "100%"
                      ; "height", "100%"
                      ; "display", "flex"
                      ; "text-align", "left"
                      ; "opacity", "1"
                      ; "color", "transparent"
                      ; "pointer-events", "all"
                      ; "background", "transparent"
                      ; "caret-color", "transparent"
                      ; "border", "0 solid transparent"
                      ; "outline", "0 solid transparent"
                      ; "box-shadow", "none"
                      ; "line-height", "1"
                      ; "letter-spacing", "-.5em"
                      ; "font-size", "36px"
                      ; "font-family", "monospace"
                      ; "font-variant-numeric", "tabular-nums"
                      ]
                  ; Attr.on_input on_input
                  ; Attr.on_focus (fun ev ->
                      Effect.Many [ on_focus_change true; caret_to_end (ev :> Dom_html.event Js.t) ])
                  ; Attr.on_blur (fun _ -> on_focus_change false)
                  ]
                  @ opt (fun p -> Attr.create "pattern" (Pattern.regexp p)) pattern
                  @ opt Attr.id id
                  @ (if disabled then [ Attr.disabled ] else [])
                  @ attrs)
               ()
           ]
       ])
;;

let component
  ?attrs
  ?class_
  ?container_class
  ?id
  ?disabled
  ?pattern
  ?(default_value = "")
  ~max_length
  children
  (local_ graph)
  =
  let open Bonsai.Let_syntax in
  let value, set = Bonsai.state default_value ~equal:String.equal graph in
  let focused, set_focused = Bonsai.state false ~equal:Bool.equal graph in
  let%arr value and set and focused and set_focused and children in
  { Control.value
  ; set
  ; view =
      view
        ?attrs
        ?class_
        ?container_class
        ?id
        ?disabled
        ?pattern
        ~max_length
        ~value
        ~focused
        ~on_change:set
        ~on_focus_change:set_focused
        children
  }
;;

let group ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "input-otp-group"; Cn.with_class ?class_ [ "flex items-center" ] ]
       @ attrs)
    children
;;

let slot ?(attrs = []) ?class_ t ~index =
  let char =
    if index < String.length t.value then Some (String.of_char t.value.[index]) else None
  in
  let active =
    t.focused && index = Int.min (String.length t.value) (t.max_length - 1)
  in
  Node.div
    ~attrs:
      ([ data "slot" "input-otp-slot"
       ; data "active" (Bool.to_string active)
       ; Cn.with_class
           ?class_
           [ "relative flex h-9 w-9 items-center justify-center border-y border-r \
              border-input text-sm shadow-xs transition-all outline-none \
              first:rounded-l-md first:border-l last:rounded-r-md \
              aria-invalid:border-destructive data-[active=true]:z-10 \
              data-[active=true]:border-ring data-[active=true]:ring-[3px] \
              data-[active=true]:ring-ring/50 data-[active=true]:aria-invalid:border-destructive \
              data-[active=true]:aria-invalid:ring-destructive/20 dark:bg-input/30 \
              dark:data-[active=true]:aria-invalid:ring-destructive/40"
           ]
       ]
       @ attrs)
    (Option.value_map char ~default:[] ~f:(fun c -> [ Node.text c ])
     @
     if active && Option.is_none char
     then
       [ Node.div
           ~attrs:
             [ Attr.class_
                 "pointer-events-none absolute inset-0 flex items-center justify-center"
             ]
           [ Node.div
               ~attrs:[ Attr.class_ "h-4 w-px animate-caret-blink bg-foreground duration-1000" ]
               []
           ]
       ]
     else [])
;;

let separator ?(attrs = []) () =
  Node.div
    ~attrs:([ data "slot" "input-otp-separator"; Attr.role "separator" ] @ attrs)
    [ Icon.view Minus ]
;;
