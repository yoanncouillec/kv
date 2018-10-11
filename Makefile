PACKAGES=unix,yojson

all: kvd.out kvr.out test.out test_find.out

kvd.out: log.cmx table.cmx service.cmx conf.cmx kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

kvr.out: log.cmx table.cmx service.cmx conf.cmx kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

test.out: log.cmx table.cmx service.cmx test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

test_find.out: log.cmx table.cmx service.cmx test_find.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^


%.cmx:%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES)

run:
	./kvd.out --id kvd1 &
	./kvd.out --id kvd2 &
	./kvr.out &

kill:
	killall kvd.out kvr.out

insert:
	./test.out

biginsert:
	./test.out --number 10000

find:
	./test_find.out

bigfind:
	./test_find.out --number 10000

clean:
	rm -rf *.out *.cm* *.o *~ _build *.log
