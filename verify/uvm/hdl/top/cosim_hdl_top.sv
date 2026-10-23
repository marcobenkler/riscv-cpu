`timescale 1ns/1ps

module cosim_hdl_top;
    import uvm_pkg::*;

    logic clk;
    logic rst_n;

    retire_if retire_if_u(
        .clk(clk),
        .rst_n(rst_n),
        .rvfi_res(pl_cpu_u.rvfi_res)
    );

    pl_cpu pl_cpu_u(
        .clk(clk),
        .reset_n(rst_n)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        uvm_config_db#(virtual retire_if)::set(null, "*", "retire_if", retire_if_u);
    end

    initial begin
        rst_n <= 1'b0;
        repeat(3) @(posedge clk);
        rst_n <= 1'b1;
    end

endmodule
