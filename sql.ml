type sqlexpr = 
  | Insert of int * string (* INSERT (123 'abc')*)
  | Select of int (* SELECT 123 *)

