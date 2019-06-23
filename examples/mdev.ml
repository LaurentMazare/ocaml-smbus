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

module Bot = struct
  type t =
    { bus : Bus.t
    }

  let create () =
    let bus = Bus.create 1 in
    Bus.set_address bus (Uint8.of_int_exn 0x18) ~force:false;
    { bus }

  let write_command t cmd v =
    Bus.write_word_data t.bus (Command.to_int cmd) v

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
end

let () =
  let bot = Bot.create () in
  let cmd =
    match Sys.argv with
    | [| _ |] | [| _; "blink" |] -> `blink
    | [| _; "buzzer" |] -> `buzzer
    | [| _; "forward" |] -> `forward
    | _ -> failwith "usage: mdev.exe blink|buzzer|forward|..."
  in
  match cmd with
  | `blink ->
      Bot.set_rgb bot ~r:0 ~g:1 ~b:1;
      Unix.sleep 3;
      Bot.set_rgb bot ~r:1 ~g:0 ~b:1;
      Unix.sleep 3;
      Bot.set_rgb bot ~r:1 ~g:1 ~b:0;
      Unix.sleep 3;
      Bot.set_rgb bot ~r:1 ~g:1 ~b:1
  | `buzzer ->
      Bot.set_buzzer bot ~level:3000;
      Unix.sleep 1;
      Bot.set_buzzer bot ~level:0
  | `forward ->
      Bot.set_pwm bot ~level:1000;
      Unix.sleep 1;
      Bot.set_pwm bot ~level:0
