type t = {
    line : int32;
    column : int32
  }

let from_command_line () =
  { line = (Int32.of_int 0); column = (Int32.of_int 0) }
       
let string_of_location loc =
  "\nLocation [line: " ^ (Int32.to_string loc.line) ^ " column: " ^ (Int32.to_string loc.column) ^ "]\n"
  
