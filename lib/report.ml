let rec print_list = function
  | [] -> ()
  | [x] -> print_string x;
  | x::xs -> print_string x; print_string ", "; print_list xs

let format_stats stats =
  Base.List.fold stats ~init:[] ~f:(fun acc (text, count) ->
      if count > 0
      then (string_of_int count ^ " " ^ text) :: acc
      else acc
    )  
             
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
  let formattedStats = format_stats stats in 
  if scenarios > 0 then
    begin
      print_string (string_of_int scenarios ^ " scenarios ");
      print_string "("; print_list formattedStats; print_endline ")"
    end
  else
    print_endline (string_of_int scenarios ^ " scenarios ")
    
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
  let formattedStats = format_stats stats in
  if steps > 0 then
    begin
      print_string (string_of_int steps ^ " steps ");
      print_string "("; print_list formattedStats; print_endline ")"
    end
  else
    print_string (string_of_int steps ^ " steps ")
  
let print feature_file outcome_lists =
  let outcomes = List.flatten outcome_lists in
  print_endline ("Feature File: " ^ feature_file);
  print_scenario_report outcome_lists;
  print_step_report outcomes;
  Outcome.print_outcomes outcomes;
  print_newline () 
