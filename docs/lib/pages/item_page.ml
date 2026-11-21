open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "item"

(*$ Demo *)
let demo =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-6" ]
    [ Item.view
        ~variant:Outline
        [ Item.content
            [ Item.title [ Node.text "Basic Item" ]
            ; Item.description [ Node.text "A simple item with title and description." ]
            ]
        ; Item.actions [ Button.view ~variant:Outline ~size:Sm [ Node.text "Action" ] ]
        ]
    ; Item.link
        ~variant:Outline
        ~size:Sm
        ~href:"#/item"
        [ Item.media [ Icon.view ~class_:"size-5" Badge_check ]
        ; Item.content [ Item.title [ Node.text "Your profile has been verified." ] ]
        ; Item.actions [ Icon.view ~class_:"size-4" Chevron_right ]
        ]
    ]
(*$*)

(*$ Variant *)
let variant =
  let item variant title description =
    Item.view
      ~variant
      [ Item.content
          [ Item.title [ Node.text title ]; Item.description [ Node.text description ] ]
      ; Item.actions [ Button.view ~variant:Outline ~size:Sm [ Node.text "Open" ] ]
      ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-col gap-6" ]
    [ item Default "Default Variant" "Standard styling with subtle background and borders."
    ; item
        Outline
        "Outline Variant"
        "Outlined style with clear borders and transparent background."
    ; item
        Muted
        "Muted Variant"
        "Subdued appearance with muted colors for secondary content."
    ]
(*$*)

(*$ Size *)
let size =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-6" ]
    [ Item.view
        ~variant:Outline
        [ Item.content
            [ Item.title [ Node.text "Basic Item" ]
            ; Item.description [ Node.text "A simple item with title and description." ]
            ]
        ; Item.actions [ Button.view ~variant:Outline ~size:Sm [ Node.text "Action" ] ]
        ]
    ; Item.link
        ~variant:Outline
        ~size:Sm
        ~href:"#/item"
        [ Item.media [ Icon.view ~class_:"size-5" Badge_check ]
        ; Item.content [ Item.title [ Node.text "Your profile has been verified." ] ]
        ; Item.actions [ Icon.view ~class_:"size-4" Chevron_right ]
        ]
    ]
(*$*)

(*$ Icon *)
let icon =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-lg flex-col gap-6" ]
    [ Item.view
        ~variant:Outline
        [ Item.media ~variant:Icon [ Icon.view Shield_exclamation_point ]
        ; Item.content
            [ Item.title [ Node.text "Security Alert" ]
            ; Item.description [ Node.text "New login detected from unknown device." ]
            ]
        ; Item.actions [ Button.view ~size:Sm ~variant:Outline [ Node.text "Review" ] ]
        ]
    ]
(*$*)

(*$ Avatar *)
let avatar (local_ graph) =
  let avatar ?class_ ?alt ?image_class ~src initials =
    Avatar.component
      ?class_
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ?alt ?class_:image_class ~src ()
         ; Avatar.fallback avatar [ Node.text initials ]
         ]))
      graph
  in
  let evilrabbit = avatar ~class_:"size-10" ~src:"https://github.com/evilrabbit.png" "ER" in
  let%arr evilrabbit
  and team =
    Bonsai.all
      [ avatar
          ~class_:"hidden sm:flex"
          ~src:"https://github.com/shadcn.png"
          ~alt:"@shadcn"
          "CN"
      ; avatar
          ~class_:"hidden sm:flex"
          ~src:"https://github.com/maxleiter.png"
          ~alt:"@maxleiter"
          "LR"
      ; avatar ~src:"https://github.com/evilrabbit.png" ~alt:"@evilrabbit" "ER"
      ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-lg flex-col gap-6" ]
    [ Item.view
        ~variant:Outline
        [ Item.media [ evilrabbit ]
        ; Item.content
            [ Item.title [ Node.text "Evil Rabbit" ]
            ; Item.description [ Node.text "Last seen 5 months ago" ]
            ]
        ; Item.actions
            [ Button.view
                ~size:Icon_sm
                ~variant:Outline
                ~class_:"rounded-full"
                ~attrs:[ Attr.create "aria-label" "Invite" ]
                [ Icon.view Plus ]
            ]
        ]
    ; Item.view
        ~variant:Outline
        [ Item.media
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "flex -space-x-2 *:data-[slot=avatar]:ring-2 \
                       *:data-[slot=avatar]:ring-background *:data-[slot=avatar]:grayscale"
                  ]
                team
            ]
        ; Item.content
            [ Item.title [ Node.text "No Team Members" ]
            ; Item.description
                [ Node.text "Invite your team to collaborate on this project." ]
            ]
        ; Item.actions [ Button.view ~size:Sm ~variant:Outline [ Node.text "Invite" ] ]
        ]
    ]
(*$*)

