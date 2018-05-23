build_test: 
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base -linkpkg -cclib -lgherkin -o cucumber_run test/test.ml 

