type outcome = Pass | Fail | Pending

type args = Datatable of int | Docstring of string | None
type t

val empty : t
val given : t -> Re.re -> (Re.groups option -> args -> outcome) -> t
val run : t -> string -> outcome
val string_of_outcome : outcome -> string
