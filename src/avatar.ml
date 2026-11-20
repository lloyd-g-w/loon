open! Import
open Js_of_ocaml

module Size = struct
  type t =
    | Xs
    | Sm
    | Md
    | Lg
    | Xl
  [@@deriving enumerate, sexp_of, compare, equal]

  let name t = String.lowercase (Sexp.to_string (sexp_of_t t))
end

module Shape = struct
  type t =
    | Circle
    | Square
  [@@deriving enumerate, sexp_of, compare, equal]
end

let initials name =
  let words =
    String.split_on_chars name ~on:[ ' '; '\t'; '-'; '_'; '.' ]
    |> List.filter ~f:(fun w -> not (String.is_empty w))
  in
  let first w = String.uppercase (String.prefix w 1) in
  match words with
  | [] -> ""
  | [ w ] -> first w
  | w :: rest -> first w ^ first (List.last_exn rest)
;;

(* A stable hue per name, so that fallbacks are told apart. *)
let hue name = String.hash name % 360

(* A picture that fails to load is hidden, uncovering the initials. *)
let hide_failed (ev : Js_of_ocaml.Dom_html.event Js.t) =
  Effect.of_thunk (fun () ->
    Js.Opt.iter ev##.target (fun target ->
      target##setAttribute (Js.string "data-state") (Js.string "error")))
;;

let view ?attrs:extra ?(size = Size.Md) ?(shape = Shape.Circle) ?src ?status name =
  Node.span
    ~attrs:
      (attrs
         ?attrs:extra
         [ "loon-avatar"
         ; "loon-avatar-" ^ Size.name size
         ; (match shape with
            | Circle -> "loon-avatar-circle"
            | Square -> "loon-avatar-square")
         ]
       @ [ Attr.style (Css_gen.create ~field:"--loon-avatar-hue" ~value:(Int.to_string (hue name))) ])
    (List.filter_opt
       [ Some
           (Node.span
              ~attrs:[ Attr.class_ "loon-avatar-fallback"; aria "hidden" "true" ]
              [ Node.text (initials name) ])
       ; Option.map src ~f:(fun src ->
           Node.img
             ~attrs:
               [ Attr.class_ "loon-avatar-image"
               ; Attr.src src
               ; Attr.alt name
               ; Attr.create "loading" "lazy"
               ; Attr.on_error hide_failed
               ]
             ()
         )
       ; (match src with
          | None -> Some (Node.span ~attrs:[ Attr.class_ "loon-sr-only" ] [ Node.text name ])
          | Some _ -> None)
       ; Option.map status ~f:(fun status ->
           let status =
             match status with
             | `Online -> "online"
             | `Busy -> "busy"
             | `Away -> "away"
             | `Offline -> "offline"
           in
           Node.span
             ~attrs:
               [ Attr.classes [ "loon-avatar-status"; "loon-avatar-status-" ^ status ]
               ; Attr.title status
               ]
             [])
       ])
;;

let group ?attrs:extra ?(size = Size.Md) ?max avatars =
  let shown, hidden =
    match max with
    | Some max when List.length avatars > max -> List.take avatars max, List.drop avatars max
    | _ -> avatars, []
  in
  Node.div
    ~attrs:
      (attrs ?attrs:extra [ "loon-avatar-group"; "loon-avatar-group-" ^ Size.name size ]
       @ [ Attr.role "group" ])
    (shown
     @
     match hidden with
     | [] -> []
     | hidden ->
       [ Node.span
           ~attrs:
             [ Attr.classes
                 [ "loon-avatar"
                 ; "loon-avatar-" ^ Size.name size
                 ; "loon-avatar-circle"
                 ; "loon-avatar-more"
                 ]
             ; aria "label" (sprintf "%d more" (List.length hidden))
             ]
           [ Node.textf "+%d" (List.length hidden) ]
       ])
;;