(*$ Image *)
let image =
  let music =
    [ "Midnight City Lights", "Neon Dreams", "Electric Nights", "3:45"
    ; "Coffee Shop Conversations", "The Morning Brew", "Urban Stories", "4:05"
    ; "Digital Rain", "Cyber Symphony", "Binary Beats", "3:30"
    ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-6" ]
    [ Item.group
        ~class_:"gap-4"
        (List.map music ~f:(fun (title, artist, album, duration) ->
           Item.link
             ~variant:Outline
             ~attrs:[ Attr.role "listitem" ]
             ~href:"#/item"
             [ Item.media
                 ~variant:Image
                 [ Node.img
                     ~attrs:
                       [ Attr.src ("https://avatar.vercel.sh/" ^ title)
                       ; Attr.alt title
                       ; Attr.create "width" "32"
                       ; Attr.create "height" "32"
                       ; Attr.class_ "object-cover grayscale"
                       ]
                     ()
                 ]
             ; Item.content
                 [ Item.title
                     ~class_:"line-clamp-1"
                     [ Node.text (title ^ " - ")
                     ; Node.span
                         ~attrs:[ Attr.class_ "text-muted-foreground" ]
                         [ Node.text album ]
                     ]
                 ; Item.description [ Node.text artist ]
                 ]
             ; Item.content
                 ~class_:"flex-none text-center"
                 [ Item.description [ Node.text duration ] ]
             ]))
    ]
(*$*)

(*$ Group *)
let group (local_ graph) =
  let people =
    [ "shadcn", "https://github.com/shadcn.png", "shadcn@vercel.com"
    ; "maxleiter", "https://github.com/maxleiter.png", "maxleiter@vercel.com"
    ; "evilrabbit", "https://github.com/evilrabbit.png", "evilrabbit@vercel.com"
    ]
  in
  let items =
    List.map people ~f:(fun (username, src, email) ->
      let avatar =
        Avatar.component
          (Bonsai.return (fun avatar ->
             [ Avatar.image avatar ~src ~class_:"grayscale" ()
             ; Avatar.fallback avatar [ Node.text (String.prefix username 1) ]
             ]))
          graph
      in
      let%arr avatar in
      Item.view
        [ Item.media [ avatar ]
        ; Item.content
            ~class_:"gap-1"
            [ Item.title [ Node.text username ]; Item.description [ Node.text email ] ]
        ; Item.actions
            [ Button.view
                ~variant:Ghost
                ~size:Icon
                ~class_:"rounded-full"
                [ Icon.view Plus ]
            ]
        ])
  in
  let%arr items = Bonsai.all items in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-6" ]
    [ Item.group (List.intersperse items ~sep:(Item.separator ())) ]
(*$*)

(*$ Header *)
let header =
  let models =
    [ ( "v0-1.5-sm"
      , "Everyday tasks and UI generation."
      , "https://images.unsplash.com/photo-1650804068570-7fb2e3dbf888?q=80&w=640&auto=format&fit=crop"
      )
    ; ( "v0-1.5-lg"
      , "Advanced thinking or reasoning."
      , "https://images.unsplash.com/photo-1610280777472-54133d004c8c?q=80&w=640&auto=format&fit=crop"
      )
    ; ( "v0-2.0-mini"
      , "Open Source model for everyone."
      , "https://images.unsplash.com/photo-1602146057681-08560aee8cde?q=80&w=640&auto=format&fit=crop"
      )
    ]
  in
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-xl flex-col gap-6" ]
    [ Item.group
        ~class_:"grid grid-cols-3 gap-4"
        (List.map models ~f:(fun (name, description, image) ->
           Item.view
             ~variant:Outline
             [ Item.header
                 [ Node.img
                     ~attrs:
                       [ Attr.src image
                       ; Attr.alt name
                       ; Attr.create "width" "128"
                       ; Attr.create "height" "128"
                       ; Attr.class_ "aspect-square w-full rounded-sm object-cover"
                       ]
                     ()
                 ]
             ; Item.content
                 [ Item.title [ Node.text name ]
                 ; Item.description [ Node.text description ]
                 ]
             ]))
    ]
(*$*)

(*$ Link
   [Item.link] is shadcn's [<Item asChild><a>]. *)
let link =
  Node.div
    ~attrs:[ Attr.class_ "flex w-full max-w-md flex-col gap-4" ]
    [ Item.link
        ~href:"#/item"
        [ Item.content
            [ Item.title [ Node.text "Visit our documentation" ]
            ; Item.description
                [ Node.text "Learn how to get started with our components." ]
            ]
        ; Item.actions [ Icon.view ~class_:"size-4" Chevron_right ]
        ]
    ; Item.link
        ~variant:Outline
        ~href:"#/item"
        ~attrs:[ Attr.create "target" "_blank"; Attr.create "rel" "noopener noreferrer" ]
        [ Item.content
            [ Item.title [ Node.text "External resource" ]
            ; Item.description [ Node.text "Opens in a new tab with security attributes." ]
            ]
        ; Item.actions [ Icon.view ~class_:"size-4" External_link ]
        ]
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Item"
    ~group:Display
    ~description:"A versatile component that you can use to display any content."
    ~usage:
      {|Item.view ~variant:Outline
  [ Item.content
      [ Item.title [ Node.text "Basic Item" ]
      ; Item.description [ Node.text "A simple item with title and description." ]
      ]
  ; Item.actions [ Button.view ~variant:Outline ~size:Sm [ Node.text "Action" ] ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "variant"
            , "Item.Variant.t"
            , "[Default] (transparent), [Outline] (a border) or [Muted] (a muted \
               background)." )
          ; "size", "Item.Size.t", "[Default] or [Sm] (less padding)."
          ; ( "variant"
            , "Item.Media_variant.t"
            , "[Item.media]: [Default], [Icon] (in a bordered square) or [Image] (cropped \
               to a square)." )
          ; "href", "string", "[Item.link]: an item that is a link."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Variant" variant
    ; Doc.static ~page "Size" size
    ; Doc.static ~page "Icon" icon
    ; Doc.example ~page "Avatar" avatar
    ; Doc.static ~page "Image" image
    ; Doc.example ~page "Group" group
    ; Doc.static ~page "Header" header
    ; Doc.static ~page "Link" link
    ]
;;
