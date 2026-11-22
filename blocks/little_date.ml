open! Core
open Loon

type moment = Date.t * int

let end_of_day = (23 * 60) + 59
let long_month d = Calendar.format "LLLL" d
let short_month d = Calendar.format "LLL" d
let month_day d = sprintf "%s %d" (short_month d) (Date.day d)

(* toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit" }),
   shortened: "9am", "11:30am", "2pm". *)
let format_time minutes =
  let h = minutes / 60
  and m = minutes % 60 in
  let h12 = if h % 12 = 0 then 12 else h % 12 in
  let text = sprintf "%d:%02d%s" h12 m (if h < 12 then "am" else "pm") in
  String.substr_replace_all text ~pattern:":00" ~with_:""
;;

let quarter d = ((Month.to_int (Date.month d) - 1) / 3) + 1

let format_date_range
      ?(today = Calendar.today ())
      ?(include_time = true)
      ?(separator = "-")
      ((from, from_time) : moment)
      ((to_, to_time) : moment)
  =
  let same_year = Date.year from = Date.year to_ in
  let same_month =
    same_year && Month.equal (Date.month from) (Date.month to_)
  in
  let same_day = Date.equal from to_ in
  let this_year = Date.year from = Date.year today in
  let this_day = Date.equal from today in
  let year_suffix = if this_year then "" else sprintf ", %d" (Date.year to_) in
  let start_time_suffix =
    if include_time && from_time <> 0 then ", " ^ format_time from_time else ""
  in
  let end_time_suffix =
    if include_time && to_time <> end_of_day
    then ", " ^ format_time to_time
    else ""
  in
  let starts_day = from_time = 0
  and ends_day = to_time = end_of_day in
  let first_of_month d = Date.day d = 1 in
  let last_of_month d = Date.day (Date.add_days d 1) = 1 in
  let first_of_quarter d =
    first_of_month d && (Month.to_int (Date.month d) - 1) % 3 = 0
  in
  let last_of_quarter d =
    last_of_month d && Month.to_int (Date.month d) % 3 = 0
  in
  let yy d = sprintf "'%02d" (Date.year d % 100) in
  if
    starts_day
    && ends_day
    && first_of_month from
    && Month.equal (Date.month from) Jan
    && last_of_month to_
    && Month.equal (Date.month to_) Dec
  then Int.to_string (Date.year from)
  else if
    starts_day
    && ends_day
    && first_of_quarter from
    && last_of_quarter to_
    && quarter from = quarter to_
  then sprintf "Q%d %d" (quarter from) (Date.year from)
  else if starts_day && ends_day && first_of_month from && last_of_month to_
  then
    if same_month
    then sprintf "%s %d" (long_month from) (Date.year from)
    else
      sprintf
        "%s %s %s %d"
        (short_month from)
        separator
        (short_month to_)
        (Date.year to_)
  else if not same_year
  then
    sprintf
      "%s %s%s %s %s %s%s"
      (month_day from)
      (yy from)
      start_time_suffix
      separator
      (month_day to_)
      (yy to_)
      end_time_suffix
  else if
    (not same_month)
    || ((not same_day)
        && not
             (String.is_empty start_time_suffix
              && String.is_empty end_time_suffix))
  then
    sprintf
      "%s%s %s %s%s%s"
      (month_day from)
      start_time_suffix
      separator
      (month_day to_)
      end_time_suffix
      year_suffix
  else if not same_day
  then
    sprintf "%s %s %d%s" (month_day from) separator (Date.day to_) year_suffix
  else if
    not (String.is_empty start_time_suffix && String.is_empty end_time_suffix)
  then
    if this_day
    then
      sprintf "%s %s %s" (format_time from_time) separator (format_time to_time)
    else
      sprintf
        "%s%s %s %s%s"
        (month_day from)
        start_time_suffix
        separator
        (format_time to_time)
        year_suffix
  else
    sprintf "%s, %s%s" (Calendar.format "EEE" from) (month_day from) year_suffix
;;
