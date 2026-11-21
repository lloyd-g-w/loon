open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "field"

(*$ Demo
   A payment form: field sets with legends, a grid of fields, a separator,
   a checkbox field and buttons. *)
let demo (local_ graph) =
  let same_as_shipping =
    Checkbox.component ~id:"checkout-7j9-same-as-shipping-wgm" ~default_checked:true graph
  in
  let%arr same_as_shipping in
  let options values =
    List.map values ~f:(fun v -> Native_select.option ~value:v [ Node.text v ])
  in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Node.form
        ~attrs:[ Attr.on_submit Dom_util.prevent_default ]
        [ Field.group
            [ Field.set
                [ Field.legend [ Node.text "Payment Method" ]
                ; Field.description
                    [ Node.text "All transactions are secure and encrypted" ]
                ; Field.group
                    [ Field.root
                        [ Field.label
                            ~for_:"checkout-7j9-card-name-43j"
                            [ Node.text "Name on Card" ]
                        ; Input.view
                            ~id:"checkout-7j9-card-name-43j"
                            ~placeholder:"Evil Rabbit"
                            ~required:true
                            ()
                        ]
                    ; Field.root
                        [ Field.label
                            ~for_:"checkout-7j9-card-number-uw1"
                            [ Node.text "Card Number" ]
                        ; Input.view
                            ~id:"checkout-7j9-card-number-uw1"
                            ~placeholder:"1234 5678 9012 3456"
                            ~required:true
                            ()
                        ; Field.description [ Node.text "Enter your 16-digit card number" ]
                        ]
                    ; Node.div
                        ~attrs:[ Attr.class_ "grid grid-cols-3 gap-4" ]
                        [ Field.root
                            [ Field.label
                                ~for_:"checkout-exp-month-ts6"
                                [ Node.text "Month" ]
                            ; Native_select.view
                                ~id:"checkout-exp-month-ts6"
                                ~class_:"w-full"
                                (Native_select.option ~value:"" [ Node.text "MM" ]
                                 :: options
                                      (List.init 12 ~f:(fun i -> sprintf "%02d" (i + 1))))
                            ]
                        ; Field.root
                            [ Field.label
                                ~for_:"checkout-7j9-exp-year-f59"
                                [ Node.text "Year" ]
                            ; Native_select.view
                                ~id:"checkout-7j9-exp-year-f59"
                                ~class_:"w-full"
                                (Native_select.option ~value:"" [ Node.text "YYYY" ]
                                 :: options
                                      [ "2024"; "2025"; "2026"; "2027"; "2028"; "2029" ])
                            ]
                        ; Field.root
                            [ Field.label ~for_:"checkout-7j9-cvv" [ Node.text "CVV" ]
                            ; Input.view
                                ~id:"checkout-7j9-cvv"
                                ~placeholder:"123"
                                ~required:true
                                ()
                            ]
                        ]
                    ]
                ]
            ; Field.separator []
            ; Field.set
                [ Field.legend [ Node.text "Billing Address" ]
                ; Field.description
                    [ Node.text "The billing address associated with your payment method" ]
                ; Field.group
                    [ Field.root
                        ~orientation:Horizontal
                        [ same_as_shipping.view
                        ; Field.label
                            ~for_:"checkout-7j9-same-as-shipping-wgm"
                            ~class_:"font-normal"
                            [ Node.text "Same as shipping address" ]
                        ]
                    ]
                ]
            ; Field.set
                [ Field.group
                    [ Field.root
                        [ Field.label
                            ~for_:"checkout-7j9-optional-comments"
                            [ Node.text "Comments" ]
                        ; Textarea.view
                            ~id:"checkout-7j9-optional-comments"
                            ~placeholder:"Add any additional comments"
                            ~class_:"resize-none"
                            ()
                        ]
                    ]
                ]
            ; Field.root
                ~orientation:Horizontal
                [ Button.view ~type_:`Submit [ Node.text "Submit" ]
                ; Button.view ~variant:Outline ~type_:`Button [ Node.text "Cancel" ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Input *)
let input =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.set
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"username" [ Node.text "Username" ]
                ; Input.view ~id:"username" ~type_:Text ~placeholder:"Max Leiter" ()
                ; Field.description
                    [ Node.text "Choose a unique username for your account." ]
                ]
            ; Field.root
                [ Field.label ~for_:"password" [ Node.text "Password" ]
                ; Field.description [ Node.text "Must be at least 8 characters long." ]
                ; Input.view
                    ~id:"password"
                    ~type_:Password
                    ~placeholder:"\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}\u{2022}"
                    ()
                ]
            ]
        ]
    ]
(*$*)

