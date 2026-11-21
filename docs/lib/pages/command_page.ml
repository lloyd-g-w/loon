open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "command"

(*$ Demo
   An item's [~value] is what the search matches: give it when the item's
   text is inside an element ([Node.span]). *)
let demo (local_ graph) =
  let item ?disabled ?shortcut icon text =
    Command.item
      ?disabled
      ~value:text
      ([ Icon.view icon; Node.span [ Node.text text ] ]
       @ Option.value_map shortcut ~default:[] ~f:(fun s ->
         [ Command.shortcut [ Node.text s ] ]))
  in
  Command.component
    ~class_:"rounded-lg border shadow-md md:min-w-[450px]"
    (Bonsai.return
       [ Command.input ~placeholder:"Type a command or search..." ()
       ; Command.list
           [ Command.empty [ Node.text "No results found." ]
           ; Command.group
               ~heading:"Suggestions"
               [ item Calendar "Calendar"
               ; item Face_slightly_smiling "Search Emoji"
               ; item ~disabled:true Calculator "Calculator"
               ]
           ; Command.separator ()
           ; Command.group
               ~heading:"Settings"
               [ item User "Profile" ~shortcut:"⌘P"
               ; item Credit_card "Billing" ~shortcut:"⌘B"
               ; item Settings "Settings" ~shortcut:"⌘S"
               ]
           ]
       ])
    graph
(*$*)

(*$ Dialog
   [Command.dialog] shows the menu in a dialog; here ⌘J (or Ctrl+J) opens and
   closes it. *)
let dialog (local_ graph) =
  let open_, set_open = Bonsai.state false graph in
  let state, set_state = Bonsai.state Command.State.empty graph in
  let%arr open_ and set_open and state and set_state in
  let item ?shortcut icon text =
    Command.item
      ~value:text
      ~on_select:(set_open false)
      ([ Icon.view icon; Node.span [ Node.text text ] ]
       @ Option.value_map shortcut ~default:[] ~f:(fun s ->
         [ Command.shortcut [ Node.text s ] ]))
  in
  Node.div
    ~attrs:
      [ Vdom.Attr.Global_listeners.keydown ~phase:Bubbling ~f:(fun ev ->
          let open Js_of_ocaml in
          let is_j =
            match Dom_html.Keyboard_code.of_event ev with
            | KeyJ -> true
            | _ -> false
          in
          if is_j && (Js.to_bool ev##.metaKey || Js.to_bool ev##.ctrlKey)
          then Effect.Many [ Dom_util.prevent_default ev; set_open (not open_) ]
          else Effect.Ignore)
      ]
    [ Node.p
        ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ]
        [ Node.text "Press "
        ; Node.kbd
            ~attrs:
              [ Attr.class_
                  "pointer-events-none inline-flex h-5 items-center gap-1 rounded border \
                   bg-muted px-1.5 font-mono text-[10px] font-medium text-muted-foreground \
                   opacity-100 select-none"
              ]
            [ Node.span ~attrs:[ Attr.class_ "text-xs" ] [ Node.text "⌘" ]; Node.text "J" ]
        ]
    ; Command.dialog
        ~open_
        ~on_open_change:set_open
        ~state
        ~on_change:set_state
        [ Command.input ~placeholder:"Type a command or search..." ()
        ; Command.list
            [ Command.empty [ Node.text "No results found." ]
            ; Command.group
                ~heading:"Suggestions"
                [ item Calendar "Calendar"
                ; item Face_slightly_smiling "Search Emoji"
                ; item Calculator "Calculator"
                ]
            ; Command.separator ()
            ; Command.group
                ~heading:"Settings"
                [ item User "Profile" ~shortcut:"⌘P"
                ; item Credit_card "Billing" ~shortcut:"⌘B"
                ; item Settings "Settings" ~shortcut:"⌘S"
                ]
            ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Command"
    ~group:Overlays
    ~description:"Fast, composable, unstyled command menu."
    ~usage:
      {|Command.component
  (return
     [ Command.input ~placeholder:"Type a command or search..." ()
     ; Command.list
         [ Command.empty [ Node.text "No results found." ]
         ; Command.group ~heading:"Suggestions"
             [ Command.item ~on_select:open_calendar [ Node.text "Calendar" ]
             ; Command.item [ Node.text "Search Emoji" ]
             ]
         ; Command.separator ()
         ; Command.group ~heading:"Settings"
             [ Command.item [ Node.text "Profile" ] ]
         ]
     ])
  graph|}
    ~body:
      [ Doc.h2 "Core's Command"
      ; Doc.p
          "Core has a [Command] module too. After [open Loon] (as here), [Command] is \
           loon's; in a file that opens Core after loon, write [Loon.Command], or alias \
           it first: [module Cmdk = Command] before [open! Core]. A component copied with \
           [loon add command] is the file [command.ml], and so the module [Command] of \
           your project, which shadows Core's in the same way."
      ; Doc.h2 "Filtering"
      ; Doc.p
          "As cmdk: typing keeps the items whose [~value] (or [~keywords]) contain the \
           search's letters in order, ranked by cmdk's command-score (whole words and \
           runs of letters first); groups are ordered by their best item and hidden when \
           none matches, separators hide while searching, and [Command.empty] shows when \
           nothing matches. [~should_filter:false] leaves filtering to you; [~filter] \
           replaces the ranking."
      ; Doc.h2 "Arguments"
      ; Doc.props
          [ ( "state, on_change"
            , "Command.State.t, _ -> unit Effect.t"
            , "[Command.view]: the search and the selected item's value. \
               [Command.component] keeps it." )
          ; "value", "string", "[item]: what the search matches; by default its text."
          ; "keywords", "string list", "[item]: more words that match it."
          ; "on_select", "unit Effect.t", "[item]: run by Enter or a click."
          ; "disabled", "bool", "[item]: shown, but not selectable."
          ; "loop", "bool", "Default [false]: the arrows wrap round at the ends."
          ; ( "open_, on_open_change"
            , "bool, bool -> unit Effect.t"
            , "[Command.dialog]: whether the dialog is open; closing it clears the \
               search." )
          ]
      ; Doc.h2 "Keyboard"
      ; Doc.table
          [ "Key"; "Does" ]
          [ [ Doc.text "ArrowUp / ArrowDown (Ctrl+P / Ctrl+N)"
            ; Doc.text "Select the previous or next item."
            ]
          ; [ Doc.text "Home / End"; Doc.text "Select the first or last item." ]
          ; [ Doc.text "Enter"; Doc.text "Run the selected item's [on_select]." ]
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Dialog" dialog ]
;;
