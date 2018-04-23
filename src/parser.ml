type token =
  | ER_INT of (int)
  | ER_IDENT of (string)
  | ER_STRING of (string)
  | LPAREN
  | RPAREN
  | EOF

open Parsing;;
let _ = parse_error;;
let yytransl_const = [|
  260 (* LPAREN *);
  261 (* RPAREN *);
    0 (* EOF *);
    0|]

let yytransl_block = [|
  257 (* ER_INT *);
  258 (* ER_IDENT *);
  259 (* ER_STRING *);
    0|]

let yylhs = "\255\255\
\001\000\003\000\003\000\002\000\002\000\002\000\002\000\000\000"

let yylen = "\002\000\
\002\000\001\000\002\000\001\000\001\000\001\000\004\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\004\000\006\000\005\000\000\000\008\000\000\000\
\000\000\001\000\000\000\000\000\003\000\007\000"

let yydgoto = "\002\000\
\007\000\011\000\012\000"

let yysindex = "\005\000\
\000\255\000\000\000\000\000\000\000\000\000\255\000\000\007\000\
\000\255\000\000\000\255\003\255\000\000\000\000"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\004\255\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\255\255\001\000"

let yytablesize = 12
let yytable = "\008\000\
\003\000\004\000\005\000\006\000\009\000\001\000\010\000\014\000\
\002\000\000\000\000\000\013\000"

let yycheck = "\001\000\
\001\001\002\001\003\001\004\001\006\000\001\000\000\000\005\001\
\005\001\255\255\255\255\011\000"

let yynames_const = "\
  LPAREN\000\
  RPAREN\000\
  EOF\000\
  "

let yynames_block = "\
  ER_INT\000\
  ER_IDENT\000\
  ER_STRING\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expression) in
    Obj.repr(
# 10 "src/parser.mly"
                 ( _1 )
# 76 "src/parser.ml"
               : Expr.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expression) in
    Obj.repr(
# 13 "src/parser.mly"
             ( [_1] )
# 83 "src/parser.ml"
               : 'expressions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'expression) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expressions) in
    Obj.repr(
# 14 "src/parser.mly"
                         ( _1 :: _2 )
# 91 "src/parser.ml"
               : 'expressions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 17 "src/parser.mly"
         ( Expr.EInt (_1) )
# 98 "src/parser.ml"
               : 'expression))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 18 "src/parser.mly"
            ( Expr.EString (String.sub (_1) 1 ((String.length _1) - 2)) )
# 105 "src/parser.ml"
               : 'expression))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 19 "src/parser.mly"
           ( Expr.EVar (_1) )
# 112 "src/parser.ml"
               : 'expression))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : 'expression) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expressions) in
    Obj.repr(
# 20 "src/parser.mly"
                                       ( List.fold_left (fun a b -> Expr.EApp(a,b)) (Expr.EApp (_2, List.hd _3)) (List.tl _3))
# 120 "src/parser.ml"
               : 'expression))
(* Entry start *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let start (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Expr.expr)
