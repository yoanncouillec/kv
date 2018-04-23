open Service

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
  | Service.Create (k,v) -> Table.create table k v
  | Service.Read k -> Table.read table k
  | Service.Update (k,v) -> Table.update table k v
  | Service.Delete k -> Table.delete table k

let rec receive table inc outc =
  let msg = Marshal.from_channel inc in
  Service.send outc (treat table msg) ; 
  receive table inc outc

let rec accept server table = 
  let inc, outc = Service.accept_client server in
  try
    receive table inc outc 
  with End_of_file -> accept server table

let main = 
  let port = ref 26000 in
  let min = ref 0 in
  let max = ref 1000 in
  let size = ref 100 in
  let options =
    [
      ("--port", Arg.Set_int port, "port");
      ("--min", Arg.Set_int min, "min");
      ("--max", Arg.Set_int max, "max");
      ("--size", Arg.Set_int size, "size");
    (*("--conf", Arg.Set_string conf, "Configuration file");*)
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let table = Table.make !size !min !max in
  let server = Service.create_server !port in
  accept server table
  
