(** A labelled form control with an optional description and error message.
    The control is built from the attributes [view] gives it (its id,
    [aria-describedby], [aria-invalid], [aria-required]), so that screen
    readers announce the label, the description and the error with it:

    {[
      Field.view ~id:"email" ~label:"Email" ?error (fun attrs ->
        Input.view ~attrs ~type_:Email ~value ~on_input:set ())
    ]} *)

open! Import

module Orientation : sig
  type t =
    | Vertical (** the label above the control *)
    | Horizontal (** the control, then the label: for checkboxes and switches *)
  [@@deriving enumerate, sexp_of, compare, equal]
end

val view
  :  ?attrs:Attr.t list
  -> ?orientation:Orientation.t
  -> ?description:string
  -> ?error:string
  -> ?required:bool
  -> id:string
  -> label:string
  -> (Attr.t list -> Node.t)
  -> Node.t

(** A [<fieldset>] with a legend, grouping fields. *)
val set : ?attrs:Attr.t list -> ?description:string -> legend:string -> Node.t list -> Node.t
