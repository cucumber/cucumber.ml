type t = {
    lang : string;
    name : string;
    locations : Location.t list;
    tags : Tag.t list;
    steps : Step.t list
  }       

let string_of_pickle pickle =
  let str = "\n\nNew Pickle\nlang: " ^ pickle.lang ^ " name: " ^ pickle.name in
  let str_2 = List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) str pickle.locations in
  let str_3 = List.fold_left (fun accum tag -> accum ^ (Tag.string_of_tag tag)) str_2 pickle.tags in
  str_3 ^ List.fold_left (fun accum step -> accum ^ (Step.string_of_step step)) str_3 pickle.steps
  
