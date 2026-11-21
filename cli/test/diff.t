`loon diff` shows how the project's copies differ from loon's, as a unified
diff (which `patch -R` or `git apply -R` would undo), and exits 1 if they
differ.

  $ loon add tabs alert > /dev/null
  $ loon diff tabs alert
  tabs, alert: the same as loon's.
  $ sed -i 's/^(\*\* A set of layered sections/(** My set of layered sections/' src/ui/tabs.mli
  $ echo '.loon-alert { gap: 0 }' >> src/ui/loon.css
  $ rm src/ui/dom_util.mli
  $ loon diff tabs alert dom_util | sed 's/^@@ -[0-9,]* +[0-9,]* @@$/@@ (lines) @@/'
  --- loon/tabs.mli
  +++ src/ui/tabs.mli
  @@ (lines) @@
  -(** A set of layered sections of content, known as tab panels, that are
  +(** My set of layered sections of content, known as tab panels, that are
       displayed one at a time. Port of shadcn/ui's [Tabs] (Radix Tabs'
       behaviour: arrow keys move between the triggers and select them, Home
       and End go to the first and last, disabled triggers are skipped).
  dom_util.mli: not in src/ui/dom_util.mli

The diff undoes with patch.

  $ loon diff tabs | patch -s -R src/ui/tabs.mli
  $ loon diff tabs
  tabs: the same as loon's.

With no names, it compares everything the project has.

  $ loon diff | grep -E '^(---|[a-z_.]+:)'
  dom_util.mli: not in src/ui/dom_util.mli
  --- loon/theme in loon.css
  $ loon diff -dir nowhere
  nowhere has no loon components.

Unknown names are errors.

  $ loon diff tab
  loon: unknown component "tab": did you mean tabs or table or data_table?
  [1]
