open! Import

module State = struct
  type t =
    | Checked
    | Unchecked
    | Indeterminate
  [@@deriving enumerate, sexp_of, compare, equal]

  let of_bool b = if b then Checked else Unchecked

  let aria = function
    | Checked -> "true"
    | Unchecked -> "false"
    | Indeterminate -> "mixed"
  ;;

  let name = function
    | Checked -> "checked"
    | Unchecked -> "unchecked"
    | Indeterminate -> "indeterminate"
  ;;
end

let view
      ?attrs:extra
      ?(disabled = false)
      ?label
      ~(state : State.t)
      ~on_change
      ()
  =
  let box =
    Node.button
      ~attrs:
        (attrs ?attrs:extra [ "loon-checkbox" ]
         @ [ Attr.type_ "button"
           ; Attr.role "checkbox"
           ; aria "checked" (State.aria state)
           ; data "state" (State.name state)
           ]
         @
         if disabled
         then [ Attr.disabled ]
         else
           [ Attr.on_click (fun _ ->
               on_change
                 (match state with
                  | Checked -> false
                  | Unchecked | Indeterminate -> true))
           ])
      (match state with
       | Unchecked -> []
       | Checked ->
         [ Icon.view ~attrs:[ Attr.class_ "loon-checkbox-mark" ] Check ]
       | Indeterminate ->
         [ Icon.view ~attrs:[ Attr.class_ "loon-checkbox-mark" ] Minus ])
  in
  match label with
  | None -> box
  | Some label ->
    Node.label
      ~attrs:
        [ Attr.class_ "loon-checkbox-label"
        ; data "disabled" (Bool.to_string disabled)
        ]
      [ box; Node.span [ Node.text label ] ]
;;

let component ?attrs ?disabled ?label ?(default = false) (local_ graph) =
  Control.make
    ~equal:Bool.equal
    default
    ~view:(fun value set ->
      view
        ?attrs
        ?disabled
        ?label
        ~state:(State.of_bool value)
        ~on_change:set
        ())
    graph
;;
