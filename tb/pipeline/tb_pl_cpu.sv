`timescale 1ps/1ps

module tb_pl_cpu();

    logic clk, reset_n;

    pl_cpu pl_cpu(
        .clk(clk),
        .reset_n(reset_n)
    );

    initial $readmemh("tb/core/program.hex", pl_cpu.instruction_memory.memo);

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/pip_cpu.vcd");
        $dumpvars(0, tb_pl_cpu);
    end

    // Tap memory bus at MEM stage (ex_mem_out holds stable values at posedge)
    wire        mem_write = pl_cpu.ex_mem_out.mem_write;
    wire [31:0] mem_addr  = pl_cpu.ex_mem_out.ex_res;
    wire [31:0] mem_wdata = pl_cpu.ex_mem_out.rs2_data;

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
        $readmemh("tb/core/program.hex", pl_cpu.data_memory.mem);
        repeat(1000) @(posedge clk);
        $display("TIMEOUT");
        $finish;
    end


    always @(posedge clk) begin
        if (reset_n)
            $display("PC=%0h ra_reg=%0h sp_reg=%0h gp_reg=%0h t4_reg=%0h", //register 28 holds current test
                pl_cpu.if_id_in.pc_current, pl_cpu.register_file.regi[1], pl_cpu.register_file.regi[2], pl_cpu.register_file.regi[3], pl_cpu.register_file.regi[29]);
    end


endmodule
