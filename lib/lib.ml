type 'a step = {
    regex : Re.re;
    stepdef : ('a option -> Re.groups option -> Step.arg option -> ('a option * Outcome.t))
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

let find str step =
  Re.execp step.regex str

let actuate user_step step state =
  let groups = Step.find_groups step user_step.regex in
  user_step.stepdef state groups (Step.argument step) 

let run cucc state step =
  match (Base.List.filter cucc.stepdefs ~f:(find (Step.text step))) with
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
     Outcome.exit_status []
  | _ ->
     let runnable_pickle_lst = Pickle.filter_pickles tags pickle_lst in
     let outcome_lst = Base.List.map runnable_pickle_lst ~f:(execute_pickle cucc) in
     Report.print feature_file outcome_lst;
     if exit_status = 0 then
       Outcome.exit_status (List.flatten outcome_lst)
     else
       exit_status

let files_arg = Cmdliner.Arg.(non_empty & pos_all file [] & info [] ~docv:"FILE" ~doc:"List of feature files to run")
let tags_arg = Cmdliner.Arg.(value & opt (some string) None & info ["tags"] ~docv:"TAGS" ~doc:"Listing tags allows the use of the tagging feature of Cucumber.  The format is @tag to a feature or step to run and ~@tag to disallow a tag from running. Tags are seperated by a space (the comma for 'or' is not supported). For instance, --tags \"@tag1 ~@tag2\" will run features/steps tagged with @tag1 and will not run features/steaps with @tag2.")
             
let manage_command_line cucc tags_str files =
  let tags =
    match tags_str with
    | Some str ->
       Tag.list_of_string str
    | None ->
       Tag.list_of_string ""
  in
  let exit_status = Base.List.fold files ~init:0 ~f:(execute_pickle_lst cucc tags) in
  if exit_status = 0 then
    `Ok 0
  else
    `Error (false, "Some scenarios failed. Please see output for more details")
  
let cmd cucc =
  Cmdliner.Term.(ret (const (manage_command_line cucc) $ tags_arg $ files_arg)),
  Cmdliner.Term.info "Cucumber.ml" ~version:"1.0" ~doc:"Run Cucumber Stepdefs" ~exits:Cmdliner.Term.default_exits
  
(** Executes current Cucumber context and exits the process.
 *)
let execute cucc =
  Cmdliner.Term.(exit @@ eval (cmd cucc))
  
let fail = (None, Outcome.Fail)
let pass = (None, Outcome.Pass)
let pass_with_state state = (Some state, Outcome.Pass)
