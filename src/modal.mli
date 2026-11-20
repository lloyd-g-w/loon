(** What dialogs and sheets share: a scrim over the page, a panel that
    takes focus and keeps it (Tab cycles inside), Esc to close, and focus
    returned to the trigger afterwards. *)

open! Import

(** Ids of the parts of the modal [id]. *)
val title_id : string -> string

val description_id : string -> string

(** Closes with [on_close] then focuses the trigger of [id] (see
    {!Floating.trigger_id}), if there is one. *)
val close : id:string -> on_close:unit Effect.t -> unit Effect.t

(** Nothing when closed. [role] is ["dialog"] or ["alertdialog"];
    [dismiss_on_scrim] (default [true]) closes it on a click outside the
    panel. [has_description] links the panel to [description_id id]. *)
val view
  :  ?panel_attrs:Attr.t list
  -> ?dismiss_on_scrim:bool
  -> ?has_description:bool
  -> role:string
  -> class_:string
  -> id:string
  -> open_:bool
  -> on_close:unit Effect.t
  -> Node.t list
  -> Node.t

(** The trigger made by [trigger] (given its attributes, or none), then the
    modal. *)
val with_trigger
  :  ?trigger:(Attr.t list -> Node.t)
  -> id:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> Node.t
  -> Node.t
