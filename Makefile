PACKAGES=unix,yojson

all: kvd.out kvr.out test.out

kvd.out: log.cmx table.cmx service.cmx conf.cmx kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

kvr.out: log.cmx table.cmx service.cmx kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

test.out: log.cmx table.cmx service.cmx test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

%.cmx:%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES)

run:
	./kvd.out --id kvd1 &
	./kvd.out --id kvd2 &
	./kvr.out --port 26100 --conf conf/conf.json > kvr.log &

kill:
	killall kvd.out kvr.out

test:
	./test.out

clean:
	rm -rf *.out *.cm* *.o *~ _build *.log
