type expr =
  | EInt of int
  | EString of string
  | ECreate of expr * expr
  | ERead of expr
  | EUpdate of expr * expr
  | EDelete of expr

let eval outc = function
  | ECreate (EInt k, EString v) -> Service.send outc (Service.Create (k,v))
  | ERead (EInt k) -> Service.send outc (Service.Read (k))
  | EUpdate (EInt k, EString v) -> Service.send outc (Service.Update (k,v))
  | EDelete (EInt k) -> Service.send outc (Service.Delete (k))
  | _ -> failwith "wrong command"
