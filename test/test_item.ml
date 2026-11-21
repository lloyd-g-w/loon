open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "shadcn's classes" =
  Render.html
    (Item.group
       [ Item.view
           ~variant:Outline
           [ Item.media ~variant:Icon [ Icon.view Shield_exclamation_point ]
           ; Item.content
               [ Item.title [ Node.text "Security Alert" ]
               ; Item.description [ Node.text "New login detected." ]
               ]
           ; Item.actions [ Node.text "Review" ]
           ]
       ; Item.separator ()
       ; Item.link
           ~size:Sm
           ~href:"#"
           [ Item.header [ Node.text "Header" ]; Item.footer [ Node.text "Footer" ] ]
       ]);
  [%expect {|
    <div role="list" data-slot="item-group" class="flex flex-col group/item-group">
      <div data-slot="item"
           data-variant="outline"
           data-size="default"
           class="[a]:hover:bg-accent/50 [a]:transition-colors border border-border duration-100 flex flex-wrap focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 gap-4 group/item items-center outline-none p-4 rounded-md text-sm transition-colors">
        <div data-slot="item-media"
             data-variant="icon"
             class="[&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none bg-muted border flex gap-2 group-has-[[data-slot=item-description]]/item:self-start group-has-[[data-slot=item-description]]/item:translate-y-0.5 items-center justify-center rounded-sm shrink-0 size-8">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true"
               class="lucide lucide-shield-exclamation-point">
            <path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z"> </path>
            <path d="M12 8v4"> </path>
            <path d="M12 16h.01"> </path>
          </svg>
        </div>
        <div data-slot="item-content"
             class="[&+[data-slot=item-content]]:flex-none flex flex-1 flex-col gap-1">
          <div data-slot="item-title"
               class="flex font-medium gap-2 items-center leading-snug text-sm w-fit"> Security Alert </div>
          <p data-slot="item-description"
             class="[&>a:hover]:text-primary [&>a]:underline [&>a]:underline-offset-4 font-normal leading-normal line-clamp-2 text-balance text-muted-foreground text-sm"> New login detected. </p>
        </div>
        <div data-slot="item-actions" class="flex gap-2 items-center"> Review </div>
      </div>
      <div data-slot="item-separator"
           role="none"
           data-orientation="horizontal"
           class="bg-border data-[orientation=horizontal]:h-px data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full data-[orientation=vertical]:w-px my-0 shrink-0"> </div>
      <a data-slot="item"
         data-variant="default"
         data-size="sm"
         href="#"
         class="[a]:hover:bg-accent/50 [a]:transition-colors bg-transparent border border-transparent duration-100 flex flex-wrap focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 gap-2.5 group/item items-center outline-none px-4 py-3 rounded-md text-sm transition-colors">
        <div data-slot="item-header" class="basis-full flex gap-2 items-center justify-between"> Header </div>
        <div data-slot="item-footer" class="basis-full flex gap-2 items-center justify-between"> Footer </div>
      </a>
    </div>
    |}]
;;

let%expect_test "variants and sizes as data attributes" =
  List.iter Item.Variant.all ~f:(fun variant ->
    List.iter Item.Size.all ~f:(fun size ->
      Render.html ~classes:false (Item.view ~variant ~size [])));
  [%expect {|
    <div data-slot="item" data-variant="default" data-size="default"> </div>
    <div data-slot="item" data-variant="default" data-size="sm"> </div>
    <div data-slot="item" data-variant="outline" data-size="default"> </div>
    <div data-slot="item" data-variant="outline" data-size="sm"> </div>
    <div data-slot="item" data-variant="muted" data-size="default"> </div>
    <div data-slot="item" data-variant="muted" data-size="sm"> </div>
    |}]
;;
