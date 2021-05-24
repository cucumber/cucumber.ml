open Lwt.Infix
   
type 'a step = {
    regex : Re.re;
    stepdef : (Re.Group.t option -> Step.arg option -> ('a option * OutcomeManager.t) -> ('a option * OutcomeManager.t) Lwt.t)
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

let set_dialect dialect cucc =
  { cucc with dialect }
          
let match_pickle_step_to_stepdef pickle_step step_def =
  (Step.find pickle_step step_def.regex)

let match_stepdefs step_defs pickle_step =
  match (Base.List.filter step_defs ~f:(match_pickle_step_to_stepdef pickle_step)) with  
  | [matched_user_stepdef] ->
     matched_user_stepdef.stepdef (Step.find_groups pickle_step matched_user_stepdef.regex) (Step.argument pickle_step)
  | [] ->
     (fun _ ->
       (Lwt_io.eprintlf "Could not find step: %s" (Step.text pickle_step))
       >>=
     (fun _ -> Lwt.return (None, OutcomeManager.create (Some Outcome.Undefined)))
     )
  | _ ->
     (fun _ ->
       (Lwt_io.eprintlf "Ambigious match: %s" (Step.text pickle_step))
       >>=
       (fun _ -> Lwt.return (None, OutcomeManager.create (Some Outcome.Undefined))))
    
let construct_monadic_pickles cucc pickle =
  let pickle_steps = Pickle.steps pickle in
  let steps_to_run = Base.List.rev (Base.List.fold pickle_steps ~init:[]
                       ~f:(fun accum s ->
                         (match_stepdefs cucc.stepdefs s)::accum
                       )) in
  let before_hooks =
    (Pickle.construct_hooks cucc.before_hooks pickle)
    >>=
      (fun _ -> Lwt.return (None, OutcomeManager.create None))
  in
  let steps = Base.List.fold steps_to_run ~init:before_hooks ~f:(Lwt.bind) in
  steps
  >>= (fun final_state ->
    (Pickle.construct_hooks cucc.after_hooks pickle)
    >>= (fun _ -> Lwt.return final_state))
  
let execute cucc file_name tag_expr =
  let pickles = Pickle.load_feature_file
                  (Dialect.string_of_dialect cucc.dialect)
                  file_name in
  let tags =
    match tag_expr with
    | Some str ->
       Tag.list_of_string str
    | None ->
       Tag.list_of_string ""
  in  
  let monadic_pickles =
    match pickles with
    | [] ->
       [Lwt.return (None, OutcomeManager.create (Some Outcome.Undefined))]
    | _ ->
       let runnable_pickles = Pickle.filter_pickles tags pickles in
       Base.List.map runnable_pickles ~f:(construct_monadic_pickles cucc)
  in
  monadic_pickles
