(** The query in the docs' hash, [#/create?preset=b0&item=preview-02]: the
    customisers keep their state there, as shadcn's keep theirs in the URL's
    search params. *)

open! Core

(** The text after the first [?] of a hash ([""] when there is none). *)
val of_hash : string -> string

(** The hash of the page [slug] with the query [query]: [#/slug?query], or
    [#/slug] when [query] is empty. *)
val to_hash : slug:string -> string -> string

(** [a=1&b=two%20words] as [("a", "1"); ("b", "two words")], in order;
    [+] is a space. *)
val parse : string -> (string * string) list

(** The inverse of [parse], percent-encoding what needs it. *)
val to_string : (string * string) list -> string

val find : (string * string) list -> string -> string option
