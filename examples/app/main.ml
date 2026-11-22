open! Core
open Bonsai_web
open Bonsai.Let_syntax
open Loon

let app (local_ graph) =
  let count, set_count = Bonsai.state 0 graph in
  let notify = Switch.component ~id:"notify" ~default_checked:true graph in
  let%arr count and set_count and notify in
  (* bg-linear-to-br from-sky-50 to-indigo-100: Tailwind classes loon's
     components do not use, in the same stylesheet as theirs. *)
  Vdom.Node.div
    ~attrs:
      [ Vdom.Attr.class_
          "flex min-h-svh items-center justify-center bg-linear-to-br from-sky-50 \
           to-indigo-100 p-6 font-sans antialiased"
      ]
    [ Card.root
        ~class_:"w-full max-w-sm"
        [ Card.header
            [ Card.title [ Vdom.Node.text "Counter" ]
            ; Card.description [ Vdom.Node.textf "Pressed %d times." count ]
            ; Card.action [ Badge.view ~variant:Secondary [ Vdom.Node.text "loon" ] ]
            ]
        ; Card.content
            [ Vdom.Node.div
                ~attrs:[ Vdom.Attr.class_ "flex items-center gap-2" ]
                [ notify.view
                ; Label.view ~for_:"notify" [ Vdom.Node.text "Notifications" ]
                ]
            ]
        ; Card.footer
            ~class_:"gap-2"
            [ Button.view
                ~on_click:(set_count (count + 1))
                [ Vdom.Node.text "Press" ]
            ; Button.view
                ~variant:Outline
                ~on_click:(set_count 0)
                [ Vdom.Node.text "Reset" ]
            ]
        ]
    ]
;;

let () = Bonsai_web.Start.start app
