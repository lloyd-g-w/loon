open! Core
module Block = Loon_blocks.Block

let page =
  Doc.page
    ~order:0
    ~slug:"blocks"
    ~title:"Featured"
    ~group:Blocks
    ~description:
      "Clean, modern building blocks: shadcn/ui's blocks, ported to loon. Copy \
       them into your apps, or open one to see it full-page."
    ~view:(Block_viewer.gallery ~page:"blocks" Block.featured)
    []
;;
