`loon list` names every component with the first sentence of its doc
comment (the list grows with loon, so only some are checked here).

  $ loon list | grep -E '^(button|tabs|theme|import|dom_util) '
  button           Displays a button or a component that looks like a button.
  dom_util         Small DOM effects the components share: moving focus and reading keys.
  import           What every component opens: Core, Vdom, Bonsai and small helpers.
  tabs             A set of layered sections of content, known as tab panels, that are displayed one at a time.
  theme            Light and dark mode.

Every line has a name and a description.

  $ loon list | awk 'NF < 2' 

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

Unknown names get suggestions.

  $ loon info buton
  loon: unknown component "buton": did you mean button?
  [1]
