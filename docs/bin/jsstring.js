// js_of_ocaml's runtime (6.3, strings as MlBytes) turns an OCaml string
// into a JS one (every attribute, class and text node Virtual_dom sets) by
// converting it to a Uint8Array and decoding that as UTF-8, every time, and
// leaves the string an array. An ASCII string is its own JS string: mark it
// so (as MlBytes's toString does) and hand that back.

//Provides: caml_jsstring_of_string mutable (const)
//If: !js-string
function caml_jsstring_of_string(s) {
  if (s.t !== 9) s.toString();
  return s.t === 9 ? s.c : s.toUtf16();
}
