type 'a t
                                     
val empty : 'a t
val _Given : Re.re -> ('a option -> Re.groups option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t
val _When : Re.re -> ('a option -> Re.groups option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t
val _Then : Re.re -> ('a option -> Re.groups option -> Step.arg option -> ('a option * Outcome.t)) -> 'a t -> 'a t

val _Before : (string -> unit) -> 'a t -> 'a t
val _After : (string -> unit) -> 'a t -> 'a t

val execute: 'a t -> unit
val fail : ('a option * Outcome.t)
val pass : ('a option * Outcome.t)
val pass_with_state : 'a -> ('a option * Outcome.t)
