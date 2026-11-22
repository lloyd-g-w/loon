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
         class="[&>svg]:size-4 [&>svg]:text-current [&>svg]:translate-y-0.5 bg-card border gap-y-0.5 grid grid-cols-[0_1fr] has-[>svg]:gap-x-3 has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] items-start px-4 py-3 relative rounded-lg text-card-foreground text-sm w-full">
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
      <div data-slot="alert-title" class="col-start-2 font-medium line-clamp-1 min-h-4 tracking-tight"> Success! Your changes have been saved </div>
      <div data-slot="alert-description"
           class="[&_p]:leading-relaxed col-start-2 gap-1 grid justify-items-start text-muted-foreground text-sm"> This is an alert with icon, title and description. </div>
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
         class="*:data-[slot=alert-description]:text-destructive/90 [&>svg]:size-4 [&>svg]:text-current [&>svg]:translate-y-0.5 bg-card border gap-y-0.5 grid grid-cols-[0_1fr] has-[>svg]:gap-x-3 has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] items-start px-6 py-3 relative rounded-lg text-destructive text-sm w-full">
      <div data-slot="alert-title" class="col-start-2 font-medium line-clamp-1 min-h-4 tracking-tight"> Error </div>
    </div>
    |}]
;;
