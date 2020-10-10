.align 2
.equ UART_BASE,         0x10010000
.equ UART_REG_TXFIFO,   0

.section .text
.globl _start

_start:
1:      auipc a0, %pcrel_hi(msg)     # load msg(hi)
        addi  a0, a0, %pcrel_lo(1b)  # load msg(lo)
2:      jal   ra, puts
3:      j     3b

puts:
        li    a5, UART_BASE
1:      lbu   a1, (a0)
        beqz  a1, 3f
2:      lw    a4, UART_REG_TXFIFO(a5)
        bltz  a4, 2b
        sw    a1, UART_REG_TXFIFO(a5)
        addi  a0, a0, 1
        j     1b
3:      ret

.section .rodata
msg:
     .string "Hello.\n"
