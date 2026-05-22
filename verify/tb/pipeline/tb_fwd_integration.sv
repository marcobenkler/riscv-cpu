module tb_fwd_integration();

    logic clk;
    logic reset_n;

    pl_cpu pl_cpu(.clk(clk), .reset_n(reset_n));

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset_n = 0;
        
        // addi x1, x0, 5  → 32'h00500093
        pl_cpu.instruction_memory.memo[0] = 8'h93;
        pl_cpu.instruction_memory.memo[1] = 8'h00;
        pl_cpu.instruction_memory.memo[2] = 8'h50;
        pl_cpu.instruction_memory.memo[3] = 8'h00;

        // add x2, x1, x1  → 32'h00108133
        pl_cpu.instruction_memory.memo[4] = 8'h33;
        pl_cpu.instruction_memory.memo[5] = 8'h81;
        pl_cpu.instruction_memory.memo[6] = 8'h10;
        pl_cpu.instruction_memory.memo[7] = 8'h00;

        // add x2, x1, x2  → 32'h00208133
        pl_cpu.instruction_memory.memo[8]  = 8'h33;
        pl_cpu.instruction_memory.memo[9]  = 8'h81;
        pl_cpu.instruction_memory.memo[10] = 8'h20;
        pl_cpu.instruction_memory.memo[11] = 8'h00;

        // NOPs
        for (int i = 12; i < 256; i++)
            pl_cpu.instruction_memory.memo[i] = 8'h00;
        // NOP = 32'h00000013
        for (int i = 12; i < 256; i += 4) begin
            pl_cpu.instruction_memory.memo[i]   = 8'h13;
            pl_cpu.instruction_memory.memo[i+1] = 8'h00;
            pl_cpu.instruction_memory.memo[i+2] = 8'h00;
            pl_cpu.instruction_memory.memo[i+3] = 8'h00;
        end
        
        repeat(2) @(posedge clk);
        reset_n = 1;

        repeat(100) @(posedge clk);
        $display("DONE");
        $finish;
    end

endmodule