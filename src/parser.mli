type token =
  | ER_INT of (int)
  | ER_IDENT of (string)
  | ER_STRING of (string)
  | CREATE
  | READ
  | UPDATE
  | DELETE
  | LPAREN
  | RPAREN
  | EOF

val start :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Expr.expr
