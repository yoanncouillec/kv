%token<int> ER_INT
%token<string> ER_STRING
%token LPAREN RPAREN COMMA EOF
%token INSERT SELECT COUNT
%start start
%type <Sql.sqlexpr> start

%%

start: 
| expression EOF { $1 }

expression:
| INSERT ER_INT ER_STRING {  
	   Sql.Insert($2,(String.sub ($3) 1 ((String.length $3) - 2)))
	 }
| SELECT ER_INT { Sql.Select $2 }
| COUNT { Sql.Count }
