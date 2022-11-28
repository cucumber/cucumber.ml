# Cucumber.ml

This implements the core Cucumber feature file language, Gherkin, and
associated library for specifying the execution of those scenarios for
the OCaml programming language.

## libgherkin.so

Libgherkin.so is the C library that Cucumber.ml uses to parse the
feature files.  This uses a git submodule to bring the
[gherkin-c](https://github.com/cucumber/gherkin-c) library into the
current project.  This means that you will need to init the submodule
after you checkout the repository like so:

```bash
git submodule update
``` 

or clone the repository with `--recursive`. This will bring the gherkin-c 
library into the `lib` directory.

## Building

This project uses [Dune](https://github.com/ocaml/dune) as its build
system.  To build the Cucumber library run:

```bash
dune build 
```

This will build and install the Cucumber library into your
[Opam](https://opam.ocaml.org/) repository and make it available to
ocamlfind.

## Overall Structure

Cucumber.ml is a library that is used to create an executable runtime
of step definitions.  This means that the library assumes that, once
`execute` is called, the library will read the command line arguments
for feature files.  The user of the library does not need to specify
command line options as the library will read them itself to determine
what feature files and other things to run.

```ocaml
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

(* or they can use a list then use a fold function to build up the run 
eg Base.List.fold bar ~init:empty ~f:(fun accum stepdef -> stepdef accum)
*)
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
          
let () =
  execute foo

```

``` gherkin
Feature: Test Example

Scenario: A passing scenario
 Given a simple true
 When I run my test
 Then I should receive the test results
```

See the test/test.ml and test/test.feature files for more information.

Once the executable has been built (see the Makefile for an instance
of building the test module), you can run the tests.  For instance,

```
dune exec -- cucumber test/test.feature
```

This will report back using the compact notation for Cucumber (dots
for pass, F or fail, P for pending, and U for undefined).