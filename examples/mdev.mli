type t

val create : unit -> t
val set_rgb : t -> r:int -> g:int -> b:int -> unit
val set_buzzer : t -> level:int -> unit
val set_pwm : t -> level:int -> unit
val get_sonic : t -> float

(** [set_servo1 t v] sets servo 1 to orientation [v] between 0 and 1. *)
val set_servo1 : t -> float -> unit

val set_servo2 : t -> float -> unit
val set_servo3 : t -> float -> unit
