open Core
open Async

let debug = true

module Mdev = struct
  include Mdev

  let set_pwm t ~level =
    if debug then Core.printf "set-pwm %d\n%!" level else set_pwm t ~level

  let set_servo1 t angle =
    if debug then Core.printf "set-servo1 %f\n%!" angle else set_servo1 t angle
end

module Sonic_scan : sig
  type t

  val create_and_start
    :  Mdev.t
    -> angles:float list
    -> refresh_rate:Time_ns.Span.t
    -> stop:unit Ivar.t
    -> t

  val distances : t -> float list
end = struct
  type t =
    { mdev : Mdev.t
    ; distances : float array
    ; angles : float list
    }

  let create_and_start mdev ~angles ~refresh_rate ~stop =
    if not (List.is_sorted angles ~compare:Float.compare)
    then raise (Invalid_argument "angles has to be sorted");
    if List.exists angles ~f:(fun angle -> Float.( < ) angle 0. || Float.( > ) angle 1.)
    then raise (Invalid_argument "angles have to be between 0 and 1");
    let t =
      { mdev; distances = Array.create ~len:(List.length angles) Float.nan; angles }
    in
    Clock_ns.every' refresh_rate ~stop:(Ivar.read stop) (fun () ->
        Deferred.List.iteri angles ~f:(fun i angle ->
            Mdev.set_servo2 t.mdev angle;
            let%map () = after (Time.Span.of_sec 0.05) in
            t.distances.(i) <- Mdev.get_sonic t.mdev));
    t

  let distances t = Array.to_list t.distances
end

let run () =
  let stop = Ivar.create () in
  let mdev = Mdev.create () in
  let sonic_scan =
    Sonic_scan.create_and_start
      mdev
      ~angles:[ 0.4; 0.5; 0.6 ]
      ~refresh_rate:(Time_ns.Span.of_sec 0.25)
      ~stop
  in
  Clock_ns.every (Time_ns.Span.of_sec 0.5) (fun () ->
      let right_dist, center_dist, left_dist =
        match Sonic_scan.distances sonic_scan with
        | [ x; y; z ] -> x, y, z
        | _ -> assert false
      in
      Core.printf "%f %f %f\n%!" left_dist center_dist right_dist;
      let action =
        if Float.( < ) center_dist 20.
        then `stop
        else if Float.( > ) center_dist 100.
        then `forward
        else if Float.( < ) right_dist left_dist
        then `forward_turn 0.6
        else `forward_turn 0.4
      in
      match action with
      | `stop ->
        Mdev.set_pwm mdev ~level:0;
        Ivar.fill_if_empty stop ()
      | `forward -> Mdev.set_pwm mdev ~level:1000
      | `forward_turn angle ->
        Mdev.set_pwm mdev ~level:700;
        Mdev.set_servo1 mdev angle);
  Ivar.read stop

let () =
  Async.Command.async ~summary:"An echo server" (Async.Command.Param.return run)
  |> Async.Command.run
