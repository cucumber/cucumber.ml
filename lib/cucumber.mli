type outcome = Pass | Fail | Pending

type args = Datatable of int | Docstring of string | Empty
type t

val empty : t
val given : t -> Re.re -> (Re.groups option -> args -> outcome) -> t
val run : t -> string -> outcome
val string_of_outcome : outcome -> string

module type TEST_PLUGIN =
  sig
    val get_tests : unit -> t
  end

val plugin : (module TEST_PLUGIN) option ref  
val get_tests : unit -> (module TEST_PLUGIN)
