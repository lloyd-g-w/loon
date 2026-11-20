(* The stateless display components' HTML. *)

open! Core
open Loon
module Node = Virtual_dom.Vdom.Node

let%expect_test "alert" =
  List.iter Alert.Variant.all ~f:(fun variant ->
    Render.html (Alert.view ~variant ~title:"Heads up" [ Node.text "Something happened." ]));
  [%expect {|
    <div role="status" class="loon-alert loon-alert-neutral">
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-alert-icon loon-icon loon-icon-info">
        <circle cx="12." cy="12." r="9.5"> </circle>
        <path d="M12 16v-4.5M12 8h.01"> </path>
      </svg>
      <div class="loon-alert-body">
        <div class="loon-alert-title"> Heads up </div>
        <div class="loon-alert-description"> Something happened. </div>
      </div>
    </div>
    <div role="status" class="loon-alert loon-alert-info">
      <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-alert-icon loon-icon loon-icon-info">
        <circle cx="12." cy="12." r="9.5"> </circle>
        <path d="M12 16v-4.5M12 8h.01"> </path>
      </svg>
      <div class="loon-alert-body">
        <div class="loon-alert-title"> Heads up </div>
        <div class="loon-alert-description"> Something happened. </div>
      </div>
    </div>
    <div role="status" class="loon-alert loon-alert-success">
      <svg viewBox="0 0 24 24"
           aria-hidden="true"
           class="loon-alert-icon loon-icon loon-icon-check-circle">
        <circle cx="12." cy="12." r="9.5"> </circle>
        <path d="m8.5 12.5 2.5 2.5 4.5-5"> </path>
      </svg>
      <div class="loon-alert-body">
        <div class="loon-alert-title"> Heads up </div>
        <div class="loon-alert-description"> Something happened. </div>
      </div>
    </div>
    <div role="alert" class="loon-alert loon-alert-warning">
      <svg viewBox="0 0 24 24"
           aria-hidden="true"
           class="loon-alert-icon loon-icon loon-icon-alert-triangle">
        <path d="M10.3 3.9 2.4 17.5A2 2 0 0 0 4.1 20.5h15.8a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"> </path>
        <path d="M12 9.5v4M12 17h.01"> </path>
      </svg>
      <div class="loon-alert-body">
        <div class="loon-alert-title"> Heads up </div>
        <div class="loon-alert-description"> Something happened. </div>
      </div>
    </div>
    <div role="alert" class="loon-alert loon-alert-danger">
      <svg viewBox="0 0 24 24"
           aria-hidden="true"
           class="loon-alert-icon loon-icon loon-icon-alert-circle">
        <circle cx="12." cy="12." r="9.5"> </circle>
        <path d="M12 7.5v5M12 16h.01"> </path>
      </svg>
      <div class="loon-alert-body">
        <div class="loon-alert-title"> Heads up </div>
        <div class="loon-alert-description"> Something happened. </div>
      </div>
    </div>
    |}];
  Render.html (Alert.view ~icon:None [ Node.text "No icon, no title" ]);
  [%expect {|
    <div role="status" class="loon-alert loon-alert-neutral">
      <div class="loon-alert-body">
        <div class="loon-alert-description"> No icon, no title </div>
      </div>
    </div>
    |}]
;;

let%expect_test "avatar" =
  List.iter [ "Ada Lovelace"; "plato"; "Jean-Luc Picard"; "  "; "émile zola" ] ~f:(fun n ->
    printf "%S -> %S\n" n (Avatar.initials n));
  [%expect {|
    "Ada Lovelace" -> "AL"
    "plato" -> "P"
    "Jean-Luc Picard" -> "JP"
    "  " -> ""
    "\195\169mile zola" -> "\195\169Z"
    |}];
  Render.html (Avatar.view ~src:"/ada.jpg" ~status:`Online "Ada Lovelace");
  [%expect {|
    <span class="loon-avatar loon-avatar-circle loon-avatar-md" style={ --loon-avatar-hue: 350; }>
      <span aria-hidden="true" class="loon-avatar-fallback"> AL </span>
      <img src="/ada.jpg" alt="Ada Lovelace" loading="lazy" class="loon-avatar-image" @on_error/>
      <span title="online" class="loon-avatar-status loon-avatar-status-online"> </span>
    </span>
    |}];
  Render.html
    (Avatar.group
       ~size:Sm
       ~max:2
       (List.map [ "Ada Lovelace"; "Alan Turing"; "Grace Hopper"; "Edsger Dijkstra" ] ~f:(fun n ->
          Avatar.view ~size:Sm n)));
  [%expect {|
    <div role="group" class="loon-avatar-group loon-avatar-group-sm">
      <span class="loon-avatar loon-avatar-circle loon-avatar-sm" style={ --loon-avatar-hue: 350; }>
        <span aria-hidden="true" class="loon-avatar-fallback"> AL </span>
        <span class="loon-sr-only"> Ada Lovelace </span>
      </span>
      <span class="loon-avatar loon-avatar-circle loon-avatar-sm" style={ --loon-avatar-hue: 185; }>
        <span aria-hidden="true" class="loon-avatar-fallback"> AT </span>
        <span class="loon-sr-only"> Alan Turing </span>
      </span>
      <span aria-label="2 more" class="loon-avatar loon-avatar-circle loon-avatar-more loon-avatar-sm"> +2 </span>
    </div>
    |}]
;;

let%expect_test "separator, skeleton, spinner, kbd, empty" =
  Render.html (Separator.view ());
  Render.html (Separator.view ~orientation:Vertical ~semantic:true ());
  Render.html (Separator.view ~label:"or" ());
  [%expect {|
    <div role="none" class="loon-separator loon-separator-horizontal"> </div>
    <div role="separator" aria-orientation="vertical" class="loon-separator loon-separator-vertical"> </div>
    <div role="none" class="loon-separator loon-separator-horizontal loon-separator-labelled">
      <span class="loon-separator-label"> or </span>
    </div>
    |}];
  Render.html (Skeleton.view ~shape:Circle ());
  Render.html (Skeleton.text ~lines:2 ());
  [%expect {|
    <div aria-hidden="true" class="loon-skeleton loon-skeleton-circle"> </div>
    <div aria-hidden="true" class="loon-skeleton-lines">
      <div aria-hidden="true" class="loon-skeleton loon-skeleton-text"> </div>
      <div aria-hidden="true" class="loon-skeleton loon-skeleton-text" style={ width: 60%; }> </div>
    </div>
    |}];
  Render.html (Spinner.view ~size:Sm ());
  [%expect {|
    <span role="status" aria-label="Loading" class="loon-spinner loon-spinner-sm">
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="12" cy="12" r="9.5" class="loon-spinner-track"> </circle>
        <path d="M21.5 12a9.5 9.5 0 0 0-9.5-9.5" class="loon-spinner-arc"> </path>
      </svg>
    </span>
    |}];
  Render.html (Kbd.combo [ "Cmd"; "Shift"; "P" ]);
  Render.html (Kbd.combo ~symbols:false [ "Ctrl"; "K" ]);
  [%expect {|
    <kbd class="loon-kbd-combo">
      <kbd title="Cmd" aria-label="Cmd" class="loon-kbd"> ⌘ </kbd>
      <kbd title="Shift" aria-label="Shift" class="loon-kbd"> ⇧ </kbd>
      <kbd class="loon-kbd"> P </kbd>
    </kbd>
    <kbd class="loon-kbd-combo">
      <kbd class="loon-kbd"> Ctrl </kbd>
      <kbd class="loon-kbd"> K </kbd>
    </kbd>
    |}];
  Render.html
    (Empty.view
       ~icon:Inbox
       ~description:"New messages show up here."
       ~actions:[ Button.view [ Node.text "Compose" ] ]
       "No messages");
  [%expect {|
    <div class="loon-empty">
      <div class="loon-empty-icon">
        <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-inbox">
          <path d="M22 12h-6l-2 3h-4l-2-3H2"> </path>
          <path d="M5.5 5.1 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.5-6.9A2 2 0 0 0 16.8 4H7.2a2 2 0 0 0-1.7 1.1Z"> </path>
        </svg>
      </div>
      <h3 class="loon-empty-title"> No messages </h3>
      <p class="loon-empty-description"> New messages show up here. </p>
      <div class="loon-empty-actions">
        <button type="button" class="loon-button loon-button-md loon-button-primary"> Compose </button>
      </div>
    </div>
    |}]
;;

let%expect_test "progress" =
  Render.html (Progress.view ~label:"Upload" ~value:42. ());
  Render.html (Progress.view ~value:150. ~tone:Success ());
  Render.html (Progress.view ~max:0. ~value:1. ());
  Render.html (Progress.view ());
  [%expect {|
    <div role="progressbar"
         aria-valuemin="0"
         aria-valuemax="100"
         data-state="loading"
         aria-valuenow="42"
         aria-label="Upload"
         class="loon-progress loon-progress-md loon-progress-primary">
      <div class="loon-progress-indicator" style={ transform: translateX(-58.00%); }> </div>
    </div>
    <div role="progressbar"
         aria-valuemin="0"
         aria-valuemax="100"
         data-state="complete"
         aria-valuenow="100"
         class="loon-progress loon-progress-md loon-progress-success">
      <div class="loon-progress-indicator" style={ transform: translateX(-0.00%); }> </div>
    </div>
    <div role="progressbar"
         aria-valuemin="0"
         aria-valuemax="0"
         data-state="loading"
         aria-valuenow="0"
         class="loon-progress loon-progress-md loon-progress-primary">
      <div class="loon-progress-indicator" style={ transform: translateX(-100.00%); }> </div>
    </div>
    <div role="progressbar"
         aria-valuemin="0"
         aria-valuemax="100"
         data-state="indeterminate"
         class="loon-progress loon-progress-md loon-progress-primary">
      <div class="loon-progress-indicator"> </div>
    </div>
    |}]
;;

let%expect_test "breadcrumb" =
  let items =
    Breadcrumb.Item.
      [ create ~href:"/" "Home"
      ; create ~href:"/docs" "Docs"
      ; create ~href:"/docs/components" "Components"
      ; create ~href:"/docs/components/display" "Display"
      ; create "Breadcrumb"
      ]
  in
  Render.html (Breadcrumb.view (List.take items 2));
  [%expect {|
    <nav aria-label="Breadcrumb" class="loon-breadcrumb">
      <ol class="loon-breadcrumb-list">
        <li class="loon-breadcrumb-item">
          <a href="/" class="loon-breadcrumb-link"> Home </a>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-current="page" class="loon-breadcrumb-page"> Docs </span>
        </li>
      </ol>
    </nav>
    |}];
  Render.html (Breadcrumb.view ~max_items:3 items);
  [%expect {|
    <nav aria-label="Breadcrumb" class="loon-breadcrumb">
      <ol class="loon-breadcrumb-list">
        <li class="loon-breadcrumb-item">
          <a href="/" class="loon-breadcrumb-link"> Home </a>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-label="3 more" role="img" class="loon-breadcrumb-ellipsis">
            <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-more-horizontal">
              <circle cx="5." cy="12." r="1."> </circle>
              <circle cx="12." cy="12." r="1."> </circle>
              <circle cx="19." cy="12." r="1."> </circle>
            </svg>
          </span>
        </li>
        <li role="presentation" aria-hidden="true" class="loon-breadcrumb-separator">
          <svg viewBox="0 0 24 24" aria-hidden="true" class="loon-icon loon-icon-chevron-right">
            <path d="m9 18 6-6-6-6"> </path>
          </svg>
        </li>
        <li class="loon-breadcrumb-item">
          <span aria-current="page" class="loon-breadcrumb-page"> Breadcrumb </span>
        </li>
      </ol>
    </nav>
    |}]
;;

let%expect_test "table" =
  Render.html
    (Table.view
       ~striped:true
       ~caption:"Invoices"
       ~footer:[ Table.cell [ Node.text "Total" ]; Table.cell ~align:Right [ Node.text "$30" ] ]
       ~columns:
         Table.Column.
           [ text "Invoice" fst; text ~align:Right "Amount" (fun (_, a) -> sprintf "$%d" a) ]
       [ "INV001", 10; "INV002", 20 ]);
  [%expect {|
    <div class="loon-table-container">
      <table class="loon-table loon-table-hover loon-table-striped">
        <caption class="loon-table-caption"> Invoices </caption>
        <thead class="loon-table-header">
          <tr class="loon-table-row">
            <th scope="col" data-align="left" class="loon-table-head"> Invoice </th>
            <th scope="col" data-align="right" class="loon-table-head"> Amount </th>
          </tr>
        </thead>
        <tbody class="loon-table-body">
          <tr class="loon-table-row">
            <td data-align="left" class="loon-table-cell"> INV001 </td>
            <td data-align="right" class="loon-table-cell"> $10 </td>
          </tr>
          <tr class="loon-table-row">
            <td data-align="left" class="loon-table-cell"> INV002 </td>
            <td data-align="right" class="loon-table-cell"> $20 </td>
          </tr>
        </tbody>
        <tfoot class="loon-table-footer">
          <tr class="loon-table-row">
            <td data-align="left" class="loon-table-cell"> Total </td>
            <td data-align="right" class="loon-table-cell"> $30 </td>
          </tr>
        </tfoot>
      </table>
    </div>
    |}]
;;
