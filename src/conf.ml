open Yojson.Basic.Util

type kvd_conf = {
    id : string;
    hostname : string;
    port : int;
    min : int;
    max : int;
    size : int;
    logfile : string;
    pidfile: string;
    fork: bool;
  }

type kvr_conf = {
    id : string;
    hostname : string;
    port : int;
    logfile : string;
    pidfile: string;
    fork: bool;
  }

type kvc_conf = {
    id : string;
    kvr_id : string;
    logfile : string;
  }

let find_conf_by_id id conf =
    List.hd (List.filter (fun c -> (c |> member "id" |> to_string) = id) conf)

let make_kvd_conf jsconf = 
  {
    id = jsconf |> member "id" |> to_string;
    hostname = jsconf |> member "hostname" |> to_string;
    port = jsconf |> member "port" |> to_int;
    min = jsconf |> member "min" |> to_int;
    max = jsconf |> member "max" |> to_int;
    size = jsconf |> member "size" |> to_int;
    logfile = jsconf |> member "logfile" |> to_string;
    pidfile = jsconf |> member "pidfile" |> to_string;
    fork = jsconf |> member "fork" |> to_bool;
  }

let make_kvr_conf jsconf = 
  {
    id = jsconf |> member "id" |> to_string;
    hostname = jsconf |> member "hostname" |> to_string;
    port = jsconf |> member "port" |> to_int;
    logfile = jsconf |> member "logfile" |> to_string;
    pidfile = jsconf |> member "pidfile" |> to_string;
    fork = jsconf |> member "fork" |> to_bool;
  }

let make_kvc_conf jsconf = 
  {
    id = jsconf |> member "id" |> to_string;
    kvr_id = jsconf |> member "kvr_id" |> to_string;
    logfile = jsconf |> member "logfile" |> to_string;
  }
