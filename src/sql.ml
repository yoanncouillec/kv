type sqlexpr = 
  | Insert of int * string (* INSERT (123 'abc')*)
  | Select of int (* SELECT 123 *)
  | Count
  | Drop
  | Stop

let string_of_sqlexpr = function
  | Insert (k,v) -> "INSERT("^(string_of_int k)^", "^v^")"
  | Select (k) -> "SELECT "^(string_of_int k)
  | Count -> "COUNT"
  | Drop -> "DROP"
  | Stop -> "STOP"
