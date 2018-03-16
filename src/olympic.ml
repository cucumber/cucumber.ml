let load_test_plugin fname =
  let fname =  Dynlink.adapt_filename fname in
  try
    Dynlink.loadfile fname
  with
  | (Dynlink.Error err) as e ->
     print_endline ("ERROR loading plugin: " ^ (Dynlink.error_message err));
     raise e

let load_feature_file fname =
  let pickleLst = Gherkin.load_feature_file fname in
  List.rev_map (fun p -> {p with Cucumber.Pickle.steps = (List.rev p.Cucumber.Pickle.steps)}) pickleLst

let unpack_pickle pickle =
  pickle.Cucumber.Pickle.steps
     
let _ =
  (* the below is to force linking with the camlCamlinternalOO module 
     see https://discuss.ocaml.org/t/objects-and-dynlink/1720 *)
  let _obj = object end in
  load_test_plugin Sys.argv.(1);
  let pickleLst = load_feature_file Sys.argv.(2) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     let module C = (val Cucumber.Lib.get_tests () : Cucumber.Lib.TEST_PLUGIN) in
     let stepLst = List.flatten (Base.List.map pickleLst (unpack_pickle)) in
     let outcomeLst = Base.List.map stepLst (Cucumber.Lib.run (C.get_tests ())) in
     List.iter (fun o -> (print_string (Cucumber.Lib.string_of_outcome o))) outcomeLst;
     print_newline ()
