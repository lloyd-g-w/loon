open! Core

let names = List.map Styles_data.all ~f:fst

(* Vega first. *)
let names =
  let vega, others = List.partition_tf names ~f:(String.equal "vega") in
  vega @ others
;;

let default = "vega"

let find name =
  let name = String.lowercase (String.strip name) in
  let name = String.chop_prefix_if_exists name ~prefix:"radix-" in
  List.find names ~f:(String.equal name)
;;

(* Rules of the form [.cn-x {] then [@apply ...;] lines then [}]; any other
   selector (a [:has()] or [:where()] one) is left out, as it holds only
   in some context. *)
let parse css =
  let lines = String.split_lines css in
  let rec go acc current = function
    | [] -> acc
    | line :: rest ->
      let line = String.strip line in
      (match current with
       | Some (cls, classes) ->
         if String.equal line "}"
         then (
           let classes = String.concat ~sep:" " (List.rev classes) in
           let acc =
             Map.update acc cls ~f:(function
               | None -> classes
               | Some before -> before ^ " " ^ classes)
           in
           go acc None rest)
         else (
           match String.chop_prefix line ~prefix:"@apply " with
           | Some applied ->
             let applied = String.strip (String.chop_suffix_if_exists applied ~suffix:";") in
             go acc (Some (cls, applied :: classes)) rest
           | None -> go acc current rest)
       | None ->
         (match String.chop_suffix line ~suffix:"{" with
          | Some selector ->
            let selector = String.strip selector in
            if String.is_prefix selector ~prefix:".cn-"
               && String.for_all (String.drop_prefix selector 1) ~f:(fun c ->
                    Char.is_alphanum c || Char.equal c '-')
            then go acc (Some (String.drop_prefix selector 1, [])) rest
            else go acc None rest
          | None -> go acc None rest))
  in
  go String.Map.empty None lines
;;

let maps =
  lazy (String.Map.of_alist_exn (List.map Styles_data.all ~f:(fun (n, css) -> n, parse css)))
;;

let map style =
  match Map.find (force maps) style with
  | Some m -> m
  | None -> raise_s [%message "unknown style" (style : string)]
;;

let is_cn token = String.is_prefix token ~prefix:"cn-"

(* The classes of a literal holding [cn-*] ones, with the style's merged
   in; [None] if it holds none. *)
let restyle map value =
  let tokens = String.split_on_chars value ~on:[ ' '; '\t'; '\n' ] in
  let tokens = List.filter tokens ~f:(fun t -> not (String.is_empty t)) in
  if not (List.exists tokens ~f:is_cn)
  then None
  else (
    let styled =
      List.filter_map tokens ~f:(fun t -> if is_cn t then Map.find map t else None)
    in
    let own =
      List.filter_map tokens ~f:(fun t ->
        match t with
        | "cn-font-heading" -> Some "font-heading"
        | "cn-menu-target" -> Some t
        | t when is_cn t -> None
        | t -> Some t)
    in
    Some (Cn.cn [ String.concat ~sep:" " styled; String.concat ~sep:" " own ]))
;;

(* An OCaml string literal's value from its source text (between the
   quotes): escapes decoded, a backslash-newline and the next line's
   leading blanks dropped. *)
let decode raw =
  let b = Buffer.create (String.length raw) in
  let n = String.length raw in
  let rec go i =
    if i < n
    then
      if Char.equal raw.[i] '\\' && i + 1 < n
      then (
        match raw.[i + 1] with
        | '\n' ->
          let j = ref (i + 2) in
          while !j < n && (Char.equal raw.[!j] ' ' || Char.equal raw.[!j] '\t') do
            incr j
          done;
          go !j
        | '"' | '\\' | '\'' ->
          Buffer.add_char b raw.[i + 1];
          go (i + 2)
        | 'n' ->
          Buffer.add_char b '\n';
          go (i + 2)
        | 't' ->
          Buffer.add_char b '\t';
          go (i + 2)
        | c ->
          Buffer.add_char b '\\';
          Buffer.add_char b c;
          go (i + 2))
      else (
        Buffer.add_char b raw.[i];
        go (i + 1))
  in
  go 0;
  Buffer.contents b
;;

let escape s =
  String.concat_map s ~f:(function
    | '"' -> "\\\""
    | '\\' -> "\\\\"
    | c -> String.of_char c)
;;

(* The literal's new source text, wrapped at spaces (with OCaml's
   backslash-newline) to stay within [margin] from [column], the opening
   quote's. *)
let encode ~column value =
  let margin = 90 in
  let indent = String.make (column + 1) ' ' in
  let words = String.split value ~on:' ' |> List.map ~f:escape in
  let lines =
    List.fold words ~init:[] ~f:(fun lines w ->
      match lines with
      | [] -> [ w ]
      | line :: rest ->
        if column + 1 + String.length line + 1 + String.length w + 3 > margin
        then w :: line :: rest
        else (line ^ " " ^ w) :: rest)
    |> List.rev
  in
  String.concat ~sep:(" \\\n" ^ indent) lines
