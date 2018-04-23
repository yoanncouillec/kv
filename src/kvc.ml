let expr_of_filename filename = 
  let lexbuf = Lexing.from_channel stdin in
  Parser.start Lexer.token lexbuf

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
  print_string "> " ;
  
