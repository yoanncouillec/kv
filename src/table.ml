type value = string

type table = 
{
  hashtbl : (int,int * value) Hashtbl.t;
  size : int;
  min : int;
  max : int
}

type result =
  | Created of int
  | NotCreated
  | Read of int
  | NotRead
  | Updated of int
  | NotUpdated
  | Deleted of int
  | NotDeleted

type exists = 
  | None of int
  | One of int * int * value
  | MoreThanOne of int

let string_of_result = function
  | Created k -> "Created "^(string_of_int k)
  | NotCreated -> "Not created"
  | Read k -> "Read "^(string_of_int k)
  | NotRead -> "Not read"
  | Updated n -> "Updated"
  | NotUpdated -> "Not updated"
  | Deleted n -> "Deleted"
  | NotDeleted -> "Not deleted"

let make size min max = 
  {
    hashtbl = Hashtbl.create size;
    size = size;
    min = min;
    max = max
  }

let exists key table =     
  let bucket_index = key / ((table.max - table.min) / table.size) in
  match (List.filter
           (fun (k,v) -> k == key)
           (Hashtbl.find_all table.hashtbl bucket_index))
  with
  | [] -> None bucket_index
  | (k,v)::[] -> One (bucket_index, k, v)
  | _ -> MoreThanOne bucket_index

let create table key value = 
  if key < table.min || table.max <= key then
    NotCreated
  else
    match exists key table with
    | None bucket_index -> Hashtbl.add table.hashtbl bucket_index (key,value) ;
                           Created key
    | _ -> NotCreated

let read table key = 
  if key < table.min || table.max <= key then
    NotRead
  else
    match exists key table with 
    | One (bucket_index, k, v) -> Read k
    | _ -> NotRead

let update table key v = 
  if key < table.min || table.max <= key then
    NotUpdated
  else
    (match exists key table with 
     | One (bucket_index, k, v) -> Hashtbl.replace table.hashtbl bucket_index (k,v) ; 
                                   Updated k
     | _ -> NotUpdated)
             
let delete table key = 
  if key < table.min || table.max <= key then
    NotDeleted
  else
    match exists key table with 
    | One (bucket_index,k,v) -> Hashtbl.remove table.hashtbl bucket_index ; 
                   Deleted k
    | _ -> NotDeleted

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
