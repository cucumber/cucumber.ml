build_test: 
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base -thread -linkpkg -cclib -lgherkin-c -o cucumber_run test/test.ml

build_test_concurrent:
	ocamlfind opt -g -package re,re.perl,cmdliner,cucumber,base,lwt,lwt.unix -thread -linkpkg -cclib -lgherkin-c -o cucumber_run test/test_concurrent.ml

clean:
	rm test/*.cm* test/*.o test/*~
