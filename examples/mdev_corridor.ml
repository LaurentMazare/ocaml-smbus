open Core
open Async

let debug = false

module Mdev = struct
  let rec repeat_until_no_error f =
    try f () with
    | _ -> repeat_until_no_error f

  type t = Mdev.t

  let create = Mdev.create
  let set_rgb = Mdev.set_rgb

  let set_pwm t ~level =
    if debug
    then Core.printf "set-pwm %d\n%!" level
    else repeat_until_no_error (fun () -> Mdev.set_pwm t ~level)

  let set_servo1 t angle =
    if debug
    then Core.printf "set-servo1 %f\n%!" angle
    else repeat_until_no_error (fun () -> Mdev.set_servo1 t angle)

  let set_servo2 t angle =
    (* Print the debug message if any *and* perform the action. *)
    if debug then Core.printf "set-servo2 %f\n%!" angle;
    repeat_until_no_error (fun () -> Mdev.set_servo2 t angle)

  let get_sonic t = repeat_until_no_error (fun () -> Mdev.get_sonic t)
end

module Sonic_scan : sig
  type t

  val create_and_start
    :  Mdev.t
    -> angles:float list
    -> refresh_rate:Time_ns.Span.t
    -> stop:unit Ivar.t
    -> t Deferred.t

  val distances : t -> float list
end = struct
  type t =
    { mdev : Mdev.t
    ; distances : float Deque.t array
    ; angles : float list
    }

  let refresh t =
    Deferred.List.iteri t.angles ~f:(fun i angle ->
        Mdev.set_servo2 t.mdev angle;
        let%map () = after (Time.Span.of_sec 0.1) in
        try
          let distance = Mdev.get_sonic t.mdev in
          Deque.enqueue_front t.distances.(i) distance;
          if Deque.length t.distances.(i) > 3 then Deque.drop_back t.distances.(i)
        with
        | _ -> ())

  let create_and_start mdev ~angles ~refresh_rate ~stop =
    if not (List.is_sorted angles ~compare:Float.compare)
    then raise (Invalid_argument "angles has to be sorted");
    if List.exists angles ~f:(fun angle -> Float.( < ) angle 0. || Float.( > ) angle 1.)
    then raise (Invalid_argument "angles have to be between 0 and 1");
    let distances = Array.init (List.length angles) ~f:(fun _ -> Deque.create ()) in
    let t = { mdev; distances; angles } in
    let%map () = refresh t in
    Clock_ns.every' refresh_rate ~stop:(Ivar.read stop) (fun () -> refresh t);
    t

  let distances t =
    Array.map t.distances ~f:(fun distances ->
        match Deque.to_list distances |> List.sort ~compare:Float.compare with
        | [] -> Float.nan
        | [ l ] -> l
        | [ l1; l2 ] -> (l1 +. l2) /. 2.
        | l -> List.nth_exn l (List.length l / 2))
    |> Array.to_list
end

let run () =
  let stop = Ivar.create () in
  let mdev = Mdev.create () in
  let%bind sonic_scan =
    Sonic_scan.create_and_start
      mdev
      ~angles:[ 0.4; 0.5; 0.6 ]
      ~refresh_rate:(Time_ns.Span.of_sec 0.4)
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
        else if Float.( > ) center_dist 60.
        then `forward
        else if Float.( < ) right_dist left_dist
        then `forward_turn 0.3
        else `forward_turn 0.7
      in
      let level, angle =
        match action with
        | `stop ->
          Ivar.fill_if_empty stop ();
          0, 0.5
        | `forward -> 400, 0.5
        | `forward_turn angle -> 300, angle
      in
      Core.printf ">> %d %f\n%!" level angle;
      Mdev.set_pwm mdev ~level;
      Mdev.set_servo1 mdev angle);
  let%map () = Ivar.read stop in
  Mdev.set_rgb mdev ~r:1 ~g:1 ~b:1

let () =
  Async.Command.async ~summary:"An echo server" (Async.Command.Param.return run)
  |> Async.Command.run
