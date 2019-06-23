type t

(** [create id] opens i2c device /dev/i2c-id. *)
val create : int -> t
val close : t -> unit

val set_address : t -> int -> force:bool -> unit
val read_byte : t -> int
val read_byte_data : t -> int -> int
val write_byte : t -> int -> unit
val write_word_data : t -> int -> int -> unit
