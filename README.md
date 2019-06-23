# ocaml-smbus
smbus interface for ocaml, this requires the `libi2c-dev` package on ubuntu or raspbian.

On raspbian, the `i2c/smbus.h` header does not exist but is inlined in `linux/i2c-dev.h`, to get things to compile just remove the include and also remove `-li2c` from dune (hopefully this will be handled by some configure script soon).
