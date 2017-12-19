type arg = String | Table

type t = {
    locations : Location.t list;
    text : string;
    argument : arg option
  }    

let string_of_step step =  
  let loc_str = List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) "" step.locations in
  "\nstep text: " ^ step.text ^ "\n" ^ loc_str
