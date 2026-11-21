open! Core
open Js_of_ocaml

let in_browser () = Js.Optdef.test (Js.Unsafe.global##.document : _ Js.Optdef.t)
let hash () = Js.to_string Dom_html.window##.location##.hash
let set_hash h = Dom_html.window##.location##.hash := Js.string h

let storage () =
  try Js.Optdef.to_option Dom_html.window##.localStorage with
  | _ -> None
;;

let get_item key =
  match storage () with
  | None -> None
  | Some s ->
    (try Js.Opt.to_option (s##getItem (Js.string key)) |> Option.map ~f:Js.to_string with
     | _ -> None)
;;

let set_item key value =
  match storage () with
  | None -> ()
  | Some s ->
    (try s##setItem (Js.string key) (Js.string value) with
     | _ -> ())
;;

let set_root_theme ~mode =
  let root = Dom_html.document##.documentElement in
  root##.className := Js.string (if String.equal mode "dark" then "dark" else "")
;;

let set_title title = Dom_html.document##.title := Js.string title
let scroll_to_top () = Dom_html.window##scroll (Js.number_of_float 0.) (Js.number_of_float 0.)

let scroll_to_anchor id =
  match Dom_html.getElementById_opt id with
  | None -> scroll_to_top ()
  | Some el -> el##scrollIntoView Js._true
;;

let reveal_current_nav () =
  let find s = Js.Opt.to_option (Dom_html.document##querySelector (Js.string s)) in
  match find ".docs-sidebar", find ".docs-sidebar .docs-nav-link[aria-current=\"page\"]" with
  | Some nav, Some link ->
    let nav_box = nav##getBoundingClientRect in
    let link_box = link##getBoundingClientRect in
    let margin = 24. in
    let above = Js.to_float link_box##.top -. Js.to_float nav_box##.top -. margin in
    let below =
      Js.to_float link_box##.bottom -. Js.to_float nav_box##.bottom +. margin
    in
    let top = Js.to_float nav##.scrollTop in
    if Float.(above < 0.)
    then nav##.scrollTop := Js.float (top +. above)
    else if Float.(below > 0.)
    then nav##.scrollTop := Js.float (top +. below)
  | _ -> ()
;;

let query_all selector =
  Dom_html.document##querySelectorAll (Js.string selector) |> Dom.list_of_nodeList
;;

let attr el name =
  Js.Opt.to_option (el##getAttribute (Js.string name)) |> Option.map ~f:Js.to_string
;;

let article_page () =
  if not (in_browser ())
  then None
  else
    Js.Opt.to_option (Dom_html.document##querySelector (Js.string ".docs-article"))
    |> Option.bind ~f:(fun el -> attr el "data-page")
;;

let outline () =
  query_all ".docs-article [data-outline]"
  |> List.filter_map ~f:(fun (el : Dom_html.element Js.t) ->
    match attr el "data-outline", Js.to_string el##.id with
    | Some title, id when not (String.is_empty id) ->
      let level = if String.equal (Js.to_string el##.tagName) "H3" then 3 else 2 in
      Some (id, title, level)
    | _ -> None)
;;

(* Marks the outline's link to the section being read: the last heading
   above a line a little below the header. *)
let update_scroll_spy () =
  let headings = query_all ".docs-article [data-outline]" in
  let links = query_all ".docs-toc-link" in
  let active =
    List.fold headings ~init:None ~f:(fun acc (el : Dom_html.element Js.t) ->
      let top = Js.to_float el##getBoundingClientRect##.top in
      if Float.( < ) top 120. then Some (Js.to_string el##.id) else acc)
  in
  let active =
    match active, headings with
    | None, first :: _ -> Some (Js.to_string first##.id)
    | active, _ -> active
  in
  List.iter links ~f:(fun (link : Dom_html.element Js.t) ->
    let is_active =
      match active, attr link "data-target" with
      | Some a, Some t -> String.equal a t
      | _ -> false
    in
    if is_active
    then link##setAttribute (Js.string "data-active") (Js.string "")
    else link##removeAttribute (Js.string "data-active"))
;;

let install_scroll_spy () =
  let scheduled = ref false in
  let handler _ =
    if not !scheduled
    then (
      scheduled := true;
      ignore
        (Dom_html.window##requestAnimationFrame
           (Js.wrap_callback (fun (_ : Js.number_t) ->
              scheduled := false;
              update_scroll_spy ()))
         : Dom_html.animation_frame_request_id));
    Js._true
  in
  ignore
    (Dom_html.addEventListener
       Dom_html.window
       Dom_html.Event.scroll
       (Dom_html.handler handler)
       Js._false
     : Dom_html.event_listener_id)
;;

let on_hash_change f =
  Dom_html.window##.onhashchange
  := Dom_html.handler (fun _ ->
       f (hash ());
       Js._true)
;;

let is_mac () =
  let platform = Js.to_string Dom_html.window##.navigator##.platform in
  String.is_substring (String.lowercase platform) ~substring:"mac"
  || String.is_substring
       (String.lowercase (Js.to_string Dom_html.window##.navigator##.userAgent))
       ~substring:"iphone"
;;

let set_body_scroll_locked locked =
  let body = Dom_html.document##.body in
  if locked
  then body##setAttribute (Js.string "data-scroll-locked") (Js.string "")
  else body##removeAttribute (Js.string "data-scroll-locked")
;;

let active_element_is_editable () =
  match Js.Opt.to_option Dom_html.document##.activeElement with
  | None -> false
  | Some el ->
    let tag = String.lowercase (Js.to_string el##.tagName) in
    List.mem [ "input"; "textarea"; "select" ] tag ~equal:String.equal
    || Js.to_bool (Js.Unsafe.get el "isContentEditable")
;;

let focus id =
  match Dom_html.getElementById_opt id with
  | None -> ()
  | Some el -> el##focus
;;

let move_focus selector delta =
  let items = query_all selector in
  let n = List.length items in
  if n > 0
  then (
    let active = Js.Opt.to_option Dom_html.document##.activeElement in
    let index =
      List.findi items ~f:(fun _ (el : Dom_html.element Js.t) ->
        match active with
        | Some a -> phys_equal (Js.Unsafe.coerce a : Dom_html.element Js.t) el
        | None -> false)
      |> Option.map ~f:fst
    in
    let next =
      match index with
      | None -> if delta > 0 then 0 else n - 1
      | Some i -> (i + delta + n) % n
    in
    (List.nth_exn items next)##focus)
;;
