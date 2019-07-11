type t =
  { file_descr : Unix.file_descr
  ; mutable closed : bool
  }

let create bus_id =
  let filename = Printf.sprintf "/dev/i2c-%d" bus_id in
  let file_descr = Unix.openfile filename [ O_RDWR ] 0 in
  let t = { file_descr; closed = false } in
  Gc.finalise (fun t -> if not t.closed then Unix.close t.file_descr) t;
  t

let ensure_not_closed t = if t.closed then failwith "bus has already been closed"

let read_byte t =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_read_byte t.file_descr

let read_byte_data t command =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_read_byte_data t.file_descr command

let read_word_data t command =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_read_word_data t.file_descr command

let write_byte t v =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_write_byte t.file_descr v

let set_address t v ~force =
  ensure_not_closed t;
  Smbus_bindings.i2c_set_address t.file_descr v force

let write_byte_data t command v =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_write_byte_data t.file_descr command v

let write_word_data t command v =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_write_word_data t.file_descr command v

let write_block_data2 t command v =
  ensure_not_closed t;
  Smbus_bindings.i2c_smbus_write_block_data2 t.file_descr command v

let close t =
  Unix.close t.file_descr;
  t.closed <- true
