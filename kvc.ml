let rec string_of_channel channel accu = 
  try
    let line = input_line channel in
    string_of_channel channel (accu^line)
  with
  | End_of_file -> accu

let expr_of_string s = 
  let lexbuf = Lexing.from_string s in
  Parser.start Lexer.token lexbuf

let expr_of_filename filename = 
  expr_of_string (string_of_channel (open_in filename) "")

let rec repl () = 
  print_string "> " ;
  let line = read_line () in
  let expr = expr_of_string line in
  print_endline (Sql.string_of_sqlexpr expr);
  repl()

let _ =
  repl()
