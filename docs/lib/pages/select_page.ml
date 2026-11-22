open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "select"

(*$ Demo *)
let demo (local_ graph) =
  let%arr _value, view =
    Select.component
      (return (Select.trigger ~class_:"w-full max-w-48" ~placeholder:"Select a fruit" ()))
      (return
         (Select.content
            [ Select.group
                [ Select.label [ Node.text "Fruits" ]
                ; Select.item ~value:"apple" [ Node.text "Apple" ]
                ; Select.item ~value:"banana" [ Node.text "Banana" ]
                ; Select.item ~value:"blueberry" [ Node.text "Blueberry" ]
                ; Select.item ~value:"grapes" [ Node.text "Grapes" ]
                ; Select.item ~value:"pineapple" [ Node.text "Pineapple" ]
                ]
            ]))
      graph
  in
  view
(*$*)

(*$ Scrollable
   A long list: it scrolls, with buttons at the ends while there is more
   to see. *)
let timezones =
  [ ( "North America"
    , [ "est", "Eastern Standard Time (EST)"
      ; "cst", "Central Standard Time (CST)"
      ; "mst", "Mountain Standard Time (MST)"
      ; "pst", "Pacific Standard Time (PST)"
      ; "akst", "Alaska Standard Time (AKST)"
      ; "hst", "Hawaii Standard Time (HST)"
      ] )
  ; ( "Europe & Africa"
    , [ "gmt", "Greenwich Mean Time (GMT)"
      ; "cet", "Central European Time (CET)"
      ; "eet", "Eastern European Time (EET)"
      ; "west", "Western European Summer Time (WEST)"
      ; "cat", "Central Africa Time (CAT)"
      ; "eat", "East Africa Time (EAT)"
      ] )
  ; ( "Asia"
    , [ "msk", "Moscow Time (MSK)"
      ; "ist", "India Standard Time (IST)"
      ; "cst_china", "China Standard Time (CST)"
      ; "jst", "Japan Standard Time (JST)"
      ; "kst", "Korea Standard Time (KST)"
      ; "ist_indonesia", "Indonesia Central Standard Time (WITA)"
      ] )
  ; ( "Australia & Pacific"
    , [ "awst", "Australian Western Standard Time (AWST)"
      ; "acst", "Australian Central Standard Time (ACST)"
      ; "aest", "Australian Eastern Standard Time (AEST)"
      ; "nzst", "New Zealand Standard Time (NZST)"
      ; "fjt", "Fiji Time (FJT)"
      ] )
  ; ( "South America"
    , [ "art", "Argentina Time (ART)"
      ; "bot", "Bolivia Time (BOT)"
      ; "brt", "Brasilia Time (BRT)"
      ; "clt", "Chile Standard Time (CLT)"
      ] )
  ]
;;

let scrollable (local_ graph) =
  let%arr _value, view =
    Select.component
      (return (Select.trigger ~class_:"w-[280px]" ~placeholder:"Select a timezone" ()))
      (return
         (Select.content
            (List.map timezones ~f:(fun (region, zones) ->
               Select.group
                 (Select.label [ Node.text region ]
                  :: List.map zones ~f:(fun (value, name) ->
                    Select.item ~value [ Node.text name ]))))))
      graph
  in
  view
(*$*)

(*$ Popper position
   With [~position:Popper] the list opens below the trigger, as a dropdown
   does, instead of over it with the chosen item on the trigger. *)
let popper (local_ graph) =
  let%arr _value, view =
    Select.component
      ~default_value:"light"
      (return (Select.trigger ~class_:"w-[180px]" ~placeholder:"Theme" ()))
      (return
         (Select.content
            ~position:Popper
            [ Select.item ~value:"light" [ Node.text "Light" ]
            ; Select.item ~value:"dark" [ Node.text "Dark" ]
            ; Select.item ~value:"system" [ Node.text "System" ]
            ]))
      graph
  in
  view
(*$*)

(*$ Disabled items, separator and small size *)
let disabled (local_ graph) =
  let%arr value, view =
    Select.component
      (return
         (Select.trigger ~size:Sm ~class_:"w-[180px]" ~placeholder:"Select a plan" ()))
      (return
         (Select.content
            [ Select.group
                [ Select.label [ Node.text "Plans" ]
                ; Select.item ~value:"free" [ Node.text "Free" ]
                ; Select.item ~value:"pro" [ Node.text "Pro" ]
                ]
            ; Select.separator ()
            ; Select.item ~value:"enterprise" ~disabled:true [ Node.text "Enterprise" ]
            ]))
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "flex items-center gap-4" ]
    [ view
    ; Node.span
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.text
            (match value with
             | None -> "Nothing chosen"
             | Some v -> "Chose " ^ v)
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Select"
    ~description:
      "Displays a list of options for the user to pick from—triggered by a button."
    ~usage:
      {|Select.component
  (return (Select.trigger ~class_:"w-[180px]" ~placeholder:"Theme" ()))
  (return
     (Select.content
        [ Select.item ~value:"light" [ Node.text "Light" ]
        ; Select.item ~value:"dark" [ Node.text "Dark" ]
        ; Select.item ~value:"system" [ Node.text "System" ]
        ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value, on_value_change"
            , "string option, string -> unit Effect.t"
            , "[Select.view]: the chosen item's value. [Select.component] keeps it \
               ([?default_value]) and returns it with the view." )
          ; ( "state, on_state_change"
            , "Select.State.t"
            , "[Select.view]: whether the list is open and its highlighted item." )
          ; ( "name, required"
            , "string, bool"
            , "With [name], a hidden native [<select>] carries the value in forms." )
          ; "disabled", "bool", "The trigger does not open."
          ; ( "placeholder, size"
            , "string, Select.Size.t"
            , "[trigger]: shown while nothing is chosen; [Default] or [Sm]." )
          ; ( "position"
            , "Select.Position.t"
            , "[content]: [Item_aligned] (default: the chosen item over the trigger) or \
               [Popper] (below it; then [side], [side_offset], [align] and \
               [align_offset] place it)." )
          ; ( "text_value"
            , "string"
            , "[item]: what typeahead matches (default: the item's text)." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "Enter / Space / ArrowDown / ArrowUp"
            ; Doc.text "On the trigger: open, highlighting the chosen item."
            ]
          ; [ Doc.text "A letter"
            ; Doc.text
                "On the closed trigger: choose the next item starting with it; in the \
                 list: highlight it."
            ]
          ; [ Doc.text "ArrowUp / ArrowDown"; Doc.text "Highlight the previous or next item." ]
          ; [ Doc.text "Home / End"; Doc.text "Highlight the first or last item." ]
          ; [ Doc.text "Enter / Space"; Doc.text "Choose the highlighted item and close." ]
          ; [ Doc.text "Esc"; Doc.text "Close, returning focus to the trigger." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Scrollable" scrollable
    ; Doc.example ~page "Popper position" popper
    ; Doc.example ~page "Disabled items, separator and small size" disabled
    ]
;;
