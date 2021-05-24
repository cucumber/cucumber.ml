type world = { foo : int }

let (>>=) = Lwt.Infix.(>>=)

let manip_state state outcome =
  match state with
  | Some x ->
     print_endline ("In Manip_State with some state: " ^ (string_of_int x.foo));
     (Some { foo = (succ x.foo) }, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
  | None ->
     print_endline ("In Manip_State with no state setting foo to 12");
     (Some { foo = 12 }, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)

let first_given_func group arg (foo_state_opt, outcome) =
  Lwt_io.printl "I am in the given: I have a simple background" >>= (fun _ -> Lwt.return (manip_state foo_state_opt outcome)) 
     
let first_when_func group arg (foo_state_opt, outcome) =
  Lwt_io.printl "I am in the when: I have a thing to do" >>= (fun _ ->
    let bar =
      match foo_state_opt with
      | Some x ->         
         (Some { foo = (succ x.foo)}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))
      | None ->
         (Some { foo = 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))
    in
    Lwt.return bar)  

let first_then_func group arg (foo_state_opt, outcome) =
  match foo_state_opt with
  | Some x ->
     (Lwt_io.printl "I am in the then: I have done the thing" ) >>= (fun _ -> Lwt.return (Some {foo = x.foo + 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)))
  | None ->
     Lwt.return (Some { foo = 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))

let second_given_func group arg (foo_state_opt, outcome) =
  Lwt_io.printl "I am in the other given" >>= (fun _ -> Lwt.return (manip_state foo_state_opt outcome))            
let second_when_func group arg (foo_state_opt, outcome) =
  Lwt_io.printl "I am in the other when" >>= (fun _ ->
    let bar =
      match foo_state_opt with
      | Some x ->
         (Some { foo = (succ x.foo)}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
      | None ->
         (Some { foo = 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
    in
    Lwt.return bar)

let second_then_func group arg (foo_state_opt, outcome) =
  Lwt_io.printl "I am in the other then" >>= (fun _ ->
    match foo_state_opt with
    | Some x ->
       Lwt.return (Some {foo = x.foo + 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
    | None ->
       Lwt.return (Some { foo = 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
  )  
  
(* users can use the pipeline operator *)
let foo = Cucumber.LibLwt.empty
          |>
            (Cucumber.LibLwt._When
               (Re.Perl.compile_pat "^I have a thing to do$")
               first_when_func)
          |> 
            (Cucumber.LibLwt._Given
               (Re.Perl.compile_pat "^I have a simple background$")
               first_given_func)
          |>
            (Cucumber.LibLwt._Then
               (Re.Perl.compile_pat "^I have done the thing$")
               first_then_func)
          |>
            (Cucumber.LibLwt._Given
              (Re.Perl.compile_pat "^I have another simple background$")
              second_given_func)
          |>
            (Cucumber.LibLwt._When
               (Re.Perl.compile_pat "^I have some other thing to do$")
               second_when_func)
          |>
            (Cucumber.LibLwt._Then
               (Re.Perl.compile_pat "^I should have done the thing$")
               second_then_func)
          |>
            (Cucumber.LibLwt._When
               (Re.Perl.compile_pat "^I have a thing to do 2$")
               first_when_func)
          |> 
            (Cucumber.LibLwt._Given
               (Re.Perl.compile_pat "^I have a simple background 2$")
               first_given_func)
          |>
            (Cucumber.LibLwt._Then
               (Re.Perl.compile_pat "^I have done the thing 2$")
               first_then_func)
          |>
            (Cucumber.LibLwt._Given
              (Re.Perl.compile_pat "^I have another simple background 2$")
              second_given_func)
          |>
            (Cucumber.LibLwt._When
               (Re.Perl.compile_pat "^I have some other thing to do 2$")
               second_when_func)
          |>
            (Cucumber.LibLwt._Then
               (Re.Perl.compile_pat "^I should have done the thing 2$")
               second_then_func)
  
        
let _ =
  let pickles = (Cucumber.LibLwt.execute foo "test/test_concurrent.feature" None) in
  let more_pickles = (Cucumber.LibLwt.execute foo "test/test_concurrent_2.feature" None) in
  Lwt_main.run begin
    (Lwt.all pickles)
    >>= (fun outcomes1 ->
        Lwt_list.iter_p (fun (world, o) ->
            match world with
            | Some x ->
               Lwt_io.printl (string_of_int x.foo)
                 >>= (fun _ -> Lwt_io.printl (Cucumber.OutcomeManager.string_of_states o))
            | None ->
               Lwt_io.printl "Something went wrong"
          ) outcomes1
    ) >>= (fun _ -> Lwt.all more_pickles)
    >>= (fun outcomes2 ->
        Lwt_list.iter_p (fun (world, o) ->
            match world with
            | Some x ->
               Lwt_io.printl (string_of_int x.foo)
                 >>= (fun _ -> Lwt_io.printl (Cucumber.OutcomeManager.string_of_states o))
            | None ->
               Lwt_io.printl "Something went wrong"
          ) outcomes2    
    )
    end 
