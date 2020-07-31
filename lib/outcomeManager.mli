type t
val create : Outcome.t -> t
val add : t -> Outcome.t -> t
val string_of_states : t -> string
