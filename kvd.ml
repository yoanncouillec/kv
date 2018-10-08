open Yojson.Basic.Util

let rec string_of_table_aux table min max i = 
  if i < max then
    ((if Hashtbl.mem table i then
        (string_of_int i) ^ "->" ^ (Hashtbl.find table i)^";"
      else "") ^
       string_of_table_aux table min max (i + 1))
  else ""

let string_of_table table min max = 
  "["^(string_of_table_aux table min max 0)^"]"

let treat table = function
  | Service.Create (k,v) ->
     Table.add table k v ;
     Table.show table
               
let rec receive table inc =
  let msg = Marshal.from_channel inc in
  treat table msg ; 
  receive table inc
          
let rec accept server table = 
  let inc, outc = Service.accept_client server in
  try
    receive table inc 
  with End_of_file -> 
    accept server table
           
let main = 
  let id = ref "kvd" in
  let conffile = ref "conf/conf.json" in
  let options =
    [
      ("--id", Arg.Set_string id, "id");
      ("--conf", Arg.Set_string conffile, "Configuration file");
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  print_endline ("Load configuration");
  let all_conf = Yojson.Basic.from_channel (open_in !conffile) in
  let jsconf = Conf.find_conf_by_id !id (all_conf |> member "kvd" |> to_list) in
  let conf = Conf.make_kvd_conf jsconf in
  let table = Table.create conf.size conf.min conf.max in
  let server = Service.create_server conf.port in
  accept server table
  
