type arg = DocString of Docstring.t | Table of Table.t  | Empty

type t
val string_of_arg : arg -> string
val string_of_step : t -> string
val find : t -> Re.re -> bool
val find_groups : t -> Re.re -> Re.groups option
val text : t -> string
val argument : t -> arg
