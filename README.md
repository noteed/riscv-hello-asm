# Bare metal RISC-V assembly hello world

This is a bare metal 64-bit RISC-V assembly program outputing `Hello.`. It is
compiled with the riscv-gnu-toolchain and can be run with the QEMU `sifive_u`
and `sifive_e` machines.

I searched for such a program on the Internet but the only examples I found
were either bare metal C, or assembly but relying on an OS. Eventually I took
the bare metal hello program from the
[riscv-probe](https://github.com/michaeljclark/riscv-probe) repository and
stripped everything I could. [The
result](https://github.com/noteed/riscv-hello-c) can be disassembled and serve
as a guide to adapt other hello world examples.


## Toolchain

I'm using Nix and use a toolchain provided by Nixpkgs's [cross-compiling
infrastructure](https://nixos.wiki/wiki/Cross_Compiling). This repository
contains a `shell.nix` file, and the example commands in this README can be
followed with either `nix-shell --attr riscv64` for the `sifive_u` case, or
`nix-shell --attr riscv32` for the `sifive_e` case.

Someone seems to have success with the SiFive binaries as seen in [the first
issue](https://github.com/noteed/riscv-hello-asm/issues/1).


## Building for the `sifive_u` machine

Assuming the toolchain is in the `$PATH`, running the following produces our
`hello` program.

```
$ riscv64-unknown-linux-gnu-gcc -march=rv64g -mabi=lp64 -static -mcmodel=medany \
  -fvisibility=hidden -nostdlib -nostartfiles -Tsifive_u/hello.ld -Isifive_u \
  hello.s -o hello
```

The result is a 64-bit RISC-V binary compatible with QEMU `sifive_u` machine.

```
$ file hello
hello: ELF 64-bit LSB executable, UCB RISC-V, version 1 (SYSV), statically
linked, not stripped
```

Run it with:

```
$ qemu-system-riscv64 -nographic -machine sifive_u -bios none -kernel hello
Hello.
QEMU: Terminated
```

Note: the program enters an infinite loop after producing the `Hello.` text.
Type `ctrl-a x` to stop QEMU.


## Building for the `sifive_e` machine

This program can be compiled for more resticted machines like `sifive_e`
that support 32-bit RISC-V, have small amount of RAM and require executable
code to be placed in ROM with different start address.

Assuming the toolchain is in the `$PATH`, running the following produces our
`hello` program, but now ready for `sifive_e`.

```
$ riscv32-none-elf-gcc -march=rv32g -mabi=ilp32 -static -mcmodel=medany \
  -fvisibility=hidden -nostdlib -nostartfiles -Tsifive_e/hello.ld -Isifive_e \
  hello.s -o hello
```

Note: using either `riscv32-none-elf-gcc` or `riscv64-unknown-linux-gnu-gcc`
works.

Run it with:

```
$ qemu-system-riscv32 -nographic -machine sifive_e -bios none -kernel hello
Hello.
QEMU: Terminated
```

Note: the program enters an infinite loop after producing the `Hello.` text.
Type `ctrl-a x` to stop QEMU.


## Assembly

To disassemble the program (here the the one for the `sifive_u` machine):


```
$ riscv64-unknown-elf-objdump -d hello
hello:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_start>:
    80000000:	f14022f3         csrr	t0,mhartid
    80000004:	00029c63         bnez	t0,8000001c <halt>
    80000008:	00008117         auipc	sp,0x8
    8000000c:	04410113         addi	sp,sp,68 # 8000804c <_end>
    80000010:	00000517         auipc	a0,0x0
    80000014:	03450513         addi	a0,a0,52 # 80000044 <msg>
    80000018:	008000ef         jal	ra,80000020 <puts>

000000008000001c <halt>:
    8000001c:	0000006f         j	8000001c <halt>

0000000080000020 <puts>:
    80000020:	100102b7         lui	t0,0x10010
    80000024:	00054303         lbu	t1,0(a0)
    80000028:	00030c63         beqz	t1,80000040 <puts+0x20>
    8000002c:	0002a383         lw	t2,0(t0) # 10010000 <UART_BASE>
    80000030:	fe03cee3         bltz	t2,8000002c <puts+0xc>
    80000034:	0062a023         sw	t1,0(t0)
    80000038:	00150513         addi	a0,a0,1
    8000003c:	fe9ff06f         j	80000024 <puts+0x4>
    80000040:	00008067         ret
```


## Elsewhere

Here is a link to another repository that links back to this repository, and
that may be worth checking out.

- [Bare metal RISC-V assembly in QEMU](https://github.com/rtfb/riscv64-in-qemu)
