let rand_chr () = (Char.chr (97 + (Random.int 26)))

let rec rand_word n = 
  if n == 0 then
    ""
  else
    (String.make 1 (rand_chr())) ^ (rand_word (n - 1))

let rec quick_rand_word n = 
    String.make n (rand_chr())

let rec insert outc number min max size = 
  if number > 0 then
    let k = min + (Random.int (max - min)) in
    let v = quick_rand_word size in
    (*print_endline ((string_of_int k) ^ " " ^ v) ;*)
    let _ = Service.send outc (Service.Create (k, v)) in
    insert outc (number - 1) min max size
           
let main =
  let hostname = ref "127.0.0.1" in
  let port = ref 26100 in
  let number = ref 1000000 in
  let min = ref 0 in
  let max = ref 2000 in
  let size = ref 1024 in
  let options =
    [
      ("--size", Arg.Set_int size, "Size of each document");
      ("--number", Arg.Set_int number, "Number of document to insert");
      ("--min", Arg.Set_int min, "min");
      ("--max", Arg.Set_int max, "max");
      ("--host", Arg.Set_string hostname, "Hostname of the server");
      ("--port", Arg.Set_int port, "Port of the server");
    ] in
  Arg.parse options print_endline "Chat client:" ;
  let inc, outc = Service.connect_to_server !hostname !port in
  Random.self_init() ;
  print_endline("Test[size="^(string_of_int !size)^",number="^(string_of_int !number)^",min="^(string_of_int !min)^",max="^(string_of_int !max)^",host="^(!hostname)^",port="^(string_of_int !port)^"]");
  let start = Unix.gettimeofday() in
  insert outc !number !min !max !size ;
  let stop = Unix.gettimeofday() in
  let total = stop -. start in
  let tps = (float_of_int !number) /. total in
  print_endline ("Total time: "^(string_of_float total)^"s") ;
  print_endline ("Tps: "^(string_of_float tps)^"tps")

