open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Alert.root
       [ Icon.view Circle_check
       ; Alert.title [ Node.text "Success! Your changes have been saved" ]
       ; Alert.description [ Node.text "This is an alert with icon, title and description." ]
       ]);
  [%expect {|
    <div data-slot="alert"
         role="alert"
         class="cn-alert cn-alert-variant-default group/alert relative w-full">
      <svg xmlns="http://www.w3.org/2000/svg"
           width="24"
           height="24"
           viewBox="0 0 24 24"
           fill="none"
           stroke="currentColor"
           stroke-width="2"
           stroke-linecap="round"
           stroke-linejoin="round"
           class="lucide lucide-circle-check">
        <circle cx="12" cy="12" r="10"> </circle>
        <path d="m9 12 2 2 4-4"> </path>
      </svg>
      <div data-slot="alert-title"
           class="[&_a]:hover:text-foreground [&_a]:underline [&_a]:underline-offset-3 cn-alert-title"> Success! Your changes have been saved </div>
      <div data-slot="alert-description"
           class="[&_a]:hover:text-foreground [&_a]:underline [&_a]:underline-offset-3 cn-alert-description"> This is an alert with icon, title and description. </div>
    </div>
    |}]
;;

let%expect_test "destructive, and the caller's class wins" =
  Render.html
    ~selector:"[data-slot=alert]"
    (Alert.root
       ~variant:Destructive
       ~class_:"px-6"
       [ Alert.title [ Node.text "Error" ] ]);
  [%expect {|
    <div data-slot="alert"
         role="alert"
         class="cn-alert cn-alert-variant-destructive group/alert px-6 relative w-full">
      <div data-slot="alert-title"
           class="[&_a]:hover:text-foreground [&_a]:underline [&_a]:underline-offset-3 cn-alert-title"> Error </div>
    </div>
    |}]
;;
