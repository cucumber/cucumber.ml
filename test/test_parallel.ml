type world = { foo : bool }

let (>>=) = Lwt.Infix.(>>=)
     
(* users can use the pipeline operator *)
let foo = Cucumber.LibParallel.empty
          |>
            Cucumber.LibParallel._Given
              (Re.Perl.compile_pat "I have a simple background")
              (fun group arg (foo_state_opt, outcome) ->
                Lwt_io.printl "I am here" >>= (fun _ -> Lwt.return (Some { foo = true}, Cucumber.Outcome.Pass))
              )
          |>
            (Cucumber.LibParallel._When
               (Re.Perl.compile_pat "I have a thing to do")
               (fun group arg (foo_state_opt, outcome) ->
                    Lwt_io.printl "I am in the when" >>= (fun _ -> Lwt.return (foo_state_opt, Cucumber.Outcome.Undefined))
               ))
          
let _ =
  match (Cucumber.LibParallel.execute foo "test/test_parallel.feature") with
  | [(Some x, o)] ->
     print_endline (string_of_bool x.foo)
  | _ ->
     print_endline "Something went wrong"
