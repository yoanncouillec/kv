all:
	ocamlfind ocamlopt -o kvd.out -package unix -linkpkg service.ml kvd.ml
	ocamlfind ocamlopt -o test.out -package unix -linkpkg service.ml test.ml

clean:
	rm -rf *.out *.cm* *.o *~ _build
