open! Core
open Loon
module Node = Virtual_dom.Vdom.Node
module Handle = Bonsai_web_test.Handle

let items acc =
  [ Accordion.item
      acc
      ~value:"a"
      [ Accordion.trigger [ Node.text "A" ]
      ; Accordion.content [ Node.text "Alpha" ]
      ]
  ; Accordion.item
      acc
      ~value:"b"
      [ Accordion.trigger [ Node.text "B" ]
      ; Accordion.content [ Node.text "Beta" ]
      ]
  ; Accordion.item
      acc
      ~disabled:true
      ~value:"c"
      [ Accordion.trigger [ Node.text "C" ]
      ; Accordion.content [ Node.text "Gamma" ]
      ]
  ]
;;

let%expect_test "shadcn's classes" =
  Render.html
    (Accordion.view
       ~type_:Single
       ~value:[ "a" ]
       ~on_change:(fun _ -> Bonsai_web.Effect.Ignore)
       (fun acc ->
          [ Accordion.item
              acc
              ~value:"a"
              [ Accordion.trigger [ Node.text "A" ]
              ; Accordion.content [ Node.text "Alpha" ]
              ]
          ]));
  [%expect
    {|
    <div data-orientation="vertical" data-slot="accordion">
      <div @key=a
           data-state="open"
           data-orientation="vertical"
           data-slot="accordion-item"
           class="border-b last:border-b-0">
        <h3 data-orientation="vertical" data-state="open" class="flex">
          <button type="button"
                  aria-controls="accordion-content-a"
                  aria-expanded="true"
                  data-state="open"
                  aria-disabled="true"
                  data-orientation="vertical"
                  id="accordion-trigger-a"
                  data-slot="accordion-trigger"
                  class="[&[data-state=open]>svg]:rotate-180 disabled:opacity-50 disabled:pointer-events-none flex flex-1 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 font-medium gap-4 hover:underline items-start justify-between outline-none py-4 rounded-md text-left text-sm transition-all"
                  @on_click
                  @on_keydown>
            A
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
                 class="duration-200 lucide lucide-chevron-down pointer-events-none shrink-0 size-4 text-muted-foreground transition-transform translate-y-0.5">
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="open"
             id="accordion-content-a"
             role="region"
             aria-labelledby="accordion-trigger-a"
             data-orientation="vertical"
             data-slot="accordion-content"
             class="data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down overflow-hidden text-sm"
             loon-collapsible-presence=true
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div class="pb-4 pt-0"> Alpha </div>
        </div>
      </div>
    </div>
    |}]
;;

let show_states handle = Handle.show handle

let%expect_test "single: one open at a time; not collapsible keeps it open" =
  let handle =
    Render.handle
      ~classes:false
      (Accordion.component
         ~type_:Single
         ~default_value:[ "a" ]
         (Bonsai_web.Bonsai.return items))
  in
  show_states handle;
  [%expect
    {|
    <div data-orientation="vertical" data-slot="accordion">
      <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="open">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-a"
                  aria-expanded="true"
                  data-state="open"
                  aria-disabled="true"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-a"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            A
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="open"
             id="bonsai_path_replaced_in_test-content-a"
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=true
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Alpha </div>
        </div>
      </div>
      <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-b"
                  aria-expanded="false"
                  data-state="closed"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-b"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            B
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-b"
             hidden=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-b"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Beta </div>
        </div>
      </div>
      <div @key=c
           data-state="closed"
           data-disabled=""
           data-orientation="vertical"
           data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed" data-disabled="">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-c"
                  aria-expanded="false"
                  data-state="closed"
                  data-disabled=""
                  disabled=""
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-c"
                  data-slot="accordion-trigger"
                  @on_keydown>
            C
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-c"
             hidden=""
             data-disabled=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-c"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Gamma </div>
        </div>
      </div>
    </div>
    |}];
  Drive.click handle "[id$=trigger-b]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-orientation="vertical" data-slot="accordion">
    -|  <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=a data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="open">
    +|    <h3 data-orientation="vertical" data-state="closed">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-a"
    -|              aria-expanded="true"
    +|              aria-expanded="false"
    -|              data-state="open"
    -|              aria-disabled="true"
    +|              data-state="closed"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-a"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              A
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="open"
    +|    <div data-state="closed"
               id="bonsai_path_replaced_in_test-content-a"
    +|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=true
    +|         loon-collapsible-presence=false
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Alpha </div>
          </div>
        </div>
    -|  <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=b data-state="open" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="closed">
    +|    <h3 data-orientation="vertical" data-state="open">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-b"
    -|              aria-expanded="false"
    +|              aria-expanded="true"
    -|              data-state="closed"
    +|              data-state="open"
    +|              aria-disabled="true"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-b"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              B
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="closed"
    +|    <div data-state="open"
               id="bonsai_path_replaced_in_test-content-b"
    -|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-b"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=false
    +|         loon-collapsible-presence=true
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Beta </div>
          </div>
        </div>
        <div @key=c
             data-state="closed"
             data-disabled=""
             data-orientation="vertical"
             data-slot="accordion-item">
          <h3 data-orientation="vertical" data-state="closed" data-disabled="">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-c"
                    aria-expanded="false"
    |}];
  (* Pressing the open item does nothing unless collapsible. *)
  Drive.click handle "[id$=trigger-b]";
  Handle.show_diff handle;
  [%expect {| |}]
