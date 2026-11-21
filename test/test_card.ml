open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "a card's parts" =
  Render.html
    (Card.root
       ~class_:"w-full max-w-sm"
       [ Card.header
           [ Card.title [ Node.text "Title" ]
           ; Card.description [ Node.text "Description" ]
           ; Card.action [ Node.text "Action" ]
           ]
       ; Card.content [ Node.text "Content" ]
       ; Card.footer ~class_:"border-t" [ Node.text "Footer" ]
       ]);
  [%expect {|
    <div data-slot="card"
         class="bg-card border flex flex-col gap-6 max-w-sm py-6 rounded-xl shadow-sm text-card-foreground w-full">
      <div data-slot="card-header"
           class="@container/card-header [.border-b]:pb-6 auto-rows-min gap-2 grid grid-rows-[auto_auto] has-data-[slot=card-action]:grid-cols-[1fr_auto] items-start px-6">
        <div data-slot="card-title" class="font-semibold leading-none"> Title </div>
        <div data-slot="card-description" class="text-muted-foreground text-sm"> Description </div>
        <div data-slot="card-action"
             class="col-start-2 justify-self-end row-span-2 row-start-1 self-start"> Action </div>
      </div>
      <div data-slot="card-content" class="px-6"> Content </div>
      <div data-slot="card-footer" class="[.border-t]:pt-6 border-t flex items-center px-6"> Footer </div>
    </div>
    |}]
;;

let%expect_test "badges" =
  Render.html (Badge.view [ Node.text "Badge" ]);
  [%expect {|
    <span data-slot="badge"
          data-variant="default"
          class="[&>svg]:pointer-events-none [&>svg]:size-3 [a&]:hover:bg-primary/90 aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-primary border border-transparent dark:aria-invalid:ring-destructive/40 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-1 inline-flex items-center justify-center overflow-hidden px-2 py-0.5 rounded-full shrink-0 text-primary-foreground text-xs transition-[color,box-shadow] w-fit whitespace-nowrap"> Badge </span>
    |}];
  List.iter Badge.Variant.all ~f:(fun variant ->
    Render.html ~classes:false (Badge.view ~variant [ Node.text "Badge" ]));
  [%expect {|
    <span data-slot="badge" data-variant="default"> Badge </span>
    <span data-slot="badge" data-variant="secondary"> Badge </span>
    <span data-slot="badge" data-variant="destructive"> Badge </span>
    <span data-slot="badge" data-variant="outline"> Badge </span>
    <span data-slot="badge" data-variant="ghost"> Badge </span>
    <span data-slot="badge" data-variant="link"> Badge </span>
    |}];
  Render.html ~classes:false (Badge.link ~href:"#" [ Node.text "Link" ]);
  [%expect {| <a href="#" data-slot="badge" data-variant="default"> Link </a> |}]
;;
