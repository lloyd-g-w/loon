open! Core
module Handle = Bonsai_web_test.Handle

(* The blocks start from today (new Date() in shadcn's): fix it. *)
let () = Loon.Calendar.For_testing.set_today (Some (Date.of_string "2025-06-10"))
let smoke name = Block_summary.show (Block_summary.handle name)

let%expect_test "calendar-01" =
  smoke "calendar-01";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-02" =
  smoke "calendar-02";
  [%expect {|
    slots:
      calendar
      button x70
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 1 2
    |}]
;;

let%expect_test "calendar-03" =
  smoke "calendar-03";
  [%expect {|
    slots:
      calendar
      button x70
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 1 2
    |}]
;;

let%expect_test "calendar-04" =
  smoke "calendar-04";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-05" =
  smoke "calendar-05";
  [%expect {|
    slots:
      calendar
      button x70
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 1 2
    |}]
;;

let%expect_test "calendar-06" =
  smoke "calendar-06";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 A minimum of 5 days is
      required
    |}]
;;

let%expect_test "calendar-07" =
  smoke "calendar-07";
  [%expect {|
    slots:
      calendar
      button x70
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 1 2 Your stay must be between 2 and 20 nights
    |}]
;;

let%expect_test "calendar-08" =
  smoke "calendar-08";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-09" =
  smoke "calendar-09";
  [%expect {|
    slots:
      calendar
      button x70
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 1 2
    |}]
;;

