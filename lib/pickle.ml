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

let execute_hooks hooks p =
    Base.List.iter (Base.List.rev hooks) (fun f -> f p.name)

let steps p =
  p.steps

let name p =
  p.name

external _load_feature_file : string -> t list = "load_feature_file"
  
let load_feature_file fname =
  let pickleLst = _load_feature_file fname in
  Base.List.rev_map pickleLst (fun p -> {p with steps = (List.rev p.steps)})

let tags_exists tags tag_str =
  Base.List.exists tags (Tag.compare_str tag_str)

let pickles_exists tags pickle =
  Base.List.exists tags (tags_exists pickle.tags)    
  
let filter_pickles tags pickles =
  Base.List.rev_filter pickles (pickles_exists tags)

