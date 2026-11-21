open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "sonner"

(*$ Demo
   A [Sonner.toaster] goes once in your app (here, in each example). *)
let demo (local_ graph) =
  let toaster = Sonner.toaster graph in
  let%arr toaster in
  Node.div
    [ Button.view
        ~variant:Outline
        ~on_click:
          (Sonner.toast
             ~description:"Sunday, December 03, 2023 at 9:00 AM"
             ~action:("Undo", Effect.print_s [%message "Undo"])
             "Event has been created")
        [ Node.text "Show Toast" ]
    ; toaster
    ]
;;

(*$*)

(*$ Types *)
let types (local_ graph) =
  let toaster = Sonner.toaster graph in
  let sleep = Bonsai.Clock.sleep graph in
  let%arr toaster
  and sleep in
  let button label on_click =
    Button.view ~variant:Outline ~on_click [ Node.text label ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-wrap gap-2" ]
    [ button "Default" (Sonner.toast "Event has been created")
    ; button "Success" (Sonner.success "Event has been created")
    ; button
        "Info"
        (Sonner.info "Be at the area 10 minutes before the event time")
    ; button
        "Warning"
        (Sonner.warning "Event start time cannot be earlier than 8am")
    ; button "Error" (Sonner.error "Event has not been created")
    ; button
        "Promise"
        (Sonner.promise
           ~loading:"Loading..."
           ~success:(fun name -> name ^ " has been created")
           ~error:(fun _ -> "Error")
           (let%map.Effect () = sleep (Time_ns.Span.of_sec 2.) in
            Ok "Event"))
    ; toaster
    ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Sonner"
    ~group:Feedback
    ~description:"An opinionated toast component."
    ~usage:
      {|(* once, in your app *)
Sonner.toaster graph

(* anywhere *)
Button.view ~on_click:(Sonner.toast "Event has been created") [ Node.text "Show Toast" ]|}
    ~body:
      [ Doc.h2 "Toasts"
      ; Doc.props
          [ "Sonner.toast", "string -> unit Effect.t", "A toast with no icon."
          ; ( "Sonner.success / info / warning / error"
            , "string -> unit Effect.t"
            , "A toast with the type's icon." )
          ; ( "Sonner.loading"
            , "string -> unit Effect.t"
            , "A spinner; stays until updated (same [~id]) or dismissed." )
          ; ( "Sonner.promise"
            , "'a Or_error.t Effect.t -> unit Effect.t"
            , "[~loading] while the effect runs, then [~success] or [~error]." )
          ; ( "Sonner.dismiss"
            , "?id:string -> unit -> unit Effect.t"
            , "Closes one or all." )
          ]
      ; Doc.h2 "Options"
      ; Doc.props
          [ "description", "string", "A second, muted line."
          ; ( "action"
            , "string * unit Effect.t"
            , "A button that also dismisses the toast." )
          ; "cancel", "string * unit Effect.t", "A quieter button."
          ; "duration", "Time_ns.Span.t", "How long it shows (default 4 s)."
          ; ( "id"
            , "string"
            , "Update the toast with this id instead of adding one." )
          ]
      ; Doc.h2 "Toaster"
      ; Doc.props
          [ ( "position"
            , "Sonner.Position.t"
            , "Where the toasts appear ([Bottom_right])." )
          ; "expand", "bool", "Spread out the stack without hovering."
          ; "rich_colors", "bool", "Colour toasts by type (off)."
          ; "close_button", "bool", "A close button on each toast."
          ; "visible_toasts", "int", "How many show stacked (3)."
          ]
      ]
    [ Doc.example ~page "Demo" demo; Doc.example ~page "Types" types ]
;;
