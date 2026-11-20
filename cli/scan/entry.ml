open! Core

module File = struct
  type t =
    { name : string
    ; contents : string
    }
  [@@deriving sexp_of]
end

type t =
  { name : string
  ; description : string
  ; sources : File.t list
  ; css : File.t list
  ; deps : string list
  }
[@@deriving sexp_of]

let theme = "theme"
let module_name file = String.capitalize (Filename.chop_extension file)

let generated_modules dune =
  (* Every word ending in [.ml] after "(target" or "(targets". *)
  let words =
    String.map dune ~f:(function
      | '(' | ')' | '\n' | '\t' -> ' '
      | c -> c)
    |> String.split ~on:' '
    |> List.filter ~f:(Fn.non String.is_empty)
  in
  let rec go acc ~in_target = function
    | [] -> acc
    | ("target" | "targets") :: rest -> go acc ~in_target:true rest
    | w :: rest when in_target && String.is_suffix w ~suffix:".ml" ->
      go (Set.add acc (module_name w)) ~in_target:true rest
    | w :: rest when in_target && String.mem w '.' ->
      go acc ~in_target:true rest
    | _ :: rest -> go acc ~in_target:false rest
  in
  go String.Set.empty ~in_target:false words
;;

let build files ~generated =
  let files =
    (* Not the build directory's preprocessed copies ([button.pp.ml]). *)
    List.filter files ~f:(fun (path, _) ->
      not (String.mem (Filename.chop_extension (Filename.basename path)) '.'))
    |> List.sort ~compare:(fun (a, _) (b, _) -> String.compare a b)
  in
  let in_dir dir =
    List.filter_map files ~f:(fun (path, contents) ->
      if String.equal (Filename.dirname path) dir
      then Some { File.name = Filename.basename path; contents }
      else None)
  in
  let src_dir =
    match
      List.find files ~f:(fun (p, _) -> String.is_suffix p ~suffix:".ml")
    with
    | Some (p, _) -> Filename.dirname p
    | None -> "src"
  in
  let sources = in_dir src_dir in
  let css_files = in_dir (Filename.concat src_dir "css") in
  let is_theme_css (f : File.t) = Char.is_digit f.name.[0] in
  let modules =
    List.filter_map sources ~f:(fun f ->
      Option.some_if
        (String.is_suffix f.name ~suffix:".ml"
         && not (Set.mem generated (module_name f.name)))
        (Filename.chop_extension f.name))
    |> String.Set.of_list
    |> Set.to_list
  in
  let module_set = String.Set.of_list (List.map modules ~f:String.capitalize) in
  let sources_of name =
    List.filter sources ~f:(fun f ->
      String.equal f.name (name ^ ".ml") || String.equal f.name (name ^ ".mli"))
  in
  let css_of name =
    if String.equal name theme
    then List.filter css_files ~f:is_theme_css
    else List.filter css_files ~f:(fun f -> String.equal f.name (name ^ ".css"))
  in
  (* Entries: every module, the theme, and stylesheets with no module. *)
  let names =
    let css_only =
      List.filter_map css_files ~f:(fun f ->
        if is_theme_css f then None else Some (Filename.chop_extension f.name))
    in
    String.Set.of_list ((theme :: modules) @ css_only) |> Set.to_list
  in
  let classes_owner =
    let by_length =
      List.sort names ~compare:(fun a b ->
        Int.compare (String.length b) (String.length a))
    in
    fun class_ ->
      List.find by_length ~f:(fun name ->
        let prefix = "loon-" ^ String.tr name ~target:'_' ~replacement:'-' in
        String.equal class_ prefix
        || String.is_prefix class_ ~prefix:(prefix ^ "-"))
  in
  let owned_classes =
    List.map names ~f:(fun name ->
      let classes =
        List.concat_map (css_of name) ~f:(fun f ->
          Set.to_list (Scan.css_classes f.contents))
        |> List.filter ~f:(fun c ->
          match classes_owner c with
          | Some owner -> String.equal owner name
          | None -> String.equal name theme)
      in
      name, classes)
  in
  let direct_deps name =
    let srcs = sources_of name in
    let module_deps =
      List.concat_map srcs ~f:(fun f ->
        Set.to_list (Scan.module_refs f.contents))
      |> List.filter ~f:(Set.mem module_set)
      |> List.map ~f:String.uncapitalize
    in
    let literals =
      List.concat_map srcs ~f:(fun f ->
        Set.to_list (Scan.class_literals f.contents))
    in
    let class_deps =
      List.filter_map owned_classes ~f:(fun (owner, classes) ->
        Option.some_if
          (List.exists literals ~f:(fun literal ->
             List.exists classes ~f:(fun class_ ->
               Scan.literal_matches ~literal ~class_)))
          owner)
    in
    module_deps @ class_deps
    |> List.filter ~f:(fun d -> not (String.equal d name))
    |> String.Set.of_list
  in
  let direct =
    String.Map.of_alist_exn (List.map names ~f:(fun n -> n, direct_deps n))
  in
  (* Modules using a generated module (directly or not) cannot be copied. *)
  let uses_generated =
    let bad =
      List.filter modules ~f:(fun name ->
        List.exists (sources_of name) ~f:(fun f ->
          Set.exists (Scan.module_refs f.contents) ~f:(Set.mem generated)))
    in
    let rec spread bad =
      let more =
        List.filter names ~f:(fun n ->
          (not (Set.mem bad n))
          && Set.exists (Map.find_exn direct n) ~f:(Set.mem bad))
      in
      if List.is_empty more
      then bad
      else spread (Set.union bad (String.Set.of_list more))
    in
    spread (String.Set.of_list bad)
  in
  let theme_needs =
    let rec go seen = function
      | [] -> seen
      | n :: rest when Set.mem seen n -> go seen rest
      | n :: rest ->
        go (Set.add seen n) (Set.to_list (Map.find_exn direct n) @ rest)
    in
    go String.Set.empty [ theme ]
  in
  List.filter_map names ~f:(fun name ->
    if Set.mem uses_generated name
    then None
    else (
      let srcs = sources_of name in
      let deps =
        if Set.mem theme_needs name
        then Map.find_exn direct name
        else Set.add (Map.find_exn direct name) theme
      in
      let description =
        let doc ext =
          List.find_map srcs ~f:(fun f ->
            if String.is_suffix f.name ~suffix:ext
            then Scan.description f.contents
            else None)
        in
        match Option.first_some (doc ".mli") (doc ".ml") with
        | Some d -> d
        | None when String.equal name theme ->
          "The theme's variables and base styles."
        | None -> ""
      in
      Some
        { name
        ; description
        ; sources = srcs
        ; css = css_of name
        ; deps = Set.to_list (Set.diff deps uses_generated)
        }))
;;

let%expect_test "build" =
  let files =
    [ "src/import.ml", "(** Opened by everything. *)\ninclude Core"
    ; "src/theme.mli", "(** Light or dark. *)\nopen! Import"
    ; "src/theme.ml", "open! Import\nlet c = \"loon-dark\""
    ; "src/button.mli", "(** Buttons. And more. *)\nopen! Import"
    ; ( "src/button.ml"
      , "open! Import\nlet x = [ Icon.view; \"loon-chip\"; \"loon-spin\" ]" )
    ; "src/icon.ml", "open! Import"
    ; "src/stylesheet.ml", "let css = Stylesheet_contents.css"
    ; "src/uses_stylesheet.ml", "let css = Stylesheet.css"
    ; "src/stylesheet_contents.ml", "let css = {||}"
    ; "src/css/00-tokens.css", ".loon-dark { } .loon-spin { }"
    ; "src/button.pp.ml", "(* a build artefact *)"
    ; "src/css/button.css", ".loon-button { } .loon-button-sm .loon-icon { }"
    ; "src/css/chip.css", ".loon-chip { }"
    ]
  in
  let generated =
    generated_modules "(rule (target stylesheet_contents.ml) (deps x.css))"
  in
  print_s [%sexp (generated : String.Set.t)];
  List.iter (build files ~generated) ~f:(fun t ->
    print_s
      [%message
        t.name
          t.description
          ~sources:(List.map t.sources ~f:(fun f -> f.name) : string list)
          ~css:(List.map t.css ~f:(fun f -> f.name) : string list)
          ~deps:(t.deps : string list)]);
  [%expect
    {|
    (Stylesheet_contents)
    (button Buttons. (sources (button.ml button.mli)) (css (button.css))
     (deps (chip icon import theme)))
    (chip "" (sources ()) (css (chip.css)) (deps (theme)))
    (icon "" (sources (icon.ml)) (css ()) (deps (import theme)))
    (import "Opened by everything." (sources (import.ml)) (css ()) (deps ()))
    (theme "Light or dark." (sources (theme.ml theme.mli)) (css (00-tokens.css))
     (deps (import)))
    |}]
;;
