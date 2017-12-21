build_runtime:
	ocamlfind ocamlc -g -I /home/cyocum/cucumber/gherkin/c/include -I /home/cyocum/cucumber/gherkin/c/src -c -cclib -lgherkin src/gherkin_intf.c 
	ocamlfind opt -I ./src  -g -package base -linkpkg  -cclib '-Wl,--no-as-needed' -cclib -lgherkin -o cucumber_run gherkin_intf.o src/location.ml src/docstring.ml src/table.ml src/step.ml src/tag.ml src/pickle.ml src/gherkin.ml src/olympic.ml 

build_library:
	ocamlfind ocamlc -package re,re.perl -o cucumber lib/cucumber.mli
	ocamlfind opt -a -I lib/ -package re,re.perl -o cucumber.cmxa lib/cucumber.ml

build_test:
	ocamlfind opt -I lib/ -package re,re.perl -linkpkg -o cucumber_test cucumber.cmxa test/test.ml

clean:
	rm src/*.cm* src/*.o src/*~ ./cucumber lib/*.cm* lib/*.o lib/*~ *.a *.o
