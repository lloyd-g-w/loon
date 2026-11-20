open! Import

module Item = struct
  type t =
    { value : string
    ; label : string
    ; disabled : bool
    }

  let create ?(disabled = false) ~value label = { value; label; disabled }
end

let view
  ?attrs:extra
  ?(disabled = false)
  ?(invalid = false)
  ?placeholder
  ~value
  ~on_change
  (items : Item.t list)
  =
  let matched = List.exists items ~f:(fun item -> String.equal item.value value) in
  let option ?(disabled = false) ~selected v label =
    Node.option
      ~attrs:
        ([ Attr.value v ]
         @ (if selected then [ Attr.selected ] else [])
         @ if disabled then [ Attr.disabled ] else [])
      [ Node.text label ]
  in
  let placeholder =
    match placeholder with
    | None -> []
    | Some p -> [ option ~disabled:true ~selected:(not matched) "" p ]
  in
  Node.div
    ~attrs:[ Attr.class_ "loon-native-select"; data "disabled" (Bool.to_string disabled) ]
    [ Node.select
        ~attrs:
          (attrs ?attrs:extra [ "loon-native-select-control" ]
           @ [ Attr.value value
             ; Attr.on_change (fun _ v -> on_change v)
             ; data "placeholder" (Bool.to_string (not matched))
             ]
           @ (if disabled then [ Attr.disabled ] else [])
           @ if invalid then [ aria "invalid" "true" ] else [])
        (placeholder
         @ List.map items ~f:(fun item ->
           option
             ~disabled:item.disabled
             ~selected:(String.equal item.value value)
             item.value
             item.label))
    ; Icon.view ~attrs:[ Attr.class_ "loon-native-select-chevron" ] Chevrons_up_down
    ]
;;

let component ?attrs ?disabled ?placeholder ?(default = "") items (local_ graph) =
  Control.make
    ~equal:String.equal
    default
    ~view:(fun value set ->
      view ?attrs ?disabled ?placeholder ~value ~on_change:set items)
    graph
;;
