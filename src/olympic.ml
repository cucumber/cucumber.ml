let load_test_plugin fname =
  let fname =  Dynlink.adapt_filename fname in
  try
    Dynlink.loadfile fname
  with
  | (Dynlink.Error err) as e ->
     print_endline ("ERROR loading plugin: " ^ (Dynlink.error_message err));
     raise e

let unpack_pickle pickle =
  List.rev_map (fun s -> s.Cucumber.Step.text) pickle.Cucumber.Pickle.steps
     
let _ =
  load_test_plugin Sys.argv.(1);
  let pickleLst = Gherkin.load_feature_file Sys.argv.(2) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     let module C = (val Cucumber.Lib.get_tests () : Cucumber.Lib.TEST_PLUGIN) in
     let stepLst = List.flatten (List.rev_map (unpack_pickle) pickleLst) in
     let outcomeLst = List.rev_map (Cucumber.Lib.run (C.get_tests ())) stepLst in
     List.iter (fun o -> (print_string (Cucumber.Lib.string_of_outcome o))) outcomeLst;
     print_newline ()

