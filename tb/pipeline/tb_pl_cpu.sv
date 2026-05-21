`timescale 1ps/1ps

module tb_pl_cpu();

    logic clk, reset_n;
    string test_file;

    pl_cpu pl_cpu(.clk(clk), .reset_n(reset_n));

    initial clk = 0;
    always #5 clk = ~clk;

    // tohost: 0x1000 – placed at ALIGN(0x1000) from base 0x0 in env/p/link.ld
    localparam TOHOST_ADDR = 32'h1000;

    wire        mem_write = pl_cpu.ex_mem_out.mem_write;
    wire [31:0] mem_addr  = pl_cpu.ex_mem_out.ex_res;
    wire [31:0] mem_wdata = pl_cpu.ex_mem_out.rs2_data;

    initial begin
        if (!$value$plusargs("test=%s", test_file))
            test_file = "tb/core/program.hex";

        $readmemh(test_file, pl_cpu.instruction_memory.memo);
        $readmemh(test_file, pl_cpu.data_memory.mem);

        reset_n = 0;
        repeat(2) @(posedge clk);
        reset_n = 1;

        repeat(10000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end

    always @(posedge clk) begin
        $display("PC=0x%h instr=0x%h mcause=0x%h", pl_cpu.if_id_in.pc_current, pl_cpu.instruction_memory.instruction, pl_cpu.csr_regfile.mcause);
    end

    always @(posedge clk) begin
        if (mem_write) begin
            $display("MEM WRITE: addr=0x%h data=0x%h", mem_addr, mem_wdata);
        end
    end

    always @(posedge clk) begin
    if (pl_cpu.csr_regfile.trap_taken)
        $display("TRAP! PC=0x%h mcause=0x%h", 
                 pl_cpu.if_id_in.pc_current, pl_cpu.csr_regfile.mcause);
    end

    always @(posedge clk) begin
        if (mem_write && mem_addr == TOHOST_ADDR) begin
            if (mem_wdata == 32'h1)
                $display("PASS");
            else
                $display("FAIL (test=%0d)", mem_wdata >> 1);
            $finish;
        end
    end

endmodule
