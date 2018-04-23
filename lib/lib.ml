type 'a step = {
    regex : Re.re;
    stepdef : ('a option -> Re.groups option -> Step.arg -> ('a option * Outcome.t))
  }

type 'a t = {
    before_hooks : (string -> unit) list;
    after_hooks : (string -> unit) list;
    stepdefs : 'a step list
  }

let empty = {
    after_hooks = [];
    before_hooks = [];
    stepdefs = [];
  }

let _Before f cucc =
  let reg_before_hooks = cucc.before_hooks in
  { cucc with before_hooks = f :: reg_before_hooks }

let _After f cucc =
  let reg_after_hooks = cucc.after_hooks in
  { cucc with after_hooks = f :: reg_after_hooks }

let _Given re f cucc =
  let reg_steps = cucc.stepdefs in
  { cucc with stepdefs = { regex = re; stepdef = f }::reg_steps }

let _When = _Given
let _Then = _Given

let find str {regex; stepdef} =
  Re.execp regex str

let actuate user_step step state =
  let groups = Step.find_groups step user_step.regex in
  user_step.stepdef state groups (Step.argument step) 

let run cucc state step =
  match (Base.List.filter cucc.stepdefs (find (Step.text step))) with
  | [user_step] ->
     actuate user_step step state
  | [] ->
     print_endline ("Could not find step: " ^ (Step.text step));
     (None, Outcome.Undefined)
  | _ ->
     print_endline ("Ambigious match: " ^ (Step.text step));
     (None, Outcome.Undefined)

let execute_step cucc state step =
  try
    let result = run cucc state step in
    Ok result
  with
  | ex -> Error (Printexc.to_string ex)

let execute_step_with_skip cucc (skipping, error, lastState, results) step =
  if skipping then
    (true, error, None, Outcome.Skip::results)
  else
    match execute_step cucc lastState step with
    | Ok (s, Outcome.Pass) ->
       (false, None, s, Outcome.Pass::results)
    | Ok (s, o) ->
       (true, None, s, o :: results)
    | Error e ->
       (true, Some e, None, Outcome.Fail::results)

let print_error error pickle =
  match error with
  | Some e ->
     print_endline ("Error in scenario " ^ Pickle.name pickle);
     print_endline e;
     print_newline ()
  | _ -> ()
  
let execute_pickle cucc pickle =
  let steps = Pickle.steps pickle in
  Pickle.execute_hooks cucc.before_hooks pickle;
  let (_, error, _, outcomeLst) = Base.List.fold steps ~init:(false, None, None, [])  ~f:(execute_step_with_skip cucc) in
  print_error error pickle;
  Pickle.execute_hooks cucc.after_hooks pickle;
  Base.List.rev outcomeLst
  
let execute_pickle_lst cucc tags exit_status feature_file =
  let pickle_lst = Pickle.load_feature_file feature_file in
  match pickle_lst with
  | [] ->
     print_endline "Empty Pickle list";
     Outcome.exit_status []
  | _ ->
     let runnable_pickle_lst = Pickle.filter_pickles tags pickle_lst in
     let outcome_lst = Base.List.map runnable_pickle_lst (execute_pickle cucc) in
     Report.print feature_file outcome_lst;
     if exit_status = 0 then
       Outcome.exit_status (List.flatten outcome_lst)
     else
       exit_status
  
let tags = ref ""
and feature_files = ref []

let specs =
  [
    ("--tags", Arg.Set_string tags, "set tags that will be run");
    ("-t", Arg.Set_string tags, "set tags that will be run");
  ]

(** Executes current Cucumber context and returns exit status 
    suitable for use with the exit function.
 *)
let execute cucc =
  Arg.parse specs (fun anon -> feature_files := anon::!feature_files) "Feature Files";
  let tags = Tag.list_of_string !tags in
  Base.List.fold (Base.List.rev !feature_files) ~init:0 ~f:(execute_pickle_lst cucc tags)
  
let fail = (None, Outcome.Fail)
let pass = (None, Outcome.Pass)
let pass_with_state state = (Some state, Outcome.Pass)
