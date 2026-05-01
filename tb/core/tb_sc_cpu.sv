`timescale 1ps/1ps

module tb_sc_cpu();

    logic clk, reset_n;

    sc_cpu sc_cpu(
        .clk(clk),
        .reset_n(reset_n)
    );

    initial $readmemh("tb/core/program.hex", sc_cpu.instruction_memory.memo);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/cpu.vcd");
        $dumpvars(0, tb_sc_cpu);
    end

    // Tap memory bus (all combinational outputs, stable before posedge)
    wire        mem_write = sc_cpu.mem_write;
    wire [31:0] mem_addr  = sc_cpu.alu_res;
    wire [31:0] mem_wdata = sc_cpu.rs2_data;

    // PicoRV32 test protocol: PASS writes "OK\n", FAIL writes "ERROR\n" to 0x10000000
    logic [7:0] prev_char = 8'h00;

    always @(posedge clk) begin
        if (mem_write && mem_addr == 32'h10000000) begin
            $write("%c\n", mem_wdata[7:0]);
            if (prev_char == "O" && mem_wdata[7:0] == "K") begin //Display all register that are not 0
                $display("");
                $finish;
            end
            prev_char <= mem_wdata[7:0];
        end
    end

    initial begin
        reset_n = 0;
        repeat(2) @(posedge clk);
        reset_n = 1;
        $readmemh("tb/core/program.hex", sc_cpu.data_memory.mem);
        repeat(1000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end


    always @(posedge clk) begin
        if (reset_n)
            $display("PC=%0h  INSTR=%0h  mw=%b  addr=%0h  wdata=%0h x28=%0d", //register 28 holds current test
                sc_cpu.pc_current, sc_cpu.instruction,
                mem_write, mem_addr, mem_wdata, sc_cpu.register_file.regi[28]);
    end


endmodule
