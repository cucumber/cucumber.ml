(lang dune 2.6)
(version 2.0.0)
(name cucumber)

(generate_opam_files true)

(source (github cucumber/cucumber.ml))
(license MIT)
(authors "Christopher Guy Yocum")
(maintainers "cyocum@gmail.com")

(package
	(name cucumber)
	(synopsis "Cucumber BDD for OCaml")
	(description "Cucumber BDD for OCaml using the gherkin-c library to parse")
	(depends
	 (dune (>= 2.6))
	 (re (>= 1.9.0))
	 (base (>= v0.14.0))
	 (cmdliner (>= 1.0.4))))
	 