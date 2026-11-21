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
    | Vertical -> "flex-col [&>*]:w-full [&>.sr-only]:w-auto"
    | Horizontal ->
      "flex-row items-center [&>[data-slot=field-label]]:flex-auto \
       has-[>[data-slot=field-content]]:items-start \
       has-[>[data-slot=field-content]]:[&>[role=checkbox],[role=radio]]:mt-px"
    | Responsive ->
      "flex-col @md/field-group:flex-row @md/field-group:items-center [&>*]:w-full \
       @md/field-group:[&>*]:w-auto [&>.sr-only]:w-auto \
       @md/field-group:[&>[data-slot=field-label]]:flex-auto \
       @md/field-group:has-[>[data-slot=field-content]]:items-start \
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
           [ "flex flex-col gap-6"
           ; "has-[>[data-slot=checkbox-group]]:gap-3 \
              has-[>[data-slot=radio-group]]:gap-3"
           ]
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
           [ "mb-3 font-medium"
           ; "data-[variant=legend]:text-base"
           ; "data-[variant=label]:text-sm"
           ]
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
           [ "group/field-group @container/field-group flex w-full flex-col gap-7 \
              data-[slot=checkbox-group]:gap-3 [&>[data-slot=field-group]]:gap-4"
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
           [ "group/field flex w-full gap-3 data-[invalid=true]:text-destructive"
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
           [ "group/field-content flex flex-1 flex-col gap-1.5 leading-snug" ]
       ]
       @ attrs)
    children
;;

let label ?(attrs = []) ?class_ ?for_ children =
  Label.view
    ~attrs:(Attr.suppress_merge_warnings (data "slot" "field-label") :: attrs)
    ~class_:
      (Cn.cn
         ([ "group/field-label peer/field-label flex w-fit gap-2 leading-snug \
             group-data-[disabled=true]/field:opacity-50"
          ; "has-[>[data-slot=field]]:w-full has-[>[data-slot=field]]:flex-col \
             has-[>[data-slot=field]]:rounded-md has-[>[data-slot=field]]:border \
             [&>*]:data-[slot=field]:p-4"
          ; "has-data-[state=checked]:border-primary has-data-[state=checked]:bg-primary/5 \
             dark:has-data-[state=checked]:bg-primary/10"
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
           [ "flex w-fit items-center gap-2 text-sm leading-snug font-medium \
              group-data-[disabled=true]/field:opacity-50"
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
           [ "text-sm leading-normal font-normal text-muted-foreground \
              group-has-[[data-orientation=horizontal]]/field:text-balance"
           ; "last:mt-0 nth-last-2:-mt-1 [[data-variant=legend]+&]:-mt-1.5"
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
       ; Cn.with_class
           ?class_
           [ "relative -my-2 h-5 text-sm group-data-[variant=outline]/field-group:-mb-2" ]
       ]
       @ attrs)
    (Node.div
       ~attrs:
         [ data "slot" "separator"
         ; Attr.role "none"
         ; data "orientation" "horizontal"
         ; Cn.attr
             [ "shrink-0 bg-border data-[orientation=horizontal]:h-px \
                data-[orientation=horizontal]:w-full data-[orientation=vertical]:h-full \
                data-[orientation=vertical]:w-px"
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
                  "relative mx-auto block w-fit bg-background px-2 text-muted-foreground"
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
         ; Cn.with_class ?class_ [ "text-sm font-normal text-destructive" ]
         ]
         @ attrs)
      content
;;
