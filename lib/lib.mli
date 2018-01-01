type outcome = Pass | Fail | Pending

type t

val empty : t
val given : t -> Re.re -> (Re.groups option -> Step.arg -> outcome) -> t
val run : t -> Step.t -> outcome
val string_of_outcome : outcome -> string

module type TEST_PLUGIN =
  sig
    val get_tests : unit -> t
  end

val plugin : (module TEST_PLUGIN) option ref  
val get_tests : unit -> (module TEST_PLUGIN)
