type t = Pass | Fail | Pending | Undefined | Skip

let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
  | Undefined -> "U"
  | Skip -> "-"


let count_outcome outcome outcome_lst = 
  Base.List.length (Base.List.filter outcome_lst ~f:(fun o -> o = outcome))

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
  Base.List.iter outcomes ~f:(fun o -> o |> string_of_outcome |> print_string)
  
(** returns exit status  suitable for use with the exit function. *)
let exit_status outcome_list =
  if (count_failed outcome_list > 0)
     || (count_undefined outcome_list > 0) then
    3
  else
    0  

let string_of_outcomes outcomes =
  Base.String.concat ~sep:"" (Base.List.map outcomes ~f:(string_of_outcome))
