
let _ =
  let pickleLst = Gherkin.load_feature_file Sys.argv.(1) in
  print_endline pickleLst.Pickle.name

