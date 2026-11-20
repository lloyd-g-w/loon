(** A section that shows or hides its content when its trigger is pressed. *)

open! Import

(** Controlled. The trigger is a button holding [trigger] and a chevron;
    the content is kept in the page when closed (hidden, so its state
    survives) and its height animates. [name] scopes the ids. *)
val view
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> name:string
  -> open_:bool
  -> on_change:(bool -> unit Effect.t)
  -> trigger:Node.t list
  -> Node.t list
  -> Node.t

(** Keeps whether it is open; closed at first unless [default_open]. *)
val component
  :  ?attrs:Attr.t list
  -> ?disabled:bool
  -> ?default_open:bool
  -> trigger:Node.t list Bonsai.t
  -> Node.t list Bonsai.t
  -> local_ Bonsai.graph
  -> Node.t Bonsai.t
