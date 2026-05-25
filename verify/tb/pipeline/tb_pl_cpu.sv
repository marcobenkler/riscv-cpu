`timescale 1ps/1ps

module tb_pl_cpu();

    logic clk, reset_n;
    string itest_file;
    string dtest_file;

    pl_cpu pl_cpu(.clk(clk), .reset_n(reset_n));

    initial clk = 0;
    always #5 clk = ~clk;

    // Most tests: tohost at 0x1000. ld_st has tohost at 0x2000.
    localparam TOHOST_ADDR_A = 32'h1000;
    localparam TOHOST_ADDR_B = 32'h2000;

    wire        mem_write  = pl_cpu.ex_mem_out.mem_write;
    wire [31:0] mem_addr   = pl_cpu.ex_mem_out.ex_res;
    wire [31:0] mem_wdata  = pl_cpu.ex_mem_out.rs2_data;
    wire [2:0]  mem_s_type = pl_cpu.ex_mem_out.mem_s_type;

    initial begin
        if (!$value$plusargs("itest=%s", itest_file)) itest_file = "program.hex";
        if (!$value$plusargs("dtest=%s", dtest_file)) dtest_file = "program.byte.hex";

        $readmemh(itest_file, pl_cpu.instruction_memory.memo);
        $readmemh(dtest_file, pl_cpu.data_memory.mem);

        reset_n = 0;
        repeat(2) @(posedge clk);
        reset_n = 1;

        repeat(10000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end

    

    always @(posedge clk) begin
    $display("PC=0x%h instr=0x%h x30=0x%h x31=0x%h mepc=0x%h", 
             pl_cpu.if_id_in.pc_current, 
             pl_cpu.instruction_memory.instruction,
             pl_cpu.register_file.regi[30],
             pl_cpu.register_file.regi[31],
             pl_cpu.csr_regfile.mepc);

             $display("PC=0x%h instr=0x%h csr_res=0x%h res_src=0x%h fwd_a=%b fwd_b=%b",
         pl_cpu.if_id_in.pc_current,
         pl_cpu.instruction_memory.instruction,
         pl_cpu.csr_regfile.csr_res,
         pl_cpu.ex_mem_out.res_src,
         pl_cpu.forward_a,
         pl_cpu.forward_b);

end

    always @(posedge clk) begin
        $display("PC=0x%h instr=0x%h mcause=0x%h mret=0x%h", pl_cpu.if_id_in.pc_current, pl_cpu.instruction_memory.instruction, pl_cpu.csr_regfile.mcause, pl_cpu.mret_taken);
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
    if (mem_write && mem_addr == 32'h1000)
        $display("tohost write: gp=0x%h", mem_wdata);
    end

    always @(posedge clk) begin
    if (pl_cpu.trap_taken)
        $display("TRAP: mepc=0x%h mtval=0x%h mcause=0x%h pc=0x%h", 
                 pl_cpu.csr_regfile.mepc, 
                 pl_cpu.csr_regfile.mtval,
                 pl_cpu.csr_regfile.mcause,
                 pl_cpu.ex_mem_out.pc_current);
    end

    always @(posedge clk) begin
        if (mem_write && (mem_addr == TOHOST_ADDR_A ||
                          (mem_addr == TOHOST_ADDR_B && mem_s_type == 3'b010 && mem_wdata < 32'h1000))) begin
            if (mem_wdata == 32'h1)
                $display("PASS");
            else
                $display("FAIL (test=%0d)", mem_wdata >> 1);
            $finish;
        end
    end

endmodule