;;

let%expect_test "single, collapsible: the open item closes" =
  let handle =
    Render.handle
      ~classes:false
      (Accordion.component
         ~type_:Single
         ~collapsible:true
         ~default_value:[ "a" ]
         (Bonsai_web.Bonsai.return items))
  in
  Handle.show handle;
  Drive.click handle "[id$=trigger-a]";
  Handle.show_diff handle;
  [%expect
    {|
    <div data-orientation="vertical" data-slot="accordion">
      <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="open">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-a"
                  aria-expanded="true"
                  data-state="open"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-a"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            A
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="open"
             id="bonsai_path_replaced_in_test-content-a"
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=true
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Alpha </div>
        </div>
      </div>
      <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-b"
                  aria-expanded="false"
                  data-state="closed"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-b"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            B
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-b"
             hidden=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-b"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Beta </div>
        </div>
      </div>
      <div @key=c
           data-state="closed"
           data-disabled=""
           data-orientation="vertical"
           data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed" data-disabled="">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-c"
                  aria-expanded="false"
                  data-state="closed"
                  data-disabled=""
                  disabled=""
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-c"
                  data-slot="accordion-trigger"
                  @on_keydown>
            C
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-c"
             hidden=""
             data-disabled=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-c"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Gamma </div>
        </div>
      </div>
    </div>

      <div data-orientation="vertical" data-slot="accordion">
    -|  <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=a data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="open">
    +|    <h3 data-orientation="vertical" data-state="closed">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-a"
    -|              aria-expanded="true"
    +|              aria-expanded="false"
    -|              data-state="open"
    +|              data-state="closed"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-a"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              A
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="open"
    +|    <div data-state="closed"
               id="bonsai_path_replaced_in_test-content-a"
    +|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=true
    +|         loon-collapsible-presence=false
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Alpha </div>
          </div>
        </div>
        <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
          <h3 data-orientation="vertical" data-state="closed">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-b"
                    aria-expanded="false"
                    data-state="closed"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-b"
                    data-slot="accordion-trigger"
    |}]
;;

