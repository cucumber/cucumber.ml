let format_stats stats =
  Base.List.fold stats ~init:[] ~f:(fun acc (text, count) ->
      if count > 0
      then (string_of_int count ^ " " ^ text)::acc
      else acc
    )
  
let scenario_report outcome_lists =
  let scenarios = Base.List.length outcome_lists in
  let failed = Base.List.length (Base.List.filter outcome_lists ~f:(fun os ->
      (Outcome.count_outcome Outcome.Fail os) > 0 || (Outcome.count_outcome Outcome.Pending os) > 0))
  in
  let undefined = Base.List.length (Base.List.filter outcome_lists ~f:(fun os ->
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
  Format.sprintf "@[%d@ scenarios@ @[(%s)@]@]@." scenarios stats_str
    
let step_report outcomes =
  let steps = Base.List.length outcomes in
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
    Format.sprintf "@[%d steps@ @[(%s)@]@]" steps stats_str
  else
    Format.sprintf "@[%d steps@]" steps
  
let print feature_file outcome_lists =
  let outcomes = List.flatten outcome_lists in  
  Format.printf "@[Feature File: %s@]@.@[%s@]@[%s@]@.@[%s@]@.@." feature_file (scenario_report outcome_lists) (step_report outcomes) (Outcome.string_of_outcomes outcomes)
