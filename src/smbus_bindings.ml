open Bigarray
open Import

type 'kind buffer = ('a, 'b, c_layout) Array1.t constraint 'kind = ('a, 'b) kind
type int8 = (int, int8_unsigned_elt) kind
type fd = Unix.file_descr

external i2c_smbus_write_quick : fd -> u8 -> unit = "ml_i2c_smbus_write_quick"
external i2c_smbus_read_byte : fd -> u8 = "ml_i2c_smbus_read_byte"
external i2c_smbus_write_byte : fd -> u8 -> unit = "ml_i2c_smbus_write_byte"
external i2c_smbus_read_byte_data : fd -> u8 -> u8 = "ml_i2c_smbus_read_byte_data"

external i2c_smbus_write_byte_data
  :  fd
  -> u8
  -> u8
  -> unit
  = "ml_i2c_smbus_write_byte_data"

external i2c_smbus_read_word_data : fd -> u8 -> u16 = "ml_i2c_smbus_read_word_data"

external i2c_smbus_write_word_data
  :  fd
  -> u8
  -> u16
  -> unit
  = "ml_i2c_smbus_write_word_data"

external i2c_smbus_process_call : fd -> u8 -> u16 -> u8 = "ml_i2c_smbus_process_call"

external i2c_smbus_read_i2c_block_data
  :  fd
  -> u8
  -> int8 buffer
  -> int
  = "ml_i2c_smbus_read_i2c_block_data"

external i2c_smbus_write_i2c_block_data
  :  fd
  -> u8
  -> int8 buffer
  -> int
  = "ml_i2c_smbus_write_i2c_block_data"

external i2c_smbus_write_block_data2
  :  fd
  -> u8
  -> u16
  -> unit
  = "ml_i2c_smbus_write_block_data2"

external i2c_set_address : fd -> u8 -> bool -> unit = "ml_i2c_set_address"