(*$ Textarea *)
let textarea =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.set
        [ Field.group
            [ Field.root
                [ Field.label ~for_:"feedback" [ Node.text "Feedback" ]
                ; Textarea.view
                    ~id:"feedback"
                    ~placeholder:"Your feedback helps us improve..."
                    ~rows:4
                    ()
                ; Field.description [ Node.text "Share your thoughts about our service." ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Select
   With [Native_select]. *)
let select =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.root
        [ Field.label ~for_:"department" [ Node.text "Department" ]
        ; Native_select.view
            ~id:"department"
            ~class_:"w-full"
            [ Native_select.option ~value:"" [ Node.text "Choose department" ]
            ; Native_select.option ~value:"engineering" [ Node.text "Engineering" ]
            ; Native_select.option ~value:"design" [ Node.text "Design" ]
            ; Native_select.option ~value:"marketing" [ Node.text "Marketing" ]
            ; Native_select.option ~value:"sales" [ Node.text "Sales" ]
            ; Native_select.option ~value:"support" [ Node.text "Customer Support" ]
            ; Native_select.option ~value:"hr" [ Node.text "Human Resources" ]
            ; Native_select.option ~value:"finance" [ Node.text "Finance" ]
            ; Native_select.option ~value:"operations" [ Node.text "Operations" ]
            ]
        ; Field.description [ Node.text "Select your department or area of work." ]
        ]
    ]
(*$*)

(*$ Slider *)
let slider (local_ graph) =
  let value, set_value = Bonsai.state [ 200.; 800. ] graph in
  let%arr value and set_value in
  let number i =
    Node.span
      ~attrs:[ Attr.class_ "font-medium tabular-nums" ]
      [ Node.text (Float.to_string_hum ~decimals:0 (List.nth_exn value i)) ]
  in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.root
        [ Field.title [ Node.text "Price Range" ]
        ; Field.description
            [ Node.text "Set your budget range ($"
            ; number 0
            ; Node.text " - "
            ; number 1
            ; Node.text ")."
            ]
        ; Slider.view
            ~attrs:[ Attr.create "aria-label" "Price Range" ]
            ~value
            ~on_change:set_value
            ~max:1000.
            ~min:0.
            ~step:10.
            ~class_:"mt-2 w-full"
            ()
        ]
    ]
(*$*)

(*$ Fieldset *)
let fieldset =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md space-y-6" ]
    [ Field.set
        [ Field.legend [ Node.text "Address Information" ]
        ; Field.description [ Node.text "We need your address to deliver your order." ]
        ; Field.group
            [ Field.root
                [ Field.label ~for_:"street" [ Node.text "Street Address" ]
                ; Input.view ~id:"street" ~type_:Text ~placeholder:"123 Main St" ()
                ]
            ; Node.div
                ~attrs:[ Attr.class_ "grid grid-cols-2 gap-4" ]
                [ Field.root
                    [ Field.label ~for_:"city" [ Node.text "City" ]
                    ; Input.view ~id:"city" ~type_:Text ~placeholder:"New York" ()
                    ]
                ; Field.root
                    [ Field.label ~for_:"zip" [ Node.text "Postal Code" ]
                    ; Input.view ~id:"zip" ~type_:Text ~placeholder:"90502" ()
                    ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Checkbox *)
let checkbox (local_ graph) =
  let item ~id ?default_checked label =
    let%arr checkbox = Checkbox.component ~id ?default_checked graph in
    Field.root
      ~orientation:Horizontal
      [ checkbox.view; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ] ]
  in
  let hard_disks = item ~id:"finder-pref-9k2-hard-disks-ljj" "Hard disks" in
  let external_disks = item ~id:"finder-pref-9k2-external-disks-1yg" "External disks" in
  let cds = item ~id:"finder-pref-9k2-cds-dvds-fzt" "CDs, DVDs, and iPods" in
  let servers = item ~id:"finder-pref-9k2-connected-servers-6l2" "Connected servers" in
  let sync =
    Checkbox.component ~id:"finder-pref-9k2-sync-folders-nep" ~default_checked:true graph
  in
  let%arr hard_disks and external_disks and cds and servers and sync in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.group
        [ Field.set
            [ Field.legend ~variant:Label [ Node.text "Show these items on the desktop" ]
            ; Field.description
                [ Node.text "Select the items you want to show on the desktop." ]
            ; Field.group ~class_:"gap-3" [ hard_disks; external_disks; cds; servers ]
            ]
        ; Field.separator []
        ; Field.root
            ~orientation:Horizontal
            [ sync.view
            ; Field.content
                [ Field.label
                    ~for_:"finder-pref-9k2-sync-folders-nep"
                    [ Node.text "Sync Desktop & Documents folders" ]
                ; Field.description
                    [ Node.text
                        "Your Desktop & Documents folders are being synced with iCloud \
                         Drive. You can access them from other devices."
                    ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Radio *)
let radio (local_ graph) =
  let%arr plan =
    Radio_group.component
      ~default_value:"monthly"
      (return (fun group ->
         List.map
           [ "monthly", "plan-monthly", "Monthly ($9.99/month)"
           ; "yearly", "plan-yearly", "Yearly ($99.99/year)"
           ; "lifetime", "plan-lifetime", "Lifetime ($299.99)"
           ]
           ~f:(fun (value, id, label) ->
             Field.root
               ~orientation:Horizontal
               [ Radio_group.item group ~value ~id
               ; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ]
               ])))
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.set
        [ Field.label [ Node.text "Subscription Plan" ]
        ; Field.description
            [ Node.text "Yearly and lifetime plans offer significant savings." ]
        ; plan.view
        ]
    ]
(*$*)

(*$ Switch *)
let switch (local_ graph) =
  let%arr mfa = Switch.component ~id:"2fa" graph in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.root
        ~orientation:Horizontal
        [ Field.content
            [ Field.label ~for_:"2fa" [ Node.text "Multi-factor authentication" ]
            ; Field.description
                [ Node.text
                    "Enable multi-factor authentication. If you do not have a two-factor \
                     device, you can use a one-time code sent to your email."
                ]
            ]
        ; mfa.view
        ]
    ]
(*$*)

(*$ Choice Card
   Wrap a [Field] in a [Field.label] for a selectable card; the checked
   control highlights it. *)
let choice_card (local_ graph) =
  let%arr environment =
    Radio_group.component
      ~default_value:"kubernetes"
      (return (fun group ->
         List.map
           [ ( "kubernetes"
             , "kubernetes-r2h"
             , "Kubernetes"
             , "Run GPU workloads on a K8s configured cluster." )
           ; ( "vm"
             , "vm-z4k"
             , "Virtual Machine"
             , "Access a VM configured cluster to run GPU workloads." )
           ]
           ~f:(fun (value, id, title, description) ->
             Field.label
               ~for_:id
               [ Field.root
                   ~orientation:Horizontal
                   [ Field.content
                       [ Field.title [ Node.text title ]
                       ; Field.description [ Node.text description ]
                       ]
                   ; Radio_group.item group ~value ~id
                   ]
               ])))
      graph
  in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.group
        [ Field.set
            [ Field.label ~for_:"compute-environment-p8w" [ Node.text "Compute Environment" ]
            ; Field.description
                [ Node.text "Select the compute environment for your cluster." ]
            ; environment.view
            ]
        ]
    ]
(*$*)

(*$ Field Group
   Stack fields with [Field.group]; [Field.separator] divides them. *)
let field_group (local_ graph) =
  let push = Checkbox.component ~id:"push" ~default_checked:true ~disabled:true graph in
  let push_tasks = Checkbox.component ~id:"push-tasks" graph in
  let email_tasks = Checkbox.component ~id:"email-tasks" graph in
  let%arr push and push_tasks and email_tasks in
  let item (checkbox : bool Control.t) ~id label =
    Field.root
      ~orientation:Horizontal
      [ checkbox.view; Field.label ~for_:id ~class_:"font-normal" [ Node.text label ] ]
  in
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.group
        [ Field.set
            [ Field.label [ Node.text "Responses" ]
            ; Field.description
                [ Node.text
                    "Get notified when ChatGPT responds to requests that take time, like \
                     research or image generation."
                ]
            ; Field.group
                ~attrs:[ Attr.suppress_merge_warnings (Attr.create "data-slot" "checkbox-group") ]
                [ item push ~id:"push" "Push notifications" ]
            ]
        ; Field.separator []
        ; Field.set
            [ Field.label [ Node.text "Tasks" ]
            ; Field.description
                [ Node.text "Get notified when tasks you've created have updates. "
                ; Node.a ~attrs:[ Attr.href "#/field" ] [ Node.text "Manage tasks" ]
                ]
            ; Field.group
                ~attrs:[ Attr.suppress_merge_warnings (Attr.create "data-slot" "checkbox-group") ]
                [ item push_tasks ~id:"push-tasks" "Push notifications"
                ; item email_tasks ~id:"email-tasks" "Email notifications"
                ]
            ]
        ]
    ]
(*$*)

(*$ Responsive Layout
   [~orientation:Responsive] stacks the label above the control in a narrow
   [Field.group] and puts them side by side in a wide one (a container
   query). *)
let responsive =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-4xl" ]
    [ Node.form
        ~attrs:[ Attr.on_submit Dom_util.prevent_default ]
        [ Field.set
            [ Field.legend [ Node.text "Profile" ]
            ; Field.description [ Node.text "Fill in your profile information." ]
            ; Field.separator []
            ; Field.group
                [ Field.root
                    ~orientation:Responsive
                    [ Field.content
                        [ Field.label ~for_:"name" [ Node.text "Name" ]
                        ; Field.description
                            [ Node.text "Provide your full name for identification" ]
                        ]
                    ; Input.view ~id:"name" ~placeholder:"Evil Rabbit" ~required:true ()
                    ]
                ; Field.separator []
                ; Field.root
                    ~orientation:Responsive
                    [ Field.content
                        [ Field.label ~for_:"message" [ Node.text "Message" ]
                        ; Field.description
                            [ Node.text
                                "You can write your message here. Keep it short, \
                                 preferably under 100 characters."
                            ]
                        ]
                    ; Textarea.view
                        ~id:"message"
                        ~placeholder:"Hello, world!"
                        ~required:true
                        ~class_:"min-h-[100px] resize-none sm:min-w-[300px]"
                        ()
                    ]
                ; Field.separator []
                ; Field.root
                    ~orientation:Responsive
                    [ Button.view ~type_:`Submit [ Node.text "Submit" ]
                    ; Button.view ~type_:`Button ~variant:Outline [ Node.text "Cancel" ]
                    ]
                ]
            ]
        ]
    ]
(*$*)

(*$ Validation and Errors
   [~invalid:true] on the [Field] turns it destructive; put [aria-invalid]
   on the control ([~invalid:true]) and the message in [Field.error]. *)
let errors =
  Node.div
    ~attrs:[ Attr.class_ "w-full max-w-md" ]
    [ Field.root
        ~invalid:true
        [ Field.label ~for_:"email-error" [ Node.text "Email" ]
        ; Input.view ~id:"email-error" ~type_:Email ~invalid:true ()
        ; Field.error [ Node.text "Enter a valid email address." ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Field"
    ~group:Forms
    ~description:
      "Combine labels, controls, and help text to compose accessible form fields and \
       grouped inputs."
    ~usage:
      {|Field.set
  [ Field.legend [ Node.text "Profile" ]
  ; Field.description [ Node.text "This appears on invoices and emails." ]
  ; Field.group
      [ Field.root
          [ Field.label ~for_:"name" [ Node.text "Full name" ]
          ; Input.view ~id:"name" ~placeholder:"Evil Rabbit" ()
          ; Field.description [ Node.text "This appears on invoices and emails." ]
          ]
      ; Field.root
          ~invalid:true
          [ Field.label ~for_:"username" [ Node.text "Username" ]
          ; Input.view ~id:"username" ~invalid:true ()
          ; Field.error [ Node.text "Choose another username." ]
          ]
      ; Field.root
          ~orientation:Horizontal
          [ Switch.view ~id:"newsletter" ~checked ~on_change:set_checked ()
          ; Field.label ~for_:"newsletter" [ Node.text "Subscribe to the newsletter" ]
          ]
      ]
  ]|}
    ~body:
      [ Doc.h2 "Anatomy"
      ; Doc.p
          "[Field.set] is a [<fieldset>] with a [Field.legend]; [Field.group] stacks \
           fields. [Field.root] is one field ([role=\"group\"]): a [Field.label], the \
           control, a [Field.description] and a [Field.error]. [Field.content] stacks a \
           label and description beside a control in a horizontal field; \
           [Field.title] is a title that is not a [<label>]; [Field.separator] divides \
           sections, with optional text."
      ; Doc.h2 "Arguments"
      ; Doc.props
          [ ( "orientation"
            , "Field.Orientation.t"
            , "On [Field.root]: [Vertical] (default), [Horizontal] or [Responsive]." )
          ; ( "invalid"
            , "bool"
            , "On [Field.root]: sets [data-invalid], turning the field destructive." )
          ; ( "disabled"
            , "bool"
            , "On [Field.root]: sets [data-disabled], fading the label." )
          ; ( "variant"
            , "Field.Legend_variant.t"
            , "On [Field.legend]: [Legend] (default) or [Label] (label-sized)." )
          ; ( "errors"
            , "string list"
            , "On [Field.error]: messages shown when it has no children (several as a \
               list)." )
          ; "for_", "string", "On [Field.label]: the control's id."
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.static ~page "Input" input
    ; Doc.static ~page "Textarea" textarea
    ; Doc.static ~page "Select" select
    ; Doc.example ~page "Slider" slider
    ; Doc.static ~page "Fieldset" fieldset
    ; Doc.example ~page "Checkbox" checkbox
    ; Doc.example ~page "Radio" radio
    ; Doc.example ~page "Switch" switch
    ; Doc.example ~page "Choice Card" choice_card
    ; Doc.example ~page "Field Group" field_group
    ; Doc.static ~page "Responsive Layout" responsive
    ; Doc.static ~page "Validation and Errors" errors
    ]
;;
