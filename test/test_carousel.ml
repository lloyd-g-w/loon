open! Core
open Loon
open Bonsai_web
module Node = Vdom.Node
module Handle = Bonsai_web_test.Handle

let slides carousel =
  List.init 3 ~f:(fun i ->
    Carousel.item carousel [ Node.text (Int.to_string (i + 1)) ])
;;

let view carousel =
  Carousel.root
    carousel
    ~class_:"w-full max-w-xs"
    [ Carousel.content carousel (slides carousel)
    ; Carousel.previous carousel
    ; Carousel.next carousel
    ]
;;

let controlled ?orientation ?loop selected =
  Carousel.create
    ?orientation
    ?loop
    ~id:"carousel"
    ~state:{ selected; count = 3 }
    ~on_change:(fun state ->
      Effect.of_thunk (fun () -> print_s [%sexp (state : Carousel.State.t)]))
    ()
;;

let%expect_test "shadcn's classes" =
  Render.html (view (controlled 0));
  [%expect {|
    <div role="region"
         aria-roledescription="carousel"
         data-slot="carousel"
         class="max-w-xs relative w-full"
         @on_keydown>
      <div data-slot="carousel-content"
           class="overflow-hidden"
           @on_click_global
           loon-after-render-carousel=<opaque>
           @on_pointerdown
           @on_pointermove
           @on_pointerup
           style={
             touch-action: pan-y pinch-zoom;
           }>
        <div class="-ml-4 flex">
          <div role="group"
               aria-roledescription="slide"
               data-slot="carousel-item"
               class="basis-full grow-0 min-w-0 pl-4 shrink-0"> 1 </div>
          <div role="group"
               aria-roledescription="slide"
               data-slot="carousel-item"
               class="basis-full grow-0 min-w-0 pl-4 shrink-0"> 2 </div>
          <div role="group"
               aria-roledescription="slide"
               data-slot="carousel-item"
               class="basis-full grow-0 min-w-0 pl-4 shrink-0"> 3 </div>
        </div>
      </div>
      <button type="button"
              data-slot="carousel-previous"
              data-variant="outline"
              data-size="icon"
              disabled=""
              class="-left-12 -translate-y-1/2 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 absolute aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none rounded-full shadow-xs shrink-0 size-8 text-sm top-1/2 transition-all whitespace-nowrap">
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
             class="lucide lucide-arrow-left">
          <path d="m12 19-7-7 7-7"> </path>
          <path d="M19 12H5"> </path>
        </svg>
        <span class="sr-only"> Previous slide </span>
      </button>
      <button type="button"
              data-slot="carousel-next"
              data-variant="outline"
              data-size="icon"
              class="-right-12 -translate-y-1/2 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 absolute aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center outline-none rounded-full shadow-xs shrink-0 size-8 text-sm top-1/2 transition-all whitespace-nowrap"
              @on_click>
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
             class="lucide lucide-arrow-right">
          <path d="M5 12h14"> </path>
          <path d="m12 5 7 7-7 7"> </path>
        </svg>
        <span class="sr-only"> Next slide </span>
      </button>
    </div>
    |}]
;;

let%expect_test "vertical" =
  let node = view (controlled ~orientation:Vertical 1) in
  Render.html ~selector:"[data-slot=carousel-content]" node;
  Render.html ~selector:"[data-slot=carousel-next]" node;
  [%expect {|
    <div data-slot="carousel-content"
         class="overflow-hidden"
         @on_click_global
         loon-after-render-carousel=<opaque>
         @on_pointerdown
         @on_pointermove
         @on_pointerup
         style={
           touch-action: pan-x pinch-zoom;
         }>
      <div class="-mt-4 flex flex-col">
        <div role="group"
             aria-roledescription="slide"
             data-slot="carousel-item"
             class="basis-full grow-0 min-w-0 pt-4 shrink-0"> 1 </div>
        <div role="group"
             aria-roledescription="slide"
             data-slot="carousel-item"
             class="basis-full grow-0 min-w-0 pt-4 shrink-0"> 2 </div>
        <div role="group"
             aria-roledescription="slide"
             data-slot="carousel-item"
             class="basis-full grow-0 min-w-0 pt-4 shrink-0"> 3 </div>
      </div>
    </div>
    <button type="button"
            data-slot="carousel-next"
            data-variant="outline"
            data-size="icon"
            class="-bottom-12 -translate-x-1/2 [&_svg:not([class*='size-'])]:size-4 [&_svg]:pointer-events-none [&_svg]:shrink-0 absolute aria-invalid:border-destructive aria-invalid:ring-destructive/20 bg-background border dark:aria-invalid:ring-destructive/40 dark:bg-input/30 dark:border-input dark:hover:bg-input/50 disabled:opacity-50 disabled:pointer-events-none focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-2 hover:bg-accent hover:text-accent-foreground inline-flex items-center justify-center left-1/2 outline-none rotate-90 rounded-full shadow-xs shrink-0 size-8 text-sm transition-all whitespace-nowrap"
            @on_click>
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
           class="lucide lucide-arrow-right">
        <path d="M5 12h14"> </path>
        <path d="m12 5 7 7-7 7"> </path>
      </svg>
      <span class="sr-only"> Next slide </span>
    </button>
    |}]
