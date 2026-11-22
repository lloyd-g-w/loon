examples/app uses loon as a library and builds one stylesheet with Tailwind
v4 over loon's installed input and its own sources.

  $ css=../app/main.css

The app's own Tailwind classes, which no loon component uses:

  $ grep -o '^  \.\(bg-linear-to-br\|from-sky-50\|to-indigo-100\) {' $css
    .bg-linear-to-br {
    .from-sky-50 {
    .to-indigo-100 {

loon's classes, including those of components the app does not use, the
theme and Sonner's stylesheet:

  $ grep -o 'has-data-\\\[slot\\=card-action\\\]' $css | sort -u
  has-data-\[slot\=card-action\]
  $ grep -c 'data-\\\[state\\=open\\\]\\:animate-in' $css | sed 's/^[1-9][0-9]*$/some/'
  some
  $ grep -c '^\[data-sonner-toaster\] {' $css
  1
  $ grep -c -- '--primary:' $css | sed 's/^[1-9][0-9]*$/some/'
  some

And the app itself:

  $ test -s ../app/main.bc.js && echo built
  built
