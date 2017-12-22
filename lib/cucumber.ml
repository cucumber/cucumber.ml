
type outcome = Pass | Fail | Pending
type args = Datatable of int | Docstring of string | Empty
                           
let string_of_outcome = function
  | Pass -> "."
  | Fail -> "F"
  | Pending -> "P"
                           
type step = {
    regex : Re.re;
    step : (Re.groups option -> args -> outcome)
  }

type t = step list

let empty = []
       
let given cucc re f =
  { regex = re; step = f } :: cucc
  
let find str {regex; step} =
  Re.execp regex str

let actuate step str =
  let groups = (Re.exec_opt step.regex str) in
  step.step groups Empty
  
let run cucc str =
  match (List.find_opt (find str) cucc) with
  | Some step ->
     actuate step str
  | None ->
     print_endline ("Could not find step: " ^ str);
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
