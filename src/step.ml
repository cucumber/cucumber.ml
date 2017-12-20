type arg = DocString of Docstring.t | Table 

type t = {
    locations : Location.t list;
    text : string;
    argument : arg
  }    

let string_of_arg = function
  | DocString doc ->
     Docstring.string_of_docstring doc
  | Table ->
     "Table"
       
let string_of_step step =  
  let loc_str = List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) "" step.locations in
  let step_str = "\nstep text: " ^ step.text ^ "\n" ^ loc_str in
  loc_str ^ step_str ^ (string_of_arg step.argument)
