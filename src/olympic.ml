
let _ =
  let pickleLst = Gherkin.load_feature_file Sys.argv.(1) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     List.iter (fun x -> (print_endline (Pickle.string_of_pickle x))) pickleLst
