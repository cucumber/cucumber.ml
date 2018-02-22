# Cucumber.ml

This implements the core Cucumber feature file language, Gherkin, and
assocated library for specifying the execution of those scenarios for
the OCaml programming language.

WARNING: This is still under heavy development and is provided as-is.
This is for the adventurous who do not mind rough edges and
half-implemented features.  All pull-requests are gratefully accepted.

## libgherkin.so

To be able to run the code, you will need to have compiled and
installed the Gherkin library as a shared object in your OS (so that
it will be avaliable to the linker at run time).  You can do this by
checking out the Cucumber project from Github [Cucumber gherkin-c](
https://github.com/cucumber/gherkin-c) then compiling the .so file and
installing the shared library for your OS.

## Overall Structure

The overall structure of the project is in two parts. 

The first part is the Cucumber.Lib module which is the user interface
to register test functions against the feature file.  This requires
the use of the Re regular expression library.  For instance (see the
test directory for more information),

```ocaml
let foo group args = 
  match args with
  | Cucumber.Step.DocString ds ->
     print_endline ds.Cucumber.Docstring.content;
     Cucumber.Lib.Pass
  | Cucumber.Step.Table table ->
     Cucumber.Lib.Pass
  | _ ->
     Cucumber.Lib.Fail

let cucc = 
     Cucumber.Lib._Given
	          Cucumber.Lib.empty
              (Re_perl.compile_pat "a simple DocString")
              foo
			  
module M : Cucumber.Lib.TEST_PLUGIN =
  struct
    let get_tests () = cucc
  end
  
let _ =
  Cucumber.Lib.plugin := Some (module M : Cucumber.Lib.TEST_PLUGIN)

```

The second part is the executable which will parse the Gherkin files
into an executable form, using libgherkin described above, then run
the tests against the matched step definition functions.  This will
then report back on the execution status of each step.  Linking the
user created tests bound by Cucumber.Lib is done by using the OCaml
[Dynlink](https://caml.inria.fr/pub/docs/manual-ocaml/libref/Dynlink.html)
module plugin system via the TEST_MODULE module type and first class
module unpacking.

Once the test module and the runtime has been built (see the Makefile
for an instance of building the test module), you can run the tests.
For instance,

```
./cucumber_run test.cmxs foo.feature
```

This will report back using the compact notation for Cucumber (dots
for pass, F or fail, P for pending, and U for undefined).



