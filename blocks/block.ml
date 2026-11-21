open! Core
open Bonsai_web

module Category = struct
  type t =
    | Sidebar
    | Dashboard
    | Authentication
    | Login
    | Signup
    | Calendar
  [@@deriving enumerate, sexp_of, compare, equal]

  let name = function
    | Sidebar -> "Sidebar"
    | Dashboard -> "Dashboard"
    | Authentication -> "Authentication"
    | Login -> "Login"
    | Signup -> "Signup"
    | Calendar -> "Calendar"
  ;;

  let slug t = String.lowercase (name t)

  let hidden = function
    | Dashboard | Authentication -> true
    | Sidebar | Login | Signup | Calendar -> false
  ;;
end

type t =
  { name : string
  ; description : string
  ; categories : Category.t list
  ; iframe_height : string
  ; container : string option
  ; view : local_ Bonsai.graph -> Vdom.Node.t Bonsai.t
  }

(* The containers are whole literals, so that Tailwind sees their classes. *)
let all =
  [ { name = "dashboard-01"
    ; description = "A dashboard with sidebar, charts and data table."
    ; categories = [ Dashboard ]
    ; iframe_height = "1000px"
    ; container = None
    ; view = Dashboard_01.view
    }
  ; { name = "sidebar-01"
    ; description = "A simple sidebar with navigation grouped by section."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_01.view
    }
  ; { name = "sidebar-02"
    ; description = "A sidebar with collapsible sections."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_02.view
    }
  ; { name = "sidebar-03"
    ; description = "A sidebar with submenus."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_03.view
    }
  ; { name = "sidebar-04"
    ; description = "A floating sidebar with submenus."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_04.view
    }
  ; { name = "sidebar-05"
    ; description = "A sidebar with collapsible submenus."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_05.view
    }
  ; { name = "sidebar-06"
    ; description = "A sidebar with submenus as dropdowns."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_06.view
    }
  ; { name = "sidebar-07"
    ; description = "A sidebar that collapses to icons."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_07.view
    }
  ; { name = "sidebar-08"
    ; description = "An inset sidebar with secondary navigation."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_08.view
    }
  ; { name = "sidebar-09"
    ; description = "Collapsible nested sidebars."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_09.view
    }
  ; { name = "sidebar-10"
    ; description = "A sidebar in a popover."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_10.view
    }
  ; { name = "sidebar-11"
    ; description = "A sidebar with a collapsible file tree."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_11.view
    }
  ; { name = "sidebar-12"
    ; description = "A sidebar with a calendar."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_12.view
    }
  ; { name = "sidebar-13"
    ; description = "A sidebar in a dialog."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_13.view
    }
  ; { name = "sidebar-14"
    ; description = "A sidebar on the right."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_14.view
    }
  ; { name = "sidebar-15"
    ; description = "A left and right sidebar."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_15.view
    }
  ; { name = "sidebar-16"
    ; description = "A sidebar with a sticky site header."
    ; categories = [ Sidebar; Dashboard ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Sidebar_16.view
    }
  ; { name = "login-01"
    ; description = "A simple login form."
    ; categories = [ Authentication; Login ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Login_01.view
    }
  ; { name = "login-02"
    ; description = "A two column login page with a cover image."
    ; categories = [ Authentication; Login ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Login_02.view
    }
  ; { name = "login-03"
    ; description = "A login page with a muted background color."
    ; categories = [ Authentication; Login ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Login_03.view
    }
  ; { name = "login-04"
    ; description = "A login page with form and image."
    ; categories = [ Authentication; Login ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Login_04.view
    }
  ; { name = "login-05"
    ; description = "A simple email-only login page."
    ; categories = [ Authentication; Login ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Login_05.view
    }
  ; { name = "signup-01"
    ; description = "A simple signup form."
    ; categories = [ Authentication; Signup ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Signup_01.view
    }
  ; { name = "signup-02"
    ; description = "A two column signup page with a cover image."
    ; categories = [ Authentication; Signup ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Signup_02.view
    }
  ; { name = "signup-03"
    ; description = "A signup page with a muted background color."
    ; categories = [ Authentication; Signup ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Signup_03.view
    }
  ; { name = "signup-04"
    ; description = "A signup page with form and image."
    ; categories = [ Authentication; Signup ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Signup_04.view
    }
  ; { name = "signup-05"
    ; description = "A simple signup form with social providers."
    ; categories = [ Authentication; Signup ]
    ; iframe_height = "930px"
    ; container = None
    ; view = Signup_05.view
    }
  ; { name = "calendar-01"
    ; description = "A simple calendar."
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-4 py-12 items-start md:py-20 \
           justify-center min-w-0"
    ; view = Calendar_01.view
    }
  ; { name = "calendar-02"
    ; description = "Multiple months with single selection."
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-4 py-12 items-start md:py-20 \
           justify-center min-w-0"
    ; view = Calendar_02.view
    }
  ; { name = "calendar-03"
    ; description = "Multiple months with multiple selection."
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-4 py-12 items-start md:py-20 \
           justify-center min-w-0"
    ; view = Calendar_03.view
    }
  ; { name = "calendar-04"
    ; description = "Single month with range selection"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-4 py-12 items-start md:py-20 \
           justify-center min-w-0 xl:pt-28"
    ; view = Calendar_04.view
    }
  ; { name = "calendar-05"
    ; description = "Multiple months with range selection"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_05.view
    }
  ; { name = "calendar-06"
    ; description = "Range selection with minimum days"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_06.view
    }
  ; { name = "calendar-07"
    ; description = "Range selection with minimum and maximum days"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_07.view
    }
  ; { name = "calendar-08"
    ; description = "Calendar with disabled days"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_08.view
    }
  ; { name = "calendar-09"
    ; description = "Calendar with disabled weekends"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_09.view
    }
  ; { name = "calendar-10"
    ; description = "Today button"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_10.view
    }
  ; { name = "calendar-11"
    ; description = "Start and end of month"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_11.view
    }
  ; { name = "calendar-12"
    ; description = "Localized calendar"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_12.view
    }
  ; { name = "calendar-13"
    ; description = "With Month and Year Dropdown"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_13.view
    }
  ; { name = "calendar-14"
    ; description = "With Booked/Unavailable Days"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_14.view
    }
  ; { name = "calendar-15"
    ; description = "With Week Numbers"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_15.view
    }
  ; { name = "calendar-16"
    ; description = "With time picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start \
           justify-center min-w-0"
    ; view = Calendar_16.view
    }
  ; { name = "calendar-17"
    ; description = "With time picker inline"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_17.view
    }
  ; { name = "calendar-18"
    ; description = "Variable size"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_18.view
    }
  ; { name = "calendar-19"
    ; description = "With presets"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start \
           justify-center min-w-0"
    ; view = Calendar_19.view
    }
  ; { name = "calendar-20"
    ; description = "With time presets"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start \
           justify-center min-w-0"
    ; view = Calendar_20.view
    }
  ; { name = "calendar-21"
    ; description = "Custom days and formatters"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start \
           justify-center min-w-0"
    ; view = Calendar_21.view
    }
  ; { name = "calendar-22"
    ; description = "Date picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_22.view
    }
  ; { name = "calendar-23"
    ; description = "Date range picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_23.view
    }
  ; { name = "calendar-24"
    ; description = "Date and Time picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_24.view
    }
  ; { name = "calendar-25"
    ; description = "Date and Time range picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_25.view
    }
  ; { name = "calendar-26"
    ; description = "Date range picker with time"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_26.view
    }
  ; { name = "calendar-27"
    ; description = "Chart filter"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start \
           justify-center min-w-0"
    ; view = Calendar_27.view
    }
  ; { name = "calendar-28"
    ; description = "Input with date picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_28.view
    }
  ; { name = "calendar-29"
    ; description = "Natural language date picker"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_29.view
    }
  ; { name = "calendar-30"
    ; description = "With little-date"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_30.view
    }
  ; { name = "calendar-31"
    ; description = "With event slots"
    ; categories = [ Calendar ]
    ; iframe_height = "700px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0"
    ; view = Calendar_31.view
    }
  ; { name = "calendar-32"
    ; description = "Date picker in a drawer"
    ; categories = [ Calendar ]
    ; iframe_height = "600px"
    ; container =
        Some
          "w-full bg-surface min-h-svh flex px-6 py-12 items-start md:pt-20 \
           justify-center min-w-0 xl:py-24"
    ; view = Calendar_32.view
    }
  ]
;;

let find name = List.find all ~f:(fun b -> String.equal b.name name)

let in_category category =
  List.filter all ~f:(fun b ->
    List.mem b.categories category ~equal:Category.equal)
;;

let featured =
  List.filter_map
    [ "dashboard-01"; "sidebar-07"; "sidebar-03"; "login-03"; "login-04" ]
    ~f:find
;;

let module_name t = String.tr t.name ~target:'-' ~replacement:'_'
