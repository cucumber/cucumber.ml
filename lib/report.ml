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
  let stats_str = Base.String.concat ~sep:", " (format_stats stats) in
  Format.printf "@[%d@ scenarios@ @[(%s)@]@]@." scenarios stats_str
    
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
  let stats_str = Base.String.concat ~sep:", " (format_stats stats) in
  if steps > 0 then
    Format.printf "@[%d steps@ @[(%s)@]@]@." steps stats_str
  else
    Format.printf "@[%d steps@]@." steps
  
let print feature_file outcome_lists =
  let outcomes = List.flatten outcome_lists in
  print_endline ("Feature File: " ^ feature_file);
  print_scenario_report outcome_lists;
  print_step_report outcomes;
  Outcome.print_outcomes outcomes;
  print_newline (); print_newline ();
