let cucc = Cucumber.Lib.given
             Cucumber.Lib.empty
             (Re_perl.compile_pat "the minimalism")
             (fun group args ->
               Cucumber.Lib.Pass
             )

module M : Cucumber.Lib.TEST_PLUGIN =
  struct
    let get_tests () = cucc
  end
  
let _ =
  Cucumber.Lib.plugin := Some (module M : Cucumber.Lib.TEST_PLUGIN)
