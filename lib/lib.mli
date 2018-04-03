type 'a t       
type outcome = Pass | Fail | Pending | Undefined | Skip
                                     
val empty : 'a t
val _Given : Re.re -> ('a option -> Re.groups option -> Step.arg -> ('a option * outcome)) -> 'a t -> 'a t
val _When : Re.re -> ('a option -> Re.groups option -> Step.arg -> ('a option * outcome)) -> 'a t -> 'a t
val _Then : Re.re -> ('a option -> Re.groups option -> Step.arg -> ('a option * outcome)) -> 'a t -> 'a t 

val _Before : (string -> unit) -> 'a t -> 'a t
val _After : (string -> unit) -> 'a t -> 'a t
val string_of_outcome : outcome -> string
val execute: 'a t -> unit      
val fail : ('a option * outcome)
val pass : ('a option * outcome)
val pass_with_state : 'a -> ('a option * outcome)
