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
#include <sys/ioctl.h>

#ifndef I2C_SMBUS_WRITE
#include <linux/i2c.h>
#endif

__s32 ml_smbus(int fd, char rw, __u8 cmd,
               int size, union i2c_smbus_data *data) {
    struct i2c_smbus_ioctl_data args;
    args.read_write = rw;
    args.command = cmd;
    args.size = size;
    args.data = data;

    __s32 err;
    return ioctl(fd, I2C_SMBUS, &args);
}

void ml_i2c_smbus_write_quick(value fd, value v) {
  CAMLparam2(fd, v);
  int r = ml_smbus(Int_val(fd), Int_val(v), 0, I2C_SMBUS_QUICK, NULL);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}

CAMLprim value ml_i2c_smbus_read_byte(value fd) {
  CAMLparam1(fd);
  union i2c_smbus_data data;
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_READ, 0, I2C_SMBUS_BYTE, &data);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(data.byte & 0x0FF));
}

void ml_i2c_smbus_write_byte(value fd, value v) {
  CAMLparam2(fd, v);
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(v), I2C_SMBUS_BYTE, NULL);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}

CAMLprim value ml_i2c_smbus_read_byte_data(value fd, value cmd) {
  CAMLparam2(fd, cmd);
  union i2c_smbus_data data;
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_READ, Int_val(cmd), I2C_SMBUS_BYTE_DATA, &data);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(data.byte & 0x0FF));
}

void ml_i2c_smbus_write_byte_data(value fd, value cmd, value v) {
  CAMLparam3(fd, cmd, v);
  union i2c_smbus_data data;
  data.byte = Int_val(v);
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(cmd), I2C_SMBUS_BYTE_DATA, &data);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}

CAMLprim value ml_i2c_smbus_read_word_data(value fd, value cmd) {
  CAMLparam2(fd, cmd);
  union i2c_smbus_data data;
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_READ, Int_val(cmd), I2C_SMBUS_WORD_DATA, &data);

  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(data.word & 0x0FFFF));
}

void ml_i2c_smbus_write_word_data(value fd, value cmd, value v) {
  CAMLparam3(fd, cmd, v);
  union i2c_smbus_data data;
  data.word = Int_val(v);
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(cmd), I2C_SMBUS_WORD_DATA, &data);

  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}

CAMLprim value ml_i2c_smbus_process_call(value fd, value cmd, value v) {
  CAMLparam3(fd, cmd, v);
  union i2c_smbus_data data;
  data.word = Int_val(v);
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(cmd), I2C_SMBUS_PROC_CALL, &data);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(data.word & 0x0FFFF));
}

CAMLprim value ml_i2c_smbus_read_i2c_block_data(value fd, value cmd, value ba) {
  CAMLparam3(fd, cmd, ba);
  size_t sz = caml_ba_byte_size(Caml_ba_array_val(ba));
  if (sz > I2C_SMBUS_BLOCK_MAX) {
    caml_invalid_argument("bigarray larger than I2C_SMBUS_BLOCK_MAX");
  }
  union i2c_smbus_data data;
  data.block[0] = sz;
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_READ, Int_val(cmd), I2C_SMBUS_I2C_BLOCK_DATA, &data);
  if (r < 0) caml_failwith(strerror(errno));
  __u8* vs = Caml_ba_data_val(ba);
  for (int i = 1; i <= data.block[0]; ++i) vs[i-1] = data.block[i];
  CAMLreturn(Val_int(data.block[0]));
}

CAMLprim value ml_i2c_smbus_write_i2c_block_data(value fd, value cmd, value ba) {
  CAMLparam3(fd, cmd, ba);
  size_t sz = caml_ba_byte_size(Caml_ba_array_val(ba));
  if (sz >= I2C_SMBUS_BLOCK_MAX) {
    caml_invalid_argument("bigarray larger than I2C_SMBUS_BLOCK_MAX");
  }
  union i2c_smbus_data data;
  data.block[0] = sz;
  __u8* vs = Caml_ba_data_val(ba);
  for (int i = 1; i <= sz; ++i) data.block[i] = vs[i-1];
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(cmd), I2C_SMBUS_I2C_BLOCK_DATA, &data);
  if (r < 0) caml_failwith(strerror(errno));
  CAMLreturn(Val_int(r));
}

void ml_i2c_smbus_write_block_data2(value fd, value cmd, value v) {
  CAMLparam3(fd, cmd, v);
  union i2c_smbus_data data;
  int w = Int_val(v);
  data.block[0] = 2;
  data.block[1] = w >> 8;
  data.block[2] = w & 0x0FF;
  int r = ml_smbus(Int_val(fd), I2C_SMBUS_WRITE, Int_val(cmd), I2C_SMBUS_I2C_BLOCK_DATA, &data);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}

void ml_i2c_set_address(value fd, value addr, value force) {
  CAMLparam3(fd, addr, force);
  char address = Int_val(addr);
  unsigned long op = Bool_val(force) ? I2C_SLAVE_FORCE : I2C_SLAVE;
  int r = ioctl(Int_val(fd), op, address);
  if (r == -1) caml_failwith(strerror(errno));
  CAMLreturn0;
}
