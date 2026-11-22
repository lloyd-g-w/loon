open! Core

module File = struct
  type t =
    { name : string
    ; contents : string
    }
  [@@deriving sexp_of]
end

module Kind = struct
  type t =
    | Component
    | Block
    | Block_part
  [@@deriving sexp_of, equal]
end

type t =
  { name : string
  ; kind : Kind.t
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

let is_block_file path =
  String.equal (Filename.basename (Filename.dirname path)) "blocks"
;;

(* shadcn's blocks are named like [login-03]; other modules of blocks/ are
   their parts. *)
let block_kind name : Kind.t =
  match String.rsplit2 name ~on:'_' with
  | Some (category, number)
    when (not (String.is_empty category))
         && String.length number = 2
         && String.for_all number ~f:Char.is_digit
         && String.for_all category ~f:Char.is_lowercase -> Block
  | _ -> Block_part
;;

(* Modules of loon that [open! Core] or [open Bonsai_web] would hide in a
   copied block (cli/test/compile.t builds every block). *)
let hidden_by_core = [ "Command"; "Field" ]

(* A block's source as a copy has it: the components are then its library's
   own modules, so [open Loon] goes, but for those [open! Core] hides, which
   a local [Loon] keeps reachable. *)
let block_source contents =
  let lines = String.split_lines contents in
  let hidden =
    List.filter hidden_by_core ~f:(Set.mem (Scan.module_refs contents))
  in
  let lines =
    if List.is_empty hidden
    then
      List.filter lines ~f:(fun line ->
        not (String.equal (String.strip line) "open Loon"))
    else
      [ "(* The library's own modules, for [open Loon] below: [open! Core] \
         hides them. *)"
      ; "module Loon = struct"
      ]
      @ List.map hidden ~f:(fun m -> sprintf "  module %s = %s" m m)
      @ [ "end"; "" ]
      @ lines
  in
  String.concat ~sep:"\n" lines
  ^ if String.is_suffix contents ~suffix:"\n" then "\n" else ""
;;

let build files ~generated =
  let files =
    (* Not the build directory's preprocessed copies ([button.pp.ml]). *)
    List.filter files ~f:(fun (path, _) ->
      not (String.mem (Filename.chop_extension (Filename.basename path)) '.'))
    |> List.sort ~compare:(fun (a, _) (b, _) -> String.compare a b)
  in
  let block_files, files =
    List.partition_tf files ~f:(fun (p, _) -> is_block_file p)
  in
  let block_sources =
    List.filter_map block_files ~f:(fun (path, contents) ->
      let name = Filename.basename path in
      if String.equal (Filename.chop_extension name) "block"
      then None
      else Some { File.name; contents })
  in
  let block_modules =
    List.filter_map block_sources ~f:(fun f ->
      Option.some_if
        (String.is_suffix f.name ~suffix:".ml")
        (Filename.chop_extension f.name))
    |> String.Set.of_list
  in
  let kind name : Kind.t =
    if Set.mem block_modules name then block_kind name else Component
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
  (* As loon has them, for finding what they use. *)
  let sources = in_dir src_dir @ block_sources in
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
      let srcs =
        if Set.mem block_modules name
        then
          List.map (sources_of name) ~f:(fun f ->
            { f with contents = block_source f.contents })
        else sources_of name
      in
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
        ; kind = kind name
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
    ; "blocks/block.ml", "let all = [ Login_01.view ]"
    ; ( "blocks/login_01.mli"
      , "(** A login page. Port of shadcn/ui's [login-01] block. *)" )
    ; ( "blocks/login_01.ml"
      , "open! Core\nopen Loon\nlet x = (Button.view, Little_date.x)\n" )
    ; "blocks/little_date.ml", "open! Core\n  open Loon\nlet x = Calendar.x"
    ; "blocks/signup_01.ml", "open! Core\nopen Loon\nlet x = Field.group\n"
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
          ~kind:(t.kind : Kind.t)
          t.description
          ~sources:(List.map t.sources ~f:(fun f -> f.name) : string list)
          ~css:(List.map t.css ~f:(fun f -> f.name) : string list)
          ~deps:(t.deps : string list)]);
  List.iter (build files ~generated) ~f:(fun t ->
    if not (Kind.equal t.kind Component)
    then List.iter t.sources ~f:(fun f -> printf "%s:\n%s\n" f.name f.contents));
  [%expect
    {|
    (Stylesheet_contents)
    (button (kind Component) Buttons. (sources (button.ml button.mli))
     (css (button.css)) (deps (chip icon import theme)))
    (chip (kind Component) "" (sources ()) (css (chip.css)) (deps (theme)))
    (icon (kind Component) "" (sources (icon.ml)) (css ()) (deps (import theme)))
    (import (kind Component) "Opened by everything." (sources (import.ml))
     (css ()) (deps ()))
    (little_date (kind Block_part) "" (sources (little_date.ml)) (css ())
     (deps (theme)))
    (login_01 (kind Block) "A login page." (sources (login_01.ml login_01.mli))
     (css ()) (deps (button little_date theme)))
    (signup_01 (kind Block) "" (sources (signup_01.ml)) (css ()) (deps (theme)))
    (theme (kind Component) "Light or dark." (sources (theme.ml theme.mli))
     (css (00-tokens.css)) (deps (import)))
    little_date.ml:
    open! Core
    let x = Calendar.x
    login_01.ml:
    open! Core
    let x = (Button.view, Little_date.x)

    login_01.mli:
    (** A login page. Port of shadcn/ui's [login-01] block. *)
    signup_01.ml:
    (* The library's own modules, for [open Loon] below: [open! Core] hides them. *)
    module Loon = struct
      module Field = Field
    end

    open! Core
    open Loon
    let x = Field.group
    |}]
;;
