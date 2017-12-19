type t = {
    line : int32;
    column : int32
  }

let string_of_location loc =
  "\nLocation [line: " ^ (Int32.to_string loc.line) ^ " column: " ^ (Int32.to_string loc.column) ^ "]\n"
  
