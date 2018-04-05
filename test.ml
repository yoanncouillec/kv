let main =
  let hostname = ref "127.0.0.1" in
  let port = ref 26000 in
  let options =
    [
      ("--host", Arg.Set_string hostname, "Hostname of the server");
      ("--port", Arg.Set_int port, "Port of the server");
    ] in
  Arg.parse options print_endline "Chat client:" ;
  let inc, outc = Service.connect_to_server !hostname !port in
  Service.send outc (Service.Create (12, "coucou")) ;
  Service.send outc (Service.Create (13, "toutou"))
