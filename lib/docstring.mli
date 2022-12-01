(** A type representing a Doc String.

    Doc Strings are used to pass a larger piece of text to a step defition.
*)

type t
   
(** Pretty print a Doc String. *)
val string_of_docstring : t -> string

(** Map across a Doc String. *)
val transform : t -> (string -> 'a) -> 'a
