let _ =
  let re = Re_perl.compile_pat "not match this" in
  let cucc = Cucumber.given Cucumber.empty re (fun group args ->
                              Cucumber.Pending
                            )
  in
  print_endline (Cucumber.string_of_outcome (Cucumber.run cucc "match this"))
           
