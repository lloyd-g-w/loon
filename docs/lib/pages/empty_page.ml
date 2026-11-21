open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "empty"

(*$ Demo *)
let demo =
  Empty.root
    [ Empty.header
        [ Empty.media ~variant:Icon [ Icon.view Folder_code ]
        ; Empty.title [ Node.text "No Projects Yet" ]
        ; Empty.description
            [ Node.text
                "You haven't created any projects yet. Get started by creating your \
                 first project."
            ]
        ]
    ; Empty.content
        [ Node.div
            ~attrs:[ Attr.class_ "flex gap-2" ]
            [ Button.view [ Node.text "Create Project" ]
            ; Button.view ~variant:Outline [ Node.text "Import Project" ]
            ]
        ]
    ; Button.link
        ~variant:Link
        ~class_:"text-muted-foreground"
        ~size:Sm
        ~href:"#/empty"
        [ Node.text "Learn More "; Icon.view Arrow_up_right ]
    ]
(*$*)

(*$ Outline
   A dashed border: [~class_:"border border-dashed"]. *)
let outline =
  Empty.root
    ~class_:"border border-dashed"
    [ Empty.header
        [ Empty.media ~variant:Icon [ Icon.view Cloud ]
        ; Empty.title [ Node.text "Cloud Storage Empty" ]
        ; Empty.description
            [ Node.text "Upload files to your cloud storage to access them anywhere." ]
        ]
    ; Empty.content [ Button.view ~variant:Outline ~size:Sm [ Node.text "Upload Files" ] ]
    ]
(*$*)

(*$ Background *)
let background =
  Empty.root
    ~class_:"h-full bg-gradient-to-b from-muted/50 from-30% to-background"
    [ Empty.header
        [ Empty.media ~variant:Icon [ Icon.view Bell ]
        ; Empty.title [ Node.text "No Notifications" ]
        ; Empty.description
            [ Node.text "You're all caught up. New notifications will appear here." ]
        ]
    ; Empty.content
        [ Button.view
            ~variant:Outline
            ~size:Sm
            [ Icon.view Refresh_ccw; Node.text "Refresh" ]
        ]
    ]
(*$*)

(*$ Avatar *)
let avatar (local_ graph) =
  let avatar =
    Avatar.component
      ~class_:"size-12"
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ~src:"https://github.com/shadcn.png" ~class_:"grayscale" ()
         ; Avatar.fallback avatar [ Node.text "LR" ]
         ]))
      graph
  in
  let%arr avatar in
  Empty.root
    [ Empty.header
        [ Empty.media ~variant:Default [ avatar ]
        ; Empty.title [ Node.text "User Offline" ]
        ; Empty.description
            [ Node.text
                "This user is currently offline. You can leave a message to notify them \
                 or try again later."
            ]
        ]
    ; Empty.content [ Button.view ~size:Sm [ Node.text "Leave Message" ] ]
    ]
(*$*)

(*$ Avatar group *)
let avatar_group (local_ graph) =
  let avatar ~src ~alt initials =
    Avatar.component
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ~src ~alt (); Avatar.fallback avatar [ Node.text initials ] ]))
      graph
  in
  let%arr avatars =
    Bonsai.all
      [ avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" "CN"
      ; avatar ~src:"https://github.com/maxleiter.png" ~alt:"@maxleiter" "LR"
      ; avatar ~src:"https://github.com/evilrabbit.png" ~alt:"@evilrabbit" "ER"
      ]
  in
  Empty.root
    [ Empty.header
        [ Empty.media
            [ Node.div
                ~attrs:
                  [ Attr.class_
                      "flex -space-x-2 *:data-[slot=avatar]:size-12 \
                       *:data-[slot=avatar]:ring-2 *:data-[slot=avatar]:ring-background \
                       *:data-[slot=avatar]:grayscale"
                  ]
                avatars
            ]
        ; Empty.title [ Node.text "No Team Members" ]
        ; Empty.description
            [ Node.text "Invite your team to collaborate on this project." ]
        ]
    ; Empty.content
        [ Button.view ~size:Sm [ Icon.view Plus; Node.text "Invite Members" ] ]
    ]
(*$*)

(*$ Icon *)
let icon =
  let empty icon title description =
    Empty.root
      [ Empty.header
          [ Empty.media ~variant:Icon [ Icon.view icon ]
          ; Empty.title [ Node.text title ]
          ; Empty.description [ Node.text description ]
          ]
      ]
  in
  Node.div
    ~attrs:[ Attr.class_ "grid gap-8 md:grid-cols-2" ]
    [ empty Inbox "No messages" "Your inbox is empty. New messages will appear here."
    ; empty Star "No favorites" "Items you mark as favorites will appear here."
    ; empty Heart "No likes yet" "Content you like will be saved here for easy access."
    ; empty Bookmark "No bookmarks" "Save interesting content by bookmarking it."
    ]
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Empty"
    ~group:Feedback
    ~description:"Use the Empty component to display an empty state."
    ~usage:
      {|Empty.root
  [ Empty.header
      [ Empty.media ~variant:Icon [ Icon.view Folder_code ]
      ; Empty.title [ Node.text "No data" ]
      ; Empty.description [ Node.text "No data found" ]
      ]
  ; Empty.content [ Button.view [ Node.text "Add data" ] ]
  ]|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ ( "variant"
            , "Empty.Media_variant.t"
            , "[Empty.media]: [Default] (as it is) or [Icon] (an icon in a muted square)." )
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.static ~page "Demo" demo
    ; Doc.static ~page "Outline" outline
    ; Doc.static ~page "Background" background
    ; Doc.example ~page "Avatar" avatar
    ; Doc.example ~page "Avatar group" avatar_group
    ; Doc.static ~page "Icon" icon
    ]
;;
