type t

val load_feature_file : string -> t list 
val execute_hooks : (string -> unit) list -> t -> unit
val steps : t -> Step.t list
val name : t -> string
