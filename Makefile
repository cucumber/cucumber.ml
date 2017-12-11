build:
	ocamlfind ocamlc -I /home/cyocum/cucumber/gherkin/c/include -I /home/cyocum/cucumber/gherkin/c/src -c -cclib -lgherkin src/gherkin_intf.c 
	ocamlfind opt -I ./src  -g -package base -linkpkg  -cclib '-Wl,--no-as-needed' -cclib -lgherkin -o cucumber gherkin_intf.o src/location.ml src/tag.ml src/pickle.ml src/gherkin.ml src/olympic.ml 

clean:
	rm src/*.cm* src/*.o src/*~
