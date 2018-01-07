type outcome = Pass | Fail | Pending | Undefined
                           
let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
  | Undefined -> "U"
                           
type step = {
    regex : Re.re;
    step : (Re.groups option -> Step.arg -> outcome)
  }

type t = step list

let empty = []
       
let _Given cucc re f =
  { regex = re; step = f } :: cucc

let _When = _Given
let _Then = _Given
  
let find str {regex; step} =
  Re.execp regex str

let actuate user_step str arg =
  let groups = (Re.exec_opt user_step.regex str) in
  user_step.step groups arg
  
let run cucc step =
  match (List.find_opt (find step.Step.text) cucc) with
  | Some user_step ->
     actuate user_step step.Step.text step.Step.argument
  | None ->
     print_endline ("Could not find step: " ^ step.Step.text);
     Pending  

module type TEST_PLUGIN =
  sig
    val get_tests : unit -> t
  end

let plugin = ref None
  
let get_tests () : (module TEST_PLUGIN) =
  match !plugin with
  | Some s -> s
  | None -> failwith "No plugin loaded"
