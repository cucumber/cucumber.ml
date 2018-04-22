type t = {
    location : Location.t;
    name : string
  }

let create loc name =
  { location = loc; name = name }
       
let create_from_command_line name =
  { location = (Location.from_command_line ()) ;
    name = name}

let string_of_tag tag =
  let loc_str = Location.string_of_location tag.location in
  "\ntag name : " ^ tag.name ^ "\n" ^ loc_str

let compare t1 t2 =
  t1.name = t2.name
  
