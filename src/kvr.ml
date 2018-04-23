open Yojson.Basic.Util

type kvd = 
{
  hostname : string;
  port : int;
  min : int;
  max : int;
  inc : in_channel;
  outc : out_channel;
}

let kvds conf = 
  List.map
    (fun e -> 
      let hostname = e |> member "hostname" |> to_string in
      let port =  e |> member "port" |> to_int in
      let min =  e |> member "min" |> to_int in
      let max =  e |> member "max" |> to_int in
      let inc, outc = Service.connect_to_server hostname port in 
      {
        hostname  = hostname;
        port  = port;
        min  = min;
        max  = max;
        inc  = inc;
        outc  = outc;
      })
    (conf |> member "kvd" |> to_list)
        
let rec string_of_table_aux table min max i = 
  if i < max then
    ((if Hashtbl.mem table i then
        (string_of_int i) ^ "->" ^ (Hashtbl.find table i)^";"
      else "") ^
       string_of_table_aux table min max (i + 1))
  else ""

let string_of_table table min max = 
  "["^(string_of_table_aux table min max 0)^"]"

let get_kvd kvds k =
  List.hd 
    (List.filter
       (fun e -> e.min <= k && k < e.max)
       kvds)

let treat kvds = function
  | Service.Create (k,v) -> Service.send (get_kvd kvds k).outc (Service.Create (k, v))
  | Service.Read k -> Service.send (get_kvd kvds k).outc (Service.Delete k)
  | Service.Update (k,v) -> Service.send (get_kvd kvds k).outc (Service.Update (k, v))
  | Service.Delete k -> Service.send (get_kvd kvds k).outc (Service.Delete k)

let rec receive kvds inc outc =
  let msg = Marshal.from_channel inc in
  Service.send outc (treat kvds msg) ; 
  receive kvds inc outc

let rec accept server kvds = 
  let inc, outc = Service.accept_client server in
  try
    receive kvds inc outc
  with End_of_file -> accept server kvds

let main = 
  let port = ref 26100 in
  let conf = ref "kvr.json" in
  let options =
    [
      ("--port", Arg.Set_int port, "port");
      ("--conf", Arg.Set_string conf, "Configuration file");
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let conf = Yojson.Basic.from_file !conf in
  let server = Service.create_server !port in
  accept server (kvds conf)
