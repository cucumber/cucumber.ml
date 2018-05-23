# Cucumber.ml

This implements the core Cucumber feature file language, Gherkin, and
associated library for specifying the execution of those scenarios for
the OCaml programming language.

WARNING: This is still under heavy development and is provided as-is.
This is for the adventurous who do not mind rough edges and
half-implemented features.  All pull-requests are gratefully accepted.

## libgherkin.so

To be able to run the code, you will need to have compiled and
installed the Gherkin library as a shared object in your OS (so that
it will be available to the linker at run time).  You can do this by
checking out the Cucumber project from Github [Cucumber gherkin-c](
https://github.com/cucumber/gherkin-c) then compiling the .so file and
installing the shared library for your OS.

## Overall Structure

Cucumber.ml is a library that is used to create an executable runtime
of step definitions.  This means that the library assumes that, once
`execute` is called, the library will read the command line arguments
for feature files.  The user of the library does not need to specify
command line options as the library will read them itself to determine
what feature files an other things to run.

```ocaml
type world = { foo : bool }

let man_state curr_state next_state = 
    match curr_state with
  | Some x ->
     begin
       print_endline ("my state is " ^ (string_of_bool x.foo));
       (Some { foo = next_state }, Cucumber.Lib.Pass)
     end
  | None ->
     begin
       print_endline "I have no state";
       (Some { foo = next_state }, Cucumber.Lib.Pass)
     end

(* users can use the pipeline operator *)
let foo = Cucumber.Lib.empty
          |>
            (Cucumber.Lib._Given
              (Re.Perl.compile_pat "a simple DocString")
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

let _ =
  Cucumber.Lib.execute foo

```

See the test/test.ml file for more information.

Once the executable has been built (see the Makefile for an instance
of building the test module), you can run the tests.  For instance,

```
./cucumber_run foo.feature
```

This will report back using the compact notation for Cucumber (dots
for pass, F or fail, P for pending, and U for undefined).



