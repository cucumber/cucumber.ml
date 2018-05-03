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
  if Sys.file_exists fname then
    _load_feature_file fname
  else
    begin
      print_endline ("Feature File " ^ fname ^ " does not exist");
      []
    end
    
let tags_exists tags tag =
  Base.List.exists tags (Tag.compare tag)

let pickles_exists tags pickle =
  Base.List.exists tags (tags_exists pickle.tags)

let filter_not_pickles disallowed pickles =
  let allow_empty_tag_list p =
    match p.tags with
    | [] ->
       true
    | tags ->
       not (pickles_exists disallowed p)
  in                        
  Base.List.rev_filter pickles allow_empty_tag_list
  
let filter_pickles tags pickles =
  match tags with
  | ([], []) ->
     pickles
  | (allowed, []) ->
     Base.List.rev_filter pickles (pickles_exists allowed)
  | ([], disallowed) ->
     filter_not_pickles disallowed pickles
  | (allowed, disallowed) ->
     let filtered_pickles = Base.List.rev_filter pickles (pickles_exists allowed) in
     Base.List.rev_filter filtered_pickles (fun p -> not (pickles_exists disallowed p))
