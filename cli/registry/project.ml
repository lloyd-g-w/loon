open! Core
module Entry = Registry.Entry

module Css_mode = struct
  type t =
    | Assembled
    | Files
end

let exists path = Sys_unix.file_exists_exn path

let unknown name =
  match Registry.suggest name with
  | [] -> Error.createf "unknown component %S (`loon list` shows them)" name
  | names ->
    Error.createf
      "unknown component %S: did you mean %s?"
      name
      (String.concat ~sep:" or " names)
;;

(* One message per line. *)
let errors es =
  Error.of_string (String.concat ~sep:"\n" (List.map es ~f:Error.to_string_hum))
;;

let resolve names =
  match List.filter names ~f:(fun n -> Option.is_none (Registry.find n)) with
  | [] -> Ok (Registry.closure names)
  | unknown_names -> Error (errors (List.map unknown_names ~f:unknown))
;;

let dune_file ~library =
  sprintf
    {|; Components copied from loon (https://github.com/lloyd-g-w/loon) with
; `loon add`: they are yours to change. `loon diff` shows how they differ
; from loon's.

(library
 (name %s)
 (libraries core bonsai bonsai_web virtual_dom virtual_dom.svg js_of_ocaml)
 (preprocess
  (pps ppx_jane js_of_ocaml-ppx bonsai.ppx_bonsai)))
|}
    library
;;

(* What a file write would do, for printing. *)
type outcome =
  | Wrote
  | Replaced
  | Skipped
  | Same

let say outcome path =
  match outcome with
  | Same -> ()
  | Wrote -> printf "  wrote    %s\n" path
  | Replaced -> printf "  replaced %s\n" path
  | Skipped -> printf "  skipped  %s (it exists; -overwrite replaces it)\n" path
;;

let write ~dry_run ~overwrite path contents =
  let outcome =
    if not (exists path)
    then Wrote
    else if String.equal (In_channel.read_all path) contents
    then Same
    else if overwrite
    then Replaced
    else Skipped
  in
  (match outcome with
   | Skipped | Same -> ()
   | Wrote | Replaced ->
     if not dry_run
     then (
       Core_unix.mkdir_p (Filename.dirname path);
       Out_channel.write_all path ~data:contents));
  say outcome path;
  outcome
;;

let css_path dir = dir ^/ "loon.css"

let write_css ~dir ~dry_run ~overwrite ~(css : Css_mode.t) entries =
  match css with
  | Files ->
    List.iter entries ~f:(fun (e : Entry.t) ->
      List.iter e.css ~f:(fun f ->
        ignore
          (write ~dry_run ~overwrite (dir ^/ "css" ^/ f.name) f.contents
           : outcome)))
  | Assembled ->
    let path = css_path dir in
    let existed = exists path in
    let current =
      Registry.Css.parse (if existed then In_channel.read_all path else "")
    in
    let merged, report = Registry.Css.merge current entries ~overwrite in
    (* In the stylesheet's order. *)
    let names which =
      List.filter (Registry.Css.names merged) ~f:(fun n ->
        match Map.find report n with
        | Some w -> Poly.equal w which
        | None -> false)
    in
    let changes =
      List.map (names `Added) ~f:(fun n -> "+" ^ n)
      @ List.map (names `Replaced) ~f:(fun n -> "~" ^ n)
    in
    if not (List.is_empty changes)
    then (
      if not dry_run
      then (
        Core_unix.mkdir_p dir;
        Out_channel.write_all path ~data:(Registry.Css.to_string merged));
      printf
        "  %s %s (%s)\n"
        (if existed then "updated " else "wrote   ")
        path
        (String.concat ~sep:", " changes));
    (match names `Skipped with
     | [] -> ()
     | skipped ->
       printf
         "  kept     %s's %s styles (they differ; -overwrite replaces them)\n"
         path
         (String.concat ~sep:", " skipped))
;;

let copy ~dir ~overwrite ~css ~dry_run entries =
  let same =
    List.sum
      (module Int)
      entries
      ~f:(fun (e : Entry.t) ->
        List.count e.sources ~f:(fun f ->
          match write ~dry_run ~overwrite (dir ^/ f.name) f.contents with
          | Same -> true
          | Wrote | Replaced | Skipped -> false))
  in
  if same > 0
  then
    printf
      "  (%d file%s already as loon has %s)\n"
      same
      (if same = 1 then "" else "s")
      (if same = 1 then "it" else "them");
  write_css ~dir ~dry_run ~overwrite ~css entries
;;

let css_note ~dir ~(css : Css_mode.t) entries =
  match css with
  | Assembled ->
    printf
      "\n\
       Link %s from your page (or embed it), and wrap the app in Theme.root.\n"
      (css_path dir)
  | Files ->
    let files =
      List.concat_map entries ~f:(fun (e : Entry.t) ->
        List.map e.css ~f:(fun f -> dir ^/ "css" ^/ f.name))
    in
    if not (List.is_empty files)
    then (
      printf "\nLink these stylesheets from your page, in this order:\n";
      List.iter files ~f:(printf "  %s\n"))
;;

let add ~dir ~overwrite ~css ~dry_run names =
  let open Or_error.Let_syntax in
  let%map entries = resolve names in
  let requested = List.map names ~f:Registry.canonical in
  let extra =
    List.filter_map entries ~f:(fun e ->
      Option.some_if
        (not (List.mem requested e.name ~equal:String.equal))
        e.name)
  in
  printf
    "%s %s%s\n"
    (if dry_run then "Would add" else "Adding")
    (String.concat ~sep:", " requested)
    (if List.is_empty extra
     then ""
     else sprintf " (and what it needs: %s)" (String.concat ~sep:", " extra));
  copy ~dir ~overwrite ~css ~dry_run entries;
  if not (exists (dir ^/ "dune"))
  then
    printf
      "\n%s has no dune file: `loon init -dir %s` makes it a library.\n"
      dir
      dir;
  css_note ~dir ~css entries
;;

let init ~dir ~library ~overwrite ~css =
  let open Or_error.Let_syntax in
  let%map entries = resolve [ Entry.theme ] in
  let dune = dir ^/ "dune" in
  if exists dune
  then (
    printf "Setting up %s\n" dir;
    printf "  kept     %s (it exists)\n" dune)
  else (
    printf "Setting up %s as the library %s\n" dir library;
    ignore
      (write ~dry_run:false ~overwrite:false dune (dune_file ~library)
       : outcome));
  copy ~dir ~overwrite ~css ~dry_run:false entries;
  printf "\nNow `loon add button` (`loon list` shows the components).\n";
  css_note ~dir ~css entries
;;

let installed ~dir =
  let css =
    if exists (css_path dir)
    then
      Registry.Css.names
        (Registry.Css.parse (In_channel.read_all (css_path dir)))
    else []
  in
  List.filter Registry.all ~f:(fun e ->
    List.exists e.sources ~f:(fun f -> exists (dir ^/ f.name))
    || List.mem css e.name ~equal:String.equal
    || List.exists e.css ~f:(fun f -> exists (dir ^/ "css" ^/ f.name)))
;;

let diff ~dir ~color names =
  let open Or_error.Let_syntax in
  let%map entries =
    match names with
    | [] -> Ok (installed ~dir)
    | names ->
      (match
         List.filter names ~f:(fun n -> Option.is_none (Registry.find n))
       with
       | [] -> Ok (List.filter_map names ~f:Registry.find)
       | bad -> Error (errors (List.map bad ~f:unknown)))
  in
  let css =
    if exists (css_path dir)
    then Some (Registry.Css.parse (In_channel.read_all (css_path dir)))
    else None
  in
  let same = ref true in
  let compare ~label ~path ~ours ~theirs =
    match theirs with
    | None ->
      same := false;
      printf "%s: not in %s\n" label path
    | Some theirs when String.equal theirs ours -> ()
    | Some theirs ->
      same := false;
      Option.iter
        (Unified.diff
           ~color
           ~prev_name:("loon/" ^ label)
           ~next_name:path
           ~prev:ours
           ~next:theirs
           ())
        ~f:print_string
  in
  if List.is_empty entries then printf "%s has no loon components.\n" dir;
  List.iter entries ~f:(fun (e : Entry.t) ->
    List.iter e.sources ~f:(fun f ->
      let path = dir ^/ f.name in
      compare
        ~label:f.name
        ~path
        ~ours:f.contents
        ~theirs:
          (Option.some_if (exists path) ()
           |> Option.map ~f:(fun () -> In_channel.read_all path)));
    match css with
    | Some css when not (List.is_empty e.css) ->
      let ours = Registry.Css.section (Registry.Css.of_entries [ e ]) e.name in
      compare
        ~label:(e.name ^ " in loon.css")
        ~path:(css_path dir)
        ~ours:(Option.value ours ~default:"")
        ~theirs:(Registry.Css.section css e.name)
    | _ ->
      List.iter e.css ~f:(fun f ->
        let path = dir ^/ "css" ^/ f.name in
        if exists path || Option.is_none css
        then
          compare
            ~label:f.name
            ~path
            ~ours:f.contents
            ~theirs:
              (Option.some_if (exists path) ()
               |> Option.map ~f:(fun () -> In_channel.read_all path))));
  if !same && not (List.is_empty entries)
  then
    printf
      "%s: the same as loon's.\n"
      (String.concat ~sep:", " (List.map entries ~f:(fun e -> e.name)));
  !same
;;