let%expect_test "multiple: several open" =
  let handle =
    Render.handle
      ~classes:false
      (Accordion.component ~type_:Multiple (Bonsai_web.Bonsai.return items))
  in
  Handle.show handle;
  Drive.click handle "[id$=trigger-a]";
  Drive.click handle "[id$=trigger-b]";
  Handle.show_diff handle;
  [%expect
    {|
    <div data-orientation="vertical" data-slot="accordion">
      <div @key=a data-state="closed" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-a"
                  aria-expanded="false"
                  data-state="closed"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-a"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            A
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-a"
             hidden=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Alpha </div>
        </div>
      </div>
      <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-b"
                  aria-expanded="false"
                  data-state="closed"
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-b"
                  data-slot="accordion-trigger"
                  @on_click
                  @on_keydown>
            B
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-b"
             hidden=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-b"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Beta </div>
        </div>
      </div>
      <div @key=c
           data-state="closed"
           data-disabled=""
           data-orientation="vertical"
           data-slot="accordion-item">
        <h3 data-orientation="vertical" data-state="closed" data-disabled="">
          <button type="button"
                  aria-controls="bonsai_path_replaced_in_test-content-c"
                  aria-expanded="false"
                  data-state="closed"
                  data-disabled=""
                  disabled=""
                  data-orientation="vertical"
                  id="bonsai_path_replaced_in_test-trigger-c"
                  data-slot="accordion-trigger"
                  @on_keydown>
            C
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
              <path d="m6 9 6 6 6-6"> </path>
            </svg>
          </button>
        </h3>
        <div data-state="closed"
             id="bonsai_path_replaced_in_test-content-c"
             hidden=""
             data-disabled=""
             role="region"
             aria-labelledby="bonsai_path_replaced_in_test-trigger-c"
             data-orientation="vertical"
             data-slot="accordion-content"
             loon-collapsible-presence=false
             style={
               --radix-accordion-content-height: var(--radix-collapsible-content-height);
               --radix-accordion-content-width: var(--radix-collapsible-content-width);
             }>
          <div> Gamma </div>
        </div>
      </div>
    </div>

      <div data-orientation="vertical" data-slot="accordion">
    -|  <div @key=a data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="closed">
    +|    <h3 data-orientation="vertical" data-state="open">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-a"
    -|              aria-expanded="false"
    +|              aria-expanded="true"
    -|              data-state="closed"
    +|              data-state="open"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-a"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              A
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="closed"
    +|    <div data-state="open"
               id="bonsai_path_replaced_in_test-content-a"
    -|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=false
    +|         loon-collapsible-presence=true
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Alpha </div>
          </div>
        </div>
    -|  <div @key=b data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=b data-state="open" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="closed">
    +|    <h3 data-orientation="vertical" data-state="open">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-b"
    -|              aria-expanded="false"
    +|              aria-expanded="true"
    -|              data-state="closed"
    +|              data-state="open"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-b"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              B
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="closed"
    +|    <div data-state="open"
               id="bonsai_path_replaced_in_test-content-b"
    -|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-b"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=false
    +|         loon-collapsible-presence=true
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Beta </div>
          </div>
        </div>
        <div @key=c
             data-state="closed"
             data-disabled=""
             data-orientation="vertical"
             data-slot="accordion-item">
          <h3 data-orientation="vertical" data-state="closed" data-disabled="">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-c"
                    aria-expanded="false"
    |}];
  Drive.click handle "[id$=trigger-a]";
  Handle.show_diff handle;
  [%expect
    {|
      <div data-orientation="vertical" data-slot="accordion">
    -|  <div @key=a data-state="open" data-orientation="vertical" data-slot="accordion-item">
    +|  <div @key=a data-state="closed" data-orientation="vertical" data-slot="accordion-item">
    -|    <h3 data-orientation="vertical" data-state="open">
    +|    <h3 data-orientation="vertical" data-state="closed">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-a"
    -|              aria-expanded="true"
    +|              aria-expanded="false"
    -|              data-state="open"
    +|              data-state="closed"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-a"
                    data-slot="accordion-trigger"
                    @on_click
                    @on_keydown>
              A
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
                <path d="m6 9 6 6 6-6"> </path>
              </svg>
            </button>
          </h3>
    -|    <div data-state="open"
    +|    <div data-state="closed"
               id="bonsai_path_replaced_in_test-content-a"
    +|         hidden=""
               role="region"
               aria-labelledby="bonsai_path_replaced_in_test-trigger-a"
               data-orientation="vertical"
               data-slot="accordion-content"
    -|         loon-collapsible-presence=true
    +|         loon-collapsible-presence=false
               style={
                 --radix-accordion-content-height: var(--radix-collapsible-content-height);
                 --radix-accordion-content-width: var(--radix-collapsible-content-width);
               }>
            <div> Alpha </div>
          </div>
        </div>
        <div @key=b data-state="open" data-orientation="vertical" data-slot="accordion-item">
          <h3 data-orientation="vertical" data-state="open">
            <button type="button"
                    aria-controls="bonsai_path_replaced_in_test-content-b"
                    aria-expanded="true"
                    data-state="open"
                    data-orientation="vertical"
                    id="bonsai_path_replaced_in_test-trigger-b"
                    data-slot="accordion-trigger"
    |}]
;;

let%expect_test "toggled" =
  let show type_ collapsible open_ value =
    print_s
      [%sexp (Accordion.toggled type_ ~collapsible ~open_ value : string list)]
  in
  show Single false [] "a";
  show Single false [ "a" ] "a";
  show Single true [ "a" ] "a";
  show Single false [ "a" ] "b";
  show Multiple false [ "a" ] "b";
  show Multiple false [ "a"; "b" ] "a";
  [%expect
    {|
    (a)
    (a)
    ()
    (b)
    (a b)
    (b)
    |}]
;;
