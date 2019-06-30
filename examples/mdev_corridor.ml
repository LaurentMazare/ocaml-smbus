open Core
open Async

module Sonic_scan : sig
  type t
  val create : Mdev.t -> angles:float list -> t
  val refresh : t -> unit Deferred.t
  val distances : t -> float list
end = struct
  type t =
    { mdev : Mdev.t
    ; distances : float array
    ; angles : float list
    }

  let create mdev ~angles =
    if not (List.is_sorted angles ~compare:Float.compare)
    then raise (Invalid_argument "angles has to be sorted");
    if List.exists angles ~f:(fun angle -> Float.(<) angle 0. || Float.(>) angle 1.)
    then raise (Invalid_argument "angles have to be between 0 and 1");
    { mdev
    ; distances = Array.create ~len:(List.length angles) Float.nan
    ; angles
    }

  let get_sonic t =
    let num_samples = 10 in
    let rec loop i acc =
      if i = num_samples
      then return (acc /. Float.of_int num_samples)
      else
        let%bind () = after (Time.Span.of_sec 0.02) in
        let sonic = Mdev.get_sonic t.mdev in
        loop (i + 1) (acc +. sonic)
    in
    loop 0 0.

  let refresh t =
    Deferred.List.iteri t.angles ~f:(fun i angle ->
      Mdev.set_servo2 t.mdev angle;
      let%bind () = after (Time.Span.of_sec 0.05) in
      let%map sonic = get_sonic t in
      t.distances.(i) <- sonic)

  let distances t = Array.to_list t.distances
end

let run () =
  let mdev = Mdev.create () in
  let sonic_scan = Sonic_scan.create mdev ~angles:[0.4; 0.5; 0.6] in
  Clock_ns.every' (Time_ns.Span.of_sec 0.5) (fun () ->
    let%map () = Sonic_scan.refresh sonic_scan in
    let right_dist, center_dist, left_dist =
      match Sonic_scan.distances sonic_scan with
      | [ x; y; z ] -> x, y, z
      | _ -> assert false
    in
    Core.printf "%f %f %f\n%!" left_dist center_dist right_dist
  );
  Deferred.never ()

let () =
  Async.Command.async ~summary:"An echo server"
    (Async.Command.Param.return run)
  |> Async.Command.run
