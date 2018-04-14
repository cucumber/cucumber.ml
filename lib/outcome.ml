type t = Pass | Fail | Pending | Undefined | Skip

let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
  | Undefined -> "U"
  | Skip -> "-"


let count_outcome outcome outcomeLst = 
  Base.List.length (Base.List.filter outcomeLst (fun o -> o = outcome))

let count_failed outcomeLst =
  count_outcome Fail outcomeLst

let count_undefined outcomeLst =
  count_outcome Undefined outcomeLst

let count_skipped outcomeLst =
  count_outcome Skip outcomeLst

let count_pending outcomeLst =
  count_outcome Pending outcomeLst

let count_passed outcomeLst =
  count_outcome Pass outcomeLst

let print_outcomes outcomes =
  Base.List.iter outcomes (fun o -> o |> string_of_outcome |> print_string);

