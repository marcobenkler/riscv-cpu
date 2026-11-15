module tb_hazard_integration();

    logic clk;
    logic reset_n;

    pl_cpu pl_cpu(.clk(clk), .reset_n(reset_n));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
    reset_n = 0;

    // lw x1, 0(x0)  => 32'h00002083
    pl_cpu.instruction_memory.memo[0]  = 8'h83;
    pl_cpu.instruction_memory.memo[1]  = 8'h20;
    pl_cpu.instruction_memory.memo[2]  = 8'h00;
    pl_cpu.instruction_memory.memo[3]  = 8'h00;

    // add x2, x1, x0  => 32'h00008133  (load-use hazard on x1)
    pl_cpu.instruction_memory.memo[4]  = 8'h33;
    pl_cpu.instruction_memory.memo[5]  = 8'h81;
    pl_cpu.instruction_memory.memo[6]  = 8'h00;
    pl_cpu.instruction_memory.memo[7]  = 8'h00;

    // lw x3, 0(x0)  => 32'h00002183
    pl_cpu.instruction_memory.memo[8]  = 8'h83;
    pl_cpu.instruction_memory.memo[9]  = 8'h21;
    pl_cpu.instruction_memory.memo[10] = 8'h00;
    pl_cpu.instruction_memory.memo[11] = 8'h00;

    // add x4, x3, x3  => 32'h00318233  (load-use hazard on x3)
    pl_cpu.instruction_memory.memo[12] = 8'h33;
    pl_cpu.instruction_memory.memo[13] = 8'h82;
    pl_cpu.instruction_memory.memo[14] = 8'h31;
    pl_cpu.instruction_memory.memo[15] = 8'h00;

    // lw x5, 0(x0)  => 32'h00002283
    pl_cpu.instruction_memory.memo[16] = 8'h83;
    pl_cpu.instruction_memory.memo[17] = 8'h22;
    pl_cpu.instruction_memory.memo[18] = 8'h00;
    pl_cpu.instruction_memory.memo[19] = 8'h00;

    // add x6, x5, x5  => 32'h00528333  (load-use hazard rs1 and rs2)
    pl_cpu.instruction_memory.memo[20] = 8'h33;
    pl_cpu.instruction_memory.memo[21] = 8'h83;
    pl_cpu.instruction_memory.memo[22] = 8'h52;
    pl_cpu.instruction_memory.memo[23] = 8'h00;

    // addi x7, x0, 1  => 32'h00100393  (no hazard)
    pl_cpu.instruction_memory.memo[24] = 8'h93;
    pl_cpu.instruction_memory.memo[25] = 8'h03;
    pl_cpu.instruction_memory.memo[26] = 8'h10;
    pl_cpu.instruction_memory.memo[27] = 8'h00;

    // addi x8, x0, 2  => 32'h00200413  (no hazard)
    pl_cpu.instruction_memory.memo[28] = 8'h13;
    pl_cpu.instruction_memory.memo[29] = 8'h04;
    pl_cpu.instruction_memory.memo[30] = 8'h20;
    pl_cpu.instruction_memory.memo[31] = 8'h00;

    repeat(2) @(posedge clk);
    reset_n = 1;
    repeat(100) @(posedge clk);
    $display("DONE");
    $finish;
end

endmodule