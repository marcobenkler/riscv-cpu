OUTPUT_ARCH( riscv ) /* Tell linker which architecture is required*/
ENTRY( _start )      /* Declare the startpoint for the program (whch instruction is executed first) */
_stack_size = 1K;

MEMORY
{
    IMEM (x)     : ORIGIN = 0x00000000, LENGTH = 16K
    DMEM (rwa!x) : ORIGIN = 0x80000000, LENGTH = 32K
}

SECTIONS                    /* Each section allocates an area*/
{
    .init :                 /* congiguration instructions like load sp in x2 reg etc. */
    {
        KEEP(*(.init))      /*_start only called from hardware, linker would optimize it away*/
    } > IMEM                /* Deklare in which memory the allocation should happen */

    .text :                 /* remaining instructions in instruction memory */
    {
        . = ALIGN(4);
        *(.text .text.*)    /* allocate all data thats created from compiling */
    } > IMEM

    .rodata :               /* for const. and string in data memory */
    {
        /* . = ALIGN(4); not needed here, dmem begins at 8000_0000 and is automatically aligned*/
        *(.rodata .rodata.*)
    } > DMEM

    .data :                 /* variables with start value (gp needs them all next to each other) */
    {
        . = ALIGN(4);
        *(.data .data.*)
        __global_pointer$ = . + 0x800; /* + 0x800 to put the pointer in the center to have +- 2KiB */
        *(.sdata .sdata.*)
        *(.srodata .srodata.*)
    } > DMEM

    .bss :                  /* variables without start value */
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.sbss .sbss.*)    /* sbss must be first after .data to still be in range of gp */
        *(.bss .bss.*)
        *(COMMON)           /* all variables with no startvalue and same name from different
                               origins are put at the same place */
        . = ALIGN(4);
        _bss_end = .; 
    } >DMEM

    .stack :                /* start assembly code from start.S and main */
    {
        . = ALIGN(16);      /* just jumps on the next aligning address (inserts padding) */
        . += _stack_size;   /* add the stack size on top of the heap */
        _stack_top = .;     /* declare stack_top on top after moving . up too _stack_size */
        __freertos_irq_stack_top= .; /* Copied from freertos page */
    } >DMEM
}