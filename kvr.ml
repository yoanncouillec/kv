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
    conf
        
let rec string_of_table_aux table min max i = 
  if i < max then
    ((if Hashtbl.mem table i then
        (string_of_int i) ^ "->" ^ (Hashtbl.find table i)^";"
      else "") ^
       string_of_table_aux table min max (i + 1))
  else ""

let string_of_table table min max = 
  "["^(string_of_table_aux table min max 0)^"]"

let treat kvds = function
  | Service.Create (k,v) ->
     let kvd = List.hd 
                 (List.filter
                    (fun e -> e.min <= k && k < e.max)
                    kvds)
     in
     (*print_endline ((string_of_int k) ^ " " ^ v) ;*)
     Service.send kvd.outc (Service.Create (k, v))

let rec receive kvds inc =
  let msg = Marshal.from_channel inc in
  treat kvds msg ; 
  receive kvds inc

let rec accept server kvds = 
  let inc, outc = Service.accept_client server in
  try
    receive kvds inc 
  with End_of_file -> accept server kvds

let main = 
  let id = ref "kvr" in
  let conffile = ref "conf/conf.json" in
  let options =
    [
      ("--id", Arg.Set_string id, "id");
      ("--conf", Arg.Set_string conffile, "Configuration file");
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let all_conf = Yojson.Basic.from_file !conffile in
  let jsconf = Conf.find_conf_by_id !id (all_conf |> member "kvr" |> to_list) in
  let kvds_jsconf = all_conf |> member "kvd" |> to_list in
  let conf = Conf.make_kvr_conf jsconf in
  Log.init (open_out conf.logfile);
  let server = Service.create_server conf.port in
  accept server (kvds kvds_jsconf)
