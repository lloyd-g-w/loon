(** little-date's [formatDateRange] (en-US), which shadcn's calendar-30
    and calendar-31 blocks use: a short, readable range ("Jun 4 - 10",
    "Jun 12, 9am - 10am, 2025"). *)

open! Core

(** A day and a time of day, in minutes since midnight (a date alone is
    its midnight). *)
type moment = Date.t * int

(** [today] (by default, today) leaves out the year when [from] is in its
    year, and the day when it is that day. [include_time] (default [true]),
    [separator] (default ["-"]). *)
val format_date_range
  :  ?today:Date.t
  -> ?include_time:bool
  -> ?separator:string
  -> moment
  -> moment
  -> string
