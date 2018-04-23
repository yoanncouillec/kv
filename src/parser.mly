%token<int> ER_INT
%token<string> ER_IDENT ER_STRING
%token LPAREN RPAREN EOF
%start start
%type <Expr.expr> start

%%

start: 
| expression EOF { $1 }

expressions:
| expression { [$1] }
| expression expressions { $1 :: $2 }

expression:
| ER_INT { Expr.EInt ($1) }
| ER_STRING { Expr.EString (String.sub ($1) 1 ((String.length $1) - 2)) }
| ER_IDENT { Expr.EVar ($1) }
| LPAREN expression expressions RPAREN { List.fold_left (fun a b -> Expr.EApp(a,b)) (Expr.EApp ($2, List.hd $3)) (List.tl $3)}
