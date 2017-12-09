build:
	ocamlfind opt -g -safe-string -package base,ctypes -linkpkg -cclib -lgherkin -cclib '-Wl,--no-as-needed' src/fileReader.ml src/olympic.ml

clean:
	rm src/*.cm* src/*.o src/*~
