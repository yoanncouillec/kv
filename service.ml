type index = int
type data = string

type message = 
  | Create of index * data
  | Read of index

let create_server port = 
  Log.info ("Create server");
  let addr = Unix.inet_addr_any in
  let saddr = Unix.ADDR_INET(addr,port) in
  let socket = Unix.socket (Unix.domain_of_sockaddr saddr) Unix.SOCK_STREAM 0 in
   Unix.bind socket saddr ;
   Unix.listen socket 100 ;
   socket

let accept_client socket =   
  Log.info ("Accept client");
  let client = Unix.accept socket in
  Log.info ("Client accepted");
  let channels = fst client in
  (Unix.in_channel_of_descr channels, Unix.out_channel_of_descr channels)

let connect_to_server hostname port = 
  Log.info ("Connect to server");
  let socket = Unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  let address = Unix.inet_addr_of_string hostname in 
  Unix.connect socket (Unix.ADDR_INET(address, port));
  (Unix.in_channel_of_descr socket, Unix.out_channel_of_descr socket)

let send outc msg =
  Marshal.to_channel outc msg [] ;
  flush outc

let receive inc =
  Marshal.from_channel inc;


