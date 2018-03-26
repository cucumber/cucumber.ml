let count_outcome outcome outcomeLst =
  List.length (List.find_all (fun o -> o = outcome) outcomeLst)

let rec print_list = function
  | [] -> ()
  | [x] -> print_string x;
  | x::xs -> print_string x; print_string ", "; print_list xs

let print_scenario_report outcomeLists =
  let scenarios = List.length outcomeLists in

  let failed = List.length (List.find_all (fun os ->
      (count_outcome Outcome.Fail os) > 0 || (count_outcome Outcome.Pending os) > 0
    ) outcomeLists) in

  let undefined = List.length (List.find_all (fun os ->
      (count_outcome Outcome.Undefined os) > 0
    ) outcomeLists) in

  let passed = scenarios - failed - undefined in

  let stats = [] in
    let stats =
      if passed > 0
      then (string_of_int passed ^ " passed") :: stats
      else stats in
    let stats =
      if undefined > 0
      then (string_of_int undefined ^ " undefined") :: stats
      else stats in
    let stats =
      if failed > 0
      then (string_of_int failed ^ " failed") :: stats
      else stats in

  print_string (string_of_int scenarios ^ " scenarios ");
  print_string "("; print_list stats; print_endline ")"

let print_step_report outcomes =
  let steps = List.length outcomes in
  let failed = count_outcome Outcome.Fail outcomes in
  let undefined = count_outcome Outcome.Undefined outcomes in
  let skipped = count_outcome Outcome.Skip outcomes in
  let pending = count_outcome Outcome.Pending outcomes in
  let passed = count_outcome Outcome.Pass outcomes in

  let stats = [] in
    let stats =
      if passed > 0
      then (string_of_int passed ^ " passed") :: stats
      else stats in
    let stats =
      if pending > 0
      then (string_of_int pending ^ " pending") :: stats
      else stats in
    let stats =
      if skipped > 0
      then (string_of_int skipped ^ " skipped") :: stats
      else stats in
    let stats =
      if undefined > 0
      then (string_of_int undefined ^ " undefined") :: stats
      else stats in
    let stats =
      if failed > 0
      then (string_of_int failed ^ " failed") :: stats
      else stats in

  print_string (string_of_int steps ^ " steps ");
  print_string "("; print_list stats; print_endline ")"

let print outcomeLists =
  let outcomes = List.flatten outcomeLists in
  print_scenario_report outcomeLists;
  print_step_report outcomes;
  List.iter (fun o -> (print_string (Outcome.string_of_outcome o))) outcomes;
  print_newline ()