open Cucumber.Lib

type world = { foo : bool }

let man_state curr_state next_state =
    match curr_state with
  | Some x ->
     print_endline ("my state is " ^ (string_of_bool x.foo));
     (Some { foo = next_state }, Cucumber.Outcome.Pass)
  | None ->
     print_endline "I have no state";
     (Some { foo = next_state }, Cucumber.Outcome.Pass)
     
(* users can use the pipeline operator *)
let foo =
  empty
  |> set_dialect Cucumber.Dialect.En
  |> _After
       (fun str ->
         print_endline "After step";
       )
  |> _Before
       (fun str ->
         print_endline "Before step";
       )
  |>
    _Given
      (Re.Perl.compile_pat "a simple (\\w+)")
      (fun state group args ->
        print_endline "Given";
        pass_with_state { foo = true})
  |>
    _When
      (Re.Perl.compile_pat "I run my test")
      (fun state group args ->
        print_endline "When";
        man_state state false)
  |>
    _Then
      (Re.Perl.compile_pat "I should receive the test results")
      (fun state group args ->
        print_endline "Then";
        man_state state true)

(* or they can use a list then use a fold function to build up the run *)
let bar = [
    _Given
      (Re.Perl.compile_pat "a simple DocString")
      (fun state group args ->
        print_endline "Given";
        man_state state true);
    _When
      (Re.Perl.compile_pat "I run my test")
      (fun state group args ->
        print_endline "When";
        man_state state false);
    _Then
      (Re.Perl.compile_pat "I should receive the test results")
      (fun state group args ->
        print_endline "Then";
        man_state state true)
  ]

let _ =
  let _cucc = Base.List.fold bar ~init:Cucumber.Lib.empty ~f:(fun accum stepdef -> stepdef accum) in
  execute foo