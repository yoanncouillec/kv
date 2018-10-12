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
     Table.add table k v
  | Service.Read (k) ->
     Table.get table k
  | Service.Count ->
     Table.count table
               
let rec receive table client_inc client_outc =
  let msg = Marshal.from_channel client_inc in
  Service.send client_outc (treat table msg) ; 
  Table.show table ;
  receive table client_inc client_outc
          
let rec accept server table = 
  let client_inc, client_outc = Service.accept_client server in
  try
    receive table client_inc client_outc 
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
  let all_conf = Yojson.Basic.from_channel (open_in !conffile) in
  let jsconf = Conf.find_conf_by_id !id (all_conf |> member "kvd" |> to_list) in
  let conf = Conf.make_kvd_conf jsconf in
  Log.init (open_out conf.logfile);
  Log.info ("Load configuration");
  let table = Table.create conf.size conf.min conf.max in
  let server = Service.create_server conf.port in
  accept server table
  
