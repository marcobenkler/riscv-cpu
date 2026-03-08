`timescale 1ps/1ps

module tb_alu();

    //Input
    logic [31:0] a, b;
    logic [4:0] shift;
    logic [3:0] alu_op;

    //Output
    logic [31:0] result;

    alu_top dut (.*);

    initial begin

        // ADD
        a = 32'd5; b = 32'd7; alu_op = 4'd0; #10;
        assert(result == 32'd12) else $fatal("ADD failed");

        // SUB
        a = 32'd10; b = 32'd3; alu_op = 4'd1; #10;
        assert(result == 32'd7) else $fatal("SUB failed");

        // AND
        a = 32'hF0F0; b = 32'h0FF0; alu_op = 4'd2; #10;
        assert(result == 32'h00F0) else $fatal("AND failed");

        // OR
        a = 32'hF0F0; b = 32'h0FF0; alu_op = 4'd3; #10;
        assert(result == 32'hFFF0) else $fatal("OR failed");

        // XOR
        a = 32'hAAAA; b = 32'h5555; alu_op = 4'd4; #10;
        assert(result == 32'hFFFF) else $fatal("XOR failed");

        // SLL
        a = 32'h1; shift = 5'd4; alu_op = 4'd5; #10;
        assert(result == 32'h10) else $fatal("SLL failed");

        // SRL
        a = 32'h10; shift = 5'd4; alu_op = 4'd6; #10;
        assert(result == 32'h1) else $fatal("SRL failed");

        // SRA
        a = 32'hF0000000; shift = 5'd4; alu_op = 4'd7; #10;
        assert(result == 32'hFF000000) else $fatal("SRA failed");

        // SLT (signed)
        a = -5; b = 3; alu_op = 4'd8; #10;
        assert(result == 32'd1) else $fatal("SLT failed");

        // SLTU (unsigned)
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = 4'd9; #10;
        assert(result == 32'd0) else $fatal("SLTU failed");

    $display("All ALU tests passed");
    $finish;
    end

    initial begin
        $dumpfile("/sim/alu/alu.vcd");
        $dumpvars(0, tb_alu);
    end

endmodule