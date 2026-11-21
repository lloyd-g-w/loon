open! Core
module Node_helpers = Virtual_dom_test_helpers.Node_helpers

let print node =
  let node = Node_helpers.unsafe_convert_exn node in
  let slots = Queue.create () in
  let counts = String.Table.create () in
  let text = Buffer.create 1024 in
  let rec walk : Node_helpers.t -> unit = function
    | Text s ->
      Buffer.add_string text s;
      Buffer.add_char text ' '
    | Widget -> ()
    | Element e ->
      (match List.Assoc.find e.attributes "data-slot" ~equal:String.equal with
       | None -> ()
       | Some slot ->
         if not (Hashtbl.mem counts slot) then Queue.enqueue slots slot;
         Hashtbl.incr counts slot);
      List.iter e.children ~f:walk
  in
  walk node;
  print_endline "slots:";
  Queue.iter slots ~f:(fun slot ->
    printf
      "  %s%s\n"
      slot
      (match Hashtbl.find_exn counts slot with
       | 1 -> ""
       | n -> sprintf " x%d" n));
  print_endline "text:";
  let words =
    String.split_on_chars (Buffer.contents text) ~on:[ ' '; '\n'; '\t' ]
    |> List.filter ~f:(fun w -> not (String.is_empty w))
  in
  let line = Buffer.create 80 in
  let flush () =
    if Buffer.length line > 0 then printf "  %s\n" (Buffer.contents line);
    Buffer.clear line
  in
  List.iter words ~f:(fun w ->
    if Buffer.length line > 0 && Buffer.length line + 1 + String.length w > 76
    then flush ();
    if Buffer.length line > 0 then Buffer.add_char line ' ';
    Buffer.add_string line w);
  flush ()
;;

let handle name =
  let block = Option.value_exn (Loon_blocks.Block.find name) in
  Bonsai_web_test.Handle.create
    (Bonsai_web_test.Result_spec.sexp
       (module struct
         type t = Virtual_dom.Vdom.Node.t

         let sexp_of_t _ = Sexp.Atom "<block>"
       end))
    block.view
;;

let show handle = print (Bonsai_web_test.Handle.last_result handle)
