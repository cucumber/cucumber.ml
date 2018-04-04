type t = Pass | Fail | Pending | Undefined | Skip

val string_of_outcome: t -> string
val count_outcome : t -> t list -> int
val count_failed : t list -> int
val count_undefined : t list -> int
val count_skipped : t list -> int
val count_pending : t list -> int
val count_passed : t list -> int
