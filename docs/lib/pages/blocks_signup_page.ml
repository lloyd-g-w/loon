open! Core
module Block = Loon_blocks.Block

let page =
  Doc.page
    ~order:3
    ~slug:"blocks-signup"
    ~title:"Signup"
    ~section:Blocks
    ~description:
      "Signup pages and forms."
    ~view:(Block_viewer.gallery ~page:"blocks-signup" (Block.in_category Signup))
    []
;;
