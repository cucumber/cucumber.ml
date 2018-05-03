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

let zip header_row row =
  let header = Base.List.map header_row.cells ~f:(fun head -> head.value) in
  let row = Base.List.map row.cells (fun cell -> cell.value) in
  let zipped_row = Base.List.zip header row in
  match zipped_row with
  | Some x ->
     x
  | None ->
     []

let update_col_map map row =
  match row with
  | (k, v) ->
     Base.Map.update map k (fun vl ->
         match vl with
         | Some x ->
            (v::x)
         | _ ->
            [v]
       )
    
let to_map_with_header dt =
  match dt.rows with
  | header::rest ->
     let key_value_zip = List.flatten (Base.List.map (Base.List.rev rest) (zip header)) in
     Base.List.fold key_value_zip ~init:(Base.Map.empty (module Base.String)) ~f:update_col_map
  | [] ->
     Base.Map.empty (module Base.String)

let transform dt f =
  let cells = Base.List.map dt.rows (fun row ->
                              Base.List.map row.cells (fun cell -> cell.value)) in
  Base.List.map cells f
