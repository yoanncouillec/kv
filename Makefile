all:
	ocamlfind ocamlc -c -o obj/table.cmo -package unix src/table.ml 
	ocamlfind ocamlc -c -o obj/service.cmo -package unix src/service.ml 
	ocamlfind ocamlc -c -o obj/kvd.cmo -package unix -I src src/kvd.ml
	ocamlfind ocamlc -c -o obj/kvr.cmo -package unix,yojson -I src src/kvr.ml
	ocamlfind ocamlc -c -o obj/test.cmo -package unix -I src src/test.ml 
	ocamlfind ocamlc -c -o obj/expr.cmo -package unix -I src src/expr.ml 
	ocamllex src/lexer.mll
	ocamlyacc src/parser.mly
	ocamlfind ocamlc -c -o obj/parser.cmi -package unix -I src src/parser.mli
	ocamlfind ocamlc -c -o obj/parser.cmo -package unix -I src src/parser.ml 
	ocamlfind ocamlc -c -o obj/lexer.cmo -package unix -I src src/lexer.ml 
	ocamlfind ocamlc -c -o obj/kvc.cmo -package unix -I src src/kvc.ml 

repl: table.cmo service.cmo parser.cmi parser.cmo lexer.cmo repl.cmo
	ocamlc -o $@ simple.cmo parser.cmo lexer.cmo repl.cmo

%.cmi: %.mli
	ocamlc $^

.SUFFIXES: .mll .mly .mli .ml .cmi .cmo .cmx

.mll.mli:
	ocamllex $<

.mll.ml:
	ocamllex $<

.mly.mli:
	ocamlyacc $<

.mly.ml:
	ocamlyacc $<

.mli.cmi:
	ocamlc -c $^

.ml.cmo:
	ocamlc -c $^











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

mrproper: clean
	rm -rf *~
