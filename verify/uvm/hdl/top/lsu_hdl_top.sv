`timescale 1ns/1ps

module lsu_hdl_top;

    logic clk;
    logic rst_n;

    axil_if axil_if_u(
        .clk(clk),
        .rst_n(rst_n)
    );

    axil_sub_bfm axil_sub_bfm_u(
        .bus(axil_if_u)
    );

    lsu lsu_u(

    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        uvm_config_db#(virtual axil_sub_bfm)::set(null, "*", "axil_sub_bfm", axil_sub_bfm_u);
        uvm_config_db#(virtual axil_mon_bfm)::set(null, "*", "axil_mon_bfm", axil_mon_bfm_u);
        //axil_mgr_bfm
    end

    initial begin
        rst_n <= 1'b0;
        repeat(3) @(posedge clk);
        rst_n <= 1'b1;
    end

endmodule
