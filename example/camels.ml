open Cucumber.Lib

type farm = { camels: int }

let steps = 
  empty
  |> set_dialect Cucumber.Dialect.En
  |> _Given (Re.Perl.compile_pat "I have (\\d+) camel on my farm")
       (fun state group args -> 
         let no_camels = Option.bind group (fun g -> Re.Group.get_opt g 1)
                         |> Option.map (fun f -> int_of_string_opt f)
                         |> Option.join
                         |> Option.value ~default:0 in
         pass_with_state { camels = no_camels }
       )

  |> _When (Re.Perl.compile_pat "I buy (\\d+) more camels")
       (fun state group args -> 
         let more_camels = Option.bind group (fun g -> Re.Group.get_opt g 1)
                         |> Option.map (fun f -> int_of_string_opt f)
                         |> Option.join
                           |> Option.value ~default:0 in
         let state = match state with
           | None -> failwith "No state"
           | Some state -> state
         in
         pass_with_state { camels = state.camels + more_camels }
       )
  |> _Then (Re.Perl.compile_pat "I have (\\d+) camels on my farm")
       (fun state group args -> 
         let camels = Option.bind group (fun g -> Re.Group.get_opt g 1)
                      |> Option.map (fun f -> int_of_string_opt f)
                      |> Option.join
                      |> Option.value ~default:0 in
         let state = match state with
           | None -> failwith "No state"
           | Some state -> state
         in
         if (state.camels == camels) then (Some state, Cucumber.Outcome.Pass)
         else (Some state, Cucumber.Outcome.Fail)
       )
let _ =
  execute steps