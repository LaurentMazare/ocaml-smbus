module type UintS = sig
  type t = private int

  val zero : t
  val one : t
  val of_int_exn : int -> t
  val to_int : t -> int
end

module Uint8 : UintS = struct
  type t = int

  let of_int_exn int =
    if int < 0 || int > 255
    then (
      let msg = Printf.sprintf "out of bounds %d" int in
      raise (Invalid_argument msg));
    int

  let to_int t = t
  let zero = 0
  let one = 1
end

module Uint16 : UintS = struct
  type t = int

  let of_int_exn int =
    if int < 0 || int > 65536
    then (
      let msg = Printf.sprintf "out of bounds %d" int in
      raise (Invalid_argument msg));
    int

  let to_int t = t
  let zero = 0
  let one = 1
end

type u8 = Uint8.t
type u16 = Uint16.t
