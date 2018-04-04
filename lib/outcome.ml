type t = Pass | Fail | Pending | Undefined | Skip

let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
  | Undefined -> "U"
  | Skip -> "-"