type t = {
    lang : string;
    name : string;
    locations : Location.t list;
    tags : Tag.t list;
    steps : Step.t list
  }       

let execute_hooks hooks p =
    Base.List.iter (Base.List.rev hooks) ~f:(fun f -> f p.name)

let steps p =
  p.steps

let name p =
  p.name

external _load_feature_file : string -> t list = "load_feature_file"
  
let load_feature_file fname =
  if Sys.file_exists fname then
    Base.List.rev (_load_feature_file fname)
  else
    begin
      print_endline ("Feature File " ^ fname ^ " does not exist");
      []
    end
    
let tags_exists tags tag =
  Base.List.exists tags ~f:(Tag.compare tag)

let pickles_exists tags pickle =
  Base.List.exists tags ~f:(tags_exists pickle.tags)

let filter_not_pickles disallowed pickles =
  let allow_empty_tag_list p =
    match p.tags with
    | [] ->
       true
    | _ ->
       not (pickles_exists disallowed p)
  in                        
  Base.List.rev_filter pickles ~f:allow_empty_tag_list
  
let filter_pickles tags pickles =
  match tags with
  | ([], []) ->
     pickles
  | (allowed, []) ->
     Base.List.rev_filter pickles ~f:(pickles_exists allowed)
  | ([], disallowed) ->
     filter_not_pickles disallowed pickles
  | (allowed, disallowed) ->
     let filtered_pickles = Base.List.rev_filter pickles ~f:(pickles_exists allowed) in
     Base.List.rev_filter filtered_pickles ~f:(fun p -> not (pickles_exists disallowed p))
