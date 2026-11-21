open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "form"

(*$ Sign-up form
   Every control here is a [Control.t] from its component. Errors appear once
   you try to submit, then update as you type. *)
module Signup = struct
  type t =
    { name : string
    ; email : string
    ; password : string
    ; country : string
    ; plan : string option
    ; terms : bool
    }

  let errors t =
    List.filter_opt
      [ (if String.is_empty (String.strip t.name)
         then Some ("name", "Tell us your name.")
         else None)
      ; (match String.lsplit2 t.email ~on:'@' with
         | Some (user, domain)
           when (not (String.is_empty user)) && String.mem domain '.' -> None
         | _ -> Some ("email", "Enter an email address like ada@example.com."))
      ; (if String.length t.password < 8
         then Some ("password", "Use at least 8 characters.")
         else None)
      ; (if String.is_empty t.country
         then Some ("country", "Choose a country.")
         else None)
      ; (if Option.is_none t.plan then Some ("plan", "Choose a plan.") else None)
      ; (if t.terms
         then None
         else Some ("terms", "You need to accept the terms."))
      ]
  ;;

  (* 0 to 4: one point each for length, mixed case, a digit, a symbol. *)
  let strength password =
    List.count
      [ String.length password >= 10
      ; String.exists password ~f:Char.is_uppercase
        && String.exists password ~f:Char.is_lowercase
      ; String.exists password ~f:Char.is_digit
      ; String.exists password ~f:(fun c -> not (Char.is_alphanum c))
      ]
      ~f:Fn.id
  ;;
end

let countries =
  [ Native_select.Item.create ~value:"au" "Australia"
  ; Native_select.Item.create ~value:"nz" "New Zealand"
  ; Native_select.Item.create ~value:"gb" "United Kingdom"
  ; Native_select.Item.create ~value:"us" "United States"
  ]
;;

