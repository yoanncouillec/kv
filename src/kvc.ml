let rec repl inc outc = 
  print_string "> " ;
  flush stdout ;
  let lexbuf = Lexing.from_channel stdin in
  Expr.eval outc (Parser.start Lexer.token lexbuf) ;
  print_endline (Table.string_of_result (Marshal.from_channel inc)) ;
  repl inc outc

let main =
  let hostname = ref "127.0.0.1" in
  let port = ref 26100 in
  let options =
    [
      ("--host", Arg.Set_string hostname, "Hostname of the server");
      ("--port", Arg.Set_int port, "Port of the server");
    ] in
  Arg.parse options print_endline "Kv repl:" ;
  let inc, outc = Service.connect_to_server !hostname !port in
  repl inc outc
  
