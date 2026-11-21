open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "form"

(*$ Bug Report
   Bonsai state holds the values; validation is a plain function of them.
   As with react-hook-form's defaults, errors appear on the first submit,
   then update as you type; Reset clears both. *)
module Bug_report = struct
  type t =
    { title : string
    ; description : string
    }
  [@@deriving sexp_of]

  let title_errors t =
    let n = String.length t.title in
    List.filter_opt
      [ Option.some_if (n < 5) "Bug title must be at least 5 characters."
      ; Option.some_if (n > 32) "Bug title must be at most 32 characters."
      ]
  ;;

  let description_errors t =
    let n = String.length t.description in
    List.filter_opt
      [ Option.some_if (n < 20) "Description must be at least 20 characters."
      ; Option.some_if (n > 100) "Description must be at most 100 characters."
      ]
  ;;

  let to_json t =
    sprintf "{\n  \"title\": %S,\n  \"description\": %S\n}" t.title t.description
  ;;
end

let bug_report (local_ graph) =
  let title, set_title = Bonsai.state "" graph in
  let description, set_description = Bonsai.state "" graph in
  let attempted, set_attempted = Bonsai.state false graph in
  let submitted, set_submitted = Bonsai.state None graph in
  let%arr title
  and set_title
  and description
  and set_description
  and attempted
  and set_attempted
  and submitted
  and set_submitted in
  let report = { Bug_report.title; description } in
  let title_errors = if attempted then Bug_report.title_errors report else [] in
  let description_errors =
    if attempted then Bug_report.description_errors report else []
  in
  let on_submit ev =
    Effect.Many
      [ Dom_util.prevent_default ev
      ; set_attempted true
      ; (if List.is_empty (Bug_report.title_errors report)
            && List.is_empty (Bug_report.description_errors report)
         then set_submitted (Some report)
         else set_submitted None)
      ]
  in
  let reset =
    Effect.Many
      [ set_title ""; set_description ""; set_attempted false; set_submitted None ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full flex-col items-center gap-4" ]
    ([ Card.root
         ~class_:"w-full sm:max-w-md"
         [ Card.header
             [ Card.title [ Node.text "Bug Report" ]
             ; Card.description
                 [ Node.text "Help us improve by reporting bugs you encounter." ]
             ]
         ; Card.content
             [ Node.form
                 ~attrs:[ Attr.id "form-rhf-demo"; Attr.on_submit on_submit ]
                 [ Field.group
                     [ Field.root
                         ~invalid:(not (List.is_empty title_errors))
                         [ Field.label ~for_:"form-rhf-demo-title" [ Node.text "Bug Title" ]
                         ; Input.view
                             ~attrs:[ Attr.create "autocomplete" "off" ]
                             ~id:"form-rhf-demo-title"
                             ~invalid:(not (List.is_empty title_errors))
                             ~placeholder:"Login button not working on mobile"
                             ~value:title
                             ~on_input:set_title
                             ()
                         ; Field.error ~errors:title_errors []
                         ]
                     ; Field.root
                         ~invalid:(not (List.is_empty description_errors))
                         [ Field.label
                             ~for_:"form-rhf-demo-description"
                             [ Node.text "Description" ]
                         ; Input_group.root
                             [ Input_group.textarea
                                 ~id:"form-rhf-demo-description"
                                 ~placeholder:
                                   "I'm having an issue with the login button on mobile."
                                 ~rows:6
                                 ~class_:"min-h-24 resize-none"
                                 ~invalid:(not (List.is_empty description_errors))
                                 ~value:description
                                 ~on_input:set_description
                                 ()
                             ; Input_group.addon
                                 ~align:Block_end
                                 [ Input_group.text
                                     ~class_:"tabular-nums"
                                     [ Node.text
                                         (sprintf
                                            "%d/100 characters"
                                            (String.length description))
                                     ]
                                 ]
                             ]
                         ; Field.description
                             [ Node.text
                                 "Include steps to reproduce, expected behavior, and \
                                  what actually happened."
                             ]
                         ; Field.error ~errors:description_errors []
                         ]
                     ]
                 ]
             ]
         ; Card.footer
             [ Field.root
                 ~orientation:Horizontal
                 [ Button.view
                     ~type_:`Button
                     ~variant:Outline
                     ~on_click:reset
                     [ Node.text "Reset" ]
                 ; Button.view
                     ~attrs:[ Attr.create "form" "form-rhf-demo" ]
                     ~type_:`Submit
                     [ Node.text "Submit" ]
                 ]
             ]
         ]
     ]
     @
     match submitted with
     | None -> []
     | Some report ->
       [ Node.div
           ~attrs:[ Attr.class_ "flex w-full flex-col gap-2 sm:max-w-md" ]
           [ Node.p
               ~attrs:[ Attr.class_ "text-sm font-medium" ]
               [ Node.text "You submitted the following values:" ]
           ; Node.pre
               ~attrs:
                 [ Attr.class_
                     "w-full overflow-x-auto rounded-md bg-muted p-4 font-mono text-sm"
                 ]
               [ Node.code [ Node.text (Bug_report.to_json report) ] ]
           ]
       ])
(*$*)

(*$ Sign-up
   A longer form on the same pattern: each control sets [aria-invalid] and
   its [Field] [~invalid] once you try to submit with errors. *)
module Signup = struct
  type t =
    { name : string
    ; email : string
    ; password : string
    ; country : string
    ; plan : string option
    ; newsletter : bool
    ; terms : bool
    }

  type field =
    | Name
    | Email
    | Password
    | Country
    | Plan
    | Terms
  [@@deriving equal]

  let errors t =
    List.filter_opt
      [ Option.some_if (String.is_empty (String.strip t.name)) (Name, "Tell us your name.")
      ; (match String.lsplit2 t.email ~on:'@' with
         | Some (user, domain) when (not (String.is_empty user)) && String.mem domain '.'
           -> None
         | _ -> Some (Email, "Enter an email address like ada@example.com."))
      ; Option.some_if
          (String.length t.password < 8)
          (Password, "Use at least 8 characters.")
      ; Option.some_if (String.is_empty t.country) (Country, "Choose a country.")
      ; Option.some_if (Option.is_none t.plan) (Plan, "Choose a plan.")
      ; Option.some_if (not t.terms) (Terms, "You need to accept the terms.")
      ]
  ;;
end

let signup (local_ graph) =
  let name, set_name = Bonsai.state "" graph in
  let email, set_email = Bonsai.state "" graph in
  let password, set_password = Bonsai.state "" graph in
  let show_password, set_show_password = Bonsai.state false graph in
  let country, set_country = Bonsai.state "" graph in
  let plan, set_plan = Bonsai.state None graph in
  let newsletter, set_newsletter = Bonsai.state true graph in
  let terms, set_terms = Bonsai.state false graph in
  let attempted, set_attempted = Bonsai.state false graph in
  let submitted, set_submitted = Bonsai.state None graph in
  let%arr name and set_name and email and set_email and password and set_password
  and show_password and set_show_password and country and set_country and plan
  and set_plan and newsletter and set_newsletter and terms and set_terms
  and attempted and set_attempted and submitted and set_submitted in
  let signup = { Signup.name; email; password; country; plan; newsletter; terms } in
  let all_errors = Signup.errors signup in
  let errors field =
    if attempted
    then
      List.filter_map all_errors ~f:(fun (f, e) ->
        Option.some_if (Signup.equal_field f field) e)
    else []
  in
  let invalid field = not (List.is_empty (errors field)) in
  let on_submit ev =
    Effect.Many
      [ Dom_util.prevent_default ev
      ; (if List.is_empty all_errors
         then set_submitted (Some email)
         else set_attempted true)
      ]
  in
  match submitted with
  | Some address ->
    Card.root
      ~class_:"w-full sm:max-w-md"
      [ Card.header
          [ Card.title [ Node.text "Check your inbox" ]
          ; Card.description
              [ Node.text (sprintf "We sent a link to %s to confirm it's you." address) ]
          ]
      ; Card.footer
          [ Button.view ~variant:Outline ~on_click:(set_submitted None) [ Node.text "Back" ]
          ]
      ]
  | None ->
    Card.root
      ~class_:"w-full sm:max-w-md"
      [ Card.header
          [ Card.title [ Node.text "Create an account" ]
          ; Card.description [ Node.text "Start your 14-day trial. No card needed." ]
          ]
      ; Card.content
          [ Node.form
              ~attrs:
                [ Attr.id "signup-form"
                ; Attr.create "novalidate" ""
                ; Attr.on_submit on_submit
                ]
              [ Field.group
                  [ Field.root
                      ~invalid:(invalid Name)
                      [ Field.label ~for_:"signup-name" [ Node.text "Name" ]
                      ; Input.view
                          ~attrs:[ Attr.create "autocomplete" "name" ]
                          ~id:"signup-name"
                          ~placeholder:"Ada Lovelace"
                          ~invalid:(invalid Name)
                          ~value:name
                          ~on_input:set_name
                          ()
                      ; Field.error ~errors:(errors Name) []
                      ]
                  ; Field.root
                      ~invalid:(invalid Email)
                      [ Field.label ~for_:"signup-email" [ Node.text "Email" ]
                      ; Input_group.root
                          [ Input_group.input
                              ~attrs:[ Attr.create "autocomplete" "email" ]
                              ~id:"signup-email"
                              ~type_:Email
                              ~placeholder:"ada@example.com"
                              ~invalid:(invalid Email)
                              ~value:email
                              ~on_input:set_email
                              ()
                          ; Input_group.addon [ Icon.view Mail ]
                          ]
                      ; Field.error ~errors:(errors Email) []
                      ]
                  ; Field.root
                      ~invalid:(invalid Password)
                      [ Field.label ~for_:"signup-password" [ Node.text "Password" ]
                      ; Input_group.root
                          [ Input_group.input
                              ~attrs:[ Attr.create "autocomplete" "new-password" ]
                              ~id:"signup-password"
                              ~type_:(if show_password then Text else Password)
                              ~invalid:(invalid Password)
                              ~value:password
                              ~on_input:set_password
                              ()
                          ; Input_group.addon
                              ~align:Inline_end
                              [ Input_group.button
                                  ~on_click:(set_show_password (not show_password))
                                  [ Node.text (if show_password then "Hide" else "Show") ]
                              ]
                          ]
                      ; Field.description [ Node.text "At least 8 characters." ]
                      ; Field.error ~errors:(errors Password) []
                      ]
                  ; Field.root
                      ~invalid:(invalid Country)
                      [ Field.label ~for_:"signup-country" [ Node.text "Country" ]
                      ; Native_select.view
                          ~id:"signup-country"
                          ~class_:"w-full"
                          ~invalid:(invalid Country)
                          ~value:country
                          ~on_change:set_country
                          [ Native_select.option ~value:"" [ Node.text "Choose..." ]
                          ; Native_select.option ~value:"au" [ Node.text "Australia" ]
                          ; Native_select.option ~value:"nz" [ Node.text "New Zealand" ]
                          ; Native_select.option ~value:"gb" [ Node.text "United Kingdom" ]
                          ; Native_select.option ~value:"us" [ Node.text "United States" ]
                          ]
                      ; Field.error ~errors:(errors Country) []
                      ]
                  ; Field.set
                      [ Field.legend ~variant:Label [ Node.text "Plan" ]
                      ; Radio_group.view
                          ~value:plan
                          ~on_change:(fun p -> set_plan (Some p))
                          (fun group ->
                            List.map
                              [ "hobby", "Hobby", "Free, for personal projects."
                              ; "team", "Team", "$8 a person a month, for working together."
                              ]
                              ~f:(fun (value, title, description) ->
                                let id = "signup-plan-" ^ value in
                                Field.label
                                  ~for_:id
                                  [ Field.root
                                      ~orientation:Horizontal
                                      ~invalid:(invalid Plan)
                                      [ Field.content
                                          [ Field.title [ Node.text title ]
                                          ; Field.description [ Node.text description ]
                                          ]
                                      ; Radio_group.item
                                          group
                                          ~value
                                          ~id
                                          ~invalid:(invalid Plan)
                                      ]
                                  ]))
                      ; Field.error ~errors:(errors Plan) []
                      ]
                  ; Field.root
                      ~orientation:Horizontal
                      [ Switch.view
                          ~id:"signup-newsletter"
                          ~checked:newsletter
                          ~on_change:set_newsletter
                          ()
                      ; Field.label
                          ~for_:"signup-newsletter"
                          ~class_:"font-normal"
                          [ Node.text "Email me the occasional product update" ]
                      ]
                  ; Field.root
                      ~orientation:Horizontal
                      ~invalid:(invalid Terms)
                      [ Checkbox.view
                          ~id:"signup-terms"
                          ~invalid:(invalid Terms)
                          ~checked:(Checkbox.State.of_bool terms)
                          ~on_change:set_terms
                          ()
                      ; Field.content
                          [ Field.label
                              ~for_:"signup-terms"
                              [ Node.text "I accept the terms of service" ]
                          ; Field.error ~errors:(errors Terms) []
                          ]
                      ]
                  ]
              ]
          ]
      ; Card.footer
          [ Button.view
              ~attrs:[ Attr.create "form" "signup-form" ]
              ~type_:`Submit
              ~class_:"w-full"
              [ Node.text "Create account" ]
          ]
      ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Forms"
    ~section:Forms
    ~description:
      "Build forms from Field, the form controls and Bonsai state, with validation \
       shown where it is needed."
    ~body:
      [ Doc.h2 "How it fits together"
      ; Doc.p
          "shadcn/ui's form examples use react-hook-form and zod; here the values are \
           Bonsai state and validation is a plain function of them. Each control has a \
           controlled [view] (its value and an [on_input]/[on_change]) and a \
           [component] that keeps the value itself and returns a [Control.t]."
      ; Doc.p
          "Lay the form out with the [Field] family: a [Field.root] per control, with \
           its [Field.label], [Field.description] and [Field.error]. When a value is \
           invalid, give the [Field.root] [~invalid:true] and the control \
           [~invalid:true] (its [aria-invalid]): both turn destructive."
      ; Doc.p
          "Show errors after the first attempt to submit, then live as the values \
           change: nobody likes being told off for a field they have not reached yet."
      ]
    [ Doc.example ~page "Bug Report" bug_report; Doc.example ~page "Sign-up" signup ]
;;
