let load_test_plugin fname =
  let fname =  Dynlink.adapt_filename fname in
  try
    Dynlink.loadfile "/home/cyocum/.opam/4.05.0+flambda/lib/re/re.cmxs";
    Dynlink.loadfile "/home/cyocum/.opam/4.05.0+flambda/lib/re/re_perl.cmxs";
    Dynlink.loadfile fname
  with
  | (Dynlink.Error err) as e ->
     print_endline ("ERROR loading plugin: " ^ (Dynlink.error_message err));
     raise e

let unpack_pickle pickle =
  List.rev_map (fun s -> s.Step.text) pickle.Pickle.steps
     
let _ =
  load_test_plugin "/home/cyocum/olympic/test.cmxs";
  let pickleLst = Gherkin.load_feature_file Sys.argv.(1) in
  match pickleLst with
  | [] -> print_endline "Empty Pickle list"
  | _ ->
     let module C = (val Cucumber.get_tests () : Cucumber.TEST_PLUGIN) in
     let stepLst = List.flatten (List.rev_map (unpack_pickle) pickleLst) in
     List.iter (fun step -> print_endline step) stepLst;
     let outcomeLst = List.rev_map (Cucumber.run (C.get_tests ())) stepLst in
     List.iter (fun o -> (print_string (Cucumber.string_of_outcome o))) outcomeLst;
     print_newline ()

