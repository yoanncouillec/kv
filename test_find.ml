let rec find kvr_inc kvr_outc number min max = 
  if number > 0 then
    let k = min + (Random.int (max - min)) in
    let msg = Service.Read (k) in
    Service.send kvr_outc msg ;
    print_endline ((Service.string_of_message msg) ^
                     " => "^Table.string_of_response (Service.receive kvr_inc));
    find kvr_inc kvr_outc (number - 1) min max
           
let main =
  let hostname = ref "127.0.0.1" in
  let port = ref 26100 in
  let number = ref 100 in
  let min = ref 0 in
  let max = ref 2000 in
  let options =
    [
      ("--number", Arg.Set_int number, "Number of document to find");
      ("--min", Arg.Set_int min, "min");
      ("--max", Arg.Set_int max, "max");
      ("--host", Arg.Set_string hostname, "Hostname of the server");
      ("--port", Arg.Set_int port, "Port of the server");
    ] in
  Arg.parse options print_endline "Chat client:" ;
  let kvr_inc, kvr_outc = Service.connect_to_server !hostname !port in
  Random.self_init() ;
  print_endline("Test[number="^(string_of_int !number)^",min="^(string_of_int !min)^",max="^(string_of_int !max)^",host="^(!hostname)^",port="^(string_of_int !port)^"]");
  let start = Unix.gettimeofday() in
  find kvr_inc kvr_outc !number !min !max ;
  let stop = Unix.gettimeofday() in
  let total = stop -. start in
  let tps = (float_of_int !number) /. total in
  print_endline ("Total time: "^(string_of_float total)^"s") ;
  print_endline ("Tps: "^(string_of_float tps)^"tps")

