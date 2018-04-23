type value = string

type table = 
{
  hashtbl : (int,int * value) Hashtbl.t;
  size : int;
  min : int;
  max : int
}

type result =
  | Nil
  | Element of value

let make size min max = 
  {
    hashtbl = Hashtbl.create size;
    size = size;
    min = min;
    max = max
  }
    
let create table key value = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = (key - table.min) / ((table.max - table.min) / table.size) in
    Hashtbl.add table.hashtbl bucket_index (key,value) ;
    Nil

let read table key = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = key / ((table.max - table.min) / table.size) in
    match (List.filter
             (fun (k,v) -> k == key)
             (Hashtbl.find_all table.hashtbl bucket_index))
    with
    | [] -> failwith "Not found"
    | (k,v)::[] -> Element v
    | _ -> failwith "too many values"

let update table key v = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = key / ((table.max - table.min) / table.size) in
    match (List.filter
             (fun (k,v) -> k == key)
             (Hashtbl.find_all table.hashtbl bucket_index))
    with
    | [] -> failwith "Not found"
    | (k,v)::[] -> Hashtbl.replace table.hashtbl bucket_index (k,v) ; Nil
    | _ -> failwith "too many values"

let delete table key = 
  if key < table.min || table.max <= key then
    failwith "Out of bounds"
  else
    let bucket_index = key / ((table.max - table.min) / table.size) in
    match (List.filter
             (fun (k,v) -> k == key)
             (Hashtbl.find_all table.hashtbl bucket_index))
    with
    | [] -> failwith "Not found"
    | (k,v)::[] -> Hashtbl.remove table.hashtbl bucket_index ; Nil
    | _ -> failwith "too many values"

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

let rec string_of_bucket_content = function
  | [] -> ""
  | (k,v)::[] ->  "(" ^ (string_of_int k) ^ "," ^ v ^ ")"
  | (k,v)::rest -> "(" ^ (string_of_int k) ^ "," ^ v ^ ")" ^ "," ^ (string_of_bucket_content rest)

let string_of_bucket table b = 
  let content = Hashtbl.find_all table.hashtbl b in
  match content with
  | [] -> ""
  | _ -> "[" ^ (string_of_int b) ^ "=>" ^ (string_of_int (List.length content)) ^ (string_of_bucket_content content) ^ "]"

let string_of_table table = 
  "{" ^ (string_of_int (count table)) ^ (List.fold_left 
             (fun a b -> a ^ (string_of_bucket table b))
             "" 
             (range 0 table.size)) ^ 
    "}"
      
let show table = 
  print_endline (string_of_table table) ;
  flush stdout
