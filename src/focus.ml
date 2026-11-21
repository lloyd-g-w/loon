open! Import
open Js_of_ocaml

let focusable =
  "a[href], button:not([disabled]), input:not([disabled]), \
   select:not([disabled]), textarea:not([disabled]), \
   [tabindex]:not([tabindex=\"-1\"])"
;;

let focusable_not_guard () =
  String.concat
    ~sep:", "
    (List.map (String.split focusable ~on:',') ~f:(fun s ->
       String.strip s ^ ":not([data-focus-guard])"))
;;

let in_browser () = Js.Optdef.test (Js.Unsafe.global##.document : _ Js.Optdef.t)

let focus_nth id ~last =
  Effect.of_thunk (fun () ->
    if in_browser ()
    then (
      match
        Js.Opt.to_option (Dom_html.document##getElementById (Js.string id))
      with
      | None -> ()
      | Some root ->
        let all =
          Dom.list_of_nodeList (root##querySelectorAll (Js.string focusable))
        in
        let all = if last then List.rev all else all in
        (match all with
         | el :: _ -> el##focus
         | [] -> root##focus)))
;;

let first_in id = focus_nth id ~last:false
let last_in id = focus_nth id ~last:true

let guard ~id side =
  Node.div
    ~attrs:
      [ data "focus-guard" ""
      ; Attr.style (Css_gen.create ~field:"position" ~value:"fixed")
      ; Attr.style (Css_gen.create ~field:"opacity" ~value:"0")
      ; Attr.style (Css_gen.create ~field:"outline" ~value:"none")
      ; Attr.style (Css_gen.create ~field:"pointer-events" ~value:"none")
      ; Attr.tabindex 0
      ; aria "hidden" "true"
      ; Attr.on_focus (fun _ ->
          match side with
          | `Start -> last_in id
          | `End -> first_in id)
      ]
    []
;;

let focus_no_scroll (el : Dom_html.element Js.t) : unit =
  (Js.Unsafe.coerce el)##focus
    (object%js
       val preventScroll = Js._true
     end)
;;

let active () = Js.Opt.to_option Dom_html.document##.activeElement

let focus_inside (el : Dom_html.element Js.t) mode =
  let first selector = Js.Opt.to_option (el##querySelector (Js.string selector)) in
  (* Radix's FocusScope: the first tabbable that takes the focus (not one
     hidden), links left out; else the element itself. *)
  let focus_first_tabbable () =
    let candidates =
      Dom.list_of_nodeList (el##querySelectorAll (Js.string (focusable_not_guard ())))
      |> List.filter ~f:(fun (c : Dom_html.element Js.t) ->
        not (String.equal (Js.to_string c##.tagName) "A"))
    in
    let focused =
      List.exists candidates ~f:(fun c ->
        focus_no_scroll c;
        Option.value_map (active ()) ~default:false ~f:(fun a -> phys_equal a c))
    in
    if not focused then focus_no_scroll el
  in
  match first "[data-highlighted]" with
  | Some h -> focus_no_scroll h
  | None ->
    (match mode with
     | `First_tabbable -> focus_first_tabbable ()
     | `Selector s ->
       (match first s with
        | Some t -> focus_no_scroll t
        | None -> focus_first_tabbable ())
     | `Self -> focus_no_scroll el)
;;

module Mount_hook = Vdom.Attr.Hooks.Make (struct
    module State = struct
      type t = { mutable previous : Dom_html.element Js.t option }
    end

    module Input = struct
      type t =
        [ `First_tabbable
        | `Self
        | `Selector of string
        ]
      [@@deriving sexp_of]

      let combine _ second = second
    end

    let init _ _ = { State.previous = None }

    let on_mount =
      `Schedule_immediately_after_this_dom_patch_completes
        (fun mode (state : State.t) el ->
          state.previous <- active ();
          focus_inside el mode)
    ;;

    let update ~old_input:_ ~new_input:_ _ _ = ()

    (* Radix's FocusScope: focus goes back where it was before, unless it
       has gone somewhere else meanwhile (a click on another element). Focus
       on an ancestor of where it was is lost too: when the focused element
       is removed, Incr_dom's focus stealer moves focus to the app's root. *)
    let destroy _ (state : State.t) (el : Dom_html.element Js.t) =
      let contains (outer : Dom_html.element Js.t) inner =
        Js.to_bool ((Js.Unsafe.coerce outer)##contains inner)
      in
      (* Bonsai moves the focus of a removed element to the app's root: an
         ancestor of [previous], so not a choice to go elsewhere. *)
      let lost =
        match active (), state.previous with
        | None, _ -> true
        | Some a, previous ->
          phys_equal a Dom_html.document##.body
          || contains el a
          || Option.value_map previous ~default:false ~f:(fun p ->
            (not (phys_equal a p)) && contains a p)
      in
      match state.previous with
      | Some prev when lost && Js.to_bool (Js.Unsafe.coerce prev)##.isConnected ->
        focus_no_scroll prev
      | _ -> ()
    ;;
  end)

let on_mount mode = Vdom.Attr.create_hook "loon-focus-on-mount" (Mount_hook.create mode)

let restore id =
  Effect.of_thunk (fun () ->
    if in_browser ()
    then (
      let (_ : Dom_html.animation_frame_request_id) =
        Dom_html.window##requestAnimationFrame
          (Js.wrap_callback (fun (_ : Js.number_t) ->
             (* Not when an open dialog has taken focus meanwhile (one a
                menu item opened). *)
             let target = Js.Opt.to_option (Dom_html.document##getElementById (Js.string id)) in
             let in_other_dialog =
               Js.Opt.case
                 Dom_html.document##.activeElement
                 (fun () -> false)
                 (fun a ->
                   match
                     Js.Opt.to_option
                       ((Js.Unsafe.coerce a)##closest
                          (Js.string
                             "[role=dialog][data-state=open], \
                              [role=alertdialog][data-state=open]")
                        : Dom_html.element Js.t Js.opt)
                   with
                   | None -> false
                   | Some dialog ->
                     (match target with
                      | None -> true
                      | Some target ->
                        not (Js.to_bool (dialog##contains (target :> Dom.node Js.t)))))
             in
             if not in_other_dialog
             then
               Option.iter
                 target
                 ~f:focus_no_scroll))
      in
      ()))
;;

module When_hook = Vdom.Attr.Hooks.Make (struct
    module State = Unit

    module Input = struct
      type t = bool [@@deriving sexp_of]

      let combine _ second = second
    end

    let init _ _ = ()

    let focus_if focused (el : Dom_html.element Js.t) =
      let active =
        Js.Opt.case Dom_html.document##.activeElement (fun () -> false) (fun a ->
          phys_equal a el)
      in
      if focused && not active then el##focus
    ;;

    let on_mount =
      `Schedule_immediately_after_this_dom_patch_completes
        (fun focused () el -> focus_if focused el)
    ;;

    let update ~old_input ~new_input () el =
      if new_input && not old_input then focus_if new_input el
    ;;

    let destroy _ () _ = ()
  end)

let when_ focused = Vdom.Attr.create_hook "loon-focus-when" (When_hook.create focused)
