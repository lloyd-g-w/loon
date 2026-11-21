open! Core
open Bonsai_web
open Loon
open! Bonsai.Let_syntax
module Node = Vdom.Node
module Attr = Vdom.Attr

let page = "avatar"

(*$ Demo *)
let demo (local_ graph) =
  let avatar ?class_ ~src ~alt initials =
    Avatar.component
      ?class_
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ~src ~alt ()
         ; Avatar.fallback avatar [ Node.text initials ]
         ]))
      graph
  in
  let shadcn = avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" "CN" in
  let evilrabbit =
    avatar
      ~class_:"rounded-lg"
      ~src:"https://github.com/evilrabbit.png"
      ~alt:"@evilrabbit"
      "ER"
  in
  let group =
    [ avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" "CN"
    ; avatar ~src:"https://github.com/maxleiter.png" ~alt:"@maxleiter" "LR"
    ; avatar ~src:"https://github.com/evilrabbit.png" ~alt:"@evilrabbit" "ER"
    ]
    |> Bonsai.all
  in
  let%arr shadcn and evilrabbit and group in
  Node.div
    ~attrs:[ Attr.class_ "flex flex-row flex-wrap items-center gap-12" ]
    [ shadcn
    ; evilrabbit
    ; Node.div
        ~attrs:
          [ Attr.class_
              "flex -space-x-2 *:data-[slot=avatar]:ring-2 \
               *:data-[slot=avatar]:ring-background *:data-[slot=avatar]:grayscale"
          ]
        group
    ]
(*$*)

(*$ Sizes
   [~size] is [Default], [Sm] or [Lg]; [Avatar.badge] marks a status. *)
let sizes (local_ graph) =
  let avatar size =
    Avatar.component
      ~size
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" ()
         ; Avatar.fallback avatar [ Node.text "CN" ]
         ; Avatar.badge ~class_:"bg-green-600 dark:bg-green-800" []
         ]))
      graph
  in
  let%arr avatars = Bonsai.all (List.map [ Avatar.Size.Sm; Default; Lg ] ~f:avatar) in
  Node.div ~attrs:[ Attr.class_ "flex flex-row flex-wrap items-center gap-6" ] avatars
(*$*)

(*$ Group
   [Avatar.group] overlaps avatars; [Avatar.group_count] counts the rest. *)
let group (local_ graph) =
  let avatar ~src ~alt initials =
    Avatar.component
      (Bonsai.return (fun avatar ->
         [ Avatar.image avatar ~src ~alt ~class_:"grayscale" ()
         ; Avatar.fallback avatar [ Node.text initials ]
         ]))
      graph
  in
  let%arr avatars =
    Bonsai.all
      [ avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" "CN"
      ; avatar ~src:"https://github.com/maxleiter.png" ~alt:"@maxleiter" "LR"
      ; avatar ~src:"https://github.com/evilrabbit.png" ~alt:"@evilrabbit" "ER"
      ]
  in
  Avatar.group (avatars @ [ Avatar.group_count [ Node.text "+3" ] ])
(*$*)

(*$ Fallback
   Without an image (or while it loads, or if it fails), the fallback
   shows. *)
let fallback (local_ graph) =
  Avatar.component
    (Bonsai.return (fun avatar -> [ Avatar.fallback avatar [ Node.text "CN" ] ]))
    graph
(*$*)

let page =
  Doc.page
    ~slug:page
    ~title:"Avatar"
    ~description:"An image element with a fallback for representing the user."
    ~usage:
      {|Avatar.component
  (return (fun avatar ->
     [ Avatar.image avatar ~src:"https://github.com/shadcn.png" ~alt:"@shadcn" ()
     ; Avatar.fallback avatar [ Node.text "CN" ]
     ]))
  graph|}
    ~body:
      [ Doc.h2 "Arguments"
      ; Doc.props
          [ "size", "Avatar.Size.t", "[Default] (32px), [Sm] (24px) or [Lg] (40px)."
          ; ( "status"
            , "Avatar.Status.t"
            , "[Avatar.view]: the image's ([Loading], [Loaded] or [Error]), reported by \
               [~on_status_change]. [Avatar.component] keeps it." )
          ; "src, alt", "string", "[Avatar.image]: the picture and its text."
          ; "class_", "string", "More Tailwind classes, merged last."
          ; "attrs", "Vdom.Attr.t list", "Extra attributes."
          ]
      ]
    [ Doc.example ~page "Demo" demo
    ; Doc.example ~page "Sizes" sizes
    ; Doc.example ~page "Group" group
    ; Doc.example ~page "Fallback" fallback
    ]
;;
