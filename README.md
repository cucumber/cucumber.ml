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

Cucumber.ml is split between two modules: `Cucumber.Lib` and
`Cucumber.LibLwt`.

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


# Cucumber Lwt

To allow concurrancy, Lwt support is included.  This is fairly similar
to the synchonous verison given above but with a few important changes
to the function signatures.  To seperate the differing
implementations, the user will need to use the `Cucumber.LibLwt`
module rather than the `Cucumber.Lib` module.

The function signature for a normal step definition is:

```ocaml
Re.Group.t option -> Step.arg option -> ('a option * OutcomeManager.t) -> ('a option * OutcomeManager.t) Lwt.t
```

The main portion of the function signature that the user needs to pay
attension to is the `('a option * OutcomeManager.t) -> ('a option *
OutcomeManager.t) `.  The step definition function now takes a tuple
which has two members: the state of the step and the `OutcomeManager`.
The `OutcomeManager` saves the outcomes from all steps.  The user can
only add to the `OutcomeManager`, which is meant to assure the user
that steps have not changed the outcome of any previous steps.
Although, there is a flaw in the design where the step can return an
entirely new and empty `OutcomeManager`; although, returning a fresh
`OutcomeManager` would be self-defeating.

The return value of the step definition is an Lwt promise which can
have any state to pass forward to the next step and an updated
OutcomeManager where the outcome of the step is recorded by using the
`OutcomeManager.add` function.  

There are examples of use in the `test/test_concurrent.ml` and a feature
file that will trigger the step definitions in
`test/test_concurrent.feature`.

# Design of Concurrent Cucumber

The way in which Cucumber.ml works is that the user supplies regular
expressions which match the steps in the feature.  To facilitate this,
Cucumber.ml takes a two step approach.  First, it takes the various
steps definitions and hook definitions and stores them in a context.
Second, once that context has been build to the user's satisfaction,
the user calls the `execute` function.  What this does is load the
feature file then it matches the tags so that there is a list of
runnable pickles.  Next, it matches the runnable pickles against the
regular expressions given by the user which gives an ordering of the
steps.  The ordering of steps is important because the next step
involves binding the steps together into that order.  At this point it
is good to remember that a monad is a way of creating the illusion of
imperative steps in a purely functional way where all functions can be
run at any time.  Once this is done, `execute` will pass the
constructed monads back to the user as a list.  At this point, the
user may bind more functions or whatever the user needs to do.  It is
good to remember that the first stitching together a run order for the
steps is done synchonously before the monads are handed back to the
user for further processing or running by `Lwt_main.run`.

