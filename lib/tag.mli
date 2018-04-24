type t

val string_of_tag : t -> string
val compare : t -> t -> bool
val list_of_string : string -> (t list * t list)
