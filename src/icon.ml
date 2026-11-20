open! Import

type t =
  | Check
  | X
  | Chevron_down
  | Chevron_up
  | Chevron_left
  | Chevron_right
  | Chevrons_up_down
  | Plus
  | Minus
  | Search
  | Info
  | Alert_triangle
  | Alert_circle
  | Check_circle
  | Sun
  | Moon
  | Copy
  | Menu
  | More_horizontal
  | Settings
  | User
  | Mail
  | Bell
  | Trash
  | Pencil
  | Arrow_right
  | Arrow_left
  | External_link
  | Github
  | Loader
  | Dot
  | Calendar
  | Home
  | Inbox
  | File
  | Folder
  | Command
[@@deriving enumerate, sexp_of, compare, equal]

let name t =
  Sexp.to_string (sexp_of_t t)
  |> String.lowercase
  |> String.map ~f:(function
    | '_' -> '-'
    | c -> c)
;;

module Shape = struct
  type t =
    | Path of string
    | Circle of float * float * float
end

let shapes : t -> Shape.t list = function
  | Check -> [ Path "M20 6 9 17l-5-5" ]
  | X -> [ Path "M18 6 6 18M6 6l12 12" ]
  | Chevron_down -> [ Path "m6 9 6 6 6-6" ]
  | Chevron_up -> [ Path "m18 15-6-6-6 6" ]
  | Chevron_left -> [ Path "m15 18-6-6 6-6" ]
  | Chevron_right -> [ Path "m9 18 6-6-6-6" ]
  | Chevrons_up_down -> [ Path "m7 15 5 5 5-5M7 9l5-5 5 5" ]
  | Plus -> [ Path "M12 5v14M5 12h14" ]
  | Minus -> [ Path "M5 12h14" ]
  | Search -> [ Circle (11., 11., 7.); Path "m20 20-3.5-3.5" ]
  | Info -> [ Circle (12., 12., 9.5); Path "M12 16v-4.5M12 8h.01" ]
  | Alert_triangle ->
    [ Path "M10.3 3.9 2.4 17.5A2 2 0 0 0 4.1 20.5h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"
    ; Path "M12 9.5v4M12 17h.01"
    ]
  | Alert_circle -> [ Circle (12., 12., 9.5); Path "M12 7.5v5M12 16h.01" ]
  | Check_circle -> [ Circle (12., 12., 9.5); Path "m8.5 12.5 2.5 2.5 4.5-5" ]
  | Sun ->
    [ Circle (12., 12., 4.)
    ; Path
        "M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"
    ]
  | Moon -> [ Path "M20.5 14.1A8.5 8.5 0 1 1 9.9 3.5a7 7 0 0 0 10.6 10.6Z" ]
  | Copy ->
    [ Path "M9 9h10a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H10a1 1 0 0 1-1-1Z"
    ; Path "M5 15H4a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v1"
    ]
  | Menu -> [ Path "M4 6h16M4 12h16M4 18h16" ]
  | More_horizontal -> [ Circle (5., 12., 1.); Circle (12., 12., 1.); Circle (19., 12., 1.) ]
  | Settings ->
    [ Circle (12., 12., 3.)
    ; Path
        "M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1Z"
    ]
  | User -> [ Circle (12., 8., 4.); Path "M4 21a8 8 0 0 1 16 0" ]
  | Mail -> [ Path "M4 5h16a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1Z"; Path "m3 7 9 6 9-6" ]
  | Bell ->
    [ Path "M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"; Path "M10.3 21a1.9 1.9 0 0 0 3.4 0" ]
  | Trash ->
    [ Path "M3 6h18M8 6V4a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v2M19 6l-1 14a1 1 0 0 1-1 1H7a1 1 0 0 1-1-1L5 6"
    ; Path "M10 11v6M14 11v6"
    ]
  | Pencil -> [ Path "M17 3a2.8 2.8 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"; Path "m15 5 4 4" ]
  | Arrow_right -> [ Path "M5 12h14M12 5l7 7-7 7" ]
  | Arrow_left -> [ Path "M19 12H5M12 19l-7-7 7-7" ]
  | External_link -> [ Path "M15 3h6v6M10 14 21 3M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" ]
  | Github ->
    [ Path
        "M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.1-1.3-.3-2.5-1-3.5.3-1.1.3-2.3 0-3.5 0 0-1 0-3 1.5-2.6-.5-5.4-.5-8 0C6 2 5 2 5 2c-.3 1.2-.3 2.4 0 3.5A5.4 5.4 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.4.5-.7 1-.8 1.6-.2.6-.3 1.3-.2 1.9v4"
    ; Path "M9 18c-4.5 2-5-2-7-2"
    ]
  | Loader -> [ Path "M21 12a9 9 0 1 1-6.2-8.6" ]
  | Dot -> [ Circle (12., 12., 3.) ]
  | Calendar ->
    [ Path "M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z"
    ; Path "M16 2v4M8 2v4M3 10h18"
    ]
  | Home -> [ Path "m3 10 9-7 9 7v10a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1Z" ]
  | Inbox ->
    [ Path "M22 12h-6l-2 3h-4l-2-3H2"
    ; Path "M5.5 5.1 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.5-6.9A2 2 0 0 0 16.8 4H7.2a2 2 0 0 0-1.7 1.1Z"
    ]
  | File -> [ Path "M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"; Path "M14 2v6h6" ]
  | Folder ->
    [ Path "M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.7-.9l-.8-1.2A2 2 0 0 0 7.9 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z" ]
  | Command ->
    [ Path "M15 6v12a3 3 0 1 0 3-3H6a3 3 0 1 0 3 3V6a3 3 0 1 0-3 3h12a3 3 0 1 0-3-3" ]
;;

let shape : Shape.t -> Node.t = function
  | Path d -> Node.create_svg "path" ~attrs:[ Attr.create "d" d ] []
  | Circle (cx, cy, r) ->
    Node.create_svg
      "circle"
      ~attrs:
        [ Attr.create "cx" (sprintf "%g" cx)
        ; Attr.create "cy" (sprintf "%g" cy)
        ; Attr.create "r" (sprintf "%g" r)
        ]
      []
;;

let view ?attrs:extra t =
  Node.create_svg
    "svg"
    ~attrs:
      (attrs ?attrs:extra [ "loon-icon"; "loon-icon-" ^ name t ]
       @ [ Attr.create "viewBox" "0 0 24 24"; aria "hidden" "true" ])
    (List.map (shapes t) ~f:shape)
;;
