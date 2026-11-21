open! Core
module Block = Loon_blocks.Block

let page =
  Doc.page
    ~order:4
    ~slug:"blocks-calendar"
    ~title:"Calendar"
    ~group:Blocks
    ~description:
      "Calendars and date pickers."
    ~view:(Block_viewer.gallery ~page:"blocks-calendar" (Block.in_category Calendar))
    []
;;
