type t = {
    location : Location.t;
    content : string
  }

let string_of_docstring doc =
  let loc_str = Location.string_of_location doc.location in
  loc_str ^ "\nContent\n"  ^ doc.content ^ "\n"
