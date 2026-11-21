open! Core

type t = Customize_fonts.Font.t

let excluded = [ "instrument-serif"; "eb-garamond"; "playfair-display" ]

let all =
  List.filter Customize_fonts.all ~f:(fun (f : t) ->
    not (List.mem excluded f.name ~equal:String.equal))
;;

let find id = List.find all ~f:(fun (f : t) -> String.equal f.name id)
let value (f : t) = sprintf "var(%s), %s" f.preview_variable f.family
