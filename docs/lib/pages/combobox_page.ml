open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "combobox"

(*$ Demo *)
let demo (local_ graph) =
  let combobox =
    Combobox.component
      ~placeholder:"Select framework..."
      ~search_placeholder:"Search framework..."
      ~empty:"No framework found."
      (Bonsai.return
         [ { Combobox.Option_.value = "next.js"; label = "Next.js" }
         ; { value = "sveltekit"; label = "SvelteKit" }
         ; { value = "nuxt.js"; label = "Nuxt.js" }
         ; { value = "remix"; label = "Remix" }
         ; { value = "astro"; label = "Astro" }
         ])
      graph
  in
  let%arr _value, view = combobox in
  view
(*$*)

(*$ Popover
   Built from [Popover] and [Command] directly, opening on the right. *)
let popover (local_ graph) =
  let statuses =
    [ "backlog", "Backlog"
    ; "todo", "Todo"
    ; "in progress", "In Progress"
    ; "done", "Done"
    ; "canceled", "Canceled"
    ]
  in
  let open_, set_open = Bonsai.state false graph in
  let selected, set_selected = Bonsai.state_opt graph in
  let command, set_command = Bonsai.state Command.State.empty graph in
  let%arr open_ and set_open and selected and set_selected and command and set_command in
  let set_open o =
    if o then set_open true else Effect.Many [ set_open false; set_command Command.State.empty ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex items-center space-x-4" ]
    [ Node.p ~attrs:[ Attr.class_ "text-sm text-muted-foreground" ] [ Node.text "Status" ]
    ; Popover.view ~id:"combobox-popover" ~open_ ~on_open_change:set_open (fun p ->
        [ Popover.trigger
            p
            (Button.view
               ~variant:Outline
               ~class_:"w-[150px] justify-start"
               [ Node.text
                   (match selected with
                    | Some value -> List.Assoc.find_exn statuses value ~equal:String.equal
                    | None -> "+ Set status")
               ])
        ; Popover.content
            p
            ~class_:"p-0"
            ~side:Right
            ~align:Start
            [ Command.view
                ~id:"combobox-popover-command"
                ~state:command
                ~on_change:set_command
                [ Command.input ~placeholder:"Change status..." ()
                ; Command.list
                    [ Command.empty [ Node.text "No results found." ]
                    ; Command.group
                        (List.map statuses ~f:(fun (value, label) ->
                           Command.item
                             ~value
                             ~on_select:
                               (Effect.Many [ set_selected (Some value); set_open false ])
                             [ Node.text label ]))
                    ]
                ]
            ]
        ])
    ]
(*$*)

(*$ Dropdown menu
   A [Command] in a dropdown menu's sub-menu. *)
let dropdown_menu (local_ graph) =
  let labels =
    [ "feature"; "bug"; "enhancement"; "documentation"; "design"; "question"; "maintenance" ]
  in
  let label, set_label = Bonsai.state "feature" graph in
  let command, set_command = Bonsai.state Command.State.empty graph in
  let menu, set_menu = Bonsai.state Dropdown_menu.State.Closed graph in
  let%arr label and set_label and command and set_command and menu and set_menu in
  Node.div
    ~attrs:
      [ Attr.class_
          "flex w-full flex-col items-start justify-between rounded-md border px-4 py-3 \
           sm:flex-row sm:items-center"
      ]
    [ Node.p
        ~attrs:[ Attr.class_ "text-sm leading-none font-medium" ]
        [ Node.span
            ~attrs:
              [ Attr.class_
                  "mr-2 rounded-lg bg-primary px-2 py-1 text-xs text-primary-foreground"
              ]
            [ Node.text label ]
        ; Node.span
            ~attrs:[ Attr.class_ "text-muted-foreground" ]
            [ Node.text "Create a new project" ]
        ]
    ; Dropdown_menu.view ~id:"combobox-dropdown-menu" ~state:menu ~on_change:set_menu (fun m ->
        [ Dropdown_menu.trigger
            m
            (Button.view ~variant:Ghost ~size:Sm [ Icon.view Ellipsis ])
        ; Dropdown_menu.content
            m
            ~align:End
            ~class_:"w-[200px]"
            [ Dropdown_menu.label [ Node.text "Actions" ]
            ; Dropdown_menu.group
                [ Dropdown_menu.item [ Node.text "Assign to..." ]
                ; Dropdown_menu.item [ Node.text "Set due date..." ]
                ; Dropdown_menu.separator ()
                ; Dropdown_menu.sub
                    (Dropdown_menu.sub_trigger [ Node.text "Apply label" ])
                    (Dropdown_menu.sub_content
                       ~class_:"p-0"
                       [ Menu.node
                           (Command.view
                              ~id:"combobox-dropdown-menu-command"
                              ~state:command
                              ~on_change:set_command
                              [ Command.input
                                  ~placeholder:"Filter label..."
                                  ~auto_focus:true
                                  ~class_:"h-9"
                                  ()
                              ; Command.list
                                  [ Command.empty [ Node.text "No label found." ]
                                  ; Command.group
                                      (List.map labels ~f:(fun l ->
                                         Command.item
                                           ~value:l
                                           ~on_select:
                                             (Effect.Many
                                                [ set_label l
                                                ; set_command Command.State.empty
                                                ; Dropdown_menu.set_open m false
                                                ])
                                           [ Node.text l ]))
                                  ]
                              ])
                       ])
                ; Dropdown_menu.separator ()
                ; Dropdown_menu.item
                    ~class_:"text-red-600"
                    [ Node.text "Delete"; Dropdown_menu.shortcut [ Node.text "⌘⌫" ] ]
                ]
            ]
        ])
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Combobox"
    ~description:"Autocomplete input and command palette with a list of suggestions."
    ~usage:
      {|(* value * view *)
Combobox.component
  ~placeholder:"Select framework..."
  (return
     [ { Combobox.Option_.value = "next.js"; label = "Next.js" }
     ; { value = "remix"; label = "Remix" }
     ])
  graph|}
    ~body:
      [ Doc.p
          "As in shadcn, a combobox is a [Popover] holding a [Command]: \
           [Combobox.component] is shadcn's demo packaged (the button shows the chosen \
           option; choosing it again clears it). For other shapes compose [Popover] and \
           [Command] yourself, as the second example does."
      ; Doc.h2 "Arguments"
      ; Doc.props
          [ ( "value, on_value_change"
            , "string option, _ -> unit Effect.t"
            , "[Combobox.view]: the chosen option's value. [Combobox.component] keeps it \
               ([?default_value]) and returns it with the view." )
          ; ( "placeholder, search_placeholder, empty"
            , "string"
            , "The button's text with nothing chosen, the search box's placeholder, and \
               the text when nothing matches." )
          ; ( "class_, content_class"
            , "string"
            , "The button's and the popover's classes ([w-[200px]] by default)." )
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Popover" popover
    ; Doc.example ~page "Dropdown menu" dropdown_menu
    ]
;;
