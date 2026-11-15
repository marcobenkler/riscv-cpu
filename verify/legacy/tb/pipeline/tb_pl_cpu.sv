`timescale 1ps/1ps

module tb_pl_cpu();

    logic clk, reset_n;
    string itest_file, dtest_file;
    logic [31:0] tohost_addr;

    pl_cpu pl_cpu(.clk(clk), .reset_n(reset_n));
    defparam pl_cpu.update_pc.RESET_VECTOR = 32'h8000_0000;
    defparam pl_cpu.axi_interconnect_u.MEM_HIGHT = 32'h0000_FFFF;   // 64 KB

    initial clk = 0;
    always #5 clk = ~clk;

    wire        mem_write = pl_cpu.ex_mem_out.mem_write;
    wire [31:0] mem_addr  = pl_cpu.ex_mem_out.ex_res;
    wire [31:0] mem_wdata = pl_cpu.ex_mem_out.rs2_data;

    initial begin
        if (!$value$plusargs("itest=%s", itest_file)) itest_file = "program.hex";
        if (!$value$plusargs("dtest=%s", dtest_file)) dtest_file = "program.hex";
        if (!$value$plusargs("tohost=%h", tohost_addr)) tohost_addr = 32'h8000_1000;

        $readmemh(itest_file, pl_cpu.instruction_memory.memo);
        $readmemh(dtest_file, pl_cpu.mem_u.mem);

        reset_n = 0;
        repeat(2) @(posedge clk);
        reset_n = 1;

        repeat(200000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end

    always @(posedge clk) begin
        if (reset_n && mem_write && mem_addr == tohost_addr) begin
            if (mem_wdata == 32'h1) $display("PASS");
            else                    $display("FAIL (test=%0d)", mem_wdata >> 1);
            $finish;
        end
    end

endmodule