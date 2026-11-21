open! Core
module Handle = Bonsai_web_test.Handle

let () = Loon.Calendar.For_testing.set_today (Some (Date.of_string "2025-06-10"))

let%expect_test "dbg" =
  let handle = Block_summary.handle "calendar-22" in
  Drive.click handle "#date";
  Render.html ~classes:false ~selector:"td[data-day='2025-06-18']" (Handle.last_result handle);
  Drive.click handle "td[data-day='2025-06-18'] button";
  Render.html ~classes:false ~selector:"td[data-day='2025-06-18']" (Handle.last_result handle);
  Render.html ~classes:false ~selector:"#date" (Handle.last_result handle);
  [%expect {| |}]
;;
