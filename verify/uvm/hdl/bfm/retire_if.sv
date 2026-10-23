interface retire_if
    import pipeline_pkg::rvfi_t;
(
    input logic  clk,
    input logic  rst_n,
    input rvfi_t rvfi_res
);

    modport MONITOR (
        input clk, rst_n, rvfi_res
    );

endinterface
