(* Example code for the Freenove 3-wheeled smartcar.
 https://github.com/Freenove/Freenove_Three-wheeled_Smart_Car_Kit_for_Raspberry_Pi
*)

open Smbus

module Command = struct
  type t =
    | Servo1
    | Servo2
    | Servo3
    | Servo4
    | Pwm1
    | Pwm2
    | Dir1
    | Dir2
    | Buzzer
    | Io1
    | Io2
    | Io3
    | Sonic1
    | Sonic2

  let to_int = function
    | Servo1 -> 0
    | Servo2 -> 1
    | Servo3 -> 2
    | Servo4 -> 3
    | Pwm1 -> 4
    | Pwm2 -> 5
    | Dir1 -> 6
    | Dir2 -> 7
    | Buzzer -> 8
    | Io1 -> 9
    | Io2 -> 10
    | Io3 -> 11
    | Sonic1 -> 12
    | Sonic2 -> 13

  let to_int t = to_int t |> Uint8.of_int_exn
end

type t =
  { bus : Bus.t
  }

let create () =
  let bus = Bus.create 1 in
  Bus.set_address bus (Uint8.of_int_exn 0x18) ~force:false;
  { bus }

let write_command t cmd v =
  Bus.write_byte t.bus (Command.to_int cmd);
  Bus.write_block_data2 t.bus (Command.to_int cmd) v

let set_rgb t ~r ~g ~b =
  write_command t Io1 (Uint16.of_int_exn r);
  write_command t Io2 (Uint16.of_int_exn b);
  write_command t Io3 (Uint16.of_int_exn g)

let set_buzzer t ~level =
  write_command t Buzzer (Uint16.of_int_exn level)

let set_pwm t ~level =
  let level =
  if level < 0
  then begin
    write_command t Dir1 Uint16.zero;
    write_command t Dir2 Uint16.zero;
    - level
  end else begin
    write_command t Dir1 Uint16.one;
    write_command t Dir2 Uint16.one;
    level
  end
  in
  write_command t Pwm1 (Uint16.of_int_exn level);
  write_command t Pwm2 (Uint16.of_int_exn level)

let get_sonic t =
  Bus.write_byte t.bus (Command.to_int Sonic1);
  let sonic1 = Bus.read_byte_data t.bus (Command.to_int Sonic1) in
  Bus.write_byte t.bus (Command.to_int Sonic2);
  let sonic2 = Bus.read_byte_data t.bus (Command.to_int Sonic2) in
  float_of_int (Uint8.to_int sonic1 * 256 + Uint8.to_int sonic2) *. 17. /. 1000.

let set_servo t cmd v =
  if v < 0. || v > 1.
  then raise (Invalid_argument "v has to be between 0 and 1");
  (* The value has to be between 500 and 2500. *)
  let v = 500. +. 2000. *. v in
  write_command t cmd (int_of_float v |> Uint16.of_int_exn)

let set_servo1 t v = set_servo t Servo1 v
let set_servo2 t v = set_servo t Servo2 v
let set_servo3 t v = set_servo t Servo3 v

let () =
  ignore (Command.Servo4, ())
