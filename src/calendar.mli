(** A month of days to pick a date from. Arrow keys move by a day or a
    week, Home and End to the week's ends, Page Up and Page Down by a month
    (with Shift, a year); Enter or Space picks (WAI-ARIA date grid). *)

open! Import

(** The date [key] moves the focus to from [focused] ([None]: not a key
    that moves it). *)
val moved
  :  week_start:Day_of_week.t
  -> shift:bool
  -> key:Js_of_ocaml.Dom_html.Keyboard_code.t
  -> Date.t
  -> Date.t option

(** The six weeks shown for [month]'s month (from the [week_start] on or
    before its first day). *)
val weeks : week_start:Day_of_week.t -> Date.t -> Date.t list list

(** Controlled. The month shown is [focused]'s; [focused] is the day the
    keyboard is on. Days before [min], after [max] or [is_disabled] can't
    be picked. [week_start] defaults to Monday. [name] scopes the ids. *)
val view
  :  ?attrs:Attr.t list
  -> ?week_start:Day_of_week.t
  -> ?min:Date.t
  -> ?max:Date.t
  -> ?is_disabled:(Date.t -> bool)
  -> ?today:Date.t
  -> name:string
  -> focused:Date.t
  -> selected:Date.t option
  -> on_focus:(Date.t -> unit Effect.t)
  -> on_select:(Date.t -> unit Effect.t)
  -> unit
  -> Node.t

type t =
  { view : Node.t
  ; selected : Date.t option
  }

(** Keeps the date picked ([default], none at first) and the month shown.
    [today] defaults to the browser's local date. *)
val component
  :  ?attrs:Attr.t list
  -> ?week_start:Day_of_week.t
  -> ?min:Date.t
  -> ?max:Date.t
  -> ?is_disabled:(Date.t -> bool)
  -> ?today:Date.t
  -> ?default:Date.t
  -> local_ Bonsai.graph
  -> t Bonsai.t
