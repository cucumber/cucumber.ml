type t = Outcome.t list

let create outcome_start =
  match outcome_start with
  | Some x ->
     [x]
  | None ->
     []

let add outcomes outcome_to_add =
  outcome_to_add :: outcomes

let string_of_states states =
  Outcome.string_of_outcomes (Base.List.rev states)
