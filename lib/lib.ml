type 'a step = {
    regex : Re.re;
    step : ('a option -> Re.groups option -> Step.arg -> ('a option * Outcome.t))
  }

type 'a t = {
    before_hooks : (string -> unit) list;
    after_hooks : (string -> unit) list;
    steps : 'a step list
  }

let empty = {
    after_hooks = [];
    before_hooks = [];
    steps = [];
  }

let _Before f cucc =
  let reg_before_hooks = cucc.before_hooks in
  { cucc with before_hooks = f :: reg_before_hooks }

let _After f cucc =
  let reg_after_hooks = cucc.after_hooks in
  { cucc with after_hooks = f :: reg_after_hooks }

let _Given re f cucc =
  let reg_steps = cucc.steps in
  { cucc with steps = { regex = re; step = f }::reg_steps }

let _When = _Given
let _Then = _Given

let find str {regex; step} =
  Re.execp regex str

let actuate user_step str arg state =
  let groups = (Re.exec_opt user_step.regex str) in
  user_step.step state groups arg

let run cucc state step =
  match (List.filter (find step.Step.text) cucc.steps) with
  | [user_step] ->
     actuate user_step step.Step.text step.Step.argument state
  | [] ->
     print_endline ("Could not find step: " ^ step.Step.text);
     (None, Outcome.Undefined)
  | _ ->
     print_endline ("Ambigious match: " ^ step.Step.text);
     (None, Outcome.Undefined)

let execute_before_hooks before_hooks pickel_name =
  Base.List.iter (Base.List.rev before_hooks) (fun f -> f pickel_name)

let execute_after_hooks after_hooks pickel_name =
  Base.List.iter (Base.List.rev after_hooks) (fun f -> f pickel_name)

let execute_step cucc state step =
  try
    let result = run cucc state step in
    Ok result
  with
  | ex -> Error (Printexc.to_string ex)

let execute_pickle cucc pickle =
  let name = pickle.Pickle.name in
  let steps = pickle.Pickle.steps in

  execute_before_hooks cucc.before_hooks pickle.Pickle.name;

  let (_, error, _, outcomeLst) = List.fold_left (fun (skipping, error, lastState, results) step ->
      if skipping then (true, error, None, Outcome.Skip :: results)
      else
        match execute_step cucc lastState step with
        | Ok (s, Outcome.Pass) -> (false, None, s, Outcome.Pass :: results)
        | Ok (s, o) -> (true, None, s, o :: results)
        | Error e -> (true, Some e, None, Outcome.Fail :: results)
    ) (false, None, None, []) steps in

  let _ = match error with
    | Some e -> print_endline ("Error in scenario " ^ name);
                print_endline e;
                print_newline ()
    | _ -> ()
  in

  execute_after_hooks cucc.after_hooks pickle.Pickle.name;
  List.rev outcomeLst

let load_feature_file fname =
  let pickleLst = Gherkin.load_feature_file fname in
  List.rev_map (fun p -> {p with Pickle.steps = (List.rev p.Pickle.steps)}) pickleLst

let execute cucc =
  let pickleLst = load_feature_file Sys.argv.(1) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     let outcomeLst = Base.List.map pickleLst (execute_pickle cucc) in
     Report.print outcomeLst

let fail = (None, Outcome.Fail)
let pass = (None, Outcome.Pass)
let pass_with_state state = (Some state, Outcome.Pass)
