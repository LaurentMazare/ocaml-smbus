open Bigarray

type 'kind buffer = ('a, 'b, c_layout) Array1.t constraint 'kind = ('a, 'b) kind
type int8 = (int, int8_unsigned_elt) kind
type fd = Unix.file_descr

external i2c_smbus_write_quick : fd -> int -> int = "ml_i2c_smbus_write_quick"
external i2c_smbus_read_byte : fd -> int = "ml_i2c_smbus_read_byte"
external i2c_smbus_write_byte : fd -> int -> int = "ml_i2c_smbus_write_byte"
external i2c_smbus_read_byte_data : fd -> int -> int = "ml_i2c_smbus_read_byte_data"
external i2c_smbus_write_byte_data : fd -> int -> int -> int = "ml_i2c_smbus_write_byte_data"
external i2c_smbus_read_word_data : fd -> int -> int = "ml_i2c_smbus_read_word_data"
external i2c_smbus_write_word_data : fd -> int -> int -> int = "ml_i2c_smbus_write_word_data"
external i2c_smbus_process_call : fd -> int -> int -> int = "ml_i2c_smbus_process_call"

external i2c_smbus_read_i2c_block_data : fd -> int -> int8 buffer -> int
  = "ml_i2c_smbus_read_i2c_block_data"

external i2c_smbus_write_i2c_block_data : fd -> int -> int8 buffer -> int
  = "ml_i2c_smbus_write_i2c_block_data"

external i2c_set_address : fd -> int -> bool -> int = "ml_i2c_set_address"
