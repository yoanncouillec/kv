%token<int> ER_INT
%token<string> ER_STRING
%token LPAREN RPAREN COMMA EOF
%token INSERT SELECT
%start start
%type <Sql.sqlexpr> start

%%

start: 
| expression EOF { $1 }
expression:
| INSERT LPAREN ER_INT COMMA ER_STRING RPAREN {  
	   Sql.Insert($3,(String.sub ($5) 1 ((String.length $5) - 2)))
	 }
| SELECT ER_INT { Sql.Select $2 }

