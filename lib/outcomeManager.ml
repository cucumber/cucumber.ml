type t = Outcome.t list

let create outcome_start =
  [outcome_start]

let add outcomes outcome_to_add =
  outcome_to_add :: outcomes

let string_of_states states =
  Outcome.string_of_outcomes (Base.List.rev states)
