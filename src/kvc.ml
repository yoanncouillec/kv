open Yojson.Basic.Util

let rec string_of_channel channel accu = 
  try
    let line = input_line channel in
    string_of_channel channel (accu^line)
  with
  | End_of_file -> accu

let expr_of_string s = 
  let lexbuf = Lexing.from_string s in
  Parser.start Lexer.token lexbuf

let expr_of_filename filename = 
  expr_of_string (string_of_channel (open_in filename) "")

let rec repl inc outc =
  try
    Log.info "Repl";
    print_string "> " ;
    let line = read_line () in
    let expr = expr_of_string line in
    (*print_endline (Sql.string_of_sqlexpr expr);*)
    Service.send outc expr ;
    let response = Service.receive inc in
    print_endline (Table.string_of_response response) ;
    repl inc outc
  with
  | End_of_file -> print_endline "\nSee you!"

let main =
  let id = ref "kvc" in
  let conffile = ref "conf/conf.json" in
  let options =
    [
      ("--id", Arg.Set_string id, "id");
      ("--conf", Arg.Set_string conffile, "Configuration file");
    ] in
  Arg.parse options (fun _ -> ()) "Options:";
  let all_conf = Yojson.Basic.from_channel (open_in !conffile) in
  let kvc_jsconf = Conf.find_conf_by_id !id (all_conf |> member "kvc" |> to_list) in
  let kvc = Conf.make_kvc_conf kvc_jsconf in
  let kvr_jsconf = Conf.find_conf_by_id kvc.kvr_id (all_conf |> member "kvr" |> to_list) in
  let kvr = Conf.make_kvr_conf kvr_jsconf in
  Log.init (open_out kvc.logfile);
  Log.info ("Load configuration");
  let inc, outc = Service.connect_to_server kvr.hostname kvr.port in 
  repl inc outc
