open Yojson.Basic.Util

type kvd_conf = {
    id : string;
    hostname : string;
    port : int;
    min : int;
    max : int;
    size : int;
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
  }

