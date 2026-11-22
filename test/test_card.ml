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
    <div data-slot="card" data-size="default" class="cn-card flex flex-col group/card max-w-sm w-full">
      <div data-slot="card-header"
           class="@container/card-header auto-rows-min cn-card-header grid group/card-header has-data-[slot=card-action]:grid-cols-[1fr_auto] has-data-[slot=card-description]:grid-rows-[auto_auto] items-start">
        <div data-slot="card-title" class="cn-card-title cn-font-heading"> Title </div>
        <div data-slot="card-description" class="cn-card-description"> Description </div>
        <div data-slot="card-action"
             class="cn-card-action col-start-2 justify-self-end row-span-2 row-start-1 self-start"> Action </div>
      </div>
      <div data-slot="card-content" class="cn-card-content"> Content </div>
      <div data-slot="card-footer" class="border-t cn-card-footer flex items-center"> Footer </div>
    </div>
    |}]
;;

let%expect_test "badges" =
  Render.html (Badge.view [ Node.text "Badge" ]);
  [%expect {|
    <span data-slot="badge"
          data-variant="default"
          class="[&>svg]:pointer-events-none aria-invalid:border-destructive aria-invalid:ring-destructive/20 cn-badge cn-badge-variant-default dark:aria-invalid:ring-destructive/40 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 group/badge inline-flex items-center justify-center overflow-hidden shrink-0 w-fit whitespace-nowrap"> Badge </span>
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
