open! Import

let label text =
  Node.div
    ~attrs:[ Attr.class_ "loon-menu-label"; Attr.role "presentation" ]
    [ Node.text text ]
;;

let separator =
  Node.div
    ~attrs:[ Attr.class_ "loon-menu-separator"; Attr.role "separator" ]
    []
;;

let shortcut text =
  Node.span ~attrs:[ Attr.class_ "loon-menu-shortcut" ] [ Node.text text ]
;;
