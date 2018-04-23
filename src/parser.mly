%token<int> ER_INT
%token<string> ER_IDENT ER_STRING
%token CREATE READ UPDATE DELETE
%token LPAREN RPAREN EOF
%start start
%type <Expr.expr> start

%%

start: 
| expression { $1 }

expressions:
| expression { [$1] }
| expression expressions { $1 :: $2 }

expression:
| ER_INT { Expr.EInt ($1) }
| ER_STRING { Expr.EString (String.sub ($1) 1 ((String.length $1) - 2)) }
| LPAREN CREATE expression expression RPAREN { Expr.ECreate ($3, $4)}
| LPAREN READ expression RPAREN { Expr.ERead $3}
| LPAREN UPDATE expression expression RPAREN { Expr.EUpdate ($3, $4)}
| LPAREN DELETE expression RPAREN { Expr.EDelete $3}
