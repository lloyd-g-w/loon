open! Core

module Framework = struct
  type t =
    | Next
    | Vite
    | Start
    | Laravel
    | React_router
    | Astro
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Next -> "next"
    | Vite -> "vite"
    | Start -> "start"
    | Laravel -> "laravel"
    | React_router -> "react-router"
    | Astro -> "astro"
  ;;

  let title = function
    | Next -> "Next.js"
    | Vite -> "Vite"
    | Start -> "TanStack Start"
    | Laravel -> "Laravel"
    | React_router -> "React Router"
    | Astro -> "Astro"
  ;;

  let of_name s = List.find all ~f:(fun t -> String.equal (name t) s)
end

module Package_manager = struct
  type t =
    | Pnpm
    | Npm
    | Yarn
    | Bun
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Pnpm -> "pnpm"
    | Npm -> "npm"
    | Yarn -> "yarn"
    | Bun -> "bun"
  ;;

  (* JavaScript's [String.replace] with a string: the first occurrence. *)
  let replace s ~pattern ~with_ =
    match String.substr_index s ~pattern with
    | None -> s
    | Some i ->
      String.prefix s i
      ^ with_
      ^ String.drop_prefix s (i + String.length pattern)
  ;;

  let command t command =
    match t with
    | Pnpm ->
      replace
        (replace command ~pattern:"npm install" ~with_:"pnpm add")
        ~pattern:"npx"
        ~with_:"pnpm dlx"
    | Yarn ->
      replace
        (replace command ~pattern:"npm install" ~with_:"yarn add")
        ~pattern:"npx"
        ~with_:"yarn dlx"
    | Bun ->
      replace
        (replace command ~pattern:"npm install" ~with_:"bun add")
        ~pattern:"npx"
        ~with_:"bunx --bun"
    | Npm -> command
  ;;
end

let css_url = "https://ui.shadcn.com/typeset.css"
let docs_url = "https://ui.shadcn.com/docs/typeset"

let picked_fonts (p : Typeset_params.t) =
  [ p.body; p.heading; p.mono ]
  |> List.filter ~f:(fun id ->
    (not (String.equal id "inherit")) && Option.is_some (Typeset_fonts.find id))
  |> List.stable_dedup ~compare:String.compare
  |> List.filter_map ~f:Customize_fonts.find
;;

let preset_name (p : Typeset_params.t) = "typeset-" ^ p.item

let preset_css (p : Typeset_params.t) =
  let heading_id =
    if String.equal p.heading "inherit" then p.body else p.heading
  in
  sprintf
    ".%s {\n\
    \  --typeset-font-body: var(--font-%s);\n\
    \  --typeset-font-heading: var(--font-%s);\n\
    \  --typeset-font-mono: var(--font-%s);\n\
    \  --typeset-size: %spx;\n\
    \  --typeset-leading: %s;\n\
    \  --typeset-flow: %s;\n\
     }"
    (preset_name p)
    p.body
    heading_id
    p.mono
    p.scale
    p.leading
    p.flow
;;

let preset p =
  sprintf
    "/* globals.css */\n\
     @import \"tailwindcss\";\n\
     @import \"./typeset.css\";\n\n\
     %s"
    (preset_css p)
;;

let usage (p : Typeset_params.t) =
  (* shadcn interpolates [undefined] for a measure it does not know. *)
  let width =
    Option.value (Typeset_params.measure_width p.measure) ~default:"undefined"
  in
  sprintf
    "<div className=\"typeset %s max-w-[%s]\">\n  {content}\n</div>"
    (preset_name p)
    width
;;

(* [-(\w)] to its capital: "geist-mono" -> "geistMono". *)
let camel_case name =
  let b = Buffer.create (String.length name) in
  let n = String.length name in
  let rec go i =
    if i < n
    then
      if
        Char.equal name.[i] '-'
        && i + 1 < n
        && (Char.is_alphanum name.[i + 1] || Char.equal name.[i + 1] '_')
      then (
        Buffer.add_char b (Char.uppercase name.[i + 1]);
        go (i + 2))
      else (
        Buffer.add_char b name.[i];
        go (i + 1))
  in
  go 0;
  Buffer.contents b
;;

let json_strings l =
  "[" ^ String.concat ~sep:"," (List.map l ~f:(sprintf "%S")) ^ "]"
;;

let next_font_code (fonts : Customize_fonts.Font.t list) =
  String.concat
    ~sep:"\n"
    ([ "// app/layout.tsx"
     ; sprintf
         "import { %s } from \"next/font/google\""
         (String.concat ~sep:", " (List.map fonts ~f:(fun f -> f.import)))
     ; ""
     ]
     @ List.map fonts ~f:(fun f ->
       String.concat
         ~sep:"\n"
         ([ sprintf "const %s = %s({" (camel_case f.name) f.import
          ; sprintf "  subsets: %s," (json_strings [ "latin" ])
          ]
          @ (if List.is_empty f.weight
             then []
             else [ sprintf "  weight: %s," (json_strings f.weight) ])
          @ [ sprintf "  variable: \"--font-%s\"," f.name; "})"; "" ]))
     @ [ sprintf
           "<html className={`%s`}>"
           (String.concat
              ~sep:" "
              (List.map fonts ~f:(fun f ->
                 sprintf "${%s.variable}" (camel_case f.name))))
       ])
;;

let fontsource_command (fonts : Customize_fonts.Font.t list) =
  "npm install "
  ^ String.concat ~sep:" " (List.map fonts ~f:(fun f -> f.dependency))
;;

let fontsource_css (fonts : Customize_fonts.Font.t list) =
  String.concat
    ~sep:"\n"
    ([ "/* globals.css */" ]
     @ List.map fonts ~f:(fun f -> sprintf "@import \"%s\";" f.dependency)
     @ [ ""; ":root {" ]
     @ List.map fonts ~f:(fun f -> sprintf "  --font-%s: %s;" f.name f.family)
     @ [ "}" ])
;;

let prompt p (framework : Framework.t) =
  let fonts = picked_fonts p in
  let font_step =
    match framework with
    | Next ->
      "Load the fonts in the root layout and update the HTML element:\n\n"
      ^ next_font_code fonts
    | _ ->
      sprintf
        "Install the fonts:\n\n\
         %s\n\n\
         Then import them in the main CSS file:\n\n\
         %s"
        (fontsource_command fonts)
        (fontsource_css fonts)
  in
  let name = preset_name p in
  String.concat
    [ "Install shadcn/typeset in this project.\n\n\
       Typeset is a single stylesheet that styles rendered markdown: wrap the \
       output in a `typeset` container and everything inside (headings, lists, \
       tables, code, blockquotes, math) is styled. Everything outside is \
       untouched.\n\n\
       1. Download "
    ; css_url
    ; " and save it as typeset.css next to the project's main CSS file (where \
       Tailwind is imported). If the file already exists, replace it with the \
       downloaded copy.\n\n\
       2. Import it in the main CSS file, after the Tailwind import:\n\n\
       @import \"./typeset.css\";\n\n\
       3. "
    ; font_step
    ; "\n\n\
       4. Add this preset to the main CSS file, after the typeset import. If a \
       class named ."
    ; name
    ; " already exists, update its values in place. Leave any other typeset-* \
       presets untouched: they are separate surfaces:\n\n"
    ; preset_css p
    ; "\n\n\
       5. Do not apply the class anywhere yet. Search the project for surfaces \
       that render markdown or rich content: react-markdown, Streamdown, or \
       MDX components, dangerouslySetInnerHTML with parsed markdown, prose \
       classes, CMS content renderers. Present the candidates you find as a \
       short list and ask the user which surface should use typeset. Then wrap \
       only the surface they pick:\n\n"
    ; usage p
    ; "\n\n\
       If the picked surface already has its own typography (a prose class, \
       styled markdown components), list those styles and let the user decide \
       what to remove before wrapping.\n\n\
       Notes:\n\n\
       - To exclude an embedded component from typeset styles, add the \
       not-typeset class or the data-not-typeset attribute to it.\n\
       - Verify on the surface the user picked: headings, lists, tables, and \
       code inside the container should be styled with no classes on the \
       content itself.\n\
       - Docs: "
    ; docs_url
    ]
;;
