open! Core

let is_word_start text i =
  i = 0
  ||
  let prev = text.[i - 1] in
  (not (Char.is_alphanum prev))
  || (Char.is_lowercase prev && Char.is_uppercase text.[i])
;;

let score ~query text =
  let query =
    String.filter query ~f:(fun c -> not (Char.is_whitespace c)) |> String.lowercase
  in
  let lower = String.lowercase text in
  let n = String.length lower in
  let rec go qi ti prev_match acc =
    if qi >= String.length query
    then Some acc
    else if ti >= n
    then None
    else if Char.equal query.[qi] lower.[ti]
    then (
      let bonus =
        1
        + (if is_word_start text ti then 8 else 0)
        + (if prev_match = ti - 1 then 5 else 0)
        + if ti = 0 then 6 else 0
      in
      go (qi + 1) (ti + 1) ti (acc + bonus))
    else go qi (ti + 1) prev_match acc
  in
  match go 0 0 (-2) 0 with
  | None -> None
  | Some s ->
    (* shorter texts are closer matches *)
    Some ((s * 4) - (n / 4) + if String.equal query lower then 50 else 0)
;;

let rank ~query items ~fields =
  if String.is_empty (String.strip query)
  then items
  else
    List.filter_mapi items ~f:(fun i item ->
      let scores =
        List.filter_mapi (fields item) ~f:(fun rank field ->
          Option.map (score ~query field) ~f:(fun s -> s - (rank * 10)))
      in
      Option.map (List.max_elt scores ~compare:Int.compare) ~f:(fun s -> s, i, item))
    |> List.sort ~compare:(fun (s1, i1, _) (s2, i2, _) ->
      match Int.compare s2 s1 with
      | 0 -> Int.compare i1 i2
      | c -> c)
    |> List.map ~f:(fun (_, _, item) -> item)
;;
