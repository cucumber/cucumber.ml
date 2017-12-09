open Ctypes
   
type t

let fileReader : t structure typ = structure "FileReader"
let file_name = field fileReader "file_name" string
 
let () = seal fileReader
