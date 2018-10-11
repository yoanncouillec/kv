type table = 
{
  hashtbl : (int,int * string) Hashtbl.t;
  size : int;
  min : int;
  max : int
}

let create size min max = 
  {
    hashtbl = Hashtbl.create size;
    size = size;
    min = min;
    max = max
  }
    
type response = 
  | Inserted of int
  | Found of string
  | FoundMany of int
  | NotFound of int
  | Fail of string

let string_of_response = function
  | Inserted b -> "Inserted("^(string_of_int b)^")"
  | Found v -> "Found("^v^")"
  | FoundMany n -> "FoundMany("^(string_of_int n)^")"
  | NotFound k -> "NotFound("^(string_of_int k)^")"
  | Fail msg -> "Fail:"^msg

let add table key value = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = (key - table.min) / ((table.max - table.min) / table.size) in
    Hashtbl.add table.hashtbl bucket_index (key,value) ;
    Inserted(bucket_index)

let get table key = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = key / ((table.max - table.min) / table.size) in
    match (List.filter
             (fun (k,v) -> k == key)
             (Hashtbl.find_all table.hashtbl bucket_index))
    with
    | [] -> NotFound(key)
    | (k,v)::[] -> Found v
    | _ as l -> FoundMany (List.length l)

let count table = 
  let rec count_aux table i =
    if i < table.size then
      (List.length (Hashtbl.find_all table.hashtbl i)) + (count_aux table (i + 1))
    else
      0
  in
  count_aux table 0
      
let rec range a b =
  if a == b then
    []
  else
    a :: (range (a + 1) b)

let rec string_of_bucket_content content verbose =
    if verbose then
      match content with
      | [] -> ""
      | (k,v)::[] ->  "(" ^ (string_of_int k) ^ "," ^ v ^ ")"
      | (k,v)::rest -> "(" ^ (string_of_int k) ^ "," ^ v ^ ")" ^ "," ^ (string_of_bucket_content rest verbose)
    else
      ""

let string_of_bucket table b verbose = 
  let content = Hashtbl.find_all table.hashtbl b in
  let key = string_of_int b in
  let count = List.length content in
  match content with
  | [] -> ""
  | _ ->
     "'" ^ key ^ "':{'count':" ^ (string_of_int count) ^ "}\n"

let rec visual_string_of_int = function
  | 0 -> ""
  | n -> "|" ^ (visual_string_of_int (n-1))

let string_of_bucket table b verbose = 
  let content = Hashtbl.find_all table.hashtbl b in
  let key = string_of_int b in
  let count = List.length content in
  match content with
  | [] -> ""
  | _ ->
     "'" ^ key ^ "':{'count':'" ^ (visual_string_of_int count) ^ "'}\n"
                                                        
let string_of_table table verbose = 
  "{'count':" ^ (string_of_int (count table)) ^ ",'content':{\n" ^ (List.fold_left 
             (fun a b -> a ^ (string_of_bucket table b verbose))
             "" 
             (range 0 table.size)) ^ 
    "}}"

let string_of_table_min table verbose = 
  "{'count':" ^ (string_of_int (count table)) ^ "}"
      
let show ?v:(verbose=true) table = 
  Log.info (string_of_table table verbose) ;
  flush stdout
