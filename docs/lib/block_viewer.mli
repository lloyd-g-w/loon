(** The blocks' gallery, as shadcn's [BlockViewer]: each block in a frame of
    its own (an iframe of this site showing the block alone, so that its
    sidebar, viewport units and overlays work as on a page of its own),
    resizable, with its source; and the page showing a block alone. *)

open! Core
open Bonsai_web

(** The block a hash shows alone: ["#/blocks/sidebar-07"]. *)
val block_of_hash : string -> Loon_blocks.Block.t option

val hash : Loon_blocks.Block.t -> string

(** The blocks' pages: the navigation between their categories, then a
    viewer for each block. [page] is the docs page's slug, for anchors. *)
val gallery
  :  page:string
  -> Loon_blocks.Block.t list
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t

(** A block alone, filling the window; it follows the docs' theme as
    other windows change it. *)
val full_page
  :  Loon_blocks.Block.t
  -> local_ Bonsai.graph
  -> Vdom.Node.t Bonsai.t
