let rand_chr () = (Char.chr (97 + (Random.int 26)))

let rec rand_word n = 
  if n == 0 then
    ""
  else
    (String.make 1 (rand_chr())) ^ (rand_word (n - 1))

let rec insert outc number min max= 
  if number > 0 then
    let k = min + (Random.int (max - min)) in
    let v = rand_word 8 in
    print_endline ((string_of_int k) ^ " " ^ v) ;
    Service.send outc (Service.Create (k, v)) ;
    insert outc (number - 1) min max
           
let main =
  let hostname = ref "127.0.0.1" in
  let port = ref 26100 in
  let number = ref 100 in
  let min = ref 0 in
  let max = ref 2000 in
  let options =
    [
      ("--number", Arg.Set_int number, "Number of document to insert");
      ("--min", Arg.Set_int min, "min");
      ("--max", Arg.Set_int max, "max");
      ("--host", Arg.Set_string hostname, "Hostname of the server");
      ("--port", Arg.Set_int port, "Port of the server");
    ] in
  Arg.parse options print_endline "Chat client:" ;
  let inc, outc = Service.connect_to_server !hostname !port in
  Random.self_init() ;
  insert outc !number !min !max

