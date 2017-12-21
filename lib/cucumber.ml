type outcome = Pass | Fail | Pending

let string_of_outcome = function
  | Pass -> "P"
  | Fail -> "F"
  | Pending -> "Pend"    
                           
type step = {
    regex : Re.re;
    step : (Re.groups option -> outcome)
  }

type t = step list

let empty = []
       
let given cucc re f =
  { regex = re; step = f } :: cucc
  
let find str {regex; step} =
  Re.execp regex str

let actuate step str =
  let groups = (Re.exec_opt step.regex str) in
  step.step groups
  
let run cucc str =
  match (List.find_opt (find str) cucc) with
  | Some step ->
     actuate step str
  | None ->
     print_endline ("Could not find step: " ^ str);
     Pending

    
