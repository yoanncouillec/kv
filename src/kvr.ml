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

let treat kvds msg =
    Log.nil ("kvr treat") ;
    match msg with
  | Service.Create (k,v) ->
     Log.nil ("kvr treat create") ;
       (try
          let kvd = 
            List.hd 
              (List.filter
                 (fun e -> e.min <= k && k < e.max)
                 kvds)
          in
          Service.send kvd.outc (Service.Create (k, v));
          Service.receive kvd.inc
        with
        | Failure m ->
           let msg = "kvr: key ("^(string_of_int k)^") is out of bounds" in
           Log.error msg ;
           Table.Fail (msg))
  | Service.Read (k) ->
     Log.nil ("kvr treat read") ;
     let kvd = List.hd 
                 (List.filter
                    (fun e -> e.min <= k && k < e.max)
                    kvds)
     in
     Service.send kvd.outc (Service.Read (k));
     Service.receive kvd.inc
  | Service.Count ->
     Log.nil ("kvr treat count") ;
     let total = 
       List.fold_left 
         (fun a kvd ->
           Service.send kvd.outc (Service.Count) ;
           match Service.receive kvd.inc with
           | Table.Count n -> a + n
           | _ -> failwith "expected count response")
         0 kvds in
     Table.Count total
  | Service.Drop ->
     Log.nil ("kvr treat drop") ;
     let total = 
       List.fold_left 
         (fun a kvd ->
           Service.send kvd.outc (Service.Drop) ;
           match Service.receive kvd.inc with
           | Table.Count n -> a + n
           | _ -> failwith "expected count response")
         0 kvds in
     Table.Count total
  | Service.Stop ->
     let total = 
       List.fold_left 
         (fun a kvd ->
           Service.send kvd.outc (Service.Stop) ;
           match Service.receive kvd.inc with
           | Table.Stopped n ->
              Log.info "kvd stopped" ;
              a + n
           | _ -> failwith "expected stopped response")
         0 kvds in
     Table.Stopped (total)
     

let rec receive kvds client_inc client_outc =
  Log.nil ("kvr receive") ;
  let msg = Marshal.from_channel client_inc in
  let response = treat kvds msg in
  Log.nil ("kvr receive got response") ;
  Log.nil (Table.string_of_response response);
  Service.send client_outc response ;
  match response with
  | Table.Stopped n ->
     Log.info (Table.string_of_response response)
  | _ ->
     receive kvds client_inc client_outc

let rec accept server kvds = 
  Log.info ("kvr accept") ;
  let client_inc, client_outc = Service.accept_client server in
  try
    receive kvds client_inc client_outc ;
    Unix.close server
  with End_of_file -> accept server kvds

let start logfile port kvds_jsconf = 
  Log.init (open_out logfile);
  let server = Service.create_server port in
  accept server (kvds kvds_jsconf)

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
  let jsconf = Kvconf.find_conf_by_id !id (all_conf |> member "kvr" |> to_list) in
  let kvds_jsconf = all_conf |> member "kvd" |> to_list in
  let conf = Kvconf.make_kvr_conf jsconf in
  Fork.start
    (fun () -> start conf.logfile conf.port kvds_jsconf)
    conf.pidfile
    conf.fork
