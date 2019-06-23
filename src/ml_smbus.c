#include <assert.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/fail.h>
#include <caml/bigarray.h>

#include <linux/i2c-dev.h>
#include <i2c/smbus.h>
#include <sys/ioctl.h>

CAMLprim value ml_i2c_smbus_write_quick(value file, value v) {
  CAMLparam2(file, v);
  int r = i2c_smbus_write_quick(Int_val(file), Int_val(v));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_read_byte(value file) {
  CAMLparam1(file);
  int r = i2c_smbus_read_byte(Int_val(file));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_write_byte(value file, value v) {
  CAMLparam2(file, v);
  int r = i2c_smbus_write_byte(Int_val(file), Int_val(v));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_read_byte_data(value file, value command) {
  CAMLparam2(file, command);
  int r = i2c_smbus_read_byte_data(Int_val(file), Int_val(command));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_write_byte_data(value file, value command, value v) {
  CAMLparam3(file, command, v);
  int r = i2c_smbus_write_byte_data(Int_val(file), Int_val(command), Int_val(v));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_read_word_data(value file, value command) {
  CAMLparam2(file, command);
  int r = i2c_smbus_read_word_data(Int_val(file), Int_val(command));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_write_word_data(value file, value command, value v) {
  CAMLparam3(file, command, v);
  int r = i2c_smbus_write_word_data(Int_val(file), Int_val(command), Int_val(v));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_process_call(value file, value command, value v) {
  CAMLparam3(file, command, v);
  int r = i2c_smbus_process_call(Int_val(file), Int_val(command), Int_val(v));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_read_i2c_block_data(value file, value command, value ba) {
  CAMLparam3(file, command, ba);
  size_t sz = caml_ba_byte_size(Caml_ba_array_val(ba));
  if (sz >= 256) {
    caml_invalid_argument("bigarray length has to be less than 256");
  }
  int r = i2c_smbus_read_i2c_block_data(Int_val(file), Int_val(command), sz, Caml_ba_data_val(ba));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_smbus_write_i2c_block_data(value file, value command, value ba) {
  CAMLparam3(file, command, ba);
  size_t sz = caml_ba_byte_size(Caml_ba_array_val(ba));
  if (sz >= 256) {
    caml_invalid_argument("bigarray length has to be less than 256");
  }
  int r = i2c_smbus_write_i2c_block_data(Int_val(file), Int_val(command), sz, Caml_ba_data_val(ba));
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

CAMLprim value ml_i2c_set_address(value file, value addr, value force) {
  CAMLparam3(file, addr, force);
  char address = Int_val(addr);
  unsigned long op = Bool_val(force) ? I2C_SLAVE_FORCE : I2C_SLAVE;
  int r = ioctl(Int_val(file), op, address);
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}
