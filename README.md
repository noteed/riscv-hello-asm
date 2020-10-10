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

While the resulting program works as intended, it is entirely possible that
this is some poor code.


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
Hello.
QEMU: Terminated
```

Note: the program enters an infinite loop after producing the `Hello.` text.
Type `ctrl-a x` to stop QEMU.

Note: the string `Hello.` is displayed twice, I don't know yet why (I guess
this is something that can be fixed by adding some QEMU command-line option).


## Assembly

To dissemble the program:


```
$ riscv64-unknown-elf-objdump -d hello
hello:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_start>:
    80000000:	00000517          auipc	a0,0x0
    80000004:	03450513          addi	a0,a0,52 # 80000034 <msg>
    80000008:	008000ef          jal	ra,80000010 <puts>
    8000000c:	0000006f          j	8000000c <_start+0xc>

0000000080000010 <puts>:
    80000010:	100107b7          lui	a5,0x10010
    80000014:	00054583          lbu	a1,0(a0)
    80000018:	00058c63          beqz	a1,80000030 <puts+0x20>
    8000001c:	0007a703          lw	a4,0(a5) # 10010000 <UART_BASE>
    80000020:	fe074ee3          bltz	a4,8000001c <puts+0xc>
    80000024:	00b7a023          sw	a1,0(a5)
    80000028:	00150513          addi	a0,a0,1
    8000002c:	fe9ff06f          j	80000014 <puts+0x4>
    80000030:	00008067          ret
```
