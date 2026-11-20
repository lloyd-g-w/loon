open! Import

let symbol key =
  match String.lowercase key with
  | "cmd" | "command" | "meta" | "super" -> Some "⌘"
  | "shift" -> Some "⇧"
  | "alt" | "option" | "opt" -> Some "⌥"
  | "ctrl" | "control" -> Some "⌃"
  | "enter" | "return" -> Some "↵"
  | "backspace" -> Some "⌫"
  | "tab" -> Some "⇥"
  | "esc" | "escape" -> Some "Esc"
  | "up" | "arrowup" -> Some "↑"
  | "down" | "arrowdown" -> Some "↓"
  | "left" | "arrowleft" -> Some "←"
  | "right" | "arrowright" -> Some "→"
  | _ -> None
;;

let view ?attrs:extra key =
  Node.kbd ~attrs:(attrs ?attrs:extra [ "loon-kbd" ]) [ Node.text key ]
;;

let combo ?attrs:extra ?(symbols = true) keys =
  let key name =
    match symbol name with
    | Some s when symbols && not (String.equal s name) ->
      Node.kbd
        ~attrs:[ Attr.class_ "loon-kbd"; Attr.title name; aria "label" name ]
        [ Node.text s ]
    | _ -> view name
  in
  Node.kbd
    ~attrs:(attrs ?attrs:extra [ "loon-kbd-combo" ])
    (List.map keys ~f:key)
;;
