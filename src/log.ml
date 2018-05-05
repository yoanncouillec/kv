let logfile = ref stdout

let output_endline c s = 
  output_string c (s^"\n")

let init lf = 
  logfile := open_out lf

let string_of_time tm =
  let t = Unix.gmtime tm in
  let us = int_of_float (1000000.0 *. (tm -. (float_of_int (int_of_float tm)))) in
  (string_of_int (1900 + t.tm_year))^"-"^(if t.tm_mon < 10 then "0" else "")^(string_of_int t.tm_mon)^"-"^(if t.tm_mday < 10 then "0" else "")^(string_of_int t.tm_mday)^" "^(if t.tm_hour < 10 then "0" else "")^(string_of_int t.tm_hour)^":"^(if t.tm_min < 10 then "0" else "")^(string_of_int t.tm_min)^":"^((if t.tm_sec < 10 then "0" else "")^(string_of_int t.tm_sec))^"."^(string_of_int us)

let log level file line msg = 
  output_endline (!logfile) ((string_of_time (Unix.gettimeofday()))^"|"^level^"|"^file^":"^(string_of_int line)^"|"^msg);
  flush (!logfile)

let info file line = 
  log "INFO" file line
