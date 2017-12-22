let cucc = Cucumber.given
             Cucumber.empty
             (Re_perl.compile_pat "not match this")
             (fun group args ->
               Cucumber.Pending
             )

module M : Cucumber.TEST_PLUGIN =
  struct
    let get_tests () = cucc
  end
  
let _ =
  Cucumber.plugin := Some (module M : Cucumber.TEST_PLUGIN)
