open! Import

module Size = struct
  type t =
    | Sm
    | Md
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

let view
      ?attrs:extra
      ?(size = Size.Md)
      ?(disabled = false)
      ?label
      ~checked
      ~on_change
      ()
  =
  let switch =
    Node.button
      ~attrs:
        (attrs ?attrs:extra [ "loon-switch"; "loon-switch-" ^ Size.name size ]
         @ [ Attr.type_ "button"
           ; Attr.role "switch"
           ; aria_bool "checked" checked
           ; data "state" (if checked then "checked" else "unchecked")
           ]
         @
         if disabled
         then [ Attr.disabled ]
         else [ Attr.on_click (fun _ -> on_change (not checked)) ])
      [ Node.span ~attrs:[ Attr.class_ "loon-switch-thumb" ] [] ]
  in
  match label with
  | None -> switch
  | Some label ->
    Node.label
      ~attrs:
        [ Attr.class_ "loon-switch-label"
        ; data "disabled" (Bool.to_string disabled)
        ]
      [ switch; Node.span [ Node.text label ] ]
;;

let component ?attrs ?size ?disabled ?label ?(default = false) (local_ graph) =
  Control.make
    ~equal:Bool.equal
    default
    ~view:(fun checked set ->
      view ?attrs ?size ?disabled ?label ~checked ~on_change:set ())
    graph
;;
