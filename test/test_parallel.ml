type world = { foo : int }

let (>>=) = Lwt.Infix.(>>=)

let bar =
  function
  | Some x ->
     (Some { foo = x.foo + 1 }, Cucumber.Outcome.Pass)
  | None ->
     (Some { foo = 12}, Cucumber.Outcome.Pass)
          
(* users can use the pipeline operator *)
let foo = Cucumber.LibParallel.empty
          |>
            (Cucumber.LibParallel._Given
              (Re.Perl.compile_pat "I have a simple background")
              (fun group arg (foo_state_opt, outcome) ->
                Lwt_io.printl "I am in the given" >>= (fun _ -> Lwt.return (bar foo_state_opt)) 
              ))
          |>
            (Cucumber.LibParallel._When
               (Re.Perl.compile_pat "I have a thing to do")
               (fun group arg (foo_state_opt, outcome) ->
                 Lwt_io.printl "I am in the when" >>= (fun _ ->
                  let bar =
                    match foo_state_opt with
                    | Some x ->
                       (Some { foo = (succ x.foo)}, Cucumber.Outcome.Pass)
                    | None ->
                       (Some { foo = 1}, Cucumber.Outcome.Pass)
                  in
                  Lwt.return bar)))
          |>
            (Cucumber.LibParallel._Then
               (Re.Perl.compile_pat "I have done the thing")
               (fun group arg (foo_state_opt, outcome) ->
                        match foo_state_opt with
                        | Some x ->
                           Lwt.return (Some {foo = x.foo + 1}, Cucumber.Outcome.Pass)
                        | None ->
                           Lwt.return (Some { foo = 1}, Cucumber.Outcome.Pass)                          
                 ))
          
let _ =
  match (Cucumber.LibParallel.execute foo "test/test_parallel.feature" None) with
  | [(Some x, o)] ->
     print_endline (string_of_int x.foo)
  | _ ->
     print_endline "Something went wrong"
