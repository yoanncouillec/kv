let rec string_of_table_aux table min max i = 
  if i < max then
    ((if Hashtbl.mem table i then
        (string_of_int i) ^ "->" ^ (Hashtbl.find table i)^";"
      else "") ^
       string_of_table_aux table min max (i + 1))
  else ""

let string_of_table table min max = 
  "["^(string_of_table_aux table min max 0)^"]"

let main = 
  (*let conf = ref "conf/conf.yml" in*)
  let port = ref 26000 in
  let min = ref 0 in
  let max = ref 1000 in
  let options =
    [
      ("--port", Arg.Set_int port, "port");
      ("--min", Arg.Set_int min, "min");
      ("--max", Arg.Set_int max, "max");
    (*("--conf", Arg.Set_string conf, "Configuration file");*)
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let table = Hashtbl.create (!max - !min) in
  let server = Service.create_server !port in
  let inc, outc = Service.accept_client server in
  while true do
    match Marshal.from_channel inc with
    | Service.Create (i,d) ->
       print_endline("create");
       (if i < !min || !max < i then
          failwith "Out of bounds"
        else
          (if Hashtbl.mem table i then
             failwith "Already exists"
           else
             (Hashtbl.add table i d ;
              print_endline (string_of_table table 0 1000))))
  done



  (* let conf = Yaml.of_string (read_file (open_in !conf) "") in
   * match conf with
   * | Result.Ok v ->
   *    (match v with
   *     | Yaml.String s ->
   *        print_string s) *)



(* let rec read_file inc acc =
 *   try
 *     let c = input_char inc in
 *     read_file inc (acc^(String.make 1 c))
 *   with 
 *     End_of_file ->
 *      acc *)

