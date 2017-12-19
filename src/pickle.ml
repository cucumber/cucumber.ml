type tag = {
    loc : Location.t;
    name : string
  }

type arg = String | Table
         
type step = {
    locations : Location.t list;
    text : string;
    argument : arg option
  }    
         
type t = {
    lang : string;
    name : string;
    locations_t : Location.t list;
    tags : tag list;
    steps : step list
  }

let string_of_step step =  
  let loc_str = List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) "" step.locations in
  "step text: " ^ step.text ^ "\n" ^ loc_str
       
let string_of_tag tag =
  let loc_column = Int32.to_string tag.loc.Location.column in
  let loc_line = Int32.to_string tag.loc.Location.line in
  "\ntag name : " ^ tag.name ^ " column: " ^ loc_column ^ " line: " ^ loc_line

let string_of_pickle pickle =
  let str = "lang: " ^ pickle.lang ^ " name: " ^ pickle.name in
  let str_2 = List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) str pickle.locations_t in
  let str_3 = List.fold_left (fun accum tag -> accum ^ (string_of_tag tag)) str_2 pickle.tags in
  str_3 ^ List.fold_left (fun accum step -> accum ^ (string_of_step step)) str_3 pickle.steps
  
