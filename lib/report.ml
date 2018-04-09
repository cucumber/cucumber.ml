let rec print_list = function
  | [] -> ()
  | [x] -> print_string x;
  | x::xs -> print_string x; print_string ", "; print_list xs
             
let print_scenario_report outcomeLists =
  let scenarios = List.length outcomeLists in
  let failed = List.length (Base.List.filter outcomeLists (fun os ->
      (Outcome.count_outcome Outcome.Fail os) > 0 || (Outcome.count_outcome Outcome.Pending os) > 0))
  in
  let undefined = List.length (Base.List.filter outcomeLists (fun os ->
      (Outcome.count_outcome Outcome.Undefined os) > 0))
  in
  let passed = scenarios - failed - undefined in
  let stats = [
      ("passed", passed);
      ("undefined", undefined);
      ("failed", failed)
    ]
  in
  let formattedStats = Base.List.fold stats ~init:[] ~f:(fun acc (text, count) ->
                           if count > 0
                           then (string_of_int count ^ " " ^ text) :: acc
                           else acc
                         )
  in 
  print_string (string_of_int scenarios ^ " scenarios ");
  print_string "("; print_list formattedStats; print_endline ")"

let print_step_report outcomes =
  let steps = List.length outcomes in
  let stats = [
          ("passed",    Outcome.count_passed outcomes);
          ("pending",   Outcome.count_pending outcomes);
          ("skipped",   Outcome.count_skipped outcomes);
          ("undefined", Outcome.count_undefined outcomes);
          ("failed",    Outcome.count_failed outcomes);
        ]
  in
  let formattedStats = Base.List.fold stats ~init:[] ~f:(fun acc (text, count) ->
                  if count > 0
                  then (string_of_int count ^ " " ^ text) :: acc
                  else acc
                )
  in 
  print_string (string_of_int steps ^ " steps ");
  print_string "("; print_list formattedStats; print_endline ")"

let print outcomeLists =
  let outcomes = List.flatten outcomeLists in
  print_scenario_report outcomeLists;
  print_step_report outcomes;
  Base.List.iter  outcomes (fun o -> (print_string (Outcome.string_of_outcome o)));
  print_newline ()
