PACKAGES=unix,yojson

all: kvc.out kvd.out kvr.out test.out test_find.out

kvc.out: sql.cmx parser.cmx lexer.cmx log.cmx table.cmx service.cmx conf.cmx kvc.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

kvd.out: log.cmx table.cmx service.cmx conf.cmx kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

kvr.out: log.cmx table.cmx service.cmx conf.cmx kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

test.out: log.cmx table.cmx service.cmx test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

test_find.out: log.cmx table.cmx service.cmx test_find.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

lexer.cmx: lexer.ml

parse.cmx: parser.ml

parser.ml: parser.mly parser.cmi
	ocamlyacc $<

parser.mli: parser.mly
	ocamlyacc $^

lexer.ml: lexer.mll
	ocamllex $^

%.cmx:%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES)

%.cmi: %.mli
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

verybiginsert:
	./test.out --number 1000000

find:
	./test_find.out

bigfind:
	./test_find.out --number 10000

clean:
	rm -rf *.out *.cm* *.o *~ _build *.log parser.mli parser.ml lexer.ml
