`timescale 1ns/1ps

module uart_loopback_hdl_top;
    import uvm_pkg::*;

    logic clk;
    logic rst_n;
    logic line;

    uart_bfm bfm_rx(
        .clk(clk),
        .rst_n(rst_n),
        .line_in(line),
        .line_out(line)
    );

    uart_bfm bfm_tx(
        .clk(clk),
        .rst_n(rst_n),
        .line_in(line),
        .line_out()
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst_n = 0;
        repeat(3) @(posedge clk);
        rst_n = 1;
        repeat(3) @(posedge clk);
        uvm_config_db#(virtual uart_bfm)::set(null, "*", "bfm_rx", bfm_rx);
        uvm_config_db#(virtual uart_bfm)::set(null, "*", "bfm_tx", bfm_tx);
    end

endmodule
