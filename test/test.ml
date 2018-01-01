let foo group args = 
  match args with
  | Cucumber.Step.DocString ds ->
     print_endline ds.Cucumber.Docstring.content;
     Cucumber.Lib.Pass
  | Cucumber.Step.Table table ->
     Cucumber.Lib.Pass
  | _ ->
     Cucumber.Lib.Fail

    
let cucc =
    let x = Cucumber.Lib.given
              Cucumber.Lib.empty
              (Re_perl.compile_pat "a DocString with escaped separator inside")
              foo
    in
    Cucumber.Lib.given
      x
      (Re_perl.compile_pat "DocString with alternative separator inside")
      foo
    
module M : Cucumber.Lib.TEST_PLUGIN =
  struct
    let get_tests () = cucc
  end
  
let _ =
  Cucumber.Lib.plugin := Some (module M : Cucumber.Lib.TEST_PLUGIN)
