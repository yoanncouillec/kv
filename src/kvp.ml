open Yojson.Basic.Util
open Lwt
open Cohttp
open Cohttp_lwt_unix
open Yojson

(* x |> f == f x *)
(* >== == bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t *)
(* >|= == 'a Lwt.t -> ('a -> 'b) -> 'b Lwt.t *)

let expr_of_string s = 
  let lexbuf = Lexing.from_string s in
  Parser.start Lexer.token lexbuf

let json_ex = to_string(`Assoc[("name",`String "name")])

let send_command inc outc line =
  try
    let expr = expr_of_string line in
    Service.send outc expr ;
    let response = Service.receive inc in
    Table.string_of_response response
  with Parsing.Parse_error ->
        print_endline "Parsing error";
        "Parse Error"
     | Failure msg -> 
        print_endline ("Failure: "^msg);
        msg

let server inc outc port =
  let callback _conn req body =
    print_endline ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>";
    let uri = req |> Request.uri |> Uri.to_string in
    print_endline (uri);
    let meth = req |> Request.meth |> Code.string_of_method in
    print_endline (meth);
    let headers = req |> Request.headers |> Header.to_string in
    print_endline (headers);
    if meth = "OPTIONS" then
      (Server.respond_string 
        ~headers:(Cohttp.Header.of_list [("Origin","http://localhost:8765");
                                         ("Access-Control-Allow-Origin","*");
                                         ("Access-Control-Allow-Methods","POST");
                                         ("Access-Control-Allow-Headers","Content-Type")]) 
        ~status:`OK ~body:"" ())
    else
      (body |> Cohttp_lwt.Body.to_string >>= 
        (fun body -> 
          (*let body = Str.global_replace (Str.regexp_string "\\\"") "\"" body in*)
          print_endline(">>"^body^"<<");
          let jsquery = Yojson.Basic.from_string body in
          let command = jsquery |> member "command" |> Yojson.Basic.to_string in
          let command = String.sub command 1 ((String.length command) - 2) in
          let response = send_command inc outc command in
          Server.respond_string ~headers:(Cohttp.Header.of_list [("Access-Control-Allow-Origin","*")]) ~status:`OK ~body:response ()))
  in
  Server.create ~mode:(`TCP (`Port port)) (Server.make ~callback ())

let main =
  let id = ref "kvp" in
  let conffile = ref "/etc/kv/conf.json" in
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
  let inc, outc = Service.connect_to_server kvr.hostname kvr.port in
  let s = server inc outc kvp.port in
  Lwt_main.run s
    
