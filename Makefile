all:
	ocamlfind ocamlopt -o kvd.out -package unix -linkpkg table.ml service.ml kvd.ml
	ocamlfind ocamlopt -o kvr.out -package unix,yojson -linkpkg table.ml service.ml kvr.ml
	ocamlfind ocamlopt -o test.out -package unix -linkpkg service.ml test.ml

clean:
	rm -rf *.out *.cm* *.o *~ _build
