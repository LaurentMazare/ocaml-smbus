module B = Smbus.Bus

(* Example code for the Freenove 3-wheeled smartcar.
 https://github.com/Freenove/Freenove_Three-wheeled_Smart_Car_Kit_for_Raspberry_Pi
*)

type command =
  | IO1
  | IO2
  | IO3

let command_to_int = function
  | IO1 -> 9
  | IO2 -> 10
  | IO3 -> 11

let set_rgb bus ~r ~g ~b=
  B.write_word_data bus (command_to_int IO1) r;
  B.write_word_data bus (command_to_int IO2) g;
  B.write_word_data bus (command_to_int IO3) b

let () =
  let b = B.create 1 in
  B.set_address b 0x18 ~force:false;
  set_rgb b ~r:0 ~g:1 ~b:1;
  Unix.sleep 3;
  set_rgb b ~r:1 ~g:0 ~b:1;
  Unix.sleep 3;
  set_rgb b ~r:1 ~g:1 ~b:0;
  Unix.sleep 3;
  set_rgb b ~r:1 ~g:1 ~b:1;
  B.close b
