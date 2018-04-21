type t = {
    location : Location.t;
    name : string
  }

let string_of_tag tag =
  let loc_column = Int32.to_string tag.location.Location.column in
  let loc_line = Int32.to_string tag.location.Location.line in
  "\ntag name : " ^ tag.name ^ " column: " ^ loc_column ^ " line: " ^ loc_line

let compare t1 t2 =
  t1.name = t2.name

let compare_str str t1 =
  str = t1.name
  
