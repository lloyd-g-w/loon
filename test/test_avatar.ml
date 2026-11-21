open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let parts avatar =
  [ Avatar.image avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" ()
  ; Avatar.fallback avatar [ Node.text "CN" ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Avatar.group
       [ Avatar.view
           ~status:Loaded
           ~on_status_change:(fun _ -> Bonsai_web.Effect.Ignore)
           (fun avatar -> parts avatar @ [ Avatar.badge [] ])
       ; Avatar.group_count [ Node.text "+3" ]
       ]);
  [%expect {|
    <div data-slot="avatar-group"
         class="*:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background -space-x-2 flex group/avatar-group">
      <span data-slot="avatar"
            data-size="default"
            class="data-[size=lg]:size-10 data-[size=sm]:size-6 flex group/avatar overflow-hidden relative rounded-full select-none shrink-0 size-8">
        <img data-slot="avatar-image"
             src="https://github.com/shadcn.png"
             alt="@shadcn"
             class="aspect-square size-full"
             @on_error
             @on_load/>
        <Vdom.Node.none-widget> </Vdom.Node.none-widget>
        <span data-slot="avatar-badge"
              class="absolute bg-primary bottom-0 group-data-[size=default]/avatar:[&>svg]:size-2 group-data-[size=default]/avatar:size-2.5 group-data-[size=lg]/avatar:[&>svg]:size-2 group-data-[size=lg]/avatar:size-3 group-data-[size=sm]/avatar:[&>svg]:hidden group-data-[size=sm]/avatar:size-2 inline-flex items-center justify-center right-0 ring-2 ring-background rounded-full select-none text-primary-foreground z-10"> </span>
      </span>
      <div data-slot="avatar-group-count"
           class="[&>svg]:size-4 bg-muted flex group-has-data-[size=lg]/avatar-group:[&>svg]:size-5 group-has-data-[size=lg]/avatar-group:size-10 group-has-data-[size=sm]/avatar-group:[&>svg]:size-3 group-has-data-[size=sm]/avatar-group:size-6 items-center justify-center relative ring-2 ring-background rounded-full shrink-0 size-8 text-muted-foreground text-sm"> +3 </div>
    </div>
    |}]
;;

let%expect_test "the fallback shows until the image loads, and if it fails" =
  List.iter Avatar.Status.all ~f:(fun status ->
    print_s [%sexp (status : Avatar.Status.t)];
    Render.html
      ~classes:false
      (Avatar.view
         ~size:Sm
         ~status
         ~on_status_change:(fun _ -> Bonsai_web.Effect.Ignore)
         parts));
  [%expect {|
    Loading
    <span data-slot="avatar" data-size="sm">
      <img data-slot="avatar-image"
           src="https://github.com/shadcn.png"
           alt="@shadcn"
           hidden=""
           @on_error
           @on_load/>
      <span data-slot="avatar-fallback"> CN </span>
    </span>
    Loaded
    <span data-slot="avatar" data-size="sm">
      <img data-slot="avatar-image"
           src="https://github.com/shadcn.png"
           alt="@shadcn"
           @on_error
           @on_load/>
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
    </span>
    Error
    <span data-slot="avatar" data-size="sm">
      <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      <span data-slot="avatar-fallback"> CN </span>
    </span>
    |}]
;;

let%expect_test "component: the image reports its load" =
  let handle =
    Render.handle ~classes:false (Avatar.component (Bonsai_web.Bonsai.return parts))
  in
  Handle.show handle;
  [%expect {|
    <span data-slot="avatar" data-size="default">
      <img data-slot="avatar-image"
           src="https://github.com/shadcn.png"
           alt="@shadcn"
           hidden=""
           @on_error
           @on_load/>
      <span data-slot="avatar-fallback"> CN </span>
    </span>
    |}];
  Virtual_dom_test_helpers.Node_helpers.(
    unsafe_convert_exn (Handle.last_result handle)
    |> select_first_exn ~selector:"img"
    |> trigger ~event_name:"onload");
  Handle.show_diff handle;
  [%expect {|
      <span data-slot="avatar" data-size="default">
        <img data-slot="avatar-image"
             src="https://github.com/shadcn.png"
             alt="@shadcn"
    -|       hidden=""
             @on_error
             @on_load/>
    -|  <span data-slot="avatar-fallback"> CN </span>
    +|  <Vdom.Node.none-widget> </Vdom.Node.none-widget>
      </span>
    |}]
;;
