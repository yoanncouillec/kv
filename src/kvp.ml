open Yojson.Basic.Util
open Lwt
open Cohttp
open Cohttp_lwt_unix

(* x |> f == f x *)
(* >== == bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t *)
(* >|= == 'a Lwt.t -> ('a -> 'b) -> 'b Lwt.t *)

let server port =
  let callback _conn req body =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    body |> Cohttp_lwt.Body.to_string >>= (fun body -> Server.respond_string ~status:`OK ~body ())
  in
  Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ())

let main =
  let id = ref "kvp" in
  let conffile = ref "conf/conf.json" in
  let options =
    [
      ("--id", Arg.Set_string id, "id");
      ("--conf", Arg.Set_string conffile, "Configuration file");
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let all_conf = Yojson.Basic.from_channel (open_in !conffile) in
  let kvp_jsconf = Kvconf.find_conf_by_id !id (all_conf |> member "kvp" |> to_list) in
  let kvp = Kvconf.make_kvp_conf kvp_jsconf in
  let kvr_jsconf = Kvconf.find_conf_by_id kvp.kvr_id (all_conf |> member "kvr" |> to_list) in
  let kvr = Kvconf.make_kvr_conf kvr_jsconf in
  Log.init (open_out kvp.logfile);
  Log.info ("Load configuration");
  (*let inc, outc = Service.connect_to_server kvr.hostname kvr.port in *)
  let s = server kvp.port in
  Lwt_main.run s
    
