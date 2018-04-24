.PHONY: clean install_library

build_library:
	ocamlfind opt -g -I /usr/include/gherkin -I lib/ -cclib -lgherkin -o lib/gherkin_intf.o lib/gherkin_intf.c 
	ocamlfind opt -c -I lib/ -for-pack Cucumber -package re,re.perl,base -c lib/location.mli lib/location.ml lib/docstring.mli lib/table.ml lib/step.mli lib/outcome.mli lib/tag.mli lib/pickle.mli lib/report.mli lib/lib.mli
	ocamlfind opt -c -I lib/ -for-pack Cucumber -package re,re.perl,base -c lib/docstring.ml lib/table.ml lib/tag.ml lib/step.ml lib/pickle.ml lib/outcome.ml lib/report.ml lib/lib.ml
	ocamlfind opt -I lib/ -pack -package re,re.perl,base -o cucumber.cmx -cclib '-Wl,--no-as-needed' -cclib -lgherkin gherkin_intf.o location.cmx docstring.cmx table.cmx tag.cmx step.cmx pickle.cmx outcome.cmx report.cmx lib.cmx

build_test: 
	ocamlfind opt -g -package re,re.perl,cucumber,base -linkpkg -cclib -lgherkin -o cucumber_run test/test.ml 

clean:
	ocamlfind remove cucumber
	rm src/*.cm* src/*.o src/*~ ./cucumber lib/*.cm* lib/*.o lib/*~ *.a *.o *.cm* ./cucumber_run


install_library: build_library
	ocamlfind install cucumber META ./cucumber.cmi ./cucumber.o ./cucumber.cmx ./gherkin_intf.o
	rm ./cucumber.cmx ./cucumber.cmi ./cucumber.o ./gherkin_intf.o
