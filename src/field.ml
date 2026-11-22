open! Import

module Orientation = struct
  type t =
    | Vertical
    | Horizontal
    | Responsive
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Vertical -> "vertical"
    | Horizontal -> "horizontal"
    | Responsive -> "responsive"
  ;;

  let classes = function
    | Vertical -> "cn-field-orientation-vertical flex-col *:w-full [&>.sr-only]:w-auto"
    | Horizontal ->
      "cn-field-orientation-horizontal flex-row items-center \
       has-[>[data-slot=field-content]]:items-start *:data-[slot=field-label]:flex-auto \
       has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px"
    | Responsive ->
      "cn-field-orientation-responsive flex-col *:w-full @md/field-group:flex-row \
       @md/field-group:items-center @md/field-group:*:w-auto \
       @md/field-group:has-[>[data-slot=field-content]]:items-start \
       @md/field-group:*:data-[slot=field-label]:flex-auto [&>.sr-only]:w-auto \
       @md/field-group:has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px"
  ;;
end

module Legend_variant = struct
  type t =
    | Legend
    | Label
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Legend -> "legend"
    | Label -> "label"
  ;;
end

let set ?(attrs = []) ?class_ children =
  Node.fieldset
    ~attrs:
      ([ data "slot" "field-set"
       ; Cn.with_class
           ?class_
           [ "cn-field-set flex flex-col" ]
       ]
       @ attrs)
    children
;;

let legend ?(attrs = []) ?class_ ?(variant = Legend_variant.Legend) children =
  Node.legend
    ~attrs:
      ([ data "slot" "field-legend"
       ; data "variant" (Legend_variant.name variant)
       ; Cn.with_class
           ?class_
           [ "cn-field-legend" ]
       ]
       @ attrs)
    children
;;

let group ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "field-group"
       ; Cn.with_class
           ?class_
           [ "cn-field-group group/field-group @container/field-group flex w-full \
              flex-col"
           ]
       ]
       @ attrs)
    children
;;

let root
  ?(attrs = [])
  ?class_
  ?(orientation = Orientation.Vertical)
  ?(invalid = false)
  ?(disabled = false)
  children
  =
  Node.div
    ~attrs:
      ([ Attr.role "group"
       ; data "slot" "field"
       ; data "orientation" (Orientation.name orientation)
       ; Cn.with_class
           ?class_
           [ "cn-field group/field flex w-full"
           ; Orientation.classes orientation
           ]
       ]
       @ (if invalid then [ data "invalid" "true" ] else [])
       @ (if disabled then [ data "disabled" "true" ] else [])
       @ attrs)
    children
;;

let content ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "field-content"
       ; Cn.with_class
           ?class_
           [ "cn-field-content group/field-content flex flex-1 flex-col leading-snug" ]
       ]
       @ attrs)
    children
;;

let label ?(attrs = []) ?class_ ?for_ children =
  Label.view
    ~attrs:(Attr.suppress_merge_warnings (data "slot" "field-label") :: attrs)
    ~class_:
      (Cn.cn
         ([ "cn-field-label group/field-label peer/field-label flex w-fit"
          ; "has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col"
          ]
          @ Option.to_list class_))
    ?for_
    children
;;

let title ?(attrs = []) ?class_ children =
  Node.div
    ~attrs:
      ([ data "slot" "field-label"
       ; Cn.with_class
           ?class_
           [ "cn-field-title flex w-fit items-center"
           ]
       ]
       @ attrs)
    children
;;

let description ?(attrs = []) ?class_ children =
  Node.p
    ~attrs:
      ([ data "slot" "field-description"
       ; Cn.with_class
           ?class_
           [ "cn-field-description leading-normal font-normal \
              group-has-data-horizontal/field:text-balance"
           ; "last:mt-0 nth-last-2:-mt-1"
           ; "[&>a]:underline [&>a]:underline-offset-4 [&>a:hover]:text-primary"
           ]
       ]
       @ attrs)
    children
;;

(* shadcn's Separator, decorative and horizontal. *)
let separator ?(attrs = []) ?class_ children =
  let has_content = not (List.is_empty children) in
  Node.div
    ~attrs:
      ([ data "slot" "field-separator"
       ; data "content" (Bool.to_string has_content)
       ; Cn.with_class ?class_ [ "cn-field-separator relative" ]
       ]
       @ attrs)
    (Node.div
       ~attrs:
         [ data "slot" "separator"
         ; Attr.role "none"
         ; data "orientation" "horizontal"
         ; Cn.attr
             [ "shrink-0 bg-border data-horizontal:h-px data-horizontal:w-full \
                data-vertical:w-px data-vertical:self-stretch"
             ; "absolute inset-0 top-1/2"
             ]
         ]
       []
     ::
     (if has_content
      then
        [ Node.span
            ~attrs:
              [ Attr.class_
                  "cn-field-separator-content relative mx-auto block w-fit bg-background"
              ; data "slot" "field-separator-content"
              ]
            children
        ]
      else []))
;;

let error ?(attrs = []) ?class_ ?(errors = []) children =
  let content =
    match children with
    | _ :: _ -> Some children
    | [] ->
      (match List.stable_dedup errors ~compare:String.compare with
       | [] -> None
       | [ e ] -> Some [ Node.text e ]
       | errors ->
         let errors = List.filter errors ~f:(fun e -> not (String.is_empty e)) in
         Some
           [ Node.ul
               ~attrs:[ Attr.class_ "ml-4 flex list-disc flex-col gap-1" ]
               (List.map errors ~f:(fun e -> Node.li [ Node.text e ]))
           ])
  in
  match content with
  | None -> Node.none
  | Some content ->
    Node.div
      ~attrs:
        ([ Attr.role "alert"
         ; data "slot" "field-error"
         ; Cn.with_class ?class_ [ "cn-field-error font-normal" ]
         ]
         @ attrs)
      content
;;
