build_runtime: build_library
	ocamlfind ocamlc -g -I /home/cyocum/cucumber/gherkin/c/include -I /home/cyocum/cucumber/gherkin/c/src -c -cclib -lgherkin src/gherkin_intf.c 
	ocamlfind opt -I ./src -I ./lib  -g -package base,dynlink,re,re.perl -linkpkg  -cclib '-Wl,--no-as-needed' -cclib -lgherkin -o cucumber_run cucumber.cmxa gherkin_intf.o src/location.ml src/docstring.ml src/table.ml src/step.ml src/tag.ml src/pickle.ml src/gherkin.ml src/olympic.ml 

build_library:
	ocamlfind ocamlc -package re,re.perl -o cucumber lib/cucumber.mli
	ocamlfind opt -a -I lib/ -package re,re.perl -o cucumber.cmxa lib/cucumber.ml

build_test: build_library
	ocamlfind opt -shared -I lib/ -package re,re.perl -o test.cmxs cucumber.cmxa test/test.ml

clean:
	rm src/*.cm* src/*.o src/*~ ./cucumber lib/*.cm* lib/*.o lib/*~ *.a *.o *.cm*

install_library:
	ocamlfind install cucumber META ./lib/cucumber.cmx ./lib/cucumber.cmi ./lib/cucumber.o
