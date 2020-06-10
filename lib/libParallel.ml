open Lwt.Infix
   
type 'a step = {
    regex : Re.re;
    stepdef : (Re.Group.t option -> Step.arg option -> ('a option * Outcome.t) -> ('a option * Outcome.t) Lwt.t)
  }

type 'a t = {
    before_hooks : (string -> unit Lwt.t) list;
    after_hooks : (string -> unit Lwt.t) list;
    stepdefs : 'a step list;
    dialect : Dialect.t
  }

let empty = {
    after_hooks = [];
    before_hooks = [];
    stepdefs = [];
    dialect = Dialect.En
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

let match_pickle_step_to_stepdef pickle_step step_def =
    if (Step.find pickle_step step_def.regex) then
      true
    else
      false

let match_stepdefs step_defs pickle_step =
  match (Base.List.filter step_defs ~f:(match_pickle_step_to_stepdef pickle_step)) with  
  | [matched_user_stepdef] ->
     let bar = matched_user_stepdef.stepdef (Step.find_groups pickle_step matched_user_stepdef.regex) (Step.argument pickle_step) in
     bar
  | _ ->
     (fun _ -> Lwt.return (None, Outcome.Undefined))

let foo stepdefs accum pickle_step =
  (match_stepdefs stepdefs pickle_step)::accum

let construct_computation cucc pickle =
  let pickle_steps = (Pickle.steps pickle) in
  let steps_to_run = Base.List.fold pickle_steps ~init:[]
                       ~f:(fun accum s ->
                         foo cucc.stepdefs accum s 
                       ) in
  let start_computation =
    (Pickle.construct_hooks cucc.before_hooks pickle)
    >>=
      (fun _ -> Lwt.return (None, Outcome.Pass))
  in
  Base.List.fold steps_to_run ~init:start_computation ~f:(Lwt.bind)

let execute_computation cucc file_name =
  let pickles = Pickle.load_feature_file
                  (Dialect.string_of_dialect cucc.dialect)
                  file_name in
  match pickles with
  | x::_ ->
     Lwt_main.run (construct_computation cucc x)
  | _ ->
     (None, Outcome.Undefined)

