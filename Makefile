PACKAGES=unix,yojson

all: kvd.out kvr.out test.out

kvd.out: table.cmx service.cmx kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

kvr.out: table.cmx service.cmx kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

test.out: table.cmx service.cmx test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

%.cmx:%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES)

start:
	./kvd.out --port 26000 --min 0 --max 1000 --size 100 > kvd1.log &
	./kvd.out --port 26001 --min 1000 --max 2000 --size 100 > kvd2.log &
	./kvr.out --port 26100 --conf kvr.json > kvr.log &

kill:
	killall kvd.out kvr.out

test:
	./test.out

clean:
	rm -rf *.out *.cm* *.o *~ _build *.log
