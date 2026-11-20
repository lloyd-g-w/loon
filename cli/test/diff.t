`loon diff` shows how the project's copies differ from loon's, as a unified
diff (which `patch -R` or `git apply -R` would undo), and exits 1 if they
differ.

  $ loon add tabs > /dev/null
  $ loon diff tabs
  tabs: the same as loon's.
  $ sed -i 's/^(\*\* Tabs: a row of triggers/(** My tabs: a row of triggers/' src/ui/tabs.mli
  $ echo '.loon-tabs { gap: 0 }' >> src/ui/loon.css
  $ rm src/ui/dom_util.mli
  $ loon diff tabs dom_util | sed 's/^@@ -[0-9,]* +[0-9,]* @@$/@@ (lines) @@/'
  --- loon/tabs.mli
  +++ src/ui/tabs.mli
  @@ (lines) @@
  -(** Tabs: a row of triggers, one panel shown at a time. Arrow keys, Home and
  +(** My tabs: a row of triggers, one panel shown at a time. Arrow keys, Home and
       End move between the triggers (WAI-ARIA tabs). *)
   
   open! Import
  --- loon/tabs in loon.css
  +++ src/ui/loon.css
  @@ (lines) @@
     color: var(--loon-foreground);
     border-bottom-color: var(--loon-accent);
   }
  +.loon-tabs { gap: 0 }
  dom_util.mli: not in src/ui/dom_util.mli

The diff undoes with patch.

  $ loon diff tabs | sed -n '1,/^--- loon\/tabs in/p' | sed '$d' | patch -s -R src/ui/tabs.mli
  $ loon diff tabs 2>&1 | head -1
  --- loon/tabs in loon.css

With no names, it compares everything the project has.

  $ loon diff | grep -E '^(---|[a-z_.]+:)'
  dom_util.mli: not in src/ui/dom_util.mli
  --- loon/tabs in loon.css
  $ loon diff -dir nowhere
  nowhere has no loon components.

Unknown names are errors.

  $ loon diff tab
  loon: unknown component "tab": did you mean tabs or table or data_table?
  [1]
