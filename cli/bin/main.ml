open! Core
open Loon_registry

let dir_flag =
  Command.Param.(
    flag
      "dir"
      (optional_with_default "src/ui" string)
      ~doc:"DIR the project's directory of components (default: src/ui)")
;;

let overwrite_flag =
  Command.Param.(
    flag
      "overwrite"
      no_arg
      ~doc:" replace files (and loon.css sections) that exist")
;;

let ok_or_exit = function
  | Ok () -> ()
  | Error e ->
    eprintf "loon: %s\n" (Error.to_string_hum e);
    exit 1
;;

let list =
  Command.basic
    ~summary:"list the components"
    (let%map_open.Command () = return () in
     fun () ->
       let width =
         List.fold Registry.all ~init:0 ~f:(fun w e ->
           Int.max w (String.length e.name))
       in
       List.iter Registry.all ~f:(fun e ->
         printf "%-*s  %s\n" width e.name e.description))
;;

let info =
  Command.basic
    ~summary:"what a component is, its files and what it needs"
    (let%map_open.Command name = anon ("COMPONENT" %: string) in
     fun () ->
       match Registry.find name with
       | None -> ok_or_exit (Error (Project.unknown name))
       | Some e ->
         printf "%s: %s\n" e.name e.description;
         printf
           "files: %s\n"
           (String.concat
              ~sep:" "
              (List.map (e.sources @ e.css) ~f:(fun f -> f.name)));
         printf "uses: %s\n" (String.concat ~sep:" " e.deps);
         printf
           "`loon add %s` adds: %s\n"
           e.name
           (String.concat
              ~sep:" "
              (List.map (Registry.closure [ e.name ]) ~f:(fun e -> e.name))))
;;

let add =
  Command.basic
    ~summary:"copy components (and what they need) into your project"
    ~readme:(fun () ->
      "Copies each COMPONENT's .ml and .mli, and those of the components it \
       uses, into DIR, and their styles (the theme, and any a component has beyond \
       its Tailwind classes) into DIR/loon.css, Tailwind's input. Files that exist are kept, so your changes are safe: \
       -overwrite replaces them. `loon diff` shows how your copies differ from \
       loon's.")
    (let%map_open.Command dir = dir_flag
     and overwrite = overwrite_flag
     and dry_run =
       flag "dry-run" no_arg ~doc:" print what it would do, and do nothing"
     and all = flag "all" no_arg ~doc:" every component"
     and names = anon (sequence ("COMPONENT" %: string)) in
     fun () ->
       let names =
         if all
         then List.map Registry.all ~f:(fun e -> e.name) @ names
         else names
       in
       if List.is_empty names
       then
         ok_or_exit
           (Or_error.error_string "which components? (`loon list` shows them)")
       else ok_or_exit (Project.add ~dir ~overwrite ~dry_run names))
;;

let init =
  Command.basic
    ~summary:"make a directory a dune library of components, with the theme"
    (let%map_open.Command dir = dir_flag
     and overwrite = overwrite_flag
     and library =
       flag
         "library"
         (optional_with_default "ui" string)
         ~doc:"NAME the library's name (default: ui)"
     in
     fun () -> ok_or_exit (Project.init ~dir ~library ~overwrite))
;;

let diff =
  Command.basic
    ~summary:"show how your copies of components differ from loon's"
    ~readme:(fun () ->
      "Compares the project's copy of each COMPONENT (every one it has, by \
       default) with loon's. Exits 1 if they differ.")
    (let%map_open.Command dir = dir_flag
     and color =
       flag "color" no_arg ~doc:" colour the output (the default on a terminal)"
     and names = anon (sequence ("COMPONENT" %: string)) in
     fun () ->
       let color = color || Core_unix.isatty Core_unix.stdout in
       match Project.diff ~dir ~color names with
       | Ok true -> ()
       | Ok false -> exit 1
       | Error e -> ok_or_exit (Error e))
;;

let css =
  Command.basic
    ~summary:"print loon.css: Tailwind's input (the theme, and sonner's styles)"
    (let%map_open.Command () = return () in
     fun () -> print_string (Registry.Css.full ()))
;;

let () =
  Command_unix.run
    (Command.group
       ~summary:"loon: components for Bonsai_web, copied into your project"
       ~readme:(fun () ->
         "Start with `loon init`, then `loon add button tabs`. The components \
          are plain OCaml in your tree: change them as you like.")
       [ "list", list
       ; "info", info
       ; "add", add
       ; "init", init
       ; "diff", diff
       ; "css", css
       ])
;;