;;

let%expect_test "buttons and arrow keys move one slide, not past the ends" =
  let handle =
    Render.handle ~classes:false (fun _ -> Bonsai.return (view (controlled 0)))
  in
  Drive.click handle "[data-slot=carousel-next]";
  Drive.key handle "[data-slot=carousel]" ArrowRight;
  Drive.key handle "[data-slot=carousel]" ArrowLeft;
  [%expect {|
    ((selected 1) (count 3))
    ("default prevented" (key ArrowRight))
    ((selected 1) (count 3))
    ("default prevented" (key ArrowLeft))
    |}];
  let handle =
    Render.handle ~classes:false (fun _ -> Bonsai.return (view (controlled 2)))
  in
  Drive.click handle "[data-slot=carousel-previous]";
  Drive.key handle "[data-slot=carousel]" ArrowRight;
  [%expect {|
    ((selected 1) (count 3))
    ("default prevented" (key ArrowRight))
    |}];
  Handle.show handle;
  [%expect {|
    <div role="region" aria-roledescription="carousel" data-slot="carousel" @on_keydown>
      <div data-slot="carousel-content"
           @on_click_global
           loon-after-render-carousel=<opaque>
           @on_pointerdown
           @on_pointermove
           @on_pointerup
           style={
             touch-action: pan-y pinch-zoom;
           }>
        <div>
          <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 1 </div>
          <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 2 </div>
          <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 3 </div>
        </div>
      </div>
      <button type="button"
              data-slot="carousel-previous"
              data-variant="outline"
              data-size="icon"
              @on_click>
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true">
          <path d="m12 19-7-7 7-7"> </path>
          <path d="M19 12H5"> </path>
        </svg>
        <span> Previous slide </span>
      </button>
      <button type="button"
              data-slot="carousel-next"
              data-variant="outline"
              data-size="icon"
              disabled="">
        <svg xmlns="http://www.w3.org/2000/svg"
             width="24"
             height="24"
             viewBox="0 0 24 24"
             fill="none"
             stroke="currentColor"
             stroke-width="2"
             stroke-linecap="round"
             stroke-linejoin="round"
             aria-hidden="true">
          <path d="M5 12h14"> </path>
          <path d="m12 5 7 7-7 7"> </path>
        </svg>
        <span> Next slide </span>
      </button>
    </div>
    |}]
;;

let%expect_test "loop goes round" =
  let handle =
    Render.handle ~classes:false (fun _ -> Bonsai.return (view (controlled ~loop:true 2)))
  in
  Drive.key handle "[data-slot=carousel]" ArrowRight;
  Drive.click handle "[data-slot=carousel-next]";
  [%expect {|
    ("default prevented" (key ArrowRight))
    ((selected 0) (count 3))
    ((selected 0) (count 3))
    |}]
;;

let%expect_test "component: the api and the buttons follow the state" =
  let handle =
    Render.handle
      ~classes:false
      (let open Bonsai.Let_syntax in
       fun (local_ graph) ->
         let carousel = Carousel.component graph in
         let%arr carousel in
         Node.div
           [ view carousel
           ; Node.textf
               "Slide %d of %d (%b %b)"
               (Carousel.selected carousel + 1)
               (Carousel.count carousel)
               (Carousel.can_scroll_prev carousel)
               (Carousel.can_scroll_next carousel)
           ])
  in
  (* Nothing measured outside a browser: no slides to move to. *)
  Handle.show handle;
  [%expect {|
    <div>
      <div role="region" aria-roledescription="carousel" data-slot="carousel" @on_keydown>
        <div data-slot="carousel-content"
             @on_click_global
             loon-after-render-carousel=<opaque>
             @on_pointerdown
             @on_pointermove
             @on_pointerup
             style={
               touch-action: pan-y pinch-zoom;
             }>
          <div>
            <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 1 </div>
            <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 2 </div>
            <div role="group" aria-roledescription="slide" data-slot="carousel-item"> 3 </div>
          </div>
        </div>
        <button type="button"
                data-slot="carousel-previous"
                data-variant="outline"
                data-size="icon"
                disabled="">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true">
            <path d="m12 19-7-7 7-7"> </path>
            <path d="M19 12H5"> </path>
          </svg>
          <span> Previous slide </span>
        </button>
        <button type="button"
                data-slot="carousel-next"
                data-variant="outline"
                data-size="icon"
                disabled="">
          <svg xmlns="http://www.w3.org/2000/svg"
               width="24"
               height="24"
               viewBox="0 0 24 24"
               fill="none"
               stroke="currentColor"
               stroke-width="2"
               stroke-linecap="round"
               stroke-linejoin="round"
               aria-hidden="true">
            <path d="M5 12h14"> </path>
            <path d="m12 5 7 7-7 7"> </path>
          </svg>
          <span> Next slide </span>
        </button>
      </div>
      Slide 1 of 0 (false false)
    </div>
    |}]
;;
