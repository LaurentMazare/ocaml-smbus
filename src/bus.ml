type t =
  { file_descr : Unix.file_descr
  ; mutable closed : bool
  }

let create bus_id =
  let filename = Printf.sprintf "/dev/i2c-%d" bus_id in
  let file_descr = Unix.openfile filename [ O_RDWR ] 0 in
  let t =
    { file_descr
    ; closed = false
    }
  in
  Gc.finalise
    (fun t -> if not t.closed then Unix.close t.file_descr)
    t;
  t

let ensure_not_closed t =
  if t.closed
  then failwith "bus has already been closed"

let read_byte t =
  ensure_not_closed t;
  let v = Smbus_bindings.i2c_smbus_read_byte t.file_descr in
  if v < 0
  then failwith "error reading bus";
  v

let write_byte t v =
  ensure_not_closed t;
  let v = Smbus_bindings.i2c_smbus_write_byte t.file_descr v in
  if v < 0
  then failwith "error writing bus";
  v

let close t =
  Unix.close t.file_descr;
  t.closed <- true
