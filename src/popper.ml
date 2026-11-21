open! Import
open Js_of_ocaml

module Side = struct
  type t =
    | Top
    | Right
    | Bottom
    | Left
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Top -> "top"
    | Right -> "right"
    | Bottom -> "bottom"
    | Left -> "left"
  ;;

  let opposite = function
    | Top -> Bottom
    | Bottom -> Top
    | Left -> Right
    | Right -> Left
  ;;
end

module Align = struct
  type t =
    | Start
    | Center
    | End
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Start -> "start"
    | Center -> "center"
    | End -> "end"
  ;;
end

module Anchor = struct
  type t =
    | Element of string
    | Point of
        { x : float
        ; y : float
        }
  [@@deriving sexp_of, equal]
end

type rect =
  { left : float
  ; top : float
  ; width : float
  ; height : float
  }

let rect_of (el : Dom_html.element Js.t) =
  let r = el##getBoundingClientRect in
  let left = Js.to_float r##.left
  and top = Js.to_float r##.top in
  { left
  ; top
  ; width = Js.to_float r##.right -. left
  ; height = Js.to_float r##.bottom -. top
  }
;;

let by_id id = Js.Opt.to_option (Dom_html.document##getElementById (Js.string id))

let anchor_rect : Anchor.t -> rect option = function
  | Element id -> Option.map (by_id id) ~f:rect_of
  | Point { x; y } -> Some { left = x; top = y; width = 0.; height = 0. }
;;

let viewport () =
  let d = Dom_html.document##.documentElement in
  Float.of_int d##.clientWidth, Float.of_int d##.clientHeight
;;

let computed (el : Dom_html.element Js.t) prop =
  let style = Dom_html.window##getComputedStyle el in
  Js.to_string ((Js.Unsafe.coerce style)##getPropertyValue (Js.string prop))
;;

(* Whether [el] is the containing block of fixed descendants (a transform,
   a filter, containment...), so that their [left] and [top] are relative
   to it rather than to the viewport. *)
let contains_fixed el =
  let set prop =
    let v = computed el prop in
    not (String.is_empty v || String.equal v "none")
  in
  let has prop words =
    let v = computed el prop in
    List.exists words ~f:(fun w -> String.is_substring v ~substring:w)
  in
  set "transform"
  || set "translate"
  || set "scale"
  || set "rotate"
  || set "perspective"
  || set "filter"
  || set "backdrop-filter"
  || has "contain" [ "paint"; "layout"; "strict"; "content" ]
  || has "will-change" [ "transform"; "filter"; "perspective" ]
  || has "container-type" [ "size"; "inline-size" ]
;;

(* Where (0, 0) of a fixed element inside [el] is, in the viewport. *)
let fixed_origin (el : Dom_html.element Js.t) =
  let rec go (node : Dom.node Js.t Js.opt) =
    match Js.Opt.to_option (Js.Opt.bind node Dom_html.CoerceTo.element) with
    | None -> 0., 0.
    | Some p when phys_equal p Dom_html.document##.documentElement -> 0., 0.
    | Some p ->
      if contains_fixed p
      then (
        let r = rect_of p in
        ( r.left +. Float.of_int p##.clientLeft -. Js.to_float p##.scrollLeft
        , r.top +. Float.of_int p##.clientTop -. Js.to_float p##.scrollTop ))
      else go p##.parentNode
  in
  go el##.parentNode
;;

let dpr () =
  let d = Js.to_float (Js.Unsafe.coerce Dom_html.window)##.devicePixelRatio in
  if Float.( > ) d 0. then d else 1.
;;

let round v =
  let d = dpr () in
  Float.round_nearest (v *. d) /. d
;;

let px v = sprintf "%gpx" (round v)

let set_style (el : Dom_html.element Js.t) name value =
  let style = Js.Unsafe.coerce el##.style in
  let old = Js.to_string (style##getPropertyValue (Js.string name)) in
  if not (String.equal old value)
  then style##setProperty (Js.string name) (Js.string value) |> ignore
;;

let set_attr (el : Dom_html.element Js.t) name value =
  let old = Js.Opt.case (el##getAttribute (Js.string name)) (fun () -> "") Js.to_string in
  if not (String.equal old value) then el##setAttribute (Js.string name) (Js.string value)
;;

let first_child (el : Dom_html.element Js.t) : Dom_html.element Js.t option =
  Js.Opt.to_option (Js.Unsafe.coerce el)##.firstElementChild
;;

let query (el : Dom_html.element Js.t) selector =
  Js.Opt.to_option (el##querySelector (Js.string selector))
;;

module Placement = struct
  type t =
    { side : Side.t
    ; side_offset : float
    ; align : Align.t
    ; align_offset : float
    ; avoid_collisions : bool
    ; collision_padding : float
    ; anchor : Anchor.t
    ; name : string
    }
  [@@deriving sexp_of]
end

let arrow_width = 10.
let arrow_height = 5.

let position (p : Placement.t) (wrapper : Dom_html.element Js.t) =
  match anchor_rect p.anchor, first_child wrapper with
  | None, _ | _, None -> ()
  | Some a, Some content ->
    let vw, vh = viewport () in
    let pad = p.collision_padding in
    let arrow = query content "[data-popper-arrow]" in
    let arrow_h = if Option.is_some arrow then arrow_height else 0. in
    let offset = p.side_offset +. arrow_h in
    let coords side ~w ~h =
      let cross = if Align.equal p.align End then -.p.align_offset else p.align_offset in
      let along start length size =
        (match p.align with
         | Start -> start
         | Center -> start +. ((length -. size) /. 2.)
         | End -> start +. length -. size)
        +. cross
      in
      match (side : Side.t) with
      | Bottom -> along a.left a.width w, a.top +. a.height +. offset
      | Top -> along a.left a.width w, a.top -. h -. offset
      | Right -> a.left +. a.width +. offset, along a.top a.height h
      | Left -> a.left -. w -. offset, along a.top a.height h
    in
    let overflow side ~w ~h =
      let x, y = coords side ~w ~h in
      match (side : Side.t) with
      | Bottom -> y +. h -. (vh -. pad)
      | Top -> pad -. y
      | Right -> x +. w -. (vw -. pad)
      | Left -> pad -. x
    in
    let w = Float.of_int wrapper##.offsetWidth
    and h = Float.of_int wrapper##.offsetHeight in
    let side =
      if not p.avoid_collisions
      then p.side
      else (
        let here = overflow p.side ~w ~h in
        let there = overflow (Side.opposite p.side) ~w ~h in
        if Float.(here <= 0.) || Float.(there >= here)
        then p.side
        else Side.opposite p.side)
    in
    let available_height, available_width =
      match side with
      | Bottom -> vh -. pad -. (a.top +. a.height +. offset), vw -. (2. *. pad)
      | Top -> a.top -. offset -. pad, vw -. (2. *. pad)
      | Right -> vh -. (2. *. pad), vw -. pad -. (a.left +. a.width +. offset)
      | Left -> vh -. (2. *. pad), a.left -. offset -. pad
    in
    let var suffix value = set_style wrapper (sprintf "--radix-%s-%s" p.name suffix) value in
    var "content-available-height" (px (Float.max 0. available_height));
    var "content-available-width" (px (Float.max 0. available_width));
    var "trigger-width" (px a.width);
    var "trigger-height" (px a.height);
    (* The size may have changed with the available height. *)
    let w = Float.of_int wrapper##.offsetWidth
    and h = Float.of_int wrapper##.offsetHeight in
    let x, y = coords side ~w ~h in
    let clamp v ~lo ~hi = if Float.(hi < lo) then lo else Float.max lo (Float.min hi v) in
    let x, y =
      if not p.avoid_collisions
      then x, y
      else (
        match side with
        | Top | Bottom ->
          let x = clamp x ~lo:pad ~hi:(vw -. pad -. w) in
          (* Radix's sticky "partial": never detached from the anchor. *)
          clamp x ~lo:(a.left -. w) ~hi:(a.left +. a.width), y
        | Left | Right ->
          let y = clamp y ~lo:pad ~hi:(vh -. pad -. h) in
          x, clamp y ~lo:(a.top -. h) ~hi:(a.top +. a.height))
    in
    let ox, oy = fixed_origin wrapper in
    set_style wrapper "left" (px (x -. ox));
    set_style wrapper "top" (px (y -. oy));
    let along =
      match p.align with
      | Start -> "0%"
      | Center -> "50%"
      | End -> "100%"
    in
    var
      "content-transform-origin"
      (match side with
       | Bottom -> sprintf "%s %s" along (px (-.arrow_h))
       | Top -> sprintf "%s %s" along (px (h +. arrow_h))
       | Right -> sprintf "%s %s" (px (-.arrow_h)) along
       | Left -> sprintf "%s %s" (px (w +. arrow_h)) along);
    set_attr content "data-side" (Side.name side);
    set_attr content "data-align" (Align.name p.align);
    Option.iter arrow ~f:(fun arrow ->
      let base = Side.name (Side.opposite side) in
      List.iter [ "top"; "bottom"; "left"; "right" ] ~f:(fun edge ->
        if not (String.equal edge base) then set_style arrow edge "");
      set_style arrow base "0";
      (match side with
       | Top | Bottom ->
         let ax = clamp (a.left +. (a.width /. 2.) -. x -. (arrow_width /. 2.)) ~lo:0. ~hi:(w -. arrow_width) in
         set_style arrow "left" (px ax)
       | Left | Right ->
         let ay =
           clamp (a.top +. (a.height /. 2.) -. y -. (arrow_width /. 2.)) ~lo:0. ~hi:(h -. arrow_width)
         in
         set_style arrow "top" (px ay));
      set_style
        arrow
        "transform-origin"
        (match side with
         | Top -> ""
         | Right -> "0 0"
         | Bottom -> "center 0"
         | Left -> "100% 0");
      set_style
        arrow
        "transform"
        (match side with
         | Top -> "translateY(100%)"
         | Right -> "translateY(50%) rotate(90deg) translateX(-50%)"
         | Bottom -> "rotate(180deg)"
         | Left -> "translateY(50%) rotate(-90deg) translateX(50%)"))
;;

(* Radix Select's item-aligned position (simplified): measured once, as the
   page does not scroll while a select is open. *)
let margin = 10.

let position_item_aligned ~anchor (wrapper : Dom_html.element Js.t) =
  match by_id anchor, first_child wrapper with
  | None, _ | _, None -> ()
  | Some trigger, Some content ->
    let vw, vh = viewport () in
    let t = rect_of trigger in
    let value =
      Option.value_map (query trigger "[data-slot=select-value]") ~default:t ~f:rect_of
    in
    let viewport_el = query content "[data-radix-select-viewport]" in
    let item =
      match query content "[role=option][data-state=checked]" with
      | Some item -> Some item
      | None -> query content "[role=option]"
    in
    set_style wrapper "max-height" (px (vh -. (2. *. margin)));
    set_style content "max-height" "100%";
    set_style wrapper "--radix-select-content-available-height" (px (vh -. (2. *. margin)));
    let c = rect_of content in
    (* Horizontally: the item's text over the trigger's value. *)
    let text_left =
      match item with
      | Some item ->
        (match Js.Opt.to_option (Js.Unsafe.coerce item)##.lastElementChild with
         | Some (text : Dom_html.element Js.t) -> (rect_of text).left
         | None -> (rect_of item).left)
      | None -> c.left
    in
    let left = value.left -. (text_left -. c.left) in
    let min_width = t.width +. (t.left -. left) in
    set_style wrapper "min-width" (px min_width);
    let width = Float.max min_width c.width in
    let left = Float.max margin (Float.min left (vw -. margin -. width)) in
    (* Vertically: the item's middle on the trigger's, scrolling the list
       when the item is far down it. *)
    let top =
      match item, viewport_el with
      | Some item, Some vp ->
        let i = rect_of item in
        let scroll = Js.to_float vp##.scrollTop in
        let item_middle = i.top -. c.top +. scroll +. (i.height /. 2.) in
        let max_scroll = Float.of_int (vp##.scrollHeight - vp##.clientHeight) in
        let target = t.top +. (t.height /. 2.) in
        let top = target -. item_middle in
        let scroll =
          if Float.(top < margin)
          then Float.min max_scroll (margin -. top)
          else 0.
        in
        vp##.scrollTop := Js.float scroll;
        target -. (item_middle -. scroll)
      | _ -> t.top
    in
    let height = Float.of_int content##.offsetHeight in
    let top = Float.min top (vh -. margin -. height) in
    let top = Float.max margin top in
    let ox, oy = fixed_origin wrapper in
    set_style wrapper "left" (px (left -. ox));
    set_style wrapper "top" (px (top -. oy))
;;

module Mode = struct
  type t =
    | Popper of Placement.t
    | Item_aligned of string
  [@@deriving sexp_of]
end

module Hook = Vdom.Attr.Hooks.Make (struct
    module State = struct
      type t =
        { mutable mode : Mode.t
        ; mutable frame : Dom_html.animation_frame_request_id option
        ; mutable frames : int
        }
    end

    module Input = struct
      type t = Mode.t [@@deriving sexp_of]

      let combine _ second = second
    end

    let init mode _ = { State.mode; frame = None; frames = 0 }

    let rec tick (state : State.t) el () =
      state.frames <- state.frames + 1;
      (match state.mode with
       | Popper p -> position p el
       | Item_aligned anchor -> if state.frames <= 2 then position_item_aligned ~anchor el);
      state.frame
      <- Some
           (Dom_html.window##requestAnimationFrame
              (Js.wrap_callback (fun (_ : Js.number_t) -> tick state el ())))
    ;;

    let on_mount =
      `Schedule_immediately_after_this_dom_patch_completes
        (fun _ (state : State.t) el ->
          set_style el "position" "fixed";
          set_style el "left" "0";
          set_style el "top" "0";
          set_style el "min-width" "max-content";
          set_style el "z-index" "50";
          (match state.mode with
           | Popper _ -> ()
           | Item_aligned _ ->
             set_style el "display" "flex";
             set_style el "flex-direction" "column");
          tick state el ())
    ;;

    let update ~old_input:_ ~new_input (state : State.t) _ = state.mode <- new_input

    let destroy _ (state : State.t) _ =
      Option.iter state.frame ~f:(fun id -> Dom_html.window##cancelAnimationFrame id);
      state.frame <- None
    ;;
  end)

let hook mode = Vdom.Attr.create_hook "loon-popper" (Hook.create mode)

let wrapper
  ?(side = Side.Bottom)
  ?(side_offset = 0.)
  ?(align = Align.Center)
  ?(align_offset = 0.)
  ?(avoid_collisions = true)
  ?(collision_padding = 0.)
  ?(attrs = [])
  ~name
  ~anchor
  content
  =
  Node.div
    ~attrs:
      ([ Attr.create "data-radix-popper-content-wrapper" ""
       ; hook
           (Popper
              { side
              ; side_offset
              ; align
              ; align_offset
              ; avoid_collisions
              ; collision_padding
              ; anchor
              ; name
              })
       ]
       @ attrs)
    [ content ]
;;

let item_aligned_wrapper ?(attrs = []) ~name:_ ~anchor content =
  Node.div
    ~attrs:
      ([ Attr.create "data-radix-popper-content-wrapper" ""
       ; hook (Item_aligned anchor)
       ]
       @ attrs)
    [ content ]
;;

let content_attrs ?(side = Side.Bottom) ?(align = Align.Center) () =
  [ data "side" (Side.name side); data "align" (Align.name align) ]
;;

let arrow ?class_ () =
  Node.span
    ~attrs:[ Attr.create "data-popper-arrow" ""; Attr.style (Css_gen.position `Absolute) ]
    [ Node.create_svg
        "svg"
        ~attrs:
          ([ Attr.create "width" "10"
           ; Attr.create "height" "5"
           ; Attr.create "viewBox" "0 0 30 10"
           ; Attr.create "preserveAspectRatio" "none"
           ; Attr.style (Css_gen.display `Block)
           ]
           @ Option.value_map class_ ~default:[] ~f:(fun c -> [ Cn.attr [ c ] ]))
        [ Node.create_svg "polygon" ~attrs:[ Attr.create "points" "0,0 30,0 15,10" ] [] ]
    ]
;;
