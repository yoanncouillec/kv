all:
	ocamlfind ocamlopt -o kvd.out -package unix -linkpkg table.ml service.ml kvd.ml
	ocamlfind ocamlopt -o kvr.out -package unix,yojson -linkpkg table.ml service.ml kvr.ml
	ocamlfind ocamlopt -o test.out -package unix -linkpkg service.ml test.ml

start:
	./kvd.out --port 26000 --min 0 --max 1000 --size 100 > kvd1.log &
	echo $$ > kvd1.pid
	./kvd.out --port 26001 --min 1000 --max 2000 --size 100 > kvd2.log &
	echo $$ > kvd2.pid
	./kvr.out --port 26100 --conf kvr.json > kvr.log &
	echo $$ > kvr.pid

stop:
	killall kvd.out kvr.out

test:
	./test.out

clean:
	rm -rf *.out *.cm* *.o *~ _build
