interface pipe_if(
    input logic clk,
    input logic rst_n
);

    modport mon (
        input clk, rst_n,
        // Transaction
        input req_vld, addr, store_data, store_type, load_data, out_vld, is_store,
        // Control
        input stall, flush, //lsu_stall,
        // Except information
        input lsu_exception, mcause, mtval
    );

    modport drv (
        input clk, rst_n,
        // Transaction
        input  req_vld, addr, store_data, store_type, is_store,
        output load_data, out_vld,
        // Control
        input  stall, flush,
        //output lsu_stall,
        // Except information
        output lsu_exception, mcause, mtval
    );

endinterface
