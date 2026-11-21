open! Core
module Block = Loon_blocks.Block

let page =
  Doc.page
    ~order:2
    ~slug:"blocks-login"
    ~title:"Login"
    ~section:Blocks
    ~description:
      "Login pages and forms."
    ~view:(Block_viewer.gallery ~page:"blocks-login" (Block.in_category Login))
    []
;;
