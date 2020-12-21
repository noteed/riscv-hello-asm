# Bare metal RISC-V assembly hello world

This is a bare metal 64-bit RISC-V assembly program outputing `Hello.`. It is
compiled with the riscv-gnu-toolchain and can be run with the QEMU `sifive_u`
machine.

I searched for such a program on the Internet but the only examples I found
were either bare metal C, or assembly but relying on an OS. Eventually I took
the bare metal hello program from the
[riscv-probe](https://github.com/michaeljclark/riscv-probe) repository and
stripped everything I could. [The
result](https://github.com/noteed/riscv-hello-c) can be disassembled and serve
as a guide to adapt other hello world examples.


## Toolchain

I'm using Nix and the toolchain from
[github.com/bgamari/riscv.nix.git](https://github.com/bgamari/riscv.nix.git),
running it directly from the `result/bin` directory.

Someone seems to have success with the SiFive binaries as seen in [the first
issue](https://github.com/noteed/riscv-hello-asm/issues/1).


## Building

Assuming the toolchain is in the `$PATH`, running the following produce our
`hello` program.

```
$ riscv64-unknown-elf-gcc -march=rv64g -mabi=lp64 -static -mcmodel=medany \
  -fvisibility=hidden -nostdlib -nostartfiles -Thello.ld hello.s -o hello
```

The result is a 64-bit RISC-V binary.

```
$ file hello
hello: ELF 64-bit LSB executable, UCB RISC-V, version 1 (SYSV), statically
linked, not stripped
```

## Running

Run it with:

```
$ qemu-system-riscv64 -nographic -machine sifive_u -bios none -kernel hello
Hello.
QEMU: Terminated
```

Note: the program enters an infinite loop after producing the `Hello.` text.
Type `ctrl-a x` to stop QEMU.


## Assembly

To dissemble the program:


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
