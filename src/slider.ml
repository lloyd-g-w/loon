open! Import

let default_format ~step value =
  let decimals =
    let rec count step d = if d >= 6 || Float.is_integer step then d else count (step *. 10.) (d + 1) in
    count step 0
  in
  Float.to_string_hum ~decimals ~strip_zero:false value
;;

(* "100." is not a valid number to the browser, which would reset the range. *)
let number_string v =
  let s = Float.to_string v in
  Option.value (String.chop_suffix s ~suffix:".") ~default:s
;;

let view
  ?attrs:extra
  ?(min = 0.)
  ?(max = 100.)
  ?(step = 1.)
  ?(disabled = false)
  ?(show_value = false)
  ?format
  ~value
  ~on_change
  ()
  =
  let format = Option.value format ~default:(default_format ~step) in
  let value = Float.clamp_exn value ~min ~max:(Float.max min max) in
  let fill = if Float.( <= ) max min then 0. else (value -. min) /. (max -. min) *. 100. in
  let input =
    Node.input
      ~attrs:
        (attrs ?attrs:extra [ "loon-slider-input" ]
         @ [ Attr.type_ "range"
           ; Attr.min min
           ; Attr.max max
           ; Attr.step step
           ; Attr.value (number_string value)
           ; aria "valuetext" (format value)
           ; Attr.on_input (fun _ s ->
               match Float.of_string_opt s with
               | Some v -> on_change v
               | None -> Effect.Ignore)
           ]
         @ if disabled then [ Attr.disabled ] else [])
      ()
  in
  Node.div
    ~attrs:
      [ Attr.class_ "loon-slider"
      ; Attr.style
          (Css_gen.create ~field:"--loon-slider-fill" ~value:(sprintf "%.3f%%" fill))
      ; data "disabled" (Bool.to_string disabled)
      ]
    (input
     ::
     (if show_value
      then [ Node.output ~attrs:[ Attr.class_ "loon-slider-value" ] [ Node.text (format value) ] ]
      else []))
;;

let component
  ?attrs
  ?min
  ?max
  ?step
  ?disabled
  ?show_value
  ?format
  ?default
  (local_ graph)
  =
  let default = Option.value default ~default:(Option.value min ~default:0.) in
  Control.make
    ~equal:Float.equal
    default
    ~view:(fun value set ->
      view ?attrs ?min ?max ?step ?disabled ?show_value ?format ~value ~on_change:set ())
    graph
;;
