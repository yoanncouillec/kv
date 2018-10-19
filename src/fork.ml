let start f pidfile fork = 
  if fork then
    match Unix.fork() with
    | 0 -> f()
    | pid -> 
       let cout = open_out pidfile in
       Log.info ("PID "^(string_of_int pid));
       output_string cout ((string_of_int pid)^"\n");
       close_out cout
  else
    f()

