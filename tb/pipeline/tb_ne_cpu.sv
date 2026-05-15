/**
 * @brief Pipeline connectivity test — no hazard handling, no branches/jumps.
 *        4 NOPs between every instruction guarantee full WB drain.
 **/

module tb_ne_cpu();

    logic clk, reset_n;

    pl_cpu pl_cpu (
        .clk    (clk),
        .reset_n(reset_n)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial $readmemh("tb/pipeline/pipeline.hex", pl_cpu.instruction_memory.memo);

    initial begin
        $dumpfile("sim/ne_cpu.vcd");
        $dumpvars(0, tb_ne_cpu);
    end

    int pass_count = 0;
    int fail_count = 0;

    task automatic check(
        input string       name,
        input logic [31:0] actual,
        input logic [31:0] expected
    );
        if (actual === expected) begin
            $display("  PASS  %-28s  got 0x%08h", name, actual);
            pass_count++;
        end else begin
            $display("  FAIL  %-28s  expected 0x%08h  got 0x%08h",
                     name, expected, actual);
            fail_count++;
        end
    endtask

    function automatic logic [31:0] rf(input int idx);
        return pl_cpu.register_file.regi[idx];
    endfunction

    function automatic logic [31:0] dmem_word(input int byte_addr);
        return {
            pl_cpu.data_memory.mem[byte_addr + 3],
            pl_cpu.data_memory.mem[byte_addr + 2],
            pl_cpu.data_memory.mem[byte_addr + 1],
            pl_cpu.data_memory.mem[byte_addr + 0]
        };
    endfunction

    initial begin
        $display("=== Pipeline Connectivity Test ===");
        $display("    (4 NOPs, no branches/jumps)");
        $display("");

        // Debug: verify hex loaded correctly
        $display("memo[0..3] = %h %h %h %h",
            pl_cpu.instruction_memory.memo[0],
            pl_cpu.instruction_memory.memo[1],
            pl_cpu.instruction_memory.memo[2],
            pl_cpu.instruction_memory.memo[3]);
        $display("");

        reset_n = 0;
        repeat(2) @(posedge clk);
        @(negedge clk);
        reset_n = 1;

        // 85 instructions + 10 drain cycles
        repeat(95) @(posedge clk);

        $display("--- ALU / Immediate ---");
        check("x1  ADDI  = 5",          rf(1),  32'd5);
        check("x2  ADDI  = 10",         rf(2),  32'd10);
        check("x3  ADD   = 15",         rf(3),  32'd15);
        check("x4  SUB   = 10",         rf(4),  32'd10);
        check("x5  AND   = 10",         rf(5),  32'd10);
        check("x6  OR    = 15",         rf(6),  32'd15);
        check("x7  XOR   = 0",          rf(7),  32'd0);
        check("x8  SLL   = 160",        rf(8),  32'd160);
        check("x9  SRL   = 5",          rf(9),  32'd5);
        check("x10 SLTI  = 1",          rf(10), 32'd1);
        check("x11 LUI   = 0x00001000", rf(11), 32'h00001000);

        $display("");
        $display("--- Upper Immediate ---");
        check("x14 AUIPC = 0x10dc",     rf(14), 32'h000010dc);

        $display("");
        $display("--- Load / Store ---");
        check("mem[0] SW word = 5",     dmem_word(0), 32'd5);
        check("x12 LW    = 5",          rf(12), 32'd5);

        $display("");
        $display("--- Sign Extension ---");
        check("x13 ADDI  = 0xFFFFFFFF", rf(13), 32'hFFFFFFFF);

        $display("");
        $display("==========================================");
        $display("  %0d passed,  %0d failed  (total %0d)",
                 pass_count, fail_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  SOME TESTS FAILED");
        $display("==========================================");

        $finish;
    end

endmodule