let%expect_test "calendar-10" =
  smoke "calendar-10";
  [%expect {|
    slots:
      card
      card-header
      card-title
      card-description
      card-action
      button x36
      card-content
      calendar
    text:
      Appointment Find a date Today June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8
      9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-11" =
  smoke "calendar-11";
  [%expect {|
    slots:
      calendar
      button x68
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 July 2025 Su Mo Tu We Th Fr Sa
      29 30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
      27 28 29 30 31 We are open in June and July only.
    |}]
;;

let%expect_test "calendar-12" =
  smoke "calendar-12";
  [%expect {|
    slots:
      card
      card-header
      card-title
      card-description
      card-action
      select-trigger
      select-value
      card-content
      calendar
      button x70
    text:
      Reserva una cita Selecciona las fechas para tu cita Español septiembre 2025
      lu ma mi ju vi sá do 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
      22 23 24 25 26 27 28 29 30 1 2 3 4 5 octubre 2025 lu ma mi ju vi sá do 29
      30 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
      28 29 30 31 1 2
    |}]
;;

let%expect_test "calendar-13" =
  smoke "calendar-13";
  [%expect {|
    slots:
      calendar
      button x35
      label
      select-trigger
      select-value
    text:
      Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec Jun 1925 1926 1927 1928 1929
      1930 1931 1932 1933 1934 1935 1936 1937 1938 1939 1940 1941 1942 1943 1944
      1945 1946 1947 1948 1949 1950 1951 1952 1953 1954 1955 1956 1957 1958 1959
      1960 1961 1962 1963 1964 1965 1966 1967 1968 1969 1970 1971 1972 1973 1974
      1975 1976 1977 1978 1979 1980 1981 1982 1983 1984 1985 1986 1987 1988 1989
      1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004
      2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019
      2020 2021 2022 2023 2024 2025 2025 June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5
      6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 1 2 3
      4 5 Dropdown Month and Year
    |}]
;;

let%expect_test "calendar-14" =
  smoke "calendar-14";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-15" =
  smoke "calendar-15";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 23 1 2 3 4 5 6 7 24 8 9 10 11 12 13 14 25 15
      16 17 18 19 20 21 26 22 23 24 25 26 27 28 27 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-16" =
  smoke "calendar-16";
  [%expect {|
    slots:
      card
      card-content
      calendar
      button x35
      card-footer
      label x2
      input x2
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 Start Time End Time
    |}]
;;

let%expect_test "calendar-17" =
  smoke "calendar-17";
  [%expect {|
    slots:
      card
      card-content
      calendar
      button x35
      card-footer
      label x2
      input x2
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 Start Time - End Time
    |}]
;;

let%expect_test "calendar-18" =
  smoke "calendar-18";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-19" =
  smoke "calendar-19";
  [%expect {|
    slots:
      card
      card-content
      calendar
      button x40
      card-footer
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 Today Tomorrow In 3 days In a
      week In 2 weeks
    |}]
;;

let%expect_test "calendar-20" =
  smoke "calendar-20";
  [%expect {|
    slots:
      card
      card-content
      calendar
      button x68
      card-footer
    text:
      June 2025 Sun Mon Tue Wed Thu Fri Sat 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
      17 18 19 20 21 22 23 24 25 26 27 28 29 30 09:00 09:15 09:30 09:45 10:00
      10:15 10:30 10:45 11:00 11:15 11:30 11:45 12:00 12:15 12:30 12:45 13:00
      13:15 13:30 13:45 14:00 14:15 14:30 14:45 15:00 15:15 15:30 15:45 16:00
      16:15 16:30 16:45 17:00 17:15 17:30 17:45 18:00 Your meeting is booked for
      Thursday, June 12 at 10:00 . Continue
    |}]
;;

let%expect_test "calendar-21" =
  smoke "calendar-21";
  [%expect {|
    slots:
      calendar
      button x35
    text:
      January February March April May June July August September October November
      December June 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936
      1937 1938 1939 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951
      1952 1953 1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966
      1967 1968 1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981
      1982 1983 1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996
      1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011
      2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2025
      June 2025 Su Mo Tu We Th Fr Sa 1 $220 2 $100 3 $100 4 $100 5 $100 6 $100 7
      $220 8 $220 9 $100 10 $100 11 $100 12 $100 13 $100 14 $220 15 $220 16 $100
      17 $100 18 $100 19 $100 20 $100 21 $220 22 $220 23 $100 24 $100 25 $100 26
      $100 27 $100 28 $220 29 $220 30 $100 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-22" =
  smoke "calendar-22";
  [%expect {|
    slots:
      label
      popover-trigger
    text:
      Date of birth Select date
    |}]
;;

let%expect_test "calendar-23" =
  smoke "calendar-23";
  [%expect {|
    slots:
      label
      popover-trigger
    text:
      Select your stay Select date
    |}]
;;

let%expect_test "calendar-24" =
  smoke "calendar-24";
  [%expect {|
    slots:
      label x2
      popover-trigger
      input
    text:
      Date Select date Time
    |}]
;;

let%expect_test "calendar-25" =
  smoke "calendar-25";
  [%expect {|
    slots:
      label x3
      popover-trigger
      input x2
    text:
      Date Select date From To
    |}]
;;

let%expect_test "calendar-26" =
  smoke "calendar-26";
  [%expect {|
    slots:
      label x4
      popover-trigger x2
      input x2
    text:
      Check-in Jun 01, 2025 From Check-out Jun 03, 2025 To
    |}]
;;

let%expect_test "calendar-27" =
  smoke "calendar-27";
  [%expect {|
    slots:
      card
      card-header
      card-title
      card-description
      card-action
      popover-trigger
      card-content
      chart
      card-footer
    text:
      Web Analytics Showing total visitors for this month. 6/5/2025 - 6/20/2025
      [data-chart=chart-bonsai_path_x_y] { --color-visitors: var(--color-primary);
      } .dark [data-chart=chart-bonsai_path_x_y] { --color-visitors:
      var(--color-primary); } 6 8 10 12 14 16 18 20 You had 8,792 visitors for the
      month of June.
    |}]
;;

let%expect_test "calendar-28" =
  smoke "calendar-28";
  [%expect {|
    slots:
      label
      input
      popover-trigger
    text:
      Subscription Date Select date
    |}]
;;

let%expect_test "calendar-29" =
  smoke "calendar-29";
  [%expect {|
    slots:
      label
      input
      popover-trigger
    text:
      Schedule Date Select date Your post will be published on June 12, 2025 .
    |}]
;;

let%expect_test "calendar-30" =
  smoke "calendar-30";
  [%expect {|
    slots:
      label
      popover-trigger
    text:
      Select your stay Jun 4 - 10
    |}]
;;

let%expect_test "calendar-31" =
  smoke "calendar-31";
  [%expect {|
    slots:
      card
      card-content
      calendar
      button x36
      card-footer
    text:
      June 2025 Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18
      19 20 21 22 23 24 25 26 27 28 29 30 1 2 3 4 5 June 12, 2025 Add Event Team
      Sync Meeting Jun 12, 9am - 10am Design Review Jun 12, 11:30am - 12:30pm
      Client Presentation Jun 12, 2pm - 3pm
    |}]
;;

let%expect_test "calendar-32" =
  smoke "calendar-32";
  [%expect {|
    slots:
      label
      drawer-trigger
    text:
      Date of birth Select date This example works best on mobile.
    |}]
;;

let%expect_test "calendar-04: picking a new range" =
  let handle = Block_summary.handle "calendar-04" in
  let click day =
    Handle.click_on
      handle
      ~get_vdom:Fn.id
      ~selector:(sprintf "td[data-day='%s'] button" day)
  in
  let selected () =
    Handle.recompute_view handle;
    let module H = Virtual_dom_test_helpers.Node_helpers in
    H.select
      (H.unsafe_convert_exn (Handle.last_result handle))
      ~selector:"td[aria-selected]"
    |> List.filter_map ~f:(function
      | H.Element e -> List.Assoc.find e.attributes ~equal:String.equal "data-day"
      | Text _ | Widget -> None)
    |> String.concat ~sep:" "
    |> print_endline
  in
  selected ();
  click "2025-06-03";
  selected ();
  click "2025-06-05";
  selected ();
  [%expect {|
    2025-06-09 2025-06-10 2025-06-11 2025-06-12 2025-06-13 2025-06-14 2025-06-15 2025-06-16 2025-06-17 2025-06-18 2025-06-19 2025-06-20 2025-06-21 2025-06-22 2025-06-23 2025-06-24 2025-06-25 2025-06-26
    2025-06-03 2025-06-04 2025-06-05 2025-06-06 2025-06-07 2025-06-08 2025-06-09 2025-06-10 2025-06-11 2025-06-12 2025-06-13 2025-06-14 2025-06-15 2025-06-16 2025-06-17 2025-06-18 2025-06-19 2025-06-20 2025-06-21 2025-06-22 2025-06-23 2025-06-24 2025-06-25 2025-06-26
    2025-06-03 2025-06-04 2025-06-05
    |}]
;;

let%expect_test "calendar-22: a date from the popover" =
  let handle = Block_summary.handle "calendar-22" in
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"#date";
  Handle.recompute_view handle;
  Handle.click_on handle ~get_vdom:Fn.id ~selector:"td[data-day='2025-06-18'] button";
  Block_summary.show handle;
  [%expect {|
    slots:
      label
      popover-trigger
      popover-content
      calendar
      button x35
    text:
      Date of birth Select date Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
      Jun 1925 1926 1927 1928 1929 1930 1931 1932 1933 1934 1935 1936 1937 1938
      1939 1940 1941 1942 1943 1944 1945 1946 1947 1948 1949 1950 1951 1952 1953
      1954 1955 1956 1957 1958 1959 1960 1961 1962 1963 1964 1965 1966 1967 1968
      1969 1970 1971 1972 1973 1974 1975 1976 1977 1978 1979 1980 1981 1982 1983
      1984 1985 1986 1987 1988 1989 1990 1991 1992 1993 1994 1995 1996 1997 1998
      1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013
      2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 2025 June 2025
      Su Mo Tu We Th Fr Sa 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21
      22 23 24 25 26 27 28 29 30 1 2 3 4 5
    |}]
;;

let%expect_test "calendar-29: natural language" =
  let today = Date.of_string "2025-06-10" in
  List.iter
    [ "today"
    ; "Tomorrow"
    ; "in 2 days"
    ; "In a week"
    ; "next week"
    ; "next month"
    ; "3 days ago"
    ; "friday"
    ; "next monday"
    ; "last friday"
    ; "June 20, 2025"
    ; "nonsense"
    ]
    ~f:(fun text ->
      printf
        "%s: %s\n"
        text
        (Option.value_map
           (Loon_blocks.Calendar_29.parse_date ~today text)
           ~default:"-"
           ~f:Date.to_string));
  [%expect {|
    today: 2025-06-10
    Tomorrow: 2025-06-11
    in 2 days: 2025-06-12
    In a week: 2025-06-17
    next week: 2025-06-17
    next month: 2025-07-10
    3 days ago: 2025-06-07
    friday: 2025-06-13
    next monday: 2025-06-16
    last friday: 2025-06-06
    June 20, 2025: 2025-06-20
    nonsense: -
    |}]
;;

let%expect_test "little-date ranges" =
  let today = Date.of_string "2025-06-10" in
  let d = Date.of_string in
  List.iter
    [ (d "2025-06-04", 0), (d "2025-06-10", 0)
    ; (d "2025-06-12", 540), (d "2025-06-12", 600)
    ; (d "2025-06-12", 690), (d "2025-06-12", 750)
    ; (d "2025-06-10", 840), (d "2025-06-10", 900)
    ; (d "2025-06-28", 0), (d "2025-07-02", 0)
    ; (d "2024-12-28", 0), (d "2025-01-02", 0)
    ; (d "2025-01-01", 0), (d "2025-12-31", 1439)
    ; (d "2025-04-01", 0), (d "2025-06-30", 1439)
    ; (d "2025-06-01", 0), (d "2025-06-30", 1439)
    ; (d "2025-06-01", 0), (d "2025-07-31", 1439)
    ; (d "2026-03-05", 0), (d "2026-03-05", 1439)
    ]
    ~f:(fun (from, to_) ->
      print_endline (Loon_blocks.Little_date.format_date_range ~today from to_));
  print_endline
    (Loon_blocks.Little_date.format_date_range
       ~today
       ~include_time:false
       (d "2025-06-04", 0)
       (d "2025-06-10", 0));
  [%expect {|
    Jun 4 - Jun 10, 12am
    Jun 12, 9am - 10am
    Jun 12, 11:30am - 12:30pm
    2pm - 3pm
    Jun 28 - Jul 2, 12am
    Dec 28 '24 - Jan 2 '25, 12am
    2025
    Q2 2025
    June 2025
    Jun - Jul 2025
    Thu, Mar 5, 2026
    Jun 4 - 10
    |}]
;;
