build_test: 
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base -linkpkg -cclib -lgherkin -o cucumber_run test/test.ml

build_test_parallel:
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base,lwt,lwt.unix -thread -linkpkg -cclib -lgherkin -o cucumber_run test/test_parallel.ml

