build_test: 
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base -thread -linkpkg -cclib -lgherkin-c -o cucumber_run test/test.ml

build_test_parallel:
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base,lwt,lwt.unix -thread -linkpkg -cclib -lgherkin-c -o cucumber_run test/test_parallel.ml

