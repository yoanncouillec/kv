{
  open Parser
}
rule token = parse
  | eof { EOF }
  | [' ' '\t' '\n'] { token lexbuf }
  | '(' { LPAREN }
  | ')' { RPAREN }
  | ',' { COMMA }
  | "INSERT" { INSERT }
  | "SELECT" { SELECT }
  | "COUNT" { COUNT }
  | "DROP" { DROP }
  | "STOP" { STOP }
  | ('\''|'\"') (('\\' _) | [^'\''])* ('\''|'\"') { ER_STRING (Lexing.lexeme lexbuf) }
  | ['0'-'9']+ { ER_INT (int_of_string (Lexing.lexeme lexbuf)) }

