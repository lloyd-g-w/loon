`loon list` names every component with the first sentence of its doc
comment (the list grows with loon, so only some are checked here).

  $ loon list | grep -E '^(button|tabs|theme|import|dom_util) '
  button           Displays a button or a component that looks like a button.
  dom_util         Small DOM effects the components share: moving focus and reading keys.
  import           What every component opens: Core, Vdom, Bonsai and small helpers.
  tabs             A set of layered sections of content, known as tab panels, that are displayed one at a time.
  theme            Light and dark mode.

Every line has a name and a description, but the blank line and heading
before the blocks: shadcn's, named as shadcn names them.

  $ loon list | awk 'NF < 2' 
  
  $ loon list | sed -n '/^Blocks/,$p' | grep -E '^(Blocks|login-03|dashboard-01) '
  Blocks (shadcn's, as `loon add login-03` copies them):
  dashboard-01     A dashboard with sidebar, charts and data table.
  login-03         A login page with a muted background color.

The modules blocks share (little_date) are not listed, but every block is.

  $ loon list | grep -c '^little_date'
  0
  [1]
  $ loon list | sed -n '/^Blocks/,$p' | grep -c -E '^(dashboard|sidebar|login|signup|calendar)-[0-9][0-9] '
  59

`loon info` says what a component is made of and what adding it brings.

  $ loon info Tabs
  tabs: A set of layered sections of content, known as tab panels, that are displayed one at a time.
  files: tabs.ml tabs.mli
  uses: cn dom_util import theme
  `loon add tabs` adds: import theme cn dom_util tabs

`loon css` is the whole stylesheet: the theme first, then a section per
component.

  $ loon css | grep '^/\* loon: ' | head -3
  /* loon: theme */
  /* loon: sonner */

A block's info is a component's.

  $ loon info login-03
  login_03: A login page with a muted background color.
  files: login_03.ml login_03.mli
  uses: button card cn field icon input theme
  `loon add login_03` adds: import theme cn button card dom_util label field icon control input login_03

Unknown names get suggestions.

  $ loon info buton
  loon: unknown component "buton": did you mean button?
  [1]
