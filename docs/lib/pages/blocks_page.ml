open! Core

(* A placeholder: the blocks are coming. *)
let page =
  Doc.page
    ~slug:"blocks"
    ~title:"Building Blocks for the Web"
    ~section:Blocks
    ~description:"Clean, modern building blocks. Copy and paste into your apps. Works with all OxCaml Bonsai apps. Open Source. Free forever."
    ~body:[ Doc.coming_soon () ]
    []
;;
