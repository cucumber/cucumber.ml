type t = {
    lang : string;
    name : string;
    locations : Location.t list
  }

let string_of_pickle pickle =
  let str = "lang: " ^ pickle.lang ^ " name: " ^ pickle.name in
  List.fold_left (fun accum loc -> accum ^ (Location.string_of_location loc)) str pickle.locations
