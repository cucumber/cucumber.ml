type outcome = Pass | Fail | Pending | Undefined | Skip
                                     
let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
  | Undefined -> "U"
  | Skip -> "-"
               
type 'a step = {
    regex : Re.re;
    step : ('a option -> Re.groups option -> Step.arg -> ('a option * outcome))
  }

type 'a t = 'a step list

let empty = []

let _Given re f cucc =
  { regex = re; step = f } :: cucc

let _When = _Given
let _Then = _Given
          
let find str {regex; step} =
  Re.execp regex str

let actuate user_step str arg state =
  let groups = (Re.exec_opt user_step.regex str) in
  user_step.step state groups arg
  
let run (cucc : 'a t) state step =
  match (List.filter (find step.Step.text) cucc) with
  | [user_step] ->
     actuate user_step step.Step.text step.Step.argument state
  | [] ->
     print_endline ("Could not find step: " ^ step.Step.text);
     (None, Undefined)
  | _ ->
     print_endline ("Ambigious match: " ^ step.Step.text);
     (None, Undefined)

let load_feature_file fname =
  let pickleLst = Gherkin.load_feature_file fname in
  List.rev_map (fun p -> {p with Pickle.steps = (List.rev p.Pickle.steps)}) pickleLst

let unpack_pickle pickle =
  pickle.Pickle.steps
  
let extract_last_state_run cucc outcome_accum step =
  match outcome_accum with
  | [] ->
     let outcome = run cucc None step in
     outcome::outcome_accum     
  | (state, out)::xs ->
     let outcome = run cucc state step in
     outcome::outcome_accum
     
let execute cucc =
  let pickleLst = load_feature_file Sys.argv.(1) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     let stepLst = List.flatten (Base.List.map pickleLst (unpack_pickle)) in
     let outcomeLst = Base.List.fold stepLst ~init:[] ~f:(extract_last_state_run cucc) in
     Base.List.iter outcomeLst (fun (state, out) -> (print_string (string_of_outcome out))) ;
     print_newline ()         

let fail = (None, Fail)
let pass = (None, Pass)
let pass_with_state state = (Some state, Pass)
