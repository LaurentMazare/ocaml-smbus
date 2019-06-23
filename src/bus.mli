type t

(** [create id] opens i2c device /dev/i2c-id. *)
val create : int -> t
val close : t -> unit

val read_byte : t -> int
val write_byte : t -> int -> int
