type world = { foo : bool }

let man_state curr_state next_state = 
    match curr_state with
  | Some x ->
     begin
       print_endline ("my state is " ^ (string_of_bool x.foo));
       (Some { foo = next_state }, Cucumber.Outcome.Pass)
     end
  | None ->
     begin
       print_endline "I have no state";
       (Some { foo = next_state }, Cucumber.Outcome.Pass)
     end  
     
(* users can use the pipeline operator *)
let foo = Cucumber.Lib.empty
          |>
            Cucumber.Lib._After
              (fun str ->
                print_endline "After step";
              )
          |> Cucumber.Lib._Before
               (fun str ->
                 print_endline "Before step";
               )
          |>
            (Cucumber.Lib._Given
              (Re.Perl.compile_pat "a simple (\\w+)")
              (fun state group args ->
                print_endline "Given";
                Cucumber.Lib.pass_with_state { foo = true}))
          |>
            Cucumber.Lib._When
              (Re.Perl.compile_pat "I run my test")
              (fun state group args ->
                print_endline "When";
                man_state state false)
          |>
            Cucumber.Lib._Then
              (Re.Perl.compile_pat "I should receive the test results")
              (fun state group args ->
                print_endline "Then";              
                man_state state true)            

(* or they can use a list then use a fold function to build up the run *)
let bar = [
    Cucumber.Lib._Given
      (Re.Perl.compile_pat "a simple DocString")
      (fun state group args ->
        print_endline "Given";
        man_state state true);
    Cucumber.Lib._When
            (Re.Perl.compile_pat "I run my test")
            (fun state group args ->
              print_endline "When";
              man_state state false);
    Cucumber.Lib._Then
            (Re.Perl.compile_pat "I should receive the test results")
            (fun state group args ->
              print_endline "Then";              
              man_state state true)
  ]

          
let _ =
  let _cucc = Base.List.fold bar ~init:Cucumber.Lib.empty ~f:(fun accum stepdef -> stepdef accum) in
  Cucumber.Lib.execute foo
