{
  open Parser
}
rule token = parse
  | eof { EOF }
  | [' ' '\t' '\n'] { token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | '\"' ('\\'* | [^'\"'])* '\"' { ER_STRING (Lexing.lexeme lexbuf) }
  | ['0'-'9']+ { ER_INT (int_of_string (Lexing.lexeme lexbuf)) }
  | ['A'-'Z''a'-'z''<''/']['A'-'Z''a'-'z''+''-''*''/''#''-''@''{'']''*''&''%''$''!''?''_''0'-'9''>''.']* { ER_IDENT (Lexing.lexeme lexbuf) }
