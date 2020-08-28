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

This will bring the gherkin-c library into the `lib` directory.

## Building

This project uses [Dune](https://github.com/ocaml/dune) as its build
system.  To build the Cucumber library do:

```bash
dune build && dune install
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
            Cucumber.Lib.set_dialect Cucumber.Dialect.En
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



