open! Core
module Block = Loon_blocks.Block

let page =
  Doc.page
    ~order:1
    ~slug:"blocks-sidebar"
    ~title:"Sidebar"
    ~group:Blocks
    ~description:
      "Sidebars: collapsible, floating, inset, nested, in popovers and dialogs."
    ~view:(Block_viewer.gallery ~page:"blocks-sidebar" (Block.in_category Sidebar))
    []
;;
