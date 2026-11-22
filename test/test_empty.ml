open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Empty.root
       [ Empty.header
           [ Empty.media ~variant:Icon [ Icon.view Folder_code ]
           ; Empty.title [ Node.text "No Projects Yet" ]
           ; Empty.description [ Node.text "Get started." ]
           ]
       ; Empty.content [ Node.text "Actions" ]
       ]);
  [%expect {|
    <div data-slot="empty"
         class="cn-empty flex flex-1 flex-col items-center justify-center min-w-0 text-balance text-center w-full">
      <div data-slot="empty-header" class="cn-empty-header flex flex-col items-center max-w-sm">
        <div data-slot="empty-icon"
             data-variant="icon"
             class="[&_svg]:pointer-events-none [&_svg]:shrink-0 cn-empty-media cn-empty-media-icon flex items-center justify-center shrink-0">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               class="lucide lucide-folder-code">
            <path d="M10 10.5 8 13l2 2.5"> </path>
            <path d="m14 10.5 2 2.5-2 2.5"> </path>
            <path d="M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2z"> </path>
          </svg>
        </div>
        <div data-slot="empty-title" class="cn-empty-title cn-font-heading"> No Projects Yet </div>
        <div data-slot="empty-description"
             class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 cn-empty-description text-muted-foreground"> Get started. </div>
      </div>
      <div data-slot="empty-content"
           class="cn-empty-content flex flex-col items-center max-w-sm min-w-0 text-balance w-full"> Actions </div>
    </div>
    |}]
;;
