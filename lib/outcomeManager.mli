type t
val create : Outcome.t option -> t
val add : t -> Outcome.t -> t
val string_of_states : t -> string
