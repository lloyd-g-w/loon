(lang dune 3.17)

(name loon)

(generate_opam_files true)

(license MIT)

(source
 (github lloyd-g-w/loon))

(package
 (name loon)
 (synopsis "Beautiful, accessible components for Bonsai_web, on OxCaml")
 (description
  "loon is a component library for Bonsai_web in the spirit of shadcn/ui: a small set of well-made components with a theme of CSS variables, usable as a library or copied into your project with the `loon add` command.")
 (depends
  ocaml
  dune
  core
  core_unix
  patience_diff
  ppx_expect
  ppx_jane
  bonsai
  bonsai_web
  bonsai_web_test
  bonsai_test
  virtual_dom
  js_of_ocaml
  js_of_ocaml-ppx
  expect_test_helpers_core))
