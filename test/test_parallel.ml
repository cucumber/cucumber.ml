type world = { foo : int }

let (>>=) = Lwt.Infix.(>>=)

let bar state outcome =
  match state with
  | Some x ->
     print_endline ("In Foo with some state: " ^ (string_of_int x.foo));
     (Some { foo = x.foo + 1 }, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
  | None ->
     (Some { foo = 12}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
          
(* users can use the pipeline operator *)
let foo = Cucumber.LibParallel.empty
          |>
            (Cucumber.LibParallel._When
               (Re.Perl.compile_pat "I have a thing to do")
               (fun group arg (foo_state_opt, outcome) ->
                 Lwt_io.printl "I am in the when: I have a thing to do" >>= (fun _ ->
                  let bar =
                    match foo_state_opt with
                    | Some x ->
                       (Some { foo = (succ x.foo)}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))
                    | None ->
                       (Some { foo = 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))
                  in
                  Lwt.return bar)))
          |> 
            (Cucumber.LibParallel._Given
              (Re.Perl.compile_pat "I have a simple background")
              (fun group arg (foo_state_opt, outcome) ->
                Lwt_io.printl "I am in the given: I have a simple background" >>= (fun _ -> Lwt.return (bar foo_state_opt outcome)) 
              ))
          |>
            (Cucumber.LibParallel._Then
               (Re.Perl.compile_pat "I have done the thing")
               (fun group arg (foo_state_opt, outcome) ->
                        match foo_state_opt with
                        | Some x ->
                           (Lwt_io.printl "I am in the then: I have done the thing" ) >>= (fun _ -> Lwt.return (Some {foo = x.foo + 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)))
                        | None ->
                           Lwt.return (Some { foo = 1}, (Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass))                          
            ))
          |>
            (Cucumber.LibParallel._Given
              (Re.Perl.compile_pat "I have another simple background")
              (fun group arg (foo_state_opt, outcome) ->
                Lwt_io.printl "I am in the other given" >>= (fun _ -> Lwt.return (bar foo_state_opt outcome)) 
            ))
          |>
            (Cucumber.LibParallel._When
               (Re.Perl.compile_pat "I have some other thing to do")
               (fun group arg (foo_state_opt, outcome) ->
                 Lwt_io.printl "I am in the other when" >>= (fun _ ->
                  let bar =
                    match foo_state_opt with
                    | Some x ->
                       (Some { foo = (succ x.foo)}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
                    | None ->
                       (Some { foo = 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
                  in
                  Lwt.return bar)))
          |>
            (Cucumber.LibParallel._Then
               (Re.Perl.compile_pat "I should have done the thing")
               (fun group arg (foo_state_opt, outcome) ->
                 match foo_state_opt with
                 | Some x ->
                    Lwt.return (Some {foo = x.foo + 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
                 | None ->
                    Lwt.return (Some { foo = 1}, Cucumber.OutcomeManager.add outcome Cucumber.Outcome.Pass)
            ))
          
let _ =
  Base.List.iter (Cucumber.LibParallel.execute foo "test/test_parallel.feature" None)
    ~f:(fun (world, o) ->
      match world with
      | Some x ->
         print_endline (string_of_int x.foo);
         print_endline (Cucumber.OutcomeManager.string_of_states o);
      | None ->
         print_endline "Something went wrong"
    )
