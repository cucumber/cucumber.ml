type cell = {
    location : Location.t;
    value : string;
  }

type row = {
    cells : cell list
  }
         
type t = {
    rows: row list
  }

let string_of_cell cell =
  let loc_str = Location.string_of_location cell.location in
  loc_str ^ "\n" ^ cell.value
  
let string_of_row row =
  let aux accum cell =
    accum ^ (string_of_cell cell) ^ "\t"
  in
  (List.fold_left aux "" row.cells) ^ "\n"
       
let string_of_table table =
  let str = List.fold_left (fun accum row -> accum ^ (string_of_row row)) "" table.rows in
  "\nTable\n" ^ str
