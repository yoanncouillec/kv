PACKAGES=unix,yojson
KVP_PACKAGES=unix,yojson,cohttp-lwt-unix,str

bin: bin/kvc bin/kvp bin/kvd bin/kvr

bin_test:  bin/test bin/test_find

bin/kvc: lib/sql.cmx lib/parser.cmx lib/lexer.cmx lib/log.cmx lib/table.cmx lib/service.cmx lib/kvconf.cmx lib/kvc.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^ 

bin/kvp: lib/sql.cmx lib/parser.cmx lib/lexer.cmx lib/log.cmx lib/table.cmx lib/service.cmx lib/kvconf.cmx lib/kvp.cmx
	ocamlfind ocamlopt -o $@ -package $(KVP_PACKAGES) -linkpkg $^ -thread

bin/kvd: lib/log.cmx lib/fork.cmx lib/table.cmx lib/service.cmx lib/kvconf.cmx lib/kvd.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^ 

bin/kvr: lib/log.cmx lib/fork.cmx lib/table.cmx lib/service.cmx lib/kvconf.cmx lib/kvr.cmx
	ocamlfind ocamlopt -o $@ -package $(PACKAGES) -linkpkg $^  -thread

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

lib/kvp.cmx:src/kvp.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(KVP_PACKAGES) -I lib -thread

lib/%.cmx:src/%.ml
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES) -I lib -thread

lib/%.cmi: src/%.mli
	ocamlfind ocamlopt -c $^ -o $@ -package $(PACKAGES) -I lib

start:
	kvd --id kvd1
	kvd --id kvd2
	kvr

stop:
	kill `cat /var/run/kv/*.pid`

api:
	./bin/kvp

client:
	./bin/kvc

install:
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

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

test_api:
	curl --header "Content-Type: application/json" --request POST --data '{"command":"COUNT"}' "http://localhost:8765"
	curl --header "Content-Type: application/json" --request POST --data '{"command":"SELECT 14"}' "http://localhost:8765"

clean:
	rm -rf bin/* lib/*.cm* lib/*.o *~ _build *.log src/parser.mli src/parser.ml src/lexer.ml pid/* log/*
