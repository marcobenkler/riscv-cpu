.section .text
.global _start

_start:
    li sp, 0xFF

    lui x1, 0x10000
    li  x2, 0x41
    sw  x2, 0(x1)

wait:
    lw x3, 4(x1)
    andi x3, x3, 1
    beqz x3, wait

done:
    j done