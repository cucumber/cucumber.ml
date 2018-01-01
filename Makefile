.PHONY: clean install_library

build_library:
	ocamlfind ocamlc -for-pack Cucumber -c -package re,re.perl lib/lib.mli
	ocamlfind opt -I lib/ -for-pack Cucumber -package re,re.perl -c lib/lib.ml lib/location.ml lib/docstring.ml lib/table.ml lib/tag.ml lib/step.ml lib/pickle.ml
	ocamlfind opt -I lib/ -pack -package re,re.perl -o cucumber.cmx location.cmx docstring.cmx table.cmx tag.cmx step.cmx pickle.cmx lib.cmx

build_runtime: build_library
	ocamlfind ocamlc -g -I /home/cyocum/cucumber/gherkin/c/include -I /home/cyocum/cucumber/gherkin/c/src -c -cclib -lgherkin src/gherkin_intf.c 
	ocamlfind opt -I ./src -I ./lib  -g -package base,dynlink,re,re.perl -linkpkg -cclib '-Wl,--no-as-needed' -cclib -lgherkin -o cucumber_run cucumber.cmx gherkin_intf.o  src/gherkin.ml src/olympic.ml 

build_test: build_library
	ocamlfind opt -shared -I lib/ -package re,re.perl -linkpkg -o test.cmxs cucumber.cmx test/test.ml 

clean:
	rm src/*.cm* src/*.o src/*~ ./cucumber lib/*.cm* lib/*.o lib/*~ *.a *.o *.cm* ./cucumber_run

install_library:
	ocamlfind install cucumber META ./cucumber.cmx ./cucumber.cmi
