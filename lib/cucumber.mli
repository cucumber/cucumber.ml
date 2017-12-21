type outcome = Pass | Fail | Pending
type t

val empty : t
val given : t -> Re.re -> (Re.groups option -> outcome) -> t
val run : t -> string -> outcome
val string_of_outcome : outcome -> string
