let () =
  let mdev = Mdev.create () in
  let cmd =
    match Sys.argv with
    | [| _ |] | [| _; "blink" |] -> `blink
    | [| _; "buzzer" |] -> `buzzer
    | [| _; "forward" |] -> `forward
    | [| _; "servo" |] -> `servo
    | [| _; "sonic" |] -> `sonic
    | [| _; "sonic-scan" |] -> `sonic_scan
    | _ -> failwith "usage: mdev.exe blink|buzzer|forward|..."
  in
  match cmd with
  | `blink ->
    Mdev.set_rgb mdev ~r:0 ~g:1 ~b:1;
    Unix.sleep 3;
    Mdev.set_rgb mdev ~r:1 ~g:0 ~b:1;
    Unix.sleep 3;
    Mdev.set_rgb mdev ~r:1 ~g:1 ~b:0;
    Unix.sleep 3;
    Mdev.set_rgb mdev ~r:1 ~g:1 ~b:1
  | `buzzer ->
    Mdev.set_buzzer mdev ~level:3000;
    Unix.sleep 1;
    Mdev.set_buzzer mdev ~level:0
  | `forward ->
    Mdev.set_pwm mdev ~level:1000;
    Unix.sleep 1;
    Mdev.set_pwm mdev ~level:0
  | `servo ->
    for d = 0 to 100 do
      Mdev.set_servo1 mdev (float_of_int d /. 100.);
      Unix.sleepf 0.01
    done;
    Mdev.set_servo1 mdev 0.5
  | `sonic ->
    for d = 0 to 25 do
      let sonic = Mdev.get_sonic mdev in
      Printf.printf "%2d %f\n%!" d sonic;
      Unix.sleepf 0.04
    done
  | `sonic_scan ->
    Mdev.set_rgb mdev ~r:0 ~g:1 ~b:1;
    for d = 0 to 100 do
      Mdev.set_servo2 mdev (float_of_int d /. 100.);
      let sonic = Mdev.get_sonic mdev in
      Printf.printf "%2d %f\n%!" d sonic;
      Unix.sleepf 0.01
    done;
    Mdev.set_servo2 mdev 0.5;
    Mdev.set_rgb mdev ~r:1 ~g:1 ~b:1
