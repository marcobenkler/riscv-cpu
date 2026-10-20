interface retire_if(
    input logic clk,
    input logic rst_n,
    input rvfi rvfi_res
);

    modport MONITOR (
        input clk, rst_n, rvfi_res
    );

endinterface