;;

let inline ~style source =
  let map = map style in
  let n = String.length source in
  let out = Buffer.create (n + 4096) in
  let column i =
    match String.rindex_from source (i - 1) '\n' with
    | Some nl -> i - nl - 1
    | None -> i
    | exception _ -> i
  in
  (* [i] at a double quote: the index after the closing one. *)
  let string_end i =
    let rec go j =
      if j >= n
      then n
      else if Char.equal source.[j] '\\'
      then go (j + 2)
      else if Char.equal source.[j] '"'
      then j + 1
      else go (j + 1)
    in
    go (i + 1)
  in
  (* [i] at a [{]: the end of a quoted string [{id|...|id}], if it is
     one. *)
  let quoted_end i =
    let j = ref (i + 1) in
    while !j < n && (Char.is_lowercase source.[!j] || Char.equal source.[!j] '_') do
      incr j
    done;
    if !j < n && Char.equal source.[!j] '|'
    then (
      let close = "|" ^ String.sub source ~pos:(i + 1) ~len:(!j - i - 1) ^ "}" in
      match String.substr_index source ~pos:(!j + 1) ~pattern:close with
      | Some k -> Some (k + String.length close)
      | None -> None)
    else None
  in
  (* [i] at a ['], if it starts a character literal: its end. *)
  let char_end i =
    if i + 2 < n && Char.equal source.[i + 1] '\\'
    then String.index_from source (i + 2) '\'' |> Option.map ~f:(fun k -> k + 1)
    else if i + 2 < n && Char.equal source.[i + 2] '\''
    then Some (i + 3)
    else None
  in
  let copy i j = Buffer.add_substring out source ~pos:i ~len:(j - i) in
  (* Comments, nested, with string literals inside them skipped. *)
  let rec comment_end i depth =
    if i >= n
    then n
    else if i + 1 < n && Char.equal source.[i] '(' && Char.equal source.[i + 1] '*'
    then comment_end (i + 2) (depth + 1)
    else if i + 1 < n && Char.equal source.[i] '*' && Char.equal source.[i + 1] ')'
    then if depth = 1 then i + 2 else comment_end (i + 2) (depth - 1)
    else if Char.equal source.[i] '"'
    then comment_end (string_end i) depth
    else comment_end (i + 1) depth
  in
  let rec go i =
    if i < n
    then (
      let c = source.[i] in
      if Char.equal c '(' && i + 1 < n && Char.equal source.[i + 1] '*'
      then (
        let j = comment_end (i + 2) 1 in
        copy i j;
        go j)
      else if Char.equal c '"'
      then (
        let j = string_end i in
        let raw = String.sub source ~pos:(i + 1) ~len:(max 0 (j - i - 2)) in
        (match restyle map (decode raw) with
         | None -> copy i j
         | Some value ->
           Buffer.add_char out '"';
           Buffer.add_string out (encode ~column:(column i) value);
           Buffer.add_char out '"');
        go j)
      else if Char.equal c '{'
      then (
        match quoted_end i with
        | Some j ->
          copy i j;
          go j
        | None ->
          Buffer.add_char out c;
          go (i + 1))
      else if Char.equal c '\''
      then (
        match char_end i with
        | Some j ->
          copy i j;
          go j
        | None ->
          Buffer.add_char out c;
          go (i + 1))
      else (
        Buffer.add_char out c;
        go (i + 1)))
  in
  go 0;
  Buffer.contents out
;;

let%expect_test "inline" =
  let source =
    {|let base =
  "cn-button group/button inline-flex shrink-0 items-center \
   justify-center"
;;

(* "cn-button" in a comment stays *)
let size = function
  | Sm -> "cn-button-size-sm"
  | Default -> "cn-card-title cn-font-heading text-lg"
;;

let c = '"'
let s = {x|cn-button|x}
|}
  in
  print_string (inline ~style:"nova" source);
  [%expect {|
    let base =
      "focus-visible:border-ring focus-visible:ring-ring/50 \
       aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 \
       aria-invalid:border-destructive dark:aria-invalid:border-destructive/50 rounded-lg \
       border border-transparent bg-clip-padding text-sm font-medium focus-visible:ring-3 \
       aria-invalid:ring-3 active:not-aria-[haspopup]:translate-y-px \
       [&_svg:not([class*='size-'])]:size-4 group/button inline-flex shrink-0 items-center \
       justify-center"
    ;;

    (* "cn-button" in a comment stays *)
    let size = function
      | Sm -> "h-7 gap-1 rounded-[min(var(--radius-md),12px)] px-2.5 text-[0.8rem] \
               in-data-[slot=button-group]:rounded-lg has-data-[icon=inline-end]:pr-1.5 \
               has-data-[icon=inline-start]:pl-1.5 [&_svg:not([class*='size-'])]:size-3.5"
      | Default -> "leading-snug font-medium group-data-[size=sm]/card:text-sm font-heading \
                    text-lg"
    ;;

    let c = '"'
    let s = {x|cn-button|x}
    |}]
;;
