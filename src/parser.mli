type token =
  | ER_INT of (int)
  | ER_IDENT of (string)
  | ER_STRING of (string)
  | LPAREN
  | RPAREN
  | EOF

val start :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Expr.expr
