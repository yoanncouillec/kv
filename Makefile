PACKAGES=unix,yojson

all: bin/kvc bin/kvd bin/kvr bin/test bin/test_find

bin/kvc: lib/sql.cmx lib/parser.cmx lib/lexer.cmx lib/log.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvc.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/kvd: lib/log.cmx lib/fork.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/kvr: lib/log.cmx lib/fork.cmx lib/table.cmx lib/service.cmx lib/conf.cmx lib/kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^	

bin/test: lib/log.cmx lib/fork.cmx lib/table.cmx lib/service.cmx lib/test.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^

bin/test_find: lib/log.cmx lib/table.cmx lib/service.cmx lib/test_find.cmx
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
	./bin/kvd --id kvd1
	./bin/kvd --id kvd2
	./bin/kvr

client:
	./bin/kvc

kill:
	killall kvd kvr

insert:
	./bin/test

biginsert:
	./bin/test --number 10000 --logfile log/test_biginsert.log

verybiginsert:
	./bin/test --number 1000000 --fork

find:
	./bin/test_find

bigfind:
	./bin/test_find --number 10000

clean:
	rm -rf bin/* lib/*.cm* lib/*.o *~ _build *.log src/parser.mli src/parser.ml src/lexer.ml pid/* log/*
