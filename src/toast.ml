open! Import

module Variant = struct
  type t =
    | Neutral
    | Success
    | Info
    | Warning
    | Danger
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))

  let icon : t -> Icon.t option = function
    | Neutral -> None
    | Success -> Some Check_circle
    | Info -> Some Info
    | Warning -> Some Alert_triangle
    | Danger -> Some Alert_circle
  ;;
end

type t =
  { title : string
  ; description : string option
  ; variant : Variant.t
  ; action : (string * unit Effect.t) option
  ; duration : Time_ns.Span.t option
  }

let create
  ?description
  ?(variant = Variant.Neutral)
  ?action
  ?(duration = Some (Time_ns.Span.of_sec 5.))
  title
  =
  { title; description; variant; action; duration }
;;

module Position = struct
  type t =
    | Bottom_right
    | Bottom_left
    | Top_right
    | Top_left
    | Bottom_center
    | Top_center
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t =
    String.lowercase (Sexp.to_string (sexp_of_t t)) |> String.tr ~target:'_' ~replacement:'-'
  ;;
end

module Toaster = struct
  type toast = t

  type t =
    { view : Node.t
    ; push : toast -> unit Effect.t
    ; dismiss_all : unit Effect.t
    }
end

module Entry = struct
  type t =
    { id : int
    ; toast : Toaster.toast
    ; closing : bool
    }
end

module Model = struct
  type t =
    { next_id : int
    ; entries : Entry.t list (* oldest first *)
    }

  let empty = { next_id = 0; entries = [] }
end

module Action = struct
  type t =
    | Push of Toaster.toast
    | Dismiss of int
    | Dismiss_all
    | Remove of int
end

(* How long a dismissed toast takes to leave (its exit animation). *)
let exit_time = Time_ns.Span.of_int_ms 200

let toast_view ~(entry : Entry.t) ~dismiss =
  let { title; description; variant; action; duration = _ } = entry.toast in
  Node.li
    ~key:(Int.to_string entry.id)
    ~attrs:
      [ Attr.classes [ "loon-toast"; "loon-toast-" ^ Variant.name variant ]
      ; Attr.role
          (match variant with
           | Danger | Warning -> "alert"
           | Neutral | Success | Info -> "status")
      ; aria "atomic" "true"
      ; data "state" (if entry.closing then "closed" else "open")
      ]
    (List.filter_opt
       [ Option.map (Variant.icon variant) ~f:(fun icon ->
           Icon.view ~attrs:[ Attr.class_ "loon-toast-icon" ] icon)
       ; Some
           (Node.div
              ~attrs:[ Attr.class_ "loon-toast-body" ]
              (List.filter_opt
                 [ Some (Node.div ~attrs:[ Attr.class_ "loon-toast-title" ] [ Node.text title ])
                 ; Option.map description ~f:(fun d ->
                     Node.div ~attrs:[ Attr.class_ "loon-toast-description" ] [ Node.text d ])
                 ]))
       ; Option.map action ~f:(fun (label, effect) ->
           Node.button
             ~attrs:
               [ Attr.class_ "loon-toast-action"
               ; Attr.type_ "button"
               ; Attr.on_click (fun _ -> Effect.Many [ effect; dismiss entry.id ])
               ]
             [ Node.text label ])
       ; Some
           (Node.button
              ~attrs:
                [ Attr.class_ "loon-toast-close"
                ; Attr.type_ "button"
                ; aria "label" "Dismiss"
                ; Attr.on_click (fun _ -> dismiss entry.id)
                ]
              [ Icon.view X ])
       ])
;;

let component ?(position = Position.Bottom_right) ?(max_visible = 3) (local_ graph) =
  let sleep = Bonsai.Clock.sleep graph in
  let model, inject =
    Bonsai.state_machine_with_input
      ~default_model:Model.empty
      ~apply_action:(fun ctx sleep (model : Model.t) (action : Action.t) ->
        let after span action =
          match sleep with
          | Bonsai.Computation_status.Inactive -> ()
          | Active sleep ->
            Bonsai.Apply_action_context.schedule_event
              ctx
              (let%bind.Effect () = sleep span in
               Bonsai.Apply_action_context.inject ctx action)
        in
        let closing (entry : Entry.t) =
          if not entry.closing then after exit_time (Remove entry.id);
          { entry with closing = true }
        in
        match action with
        | Push toast ->
          let id = model.next_id in
          Option.iter toast.duration ~f:(fun d -> after d (Dismiss id));
          { next_id = id + 1
          ; entries = model.entries @ [ { id; toast; closing = false } ]
          }
        | Dismiss id ->
          { model with
            entries =
              List.map model.entries ~f:(fun e -> if e.id = id then closing e else e)
          }
        | Dismiss_all -> { model with entries = List.map model.entries ~f:closing }
        | Remove id ->
          { model with entries = List.filter model.entries ~f:(fun e -> e.id <> id) })
      sleep
      graph
  in
  let open Bonsai.Let_syntax in
  let%arr model and inject in
  let dismiss id = inject (Dismiss id) in
  let shown =
    let n = List.length model.entries in
    List.drop model.entries (Int.max 0 (n - max_visible))
  in
  let view =
    Node.section
      ~attrs:
        [ Attr.classes [ "loon-toaster"; "loon-toaster-" ^ Position.name position ]
        ; aria "label" "Notifications"
        ; Attr.tabindex (-1)
        ]
      [ Node.ol
          ~attrs:[ Attr.class_ "loon-toaster-list" ]
          (List.map shown ~f:(fun entry -> toast_view ~entry ~dismiss))
      ]
  in
  { Toaster.view; push = (fun t -> inject (Push t)); dismiss_all = inject Dismiss_all }
;;
