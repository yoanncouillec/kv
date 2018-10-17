PACKAGES=unix,yojson

all: bin/kvc.out bin/kvd.out bin/kvr.out bin/test.out bin/test_find.out

bin/kvc.out: lib/sql.cmx lib/parser.cmx lib/lexer.cmx lib/log.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvc.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/kvd.out: lib/log.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/kvr.out: lib/log.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/test.out: lib/log.cmx lib/table.cmx lib/service.cmx lib/test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

bin/test_find.out: lib/log.cmx lib/table.cmx lib/service.cmx lib/test_find.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

lib/lexer.cmx: src/lexer.ml

lib/parse.cmx: src/parser.ml

src/parser.ml: src/parser.mly lib/parser.cmi
	ocamlyacc $<

src/parser.mli: src/parser.mly
	ocamlyacc $^

src/lexer.ml: src/lexer.mll
	ocamllex $^ -o $@

lib/%.cmx:src/%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES) -I lib

lib/%.cmi: src/%.mli
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES) -I lib

run:
	./bin/kvd.out --id kvd1 &
	./bin/kvd.out --id kvd2 &
	./bin/kvr.out &

kill:
	killall kvd.out kvr.out

insert:
	./bin/test.out

biginsert:
	./bin/test.out --number 10000

verybiginsert:
	./bin/test.out --number 1000000

find:
	./bin/test_find.out

bigfind:
	./bin/test_find.out --number 10000

clean:
	rm -rf bin/*.out lib/*.cm* lib/*.o *~ _build *.log parser.mli parser.ml lexer.ml
