open Import

type t

(** [create id] opens i2c device /dev/i2c-id. *)
val create : int -> t

val close : t -> unit
val set_address : t -> u8 -> force:bool -> unit
val read_byte : t -> u8
val read_byte_data : t -> u8 -> u8
val read_word_data : t -> u8 -> u16
val write_byte : t -> u8 -> unit
val write_byte_data : t -> u8 -> u8 -> unit
val write_word_data : t -> u8 -> u16 -> unit
val write_block_data2 : t -> u8 -> u16 -> unit
