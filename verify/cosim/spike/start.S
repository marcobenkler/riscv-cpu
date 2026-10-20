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
        la t0, trap_handler
        csrw mtvec, t0

        call main

end:
        li t1, 1
        sw t1, tohost, t0 //t0 at the end is a temp register, where aupic stores the addr of tohost

loop:
        j loop

        .align 2 //write next label on address thats subtractable by 2^2=4
trap_handler:
        csrr t1, mcause //load cause in t1 reg
        addi t1, t1, 1  //0 would mean test success
        slli t1, t1, 1 //shift to make room for end mask
        ori  t1, t1, 1 //mask program end
        sw   t1, tohost, t0 //write in tohost, spike knows program is done

trap_loop:
        j trap_loop