let signup (local_ graph) =
  let name = Input.component graph in
  let email = Input.component graph in
  let password = Input.component graph in
  let country, set_country = Bonsai.state "au" graph in
  let plan, set_plan = Bonsai.state (Some "hobby") graph in
  let newsletter =
    Switch.component
      ~label:"Email me the occasional product update"
      ~default:true
      graph
  in
  let terms, set_terms = Bonsai.state false graph in
  let show_password = Toggle.component [ Node.text "Show" ] graph in
  let attempted, set_attempted = Bonsai.state false graph in
  let submitted, set_submitted = Bonsai.state None graph in
  let%arr name
  and email
  and password
  and country
  and set_country
  and plan
  and set_plan
  and newsletter
  and terms
  and set_terms
  and show_password
  and attempted
  and set_attempted
  and submitted
  and set_submitted in
  let signup =
    { Signup.name = name.value
    ; email = email.value
    ; password = password.value
    ; country
    ; plan
    ; terms
    }
  in
  let errors = Signup.errors signup in
  let error field =
    if attempted then List.Assoc.find errors field ~equal:String.equal else None
  in
  let on_submit ev =
    Effect.Many
      [ Dom_util.prevent_default ev
      ; (if List.is_empty errors
         then set_submitted (Some signup.email)
         else set_attempted true)
      ]
  in
  match submitted with
  | Some address ->
    Card.root
      ~class_:"w-full max-w-md"
      [ Card.header
          [ Card.title [ Node.text "Check your inbox" ]
          ; Card.description
              [ Node.text (sprintf "We sent a link to %s to confirm it's you." address) ]
          ]
      ; Card.footer
          [ Button.view ~variant:Outline ~on_click:(set_submitted None) [ Node.text "Back" ] ]
      ]
  | None ->
    let strength = Signup.strength password.value in
    Node.form
      ~attrs:
        [ Attr.on_submit on_submit
        ; Attr.create "novalidate" ""
        ; Attr.style (Css_gen.create ~field:"width" ~value:"min(100%, 28rem)")
        ]
      [ Card.root
          [ Card.header
              [ Card.title [ Node.text "Create an account" ]
              ; Card.description [ Node.text "Start your 14-day trial. No card needed." ]
              ]
          ; Card.content
            [ Node.div
              ~attrs:
                [ Attr.class_ "docs-stack"
                ; Attr.style (Css_gen.create ~field:"gap" ~value:"1.125rem")
                ]
              [ Field.view
                  ~id:"signup-name"
                  ~label:"Name"
                  ~required:true
                  ?error:(error "name")
                  (fun attrs ->
                     Input.view
                       ~attrs:(Attr.create "autocomplete" "name" :: attrs)
                       ~placeholder:"Ada Lovelace"
                       ~value:name.value
                       ~on_input:name.set
                       ())
              ; Field.view
                  ~id:"signup-email"
                  ~label:"Email"
                  ~required:true
                  ?error:(error "email")
                  (fun attrs ->
                     Input.view
                       ~attrs:(Attr.create "autocomplete" "email" :: attrs)
                       ~type_:Email
                       ~leading:Mail
                       ~placeholder:"ada@example.com"
                       ~value:email.value
                       ~on_input:email.set
                       ())
              ; Field.view
                  ~id:"signup-password"
                  ~label:"Password"
                  ~required:true
                  ~description:
                    (match strength with
                     | _ when String.is_empty password.value ->
                       "At least 8 characters."
                     | 0 | 1 -> "Strength: weak"
                     | 2 -> "Strength: fair"
                     | 3 -> "Strength: good"
                     | _ -> "Strength: strong")
                  ?error:(error "password")
                  (fun attrs ->
                     Input.view
                       ~attrs:
                         (Attr.create "autocomplete" "new-password" :: attrs)
                       ~type_:(if show_password.value then Text else Password)
                       ~trailing:
                         (Toggle.view
                            ~size:Sm
                            ~pressed:show_password.value
                            ~on_change:show_password.set
                            [ Node.text
                                (if show_password.value then "Hide" else "Show")
                            ])
                       ~value:password.value
                       ~on_input:password.set
                       ())
              ; Field.view
                  ~id:"signup-country"
                  ~label:"Country"
                  ?error:(error "country")
                  (fun attrs ->
                     Native_select.view
                       ~attrs
                       ~placeholder:"Choose…"
                       ~value:country
                       ~on_change:set_country
                       countries)
              ; Field.set
                  ~legend:"Plan"
                  [ Radio_group.view
                      ~name:"signup-plan"
                      ~value:plan
                      ~on_change:(fun p -> set_plan (Some p))
                      [ Radio_group.Item.create
                          ~value:"hobby"
                          ~description:"Free, for personal projects."
                          "Hobby"
                      ; Radio_group.Item.create
                          ~value:"team"
                          ~description:
                            "$8 a person a month, for working together."
                          "Team"
                      ]
                  ]
              ; newsletter.view
              ; Field.view
                  ~orientation:Horizontal
                  ~id:"signup-terms"
                  ~label:"I accept the terms of service"
                  ?error:(error "terms")
                  (fun attrs ->
                     Checkbox.view
                       ~attrs
                       ~state:(Checkbox.State.of_bool terms)
                       ~on_change:set_terms
                       ())
              ]
            ]
          ; Card.footer
              [ Button.view ~type_:`Submit ~class_:"w-full" [ Node.text "Create account" ] ]
          ]
      ]
;;

(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Forms"
    ~group:Forms
    ~description:
      "Putting the form components together: labels, validation and submitting."
    ~body:
      [ Doc.h2 "How it fits together"
      ; Doc.p
          "Each control has a controlled view (you pass its value and an \
           on_change) and a component that keeps the value in Bonsai state and \
           returns a Control.t { value; set; view }. Field.view gives a \
           control its label, description and error, passing it the attributes \
           (id, aria-describedby, aria-invalid) that tie them together."
      ; Doc.p
          "Validate with plain functions of the values. Showing errors only \
           after a first attempt to submit, then live, is kind: nobody likes \
           being told off for a field they have not reached yet."
      ]
    [ Doc.example ~page "Sign-up form" signup ]
;;
