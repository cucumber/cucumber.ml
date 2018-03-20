.PHONY: clean install_library

build_library:
	ocamlfind ocamlc -I lib/ -for-pack Cucumber -c -package re,re.perl lib/location.mli lib/docstring.mli lib/table.ml lib/step.mli lib/lib.mli
	ocamlfind opt -I lib/ -for-pack Cucumber -package re,re.perl -c lib/lib.ml lib/location.ml lib/docstring.ml lib/table.ml lib/tag.ml lib/step.ml lib/pickle.ml
	ocamlfind opt -I lib/ -pack -package re,re.perl -o cucumber.cmx location.cmx docstring.cmx table.cmx tag.cmx step.cmx pickle.cmx lib.cmx
	ocamlfind opt -I lib/ -pack -package re,re.perl -o cucumber.cmxa location.cmx docstring.cmx table.cmx tag.cmx step.cmx pickle.cmx lib.cmx

build_runtime:
	ocamlfind ocamlc -g -I /usr/include/gherkin -c -cclib -lgherkin src/gherkin_intf.c 
	ocamlfind opt -I ./src -g -package base,dynlink,re,re.perl,cucumber -linkpkg -linkall -cclib '-Wl,--no-as-needed' -cclib -lgherkin -o cucumber_run gherkin_intf.o  src/gherkin.ml src/olympic.ml 

build_test: 
	ocamlfind opt -shared -package re,re.perl,cucumber -linkpkg -o test.cmxs test/test.ml 

clean:
	rm src/*.cm* src/*.o src/*~ ./cucumber lib/*.cm* lib/*.o lib/*~ *.a *.o *.cm* ./cucumber_run

install_library: build_library
	ocamlfind remove cucumber
	ocamlfind install cucumber META ./cucumber.cmx ./cucumber.cmi ./cucumber.o ./cucumber.cmxa
	rm ./cucumber.cmx ./cucumber.cmi ./cucumber.o ./cucumber.cmxa
