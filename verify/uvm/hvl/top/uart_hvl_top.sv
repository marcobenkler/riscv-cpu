`timescale 1ns/1ps

module uart_hvl_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    // import uart_test_pkg::*; dont include custom pkg, always through .f file
    initial begin
        run_test();
    end
endmodule
