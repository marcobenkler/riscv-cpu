        .section .init
        .global _start

_start:
.option push                        /*push pop work like brackets, norelax disables optimization, else gp stays 0*/
.option norelax
        la gp, __global_pointer$
.option pop

        la sp, _stack_top
    
        la t0, _bss_start
        la t1, _bss_end
        bgeu t0, t1, set_mtvec

bss:
        sw zero, 0(t0)
        addi t0, t0, 4
        bltu t0, t1, bss

set_mtvec:
        la t0, freertos_risc_v_trap_handler
        csrw mtvec, t0

        call main
loop:   
        j loop