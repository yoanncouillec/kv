all: bin/kvd.out bin/kvr.out bin/kvc.out bin/test.out

bin/kvd.out: obj/service.cmo obj/table.cmo obj/kvd.cmo
	ocamlfind ocamlc -o $@ -package unix,yojson -linkpkg $^

bin/kvr.out: obj/service.cmo obj/kvr.cmo
	ocamlfind ocamlc -o $@ -package unix,yojson -linkpkg $^

bin/kvc.out:obj/table.cmo obj/service.cmo obj/expr.cmo obj/parser.cmo obj/lexer.cmo obj/kvc.cmo
	ocamlfind ocamlc -o $@ -package unix,yojson -linkpkg $^

bin/test.out: obj/service.cmo obj/lexer.cmo obj/parser.cmo obj/test.cmo
	ocamlfind ocamlc -o $@ -package unix,yojson -linkpkg $^

obj/parser.cmo:src/parser.ml obj/parser.cmi
	ocamlfind ocamlc -c -o $@ -package unix,yojson -I obj $<

obj/lexer.cmo:src/lexer.ml
	ocamlfind ocamlc -c -o $@ -package unix,yojson -I obj $<

obj/%.cmo:src/%.ml
	ocamlfind ocamlc -c -o $@ -package unix,yojson -I obj $^

obj/%.cmi:src/%.mli
	ocamlfind ocamlc -c -o $@ -package unix,yojson -I obj $^

src/lexer.ml:src/lexer.mll
	ocamllex src/lexer.mll	

src/parser.ml:src/parser.mly
	ocamlyacc src/parser.mly

start:
	./bin/kvd.out --port 26000 --min 0 --max 1000 --size 100 > log/kvd1.log &
	echo $$ > kvd1.pid
	./bin/kvd.out --port 26001 --min 1000 --max 2000 --size 100 > log/kvd2.log &
	echo $$ > kvd2.pid
	./bin/kvr.out --port 26100 --conf conf/kvr.json > log/kvr.log &
	echo $$ > kvr.pid

stop:
	killall ocamlrun

test:
	./test.out

clean:
	rm -rf _build bin/*.out obj/*.cm* obj/*.o src/parser.ml src/lexer.ml

mrproper: clean
	rm -rf *~
